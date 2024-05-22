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
	input [2:0] tri_color,					// 2-bit, but only use 6 intensity level
	input signed [19:0] y_screen_v0,		// change per frame, int20		
	input signed [19:0] y_screen_v1,		
	input signed [19:0] y_screen_v2,
	input signed [19:0] e0_init_t1,			// change per line, int20
	input signed [19:0] e1_init_t1,
	input signed [19:0] e2_init_t1,
	// to top
	output reg [5:0] rgb
	);

	
	reg signed [19:0] e0_t1;
	reg signed [19:0] e1_t1;
	reg signed [19:0] e2_t1;
	reg [1:0] state_pixel;


	always @(posedge clk) begin
		if (reset) begin
			e0_t1 <= 0;
			e1_t1 <= 0;
			e2_t1 <= 0;
			state_pixel <= 1;
			rgb <= 0;
		end
		else begin

			if (y < 480) begin
				if (x < 640) begin
					// @ each pixel, chk inside tri
					state_pixel <= state_pixel + 1;
					if (state_pixel == 1) begin 		
						state_pixel <= 0;
						if ((e0_t1 < 0) && (e1_t1 < 0) && (e2_t1 < 0)) begin 	// pico version
							//rgb <= {2'b00, tri_color, 2'b00};
							case (tri_color)
								0: begin
									rgb <= 6'b000000;
								end
								1: begin
									rgb <= 6'b000100;
								end
								2: begin
									rgb <= 6'b001000;
								end
								3: begin
									rgb <= 6'b001000;
								end
								4: begin
									rgb <= 6'b001100;
								end
								5: begin
									rgb <= 6'b001100;
								end
								6: begin
									rgb <= 6'b011101;
								end
								7: begin
									rgb <= 6'b101110;
								end
							endcase
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
						e0_t1 <= e0_t1 + (y_screen_v1 - y_screen_v0);	// a0
						e1_t1 <= e1_t1 + (y_screen_v2 - y_screen_v1);	// a1
						e2_t1 <= e2_t1 + (y_screen_v0 - y_screen_v2);	// a2
					end 
				end 
				else if (x == 799) begin
					// update e0 = e0_init; each line
					e0_t1 <= e0_init_t1;
					e1_t1 <= e1_init_t1;
					e2_t1 <= e2_init_t1;
				end 	
			end 	// y < 480
			else if ((y == 524) && (x == 799)) begin
				// update e0 = e0_init; each frame, before begin line y = 0
				e0_t1 <= e0_init_t1;
				e1_t1 <= e1_init_t1;
				e2_t1 <= e2_init_t1;
			end
		end 	// reset
	end


endmodule

