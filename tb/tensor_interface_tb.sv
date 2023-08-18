module tensor_interface_tb;

  // Parameters

  //Ports
  reg  clock;
  reg  reset_n;
  reg [106:0] config_in_tdata;
  reg  config_in_tvalid;
  wire  config_in_tready;
  wire [15:0] ar_addr;
  wire  ar_valid;
  reg  ar_ready;
  reg [31:0] r_data;
  reg  r_last;
  reg  r_valid;
  wire  r_ready;
  wire [15:0] aw_addr;
  wire  aw_valid;
  reg  aw_ready;
  wire [31:0] w_data;
  wire  w_last;
  wire  w_valid;
  reg  w_ready;
  reg  b_resp;
  reg  b_valid;
  wire  b_ready;
  wire [31:0] out_data;
  wire  out_last;
  wire  out_valid;
  reg  out_ready;

  tensor_interface  tensor_interface_inst (
    .clock(clock),
    .reset_n(reset_n),
    .config_in_tdata(config_in_tdata),
    .config_in_tvalid(config_in_tvalid),
    .config_in_tready(config_in_tready),
    .ar_addr(ar_addr),
    .ar_valid(ar_valid),
    .ar_ready(ar_ready),
    .r_data(r_data),
    .r_last(r_last),
    .r_valid(r_valid),
    .r_ready(r_ready),
    .aw_addr(aw_addr),
    .aw_valid(aw_valid),
    .aw_ready(aw_ready),
    .w_data(w_data),
    .w_last(w_last),
    .w_valid(w_valid),
    .w_ready(w_ready),
    .b_resp(b_resp),
    .b_valid(b_valid),
    .b_ready(b_ready),
    .out_data(out_data),
    .out_last(out_last),
    .out_valid(out_valid),
    .out_ready(out_ready)
  );

  localparam string CONFIG_FP ="../test/stimulus/interface_config.csv";
  localparam string RD_DATA_FP="../test/stimulus/rd_data.mem";

  typedef struct packed {
    reg [1:0]   rd_wr;
    reg [2:0]   operation;
    reg [10:0]  rd_base_addr;
    reg [39:0]  rd_dim;
    reg [10:0]  wr_base_addr;
    reg [39:0]   wr_dim;
  } w_config;

  w_config wr_config;

  initial begin
    rest_task();
    fork
      begin
        config_drive(1,CONFIG_FP);
      end
      begin
        rd_data_drive(1,RD_DATA_FP);
      end
    join 
  end
  // Reset Task
  task automatic rest_task;
  begin
    wait(5) @(posedge clock);
    reset_n = ~ reset_n;
  end
  endtask

  // CONFIG TASK
  task automatic config_drive;
  input int WAIT_CYCLES;
  input string FILE_NAME;
  begin
      int fp;
      logic [112:0] config_data;
      int wait_n;
      fp = $fopen(FILE_NAME,"r");
      // stopt simulation if file not there
      if (fp == 0) begin
          $fatal(1, "ERROR: FILE NOT FOUND\t %s \n",FILE_NAME);
      end

      wait(reset_n);
      @(posedge clock);
      while ($fscanf(fp,"%d,%d,%d,%d,%d,%d,%d,%d,",
              wr_config.rd_wr,
              wr_config.operation,
              wr_config.rd_base_addr,
              wr_config.rd_dim,
              wr_config.wr_base_addr,
              wr_config.wr_dim )==6) begin
          config_in_tdata  <= wr_config;
          config_in_tvalid <= 1;
          @(posedge clock);
          while(~config_in_tready) @(posedge clock);
          config_in_tvalid <= 0;

          wait_n = $urandom % WAIT_CYCLES;
          if (wait_n > 0) $display("waiting for %d cycles",wait_n);
          repeat(wait_n) @(posedge clock); 
      end
      $fclose(FILE_NAME);
  end
  endtask

  // READ DATA TASK
  task automatic rd_data_drive;
  input int WAIT_CYCLES;
  input string FILE_NAME;
  begin
      int fp;
      reg [31:0] data_in_data;
      reg data_in_tlast;
      int wait_n;
      fp = $fopen(FILE_NAME,"r");
      // stopt simulation if file not there
      if (fp == 0) begin
          $fatal(1, "ERROR: FILE NOT FOUND\t %s \n",FILE_NAME);
      end

      wait(reset_n);
      @(posedge clock);
      while ($fscanf(fp,"%h",data_in_data)==1) begin
          r_data  <= data_in_data;
          r_valid <= 1;
          r_last  <= data_in_data[0];
          @(posedge clock);
          while(~r_ready) @(posedge clock);
          r_valid <= 0;

          wait_n = $urandom % WAIT_CYCLES;
          if (wait_n > 0) $display("waiting for %d cycles",wait_n);
          repeat(wait_n) @(posedge clock); 
      end
      $fclose(FILE_NAME);
  end
  endtask

  always @(posedge clock) begin
    if (!reset_n) begin
      ar_ready <= 0;
      out_ready <= 0;
      w_ready <= 0;
      b_resp  <= 0;
      b_valid <= 0;
    end
    else begin
      ar_ready <= 1;
      out_ready <= 1;
    end
  end




always #5  clock = ! clock ;

endmodule