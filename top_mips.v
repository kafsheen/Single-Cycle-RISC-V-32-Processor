module mips_top (
    input  wire        clk,
    input  wire        rst,
    output wire [3:0]  out_led
);

wire        mem_to_reg, mem_write, branch, alu_src, reg_dst, reg_write, jump, zero;
wire [31:0] sign_imm, instr, pc, pc_plus4, pc_branch, pc_next;
wire [31:0] mem_rd_data, rd_data2, src_a, src_b, alu_result, wr_data3;
wire [4:0]  wr_addr3;
wire [2:0]  alu_control;

// PC datapath
assign pc_plus4  = pc + 4;
assign pc_branch = pc_plus4 + (sign_imm << 2);
assign pc_next   = jump            ? {pc[31:28], instr[25:0], 2'b00} :
                   (branch & zero) ? pc_branch :
                   pc_plus4;

assign src_b    = alu_src    ? sign_imm    : rd_data2;
assign wr_addr3 = reg_dst    ? instr[15:11]: instr[20:16];
assign wr_data3 = mem_to_reg ? mem_rd_data : alu_result;

// -------------------------------------------------------
// Instruction Memory
// pc[9:2] converts byte address to word address (>>2)
// wr_en tied to 0 — read only
// -------------------------------------------------------
ram_memory #(.DEPTH(256), .WIDTH(32)) instruction_mem_ins (
    .clk     (clk),
    .wr_en   (1'b0),
    .addr    (pc[9:2]),
    .wr_data (32'b0),
    .rd_data (instr)
);

// PC Register
pc_reg pc_reg_inst (
    .clk     (clk),
    .rst     (rst),
    .pc_next (pc_next),
    .pc      (pc)
);

// Register File
register_file register_file_inst (
    .clk      (clk),
    .wr_en3   (reg_write),
    .rd_addr1 (instr[25:21]),
    .rd_addr2 (instr[20:16]),
    .wr_addr3 (wr_addr3),
    .wr_data3 (wr_data3),
    .rd_data1 (src_a),
    .rd_data2 (rd_data2),
    .s0_reg   (out_led)
);

// Sign Extend
sign_extend sign_extend_inst (
    .instruction_imm (instr[15:0]),
    .sign_imm        (sign_imm)
);

// -------------------------------------------------------
// Data Memory
// alu_result[9:2] converts byte address to word address
// -------------------------------------------------------
ram_memory #(.DEPTH(256), .WIDTH(32)) data_mem (
    .clk     (clk),
    .wr_en   (mem_write),
    .addr    (alu_result[9:2]),
    .wr_data (rd_data2),
    .rd_data (mem_rd_data)
);

// ALU
alu alu_inst (
    .src_a      (src_a),
    .src_b      (src_b),
    .alu_control(alu_control),
    .zero       (zero),
    .alu_result (alu_result)
);

// Control Unit
ctrl_unit ctrl_unit_inst (
    .funct      (instr[5:0]),
    .opcode     (instr[31:26]),
    .mem_to_reg (mem_to_reg),
    .mem_write  (mem_write),
    .branch     (branch),
    .alu_control(alu_control),
    .alu_src    (alu_src),
    .reg_dst    (reg_dst),
    .reg_write  (reg_write),
    .jump       (jump)
);

endmodule