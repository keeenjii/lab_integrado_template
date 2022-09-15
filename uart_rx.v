module uart_rx (clk,rst,rx_data,rx_data_fresh,rxd);
  
input clk, rst, rxd;
output [7:0] rx_data;
output rx_data_fresh;

parameter BAUD_DIVISOR = 5208;

reg [15:0] sample_cntr;
reg [7:0] rx_shift;
reg sample_now;
reg [7:0] rx_data;
reg rx_data_fresh;

reg last_rxd;
always @(posedge clk) begin
	last_rxd <= rxd;
end
wire slew = rxd ^ last_rxd;

always @(posedge clk) begin
	if (rst) begin
		sample_cntr <= 0;
		sample_now <= 1'b0;
	end
	else if (sample_cntr == (BAUD_DIVISOR-1) || slew) begin
		sample_cntr <= 0;
	end
	else if (sample_cntr == (BAUD_DIVISOR/2)) begin
		sample_now <= 1'b1;
		sample_cntr <= sample_cntr + 1'b1;
	end
	else begin
		sample_now <= 1'b0;
		sample_cntr <= sample_cntr + 1'b1;
	end
end

reg [1:0] state;
reg [3:0] held_bits;
parameter WAITING = 2'b00, READING = 2'b01, STOP = 2'b10, RECOVER = 2'b11;

always @(posedge clk) begin
	if (rst) begin
		state <= WAITING;
		held_bits <= 0;
		rx_shift <= 0;
		rx_data_fresh <= 1'b0;
		rx_data <= 0;
	end
	else begin
		rx_data_fresh <= 1'b0;
		case (state) 
			WAITING : begin
				// wait for a start bit (0)
				if (!slew & sample_now && !last_rxd) begin
					state <= READING;
					held_bits <= 0;
				end
			end
			READING : begin
				// gather data bits
				if (sample_now) begin
					rx_shift <= {last_rxd,rx_shift[7:1]};
					held_bits <= held_bits + 1'b1;
					if (held_bits == 4'h7) state <= STOP;
				end
			end
			STOP : begin
				// verify stop bit (1)
				if (sample_now) begin
					if (last_rxd) begin
						rx_data <= rx_shift;
						rx_data_fresh <= 1'b1;
						state <= WAITING;
					end
					else begin
						// there was a framing error -
						// discard the byte and work on resync
						state <= RECOVER;
					end
				end					
			end
			RECOVER : begin
				// wait for an idle (1) then resume
				if (sample_now) begin
					if (last_rxd) state <= WAITING;
				end				
			end
		endcase
	end
end

endmodule