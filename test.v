module test;

reg         clk;
reg         rst;

wire [31:0] ib_addr;
wire [31:0] ib_data;
wire        ib_valid;
wire        ib_ready;

wire [31:0] db_addr;
wire [ 3:0] db_lanes;
wire [31:0] db_din;
wire [31:0] db_dout;
wire        db_wr;
wire        db_valid;
wire        db_ready;

wire [31:0] f_instr;
wire [31:0] f_instr_addr;
wire        f_instr_valid;
wire        f_instr_ready;

wire [31:0] d_instr;
wire [31:0] d_instr_addr;
wire [31:0] d_r1;
wire [31:0] d_r2;
wire [31:0] d_r2s;
wire [ 4:0] d_alu_op;
wire [31:0] d_jmp_addr;
wire        d_instr_valid;
wire        d_instr_ready;
wire [31:0] r5;
wire [31:0] r6;
wire [31:0] r7;
wire [31:0] r10;

wire [31:0] e_instr;
wire [31:0] e_instr_addr;
wire [31:0] e_alu_res;
wire        e_write_rd;
wire        e_instr_valid;
wire        e_instr_ready;

wire        jmp;
wire [31:0] jmp_addr;

wire        hazard;

assign e_instr_ready = 1'b1;


reg [1:0] delay;
initial delay <= 2'd0;

fetch i_fetch
(
	.clk        (clk),
	.rst        (rst),

        .ib_addr    (ib_addr),
	.ib_din     (ib_data),
        .ib_valid   (ib_valid),
        .ib_ready   (ib_ready),

	.instr      (f_instr),
	.instr_addr (f_instr_addr),
	.valid      (f_instr_valid),
	.ready      (f_instr_ready),

	.jmp        (jmp),
	.jmp_addr   (jmp_addr)
);

decode i_decode
(
	.clk        (clk),
	.rst        (rst),

	.instr      (f_instr),
	.instr_addr (f_instr_addr),
	.valid      (f_instr_valid),
	.ready      (f_instr_ready),

	.write_reg_number (e_instr[11:7]),
	.write_reg_value  (e_alu_res),
	.write_reg        (e_write_rd),

	.q_instr    (d_instr),
	.q_instr_addr   (d_instr_addr),
	.q_r1       (d_r1),
	.q_r2       (d_r2),
	.q_r2s      (d_r2s),
	.q_alu_op   (d_alu_op),
	.q_jmp_addr (d_jmp_addr),
	.q_valid    (d_instr_valid),
	.q_ready    (d_instr_ready),

	.jmp        (jmp),
	.stall      (hazard),

	.r5         (r5),
	.r6         (r6),
	.r7         (r7),
	.r10        (r10)
);

execute i_execute
(
	.clk         (clk),
	.rst         (rst),

	.instr       (d_instr),
	.instr_addr  (d_instr_addr),
	.r1          (d_r1),
	.r2          (d_r2),
	.r2s         (d_r2s),
	.alu_op      (d_alu_op),
	.jmp_addr    (d_jmp_addr),
	.valid       (d_instr_valid),
	.ready       (d_instr_ready),

	.q_instr     (e_instr),
	.q_instr_addr(e_instr_addr),
	.q_alu_res   (e_alu_res),
	.q_write_rd  (e_write_rd),
	.q_valid     (e_instr_valid),
	.q_ready     (e_instr_ready),

        .bus_addr    (db_addr),
	.bus_lanes   (db_lanes),
	.bus_din     (db_din),
	.bus_dout    (db_dout),
	.bus_wr      (db_wr),
        .bus_valid   (db_valid),
        .bus_ready   (1'b1),

	.q_jmp       (jmp),
	.q_jmp_addr  (jmp_addr)
);

hazard_detector i_hazard_detector
(
	.clk        (clk),
	.rst        (rst),

	.f_instr    (f_instr),
	.f_valid    (f_instr_valid),

	.d_instr    (d_instr),
	.d_valid    (d_instr_valid),

	.e_instr    (e_instr),
	.e_valid    (e_instr_valid),

	.jmp        (jmp),

	.hazard     (hazard)
);

rom i_rom
(
	.clk        (clk),

        .ibus_addr  (ib_addr),
	.ibus_data  (ib_data),
	.ibus_valid (ib_valid),
	.ibus_ready (ib_ready)
);

integer cycle;
integer count;

initial
begin
	cycle <= 0;
	count <= 0;
	wait(rst);
	$display("CYCLE  ROM               VR  FETCH             VR  DECODE            VR  EXECUTE           V  JMP HAZ COUNT  T0       T1       T2       A0");
	forever
	begin
		cycle = cycle + 1;
		@(posedge clk);

		if (e_instr_valid)
			count = count + 1;

		$display("%5d  %x:%x %1d%1d  %x:%x %1d%1d  %x:%x %1d%1d  %x:%x %1d  %1d   %1d    %4d  %x %x %x %x",
			cycle, ib_addr, ib_data, ib_valid, ib_ready,
			f_instr_addr, f_instr, f_instr_valid, f_instr_ready,
			d_instr_addr, d_instr, d_instr_valid, d_instr_ready,
			e_instr_addr, e_instr, e_instr_valid, jmp, hazard, count,
			r5, r6, r7, r10);

		if (db_valid)
		begin
			if (db_wr)
			begin
				$display("Write(%x, %4b, %x)", db_addr, db_lanes, db_dout);
				if (db_dout == 32'h213d05)
				begin
					$display("PASS");
					$finish;
				end
			end
		end
	end
end

// Период тактового сигнала
parameter CLK_PERIOD = 10;

// Генерация тактового сигнала
initial
begin
	clk <= 0;
	rst <= 0;
	#(CLK_PERIOD);
	rst <= 1;
	#(CLK_PERIOD);
	rst <= 0;
	#(CLK_PERIOD);
	forever begin
		#(CLK_PERIOD/2) clk <= ~clk;
	end
end

// Таймаут
initial
begin
	repeat(1000) @(posedge clk);
	$finish;
end

endmodule
