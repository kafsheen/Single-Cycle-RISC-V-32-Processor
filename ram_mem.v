module ram_memory #(
    parameter DEPTH = 256,
    parameter WIDTH = 32
)(
    input  wire                      clk,
    input  wire                      wr_en,
    input  wire [$clog2(DEPTH)-1:0]  addr,
    input  wire [WIDTH-1:0]          wr_data,
    output wire [WIDTH-1:0]          rd_data
);

(* ram_style = "block" *) reg [WIDTH-1:0] mem [0:DEPTH-1];

initial begin
    // Program — word-addressed 32-bit instructions
    // BRAM uninitialised entries default to 0 automatically
    mem[0]  = 32'h20100AF0;  // addi $s0, $0, 0x0AF0
    mem[1]  = 32'h201104B0;  // addi $s1, $0, 0x04B0
    mem[2]  = 32'h02119020;  // add  $s2, $s0, $s1
    mem[3]  = 32'h20080FA0;  // addi $t0, $0, 0x0FA0
    mem[4]  = 32'h12480001;  // beq  $s2, $t0, NEXT1
    mem[5]  = 32'h08000016;  // j    ERROR
    mem[6]  = 32'h02119822;  // sub  $s3, $s0, $s1
    mem[7]  = 32'h20090640;  // addi $t1, $0, 0x0640
    mem[8]  = 32'h12690001;  // beq  $s3, $t1, NEXT2
    mem[9]  = 32'h08000016;  // j    ERROR
    mem[10] = 32'h0211A024;  // and  $s4, $s0, $s1
    mem[11] = 32'h200A00B0;  // addi $t2, $0, 0x00B0
    mem[12] = 32'h128A0001;  // beq  $s4, $t2, NEXT3
    mem[13] = 32'h08000016;  // j    ERROR
    mem[14] = 32'h0211A825;  // or   $s5, $s0, $s1
    mem[15] = 32'h200B0EF0;  // addi $t3, $0, 0x0EF0
    mem[16] = 32'h12AB0001;  // beq  $s5, $t3, NEXT4
    mem[17] = 32'h08000016;  // j    ERROR
    mem[18] = 32'h200C0064;  // addi $t4, $0, 0x0064
    mem[19] = 32'hAD900032;  // sw   $s0, 50($t4)
    mem[20] = 32'h8D8D0032;  // lw   $t5, 50($t4)
    mem[21] = 32'h120D0002;  // beq  $s0, $t5, DONE
    mem[22] = 32'h2010DEAD;  // addi $s0, $0, 0xDEAD  (ERROR)
    mem[23] = 32'h08000018;  // j    SKIP
    mem[24] = 32'h2010D08E;  // addi $s0, $0, 0xD08E  (DONE)
    mem[25] = 32'h00000000;  // nop                   (SKIP)
end

// Synchronous write
always @(posedge clk) begin
    if (wr_en)
        mem[addr] <= wr_data;
end

// Asynchronous read — Vivado infers BRAM with async read port
assign rd_data = mem[addr];

endmodule