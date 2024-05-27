//`timescale 1ns / 1ps

/*
 * Copyright (c) 2024 Matt Pongsagon Vichitvejpaisal
 * SPDX-License-Identifier: Apache-2.0
 */
 
module raster(
	input clk, 		
	input reset,
	// from vga
	input [9:0] x,
	input [9:0] y,
	// from VS, 
	input [2:0] tri_color,					// 3-bit, but only use 6 intensity level
	input signed [19:0] y_screen_v0,		// change per frame, int20		
	input signed [19:0] y_screen_v1,		
	input signed [19:0] y_screen_v2,
	input signed [19:0] y_screen_v3,
	input signed [19:0] e0_init_t1,			// change per line, int20
	input signed [19:0] e1_init_t1,
	input signed [19:0] e2_init_t1,
	input signed [19:0] e0_init_t2,			// change per line, int20
	input signed [19:0] e1_init_t2,
	input signed [19:0] e2_init_t2,
	input signed [21:0] bar_iy,				// Q2.20
    input signed [21:0] bar_iy_dx,
    input signed [21:0] bar_iz,			
    input signed [21:0] bar_iz_dx,
    input signed [21:0] bar2_iy,				// Q2.20
    input signed [21:0] bar2_iy_dx,
    input signed [21:0] bar2_iz,			
    input signed [21:0] bar2_iz_dx,
	// to top
	output reg [5:0] rgb
	);

	
	reg signed [19:0] e0_t1;
	reg signed [19:0] e1_t1;
	reg signed [19:0] e2_t1; 
	reg signed [19:0] e0_t2;
	reg signed [19:0] e1_t2;
	reg signed [19:0] e2_t2; 
	reg signed [21:0] b_iy;			// Q2.20
    reg signed [21:0] b_iz;			
    reg signed [21:0] ui;			// Q2.20
    reg signed [21:0] vi;
    reg signed [21:0] b2_iy;			// Q2.20
    reg signed [21:0] b2_iz;			
    reg signed [21:0] ui2;			// Q2.20
    reg signed [21:0] vi2;
	reg [1:0] state_pixel;


	wire texel;	
	wire [6:0] u_;
	wire [6:0] v_;

	reg tri_idx;
	reg back_face;
	reg bg;

	//Q2.20 [0.0.999] x 128 -> Q9.13
	assign u_ = (tri_idx)? ui2[19:13] : ui[19:13];
	assign v_ = (tri_idx)? vi2[19:13] : vi[19:13];

	bitmap_rom tex(.x(u_),.y(v_),.pixel(texel)); 


	always @(posedge clk) begin
		if (reset) begin
			e0_t1 <= 0;
			e1_t1 <= 0;
			e2_t1 <= 0;
			e0_t2 <= 0;
			e1_t2 <= 0;
			e2_t2 <= 0;
			b_iy <= 0;
			b_iz <= 0;
			ui <= 0;
			vi <= 0;
			b2_iy <= 0;
			b2_iz <= 0;
			ui2 <= 0;
			vi2 <= 0;
			tri_idx <= 0;
			back_face <= 0;
			bg <= 0;
			state_pixel <= 1;
			rgb <= 0;
		end
		else begin

			if (y < 480) begin
				if (x < 640) begin
					// @ each pixel, 
					case (state_pixel)
						0: begin
							b_iy <= b_iy + bar_iy_dx;
							b_iz <= b_iz + bar_iz_dx;
							ui <= (b_iz + bar_iz_dx);
							vi <= (b_iy + bar_iy_dx + b_iz + bar_iz_dx); 
							//
							b2_iy <= b2_iy + bar2_iy_dx;
							b2_iz <= b2_iz + bar2_iz_dx;
							ui2 <= (b2_iy + bar2_iy_dx + b2_iz + bar2_iz_dx); 
							vi2 <= (b2_iy + bar2_iy_dx); 
							
							// chk inside tri
							if ((e0_t1 < 0) && (e1_t1 < 0) && (e2_t1 < 0)) begin 
								tri_idx <= 0;
								back_face <= 0;
								bg <= 0;
							end
							else if ((e0_t1 > 0) && (e1_t1 > 0) && (e2_t1 > 0)) begin 	// reverse order, back facing	
								tri_idx <= 0;
								back_face <= 1;
								bg <= 0;
							end
							else if ((e0_t2 < 0) && (e1_t2 < 0) && (e2_t2 < 0)) begin
								tri_idx <= 1;
								back_face <= 0;
								bg <= 0;
							end
							else if ((e0_t2 > 0) && (e1_t2 > 0) && (e2_t2 > 0)) begin
								tri_idx <= 1;
								back_face <= 1;
								bg <= 0;
							end else begin
								bg <= 1;
							end
							state_pixel <= 1;
						end
						1: begin
							// set color
							if (bg) begin
								rgb <= 6'b01_0101;
							end
							else begin
								if (tri_idx) begin
									if (back_face) begin
										rgb <= 6'b00_0011;
									end
									else begin
										if (texel) begin
											rgb <= 6'b00_1100;
										end 
										else begin
											rgb <= 6'b00_0000;
										end
									end
									//rgb <= 6'b01_0101;
								end
								else begin
									if (back_face) begin
										rgb <= 6'b11_0000;
									end
									else begin
										if (texel) begin
											rgb <= 6'b00_1100;
										end 
										else begin
											rgb <= 6'b00_0000;
										end
									end
								end
							end
							
							//
							e0_t1 <= e0_t1 + (y_screen_v1 - y_screen_v0);	// a0
							e1_t1 <= e1_t1 + (y_screen_v2 - y_screen_v1);	// a1
							e2_t1 <= e2_t1 + (y_screen_v0 - y_screen_v2);	// a2
							//
							e0_t2 <= e0_t2 + (y_screen_v2 - y_screen_v0);	// a0
							e1_t2 <= e1_t2 + (y_screen_v3 - y_screen_v2);	// a1
							e2_t2 <= e2_t2 + (y_screen_v0 - y_screen_v3);	// a2
							state_pixel <= 0;
						end

						default: begin
							state_pixel <= 0;
						end
					endcase
				end 
				else if (x == 799) begin
					// update e0 = e0_init; each line
					e0_t1 <= e0_init_t1;
					e1_t1 <= e1_init_t1;
					e2_t1 <= e2_init_t1;
					//
					e0_t2 <= e0_init_t2;
					e1_t2 <= e1_init_t2;
					e2_t2 <= e2_init_t2;
					// update b
					b_iy <= bar_iy;
					b_iz <= bar_iz;
					b2_iy <= bar2_iy;
					b2_iz <= bar2_iz;
				end 	
			end 	// y < 480
			else if ((y == 524) && (x == 799)) begin
				// update e0 = e0_init; each frame, before begin line y = 0
				e0_t1 <= e0_init_t1;
				e1_t1 <= e1_init_t1;
				e2_t1 <= e2_init_t1;
				//
				e0_t2 <= e0_init_t2;
				e1_t2 <= e1_init_t2;
				e2_t2 <= e2_init_t2;
				// update b
				b_iy <= bar_iy;
				b_iz <= bar_iz;
				b2_iy <= bar2_iy;
				b2_iz <= bar2_iz;
			end
		end 	// reset
	end


endmodule

