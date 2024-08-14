module fetch
(
	input  wire        clk,
	input  wire        rst,

	// Шина чтения инструкций
	output wire [31:0] ib_addr,
	input  wire [31:0] ib_din,
	output wire        ib_valid,
	input  wire        ib_ready,

	output wire [31:0] instr,
	output wire [31:0] instr_addr,
	output wire        valid,
	input  wire        ready,

	input  wire        jmp,
	input  wire [31:0] jmp_addr
);

reg [31:0] pc;

reg [31:0] fifo_instr      [0:1];
reg [31:0] fifo_instr_addr [0:1];
reg        fifo_rp;
reg        fifo_wp;
reg [ 1:0] fifo_count;

reg        skip_next_instr;

wire fifo_empty = fifo_count == 2'b00;
wire fifo_full  = fifo_count[1];

assign ib_addr = pc;
assign ib_valid = !fifo_full;

assign instr = fifo_instr[fifo_rp];
assign instr_addr = fifo_instr_addr[fifo_rp];
assign valid = !fifo_empty;

wire [31:0] bp_next_addr;
branch_predictor i_branch_predictor
(
	.instr(ib_din),
	.instr_addr(ib_addr),

	.next_addr(bp_next_addr)
);

initial
begin
	pc <= 32'h0;
	fifo_rp <= 1'b0;
	fifo_wp <= 1'b0;
	fifo_count <= 2'd0;
	skip_next_instr <= 1'b0;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		pc <= 32'h0;
		fifo_rp <= 1'b0;
		fifo_wp <= 1'b0;
		fifo_count <= 2'd0;
		skip_next_instr <= 1'b0;
	end
	else
	begin
		if (jmp)
		begin
			pc <= jmp_addr;

			fifo_wp <= fifo_rp;
			fifo_count <= 2'b0;

			// Если команда перехода пришла во время чтения инструкции,
			// и ПЗУ не готово, то пропустить следующую инструкцию,
			// она по неправильному адресу считана
			skip_next_instr <= !fifo_full;
		end
		else
		begin
			if (ib_valid && ib_ready)
			begin
				skip_next_instr <= 1'b0;
				if (!skip_next_instr)
				begin
					pc <= bp_next_addr; // pc + 3'd4;
					fifo_instr_addr[fifo_wp] <= ib_addr;
					fifo_instr[fifo_wp] <= ib_din;
					fifo_wp <= fifo_wp + 1'b1;
					if (!ready || !valid)
						fifo_count <= fifo_count + 2'd1;
				end
			end

			if (valid && ready)
			begin
				fifo_rp <= fifo_rp + 1'b1;
				if (!ib_ready || !ib_valid || skip_next_instr)
					fifo_count <= fifo_count - 2'd1;
			end
		end
	end
end

endmodule
