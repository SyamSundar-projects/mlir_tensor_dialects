/*
Controller
Field Name	               Bitwidth	To bit position	  From bit position
---------------------------------------------------------------------------
operator	                 5	           4	              0
sub fields in operator	     5	           9	              5
source dimensions	        40	           49	              10
destination dimensions	    40	           89	              50
source address	            11	           100	              90
destination address	        11	           111	              101
input element size	         3	           114	              112
output element size	         3	           117	              115


BitCasting Operator
Field Name	              Bitwidths	To bit position	 From bit position
sub fields in operator	     5	            4	            0
source dimensions	        40	            44	            5
destination dimensions	    40	            84	            45
source address	            11	            95	            85
destination address	        11	            106	            96
input element size	         3	            109	            107
output element size	         3	            112	            110
*/
module controller(
    input clock,
    input reset_n,
    input [117:0] config_in_tdata,
    input config_in_tvalid,
    output reg config_in_tready,
    output reg [112:0] bitcast_out_tdata,
    output reg bitcast_out_tvalid,
    input bicast_out_tredy
);

typedef struct packed {
    reg [4:0]   operator;
    reg [4:0]   sub_field_op;
    reg [39:0]  src_dim;
    reg [39:0]  dstn_dim;
    reg [10:0]  src_addr;
    reg [10:0]  dstn_addr;
    reg [2:0]   in_size;
    reg [2:0]   out_size;
} config_struct;

config_struct rd_config;

reg state,next_state;

// Register Config
always @(posedge clock) begin
    if (~reset_n) begin
        rd_config <= 0;
    end
    else if (config_in_tready && config_in_tvalid) begin
        rd_config <= config_in_tdata ;
    end
end

always @(posedge clock) begin
    if (!reset_n) state <= 0;
    else state <= next_state;
end

always_comb begin
    case (state)
        0:  if(config_in_tvalid) next_state = 1;
                    else next_state = 0;
        1:  if (bicast_out_tredy & (rd_config.operator==0))   next_state = 0;
                    else next_state = 1;
        default: next_state = 0;
    endcase
end

always @(posedge clock) begin
    if (state == 1) begin
        case (rd_config.operator)
            0: if (bicast_out_tredy) begin
                    bitcast_out_tdata  <= {rd_config.sub_field_op,rd_config.src_dim,rd_config.dstn_dim,
                                           rd_config.src_addr,rd_config.dstn_addr,rd_config.in_size,rd_config.out_size};
                    bitcast_out_tvalid <= 1;
                end
            default: begin
                bitcast_out_tdata  <= 0;
                bitcast_out_tvalid <= 0;
            end
        endcase
    end
end

assign config_in_tready = state == 0;

endmodule

