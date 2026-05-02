module mips_tbench ();

//////////////////////////////////////////
parameter clk_period=10;
logic clk, rst;
logic [3:0] out_led;
//////////////////////////////////////////
initial begin
    clk=0;
    rst=0;
    mips_top_inst.pc_reg_inst.pc = 0;
    mips_top_inst.counter = 0;
    #clk_period rst=1;
end
always #(clk_period/2) clk=~clk;
//////////////////////////////////////////
mips_top mips_top_inst(
    .clk    (clk),
    //.rst    (rst),
    //.instr_wr_en (1'b0),            // To be able to do synthesis
    .out_led      (out_led)
);

endmodule