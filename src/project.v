/*
 * Copyright (c) 2024 Matt Pongsagon Vichitvejpaisal
 * SPDX-License-Identifier: Apache-2.0
 */

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
	wire reset = !rst_n;
	
	wire [9:0] x, y;
	wire blank;
	
	wire rx = ui_in[3];
	wire [7:0] read_data;
	wire read_done;
	
	
	vga v(.clk (clk),.reset(reset), .HS (hsync), .VS (vsync), .x (x), .y (y), .blank (blank));
	uart_top UART_UNIT
        (
            .clk(clk),
            .reset(reset),
            .rx(rx),
            .rx_data_out(read_data),
            .rx_done_tick(read_done)
        );

    // test include div.v, slowmpy.v to see area usage
    reg signed [15:0] a;  // -19.9218 = -5100/256
	reg signed [15:0] b;  // -1.9531 = -500/256
    wire signed [31:0] ab;  // large enough for product
    reg i_stb;
    wire o_busy;
    wire o_done;
    wire o_aux;
    slowmpy mul (.i_clk (clk), .i_reset(reset), .i_stb(i_stb),.i_a(a),.i_b(b)
    			,.i_aux(1'b0),.o_busy(o_busy),.o_done(o_done),.o_p(ab),.o_aux(o_aux));
    reg start;
	wire busy;
	wire done;
	wire valid;
	wire dbz;
	wire ovf;
	reg signed [31:0] a32;  
	reg signed [31:0] b32;  
	wire signed [31:0] val;		
    div #(.WIDTH(32),.FBITS(16)) div1 (.clk (clk), .rst(reset),.start(start),.busy(busy),.done(done)
    								,.valid(valid),.dbz(dbz),.ovf(ovf),.a(a32),.b(b32),.val(val));
    
    reg [1:0] state_mul;
    reg [1:0] state_div;


	reg [9:0] o_x, o_y;								// store obj properties, 
	wire object = x>o_x & x<o_x+100 & y>o_y & y<o_y+100;	// define obj shape
	wire border = (x>0 & x<10) | (x>630 & x<640) | (y>0 & y<10) | (y>470 & y<480);
	
	assign R = (border & ~ blank)? 2'b11:0;
	assign G = ((border | object) & ~ blank)? 2'b11:0;
	assign B = (border & ~ blank)? 2'b11:0;
	
	always @(posedge clk) begin			// changing properties each clk
		if (reset) begin
			//mul
			state_mul <= 0;
			state_div <= 0;
			a <= 16'b1110_1100_0001_0100;
			b <= 16'b1111_1110_0000_1100;
			// vga
			o_x <= 320;
			o_y <= 240;
			// div
			i_stb <= 0;
			start <= 0;
			a32 <= 32'b0000_0000_1000_0000_0000_0000_0000_0000;  //  128
	    	b32 <= 32'b0000_0000_0000_1111_0000_0000_0000_0000;  //  15
		end 
		else begin
			// mul
			case (state_mul)
	    		0: begin			
	    			i_stb <= 1;
	    			state_mul <= 1;
	    		end
	    		1: begin	
	    			i_stb <= 0;
	    			//if (o_done) begin
	    			//	c <= ab[23:8];	// ready in 19clk for 16bit mul
	    			//end		
	    		end
	    		default: begin
	    			state_mul <= 0;
	    		end
	    	endcase

	    	// vga
			if (read_done) begin
				if (read_data == 119) begin		// will loop back to 0, warp left/right
					o_y <= o_y - 4;
				end
				if (read_data == 115) begin
					o_y <= o_y + 4;
				end
				if (read_data == 97) begin
					o_x <= o_x - 4;
				end
				if (read_data == 100) begin
					o_x <= o_x + 4;
				end
			end
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
	
	//assign uio_oe[7:0] = 8'b1111_1111;
	//assign uo_out[7:0] = 0;

	assign uio_oe[7:0] = 8'b1111_1111;
	assign uo_out[7:0] = (o_done)? ab[17:10]: 0;
	


endmodule
