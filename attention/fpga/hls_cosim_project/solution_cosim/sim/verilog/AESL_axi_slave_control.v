// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.1 (64-bit)
// Tool Version Limit: 2022.04
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps

module AESL_axi_slave_control (
    clk,
    reset,
    TRAN_s_axi_control_AWADDR,
    TRAN_s_axi_control_AWVALID,
    TRAN_s_axi_control_AWREADY,
    TRAN_s_axi_control_WVALID,
    TRAN_s_axi_control_WREADY,
    TRAN_s_axi_control_WDATA,
    TRAN_s_axi_control_WSTRB,
    TRAN_s_axi_control_ARADDR,
    TRAN_s_axi_control_ARVALID,
    TRAN_s_axi_control_ARREADY,
    TRAN_s_axi_control_RVALID,
    TRAN_s_axi_control_RREADY,
    TRAN_s_axi_control_RDATA,
    TRAN_s_axi_control_RRESP,
    TRAN_s_axi_control_BVALID,
    TRAN_s_axi_control_BREADY,
    TRAN_s_axi_control_BRESP,
    TRAN_control_write_data_finish,
    TRAN_control_start_in,
    TRAN_control_idle_out,
    TRAN_control_ready_out,
    TRAN_control_ready_in,
    TRAN_control_done_out,
    TRAN_control_write_start_in   ,
    TRAN_control_write_start_finish,
    TRAN_control_interrupt,
    TRAN_control_transaction_done_in
    );

//------------------------Parameter----------------------
`define TV_IN_Q_in "../tv/cdatafile/c.attention_int8_kernel.autotvin_Q_in.dat"
`define TV_IN_K_in "../tv/cdatafile/c.attention_int8_kernel.autotvin_K_in.dat"
`define TV_IN_V_in "../tv/cdatafile/c.attention_int8_kernel.autotvin_V_in.dat"
`define TV_IN_O_out "../tv/cdatafile/c.attention_int8_kernel.autotvin_O_out.dat"
`define TV_IN_q_scale "../tv/cdatafile/c.attention_int8_kernel.autotvin_q_scale.dat"
`define TV_IN_v_scale "../tv/cdatafile/c.attention_int8_kernel.autotvin_v_scale.dat"
parameter ADDR_WIDTH = 7;
parameter DATA_WIDTH = 32;
parameter Q_in_DEPTH = 1;
reg [31 : 0] Q_in_OPERATE_DEPTH = 0;
parameter Q_in_c_bitwidth = 64;
parameter K_in_DEPTH = 1;
reg [31 : 0] K_in_OPERATE_DEPTH = 0;
parameter K_in_c_bitwidth = 64;
parameter V_in_DEPTH = 1;
reg [31 : 0] V_in_OPERATE_DEPTH = 0;
parameter V_in_c_bitwidth = 64;
parameter O_out_DEPTH = 1;
reg [31 : 0] O_out_OPERATE_DEPTH = 0;
parameter O_out_c_bitwidth = 64;
parameter q_scale_DEPTH = 1;
reg [31 : 0] q_scale_OPERATE_DEPTH = 0;
parameter q_scale_c_bitwidth = 32;
parameter v_scale_DEPTH = 1;
reg [31 : 0] v_scale_OPERATE_DEPTH = 0;
parameter v_scale_c_bitwidth = 32;
parameter START_ADDR = 0;
parameter attention_int8_kernel_continue_addr = 0;
parameter attention_int8_kernel_auto_start_addr = 0;
parameter Q_in_data_in_addr = 16;
parameter K_in_data_in_addr = 28;
parameter V_in_data_in_addr = 40;
parameter O_out_data_in_addr = 52;
parameter q_scale_data_in_addr = 64;
parameter v_scale_data_in_addr = 72;
parameter STATUS_ADDR = 0;

output [ADDR_WIDTH - 1 : 0] TRAN_s_axi_control_AWADDR;
output  TRAN_s_axi_control_AWVALID;
input  TRAN_s_axi_control_AWREADY;
output  TRAN_s_axi_control_WVALID;
input  TRAN_s_axi_control_WREADY;
output [DATA_WIDTH - 1 : 0] TRAN_s_axi_control_WDATA;
output [DATA_WIDTH/8 - 1 : 0] TRAN_s_axi_control_WSTRB;
output [ADDR_WIDTH - 1 : 0] TRAN_s_axi_control_ARADDR;
output  TRAN_s_axi_control_ARVALID;
input  TRAN_s_axi_control_ARREADY;
input  TRAN_s_axi_control_RVALID;
output  TRAN_s_axi_control_RREADY;
input [DATA_WIDTH - 1 : 0] TRAN_s_axi_control_RDATA;
input [2 - 1 : 0] TRAN_s_axi_control_RRESP;
input  TRAN_s_axi_control_BVALID;
output  TRAN_s_axi_control_BREADY;
input [2 - 1 : 0] TRAN_s_axi_control_BRESP;
output TRAN_control_write_data_finish;
input     clk;
input     reset;
input     TRAN_control_start_in;
output    TRAN_control_done_out;
output    TRAN_control_ready_out;
input     TRAN_control_ready_in;
output    TRAN_control_idle_out;
input  TRAN_control_write_start_in   ;
output TRAN_control_write_start_finish;
input     TRAN_control_interrupt;
input     TRAN_control_transaction_done_in;

