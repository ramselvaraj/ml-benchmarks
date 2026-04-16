module testbench;

    logic clk;
    logic rst;
    logic start;

    logic signed [15:0] x [4];
    logic y_pred;
    logic signed [31:0] debug_dot;
    logic [31:0] elapsed_cycles;

    logic y_true;
    int   y_true_i;
    int   file;
    int   ret;
    int   rc;
    reg [1023:0] header;

    logic start_run;
    logic valid_out;

    logic [31:0] total_cycles;
    logic [31:0] TP, TN, FP, FN;
    logic [31:0] correct_hw, total_hw;

    real FCLK_HZ = 100_000_000.0;

    real time_ms;
    real throughput;
    real accuracy;
    real precision;
    real recall;
    real f1;
    real forward_ms;

    real f0, f1_in, f2, f3;

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
        x[0] = 0;
        x[1] = 0;
        x[2] = 0;
        x[3] = 0;
        #20;
        rst = 0;
    end

        string label_str;

    initial begin
        file = $fopen("iris_test.csv", "r");
        if (file == 0) begin
            $display("ERROR: Cannot open file");
            $finish;
        end

        $display("CSV opened successfully");

        // Skip header row
        rc = $fgets(header, file);
        $display("Skipped header: %0s", header);

        start_run = 1;
        @(posedge clk);
        start_run = 0;

        while (1) begin
            ret = $fscanf(file, "%f,%f,%f,%f,%s\n", f0, f1_in, f2, f3, label_str);

            if (ret != 5) begin
                $display("Reached end of file or bad row, ret=%0d", ret);
                break;
            end

            // Encode English labels to binary classes
            if (label_str == "Setosa" || label_str == "setosa")
                y_true = 0;
            else if (label_str == "Versicolor" || label_str == "versicolor")
                y_true = 1;
            else begin
                $display("WARNING: Unknown label '%0s', skipping row", label_str);
                continue;
            end

            x[0] = $rtoi(f0    * 256.0);
            x[1] = $rtoi(f1_in * 256.0);
            x[2] = $rtoi(f2    * 256.0);
            x[3] = $rtoi(f3    * 256.0);

            $display("--------------------------------------");
            $display("Applying row at t=%0t", $time);
            $display("Input: %f %f %f %f", f0, f1_in, f2, f3);
            $display("Fixed: %0d %0d %0d %0d", x[0], x[1], x[2], x[3]);
            $display("Label string = %0s", label_str);
            $display("Actual label encoded = %0d", y_true);

            start = 1;
            @(posedge clk);
            start = 0;

            repeat (4) @(posedge clk);

            valid_out = 1;
            @(posedge clk);
            valid_out = 0;

            $display("Dot = %0d", debug_dot);
            $display("Predicted = %0d | Actual = %0d", y_pred, y_true);
            $display("Cycles = %0d", elapsed_cycles);
            $display("Time (ms) = %f", elapsed_cycles / 100000.0);
        end

        repeat (5) @(posedge clk);

        forward_ms = (4.0 / FCLK_HZ) * 1000.0;
        time_ms = (total_cycles / FCLK_HZ) * 1000.0;
        throughput = (time_ms > 0.0) ? (total_hw / (time_ms / 1000.0)) : 0.0;

        accuracy  = (total_hw > 0) ? (correct_hw * 1.0 / total_hw) : 0.0;
        precision = (TP + FP > 0)  ? (TP * 1.0 / (TP + FP)) : 0.0;
        recall    = (TP + FN > 0)  ? (TP * 1.0 / (TP + FN)) : 0.0;
        f1        = (precision + recall > 0.0) ?
                    (2.0 * precision * recall / (precision + recall)) : 0.0;

        $display("======================================");
        $display("Clock Frequency (Hz) = %f", FCLK_HZ);
        $display("input_staging_ms = 0");
        $display("forward_ms = %f", forward_ms);
        $display("loss_metric_ms = 0");
        $display("backward_ms = 0");
        $display("update_ms = 0");
        $display("--------------------------------------");
        $display("Total Time (ms) = %f", time_ms);
        $display("Throughput = %f samples/sec", throughput);
        $display("Memory (bytes) = <from Vivado>");
        $display("--------------------------------------");
        $display("Accuracy  = %f", accuracy);
        $display("Precision = %f", precision);
        $display("Recall    = %f", recall);
        $display("F1        = %f", f1);
        $display("TP=%0d TN=%0d FP=%0d FN=%0d", TP, TN, FP, FN);
        $display("======================================");

        $fclose(file);
        $finish;
    end

endmodule
