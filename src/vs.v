//`timescale 1ns / 1ps

/*
 * Copyright (c) 2024 Matt Pongsagon Vichitvejpaisal
 * SPDX-License-Identifier: Apache-2.0
 */

 // Transform coordinate

 // world: clockwise order, Y- point up, Z+ into the screen
 // screen: Y+ point down

module vs(
	input clk, 		
	input reset,
	// from vga
	input [9:0] x,
	input [9:0] y,
	// from top, set by IA
	input pc_data_ready,						// true for 1 clk	 
	input signed [15:0] x_world_v0,			// Q8.8
	input signed [15:0] y_world_v0,
	input signed [15:0] z_world_v0,
	input signed [15:0] x_world_v1,
	input signed [15:0] y_world_v1,
	input signed [15:0] z_world_v1,
	input signed [15:0] x_world_v2,
	input signed [15:0] y_world_v2,
	input signed [15:0] z_world_v2,
	input signed [15:0] x_world_v3,
	input signed [15:0] y_world_v3,
	input signed [15:0] z_world_v3,
	input signed [15:0] nx,					// Q8.8
	input signed [15:0] ny,
	input signed [15:0] nz,
	input signed [15:0] light_x,			// Q8.8
	input signed [15:0] light_y,
	input signed [15:0] light_z,
	input signed [15:0] vp_00,				// Q8.8
	input signed [15:0] vp_01,
	input signed [15:0] vp_02,
	input signed [15:0] vp_03,
	input signed [15:0] vp_10,				
	input signed [15:0] vp_11,
	input signed [15:0] vp_12,
	input signed [15:0] vp_13,
	input signed [15:0] vp_30,				
	input signed [15:0] vp_31,
	input signed [15:0] vp_32,
	input signed [15:0] vp_33,
	// to raster
	output reg [1:0] intensity,					// 2-bit intensity for each tri							
	output reg signed [19:0] y_screen_v0,		// change per frame, int20		
	output reg signed [19:0] y_screen_v1,	
	output reg signed [19:0] y_screen_v2,
	output reg signed [19:0] y_screen_v3,
	output reg signed [19:0] e0_init_t1,		// change per line, int20
	output reg signed [19:0] e1_init_t1,
	output reg signed [19:0] e2_init_t1,
	output reg signed [19:0] e0_init_t2,		// change per line, int20
	output reg signed [19:0] e1_init_t2,
	output reg signed [19:0] e2_init_t2,
	output reg signed [21:0] bar_iy,			// Q2.20
    output reg signed [21:0] bar_iy_dx,
    output reg signed [21:0] bar_iz,			
    output reg signed [21:0] bar_iz_dx,
    output reg signed [21:0] bar2_iy,			// Q2.20
    output reg signed [21:0] bar2_iy_dx,
    output reg signed [21:0] bar2_iz,			
    output reg signed [21:0] bar2_iz_dx
	);


	// for vs
	reg signed [15:0] x_clip_v0;				// Q8.8
	reg signed [15:0] x_clip_v1;
	reg signed [15:0] x_clip_v2;
	reg signed [15:0] x_clip_v3;
	reg signed [15:0] y_clip_v0;
	reg signed [15:0] y_clip_v1;
	reg signed [15:0] y_clip_v2;
	reg signed [15:0] y_clip_v3;
	reg signed [15:0] w_clip_v0;
	reg signed [15:0] w_clip_v1;
	reg signed [15:0] w_clip_v2;
	reg signed [15:0] w_clip_v3;
	reg signed [15:0] x_ndc_v0;					// Q2.14
	reg signed [15:0] x_ndc_v1;	
	reg signed [15:0] x_ndc_v2;	
	reg signed [15:0] x_ndc_v3;	
	reg signed [15:0] y_ndc_v0;	
	reg signed [15:0] y_ndc_v1;	
	reg signed [15:0] y_ndc_v2;	
	reg signed [15:0] y_ndc_v3;				
	reg signed [19:0] x_screen_v0_buff1;		// int20
	reg signed [19:0] y_screen_v0_buff1;
	reg signed [19:0] x_screen_v1_buff1;		
	reg signed [19:0] y_screen_v1_buff1;
	reg signed [19:0] x_screen_v2_buff1;		
	reg signed [19:0] y_screen_v2_buff1;
	reg signed [19:0] x_screen_v3_buff1;		
	reg signed [19:0] y_screen_v3_buff1;
	reg signed [19:0] x_screen_v0_buff2;		
	reg signed [19:0] y_screen_v0_buff2;
	reg signed [19:0] x_screen_v1_buff2;		
	reg signed [19:0] y_screen_v1_buff2;
	reg signed [19:0] x_screen_v2_buff2;		
	reg signed [19:0] y_screen_v2_buff2;
	reg signed [19:0] x_screen_v3_buff2;		
	reg signed [19:0] y_screen_v3_buff2;
	reg signed [19:0] x_screen_v0;
	reg signed [19:0] x_screen_v1;
	reg signed [19:0] x_screen_v2;
	reg signed [19:0] x_screen_v3;
	reg buff1_ready;
	reg [1:0] tmp_color;


	// used by div w
	reg signed [31:0] div_a;  
	reg signed [31:0] div_b;  
	wire signed [31:0] div_result;
    reg div_start;
	wire div_done;
	wire div_busy;
	wire div_valid;
	wire div_dbz;
	wire div_ovf;
	// Q16.16
    div div1 (.clk (clk), .rst(reset),.start(div_start),.done(div_done)
    		  ,.a(div_a),.b(div_b),.val(div_result)
    		  ,.busy(div_busy),.valid(div_valid),.dbz(div_dbz),.ovf(div_ovf));

    // used by denom, (div w and denom can be computed at the same time)
    // Q20.20
    reg signed [39:0] div2_a;  
	reg signed [39:0] div2_b;  
	wire signed [39:0] div2_result;
    reg div2_start;
	wire div2_done;
	wire div2_busy;
	wire div2_valid;
	wire div2_dbz;
	wire div2_ovf;
    div #(.WIDTH(40),.FBITS(20))div2 
    		  (.clk (clk), .rst(reset),.start(div2_start),.done(div2_done)
    		  ,.a(div2_a),.b(div2_b),.val(div2_result)
    		  ,.busy(div2_busy),.valid(div2_valid),.dbz(div2_dbz),.ovf(div2_ovf));

	// mul 22-bit used to compute ei_init, bar
	reg signed [21:0] mul_a;  
	reg signed [21:0] mul_b;  
    wire signed [43:0] mul_result;  
    reg mul_start;
    wire mul_done;
    wire mul_busy;
    wire mul_aux;
    slowmpy #(.LGNA(5),.NA(22)) mul 
    			(.i_clk (clk), .i_reset(reset), .i_stb(mul_start),.i_a(mul_a)
    			,.i_b(mul_b),.i_aux(1'b0),.o_done(mul_done),.o_p(mul_result)
    			,.o_busy(mul_busy),.o_aux(mul_aux));

    reg dot_start;
    wire dot_done;
    // use in always @(*), not infer registers (that's not what declare the signal of reg type means), 
    // it infers a multiplexer with constant assignment 
    reg signed [15:0] v1_x;			
	reg signed [15:0] v1_y;
	reg signed [15:0] v1_z;
	reg signed [15:0] v1_w;
	reg signed [15:0] v2_x;
	reg signed [15:0] v2_y;
	reg signed [15:0] v2_z;
	reg signed [15:0] v2_w;
    wire signed [15:0] dot_result;
    dot4 dot (.clk (clk), .reset(reset),.start(dot_start)
    			,.v1_x(v1_x),.v1_y(v1_y),.v1_z(v1_z),.v1_w(v1_w)
    			,.v2_x(v2_x),.v2_y(v2_y),.v2_z(v2_z),.v2_w(v2_w)
    			,.done(dot_done),.result(dot_result));
    

    
    // for compute [VP] -> div w -> [S], dot(light,n)
	reg [5:0] state_transform;		// 0-32 states
	reg signed [15:0] tmp_ndc;


	// for setting wire input to dot4 module
	always @(*) begin
		case (state_transform)
			1: begin
				v1_x = x_world_v0;
				v1_y = y_world_v0;
				v1_z = z_world_v0;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_00;
				v2_y = vp_01;
				v2_z = vp_02;
				v2_w = vp_03;
			end
			2: begin
				v1_x = x_world_v0;
				v1_y = y_world_v0;
				v1_z = z_world_v0;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_10;
				v2_y = vp_11;
				v2_z = vp_12;
				v2_w = vp_13;
			end
			3: begin
				v1_x = x_world_v0;
				v1_y = y_world_v0;
				v1_z = z_world_v0;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_30;
				v2_y = vp_31;
				v2_z = vp_32;
				v2_w = vp_33;
			end
			4: begin
				v1_x = x_world_v1;
				v1_y = y_world_v1;
				v1_z = z_world_v1;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_00;
				v2_y = vp_01;
				v2_z = vp_02;
				v2_w = vp_03;
			end
			5: begin
				v1_x = x_world_v1;
				v1_y = y_world_v1;
				v1_z = z_world_v1;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_10;
				v2_y = vp_11;
				v2_z = vp_12;
				v2_w = vp_13;
			end
			6: begin
				v1_x = x_world_v1;
				v1_y = y_world_v1;
				v1_z = z_world_v1;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_30;
				v2_y = vp_31;
				v2_z = vp_32;
				v2_w = vp_33;
			end
			7: begin
				v1_x = x_world_v2;
				v1_y = y_world_v2;
				v1_z = z_world_v2;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_00;
				v2_y = vp_01;
				v2_z = vp_02;
				v2_w = vp_03;
			end
			8: begin
				v1_x = x_world_v2;
				v1_y = y_world_v2;
				v1_z = z_world_v2;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_10;
				v2_y = vp_11;
				v2_z = vp_12;
				v2_w = vp_13;
			end
			9: begin
				v1_x = x_world_v2;
				v1_y = y_world_v2;
				v1_z = z_world_v2;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_30;
				v2_y = vp_31;
				v2_z = vp_32;
				v2_w = vp_33;
			end
			10: begin
				v1_x = x_world_v3;
				v1_y = y_world_v3;
				v1_z = z_world_v3;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_00;
				v2_y = vp_01;
				v2_z = vp_02;
				v2_w = vp_03;
			end
			11: begin
				v1_x = x_world_v3;
				v1_y = y_world_v3;
				v1_z = z_world_v3;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_10;
				v2_y = vp_11;
				v2_z = vp_12;
				v2_w = vp_13;
			end
			12: begin
				v1_x = x_world_v3;
				v1_y = y_world_v3;
				v1_z = z_world_v3;
				v1_w = 16'sb0000_0001_0000_0000;
				v2_x = vp_30;
				v2_y = vp_31;
				v2_z = vp_32;
				v2_w = vp_33;
			end
			// for dot(light,n)
			31: begin
				v1_x = nx;
				v1_y = ny;
				v1_z = nz;
				v1_w = 16'sb0000_0000_0000_0000;
				v2_x = light_x;
				v2_y = light_y;
				v2_z = light_z;
				v2_w = 16'sb0000_0000_0000_0000;
			end
			default: begin
				v1_x = 0;
				v1_y = 0;
				v1_z = 0;
				v1_w = 0;
				v2_x = 0;
				v2_y = 0;
				v2_z = 0;
				v2_w = 0;
			end
		endcase
	end


    // for compute ei_int,
    reg [1:0] state_ei_line;			// 0-
    reg [5:0] state_ei_frame;			// 0-50
    reg signed [19:0] tmp_ei_mul1;
    reg signed [19:0] tmp_ei_mul2;
    // bar_iy, bar_iz, denom
    reg signed [21:0] denom;			// Q2.20  [-1,0.999]
    reg signed [21:0] bar_iy_dy;		// Q2.20
    reg signed [21:0] bar_iz_dy;
    reg signed [21:0] denom2;			// Q2.20  [-1,0.999]
    reg signed [21:0] bar2_iy_dy;		// Q2.20
    reg signed [21:0] bar2_iz_dy;

	always @(posedge clk) begin
		if (reset) begin
			// mul, div
			div_a <= 0;
			div_b <= 0;
			div_start <= 0;
			div2_a <= 0;
			div2_b <= 0;
			div2_start <= 0;
			mul_a <= 0;
			mul_b <= 0;
			mul_start <= 0;
			// compute transform
			state_transform <= 0;
			tmp_ndc <= 0;
			tmp_color <= 0;
			// compute e0_init
			state_ei_line <= 1;
			state_ei_frame <= 0;
			tmp_ei_mul1 <= 0;
			tmp_ei_mul2 <= 0;
			// bar, denom
			denom <= 0;
			bar_iy <= 0;
		    bar_iy_dy <= 0;
		    bar_iy_dx <= 0;
		    bar_iz <= 0;
		    bar_iz_dy <= 0;
		    bar_iz_dx <= 0;
		    denom2 <= 0;
			bar2_iy <= 0;
		    bar2_iy_dy <= 0;
		    bar2_iy_dx <= 0;
		    bar2_iz <= 0;
		    bar2_iz_dy <= 0;
		    bar2_iz_dx <= 0;
			// vs
			x_clip_v0 <= 0;
			x_clip_v1 <= 0;
			x_clip_v2 <= 0;
			x_clip_v3 <= 0;
			y_clip_v0 <= 0;
			y_clip_v1 <= 0;
			y_clip_v2 <= 0;
			y_clip_v3 <= 0;
			w_clip_v0 <= 0;
			w_clip_v1 <= 0;
			w_clip_v2 <= 0;
			w_clip_v3 <= 0;
			x_ndc_v0 <= 0;
			x_ndc_v1 <= 0;
			x_ndc_v2 <= 0;
			x_ndc_v3 <= 0;
			y_ndc_v0 <= 0;
			y_ndc_v1 <= 0;
			y_ndc_v2 <= 0;
			y_ndc_v3 <= 0;
			buff1_ready <= 0;
			x_screen_v0 <= 0;
			y_screen_v0 <= 0;
			x_screen_v1 <= 0;
			y_screen_v1 <= 0;
			x_screen_v2 <= 0;
			y_screen_v2 <= 0;
			x_screen_v3 <= 0;
			y_screen_v3 <= 0;
			x_screen_v0_buff1 <= 0;
			y_screen_v0_buff1 <= 0;
			x_screen_v1_buff1 <= 0;
			y_screen_v1_buff1 <= 0;
			x_screen_v2_buff1 <= 0;
			y_screen_v2_buff1 <= 0;
			x_screen_v3_buff1 <= 0;
			y_screen_v3_buff1 <= 0;
			x_screen_v0_buff2 <= 0;
			y_screen_v0_buff2 <= 0;
			x_screen_v1_buff2 <= 0;
			y_screen_v1_buff2 <= 0;
			x_screen_v2_buff2 <= 0;
			y_screen_v2_buff2 <= 0;
			x_screen_v3_buff2 <= 0;
			y_screen_v3_buff2 <= 0;
			e0_init_t1 <= 0;
			e1_init_t1 <= 0;
			e2_init_t1 <= 0;
			e0_init_t2 <= 0;
			e1_init_t2 <= 0;
			e2_init_t2 <= 0;
			intensity <= 0;
		end
		else begin

			//////////////////////////////
			// compute [VP] -> div w -> [S], dot(light,n)
			//////////////////////////////
			case (state_transform)
				0: begin
					// wait for pc_data_ready
					if (pc_data_ready) begin
						dot_start <= 1;
						state_transform <= 1;
					end
				end
				// clip = [VP] * world
				1: begin
					dot_start <= 0;
					if (dot_done) begin
						x_clip_v0 <= dot_result;
						dot_start <= 1;
						state_transform <= 2;
					end
				end 
				2: begin
					dot_start <= 0;
					if (dot_done) begin
						y_clip_v0 <= dot_result;
						dot_start <= 1;
						state_transform <= 3;
					end
				end 
				3: begin
					dot_start <= 0;
					if (dot_done) begin
						w_clip_v0 <= dot_result;
						dot_start <= 1;
						state_transform <= 4;
					end
				end 
				4: begin
					dot_start <= 0;
					if (dot_done) begin
						x_clip_v1 <= dot_result;
						dot_start <= 1;
						state_transform <= 5;
					end
				end 
				5: begin
					dot_start <= 0;
					if (dot_done) begin
						y_clip_v1 <= dot_result;
						dot_start <= 1;
						state_transform <= 6;
					end
				end 
				6: begin
					dot_start <= 0;
					if (dot_done) begin
						w_clip_v1 <= dot_result;
						dot_start <= 1;
						state_transform <= 7;
					end
				end 
				7: begin
					dot_start <= 0;
					if (dot_done) begin
						x_clip_v2 <= dot_result;
						dot_start <= 1;
						state_transform <= 8;
					end
				end 
				8: begin
					dot_start <= 0;
					if (dot_done) begin
						y_clip_v2 <= dot_result;
						dot_start <= 1;
						state_transform <= 9;
					end
				end 
				9: begin
					dot_start <= 0;
					if (dot_done) begin
						w_clip_v2 <= dot_result;
						dot_start <= 1;
						state_transform <= 10;
					end
				end 
				10: begin
					dot_start <= 0;
					if (dot_done) begin
						x_clip_v3 <= dot_result;
						dot_start <= 1;
						state_transform <= 11;
					end
				end 
				11: begin
					dot_start <= 0;
					if (dot_done) begin
						y_clip_v3 <= dot_result;
						dot_start <= 1;
						state_transform <= 12;
					end
				end 
				12: begin
					dot_start <= 0;
					if (dot_done) begin
						w_clip_v3 <= dot_result;
						// ndc = clip.xy / clip.w
						// 		Q8.8->Q16.16 -> Q16.16 = Q16.16/Q16.16 -> Q16.16->Q2.14
						// 		signed extended[15:0] <= { {8{extend[7]}}, extend[7:0] };
						div_a <= { {8{x_clip_v0[15]}}, x_clip_v0, 8'b0000_0000};
						div_b <= { {8{w_clip_v0[15]}}, w_clip_v0, 8'b0000_0000};
						div_start <= 1;
						state_transform <= 13;
					end
				end 
				// 
				//
				13: begin
					div_start <= 0;
					if (div_done) begin
						x_ndc_v0 <= div_result[17:2];
						div_a <= { {8{y_clip_v0[15]}}, y_clip_v0, 8'b0000_0000};
						div_b <= { {8{w_clip_v0[15]}}, w_clip_v0, 8'b0000_0000};
						div_start <= 1;
						state_transform <= 14;
					end
				end
				14: begin
					div_start <= 0;
					if (div_done) begin
						y_ndc_v0 <= div_result[17:2];
						div_a <= { {8{x_clip_v1[15]}}, x_clip_v1, 8'b0000_0000};
						div_b <= { {8{w_clip_v1[15]}}, w_clip_v1, 8'b0000_0000};
						div_start <= 1;
						state_transform <= 15;
					end
				end
				15: begin
					div_start <= 0;
					if (div_done) begin
						x_ndc_v1 <= div_result[17:2];
						div_a <= { {8{y_clip_v1[15]}}, y_clip_v1, 8'b0000_0000};
						div_b <= { {8{w_clip_v1[15]}}, w_clip_v1, 8'b0000_0000};
						div_start <= 1;
						state_transform <= 16;
					end
				end
				16: begin
					div_start <= 0;
					if (div_done) begin
						y_ndc_v1 <= div_result[17:2];
						div_a <= { {8{x_clip_v2[15]}}, x_clip_v2, 8'b0000_0000};
						div_b <= { {8{w_clip_v2[15]}}, w_clip_v2, 8'b0000_0000};
						div_start <= 1;
						state_transform <= 17;
					end
				end
				17: begin
					div_start <= 0;
					if (div_done) begin
						x_ndc_v2 <= div_result[17:2];
						div_a <= { {8{y_clip_v2[15]}}, y_clip_v2, 8'b0000_0000};
						div_b <= { {8{w_clip_v2[15]}}, w_clip_v2, 8'b0000_0000};
						div_start <= 1;
						state_transform <= 18;
					end
				end
				18: begin
					div_start <= 0;
					if (div_done) begin
						y_ndc_v2 <= div_result[17:2];
						div_a <= { {8{x_clip_v3[15]}}, x_clip_v3, 8'b0000_0000};
						div_b <= { {8{w_clip_v3[15]}}, w_clip_v3, 8'b0000_0000};
						div_start <= 1;
						state_transform <= 19;
					end
				end
				19: begin
					div_start <= 0;
					if (div_done) begin
						x_ndc_v3 <= div_result[17:2];
						div_a <= { {8{y_clip_v3[15]}}, y_clip_v3, 8'b0000_0000};
						div_b <= { {8{w_clip_v3[15]}}, w_clip_v3, 8'b0000_0000};
						div_start <= 1;
						state_transform <= 20;
					end
				end
				20: begin
					div_start <= 0;
					if (div_done) begin
						y_ndc_v3 <= div_result[17:2];
						// screen = [S] * ndc
						// 		x_ndc * 320 + 320 = x_ndc << 8 + x_ndc << 6 + 320
						x_ndc_v0 <= {x_ndc_v0[15],x_ndc_v0[15:1]};		// Q2.14 (x_ndc) -> Q10.6 (x_ndc << 8) -> Q11.5
						tmp_ndc <= { {3{x_ndc_v0[15]}}, x_ndc_v0[15:3]};	// Q2.14 (x_ndc) -> Q8.8 (x_ndc << 6) -> Q11.5
						state_transform <= 21;
					end
				end
				//
				//
	 			21: begin
					x_ndc_v0 <= x_ndc_v0 + tmp_ndc;
					//
					x_ndc_v1 <= {x_ndc_v1[15],x_ndc_v1[15:1]};		
					tmp_ndc <= { {3{x_ndc_v1[15]}}, x_ndc_v1[15:3]};
					state_transform <= 22;
				end
				22: begin  
					x_ndc_v0 <= x_ndc_v0 + 16'sb001_0100_0000_00000;		// Q11.5 (320)
					//
					x_ndc_v1 <= x_ndc_v1 + tmp_ndc;
					//
					x_ndc_v2 <= {x_ndc_v2[15],x_ndc_v2[15:1]};		
					tmp_ndc <= { {3{x_ndc_v2[15]}}, x_ndc_v2[15:3]};
					state_transform <= 23;
				end
				23: begin  
					x_ndc_v1 <= x_ndc_v1 + 16'sb001_0100_0000_00000;		// Q11.5 (320)
					//
					x_ndc_v2 <= x_ndc_v2 + tmp_ndc;
					//
					x_ndc_v3 <= {x_ndc_v3[15],x_ndc_v3[15:1]};		
					tmp_ndc <= { {3{x_ndc_v3[15]}}, x_ndc_v3[15:3]};
					state_transform <= 24;
				end
				24: begin  
					x_ndc_v2 <= x_ndc_v2 + 16'sb001_0100_0000_00000;		// Q11.5 (320)
					//
					x_ndc_v3 <= x_ndc_v3 + tmp_ndc;
					// y_ndc * 240 + 240 = y_ndc << 8 - y_ndcc << 4 + 240
					y_ndc_v0 <= {y_ndc_v0[15],y_ndc_v0[15:1]};		// Q2.14 (y_ndc) -> Q10.6 (y_ndc << 8) -> Q11.5
					tmp_ndc <= { {5{y_ndc_v0[15]}}, y_ndc_v0[15:5]};	// Q2.14 (y_ndc) -> Q6.10 (y_ndc << 4) -> Q11.5
					state_transform <= 25;
				end
				25: begin  
					x_ndc_v3 <= x_ndc_v3 + 16'sb001_0100_0000_00000;
					//
					y_ndc_v0 <= y_ndc_v0 - tmp_ndc;
					//
					y_ndc_v1 <= {y_ndc_v1[15],y_ndc_v1[15:1]};		
					tmp_ndc <= { {5{y_ndc_v1[15]}}, y_ndc_v1[15:5]};
					state_transform <= 26;
				end
				26: begin
					y_ndc_v0 <= y_ndc_v0 + 16'sb000_1111_0000_00000;		// Q11.5 (240) 16'sb000_1111_0000_00000
					//
					y_ndc_v1 <= y_ndc_v1 - tmp_ndc;
					//
					y_ndc_v2 <= {y_ndc_v2[15],y_ndc_v2[15:1]};		
					tmp_ndc <= { {5{y_ndc_v2[15]}}, y_ndc_v2[15:5]};
					state_transform <= 27;
				end
				27: begin
					y_ndc_v1 <= y_ndc_v1 + 16'sb000_1111_0000_00000;		// Q11.5 (240) 16'sb000_1111_0000_00000
					//
					y_ndc_v2 <= y_ndc_v2 - tmp_ndc;
					//
					y_ndc_v3 <= {y_ndc_v3[15],y_ndc_v3[15:1]};		
					tmp_ndc <= { {5{y_ndc_v3[15]}}, y_ndc_v3[15:5]};
					state_transform <= 28;
				end
				28: begin
					y_ndc_v2 <= y_ndc_v2 + 16'sb000_1111_0000_00000;	
					//
					y_ndc_v3 <= y_ndc_v3 - tmp_ndc;
					state_transform <= 29;
				end
				29: begin
					y_ndc_v3 <= y_ndc_v3 + 16'sb000_1111_0000_00000;	
					//
					state_transform <= 30;
				end
				30: begin
					if (buff1_ready) begin
						x_screen_v0_buff2 <= {9'b0000_0000_0,x_ndc_v0[15:5]};		// Q20.0 (screen), always positive 
						y_screen_v0_buff2 <= {9'b0000_0000_0,y_ndc_v0[15:5]};
						x_screen_v1_buff2 <= {9'b0000_0000_0,x_ndc_v1[15:5]};
						y_screen_v1_buff2 <= {9'b0000_0000_0,y_ndc_v1[15:5]};
						x_screen_v2_buff2 <= {9'b0000_0000_0,x_ndc_v2[15:5]};
						y_screen_v2_buff2 <= {9'b0000_0000_0,y_ndc_v2[15:5]};
						x_screen_v3_buff2 <= {9'b0000_0000_0,x_ndc_v3[15:5]};
						y_screen_v3_buff2 <= {9'b0000_0000_0,y_ndc_v3[15:5]};
						buff1_ready <= 0;
					end
					else begin
						x_screen_v0_buff1 <= {9'b0000_0000_0,x_ndc_v0[15:5]};		// Q20.0 (screen), always positive 
						y_screen_v0_buff1 <= {9'b0000_0000_0,y_ndc_v0[15:5]};
						x_screen_v1_buff1 <= {9'b0000_0000_0,x_ndc_v1[15:5]};
						y_screen_v1_buff1 <= {9'b0000_0000_0,y_ndc_v1[15:5]};
						x_screen_v2_buff1 <= {9'b0000_0000_0,x_ndc_v2[15:5]};
						y_screen_v2_buff1 <= {9'b0000_0000_0,y_ndc_v2[15:5]};
						x_screen_v3_buff1 <= {9'b0000_0000_0,x_ndc_v3[15:5]};
						y_screen_v3_buff1 <= {9'b0000_0000_0,y_ndc_v3[15:5]};
						buff1_ready <= 1;
					end
					// dot(light, n)
					dot_start <= 1;
					state_transform <= 31;
				end 
				// 
				//
				31: begin
					dot_start <= 0;
					if (dot_done) begin
						if (dot_result[9] == 1'b1) begin  	   	  		// backfacing 1x.xxx
							if (dot_result[8:6] == 3'b100) begin  		// 11.000 -> -1
								tmp_color <= 2'b11;
							end
							else if (dot_result[9:8] == 2'b10) begin 	// 10.xxx -> -1.xxx
								tmp_color <= 2'b11;
							end
							else begin
								tmp_color <= ~dot_result[7:6];			// 11.xxx -> -0.xxx
							end
						end
						else begin
							if (dot_result[8:5] == 4'b1000) begin 		// 01.000 -> 0.111
								tmp_color <= 2'b11;
							end
							else begin
								tmp_color <= dot_result[7:6];			// 0.000 - 0.111
							end
						end
						state_transform <= 32;
					end
				end


				32: begin
					state_transform <= 0;
				end 
				default: begin
					state_transform <= 0;
				end
			endcase

			//////////////////////////////
			// double buffer xy_screen
			//////////////////////////////
			if ((y == 480) && (x == 0)) begin
	    		if (buff1_ready) begin
	    			x_screen_v0 <= x_screen_v0_buff1;
					y_screen_v0 <= y_screen_v0_buff1;
					x_screen_v1 <= x_screen_v1_buff1;
					y_screen_v1 <= y_screen_v1_buff1;
					x_screen_v2 <= x_screen_v2_buff1;
					y_screen_v2 <= y_screen_v2_buff1;
					x_screen_v3 <= x_screen_v3_buff1;
					y_screen_v3 <= y_screen_v3_buff1;
					intensity <= tmp_color;
	    		end
	    		else begin
	    			x_screen_v0 <= x_screen_v0_buff2;
					y_screen_v0 <= y_screen_v0_buff2;
					x_screen_v1 <= x_screen_v1_buff2;
					y_screen_v1 <= y_screen_v1_buff2;
					x_screen_v2 <= x_screen_v2_buff2;
					y_screen_v2 <= y_screen_v2_buff2;
					x_screen_v3 <= x_screen_v3_buff2;
					y_screen_v3 <= y_screen_v3_buff2;
					intensity <= tmp_color;
	    		end

	    		// skip [VS] to test raster
	    		// x_screen_v0 <= {9'b0000_0000_0,11'd200};	
				// y_screen_v0 <= {9'b0000_0000_0,11'd200};
				// x_screen_v1 <= {9'b0000_0000_0,11'd300};
				// y_screen_v1 <= {9'b0000_0000_0,11'd100};
				// x_screen_v2 <= {9'b0000_0000_0,11'd400};
				// y_screen_v2 <= {9'b0000_0000_0,11'd100};
				// x_screen_v3 <= {9'b0000_0000_0,11'd400};
				// y_screen_v3 <= {9'b0000_0000_0,11'd300};
	    	end


			//////////////////////////////
			// compute e0_init
			//////////////////////////////
			if (y < 480) begin
				// @ endline, 
				// 		- must finished before x == 799, raster will use e0_init @ x == 799
				if (x == 640) begin
					// 1. compute e0_init -= x2x1; 
					// 2. bar_iy += bar_iy_dy;
					//	  bar_iz += bar_iz_dy;
					// do only 1 time, x == 640 for 2 clk
					state_ei_line <= state_ei_line + 1;
					if (state_ei_line == 1) begin
						state_ei_line <= 0;
						// 012
						e0_init_t1 <= e0_init_t1 - (x_screen_v1 - x_screen_v0);		// b0
						e1_init_t1 <= e1_init_t1 - (x_screen_v2 - x_screen_v1);		// b1
						e2_init_t1 <= e2_init_t1 - (x_screen_v0 - x_screen_v2);		// b2
						// 023
						e0_init_t2 <= e0_init_t2 - (x_screen_v2 - x_screen_v0);		// b0
						e1_init_t2 <= e1_init_t2 - (x_screen_v3 - x_screen_v2);		// b1
						e2_init_t2 <= e2_init_t2 - (x_screen_v0 - x_screen_v3);		// b2
						//
						bar_iy <= bar_iy + bar_iy_dy;
						bar_iz <= bar_iz + bar_iz_dy;
						bar2_iy <= bar2_iy + bar2_iy_dy;
						bar2_iz <= bar2_iz + bar2_iz_dy;
					end
				end
			end // y < 480
			else begin
				// @ endframe
				case (state_ei_frame)
					//
					//	1. compute e0_init = (-pts[0].x * a0) + (pts[0].y * (pts[1].x-pts[0].x);
					//		- call mul 6  time
					// Q20.2 x Q20.2 = Q40.4->Q20.0
					0: begin
						if ((y == 480) && (x == 1)) begin
							mul_a <= {x_screen_v0,2'b00};					// pts[0].x
							mul_b <= {y_screen_v0 - y_screen_v1,2'b00};		// -a0
							mul_start <= 1;
							state_ei_frame <= 1;
						end
					end
					1: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v0,2'b00};					// pts[0].y
							mul_b <= {x_screen_v1 - x_screen_v0,2'b00};		// b0
							mul_start <= 1;
							state_ei_frame <= 2;
						end
					end
					2: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							state_ei_frame <= 3;
						end 
					end
					3: begin
						e0_init_t1 <= tmp_ei_mul2 + tmp_ei_mul1;	// fin e0_init_t1
						mul_a <= {x_screen_v1,2'b00};						// pts[1].x
						mul_b <= {y_screen_v1 - y_screen_v2,2'b00};			// -a1
						mul_start <= 1;
						state_ei_frame <= 4;
					end 
					4: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v1,2'b00};					// pts[1].y
							mul_b <= {x_screen_v2 - x_screen_v1,2'b00};		// b1
							mul_start <= 1;
							state_ei_frame <= 5;
						end
					end
					5: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							state_ei_frame <= 6;
						end 
					end
					6: begin
						e1_init_t1 <= tmp_ei_mul2 + tmp_ei_mul1;	// fin e1_init_t1
						mul_a <= {x_screen_v2,2'b00};						// pts[2].x
						mul_b <= {y_screen_v2 - y_screen_v0,2'b00};			// -a2
						mul_start <= 1;
						state_ei_frame <= 7;
					end 
					7: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v2,2'b00};					// pts[2].y
							mul_b <= {x_screen_v0 - x_screen_v2,2'b00};		// b2
							mul_start <= 1;
							state_ei_frame <= 8;
						end
					end
					8: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= mul_result[23:4];		// ready in 23clk for 20bit mul	
							state_ei_frame <= 9;
						end 
					end
					9: begin
						e2_init_t1 <= tmp_ei_mul2 + tmp_ei_mul1;	// fin e2_init_t1
						
						// start tri2
						mul_a <= {x_screen_v0,2'b00};					
						mul_b <= {y_screen_v0 - y_screen_v2,2'b00};		
						mul_start <= 1;
						state_ei_frame <= 10;
					end 
					10: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v0,2'b00};					
							mul_b <= {x_screen_v2 - x_screen_v0,2'b00};		
							mul_start <= 1;
							state_ei_frame <= 11;
						end
					end
					11: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							state_ei_frame <= 12;
						end 
					end
					12: begin
						e0_init_t2 <= tmp_ei_mul2 + tmp_ei_mul1;	// fin e0_init_t1
						mul_a <= {x_screen_v2,2'b00};						
						mul_b <= {y_screen_v2 - y_screen_v3,2'b00};			
						mul_start <= 1;
						state_ei_frame <= 13;
					end 
					13: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v2,2'b00};					
							mul_b <= {x_screen_v3 - x_screen_v2,2'b00};		
							mul_start <= 1;
							state_ei_frame <= 14;
						end
					end
					14: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							state_ei_frame <= 15;
						end 
					end
					15: begin
						e1_init_t2 <= tmp_ei_mul2 + tmp_ei_mul1;	// fin e1_init_t1
						mul_a <= {x_screen_v3,2'b00};						
						mul_b <= {y_screen_v3 - y_screen_v0,2'b00};			
						mul_start <= 1;
						state_ei_frame <= 16;
					end 
					16: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v3,2'b00};					
							mul_b <= {x_screen_v0 - x_screen_v3,2'b00};		
							mul_start <= 1;
							state_ei_frame <= 17;
						end
					end
					17: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= mul_result[23:4];		// ready in 23clk for 20bit mul	
							state_ei_frame <= 18;
						end 
					end
					18: begin
						e2_init_t2 <= tmp_ei_mul2 + tmp_ei_mul1;	// fin e2_init_t1
						state_ei_frame <= 19;
					end 
					//
					// 2. compute denom
					//		Q20.0 denom_i = (pts[0].y-pts[2].y) * (pts[1].x-pts[2].x) + (pts[1].y-pts[2].y) * (pts[2].x-pts[0].x)
					//		Q2.20 denom = float2fix14(1.0f/denom_i);
					//		640x640 x2 = 819,200      2^20
    				//      1/819,200 = 0.00000122,   1/2^20   
					// 012 -> 023
					19: begin
						mul_a <= {y_screen_v0 - y_screen_v2,2'b00};			// pts[0].y-pts[2].y
						mul_b <= {x_screen_v1 - x_screen_v2,2'b00};			// pts[1].x-pts[2].x
						mul_start <= 1;
						state_ei_frame <= 20;
					end
					20: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v1 - y_screen_v2,2'b00};		// pts[1].y-pts[2].y
							mul_b <= {x_screen_v2 - x_screen_v0,2'b00};		// pts[2].x-pts[0].x
							mul_start <= 1;
							state_ei_frame <= 21;
						end
					end
					21: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= tmp_ei_mul1 + mul_result[23:4];		// denom_i
							state_ei_frame <= 22;
						end 
					end
					22: begin
						// Q20.0->Q20.20 -> Q20.20/Q20.20 
						div2_a <= { 20'b0000_0000_0000_0000_0001, 20'b0000_0000_0000_0000_0001};	// 1.0f/denom_i
						div2_b <= { tmp_ei_mul2, 20'b0000_0000_0000_0000_0000};
						div2_start <= 1;
						state_ei_frame <= 23;
					end
					23: begin
						div2_start <= 0;
						if (div2_done) begin
							// Q20.20->Q2.20
							denom <= {div2_result[21:0]};
							state_ei_frame <= 24;
						end
					end
					//
					24: begin
						mul_a <= {y_screen_v0 - y_screen_v3,2'b00};			// pts[0].y-pts[2].y
						mul_b <= {x_screen_v2 - x_screen_v3,2'b00};			// pts[1].x-pts[2].x
						mul_start <= 1;
						state_ei_frame <= 25;
					end
					25: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v2 - y_screen_v3,2'b00};		// pts[1].y-pts[2].y
							mul_b <= {x_screen_v3 - x_screen_v0,2'b00};		// pts[2].x-pts[0].x
							mul_start <= 1;
							state_ei_frame <= 26;
						end
					end
					26: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= tmp_ei_mul1 + mul_result[23:4];		// denom_i
							state_ei_frame <= 27;
						end 
					end
					27: begin
						// Q20.0->Q20.20 -> Q20.20/Q20.20 
						div2_a <= { 20'b0000_0000_0000_0000_0001, 20'b0000_0000_0000_0000_0001};	// 1.0f/denom_i
						div2_b <= { tmp_ei_mul2, 20'b0000_0000_0000_0000_0000};
						div2_start <= 1;
						state_ei_frame <= 28;
					end
					28: begin
						div2_start <= 0;
						if (div2_done) begin
							// Q20.20->Q2.20
							denom2 <= {div2_result[21:0]};
							state_ei_frame <= 29;
						end
					end
					//
					//3. bar_iy, bar_iz  (no need for bar_ix, uv[0] (0,0))
					// 	Q2.20 = (Q20.0->)Q20.2 * Q2.20
					//	      = 500,000 * 0.000002 = 1
					//        = 10,000 * 0.000002 = 0.02
					//	Q2.20 = 500 * 0.000002 = 0.001, 2^10
					//		  = 100 * 0.000002 = 0.0002, 2^16 = 0.000015
					//		
					//		 bar_iy <= ((pts[0].y * x1x3) + (-y1y3 * pts[0].x)) * denom;	// 3 mul
				    //		 bar_iy_dy <= -x1x3 * denom;		// 1 mul
					//		 bar_iy_dx <= y1y3 * denom;		// 1 mul
					//		 bar_iz <= ((pts[1].y * x2x1) + (y1y2 * pts[1].x)) * denom;	// 3 mul
					//		 bar_iz_dy <= -x2x1 * denom;		// 1 mul
					//		 bar_iz_dx <= -y1y2 * denom;		// 1 mul
					// 012 -> 023
					29: begin
						mul_a <= {y_screen_v0,2'b00};						// pts[0].y
						mul_b <= {x_screen_v0 - x_screen_v2,2'b00};			// x1x3, pts[0].x-pts[2].x
						mul_start <= 1;
						state_ei_frame <= 30;
					end
					30: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v2 - y_screen_v0,2'b00};		// -y1y3, pts[2].y - pts[0].y
							mul_b <= {x_screen_v0,2'b00};					// pts[0].x
							mul_start <= 1;
							state_ei_frame <= 31;
						end
					end
					31: begin
						mul_start <= 0;
						if (mul_done) begin
							mul_a <= {tmp_ei_mul1 + mul_result[23:4],2'b00};		// ready in 23clk for 20bit mul
							mul_b <= denom;							
							mul_start <= 1;
							state_ei_frame <= 32;
						end
					end
					32: begin
						mul_start <= 0;
						if (mul_done) begin
							bar_iy <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							mul_a <= {x_screen_v2 - x_screen_v0,2'b00};		// -x1x3, pts[2].x - pts[0].x
							mul_b <= denom;					
							mul_start <= 1;
							state_ei_frame <= 33;
						end
					end
					33: begin
						mul_start <= 0;
						if (mul_done) begin
							bar_iy_dy <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							mul_a <= {y_screen_v0 - y_screen_v2,2'b00};			// y1y3, pts[0].y - pts[2].y
							mul_b <= denom;					
							mul_start <= 1;
							state_ei_frame <= 34;
						end
					end
					34: begin
						mul_start <= 0;
						if (mul_done) begin
							bar_iy_dx <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							mul_a <= {y_screen_v1,2'b00};						// pts[1].y
							mul_b <= {x_screen_v1 - x_screen_v0,2'b00};			// x2x1		
							mul_start <= 1;
							state_ei_frame <= 35;
						end
					end
					35: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v0 - y_screen_v1,2'b00};		// y1y2, pts[0].y - pts[1].y
							mul_b <= {x_screen_v1,2'b00};					// pts[1].x
							mul_start <= 1;
							state_ei_frame <= 36;
						end
					end
					36: begin
						mul_start <= 0;
						if (mul_done) begin
							mul_a <= {tmp_ei_mul1 + mul_result[23:4],2'b00};		// ready in 23clk for 20bit mul
							mul_b <= denom;							
							mul_start <= 1;
							state_ei_frame <= 37;
						end
					end
					37: begin
						mul_start <= 0;
						if (mul_done) begin
							bar_iz <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							mul_a <= {x_screen_v0 - x_screen_v1,2'b00};		// -x2x1, pts[0].x - pts[1].x
							mul_b <= denom;					
							mul_start <= 1;
							state_ei_frame <= 38;
						end
					end
					38: begin
						mul_start <= 0;
						if (mul_done) begin
							bar_iz_dy <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							mul_a <= {y_screen_v1 - y_screen_v0,2'b00};			// -y1y2, pts[1].y - pts[0].y
							mul_b <= denom;					
							mul_start <= 1;
							state_ei_frame <= 39;
						end
					end
					39: begin
						mul_start <= 0;
						if (mul_done) begin
							bar_iz_dx <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							state_ei_frame <= 40;
						end
					end
					//
					40: begin
						mul_a <= {y_screen_v0,2'b00};						// pts[0].y
						mul_b <= {x_screen_v0 - x_screen_v3,2'b00};			// x1x3, pts[0].x-pts[2].x
						mul_start <= 1;
						state_ei_frame <= 41;
					end
					41: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v3 - y_screen_v0,2'b00};		// -y1y3, pts[2].y - pts[0].y
							mul_b <= {x_screen_v0,2'b00};					// pts[0].x
							mul_start <= 1;
							state_ei_frame <= 42;
						end
					end
					42: begin
						mul_start <= 0;
						if (mul_done) begin
							mul_a <= {tmp_ei_mul1 + mul_result[23:4],2'b00};		// ready in 23clk for 20bit mul
							mul_b <= denom2;							
							mul_start <= 1;
							state_ei_frame <= 43;
						end
					end
					43: begin
						mul_start <= 0;
						if (mul_done) begin
							bar2_iy <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							mul_a <= {x_screen_v3 - x_screen_v0,2'b00};		// -x1x3, pts[2].x - pts[0].x
							mul_b <= denom2;					
							mul_start <= 1;
							state_ei_frame <= 44;
						end
					end
					44: begin
						mul_start <= 0;
						if (mul_done) begin
							bar2_iy_dy <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							mul_a <= {y_screen_v0 - y_screen_v3,2'b00};			// y1y3, pts[0].y - pts[2].y
							mul_b <= denom2;					
							mul_start <= 1;
							state_ei_frame <= 45;
						end
					end
					45: begin
						mul_start <= 0;
						if (mul_done) begin
							bar2_iy_dx <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							mul_a <= {y_screen_v2,2'b00};						// pts[1].y
							mul_b <= {x_screen_v2 - x_screen_v0,2'b00};			// x2x1		
							mul_start <= 1;
							state_ei_frame <= 46;
						end
					end
					46: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[23:4];		// ready in 23clk for 20bit mul
							mul_a <= {y_screen_v0 - y_screen_v2,2'b00};		// y1y2, pts[0].y - pts[1].y
							mul_b <= {x_screen_v2,2'b00};					// pts[1].x
							mul_start <= 1;
							state_ei_frame <= 47;
						end
					end
					47: begin
						mul_start <= 0;
						if (mul_done) begin
							mul_a <= {tmp_ei_mul1 + mul_result[23:4],2'b00};		// ready in 23clk for 20bit mul
							mul_b <= denom2;							
							mul_start <= 1;
							state_ei_frame <= 48;
						end
					end
					48: begin
						mul_start <= 0;
						if (mul_done) begin
							bar2_iz <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							mul_a <= {x_screen_v0 - x_screen_v2,2'b00};		// -x2x1, pts[0].x - pts[1].x
							mul_b <= denom2;					
							mul_start <= 1;
							state_ei_frame <= 49;
						end
					end
					49: begin
						mul_start <= 0;
						if (mul_done) begin
							bar2_iz_dy <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							mul_a <= {y_screen_v2 - y_screen_v0,2'b00};			// -y1y2, pts[1].y - pts[0].y
							mul_b <= denom2;					
							mul_start <= 1;
							state_ei_frame <= 50;
						end
					end
					50: begin
						mul_start <= 0;
						if (mul_done) begin
							bar2_iz_dx <= mul_result[23:2];				// ready in 23clk for 20bit mul
							//
							state_ei_frame <= 0;
						end
					end

					default: begin
						state_ei_frame <= 0;
					end
				endcase
			end


		end // reset
	end



endmodule

