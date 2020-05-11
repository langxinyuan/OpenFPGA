//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: FPGA Verilog Testbench for Top-level netlist of Design: top
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Fri Apr 17 08:24:53 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`define AUTOCHECKED_SIMULATION
module top_autocheck_sc_tb;
// ----- Local wires for global ports of FPGA fabric -----
wire [0:0] pReset;
wire [0:0] prog_clk;
wire [0:0] Reset;
wire [0:0] Test_en;
wire [0:0] clk;

// ----- Local wires for I/Os of FPGA fabric -----
wire [0:7] gfpga_pad_GPIO_Y;

reg [0:0] test_en;
reg [0:0] config_done = 1'b1;
wire [0:0] prog_clock;
reg [0:0] prog_clock_reg;
wire [0:0] op_clock;
reg [0:0] op_clock_reg;
reg [0:0] prog_reset;
reg [0:0] prog_set;
reg [0:0] greset;
reg [0:0] gset;
// ---- Configuration-chain head -----
reg [0:0] ccff_head = 0;
reg [0:0] sc_head;
// ---- Configuration-chain tail -----
wire [0:0] ccff_tail;
wire [0:0] sc_tail;

// ---- Spypads ----
wire [0:0] lut4_out_0;
wire [0:0] lut4_out_1;
wire [0:0] lut4_out_2;
wire [0:0] lut4_out_3;
wire [0:0] lut5_out_0;
wire [0:0] lut5_out_1;
wire [0:0] lut6_out_0;
wire [0:0] cc_spypad_0;
wire [0:0] cc_spypad_1;
wire [0:0] cc_spypad_2;
wire [0:0] sc_spypad_0;
wire [0:0] shiftreg_spypad_0;
wire [0:0] cout_spypad_0;
wire [0:0] perf_spypad_0;

// ----- Shared inputs -------
	reg [0:0] a;
	reg [0:0] b;

// ----- FPGA fabric outputs -------
	wire [0:0] out_c_fpga;

`ifdef AUTOCHECKED_SIMULATION

// ----- Benchmark outputs -------
	wire [0:0] out_c_benchmark;

// ----- Output vectors checking flags -------
	reg [0:0] out_c_flag;

