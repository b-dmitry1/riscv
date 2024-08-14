// Быстрое ПЗУ с задержкой меньше 1 такта

module rom
(
	input  wire        clk,

	// Сигналы чтения памяти команд
        input  wire [31:0] ibus_addr,
	output wire [31:0] ibus_data,
	input  wire        ibus_valid,
	output wire        ibus_ready
);

	// Блок памяти ПЗУ
	reg [31:0] mem [0:1023];
	initial $readmemh ("test_programs/hazard/program.hex", mem);

	// Немедленно выдать код инструкции
	assign ibus_data  = mem[ibus_addr >> 2];

	// ПЗУ всегда готово
	assign ibus_ready = 1'b1;

endmodule
