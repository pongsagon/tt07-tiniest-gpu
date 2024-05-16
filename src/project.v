/*
 * Copyright (c) 2024 Matt Pongsagon Vichitvejpaisal
 * SPDX-License-Identifier: Apache-2.0
 */
//`timescale 1ns / 1ps
`default_nettype none

module tt_um_pongsagon_tiniest_gpu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n    // reset_n - low to reset
);

	wire reset = !rst_n;
	wire [5:0] RGB;

	wire hsync;
	wire vsync;
	wire [9:0] x, y;
	wire blank;
	vga v(.clk (clk),.reset(reset), .HS (hsync),.VS (vsync), .x (x), .y (y), .blank (blank));
	
	wire rx = ui_in[3];
	wire [7:0] read_data;
	wire read_done;
	//uart_top UART_UNIT(.clk(clk),.reset(reset),.rx(rx),.rx_data_out(read_data),.rx_done_tick(read_done));

	wire [5:0] rgb;
	wire signed [19:0] x_screen_v0;
	wire signed [19:0] y_screen_v0;
	wire signed [19:0] x_screen_v1;		
	wire signed [19:0] y_screen_v1;
	wire signed [19:0] x_screen_v2;		
	wire signed [19:0] y_screen_v2;
	wire signed [19:0] e0_init_t1;
	wire signed [19:0] e1_init_t1;
	wire signed [19:0] e2_init_t1;
	raster raster1(.clk(clk),.reset(reset),.x(x),.y(y),
					.x_screen_v0(x_screen_v0),.y_screen_v0(y_screen_v0),.x_screen_v1(x_screen_v1),
					.y_screen_v1(y_screen_v1),.x_screen_v2(x_screen_v2),.y_screen_v2(y_screen_v2),
					.e0_init_t1(e0_init_t1),.e1_init_t1(e1_init_t1),.e2_init_t1(e2_init_t1),.rgb(rgb));

	vs vs1(.clk(clk),.reset(reset),.x(x),.y(y),
					.x_screen_v0(x_screen_v0),.y_screen_v0(y_screen_v0),.x_screen_v1(x_screen_v1),
					.y_screen_v1(y_screen_v1),.x_screen_v2(x_screen_v2),.y_screen_v2(y_screen_v2),
					.e0_init_t1(e0_init_t1),.e1_init_t1(e1_init_t1),.e2_init_t1(e2_init_t1));

	
	assign RGB = (blank)? 6'b000000: rgb;

	
	always @(posedge clk) begin			// changing properties each clk
		if (reset) begin
			
		end 
		else begin


		end
	end



	// All output pins must be assigned. If not used, assign to 0.
	
	// Output PMOD - Tiny VGA
    assign uio_out[0] = RGB[1];
    assign uio_out[1] = RGB[3];
    assign uio_out[2] = RGB[5];
    assign uio_out[3] = vsync;
    assign uio_out[4] = RGB[0];
    assign uio_out[5] = RGB[2];
    assign uio_out[6] = RGB[4];
    assign uio_out[7] = hsync;
	
	assign uio_oe[7:0] = 8'b1111_1111;
	assign uo_out[7:0] = 0;




endmodule
