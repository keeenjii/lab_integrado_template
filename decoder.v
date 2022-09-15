module decoder
	(
		input wire [7:0] ascii_code,
		output reg [7:0] output_code
	);
	
always @*
	begin
	case(ascii_code)
		8'h31: output_code = 8'd1;   // 1
		8'h32: output_code = 8'd2;   // 2
		8'h33: output_code = 8'd3;   // 3
		8'h34: output_code = 8'd4;   // 4
		8'h35: output_code = 8'd5;   // 5
		8'h36: output_code = 8'd6;   // 6
		8'h37: output_code = 8'd7;   // 7
		8'h38: output_code = 8'd8;   // 8
		8'h39: output_code = 8'd9;   // 9
		8'h61: output_code = 8'd10;  // a
		8'h62: output_code = 8'd11;  // b
		8'h63: output_code = 8'd12;  // c
		8'h64: output_code = 8'd13;  // d
		8'h65: output_code = 8'd14;  // e
		8'h66: output_code = 8'd15;  // f
		8'h67: output_code = 8'd16;  // g
		8'h68: output_code = 8'd17;  // h
		8'h69: output_code = 8'd18;  // i
		
		default: ascii_code = 8'd0; // *
	endcase

	end
endmodule
