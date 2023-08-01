`timescale 1ns/1ps
module controller_tb;

  // Parameters

  //Ports
  reg  clock = 0;
  reg  reset_n = 0;
  reg [117:0] config_in_tdata;
  reg  config_in_tvalid;
  wire  config_in_tready;
  wire [112:0] bitcast_out_tdata;
  wire  bitcast_out_tvalid;
  reg  bicast_out_tredy;

  controller  tensor_config_ctrl_inst (
    .clock(clock),
    .reset_n(reset_n),
    .config_in_tdata(config_in_tdata),
    .config_in_tvalid(config_in_tvalid),
    .config_in_tready(config_in_tready),
    .bitcast_out_tdata(bitcast_out_tdata),
    .bitcast_out_tvalid(bitcast_out_tvalid),
    .bicast_out_tredy(bicast_out_tredy)
  );

  localparam string CONFIG_FP="../test/stimulus/config.csv";

  typedef struct packed {
    reg [4:0]   operator;
    reg [4:0]   sub_field_op;
    reg [39:0]  src_dim;
    reg [39:0]  dstn_dim;
    reg [10:0]  src_addr;
    reg [10:0]  dstn_addr;
    reg [2:0]   in_size;
    reg [2:0]   out_size;
  } w_config;

  w_config wr_config;

  initial begin
    reset_task();
    config_drive(1,CONFIG_FP);
  end

  task automatic reset_task;
    begin
      repeat(3) @(posedge clock);
      reset_n <= ~reset_n;
    end
  endtask //automatic

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
              wr_config.operator,
              wr_config.sub_field_op,
              wr_config.src_dim,
              wr_config.dstn_dim,
              wr_config.src_addr,
              wr_config.dstn_addr,
              wr_config.in_size,
              wr_config.out_size  )==8) begin
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

  always @(posedge clock) begin
    if (!reset_n) begin
      bicast_out_tredy <= 0;
    end
    else begin
      bicast_out_tredy <= ~bicast_out_tredy;
    end
  end

always #5  clock = ! clock ;

endmodule