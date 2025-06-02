`timescale 1ns / 1ps

module tb_afifo();
    localparam DATA_WIDTH = 32;
    localparam CLK_PERIOD = 10;
    localparam STEP = 13;

    logic clk_r, clk_w, arst, re_i, we_i;
    logic empty, full;
    logic [DATA_WIDTH - 1:0] data_r, data_w;

    `ifdef USE_POWER_PINS
        wire VPWR, VGND;
        assign VPWR = 1;
        assign VGND = 0;
    `endif

    afifo #(DATA_WIDTH) UUT(.*);

    initial begin
        $dumpfile("tb_afifo.vcd");
        $dumpvars(0, tb_afifo);
        clk_r = 0;
        clk_w = 0;
    end

    always #(CLK_PERIOD / 2) clk_r = ~clk_r;
    always #(CLK_PERIOD * 0.7) clk_w = ~clk_w;

    always begin
        arst = 1;
        re_i = 0;
        we_i = 0;

        #STEP;
        arst = 0;
        data_w = 32'hfeedbeef;

        #STEP;
        we_i = 1;

        #STEP;
        data_w = 32'hdeadbeef;

        #STEP
        data_w = 32'hdeaddead;

        #STEP
        data_w = 32'hbeefbeef;

        #STEP;
        re_i = 1;
        data_w = 32'hfeedfeed;

        #(STEP * 7);
        $finish();
    end
endmodule
