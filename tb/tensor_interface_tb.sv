module tensor_interface_tb;

  // Parameters

  //Ports
  reg  clock = 0;
  reg  reset_n = 0;
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

  reg  [31:0] mem [99:0];

  initial begin
    mem[0]=32'h295A4;
    mem[1]=32'h9EAF3;
    mem[2]=32'h912F;
    mem[3]=32'h4C1C7;
    mem[4]=32'h4F01E;
    mem[5]=32'h94521;
    mem[6]=32'h9EE95;
    mem[7]=32'hCE906;
    mem[8]=32'hE276C;
    mem[9]=32'hA142E;
    mem[10]=32'h8D2D2;
    mem[11]=32'h615F4;
    mem[12]=32'hEBFDC;
    mem[13]=32'h25A88;
    mem[14]=32'hDA884;
    mem[15]=32'h4BF6F;
    mem[16]=32'h85EE3;
    mem[17]=32'hA6892;
    mem[18]=32'h39C4E;
    mem[19]=32'h28FDF;
    mem[20]=32'h7C2A4;
    mem[21]=32'hC1562;
    mem[22]=32'hA90FC;
    mem[23]=32'h1D16D;
    mem[24]=32'hDBE9A;
    mem[25]=32'h75262;
    mem[26]=32'hE7200;
    mem[27]=32'h87233;
    mem[28]=32'h14BF8;
    mem[29]=32'h3177E;
    mem[30]=32'hD08FB;
    mem[31]=32'hAC5C2;
    mem[32]=32'hDA7F1;
    mem[33]=32'h50640;
    mem[34]=32'h80EE0;
    mem[35]=32'h9ECE4;
    mem[36]=32'h911C4;
    mem[37]=32'h388C0;
    mem[38]=32'h683B8;
    mem[39]=32'h3C9C6;
    mem[40]=32'hCE74E;
    mem[41]=32'hF0E39;
    mem[42]=32'h104C5;
    mem[43]=32'hAE501;
    mem[44]=32'h50A09;
    mem[45]=32'h98B66;
    mem[46]=32'h3F0E6;
    mem[47]=32'h9EF46;
    mem[48]=32'h5AA49;
    mem[49]=32'h48032;
    mem[50]=32'hDE9A5;
    mem[51]=32'hE61AF;
    mem[52]=32'h95CFB;
    mem[53]=32'h34661;
    mem[54]=32'hE55A7;
    mem[55]=32'hB73A8;
    mem[56]=32'hB7624;
    mem[57]=32'h33BA7;
    mem[58]=32'hCAAEF;
    mem[59]=32'h3AA77;
    mem[60]=32'h9A38F;
    mem[61]=32'hAD88E;
    mem[62]=32'hB5423;
    mem[63]=32'h5F4F3;
    mem[64]=32'hB9842;
    mem[65]=32'hDC72C;
    mem[66]=32'h8F6EF;
    mem[67]=32'h161DF;
    mem[68]=32'h1F87E;
    mem[69]=32'h19BE1;
    mem[70]=32'h2A35D;
    mem[71]=32'h1EE8D;
    mem[72]=32'hBE06A;
    mem[73]=32'h9AB3;
    mem[74]=32'h3B02E;
    mem[75]=32'hD69F3;
    mem[76]=32'hEDAD5;
    mem[77]=32'h93D3D;
    mem[78]=32'hEE573;
    mem[79]=32'hAA7A;
    mem[80]=32'hE7968;
    mem[81]=32'h4C08A;
    mem[82]=32'hC3125;
    mem[83]=32'hC5EAB;
    mem[84]=32'hD1F7B;
    mem[85]=32'h6FFA3;
    mem[86]=32'hE3363;
    mem[87]=32'h3EFF9;
    mem[88]=32'hE423B;
    mem[89]=32'h972BC;
    mem[90]=32'hF0968;
    mem[91]=32'h8045;
    mem[92]=32'hB10E6;
    mem[93]=32'h8A189;
    mem[94]=32'h783EE;
    mem[95]=32'h3F526;
    mem[96]=32'h4FD35;
    mem[97]=32'h3CF0C;
    mem[98]=32'h35920;
    mem[99]=32'hC33D5;
end

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
      while ($fscanf(fp,"%d,%d,%d,%d,%d,%d",
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

  always @(posedge clock) begin
    if (!reset_n) begin
      r_data <= 0;
      r_last <= 0;
      r_valid <= 0;
    end
    else begin
      if (ar_valid) begin
        r_data <= mem[ar_addr];
        r_valid <= 1;
        if (ar_addr==(wr_config.rd_base_addr + 30 - 1)) begin
          r_last <= 1;
        end
      end
    end
  end

always #5  clock = ! clock ;

endmodule