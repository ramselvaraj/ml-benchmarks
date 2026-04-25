module dec_rom_1d #(
    parameter int DEPTH = 1,
    parameter int DW    = 8,
    parameter string FILE = ""
)(
    output logic signed [DW-1:0] mem [0:DEPTH-1]
);

  integer fd, code, i, value;

  initial begin
    for (i = 0; i < DEPTH; i = i + 1)
      mem[i] = '0;

    fd = $fopen(FILE, "r");
    if (fd == 0) begin
      $display("ERROR: could not open %s", FILE);
      $finish;
    end

    i = 0;
	while (i < DEPTH) begin
	  code = $fscanf(fd, "%d", value);

	  if (code == 1) begin
	    mem[i] = value;
	    i = i + 1;
	  end
	  else begin
	    $display("ERROR: Failed to read integer at index %0d from %s", i, FILE);
	    $finish;
	  end
	end

    $fclose(fd);
    $display("Loaded %0d values from %s", i, FILE);
  end

endmodule
