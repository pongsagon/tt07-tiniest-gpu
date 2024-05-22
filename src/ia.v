//`timescale 1ns / 1ps
//`default_nettype wire



module ia(
	input clk, 		
	input reset,
	input rx,
	output reg pc_ready,				//must be true for only 1 clk
	output reg [7:0] read_data,
	output reg [5:0] idx,				// 0-54
	output reg update_reg
	);
	
	
	wire read_done;
	wire [7:0] byte_data;

	uart_top UART_UNIT(.clk(clk),.reset(reset),.rx(rx),
						.rx_data_out(byte_data),.rx_done_tick(read_done));


	reg [5:0] state;

	always @(posedge clk) begin
		if (reset) begin
			pc_ready <= 0;
			update_reg <= 0;
			idx <= 0;
			read_data <= 0;
			state <= 0;
		end
		else begin
			case (state)
				0: begin
					pc_ready <= 0;
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 0;
						update_reg <= 1;
						state <= 1;
					end
				end
				1: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 1;
						update_reg <= 1;
						state <= 2;
					end
				end
				2: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 2;
						update_reg <= 1;
						state <= 3;
					end
				end
				3: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 3;
						update_reg <= 1;
						state <= 4;
					end
				end
				4: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 4;
						update_reg <= 1;
						state <= 5;
					end
				end
				5: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 5;
						update_reg <= 1;
						state <= 6;
					end
				end
				6: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 6;
						update_reg <= 1;
						state <= 7;
					end
				end
				7: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 7;
						update_reg <= 1;
						state <= 8;
					end
				end
				8: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 8;
						update_reg <= 1;
						state <= 9;
					end
				end
				9: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 9;
						update_reg <= 1;
						state <= 10;
					end
				end
				10: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 10;
						update_reg <= 1;
						state <= 11;
					end
				end
				11: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 11;
						update_reg <= 1;
						state <= 12;
					end
				end
				12: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 12;
						update_reg <= 1;
						state <= 13;
					end
				end
				13: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 13;
						update_reg <= 1;
						state <= 14;
					end
				end
				14: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 14;
						update_reg <= 1;
						state <= 15;
					end
				end
				15: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 15;
						update_reg <= 1;
						state <= 16;
					end
				end
				16: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 16;
						update_reg <= 1;
						state <= 17;
					end
				end
				17: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 17;
						update_reg <= 1;
						state <= 18;
					end
				end
				18: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 18;
						update_reg <= 1;
						state <= 19;
					end
				end
				19: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 19;
						update_reg <= 1;
						state <= 20;
					end
				end
				20: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 20;
						update_reg <= 1;
						state <= 21;
					end
				end
				21: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 21;
						update_reg <= 1;
						state <= 22;
					end
				end
				22: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 22;
						update_reg <= 1;
						state <= 23;
					end
				end
				23: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 23;
						update_reg <= 1;
						state <= 24;
					end
				end
				24: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 24;
						update_reg <= 1;
						state <= 25;
					end
				end
				25: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 25;
						update_reg <= 1;
						state <= 26;
					end
				end
				26: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 26;
						update_reg <= 1;
						state <= 27;
					end
				end
				27: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 27;
						update_reg <= 1;
						state <= 28;
					end
				end
				28: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 28;
						update_reg <= 1;
						state <= 29;
					end
				end
				29: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 29;
						update_reg <= 1;
						state <= 30;
					end
				end
				30: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 30;
						update_reg <= 1;
						state <= 31;
					end
				end
				31: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 31;
						update_reg <= 1;
						state <= 32;
					end
				end
				32: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 32;
						update_reg <= 1;
						state <= 33;
					end
				end
				33: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 33;
						update_reg <= 1;
						state <= 34;
					end
				end
				34: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 34;
						update_reg <= 1;
						state <= 35;
					end
				end
				35: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 35;
						update_reg <= 1;
						state <= 36;
					end
				end
				36: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 36;
						update_reg <= 1;
						state <= 37;
					end
				end
				37: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 37;
						update_reg <= 1;
						state <= 38;
					end
				end
				38: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 38;
						update_reg <= 1;
						state <= 39;
					end
				end
				39: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 39;
						update_reg <= 1;
						state <= 40;
					end
				end
				40: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 40;
						update_reg <= 1;
						state <= 41;
					end
				end
				41: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 41;
						update_reg <= 1;
						state <= 42;
					end
				end
				42: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 42;
						update_reg <= 1;
						state <= 43;
					end
				end
				43: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 43;
						update_reg <= 1;
						state <= 44;
					end
				end
				44: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 44;
						update_reg <= 1;
						state <= 45;
					end
				end
				45: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 45;
						update_reg <= 1;
						state <= 46;
					end
				end
				46: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 46;
						update_reg <= 1;
						state <= 47;
					end
				end
				47: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 47;
						update_reg <= 1;
						state <= 48;
					end
				end
				48: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 48;
						update_reg <= 1;
						state <= 49;
					end
				end
				49: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 49;
						update_reg <= 1;
						state <= 50;
					end
				end
				50: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 50;
						update_reg <= 1;
						state <= 51;
					end
				end
				51: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 51;
						update_reg <= 1;
						state <= 52;
					end
				end
				52: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 52;
						update_reg <= 1;
						state <= 53;
					end
				end
				53: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 53;
						update_reg <= 1;
						state <= 54;
					end
				end
				54: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 54;
						update_reg <= 1;
						state <= 55;
					end
				end
				// wait for vp_33 to get read_data
				55: begin
					update_reg <= 0;
					pc_ready <= 1;
					state <= 0;
				end

				default: begin
					state <= 0;
				end
			endcase
		end
	end
	
endmodule


