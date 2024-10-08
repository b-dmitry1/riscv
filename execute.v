`include "cpu.vh"

module execute
(
	input  wire        clk,
	input  wire        rst,

	input  wire [31:0] instr,
	input  wire [31:0] instr_addr,
	input  wire [31:0] next_instr_addr,
	input  wire [31:0] r1,
	input  wire [31:0] r2,
	input  wire [31:0] r2s,
	input  wire [ 4:0] alu_op,
	input  wire [31:0] jmp_addr,
	input  wire        valid,
	output wire        ready,

	output reg  [31:0] q_instr,
	output reg  [31:0] q_instr_addr,
	output reg  [31:0] q_alu_res,
	output reg         q_write_rd,
	output reg  [31:0] q_jmp_addr,
	output reg         q_jmp,

	output wire [31:0] bus_addr,
	output wire [ 3:0] bus_lanes,
	input  wire [31:0] bus_din,
	output wire [31:0] bus_dout,
	output wire        bus_wr,
	output wire        bus_valid,
	input  wire        bus_ready,

	output reg         q_valid,
	input  wire        q_ready
);

wire [31:0] s_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
wire [31:0] i_imm = {{20{instr[31]}}, instr[31:20]};
wire [31:0] u_imm = {instr[31:12], 12'h000};

assign ready = 1'b1;

wire [31:0] alu_res;
alu i_alu
(
	.instr(instr),
	.instr_addr(instr_addr),
	.r1(r1),
	.r2(r2),
	.op(alu_op),

	.result(alu_res)
);

wire [31:0] biu_res;
wire        biu_ready;
biu i_biu
(
	.clk         (clk),
	.rst         (rst),

	.instr       (instr),
	.r1          (r1),
	.r2          (r2),
	.valid       (valid),
	.ready       (biu_ready),

	.bus_addr    (bus_addr),
	.bus_lanes   (bus_lanes),
	.bus_din     (bus_din),
	.bus_dout    (bus_dout),
	.bus_wr      (bus_wr),
	.bus_valid   (bus_valid),
	.bus_ready   (bus_ready),

	.read_result (biu_res)
);

initial
begin
end

always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		q_jmp <= 1'b0;
		q_write_rd <= 1'b0;
		q_valid <= 1'b0;
	end
	else
	begin
		// Установить начальные значения, если нет готовности предыдущей
		// стадии конвейера: не выполнять переход и ничего не записывать
		// в регистровый файл
		q_jmp <= 1'b0;
		q_write_rd <= 1'b0;
		q_valid <= 1'b0;

		// Использовать полученное от декодера значение адреса перехода,
		// если не будет указано иное
		q_jmp_addr <= jmp_addr;

		// Проверить готовность предыдущей стадии конвейера
		if (valid && ready && q_ready && !q_jmp)
		begin
			// Сохранить результат вычисления АЛУ, чтобы в следующем такте
			// записать его в регистровый файл
			q_alu_res <= alu_res;

			// Если для сохранения результата выбран не нулевой регистр rd,
			// и инструкция предусматривает запись результата в регистр rd,
			// то записать вычисленное АЛУ значение на следующем такте
			q_write_rd <=
				instr[11:7] != 5'd0 &&
				instr[6:0] != 7'h63 && // Bxx
				instr[6:0] != 7'h23 && // Sx
				instr[6:0] != 7'h0F;   // FENCE

			// JAL
			if (instr[6:0] == 7'h6F)
				q_jmp <= jmp_addr != next_instr_addr;

			// Bxx
			if (instr[6:0] == 7'h63)
			begin
				q_jmp <= jmp_addr != next_instr_addr || !alu_res[0];
				q_jmp_addr <= !alu_res[0] ? instr_addr + 3'd4 : jmp_addr;
			end

			// Передать код и адрес инструкции в следующую стадию, если она будет
			q_instr <= instr;
			q_instr_addr <= instr_addr;

			q_valid <= !q_jmp;
		end
	end
end

endmodule
