module neuron (
    input wire clk,
    input wire rst,
   
    input wire signed [15:0] input0,  
    input wire signed [15:0] input1, 
    input wire signed [15:0] input2, 
    
    input wire signed [15:0] weight0, 
    input wire signed [15:0] weight1, 
    input wire signed [15:0] weight2, 
    input wire signed [15:0] bias,   
    output reg signed [15:0] output_val 
);
    
    wire signed [31:0] weighted_sum; 
    wire signed [15:0] activated;    
    

    assign weighted_sum = (input0 * weight0) +  // input0 × weight0
                         (input1 * weight1) +  // input1 × weight1
                         (input2 * weight2) +  // input2 × weight2
                         bias;                 // Add bias (extended to 32 bits)
    
    // Sigmoid activation function instance
    // Extract bits [23:8] from 32-bit weighted_sum to convert Q16.16 ? Q8.8
    sigmoid activation (
        .x(weighted_sum[23:8]),  
        .y(activated)            
    );
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset condition: clear output to zero
            output_val <= 16'sb0;  
        end else begin
            
            output_val <= activated; 
        end
    end
endmodule