reg [ADDR_WIDTH - 1 : 0] AWADDR_reg = 0;
reg  AWVALID_reg = 0;
reg  WVALID_reg = 0;
reg [DATA_WIDTH - 1 : 0] WDATA_reg = 0;
reg [DATA_WIDTH/8 - 1 : 0] WSTRB_reg = 0;
reg [ADDR_WIDTH - 1 : 0] ARADDR_reg = 0;
reg  ARVALID_reg = 0;
reg  RREADY_reg = 0;
reg [DATA_WIDTH - 1 : 0] RDATA_reg = 0;
reg  BREADY_reg = 0;
reg [Q_in_c_bitwidth - 1 : 0] mem_Q_in [Q_in_DEPTH - 1 : 0] = '{default : 'h0};
reg [DATA_WIDTH-1 : 0] image_mem_Q_in [ (Q_in_c_bitwidth+DATA_WIDTH-1)/DATA_WIDTH * Q_in_DEPTH -1 : 0] = '{default : 'hz};
reg Q_in_write_data_finish;
reg [K_in_c_bitwidth - 1 : 0] mem_K_in [K_in_DEPTH - 1 : 0] = '{default : 'h0};
reg [DATA_WIDTH-1 : 0] image_mem_K_in [ (K_in_c_bitwidth+DATA_WIDTH-1)/DATA_WIDTH * K_in_DEPTH -1 : 0] = '{default : 'hz};
reg K_in_write_data_finish;
reg [V_in_c_bitwidth - 1 : 0] mem_V_in [V_in_DEPTH - 1 : 0] = '{default : 'h0};
reg [DATA_WIDTH-1 : 0] image_mem_V_in [ (V_in_c_bitwidth+DATA_WIDTH-1)/DATA_WIDTH * V_in_DEPTH -1 : 0] = '{default : 'hz};
reg V_in_write_data_finish;
reg [O_out_c_bitwidth - 1 : 0] mem_O_out [O_out_DEPTH - 1 : 0] = '{default : 'h0};
reg [DATA_WIDTH-1 : 0] image_mem_O_out [ (O_out_c_bitwidth+DATA_WIDTH-1)/DATA_WIDTH * O_out_DEPTH -1 : 0] = '{default : 'hz};
reg O_out_write_data_finish;
reg [DATA_WIDTH - 1 : 0] mem_q_scale [q_scale_DEPTH - 1 : 0] = '{default : 'h0};
reg [DATA_WIDTH-1 : 0] image_mem_q_scale [ (q_scale_c_bitwidth+DATA_WIDTH-1)/DATA_WIDTH * q_scale_DEPTH -1 : 0] = '{default : 'hz};
reg q_scale_write_data_finish;
reg [DATA_WIDTH - 1 : 0] mem_v_scale [v_scale_DEPTH - 1 : 0] = '{default : 'h0};
reg [DATA_WIDTH-1 : 0] image_mem_v_scale [ (v_scale_c_bitwidth+DATA_WIDTH-1)/DATA_WIDTH * v_scale_DEPTH -1 : 0] = '{default : 'hz};
reg v_scale_write_data_finish;
reg AESL_ready_out_index_reg = 0;
reg AESL_write_start_finish = 0;
reg AESL_ready_reg;
reg ready_initial;
reg AESL_done_index_reg = 0;
reg AESL_idle_index_reg = 0;
reg AESL_auto_restart_index_reg;
reg process_0_finish = 0;
reg process_1_finish = 0;
reg process_2_finish = 0;
reg process_3_finish = 0;
reg process_4_finish = 0;
reg process_5_finish = 0;
reg process_6_finish = 0;
reg process_7_finish = 0;
//write Q_in reg
reg [31 : 0] write_Q_in_count = 0;
reg write_Q_in_run_flag = 0;
reg write_one_Q_in_data_done = 0;
//write K_in reg
reg [31 : 0] write_K_in_count = 0;
reg write_K_in_run_flag = 0;
reg write_one_K_in_data_done = 0;
//write V_in reg
reg [31 : 0] write_V_in_count = 0;
reg write_V_in_run_flag = 0;
reg write_one_V_in_data_done = 0;
//write O_out reg
reg [31 : 0] write_O_out_count = 0;
reg write_O_out_run_flag = 0;
reg write_one_O_out_data_done = 0;
//write q_scale reg
reg [31 : 0] write_q_scale_count = 0;
reg write_q_scale_run_flag = 0;
reg write_one_q_scale_data_done = 0;
//write v_scale reg
reg [31 : 0] write_v_scale_count = 0;
reg write_v_scale_run_flag = 0;
reg write_one_v_scale_data_done = 0;
reg [31 : 0] write_start_count = 0;
reg write_start_run_flag = 0;

//===================process control=================
reg [31 : 0] ongoing_process_number = 0;
//process number depends on how much processes needed.
reg process_busy = 0;

//=================== signal connection ==============
assign TRAN_s_axi_control_AWADDR = AWADDR_reg;
assign TRAN_s_axi_control_AWVALID = AWVALID_reg;
assign TRAN_s_axi_control_WVALID = WVALID_reg;
assign TRAN_s_axi_control_WDATA = WDATA_reg;
assign TRAN_s_axi_control_WSTRB = WSTRB_reg;
assign TRAN_s_axi_control_ARADDR = ARADDR_reg;
assign TRAN_s_axi_control_ARVALID = ARVALID_reg;
assign TRAN_s_axi_control_RREADY = RREADY_reg;
assign TRAN_s_axi_control_BREADY = BREADY_reg;
assign TRAN_control_write_start_finish = AESL_write_start_finish;
assign TRAN_control_done_out = AESL_done_index_reg;
assign TRAN_control_ready_out = AESL_ready_out_index_reg;
assign TRAN_control_idle_out = AESL_idle_index_reg;
assign TRAN_control_write_data_finish = 1 & Q_in_write_data_finish & K_in_write_data_finish & V_in_write_data_finish & O_out_write_data_finish & q_scale_write_data_finish & v_scale_write_data_finish;
always @(TRAN_control_ready_in or ready_initial) 
begin
    AESL_ready_reg <= TRAN_control_ready_in | ready_initial;
end

always @(reset or process_0_finish or process_1_finish or process_2_finish or process_3_finish or process_4_finish or process_5_finish or process_6_finish or process_7_finish ) begin
    if (reset == 0) begin
        ongoing_process_number <= 0;
    end
    else if (ongoing_process_number == 0 && process_0_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 1 && process_1_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 2 && process_2_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 3 && process_3_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 4 && process_4_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 5 && process_5_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 6 && process_6_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 7 && process_7_finish == 1) begin
            ongoing_process_number <= 0;
    end
end

task count_c_data_four_byte_num_by_bitwidth;
input  integer bitwidth;
output integer num;
integer factor;
integer i;
begin
    factor = 32;
    for (i = 1; i <= 1024; i = i + 1) begin
        if (bitwidth <= factor && bitwidth > factor - 32) begin
            num = i;
        end
        factor = factor + 32;
    end
end    
endtask

task count_seperate_factor_by_bitwidth;
input  integer bitwidth;
output integer factor;
begin
    if (bitwidth <= 8) begin
        factor=4;
    end
    if (bitwidth <= 16 & bitwidth > 8 ) begin
        factor=2;
    end
    if (bitwidth <= 32 & bitwidth > 16 ) begin
        factor=1;
    end
    if (bitwidth > 32 ) begin
        factor=1;
    end
end    
endtask

task count_operate_depth_by_bitwidth_and_depth;
input  integer bitwidth;
input  integer depth;
output integer operate_depth;
integer factor;
integer remain;
begin
    count_seperate_factor_by_bitwidth (bitwidth , factor);
    operate_depth = depth / factor;
    remain = depth % factor;
    if (remain > 0) begin
        operate_depth = operate_depth + 1;
    end
end    
endtask

task write; /*{{{*/
    input  reg [ADDR_WIDTH - 1:0] waddr;   // write address
    input  reg [DATA_WIDTH - 1:0] wdata;   // write data
    output reg wresp;
    reg aw_flag;
    reg w_flag;
    reg [DATA_WIDTH/8 - 1:0] wstrb_reg;
    integer i;
begin 
    wresp = 0;
    aw_flag = 0;
    w_flag = 0;
