`timescale 1ns / 1ps

module synchronizer #(
    parameter WIDTH=3
) (
    input logic clk, arst,
    input logic [WIDTH:0] d_in,
    output logic [WIDTH:0] d_out
);
    logic [WIDTH:0] q1;
    always_ff @ (posedge clk) begin
        if(arst) begin
            q1 <= 0;
            d_out <= 0;
        end
        else begin
            q1 <= d_in;
            d_out <= q1;
        end
    end
endmodule
