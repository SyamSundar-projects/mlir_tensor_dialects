module tensor_interface(
    input clock,
    input reset_n,
    input [53:0] config_in_tdata,
    input config_in_tvalid,
    output config_in_tready,
    output reg [15:0] mem_addr,
    output reg mem_valid
);

reg state,next_state;

reg [10:0] base_addr;
reg [15:0] no_of_rd;
reg [15:0] rd_addr_count;

// #words to read count
always @(posedge clock) begin
    if (!reset_n) no_of_rd <= 0;
    else if (config_in_tvalid && config_in_tready) begin
        base_addr <= config_in_tdata[53:43];
        case (config_in_tdata[42:40])
            0: no_of_rd <= 0;
            1: no_of_rd <= config_in_tdata[39:0] >> 2;
            2: no_of_rd <= config_in_tdata[39:0] >> 1;
            3: no_of_rd <= config_in_tdata[39:0];
            4: no_of_rd <= config_in_tdata[39:0];
            5: no_of_rd <= (config_in_tdata[39:0]*5)>>2 + 1;
            6: no_of_rd <= (config_in_tdata[39:0]*6)>>2 + 1;
            7: no_of_rd <= (config_in_tdata[39:0]*7)>>2 + 1;
            default: no_of_rd <= config_in_tdata[39:0];
        endcase
    end
end

//Present State
always @(posedge clock) begin
    if (!reset_n) state <= 0;
    else state <= next_state;
end

//Next State FSM
always @(*) begin
    case (state)
        0: if (config_in_tvalid) next_state = 1;
           else next_state = 0;
        1: if (rd_addr_count == no_of_rd-1) next_state = 0;
           else next_state = 1;
        default: next_state = 0;
    endcase
end

// OUTPUTS & Counter
always @(posedge clock) begin
    if (state == 1) begin
        mem_addr <= base_addr + 1;
        mem_valid <= 1;
        rd_addr_count <= rd_addr_count + 1;
    end
    else begin
        mem_addr <= 0;
        mem_valid <= 0;
        rd_addr_count <= 0;
    end
end

// CONFIG TREADY
assign config_in_tready = (state == 0) ? 1 : 0;

endmodule