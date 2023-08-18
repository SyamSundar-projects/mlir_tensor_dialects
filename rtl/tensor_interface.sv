/*
config is divided into
    config_data[106:0]	        bitwidth	to	from
    read_en,write_en	        2	        106	105
    element_size	            3	        104	102
    rd_base_addr	            11	        101	91
    rd_dimensions(#of bytes)	40	        90	51
    wr_base_addr	            11	        50	40
    wr_dimensions	            40	        39	0
*/
module tensor_interface(
    input               clock,
    input               reset_n,
    // config
input [106:0]           config_in_tdata,
    input               config_in_tvalid,
    output              config_in_tready,
    // read address
    output reg [15:0]   ar_addr,
    output reg          ar_valid,
input                   ar_ready,
    // read data
    input [31:0]        r_data,
    input               r_last,
    input               r_valid,
    output              r_ready,
    // write address
    output reg [15:0]   aw_addr,
    output reg          aw_valid,
    input               aw_ready,   
    // write data
    output reg [31:0]   w_data,
    output reg          w_last,
    output reg          w_valid,
    input               w_ready,
    // write response
    input               b_resp,
    input               b_valid,
    output              b_ready,
    // output 
    output reg [31:0]   out_data,
    output reg          out_last,
    output reg          out_valid,
    input               out_ready        
);

reg [2:0] state,next_state;
//read write enable
reg [1:0] rd_wr;//11 - rd & wr,10 - only rd,01 - only wr,00 - neither rd not wr
//read variables
reg [10:0] rd_base_addr;
reg [15:0] no_of_rd;
reg [15:0] rd_addr_count;
//write variables
reg [10:0] wr_base_addr;
reg [15:0] no_of_wr;
reg [15:0] wr_addr_count;

// #words to read count
always @(posedge clock) begin
    if (!reset_n) no_of_rd <= 0;
    else if (config_in_tvalid && config_in_tready) begin
        rd_wr = config_in_tdata[106:105];
        
        case (config_in_tdata[104:102])
            0: no_of_rd <= 0;
            1: no_of_rd <= config_in_tdata[90:51] >> 2;
            2: no_of_rd <= config_in_tdata[90:51] >> 1;
            3: no_of_rd <= config_in_tdata[90:51];
            4: no_of_rd <= config_in_tdata[90:51];
            5: no_of_rd <= (config_in_tdata[90:51]*5)>>2 + 1;
            6: no_of_rd <= (config_in_tdata[90:51]*6)>>2 + 1;
            7: no_of_rd <= (config_in_tdata[90:51]*7)>>2 + 1;
            default: no_of_rd <= config_in_tdata[90:51];
        endcase
        rd_base_addr <= config_in_tdata[101:91];

        case (config_in_tdata[104:102])
            0: no_of_wr <= 0;
            1: no_of_wr <= config_in_tdata[39:0] >> 2;
            2: no_of_wr <= config_in_tdata[39:0] >> 1;
            3: no_of_wr <= config_in_tdata[39:0];
            4: no_of_wr <= config_in_tdata[39:0];
            5: no_of_wr <= (config_in_tdata[39:0]*5)>>2 + 1;
            6: no_of_wr <= (config_in_tdata[39:0]*6)>>2 + 1;
            7: no_of_wr <= (config_in_tdata[39:0]*7)>>2 + 1;
            default: no_of_wr <= config_in_tdata[39:0];
        endcase
        wr_base_addr <= config_in_tdata[50:40];
    end
end

//Present State
always @(posedge clock) begin
    if (!reset_n) state <= 0;
    else state <= next_state;
end
/*
STATES
0 - RD_CONFIG
1 - AR_ADDR
2 - R_DATA
3 - AW_ADDR
4 - W_DATA
5 - B_RES
*/
//Next State FSM
always @(*) begin
    case (state)
        0:  if (config_in_tvalid) 
                if (config_in_tdata[106:105]==1) next_state = 3;
                else if (config_in_tdata[106:105]==2 || config_in_tdata[106:105]==3) next_state = 1;
                else next_state = 0;
            else next_state = 0;
        1:  if (ar_ready) next_state = 2;
            else next_state = 1;
        2:  if (r_valid && r_last) 
                if (rd_wr==3) next_state = 3;
                else next_state = 0;
            else next_state = 0;
        3:  if(aw_ready) next_state = 4;
            else next_state = 3;
        4:  if(w_ready && wr_addr_count == no_of_wr-1) next_state = 5;
            else next_state = 4;
        5:  if(b_valid && b_resp) next_state = 0;
            else next_state = 5;
        default: next_state = 0;
    endcase
end

always @(posedge clock) begin

    // AR
    if (state == 1 && ar_ready) begin
        ar_addr  <= rd_base_addr;
        ar_valid <= 1;
    end
    else if (state == 2 && r_valid) begin
        ar_addr  <= rd_base_addr + rd_addr_count;
        ar_valid <= 1;
    end
    else begin 
        ar_addr  <= 0;
        ar_valid <= 0;
    end 

    // OUT
    if (state == 2) begin
        out_data  <= r_data;
        out_valid <= r_valid;
        out_last  <= r_last;
    end

    // AW
    if (state == 3 && aw_ready) begin
        aw_addr  <= wr_base_addr;
        aw_valid <= 1;
    end
    else if (state == 4 && w_ready) begin
        aw_addr  <= wr_base_addr + wr_addr_count;
        aw_valid <= 1;
    end
    else begin
        aw_addr  <= 0;
        aw_valid <= 0;
    end

    // W
    if (state == 4 && w_ready) begin
        w_data  <= 0;//TODO has to be decide whether to add a data input port or not to w_data
        w_valid <= 1;
    end

    // rd_counter
    if (state == 0) rd_addr_count <= 0;
    else if(state == 2) rd_addr_count <= rd_addr_count + 1;
     
    // wr_counter
    if (state == 0) wr_addr_count <= 0;
    else if(state == 4) wr_addr_count <= wr_addr_count + 1;

end

// b_resp
assign b_ready = state == 5;

// r_ready
assign r_ready = out_ready && (state==2);

// CONFIG TREADY
assign config_in_tready = state == 0;

endmodule