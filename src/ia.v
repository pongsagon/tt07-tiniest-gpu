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
						state <= 1;
					end
				end
				2: begin
					update_reg <= 0;
					if (read_done) begin
						read_data <= byte_data;
						idx <= 2;
						update_reg <= 1;
						state <= 54;
					end
				end
				
				54: begin
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


