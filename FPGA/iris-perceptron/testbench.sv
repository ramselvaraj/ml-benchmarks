.module testbench;

    logic clk;
    logic rst;
    logic start;

    logic signed [15:0] x [4];
    logic y_pred;
    logic signed [31:0] debug_dot;
    logic [31:0] elapsed_cycles;

    int y_true;
    int file;
    reg [1023:0] header;

    logic start_run;
    logic valid_out;

    logic [31:0] total_cycles;
    logic [31:0] TP, TN, FP, FN;
    logic [31:0] correct_hw, total_hw;

    // Clock frequency (UPDATE from Vivado later)
    real FCLK_HZ = 100_000_000.0;

    real time_ms;
    real throughput;
    real accuracy;
    real precision;
    real recall;
    real f1;
    real forward_ms;

    perceptron_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x_in(x),
        .y_out(y_pred),
        .debug_dot(debug_dot),
        .elapsed_cycles(elapsed_cycles)
    );

    fpga_benchmark bench (
        .clk(clk),
        .rst(rst),
        .start(start_run),
        .valid_out(valid_out),
        .y_pred(y_pred),
        .y_true(y_true),
        .total_cycles(total_cycles),
        .TP(TP), .TN(TN), .FP(FP), .FN(FN),
        .correct(correct_hw),
        .total(total_hw)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        start_run = 0;
        valid_out = 0;
        #20;
        rst = 0;
    end

    initial begin
        file = $fopen("iris_test.csv", "r");

        if (file == 0) begin
            $display("ERROR: Cannot open file");
            $finish;
        end

        $fgets(header, file);

        start_run = 1;
        @(posedge clk);
        start_run = 0;

        while (!$feof(file)) begin
            real f0,f1,f2,f3;
            int ret;

            ret = $fscanf(file,"%f,%f,%f,%f,%d",f0,f1,f2,f3,y_true);

            if (ret == 5) begin
                x[0] = $rtoi(f0 * 256.0);
                x[1] = $rtoi(f1 * 256.0);
                x[2] = $rtoi(f2 * 256.0);
                x[3] = $rtoi(f3 * 256.0);

                start = 1;
                @(posedge clk);
                start = 0;

                repeat(3) @(posedge clk);
                @(posedge clk);

                valid_out = 1;
                @(posedge clk);
                valid_out = 0;

                $display("--------------------------------------");
                $display("Input: %f %f %f %f", f0, f1, f2, f3);
                $display("Dot = %0d", debug_dot);
                $display("Predicted = %0d | Actual = %0d",
                          y_pred, y_true);
                $display("Cycles = %0d", elapsed_cycles);
                $display("Time (ms) = %f", elapsed_cycles / 100000.0);
            end
        end

        repeat(5) @(posedge clk);

        // Calculations
        forward_ms = (4.0 / FCLK_HZ) * 1000.0;
        time_ms = (total_cycles / FCLK_HZ) * 1000.0;
        throughput = total_hw / (time_ms / 1000.0);

        accuracy = correct_hw * 1.0 / total_hw;
        precision = TP * 1.0 / (TP + FP + 1e-9);
        recall = TP * 1.0 / (TP + FN + 1e-9);
        f1 = 2.0 * precision * recall / (precision + recall + 1e-9);

        $display("======================================");
        $display("Clock Frequency (Hz) = %f", FCLK_HZ);

        $display("input_staging_ms = 0 (no buffering)");
        $display("forward_ms = %f (4/Fclk *1000)", forward_ms);
        $display("loss_metric_ms = 0");
        $display("backward_ms = 0");
        $display("update_ms = 0");

        $display("--------------------------------------");

        $display("Total Time (ms) = %f (%0d/Fclk *1000)",
                  time_ms, total_cycles);

        $display("Throughput = %f samples/sec (samples/time)",
                  throughput);

        $display("Memory (bytes) = <from Vivado>");

        $display("--------------------------------------");

        $display("Accuracy  = %f (correct/total)", accuracy);
        $display("Precision = %f (TP/(TP+FP))", precision);
        $display("Recall    = %f (TP/(TP+FN))", recall);
        $display("F1        = %f (2PR/(P+R))", f1);

        $display("TP=%0d TN=%0d FP=%0d FN=%0d", TP, TN, FP, FN);

        $display("======================================");

        $fclose(file);
        $finish;
    end

endmodule