//=======================one single write operate======================
    AWADDR_reg <= waddr;
    AWVALID_reg <= 1;
    WDATA_reg <= wdata;
    WVALID_reg <= 1;
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
        wstrb_reg [i] = 1;
    end    
    WSTRB_reg <= wstrb_reg;
    while (!(aw_flag && w_flag)) begin
        @(posedge clk);
        if (aw_flag != 1)
            aw_flag = TRAN_s_axi_control_AWREADY & AWVALID_reg;
        if (w_flag != 1)
            w_flag = TRAN_s_axi_control_WREADY & WVALID_reg;
        AWVALID_reg <= !aw_flag;
        WVALID_reg <= !w_flag;
    end

    BREADY_reg <= 1;
    while (TRAN_s_axi_control_BVALID != 1) begin
        //wait for response 
        @(posedge clk);
    end
    @(posedge clk);
    BREADY_reg <= 0;
    if (TRAN_s_axi_control_BRESP === 2'b00) begin
        wresp = 1;
        //input success. in fact BRESP is always 2'b00
    end   
//=======================one single write operate======================

end
endtask/*}}}*/

task read (/*{{{*/
    input  [ADDR_WIDTH - 1:0] raddr ,   // write address
    output [DATA_WIDTH - 1:0] RDATA_result ,
    output rresp
);
begin 
    rresp = 0;
//=======================one single read operate======================
    ARADDR_reg <= raddr;
    ARVALID_reg <= 1;
    while (TRAN_s_axi_control_ARREADY !== 1) begin
        @(posedge clk);
    end
    @(posedge clk);
    ARVALID_reg <= 0;
    RREADY_reg <= 1;
    while (TRAN_s_axi_control_RVALID !== 1) begin
        //wait for response 
        @(posedge clk);
    end
    @(posedge clk);
    RDATA_result  <= TRAN_s_axi_control_RDATA;
    RREADY_reg <= 0;
    if (TRAN_s_axi_control_RRESP === 2'b00 ) begin
        rresp <= 1;
        //output success. in fact RRESP is always 2'b00
    end  
    @(posedge clk);

//=======================one single read operate end======================

end
endtask/*}}}*/

initial begin : ready_initial_process
    ready_initial = 0;
    wait(reset === 1);
    @(posedge clk);
    ready_initial = 1;
    @(posedge clk);
    ready_initial = 0;
end

initial begin : update_status
    integer process_num ;
    integer read_status_resp;
    wait(reset === 1);
    @(posedge clk);
    process_num = 0;
    while (1) begin
        process_0_finish = 0;
        AESL_done_index_reg         <= 0;
        AESL_ready_out_index_reg        <= 0;
        if (ongoing_process_number === process_num && process_busy === 0) begin
            process_busy = 1;
            read (STATUS_ADDR, RDATA_reg, read_status_resp);
                AESL_done_index_reg         <= RDATA_reg[1 : 1];
                AESL_ready_out_index_reg    <= RDATA_reg[1 : 1];
                AESL_idle_index_reg         <= RDATA_reg[2 : 2];
            process_0_finish = 1;
            process_busy = 0;
        end 
        @(posedge clk);
    end
end

always @(reset or posedge clk) begin
    if (reset == 0) begin
        Q_in_write_data_finish <= 0;
        write_Q_in_run_flag <= 0; 
        write_Q_in_count = 0;
        count_operate_depth_by_bitwidth_and_depth (Q_in_c_bitwidth, Q_in_DEPTH, Q_in_OPERATE_DEPTH);
    end
    else begin
        if (TRAN_control_start_in === 1) begin
            Q_in_write_data_finish <= 0;
        end
        if (AESL_ready_reg === 1) begin
            write_Q_in_run_flag <= 1; 
            write_Q_in_count = 0;
        end
        if (write_one_Q_in_data_done === 1) begin
            write_Q_in_count = write_Q_in_count + 1;
            if (write_Q_in_count == Q_in_OPERATE_DEPTH) begin
                write_Q_in_run_flag <= 0; 
                Q_in_write_data_finish <= 1;
            end
        end
    end
end

initial begin : write_Q_in
    integer write_Q_in_resp;
    integer process_num ;
    integer get_ack;
    integer four_byte_num;
    integer c_bitwidth;
    integer i;
    integer j;
    reg [31 : 0] Q_in_data_tmp_reg;
    wait(reset === 1);
    @(posedge clk);
    c_bitwidth = Q_in_c_bitwidth;
    process_num = 1;
    count_c_data_four_byte_num_by_bitwidth (c_bitwidth , four_byte_num) ;
    while (1) begin
        process_1_finish <= 0;

        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            get_ack = 1;
            if (write_Q_in_run_flag === 1 && get_ack === 1) begin
                process_busy = 1;
                //write Q_in data 
                for (i = 0 ; i < four_byte_num ; i = i+1) begin
                    if (Q_in_c_bitwidth < 32) begin
                        Q_in_data_tmp_reg = mem_Q_in[write_Q_in_count];
                    end
                    else begin
                        for (j=0 ; j<32 ; j = j + 1) begin
                            if (i*32 + j < Q_in_c_bitwidth) begin
                                Q_in_data_tmp_reg[j] = mem_Q_in[write_Q_in_count][i*32 + j];
                            end
                            else begin
                                Q_in_data_tmp_reg[j] = 0;
                            end
                        end
                    end
                    if(image_mem_Q_in[write_Q_in_count * four_byte_num  + i]!==Q_in_data_tmp_reg) begin
                    write (Q_in_data_in_addr + write_Q_in_count * four_byte_num * 4 + i * 4, Q_in_data_tmp_reg, write_Q_in_resp);
                    image_mem_Q_in[write_Q_in_count * four_byte_num + i]=Q_in_data_tmp_reg;
                    end
                end
                process_busy = 0;
                write_one_Q_in_data_done <= 1;
                @(posedge clk);
                write_one_Q_in_data_done <= 0;
            end   
            process_1_finish <= 1;
        end
        @(posedge clk);
    end    
end
always @(reset or posedge clk) begin
    if (reset == 0) begin
        K_in_write_data_finish <= 0;
        write_K_in_run_flag <= 0; 
        write_K_in_count = 0;
        count_operate_depth_by_bitwidth_and_depth (K_in_c_bitwidth, K_in_DEPTH, K_in_OPERATE_DEPTH);
    end
    else begin
        if (TRAN_control_start_in === 1) begin
            K_in_write_data_finish <= 0;
        end
        if (AESL_ready_reg === 1) begin
            write_K_in_run_flag <= 1; 
            write_K_in_count = 0;
        end
        if (write_one_K_in_data_done === 1) begin
            write_K_in_count = write_K_in_count + 1;
            if (write_K_in_count == K_in_OPERATE_DEPTH) begin
                write_K_in_run_flag <= 0; 
                K_in_write_data_finish <= 1;
            end
        end
    end
end

initial begin : write_K_in
    integer write_K_in_resp;
    integer process_num ;
    integer get_ack;
    integer four_byte_num;
    integer c_bitwidth;
    integer i;
    integer j;
    reg [31 : 0] K_in_data_tmp_reg;
    wait(reset === 1);
    @(posedge clk);
    c_bitwidth = K_in_c_bitwidth;
    process_num = 2;
    count_c_data_four_byte_num_by_bitwidth (c_bitwidth , four_byte_num) ;
    while (1) begin
        process_2_finish <= 0;

        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            get_ack = 1;
            if (write_K_in_run_flag === 1 && get_ack === 1) begin
                process_busy = 1;
                //write K_in data 
                for (i = 0 ; i < four_byte_num ; i = i+1) begin
                    if (K_in_c_bitwidth < 32) begin
                        K_in_data_tmp_reg = mem_K_in[write_K_in_count];
                    end
                    else begin
                        for (j=0 ; j<32 ; j = j + 1) begin
                            if (i*32 + j < K_in_c_bitwidth) begin
                                K_in_data_tmp_reg[j] = mem_K_in[write_K_in_count][i*32 + j];
                            end
                            else begin
                                K_in_data_tmp_reg[j] = 0;
                            end
                        end
                    end
                    if(image_mem_K_in[write_K_in_count * four_byte_num  + i]!==K_in_data_tmp_reg) begin
                    write (K_in_data_in_addr + write_K_in_count * four_byte_num * 4 + i * 4, K_in_data_tmp_reg, write_K_in_resp);
                    image_mem_K_in[write_K_in_count * four_byte_num + i]=K_in_data_tmp_reg;
                    end
                end
                process_busy = 0;
                write_one_K_in_data_done <= 1;
                @(posedge clk);
                write_one_K_in_data_done <= 0;
            end   
            process_2_finish <= 1;
        end
        @(posedge clk);
    end    
end
always @(reset or posedge clk) begin
    if (reset == 0) begin
        V_in_write_data_finish <= 0;
        write_V_in_run_flag <= 0; 
        write_V_in_count = 0;
        count_operate_depth_by_bitwidth_and_depth (V_in_c_bitwidth, V_in_DEPTH, V_in_OPERATE_DEPTH);
    end
    else begin
        if (TRAN_control_start_in === 1) begin
            V_in_write_data_finish <= 0;
        end
        if (AESL_ready_reg === 1) begin
            write_V_in_run_flag <= 1; 
            write_V_in_count = 0;
        end
        if (write_one_V_in_data_done === 1) begin
            write_V_in_count = write_V_in_count + 1;
            if (write_V_in_count == V_in_OPERATE_DEPTH) begin
                write_V_in_run_flag <= 0; 
                V_in_write_data_finish <= 1;
            end
        end
    end
end

initial begin : write_V_in
    integer write_V_in_resp;
    integer process_num ;
    integer get_ack;
    integer four_byte_num;
    integer c_bitwidth;
    integer i;
    integer j;
    reg [31 : 0] V_in_data_tmp_reg;
    wait(reset === 1);
    @(posedge clk);
    c_bitwidth = V_in_c_bitwidth;
    process_num = 3;
    count_c_data_four_byte_num_by_bitwidth (c_bitwidth , four_byte_num) ;
    while (1) begin
        process_3_finish <= 0;

        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            get_ack = 1;
            if (write_V_in_run_flag === 1 && get_ack === 1) begin
                process_busy = 1;
                //write V_in data 
                for (i = 0 ; i < four_byte_num ; i = i+1) begin
                    if (V_in_c_bitwidth < 32) begin
                        V_in_data_tmp_reg = mem_V_in[write_V_in_count];
                    end
                    else begin
                        for (j=0 ; j<32 ; j = j + 1) begin
                            if (i*32 + j < V_in_c_bitwidth) begin
                                V_in_data_tmp_reg[j] = mem_V_in[write_V_in_count][i*32 + j];
                            end
                            else begin
                                V_in_data_tmp_reg[j] = 0;
                            end
                        end
                    end
                    if(image_mem_V_in[write_V_in_count * four_byte_num  + i]!==V_in_data_tmp_reg) begin
                    write (V_in_data_in_addr + write_V_in_count * four_byte_num * 4 + i * 4, V_in_data_tmp_reg, write_V_in_resp);
                    image_mem_V_in[write_V_in_count * four_byte_num + i]=V_in_data_tmp_reg;
                    end
                end
                process_busy = 0;
                write_one_V_in_data_done <= 1;
                @(posedge clk);
                write_one_V_in_data_done <= 0;
            end   
            process_3_finish <= 1;
        end
        @(posedge clk);
    end    
end
always @(reset or posedge clk) begin
    if (reset == 0) begin
        O_out_write_data_finish <= 0;
        write_O_out_run_flag <= 0; 
        write_O_out_count = 0;
        count_operate_depth_by_bitwidth_and_depth (O_out_c_bitwidth, O_out_DEPTH, O_out_OPERATE_DEPTH);
    end
    else begin
        if (TRAN_control_start_in === 1) begin
            O_out_write_data_finish <= 0;
        end
        if (AESL_ready_reg === 1) begin
            write_O_out_run_flag <= 1; 
            write_O_out_count = 0;
        end
        if (write_one_O_out_data_done === 1) begin
            write_O_out_count = write_O_out_count + 1;
            if (write_O_out_count == O_out_OPERATE_DEPTH) begin
                write_O_out_run_flag <= 0; 
                O_out_write_data_finish <= 1;
            end
        end
    end
end

initial begin : write_O_out
    integer write_O_out_resp;
    integer process_num ;
    integer get_ack;
    integer four_byte_num;
    integer c_bitwidth;
    integer i;
    integer j;
    reg [31 : 0] O_out_data_tmp_reg;
    wait(reset === 1);
    @(posedge clk);
    c_bitwidth = O_out_c_bitwidth;
    process_num = 4;
    count_c_data_four_byte_num_by_bitwidth (c_bitwidth , four_byte_num) ;
    while (1) begin
        process_4_finish <= 0;

        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            get_ack = 1;
            if (write_O_out_run_flag === 1 && get_ack === 1) begin
                process_busy = 1;
                //write O_out data 
                for (i = 0 ; i < four_byte_num ; i = i+1) begin
                    if (O_out_c_bitwidth < 32) begin
                        O_out_data_tmp_reg = mem_O_out[write_O_out_count];
                    end
                    else begin
                        for (j=0 ; j<32 ; j = j + 1) begin
                            if (i*32 + j < O_out_c_bitwidth) begin
                                O_out_data_tmp_reg[j] = mem_O_out[write_O_out_count][i*32 + j];
                            end
                            else begin
                                O_out_data_tmp_reg[j] = 0;
                            end
                        end
                    end
                    if(image_mem_O_out[write_O_out_count * four_byte_num  + i]!==O_out_data_tmp_reg) begin
                    write (O_out_data_in_addr + write_O_out_count * four_byte_num * 4 + i * 4, O_out_data_tmp_reg, write_O_out_resp);
                    image_mem_O_out[write_O_out_count * four_byte_num + i]=O_out_data_tmp_reg;
                    end
                end
                process_busy = 0;
                write_one_O_out_data_done <= 1;
                @(posedge clk);
                write_one_O_out_data_done <= 0;
            end   
            process_4_finish <= 1;
        end
        @(posedge clk);
    end    
end
always @(reset or posedge clk) begin
    if (reset == 0) begin
        q_scale_write_data_finish <= 0;
        write_q_scale_run_flag <= 0; 
        write_q_scale_count = 0;
        count_operate_depth_by_bitwidth_and_depth (q_scale_c_bitwidth, q_scale_DEPTH, q_scale_OPERATE_DEPTH);
    end
    else begin
        if (TRAN_control_start_in === 1) begin
            q_scale_write_data_finish <= 0;
        end
        if (AESL_ready_reg === 1) begin
            write_q_scale_run_flag <= 1; 
            write_q_scale_count = 0;
        end
        if (write_one_q_scale_data_done === 1) begin
            write_q_scale_count = write_q_scale_count + 1;
            if (write_q_scale_count == q_scale_OPERATE_DEPTH) begin
                write_q_scale_run_flag <= 0; 
                q_scale_write_data_finish <= 1;
            end
        end
    end
end

initial begin : write_q_scale
    integer write_q_scale_resp;
    integer process_num ;
    integer get_ack;
    integer four_byte_num;
    integer c_bitwidth;
    integer i;
    integer j;
    reg [31 : 0] q_scale_data_tmp_reg;
    wait(reset === 1);
    @(posedge clk);
    c_bitwidth = q_scale_c_bitwidth;
    process_num = 5;
    count_c_data_four_byte_num_by_bitwidth (c_bitwidth , four_byte_num) ;
    while (1) begin
        process_5_finish <= 0;

        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            get_ack = 1;
            if (write_q_scale_run_flag === 1 && get_ack === 1) begin
                process_busy = 1;
                //write q_scale data 
                for (i = 0 ; i < four_byte_num ; i = i+1) begin
                    if (q_scale_c_bitwidth < 32) begin
                        q_scale_data_tmp_reg = mem_q_scale[write_q_scale_count];
                    end
                    else begin
                        for (j=0 ; j<32 ; j = j + 1) begin
                            if (i*32 + j < q_scale_c_bitwidth) begin
                                q_scale_data_tmp_reg[j] = mem_q_scale[write_q_scale_count][i*32 + j];
                            end
                            else begin
                                q_scale_data_tmp_reg[j] = 0;
                            end
                        end
                    end
                    if(image_mem_q_scale[write_q_scale_count * four_byte_num  + i]!==q_scale_data_tmp_reg) begin
                    write (q_scale_data_in_addr + write_q_scale_count * four_byte_num * 4 + i * 4, q_scale_data_tmp_reg, write_q_scale_resp);
                    image_mem_q_scale[write_q_scale_count * four_byte_num + i]=q_scale_data_tmp_reg;
                    end
                end
                process_busy = 0;
                write_one_q_scale_data_done <= 1;
                @(posedge clk);
                write_one_q_scale_data_done <= 0;
            end   
            process_5_finish <= 1;
        end
        @(posedge clk);
    end    
end
always @(reset or posedge clk) begin
    if (reset == 0) begin
        v_scale_write_data_finish <= 0;
        write_v_scale_run_flag <= 0; 
        write_v_scale_count = 0;
        count_operate_depth_by_bitwidth_and_depth (v_scale_c_bitwidth, v_scale_DEPTH, v_scale_OPERATE_DEPTH);
    end
    else begin
        if (TRAN_control_start_in === 1) begin
            v_scale_write_data_finish <= 0;
        end
        if (AESL_ready_reg === 1) begin
            write_v_scale_run_flag <= 1; 
            write_v_scale_count = 0;
        end
        if (write_one_v_scale_data_done === 1) begin
            write_v_scale_count = write_v_scale_count + 1;
            if (write_v_scale_count == v_scale_OPERATE_DEPTH) begin
                write_v_scale_run_flag <= 0; 
                v_scale_write_data_finish <= 1;
            end
        end
    end
end

initial begin : write_v_scale
    integer write_v_scale_resp;
    integer process_num ;
    integer get_ack;
    integer four_byte_num;
    integer c_bitwidth;
    integer i;
    integer j;
    reg [31 : 0] v_scale_data_tmp_reg;
    wait(reset === 1);
    @(posedge clk);
    c_bitwidth = v_scale_c_bitwidth;
    process_num = 6;
    count_c_data_four_byte_num_by_bitwidth (c_bitwidth , four_byte_num) ;
    while (1) begin
        process_6_finish <= 0;

        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            get_ack = 1;
            if (write_v_scale_run_flag === 1 && get_ack === 1) begin
                process_busy = 1;
                //write v_scale data 
                for (i = 0 ; i < four_byte_num ; i = i+1) begin
                    if (v_scale_c_bitwidth < 32) begin
                        v_scale_data_tmp_reg = mem_v_scale[write_v_scale_count];
                    end
                    else begin
                        for (j=0 ; j<32 ; j = j + 1) begin
                            if (i*32 + j < v_scale_c_bitwidth) begin
                                v_scale_data_tmp_reg[j] = mem_v_scale[write_v_scale_count][i*32 + j];
                            end
                            else begin
                                v_scale_data_tmp_reg[j] = 0;
                            end
                        end
                    end
                    if(image_mem_v_scale[write_v_scale_count * four_byte_num  + i]!==v_scale_data_tmp_reg) begin
                    write (v_scale_data_in_addr + write_v_scale_count * four_byte_num * 4 + i * 4, v_scale_data_tmp_reg, write_v_scale_resp);
                    image_mem_v_scale[write_v_scale_count * four_byte_num + i]=v_scale_data_tmp_reg;
                    end
                end
                process_busy = 0;
                write_one_v_scale_data_done <= 1;
                @(posedge clk);
                write_one_v_scale_data_done <= 0;
            end   
            process_6_finish <= 1;
        end
        @(posedge clk);
    end    
end

always @(reset or posedge clk) begin
    if (reset == 0) begin
        write_start_run_flag <= 0; 
        write_start_count <= 0;
    end
    else begin
        if (write_start_count >= 1) begin
            write_start_run_flag <= 0; 
        end
        else if (TRAN_control_write_start_in === 1) begin
            write_start_run_flag <= 1; 
        end
        if (AESL_write_start_finish === 1) begin
            write_start_count <= write_start_count + 1;
            write_start_run_flag <= 0; 
        end
    end
end

initial begin : write_start
    reg [DATA_WIDTH - 1 : 0] write_start_tmp;
    integer process_num;
    integer write_start_resp;
    wait(reset === 1);
    @(posedge clk);
    process_num = 7;
    while (1) begin
        process_7_finish = 0;
        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            if (write_start_run_flag === 1) begin
                process_busy = 1;
                write_start_tmp=0;
                write_start_tmp[0 : 0] = 1;
                write (START_ADDR, write_start_tmp, write_start_resp);
                process_busy = 0;
                AESL_write_start_finish <= 1;
                @(posedge clk);
                AESL_write_start_finish <= 0;
            end
            process_7_finish <= 1;
        end 
        @(posedge clk);
    end
end

//------------------------Task and function-------------- 
task read_token; 
    input integer fp; 
    output reg [151 : 0] token;
    integer ret;
    begin
        token = "";
        ret = 0;
        ret = $fscanf(fp,"%s",token);
    end 
endtask 
 
//------------------------Read file------------------------ 
 
// Read data from file 
initial begin : read_Q_in_file_process 
  integer fp; 
  integer ret; 
  integer factor; 
  reg [151 : 0] token; 
  reg [151 : 0] token_tmp; 
  //reg [Q_in_c_bitwidth - 1 : 0] token_tmp; 
  reg [DATA_WIDTH - 1 : 0] tmp_cache_mem; 
  reg [ 8*5 : 1] str;
    reg [63:0] trans_depth;
  integer transaction_idx; 
  integer i; 
  transaction_idx = 0; 
  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
  count_seperate_factor_by_bitwidth (Q_in_c_bitwidth , factor);
  fp = $fopen(`TV_IN_Q_in ,"r"); 
  if(fp == 0) begin                               // Failed to open file 
      $display("Failed to open file \"%s\"!", `TV_IN_Q_in); 
      $finish; 
  end 
  read_token(fp, token); 
  if (token != "[[[runtime]]]") begin             // Illegal format 
      $display("ERROR: Simulation using HLS TB failed.");
      $finish; 
  end 
  read_token(fp, token); 
  while (token != "[[[/runtime]]]") begin 
      if (token != "[[transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token);                        // skip transaction number 
      @(posedge clk);
      # 0.2;
      while(AESL_ready_reg !== 1) begin
          @(posedge clk); 
          # 0.2;
      end
      for(i = 0; i < Q_in_DEPTH; i = i + 1) begin 
          read_token(fp, token); 
          ret = $sscanf(token, "0x%x", token_tmp); 
          if (factor == 4) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [7 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [15 : 8] = token_tmp;
              end
              if (i%factor == 2) begin
                  tmp_cache_mem [23 : 16] = token_tmp;
              end
              if (i%factor == 3) begin
                  tmp_cache_mem [31 : 24] = token_tmp;
                  mem_Q_in [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
              end
          end
          if (factor == 2) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [15 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [31 : 16] = token_tmp;
                  mem_Q_in [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1: 0] = 0;
              end
          end
          if (factor == 1) begin
              mem_Q_in [i] = token_tmp;
          end
      end 
      if (factor == 4) begin
          if (i%factor != 0) begin
              mem_Q_in [i/factor] = tmp_cache_mem;
          end
      end
      if (factor == 2) begin
          if (i%factor != 0) begin
              mem_Q_in [i/factor] = tmp_cache_mem;
          end
      end 
      read_token(fp, token); 
      if(token != "[[/transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token); 
      transaction_idx = transaction_idx + 1; 
  end 
  $fclose(fp); 
end 
 
task write_binary_Q_in;
    input integer fp;
    input reg[64-1:0] in;
    input integer in_bw;
    reg [63:0] tmp_long;
    reg[64-1:0] local_in;
    integer char_num;
    integer long_num;
    integer i;
    integer j;
    begin
        long_num = (in_bw + 63) / 64;
        char_num = ((in_bw - 1) % 64 + 7) / 8;
        for(i=long_num;i>0;i=i-1) begin
             local_in = in;
             tmp_long = local_in >> ((i-1)*64);
             for(j=0;j<64;j=j+1)
                 if (tmp_long[j] === 1'bx)
                     tmp_long[j] = 1'b0;
             if (i == long_num) begin
                 case(char_num)
                     1: $fwrite(fp,"%c",tmp_long[7:0]);
                     2: $fwrite(fp,"%c%c",tmp_long[15:8],tmp_long[7:0]);
                     3: $fwrite(fp,"%c%c%c",tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     4: $fwrite(fp,"%c%c%c%c",tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     5: $fwrite(fp,"%c%c%c%c%c",tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     6: $fwrite(fp,"%c%c%c%c%c%c",tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     7: $fwrite(fp,"%c%c%c%c%c%c%c",tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     8: $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     default: ;
                 endcase
             end
             else begin
                 $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
             end
        end
    end
endtask;
//------------------------Read file------------------------ 
 
// Read data from file 
initial begin : read_K_in_file_process 
  integer fp; 
  integer ret; 
  integer factor; 
  reg [151 : 0] token; 
  reg [151 : 0] token_tmp; 
  //reg [K_in_c_bitwidth - 1 : 0] token_tmp; 
  reg [DATA_WIDTH - 1 : 0] tmp_cache_mem; 
  reg [ 8*5 : 1] str;
    reg [63:0] trans_depth;
  integer transaction_idx; 
  integer i; 
  transaction_idx = 0; 
  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
  count_seperate_factor_by_bitwidth (K_in_c_bitwidth , factor);
  fp = $fopen(`TV_IN_K_in ,"r"); 
  if(fp == 0) begin                               // Failed to open file 
      $display("Failed to open file \"%s\"!", `TV_IN_K_in); 
      $finish; 
  end 
  read_token(fp, token); 
  if (token != "[[[runtime]]]") begin             // Illegal format 
      $display("ERROR: Simulation using HLS TB failed.");
      $finish; 
  end 
  read_token(fp, token); 
  while (token != "[[[/runtime]]]") begin 
      if (token != "[[transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token);                        // skip transaction number 
      @(posedge clk);
      # 0.2;
      while(AESL_ready_reg !== 1) begin
          @(posedge clk); 
          # 0.2;
      end
      for(i = 0; i < K_in_DEPTH; i = i + 1) begin 
          read_token(fp, token); 
          ret = $sscanf(token, "0x%x", token_tmp); 
          if (factor == 4) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [7 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [15 : 8] = token_tmp;
              end
              if (i%factor == 2) begin
                  tmp_cache_mem [23 : 16] = token_tmp;
              end
              if (i%factor == 3) begin
                  tmp_cache_mem [31 : 24] = token_tmp;
                  mem_K_in [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
              end
          end
          if (factor == 2) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [15 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [31 : 16] = token_tmp;
                  mem_K_in [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1: 0] = 0;
              end
          end
          if (factor == 1) begin
              mem_K_in [i] = token_tmp;
          end
      end 
      if (factor == 4) begin
          if (i%factor != 0) begin
              mem_K_in [i/factor] = tmp_cache_mem;
          end
      end
      if (factor == 2) begin
          if (i%factor != 0) begin
              mem_K_in [i/factor] = tmp_cache_mem;
          end
      end 
      read_token(fp, token); 
      if(token != "[[/transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token); 
      transaction_idx = transaction_idx + 1; 
  end 
  $fclose(fp); 
end 
 
task write_binary_K_in;
    input integer fp;
    input reg[64-1:0] in;
    input integer in_bw;
    reg [63:0] tmp_long;
    reg[64-1:0] local_in;
    integer char_num;
    integer long_num;
    integer i;
    integer j;
    begin
        long_num = (in_bw + 63) / 64;
        char_num = ((in_bw - 1) % 64 + 7) / 8;
        for(i=long_num;i>0;i=i-1) begin
             local_in = in;
             tmp_long = local_in >> ((i-1)*64);
             for(j=0;j<64;j=j+1)
                 if (tmp_long[j] === 1'bx)
                     tmp_long[j] = 1'b0;
             if (i == long_num) begin
                 case(char_num)
                     1: $fwrite(fp,"%c",tmp_long[7:0]);
                     2: $fwrite(fp,"%c%c",tmp_long[15:8],tmp_long[7:0]);
                     3: $fwrite(fp,"%c%c%c",tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     4: $fwrite(fp,"%c%c%c%c",tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     5: $fwrite(fp,"%c%c%c%c%c",tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     6: $fwrite(fp,"%c%c%c%c%c%c",tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     7: $fwrite(fp,"%c%c%c%c%c%c%c",tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     8: $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     default: ;
                 endcase
             end
             else begin
                 $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
             end
        end
    end
endtask;
//------------------------Read file------------------------ 
 
// Read data from file 
initial begin : read_V_in_file_process 
  integer fp; 
  integer ret; 
  integer factor; 
  reg [151 : 0] token; 
  reg [151 : 0] token_tmp; 
  //reg [V_in_c_bitwidth - 1 : 0] token_tmp; 
  reg [DATA_WIDTH - 1 : 0] tmp_cache_mem; 
  reg [ 8*5 : 1] str;
    reg [63:0] trans_depth;
  integer transaction_idx; 
  integer i; 
  transaction_idx = 0; 
  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
  count_seperate_factor_by_bitwidth (V_in_c_bitwidth , factor);
  fp = $fopen(`TV_IN_V_in ,"r"); 
  if(fp == 0) begin                               // Failed to open file 
      $display("Failed to open file \"%s\"!", `TV_IN_V_in); 
      $finish; 
  end 
  read_token(fp, token); 
  if (token != "[[[runtime]]]") begin             // Illegal format 
      $display("ERROR: Simulation using HLS TB failed.");
      $finish; 
  end 
  read_token(fp, token); 
  while (token != "[[[/runtime]]]") begin 
      if (token != "[[transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token);                        // skip transaction number 
      @(posedge clk);
      # 0.2;
      while(AESL_ready_reg !== 1) begin
          @(posedge clk); 
          # 0.2;
      end
      for(i = 0; i < V_in_DEPTH; i = i + 1) begin 
          read_token(fp, token); 
          ret = $sscanf(token, "0x%x", token_tmp); 
          if (factor == 4) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [7 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [15 : 8] = token_tmp;
              end
              if (i%factor == 2) begin
                  tmp_cache_mem [23 : 16] = token_tmp;
              end
              if (i%factor == 3) begin
                  tmp_cache_mem [31 : 24] = token_tmp;
                  mem_V_in [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
              end
          end
          if (factor == 2) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [15 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [31 : 16] = token_tmp;
                  mem_V_in [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1: 0] = 0;
              end
          end
          if (factor == 1) begin
              mem_V_in [i] = token_tmp;
          end
      end 
      if (factor == 4) begin
          if (i%factor != 0) begin
              mem_V_in [i/factor] = tmp_cache_mem;
          end
      end
      if (factor == 2) begin
          if (i%factor != 0) begin
              mem_V_in [i/factor] = tmp_cache_mem;
          end
      end 
      read_token(fp, token); 
      if(token != "[[/transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token); 
      transaction_idx = transaction_idx + 1; 
  end 
  $fclose(fp); 
end 
 
task write_binary_V_in;
    input integer fp;
    input reg[64-1:0] in;
    input integer in_bw;
    reg [63:0] tmp_long;
    reg[64-1:0] local_in;
    integer char_num;
    integer long_num;
    integer i;
    integer j;
    begin
        long_num = (in_bw + 63) / 64;
        char_num = ((in_bw - 1) % 64 + 7) / 8;
        for(i=long_num;i>0;i=i-1) begin
             local_in = in;
             tmp_long = local_in >> ((i-1)*64);
             for(j=0;j<64;j=j+1)
                 if (tmp_long[j] === 1'bx)
                     tmp_long[j] = 1'b0;
             if (i == long_num) begin
                 case(char_num)
                     1: $fwrite(fp,"%c",tmp_long[7:0]);
                     2: $fwrite(fp,"%c%c",tmp_long[15:8],tmp_long[7:0]);
                     3: $fwrite(fp,"%c%c%c",tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     4: $fwrite(fp,"%c%c%c%c",tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     5: $fwrite(fp,"%c%c%c%c%c",tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     6: $fwrite(fp,"%c%c%c%c%c%c",tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     7: $fwrite(fp,"%c%c%c%c%c%c%c",tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     8: $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     default: ;
                 endcase
             end
             else begin
                 $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
             end
        end
    end
endtask;
//------------------------Read file------------------------ 
 
// Read data from file 
initial begin : read_O_out_file_process 
  integer fp; 
  integer ret; 
  integer factor; 
  reg [151 : 0] token; 
  reg [151 : 0] token_tmp; 
  //reg [O_out_c_bitwidth - 1 : 0] token_tmp; 
  reg [DATA_WIDTH - 1 : 0] tmp_cache_mem; 
  reg [ 8*5 : 1] str;
    reg [63:0] trans_depth;
  integer transaction_idx; 
  integer i; 
  transaction_idx = 0; 
  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
  count_seperate_factor_by_bitwidth (O_out_c_bitwidth , factor);
  fp = $fopen(`TV_IN_O_out ,"r"); 
  if(fp == 0) begin                               // Failed to open file 
      $display("Failed to open file \"%s\"!", `TV_IN_O_out); 
      $finish; 
  end 
  read_token(fp, token); 
  if (token != "[[[runtime]]]") begin             // Illegal format 
      $display("ERROR: Simulation using HLS TB failed.");
      $finish; 
  end 
  read_token(fp, token); 
  while (token != "[[[/runtime]]]") begin 
      if (token != "[[transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token);                        // skip transaction number 
      @(posedge clk);
      # 0.2;
      while(AESL_ready_reg !== 1) begin
          @(posedge clk); 
          # 0.2;
      end
      for(i = 0; i < O_out_DEPTH; i = i + 1) begin 
          read_token(fp, token); 
          ret = $sscanf(token, "0x%x", token_tmp); 
          if (factor == 4) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [7 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [15 : 8] = token_tmp;
              end
              if (i%factor == 2) begin
                  tmp_cache_mem [23 : 16] = token_tmp;
              end
              if (i%factor == 3) begin
                  tmp_cache_mem [31 : 24] = token_tmp;
                  mem_O_out [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
              end
          end
          if (factor == 2) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [15 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [31 : 16] = token_tmp;
                  mem_O_out [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1: 0] = 0;
              end
          end
          if (factor == 1) begin
              mem_O_out [i] = token_tmp;
          end
      end 
      if (factor == 4) begin
          if (i%factor != 0) begin
              mem_O_out [i/factor] = tmp_cache_mem;
          end
      end
      if (factor == 2) begin
          if (i%factor != 0) begin
              mem_O_out [i/factor] = tmp_cache_mem;
          end
      end 
      read_token(fp, token); 
      if(token != "[[/transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token); 
      transaction_idx = transaction_idx + 1; 
  end 
  $fclose(fp); 
end 
 
task write_binary_O_out;
    input integer fp;
    input reg[64-1:0] in;
    input integer in_bw;
    reg [63:0] tmp_long;
    reg[64-1:0] local_in;
    integer char_num;
    integer long_num;
    integer i;
    integer j;
    begin
        long_num = (in_bw + 63) / 64;
        char_num = ((in_bw - 1) % 64 + 7) / 8;
        for(i=long_num;i>0;i=i-1) begin
             local_in = in;
             tmp_long = local_in >> ((i-1)*64);
             for(j=0;j<64;j=j+1)
                 if (tmp_long[j] === 1'bx)
                     tmp_long[j] = 1'b0;
             if (i == long_num) begin
                 case(char_num)
                     1: $fwrite(fp,"%c",tmp_long[7:0]);
                     2: $fwrite(fp,"%c%c",tmp_long[15:8],tmp_long[7:0]);
                     3: $fwrite(fp,"%c%c%c",tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     4: $fwrite(fp,"%c%c%c%c",tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     5: $fwrite(fp,"%c%c%c%c%c",tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     6: $fwrite(fp,"%c%c%c%c%c%c",tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     7: $fwrite(fp,"%c%c%c%c%c%c%c",tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     8: $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     default: ;
                 endcase
             end
             else begin
                 $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
             end
        end
    end
endtask;
//------------------------Read file------------------------ 
 
// Read data from file 
initial begin : read_q_scale_file_process 
  integer fp; 
  integer ret; 
  integer factor; 
  reg [127 : 0] token; 
  reg [127 : 0] token_tmp; 
  //reg [q_scale_c_bitwidth - 1 : 0] token_tmp; 
  reg [DATA_WIDTH - 1 : 0] tmp_cache_mem; 
  reg [ 8*5 : 1] str;
    reg [63:0] trans_depth;
  integer transaction_idx; 
  integer i; 
  transaction_idx = 0; 
  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
  count_seperate_factor_by_bitwidth (q_scale_c_bitwidth , factor);
  fp = $fopen(`TV_IN_q_scale ,"r"); 
  if(fp == 0) begin                               // Failed to open file 
      $display("Failed to open file \"%s\"!", `TV_IN_q_scale); 
      $finish; 
  end 
  read_token(fp, token); 
  if (token != "[[[runtime]]]") begin             // Illegal format 
      $display("ERROR: Simulation using HLS TB failed.");
      $finish; 
  end 
  read_token(fp, token); 
  while (token != "[[[/runtime]]]") begin 
      if (token != "[[transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token);                        // skip transaction number 
      @(posedge clk);
      # 0.2;
      while(AESL_ready_reg !== 1) begin
          @(posedge clk); 
          # 0.2;
      end
      for(i = 0; i < q_scale_DEPTH; i = i + 1) begin 
          read_token(fp, token); 
          ret = $sscanf(token, "0x%x", token_tmp); 
          if (factor == 4) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [7 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [15 : 8] = token_tmp;
              end
              if (i%factor == 2) begin
                  tmp_cache_mem [23 : 16] = token_tmp;
              end
              if (i%factor == 3) begin
                  tmp_cache_mem [31 : 24] = token_tmp;
                  mem_q_scale [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
              end
          end
          if (factor == 2) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [15 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [31 : 16] = token_tmp;
                  mem_q_scale [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1: 0] = 0;
              end
          end
          if (factor == 1) begin
              mem_q_scale [i] = token_tmp;
          end
      end 
      if (factor == 4) begin
          if (i%factor != 0) begin
              mem_q_scale [i/factor] = tmp_cache_mem;
          end
      end
      if (factor == 2) begin
          if (i%factor != 0) begin
              mem_q_scale [i/factor] = tmp_cache_mem;
          end
      end 
      read_token(fp, token); 
      if(token != "[[/transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token); 
      transaction_idx = transaction_idx + 1; 
  end 
  $fclose(fp); 
end 
 
task write_binary_q_scale;
    input integer fp;
    input reg[64-1:0] in;
    input integer in_bw;
    reg [63:0] tmp_long;
    reg[64-1:0] local_in;
    integer char_num;
    integer long_num;
    integer i;
    integer j;
    begin
        long_num = (in_bw + 63) / 64;
        char_num = ((in_bw - 1) % 64 + 7) / 8;
        for(i=long_num;i>0;i=i-1) begin
             local_in = in;
             tmp_long = local_in >> ((i-1)*64);
             for(j=0;j<64;j=j+1)
                 if (tmp_long[j] === 1'bx)
                     tmp_long[j] = 1'b0;
             if (i == long_num) begin
                 case(char_num)
                     1: $fwrite(fp,"%c",tmp_long[7:0]);
                     2: $fwrite(fp,"%c%c",tmp_long[15:8],tmp_long[7:0]);
                     3: $fwrite(fp,"%c%c%c",tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     4: $fwrite(fp,"%c%c%c%c",tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     5: $fwrite(fp,"%c%c%c%c%c",tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     6: $fwrite(fp,"%c%c%c%c%c%c",tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     7: $fwrite(fp,"%c%c%c%c%c%c%c",tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     8: $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     default: ;
                 endcase
             end
             else begin
                 $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
             end
        end
    end
endtask;
//------------------------Read file------------------------ 
 
// Read data from file 
initial begin : read_v_scale_file_process 
  integer fp; 
  integer ret; 
  integer factor; 
  reg [127 : 0] token; 
  reg [127 : 0] token_tmp; 
  //reg [v_scale_c_bitwidth - 1 : 0] token_tmp; 
  reg [DATA_WIDTH - 1 : 0] tmp_cache_mem; 
  reg [ 8*5 : 1] str;
    reg [63:0] trans_depth;
  integer transaction_idx; 
  integer i; 
  transaction_idx = 0; 
  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
  count_seperate_factor_by_bitwidth (v_scale_c_bitwidth , factor);
  fp = $fopen(`TV_IN_v_scale ,"r"); 
  if(fp == 0) begin                               // Failed to open file 
      $display("Failed to open file \"%s\"!", `TV_IN_v_scale); 
      $finish; 
  end 
  read_token(fp, token); 
  if (token != "[[[runtime]]]") begin             // Illegal format 
      $display("ERROR: Simulation using HLS TB failed.");
      $finish; 
  end 
  read_token(fp, token); 
  while (token != "[[[/runtime]]]") begin 
      if (token != "[[transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token);                        // skip transaction number 
      @(posedge clk);
      # 0.2;
      while(AESL_ready_reg !== 1) begin
          @(posedge clk); 
          # 0.2;
      end
      for(i = 0; i < v_scale_DEPTH; i = i + 1) begin 
          read_token(fp, token); 
          ret = $sscanf(token, "0x%x", token_tmp); 
          if (factor == 4) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [7 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [15 : 8] = token_tmp;
              end
              if (i%factor == 2) begin
                  tmp_cache_mem [23 : 16] = token_tmp;
              end
              if (i%factor == 3) begin
                  tmp_cache_mem [31 : 24] = token_tmp;
                  mem_v_scale [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
              end
          end
          if (factor == 2) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [15 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [31 : 16] = token_tmp;
                  mem_v_scale [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1: 0] = 0;
              end
          end
          if (factor == 1) begin
              mem_v_scale [i] = token_tmp;
          end
      end 
      if (factor == 4) begin
          if (i%factor != 0) begin
              mem_v_scale [i/factor] = tmp_cache_mem;
          end
      end
      if (factor == 2) begin
          if (i%factor != 0) begin
              mem_v_scale [i/factor] = tmp_cache_mem;
          end
      end 
      read_token(fp, token); 
      if(token != "[[/transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token); 
      transaction_idx = transaction_idx + 1; 
  end 
  $fclose(fp); 
end 
 
task write_binary_v_scale;
    input integer fp;
    input reg[64-1:0] in;
    input integer in_bw;
    reg [63:0] tmp_long;
    reg[64-1:0] local_in;
    integer char_num;
    integer long_num;
    integer i;
    integer j;
    begin
        long_num = (in_bw + 63) / 64;
        char_num = ((in_bw - 1) % 64 + 7) / 8;
        for(i=long_num;i>0;i=i-1) begin
             local_in = in;
             tmp_long = local_in >> ((i-1)*64);
             for(j=0;j<64;j=j+1)
                 if (tmp_long[j] === 1'bx)
                     tmp_long[j] = 1'b0;
             if (i == long_num) begin
                 case(char_num)
                     1: $fwrite(fp,"%c",tmp_long[7:0]);
                     2: $fwrite(fp,"%c%c",tmp_long[15:8],tmp_long[7:0]);
                     3: $fwrite(fp,"%c%c%c",tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     4: $fwrite(fp,"%c%c%c%c",tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     5: $fwrite(fp,"%c%c%c%c%c",tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     6: $fwrite(fp,"%c%c%c%c%c%c",tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     7: $fwrite(fp,"%c%c%c%c%c%c%c",tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     8: $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     default: ;
                 endcase
             end
             else begin
                 $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
             end
        end
    end
endtask;
endmodule
