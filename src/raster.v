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
	input signed [19:0] e0_init_t1,			// change per line, int20
	input signed [19:0] e1_init_t1,
	input signed [19:0] e2_init_t1,
	input signed [21:0] bar_iy,				// Q2.20
    input signed [21:0] bar_iy_dx,
    input signed [21:0] bar_iz,			
    input signed [21:0] bar_iz_dx,
	// to top
	output reg [5:0] rgb
	);

	
	reg signed [19:0] e0_t1;
	reg signed [19:0] e1_t1;
	reg signed [19:0] e2_t1; 
	reg signed [21:0] b_iy;			// Q2.20
    reg signed [21:0] b_iz;			
    reg signed [21:0] ui;			// Q2.20
    reg signed [21:0] vi;
	reg [1:0] state_pixel;


	wire texel;	
	//Q2.20 [0.0.999] x 128 -> Q9.13	
	bitmap_rom tex(.x(ui[19:13]),.y(vi[19:13]),.pixel(texel)); 


	always @(posedge clk) begin
		if (reset) begin
			e0_t1 <= 0;
			e1_t1 <= 0;
			e2_t1 <= 0;
			b_iy <= 0;
			b_iz <= 0;
			ui <= 0;
			vi <= 0;
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
							ui <= (b_iy + bar_iy_dx + b_iz + bar_iz_dx); 
							vi <= (b_iy + bar_iy_dx); 
							state_pixel <= 1;
						end
						1: begin
							// chk inside tri
							if ((e0_t1 < 0) && (e1_t1 < 0) && (e2_t1 < 0)) begin 	// pico version
								//rgb <= {2'b00, tri_color, 2'b00};
								if(texel) begin
									rgb <= 6'b001100;
								end
								else begin
									rgb <= 6'b000000;
								end
								// case (tri_color)
								// 	0: begin
								// 		rgb <= 6'b000000;
								// 	end
								// 	1: begin
								// 		rgb <= 6'b000100;
								// 	end
								// 	2: begin
								// 		rgb <= 6'b001000;
								// 	end
								// 	3: begin
								// 		rgb <= 6'b001000;
								// 	end
								// 	4: begin
								// 		rgb <= 6'b001100;
								// 	end
								// 	5: begin
								// 		rgb <= 6'b001100;
								// 	end
								// 	6: begin
								// 		rgb <= 6'b011101;
								// 	end
								// 	7: begin
								// 		rgb <= 6'b101110;
								// 	end
								// endcase
							end
							else if ((e0_t1 > 0) && (e1_t1 > 0) && (e2_t1 > 0)) begin 	// reverse order, back facing	
								//rgb <= {tri_color[1:0], tri_color[1:0], 2'b00};
								case (tri_color)
									0: begin
										rgb <= 6'b000000;
									end
									1: begin
										rgb <= 6'b000001;
									end
									2: begin
										rgb <= 6'b000010;
									end
									3: begin
										rgb <= 6'b000010;
									end
									4: begin
										rgb <= 6'b000011;
									end
									5: begin
										rgb <= 6'b000011;
									end
									6: begin
										rgb <= 6'b010111;
									end
									7: begin
										rgb <= 6'b101011;
									end
								endcase
							end
							else begin
								rgb <= 6'b010101;
							end
							//
							e0_t1 <= e0_t1 + (y_screen_v1 - y_screen_v0);	// a0
							e1_t1 <= e1_t1 + (y_screen_v2 - y_screen_v1);	// a1
							e2_t1 <= e2_t1 + (y_screen_v0 - y_screen_v2);	// a2
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
					// update b
					b_iy <= bar_iy;
					b_iz <= bar_iz;
				end 	
			end 	// y < 480
			else if ((y == 524) && (x == 799)) begin
				// update e0 = e0_init; each frame, before begin line y = 0
				e0_t1 <= e0_init_t1;
				e1_t1 <= e1_init_t1;
				e2_t1 <= e2_init_t1;
				// update b
				b_iy <= bar_iy;
				b_iz <= bar_iz;
			end
		end 	// reset
	end


endmodule