`endif

// ----- Error counter -----
	integer nb_error= 0;
// ----- Number of clock cycles in configuration phase: 5236 -----


// ----- Begin raw programming clock signal generation -----
initial
	begin
		prog_clock_reg[0] = 1'b0;
	end
always
	begin
		#50.00000381	prog_clock_reg[0] = ~prog_clock_reg[0];
	end

// ----- End raw programming clock signal generation -----

// ----- Actual programming clock is triggered only when config_done and prog_reset are disabled -----
	assign prog_clock[0] = prog_clock_reg[0] & (~config_done[0]) & (~prog_reset[0]);

// ----- Begin raw operating clock signal generation -----
initial
	begin
		op_clock_reg[0] = 1'b0;
	end
always wait(~greset)
	begin
		#2.5	op_clock_reg[0] = ~op_clock_reg[0];
	end

// ----- End raw operating clock signal generation -----
// ----- Actual operating clock is triggered only when config_done is enabled -----
	assign op_clock[0] = op_clock_reg[0] & config_done[0];

// ----- Begin programming reset signal generation -----
initial
	begin
		prog_reset[0] = 1'b1;
	#100.0000076	prog_reset[0] = 1'b0;
	end

// ----- End programming reset signal generation -----

// ----- Begin programming set signal generation: always disabled -----
initial
	begin
		prog_set[0] = 1'b0;
	end

// ----- End programming set signal generation: always disabled -----

// ----- Begin operating reset signal generation -----
// ----- Reset signal is enabled until the first clock cycle in operation phase -----
initial
	begin
		greset[0] = 1'b1;
	#5	greset[0] = 1'b1;
	#10	greset[0] = 1'b0;
	end

// ----- End operating reset signal generation -----
// ----- Begin operating set signal generation: always disabled -----
initial
	begin
		gset[0] = 1'b0;
	end

// ----- End operating set signal generation: always disabled -----

// ----- Begin connecting global ports of FPGA fabric to stimuli -----
	assign clk[0] = op_clock[0];
	assign prog_clk[0] = prog_clock[0];
	assign Reset[0] = greset[0];
	assign pReset[0] = prog_reset[0];
	assign Test_en[0] = test_en[0];
// ----- End connecting global ports of FPGA fabric to stimuli -----
// ----- FPGA top-level module to be capsulated -----

   fpga_top FPGA_DUT (
		.pReset_pad(pReset[0]),
		.prog_clk_pad(prog_clk[0]),
		.Reset_pad(Reset[0]),
		.Test_en_pad(Test_en[0]),
		.clk_pad(clk[0]),
		.ccff_head_pad(ccff_head),
		.lut4_out_0_pad(lut4_out_0[0]),
  		.lut4_out_1_pad(lut4_out_1[0]),
  		.lut4_out_2_pad(lut4_out_2[0]),
  		.lut4_out_3_pad(lut4_out_3[0]),
  		.lut5_out_0_pad(lut5_out_0[0]),
  		.lut5_out_1_pad(lut5_out_1[0]),
  		.lut6_out_0_pad(lut6_out_0[0]),
  		.cc_spypad_0_pad(cc_spypad_0[0]),
  		.cc_spypad_1_pad(cc_spypad_1[0]),
  		.cc_spypad_2_pad(cc_spypad_2[0]),
  		.sc_spypad_0_pad(sc_spypad_0[0]),
  		.shiftreg_spypad_0_pad(shiftreg_spypad_0[0]),
 		.cout_spypad_0_pad(cout_spypad_0[0]),
  		.perf_spypad_0_pad(perf_spypad_0[0]),
		.sc_head_pad(sc_head[0]),
		.sc_tail_pad(sc_tail[0]));

  bind fpga_top inv_checker #(.enable_assertions(1), // Write 0 to disable assertions, 1 for enabling them.
				 .BS_LGT(8387),		// Bitstream length
				 .FF_n(80))		// Number of flipflop in all 4 clbs
				 sva_checker  
					(	.pReset(pReset_pad),
						.Reset(Reset_pad),
						.prog_clk(prog_clk_pad),
						.clk(clk_pad),
						.Test_en(Test_en_pad),
						.lut4_out_0(lut4_out_0[0]),
				  		.lut4_out_1(lut4_out_1[0]),
				  		.lut4_out_2(lut4_out_2[0]),
				  		.lut4_out_3(lut4_out_3[0]),
				  		.lut5_out_0(lut5_out_0[0]),
				  		.lut5_out_1(lut5_out_1[0]),
				  		.lut6_out_0(lut6_out_0[0]),
				  		.cc_spypad_0(cc_spypad_0[0]),
				  		.cc_spypad_1(cc_spypad_1[0]),
				  		.cc_spypad_2(cc_spypad_2[0]),
				  		.sc_spypad_0(sc_spypad_0[0]),
				  		.shiftreg_spypad_0(shiftreg_spypad_0[0]),
				 		.cout_spypad_0(cout_spypad_0[0]),
				  		.perf_spypad_0(perf_spypad_0[0]),
						.ccff_head(ccff_head_pad),
    						.ccff_tail_gbot_1_0(fpga_core_uut.grid_io_bottom_1_0.ccff_tail),
   						.ccff_head_gbot_2_0(fpga_core_uut.grid_io_bottom_2_0.ccff_head),
    						.ccff_head_gright_3_1(fpga_core_uut.grid_io_right_3_1.ccff_head),
   						.ccff_head_gright_3_2(fpga_core_uut.grid_io_right_3_2.ccff_head),
   						.ccff_tail_gright_3_2(fpga_core_uut.grid_io_right_3_2.ccff_tail),
  						.ccff_head_sb_2_2(fpga_core_uut.sb_2__2_.ccff_head),
   						.ccff_tail_sb_2_2(fpga_core_uut.sb_2__2_.ccff_tail),
   						.ccff_head_cbx_2_2(fpga_core_uut.cbx_2__2_.ccff_head),
   						.ccff_head_g11(fpga_core_uut.grid_clb_1_1.ccff_head),
   						.ccff_head_g21(fpga_core_uut.grid_clb_2_1.ccff_head),
   						.ccff_head_g22(fpga_core_uut.grid_clb_2_2.ccff_head),
   						.ccff_head_g12(fpga_core_uut.grid_clb_1_2.ccff_head),
						.sc_head(sc_head_pad),
						.sc_tail(sc_tail_pad),
						.sc_tail_clb_1_2(fpga_core_uut.grid_clb_1_2.top_width_0_height_0__pin_40_),
						.sc_tail_clb_1_1(fpga_core_uut.grid_clb_1_1.top_width_0_height_0__pin_40_),
						.sc_tail_clb_2_2(fpga_core_uut.grid_clb_2_2.top_width_0_height_0__pin_40_),
						.sc_tail_clb_2_1(fpga_core_uut.grid_clb_2_1.top_width_0_height_0__pin_40_),
						.cc_spypad_1_ref(fpga_core_uut.grid_io_left_0_1.ccff_tail),
						.cc_spypad_2_ref(fpga_core_uut.grid_clb_1_1.ccff_tail),
						.cout_spypad_0_ref(fpga_core_uut.grid_clb_1_1.bottom_width_0_height_0__pin_65_),
						.lut4_out_0_ref(fpga_core_uut.grid_clb_1_1.gfpga_pad_frac_lut6_spypad_lut4_spy[0]),
						.lut4_out_1_ref(fpga_core_uut.grid_clb_1_1.gfpga_pad_frac_lut6_spypad_lut4_spy[1]),
						.lut4_out_2_ref(fpga_core_uut.grid_clb_1_1.gfpga_pad_frac_lut6_spypad_lut4_spy[2]),
						.lut4_out_3_ref(fpga_core_uut.grid_clb_1_1.gfpga_pad_frac_lut6_spypad_lut4_spy[3]),
						.lut5_out_0_ref(fpga_core_uut.grid_clb_1_1.gfpga_pad_frac_lut6_spypad_lut5_spy[0]),
						.lut5_out_1_ref(fpga_core_uut.grid_clb_1_1.gfpga_pad_frac_lut6_spypad_lut5_spy[1]),
						.lut6_out_0_ref(fpga_core_uut.grid_clb_1_1.gfpga_pad_frac_lut6_spypad_lut6_spy[0]),
						.perf_spypad_0_ref(fpga_core_uut.grid_clb_1_1.top_width_0_height_0__pin_68_),
						.sc_spypad_0_ref(fpga_core_uut.grid_clb_1_1.bottom_width_0_height_0__pin_64_),
						.shiftreg_spypad_0_ref(fpga_core_uut.grid_clb_1_1.bottom_width_0_height_0__pin_67_lower),
						.ccff_tail(ccff_tail_pad));


// ----- Link BLIF Benchmark I/Os to FPGA I/Os -----
// ----- Blif Benchmark input a is mapped to FPGA IOPAD gfpga_pad_GPIO_Y[4] -----
	assign gfpga_pad_GPIO_Y[4] = a[0];
// ----- Blif Benchmark input b is mapped to FPGA IOPAD gfpga_pad_GPIO_Y[6] -----
	assign gfpga_pad_GPIO_Y[6] = b[0];
// ----- Blif Benchmark output out_c is mapped to FPGA IOPAD gfpga_pad_GPIO_Y[5] -----
	assign out_c_fpga[0] = gfpga_pad_GPIO_Y[5];
	



// ----- End bitstream loading during configuration phase -----
// ----- Input Initialization -------
	initial begin
		test_en <= 1'b1;
		out_c_flag[0] <= 1'b0;
	end
integer counter=0;
integer started=0;
// ----- Input Stimulus -------
	always@(negedge op_clock[0]) begin
		counter = counter+1;
		if (counter == 20)
			begin
				if (started !=4)
				begin
					started = started + 1;
				end
					counter = 0;
					sc_head <= 1'b1;	
			end
		else
			begin
				sc_head <= 1'b0;
			end

	end

`ifdef AUTOCHECKED_SIMULATION
// ----- Begin checking output vectors -------
// ----- Skip the first falling edge of clock, it is for initialization -------
	reg [0:0] sim_start;

	always@(negedge op_clock[0]) begin
				if ((sc_tail == 1'b1) && (counter == 19) && (started == 4))
				begin
				out_c_flag <= 1'b1;
			end else begin
				out_c_flag<= 1'b0;
			end
		
	end

	always@(posedge out_c_flag) begin
		if(out_c_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_c_fpga at time = %t", $realtime);
		end
	end

`endif

`ifdef ICARUS_SIMULATOR
// ----- Begin Icarus requirement -------
	initial begin
		$dumpfile("top_formal.vcd");
		$dumpvars(1, top_autocheck_top_tb);
	end
`endif
// ----- END Icarus requirement -------

initial begin
	sim_start[0] <= 1'b1;
	$timeformat(-9, 2, "ns", 20);
	$display("Simulation start");
// ----- Can be changed by the user for his/her need -------
	#10000
	if(nb_error == 0) begin
		$display("Simulation Succeed");
	end else begin
		$display("Simulation Failed with %d error(s)", nb_error);
	end
	$finish;
end

endmodule
// ----- END Verilog module for top_autocheck_top_tb -----
