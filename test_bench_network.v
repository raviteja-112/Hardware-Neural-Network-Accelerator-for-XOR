module test_bench_network;
    
    // Testbench signals
    reg clk;
    reg rst;
    reg signed [15:0] a, b, c;
    wire signed [15:0] result;
    
    // Constants for input values
    parameter signed [15:0] ZERO = 16'sh0000;  // 0.0 in Q8.8
    parameter signed [15:0] ONE  = 16'sh0100;  // 1.0 in Q8.8
    
    // Instantiate the neural network Unit Under Test (UUT)
    network uut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .c(c),
        .result(result)
    );
    
    // Clock generation: 100MHz clock (10ns period)
    always #5 clk = ~clk;
    
    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        a = ZERO; 
        b = ZERO; 
        c = ZERO;
        
        // Display test header
        $display("=== 3-Input XOR Neural Network Test ===");
        $display("Time\tA\tB\tC\tResult\tExpected\tStatus");
        $display("------------------------------------------------");
        
        // Release reset after 10ns
        #10 rst = 0;
        
        // Test all 8 combinations of 3-input XOR
        // Test case 1: 0,0,0 -> 0
        #10 a = ZERO; b = ZERO; c = ZERO;
        #20 check_result(0, "000");
        
        // Test case 2: 0,0,1 -> 1
        #10 a = ZERO; b = ZERO; c = ONE;
        #20 check_result(1, "001");
        
        // Test case 3: 0,1,0 -> 1
        #10 a = ZERO; b = ONE; c = ZERO;
        #20 check_result(1, "010");
        
        // Test case 4: 0,1,1 -> 0
        #10 a = ZERO; b = ONE; c = ONE;
        #20 check_result(0, "011");
        
        // Test case 5: 1,0,0 -> 1
        #10 a = ONE; b = ZERO; c = ZERO;
        #20 check_result(1, "100");
        
        // Test case 6: 1,0,1 -> 0
        #10 a = ONE; b = ZERO; c = ONE;
        #20 check_result(0, "101");
        
        // Test case 7: 1,1,0 -> 0
        #10 a = ONE; b = ONE; c = ZERO;
        #20 check_result(0, "110");
        
        // Test case 8: 1,1,1 -> 1
        #10 a = ONE; b = ONE; c = ONE;
        #20 check_result(1, "111");
        
        // Finish simulation
        #10 $display("=== Test Complete ===");
        $finish;
    end
    
    // Task to check results and display status
    task check_result;
        input expected;
        input [2:0] pattern;
        begin
            // Convert result to binary (1 or 0) for comparison
            if ((result > 16'sh0080 && expected == 1) || 
                (result <= 16'sh0080 && expected == 0)) begin
                $display("%0t\t%d\t%d\t%d\t%d\t%d\t\tPASS", 
                        $time, a != 0, b != 0, c != 0, result != 0, expected);
            end else begin
                $display("%0t\t%d\t%d\t%d\t%d\t%d\t\tFAIL", 
                        $time, a != 0, b != 0, c != 0, result != 0, expected);
            end
        end
    endtask
    
    // Monitor to track all signal changes
    initial begin
        $monitor("At time %0t: A=%b, B=%b, C=%b, Result=%b (Raw: %h)", 
                 $time, a != 0, b != 0, c != 0, result != 0, result);
    end
    
    
endmodule