// Детектор конфликтов конвейера

module hazard_detector
(
	input  wire        clk,
	input  wire        rst,

	input  wire [31:0] f_instr,
	input  wire        f_valid,

	input  wire [31:0] d_instr,
	input  wire        d_valid,

	input  wire [31:0] e_instr,
	input  wire        e_valid,

	input  wire        jmp,

	output wire        hazard
);

wire [4:0] f_r1 = f_instr[19:15];
wire [4:0] f_r2 = f_instr[24:20];
wire [4:0] d_r1 = d_instr[19:15];
wire [4:0] d_r2 = d_instr[24:20];
wire [4:0] d_rd = d_instr[ 11:7];
wire [4:0] e_rd = e_instr[ 11:7];

// Если поступающая на конвейер команда использует значение регистра,
// который модифицируется одной из команд, находящихся на конвейере,
// то выдать сигнал hazard.
// В таком случае процессор может:
// * временно запретить приём новых команд, пока конфликт не разрешится
// * поменять команды местами, принять другую команду вместо конфликтующей
// * подставить корректное значение вместо считанного из регистра

// Проверить конфликт новой команды для стадий декодирования и выполнения
assign d_hazard = ((d_rd != 5'd0) && d_valid && (((d_rd == f_r1 || d_rd == f_r2) && f_valid)));
assign e_hazard = ((e_rd != 5'd0) && e_valid && (((e_rd == f_r1 || e_rd == f_r2) && f_valid)
	|| ((e_rd == d_r1 || e_rd == d_r2) && d_valid)));

assign hazard = d_hazard || e_hazard;

endmodule
