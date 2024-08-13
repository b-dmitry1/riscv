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

wire [31:0] addr = instr[5] ? r1 + s_imm : r1 + i_imm;

reg unaligned;
reg [3:0] next_lanes;

initial
begin
	ready <= 1'b0;
	bus_valid <= 1'b0;
	unaligned <= 1'b0;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		ready <= 1'b0;
		bus_valid <= 1'b0;
		unaligned <= 1'b0;
	end
	else
	begin
		ready <= 1'b0;

		if (valid && !bus_valid)
		begin
			bus_addr <= addr;
			bus_wr <= 1'b0;
			bus_lanes <= 4'b1111;
			unaligned <= 1'b0;

			case ({instr[14:12], instr[6:0]})
				10'b010_0000011: // LW
				begin
					bus_valid <= 1'b1;
				end
				10'b000_0100011: // SB
				begin
					// Записать только нужный байт 32-битного слова
					bus_dout <= {4{r2[7:0]}};
					bus_lanes[0] <= addr[1:0] == 2'b00;
					bus_lanes[1] <= addr[1:0] == 2'b01;
					bus_lanes[2] <= addr[1:0] == 2'b10;
					bus_lanes[3] <= addr[1:0] == 2'b11;
					bus_wr <= 1'b1;
					bus_valid <= 1'b1;
				end
				10'b001_0100011: // SH
				begin
					case (addr[1:0])
						2'b00:
						begin
							bus_dout <= {2{r2[15:0]}};
							bus_lanes <= 4'b0011;
						end
						2'b01:
						begin
							bus_dout <= {r2[7:0], r2[15:0], r2[15:8]};
							bus_lanes <= 4'b0110;
						end
						2'b10:
						begin
							bus_dout <= {2{r2[15:0]}};
							bus_lanes <= 4'b1100;
						end
						2'b11:
						begin
							bus_dout <= {r2[7:0], r2[15:0], r2[15:8]};
							bus_lanes <= 4'b1000;
							next_lanes <= 4'b0111;
							unaligned <= 1'b1;
						end
					endcase
					bus_wr <= 1'b1;
					bus_valid <= 1'b1;
				end
				10'b010_0100011: // SW
				begin
					case (addr[1:0])
						2'b00:
						begin
							bus_dout   <= r2;
							bus_lanes  <= 4'b1111;
						end
						2'b01:
						begin
							bus_dout   <= {r2[23:0], r2[31:24]};
							bus_lanes  <= 4'b1110;
							next_lanes <= 4'b0001;
							unaligned  <= 1'b1;
						end
						2'b10:
						begin
							bus_dout   <= {r2[15:0], r2[31:16]};
							bus_lanes  <= 4'b1100;
							next_lanes <= 4'b0011;
							unaligned  <= 1'b1;
						end
						2'b11:
						begin
							bus_dout   <= {r2[7:0], r2[31:8]};
							bus_lanes  <= 4'b1000;
							next_lanes <= 4'b0111;
							unaligned  <= 1'b1;
						end
					endcase
					bus_wr <= 1'b1;
					bus_valid <= 1'b1;
				end
			endcase
		end

		if (bus_valid && bus_ready)
		begin
			bus_valid <= 1'b0;
			read_result <= bus_din;
			ready <= 1'b1;
		end
	end
end

endmodule
