`include "cpu.vh"

module decode
(
	input  wire        clk,
	input  wire        rst,

	input  wire [31:0] instr,
	input  wire [31:0] instr_addr,
	input  wire        valid,
	output wire        ready,

	output reg  [31:0] q_instr,
	output reg  [31:0] q_instr_addr,
	output reg  [31:0] q_r1,
	output reg  [31:0] q_r2,
	output reg  [31:0] q_r2s,
	output reg  [ 4:0] q_alu_op,
	output reg  [31:0] q_jmp_addr,
	output reg         q_valid,
	input  wire        q_ready,

	input  wire [ 4:0] write_reg_number,
	input  wire [31:0] write_reg_value,
	input  wire        write_reg,

	input  wire        jmp,
	input  wire        stall,

	output wire [31:0] r0,
	output wire [31:0] r5,
	output wire [31:0] r6,
	output wire [31:0] r7,
	output wire [31:0] r10
);

reg  [31:0] r [0:31];

assign r0 = r[0];
assign r5 = r[5];
assign r6 = r[6];
assign r7 = r[7];
assign r10 = r[10];

assign ready = (!q_valid || q_ready) && !stall;

integer i;
initial
begin
	for (i = 0; i < 32; i = i + 1)
		r[i] = 32'h0;
	q_valid = 1'b0;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		r[0] <= 32'h0;
		q_valid <= 1'b0;
	end
	else
	begin
		if (write_reg)
		begin
			r[write_reg_number] <= write_reg_value;
			// $display("r[%2d] <= %x", write_reg_number, write_reg_value);
		end

		if (valid && (!q_valid || q_ready) && !jmp && !stall)
		begin
			q_instr <= instr;
			q_instr_addr <= instr_addr;
			q_r1  <= r[instr[19:15]];
			q_r2  <= instr[5] ? r[instr[24:20]] : {{20{instr[31]}}, instr[31:20]};
			q_r2s <= r[instr[24:20]];

			q_valid <= 1'b1;

			// Декодирование команды АЛУ
			casex ({instr[30], instr[25], instr[14:12], instr[6:0]})
				12'bxx_000_0010011: q_alu_op <= `ALU_ADD;
				12'bxx_xxx_0000011: q_alu_op <= `ALU_ADD;
				12'bxx_010_0010011: q_alu_op <= `ALU_SLT;
				12'bxx_011_0010011: q_alu_op <= `ALU_SLTU;
				12'bxx_100_0010011: q_alu_op <= `ALU_XOR;
				12'bxx_110_0010011: q_alu_op <= `ALU_OR;
				12'bxx_111_0010011: q_alu_op <= `ALU_AND;
				12'bxx_001_0010011: q_alu_op <= `ALU_SLL;
				12'b0x_101_0010011: q_alu_op <= `ALU_SRL;
				12'b1x_101_0010011: q_alu_op <= `ALU_SRA;

				12'b00_000_0110011: q_alu_op <= `ALU_ADD;
				12'b10_000_0110011: q_alu_op <= `ALU_SUB;
				12'bx0_010_0110011: q_alu_op <= `ALU_SLT;
				12'bx0_011_0110011: q_alu_op <= `ALU_SLTU;
				12'bx0_100_0110011: q_alu_op <= `ALU_XOR;
				12'bx0_110_0110011: q_alu_op <= `ALU_OR;
				12'bx0_111_0110011: q_alu_op <= `ALU_AND;
				12'bx0_001_0110011: q_alu_op <= `ALU_SLL;
				12'b00_101_0110011: q_alu_op <= `ALU_SRL;
				12'b10_101_0110011: q_alu_op <= `ALU_SRA;

				12'bxx_xxx_0110111: q_alu_op <= `ALU_LUI;
				12'bxx_xxx_0010111: q_alu_op <= `ALU_AUIPC;
				12'bxx_xxx_110x111: q_alu_op <= `ALU_JAL;

				12'bxx_000_1100011: q_alu_op <= `ALU_SEQ;
				12'bxx_001_1100011: q_alu_op <= `ALU_SNE;
				12'bxx_100_1100011: q_alu_op <= `ALU_SLT;
				12'bxx_101_1100011: q_alu_op <= `ALU_SGE;
				12'bxx_110_1100011: q_alu_op <= `ALU_SLTU;
				12'bxx_111_1100011: q_alu_op <= `ALU_SGEU;

				12'b01_000_0110011: q_alu_op <= `ALU_MUL;
				12'b01_001_0110011: q_alu_op <= `ALU_MULH;
				12'b01_010_0110011: q_alu_op <= `ALU_MULHSU;
				12'b01_011_0110011: q_alu_op <= `ALU_MULHU;
				12'b01_100_0110011: q_alu_op <= `ALU_DIV;
				12'b01_101_0110011: q_alu_op <= `ALU_DIVU;
				12'b01_110_0110011: q_alu_op <= `ALU_REM;
				12'b01_111_0110011: q_alu_op <= `ALU_REMU;

				12'bxx_xxx_0100011: q_alu_op <= `ALU_SADDR;
				default:            q_alu_op <= `ALU_ADD;
			endcase

			q_jmp_addr <= instr_addr + {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
		end
		else if (q_ready)
			q_valid <= 1'b0;

	end
end

endmodule
