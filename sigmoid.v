module sigmoid (
    input wire signed [15:0] x, 
    output reg signed [15:0] y   
);
    // Simplified sigmoid approximation: y = 1/(1 + e^-x)
    // Using fixed-point arithmetic: Q8.8 format
	always @(*) begin
    		if (x > 2048) y = 16'sh0100;  // 1.0 in Q8.8 (256)
    		else if (x < -2048) y = 0;     // 0.0
    		else begin
        // Better linear approximation: y = 0.5 + x/8
        // In Q8.8: 0.5 = 128, x/8 = x >> 3
        	y = 16'sh0080 + (x >>> 3);  // Use arithmetic right shift
    		end
	end
endmodule