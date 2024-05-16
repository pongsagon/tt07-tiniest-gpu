//`timescale 1ns / 1ps



module vs(
	input clk, 		
	input reset,
	// from vga
	input [9:0] x,
	input [9:0] y,
	// from uart

	// to raster
	//output reg [1:0] tri_color,				// 2-bit intensity for each tri			
	output reg signed [19:0] x_screen_v0,		// change per frame, int20
	output reg signed [19:0] y_screen_v0,
	output reg signed [19:0] x_screen_v1,		
	output reg signed [19:0] y_screen_v1,
	output reg signed [19:0] x_screen_v2,		
	output reg signed [19:0] y_screen_v2,
	output reg signed [19:0] e0_init_t1,		// change per line, int20
	output reg signed [19:0] e1_init_t1,
	output reg signed [19:0] e2_init_t1
	);

		


	reg signed [19:0] mul_a;  
	reg signed [19:0] mul_b;  
    wire signed [39:0] mul_result;  
    reg mul_start;
    wire mul_busy;
    wire mul_done;
    wire mul_aux;
    slowmpy mul (.i_clk (clk), .i_reset(reset), .i_stb(mul_start),.i_a(mul_a)
    			,.i_b(mul_b),.i_aux(1'b0),.o_busy(mul_busy),.o_done(mul_done)
    			,.o_p(mul_result),.o_aux(mul_aux));
    
    reg signed [31:0] div_a;  
	reg signed [31:0] div_b;  
	wire signed [31:0] div_result;
    reg div_start;
	wire div_busy;
	wire div_done;
	wire div_valid;
	wire div_dbz;
	wire div_ovf;
    div div1 (.clk (clk), .rst(reset),.start(div_start),.busy(div_busy)
    			,.done(div_done),.valid(div_valid),.dbz(div_dbz),.ovf(div_ovf)
    			,.a(div_a),.b(div_b),.val(div_result));


    reg [1:0] state_ei_line;
    reg [3:0] state_ei_frame;
    reg signed [19:0] tmp_ei_mul1;
    reg signed [19:0] tmp_ei_mul2;


	always @(posedge clk) begin
		if (reset) begin
			// mul, div
			div_a <= 0;
			div_b <= 0;
			div_start <= 0;
			mul_a <= 0;
			mul_b <= 0;
			mul_start <= 0;
			//
			state_ei_line <= 1;
			state_ei_frame <= 0;
			tmp_ei_mul1 <= 0;
			tmp_ei_mul2 <= 0;
			// output to raster, test by set value here, 
			//		- max edge length 110 pixel, or else int16 overflow when mul
			x_screen_v0 <= 0;
			y_screen_v0 <= 250;
			x_screen_v1 <= 638;
			y_screen_v1 <= 475;
			x_screen_v2 <= 1;
			y_screen_v2 <= 2;
			e0_init_t1 <= 0;
			e1_init_t1 <= 0;
			e2_init_t1 <= 0;
		end
		else begin

			//////////////////////////////
			// compute e0_init
			//////////////////////////////
			if (y < 480) begin
				if (x == 640) begin
					// @ endline, compute e0_init -= x2x1; 
					// 		- must finished before x == 799, raster will use e0_init @ x == 799
					state_ei_line <= state_ei_line + 1;
					if (state_ei_line == 1) begin
						state_ei_line <= 0;
						e0_init_t1 <= e0_init_t1 - (x_screen_v1 - x_screen_v0);		// b0
						e1_init_t1 <= e1_init_t1 - (x_screen_v2 - x_screen_v1);		// b1
						e2_init_t1 <= e2_init_t1 - (x_screen_v0 - x_screen_v2);		// b2
					end
				end
			end // y < 480
			else begin
				// @ endframe, compute e0_init = (-pts[0].x * a0) + (pts[0].y * (pts[1].x-pts[0].x);
				//		- call mul 6  time
				case (state_ei_frame)
					0: begin
						if ((y == 480) && (x == 0)) begin
							mul_a <= x_screen_v0;					// pts[0].x
							mul_b <= y_screen_v0 - y_screen_v1;		// -a0
							mul_start <= 1;
							state_ei_frame <= 1;
						end
					end
					1: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[19:0];		// ready in 19clk for 16bit mul
							mul_a <= y_screen_v0;					// pts[0].y
							mul_b <= x_screen_v1 - x_screen_v0;		// b0
							mul_start <= 1;
							state_ei_frame <= 2;
						end
					end
					2: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= mul_result[19:0];
							state_ei_frame <= 3;
						end 
					end
					3: begin
						e0_init_t1 <= tmp_ei_mul2 + tmp_ei_mul1;	// fin e0_init_t1
						mul_a <= x_screen_v1;						// pts[1].x
						mul_b <= y_screen_v1 - y_screen_v2;			// -a1
						mul_start <= 1;
						state_ei_frame <= 4;
					end 
					4: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[19:0];		// ready in 19clk for 16bit mul
							mul_a <= y_screen_v1;					// pts[1].y
							mul_b <= x_screen_v2 - x_screen_v1;		// b1
							mul_start <= 1;
							state_ei_frame <= 5;
						end
					end
					5: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= mul_result[19:0];
							state_ei_frame <= 6;
						end 
					end
					6: begin
						e1_init_t1 <= tmp_ei_mul2 + tmp_ei_mul1;	// fin e1_init_t1
						mul_a <= x_screen_v2;						// pts[2].x
						mul_b <= y_screen_v2 - y_screen_v0;			// -a2
						mul_start <= 1;
						state_ei_frame <= 7;
					end 
					7: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul1 <= mul_result[19:0];		// ready in 19clk for 16bit mul
							mul_a <= y_screen_v2;					// pts[2].y
							mul_b <= x_screen_v0 - x_screen_v2;		// b2
							mul_start <= 1;
							state_ei_frame <= 8;
						end
					end
					8: begin
						mul_start <= 0;
						if (mul_done) begin
							tmp_ei_mul2 <= mul_result[19:0];
							state_ei_frame <= 9;
						end 
					end
					9: begin
						e2_init_t1 <= tmp_ei_mul2 + tmp_ei_mul1;	// fin e2_init_t1
						state_ei_frame <= 0;
					end 
					default: begin
						state_ei_frame <= 0;
					end
				endcase
			end



		end // reset
	end



endmodule

