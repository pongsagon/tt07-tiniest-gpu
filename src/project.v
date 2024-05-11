/*
 * Copyright (c) 2024 Matt Pongsagon Vichitvejpaisal
 * SPDX-License-Identifier: Apache-2.0
 */

`timescale 1ns / 1ps
`default_nettype none

module tt_um_pongsagon_tiniest_gpu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

	wire [1:0] R;
	wire [1:0] G;
	wire [1:0] B;
	wire hsync;
	wire vsync;
	
	wire [9:0] x, y;
	wire blank;
	
	vga v(.clk (clk), .HS (hsync), .VS (vsync), .x (x), .y (y), .blank (blank));

	reg [9:0] o_x = 320;								// store obj properties, 
	reg [9:0] o_y = 240;
	wire object = x>o_x & x<o_x+30 & y>o_y & y<o_y+30;	// define obj shape
	wire border = (x>0 & x<10) | (x>630 & x<640) | (y>0 & y<10) | (y>470 & y<480);
	
	assign R = (border & ~ blank)? 2'b11:0;
	assign G = ((border | object) & ~ blank)? 2'b11:0;
	assign B = (border & ~ blank)? 2'b11:0;
	
	reg [17:0] prescaler;	// to slow down input
	
	always @(posedge clk) begin			// changing properties each clk
		prescaler <= prescaler + 1;
		if (prescaler == 0) begin
			// if (up_switch) begin		// will loop back to 0, warp left/right
				// o_y <= o_y - 1;
			// end
			// if (dn_switch) begin
				// o_y <= o_y + 1;
			// end
			// if (left_switch) begin
				// o_x <= o_x - 1;
			// end
			// if (right_switch) begin
				// o_x <= o_x + 1;
			// end
		end
	end



	// All output pins must be assigned. If not used, assign to 0.
	
	// Output PMOD - Tiny VGA
    assign uio_out[0] = R[1];
    assign uio_out[1] = G[1];
    assign uio_out[2] = B[1];
    assign uio_out[3] = vsync;
    assign uio_out[4] = R[0];
    assign uio_out[5] = G[0];
    assign uio_out[6] = B[0];
    assign uio_out[7] = hsync;
	
	assign uio_oe[7:0] = 8'b1111_1111;
	assign uo_out[7:0] = 0;
	


endmodule
