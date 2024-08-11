`include "cpu.vh"

module biu
(
	input  wire        clk,
	input  wire        rst,

	input  wire [31:0] instr,
	input  wire [31:0] r1,
	input  wire [31:0] r2,
	input  wire        valid,
	output reg         ready,

	output reg  [31:0] bus_addr,
	output reg  [ 3:0] bus_lanes,
	input  wire [31:0] bus_din,
	output reg  [31:0] bus_dout,
	output reg         bus_wr,
	output reg         bus_valid,
	input  wire        bus_ready,

	output reg  [31:0] read_result
);

wire [31:0] i_imm = {{20{instr[31]}}, instr[31:20]};
wire [31:0] s_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

initial
begin
	ready <= 1'b0;
	bus_valid <= 1'b0;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		ready <= 1'b0;
		bus_valid <= 1'b0;
	end
	else
	begin
		ready <= 1'b0;

		if (valid && !bus_valid)
		begin
			bus_addr <= instr[5] ? r1 + s_imm : r1 + i_imm;
			bus_lanes <= 4'b1111;
			bus_dout <= r2;
			bus_wr <= 1'b0;

			case ({instr[14:12], instr[6:0]})
				10'b010_0100011: // SW
				begin
					bus_wr <= 1'b1;
					bus_valid <= 1'b1;
				end
			endcase
		end

		if (bus_valid && bus_ready)
		begin
			bus_valid <= 1'b0;
			ready <= 1'b1;
		end
	end
end

endmodule
