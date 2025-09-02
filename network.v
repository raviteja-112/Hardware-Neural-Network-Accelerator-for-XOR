module network (
    input wire clk,
    input wire rst,
    input wire signed [15:0] a, b, c,  
    output reg signed [15:0] result    
);
    
    // Hidden layer weights and biases (pre-trained for 3-input XOR)
    parameter signed [15:0] w1 [0:2] = '{16'sh0080, 16'shFF80, 16'sh0080}; // [0.5, -0.5, 0.5]
    parameter signed [15:0] w2 [0:2] = '{16'shFF80, 16'sh0080, 16'shFF80}; // [-0.5, 0.5, -0.5]
    parameter signed [15:0] w3 [0:2] = '{16'sh0080, 16'shFF80, 16'shFF80}; // [0.5, -0.5, -0.5]
    parameter signed [15:0] w4 [0:2] = '{16'shFF80, 16'sh0080, 16'sh0080}; // [-0.5, 0.5, 0.5]
    
    parameter signed [15:0] b1 = 16'shFF00; // -1.0
    parameter signed [15:0] b2 = 16'shFF00; // -1.0
    parameter signed [15:0] b3 = 16'sh0100; // 1.0
    parameter signed [15:0] b4 = 16'sh0100; // 1.0
    
    // Output layer weights and bias
    parameter signed [15:0] w_out [0:3] = '{16'sh0100, 16'sh0100, 16'sh0100, 16'sh0100}; // [1.0, 1.0, 1.0, 1.0]
    parameter signed [15:0] b_out = 16'shFE00; // -2.0
    
    // Hidden layer outputs
    wire signed [15:0] h1, h2, h3, h4;
    
    // Input array for convenience
    wire signed [15:0] inputs [0:2];
    assign inputs[0] = a;
    assign inputs[1] = b;
    assign inputs[2] = c;
    
    // Hidden layer neurons - FIXED: individual port connections
    neuron neuron1 (
        .clk(clk),
        .rst(rst),
        .input0(inputs[0]),
        .input1(inputs[1]),
        .input2(inputs[2]),
        .weight0(w1[0]),
        .weight1(w1[1]),
        .weight2(w1[2]),
        .bias(b1),
        .output_val(h1)
    );
    
    neuron neuron2 (
        .clk(clk),
        .rst(rst),
        .input0(inputs[0]),
        .input1(inputs[1]),
        .input2(inputs[2]),
        .weight0(w2[0]),
        .weight1(w2[1]),
        .weight2(w2[2]),
        .bias(b2),
        .output_val(h2)
    );
    
    neuron neuron3 (
        .clk(clk),
        .rst(rst),
        .input0(inputs[0]),
        .input1(inputs[1]),
        .input2(inputs[2]),
        .weight0(w3[0]),
        .weight1(w3[1]),
        .weight2(w3[2]),
        .bias(b3),
        .output_val(h3)
    );
    
    neuron neuron4 (
        .clk(clk),
        .rst(rst),
        .input0(inputs[0]),
        .input1(inputs[1]),
        .input2(inputs[2]),
        .weight0(w4[0]),
        .weight1(w4[1]),
        .weight2(w4[2]),
        .bias(b4),
        .output_val(h4)
    );
    
    // Output layer calculation
    wire signed [31:0] output_sum;     // Q16.16 format
    wire signed [15:0] activated_output; // Q8.8 format
    
    // Multiply and accumulate for output layer
    assign output_sum = (h1 * w_out[0]) + 
                       (h2 * w_out[1]) + 
                       (h3 * w_out[2]) + 
                       (h4 * w_out[3]) + 
                       b_out;
    
    // Output activation function
    sigmoid output_activation (
        .x(output_sum[23:8]),  // Convert Q16.16 to Q8.8
        .y(activated_output)
    );
    
    // Output register with thresholding
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 16'sb0;  // Reset output to 0
        end else begin
            // Binary threshold: if activated_output > 0.5, output 1.0, else 0.0
            if (activated_output > 16'sh0080) // 0.5 in Q8.8 = 128
                result <= 16'sh0100; // 1.0 in Q8.8
            else
                result <= 16'sb0;    // 0.0
        end
    end
endmodule
