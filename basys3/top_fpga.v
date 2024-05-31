/*
 * Copyright (c) 2024 Matt Pongsagon Vichitvejpaisal
 * SPDX-License-Identifier: Apache-2.0
 */
//`timescale 1ns / 1ps


module top_gpu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n    // reset_n - low to reset
);

	clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_50(clk_50),     // output clk_50
    // Status and control signals
    .reset(!rst_n), // input reset
   // Clock in ports
    .clk_100(clk));      // input clk_100
	
	tt_um_pongsagon_tiniest_gpu gpu (.ui_in(ui_in),.uo_out(uo_out),
					.uio_in(uio_in),.uio_out(uio_out),.uio_oe(uio_oe),
					.ena(ena),.clk(clk_50),.rst_n(rst_n));
	
endmodule

