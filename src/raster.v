//`timescale 1ns / 1ps

/*
 * Copyright (c) 2024 Matt Pongsagon Vichitvejpaisal
 * SPDX-License-Identifier: Apache-2.0
 */

// Render mode
// [7:6] 2: tt, 1: sk, 0: ddct texture
// [5:4] tri 1 color, [3:2] tri 0 color, [1:0] render mode (uv 1, color 2, mask 0)
 
module raster(
	input clk, 		
	input reset,
	// from vga
	input [9:0] x,
	input [9:0] y,
	// from VS, 
	input [1:0] intensity,					// 2-bit
	input [7:0] render_mode,				
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


	wire texel0;	
	wire texel1;	
	//wire texel2;	
	wire [6:0] u_;
	wire [6:0] v_;

	reg tri_idx;
	reg back_face;
	reg bg;

	//Q2.20 [0.0.999] x 128 -> Q9.13
	assign u_ = (tri_idx)? ui2[19:13] : ui[19:13];
	assign v_ = (tri_idx)? vi2[19:13] : vi[19:13];		// 7'd127-, to reverse v

	bitmap_rom_ddct tex0(.x(u_),.y(v_),.pixel(texel0)); 
	bitmap_rom_sk tex1(.x(u_),.y(v_),.pixel(texel1)); 
	//bitmap_rom_tt tex2(.x(u_),.y(v_),.pixel(texel2)); 


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
							
							// chk inside tri, back facing tri
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
								case (render_mode[1:0]) 
									2'b00:begin				// mask
										rgb <= 6'b01_0101;		// default to bg
										// ddct
										if (render_mode[7:6] == 0) begin
											if (texel0) begin
												if(u_ < 7'd64) begin
													if(v_ < 7'd64) begin
														rgb <= 6'b011111;	// yellow
													end 
													else begin
														rgb <= 6'b010011;	// red
													end 
												end
												else begin
													if(v_ < 7'd64) begin
														rgb <= 6'b101001;	// green
													end 
													else begin
														rgb <= 6'b100000;	// blue
													end
												end
											end
										end
										// sk
										else if (render_mode[7:6] == 1) begin
											if (texel1) begin
												if(u_ < 7'd64) begin
													rgb <= 6'b110111;
												end
												else begin
													rgb <= 6'b111100;
												end
											end
										end
										// tt
										else begin
//											 if (texel2) begin
//											 	rgb <= 6'b00_1100;
//											 end
										end
									end
									2'b01:begin				// uv
										rgb <= 6'b11_1111;
										// ddct
										if (render_mode[7:6] == 0) begin
											if (texel0) begin
												if(u_ < 7'd64) begin
													if(v_ < 7'd64) begin
														rgb <= 6'b011111;	// yellow
													end 
													else begin
														rgb <= 6'b010011;	// red
													end 
												end
												else begin
													if(v_ < 7'd64) begin
														rgb <= 6'b101001;	// green
													end 
													else begin
														rgb <= 6'b100000;	// blue
													end
												end
											end
										end
										// sk
										else if (render_mode[7:6] == 1) begin
											if (texel1) begin
												if(u_ < 7'd64) begin
													rgb <= 6'b110111;
												end
												else begin
													rgb <= 6'b111100;
												end
											end
										end
										// tt
										else begin
//											 if (texel2) begin
//											 	rgb <= 6'b00_1100;
//											 end
										end
									end
									2'b10:begin				// color
										if (tri_idx) begin
											case (render_mode[3:2])
												0: begin
													rgb <= {intensity,2'b00,intensity};		// pink
												end
												1: begin
													rgb <= {intensity, intensity, 2'b00};	// blue
												end
												2: begin
													rgb <= {2'b00,intensity,2'b00};			// green
												end
												3: begin
													rgb <= {2'b00,intensity,intensity};		// yellow
												end
											endcase
										end
										else begin
											case (render_mode[5:4])
												0: begin
													rgb <= {intensity,2'b00,intensity};		// pink
												end
												1: begin
													rgb <= {intensity, intensity, 2'b00};	// blue
												end
												2: begin
													rgb <= {2'b00,intensity,2'b00};			// green
												end
												3: begin
													rgb <= {2'b00,intensity,intensity};		// yellow
												end
											endcase
										end
									end
									default:begin
										rgb <= 6'b00_00000;
									end
								endcase
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

