`include "cpu.vh"

module alu
(
	input  wire [31:0] instr,
	input  wire [31:0] instr_addr,
	input  wire [31:0] r1,
	input  wire [31:0] r2,
	input  wire [ 4:0] op,

	output reg  [31:0] result
);

wire [31:0] s_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
wire [31:0] i_imm = {{20{instr[31]}}, instr[31:20]};
wire [31:0] u_imm = {instr[31:12], 12'h000};

always @*
begin
	case (op)
		`ALU_ADD:    result = r1 + r2;
		`ALU_SUB:    result = r1 - r2;
		`ALU_AND:    result = r1 & r2;
		`ALU_OR:     result = r1 | r2;
		`ALU_XOR:    result = r1 ^ r2;
		`ALU_SLL:    result = r1 << r2[4:0];
		`ALU_SRL:    result = r1 >> r2[4:0];
		`ALU_SRA:    result = r1 >>> r2[4:0];
		`ALU_MUL:    result = r1 * r2;
		`ALU_MULH:   result = ($signed(r1) * $signed(r2)) >> 32;
		`ALU_MULHSU: result = ($signed(r1) * r2) >> 32;
		`ALU_MULHU:  result = (r1 * r2) >> 32;
		`ALU_DIV:    result = $signed(r1) / $signed(r2);
		`ALU_DIVU:   result = r1 / r2;
		`ALU_REM:    result = $signed(r1) % $signed(r2);
		`ALU_REMU:   result = r1 % r2;
		`ALU_LUI:    result = u_imm;
		`ALU_AUIPC:  result = instr_addr + u_imm;
		`ALU_JAL:    result = instr_addr;
		`ALU_SADDR:  result = r1 + s_imm;
		`ALU_SEQ:    result = r1 == r2;
		`ALU_SNE:    result = r1 != r2;
		`ALU_SLT:    result = $signed(r1) < $signed(r2);
		`ALU_SLTU:   result = r1 < r2;
		`ALU_SGE:    result = $signed(r1) >= $signed(r2);
		`ALU_SGEU:   result = r1 >= r2;
		default:     result = r1 + r2;
	endcase
end

endmodule
