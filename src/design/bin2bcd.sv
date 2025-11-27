module bin2bcd #(
    parameter N = 8
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [N-1:0] bin,

    output logic [3:0] bcd3,
    output logic [3:0] bcd2,
    output logic [3:0] bcd1,
    output logic [3:0] bcd0,

    output logic        done
);

    localparam TOTAL = N + 16;
    logic [TOTAL-1:0] shift;
    logic [$clog2(N+1)-1:0] count;

    typedef enum logic [1:0] {IDLE, LOAD, RUN, FINISH} state_t;
    state_t estado, next;

    always_comb begin
        next = estado;
        case (estado)
            IDLE:   if (start) next = LOAD;
            LOAD:   next = RUN;
            RUN:    if (count == 0) next = FINISH;
            FINISH: next = IDLE;
        endcase
    end

    integer i;
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            estado <= IDLE;
            done <= 0;
            shift <= 0;
            count <= 0;
        end else begin
            estado <= next;
            case (estado)
                IDLE: done <= 0;

                LOAD: begin
                    shift <= {16'b0, bin};
                    count <= N;
                end

                RUN: begin
                    for (i=0; i<4; i++) begin
                        if (shift[N+4*i +:4] >= 5)
                            shift[N+4*i +:4] <= shift[N+4*i +:4] + 3;
                    end
                    shift <= shift << 1;
                    count <= count - 1;
                end

                FINISH: done <= 1;
            endcase
        end
    end

    assign bcd3 = shift[N+12 +:4];
    assign bcd2 = shift[N+8  +:4];
    assign bcd1 = shift[N+4  +:4];
    assign bcd0 = shift[N+0  +:4];

endmodule
