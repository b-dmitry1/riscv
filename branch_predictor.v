module branch_predictor
(
	input  wire [31:0] instr,
	input  wire [31:0] instr_addr,

	output wire [31:0] next_addr
);

wire [31:0] j_imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

assign next_addr = instr[6:0] == 7'h6F ? instr_addr + j_imm : instr_addr + 3'd4;

endmodule
