`timescale  1ns/1ns
 
module  tb_sdram_pro_top();
 
//********************************************************************//
//****************** Internal Signal and Defparam ********************//
//********************************************************************//
//wire define
//clk_gen
/* wire            clk_50m         ;   //PLL输出50M时钟
wire            clk_100m        ;   //PLL输出100M时钟
wire            clk_100m_shift  ;   //PLL输出100M时钟,相位偏移-30deg
wire            locked          ;   //PLL时钟锁定信号 */

//sdram
wire            sdram_clk_out	;   //SDRAM时钟
wire            sdram_cke       ;   //SDRAM时钟使能信号
wire            sdram_cs_n      ;   //SDRAM片选信号
wire            sdram_ras_n     ;   //SDRAM行选通信号
wire            sdram_cas_n     ;   //SDRAM列选题信号
wire            sdram_we_n      ;   //SDRAM写使能信号
wire	[3:0]	sdram_cmd		;
wire    [1:0]   sdram_bank		;   //SDRAM L-Bank地址
wire    [11:0]  sdram_addr      ;   //SDRAM地址总线
wire    [15:0]  sdram_dq        ;   //SDRAM数据总线
wire    [1:0]   sdram_dqm       ;   //SDRAM数据总线
//sdram_ctrl
// wire            sdram_wr_ack    ;   //数据写阶段写响应
// wire            sdram_rd_ack    ;   //数据读阶段响应
 
wire    [9:0]   wr_fifo_num     ;   //fifo_ctrl模块中写fifo中的数据量
wire			init_end		;
 
wire    [9:0]   rd_fifo_num     ;   //fifo_ctrl模块中读fifo中的数据量
wire    [15:0]  rfifo_rd_data   ;   //fifo_ctrl模块中读fifo读数据
 
//reg define
reg             sys_clk         ;   //系统时钟
reg             sys_rst_n       ;   //复位信号
reg             wr_en           ;   //写使能
reg     [15:0]  wr_data_in      ;   //写数据
reg             rd_en           ;   //读使能
reg     [2:0]   cnt_wr_wait     ;   //数据写入间隔计数
reg     [9:0]   cnt_rd_data     ;   //读出数据计数
reg             wr_data_flag    ;   //fifo_ctrl模块中写fifo写使能
reg             read_valid      ;   //读有效信号
 
//defparam
//重定义仿真模型中的相关参数
defparam sdram_model_plus_inst.addr_bits = 12;          //地址位宽
defparam sdram_model_plus_inst.data_bits = 16;          //数据位宽
defparam sdram_model_plus_inst.col_bits  = 9;           //列地址位宽
defparam sdram_model_plus_inst.mem_sizes = 2*1024*1024; //L-Bank容量
 
//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
 
//时钟、复位信号
initial
  begin
    sys_clk     =   1'b1  ;
    sys_rst_n   <=  1'b0  ;
    #200
    sys_rst_n   <=  1'b1  ;
  end
always  #10 sys_clk = ~sys_clk;
//rst_n:复位信号
//assign  rst_n = sys_rst_n & locked;
//wr_en:写数据使能
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en   <=  1'b1;
    else    if(wr_data_in == 10'd30)
        wr_en   <=  1'b0;
    else
        wr_en   <=  wr_en;
//cnt_wr_wait:数据写入间隔计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wr_wait <=  3'd0;
    else    if(wr_en == 1'b1)
        cnt_wr_wait <=  cnt_wr_wait + 1'b1;
    else
        cnt_wr_wait <=  3'd0;
 
//wr_data_flag:fifo_ctrl模块中写fifo写使能
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_data_flag    <=  1'b0;
    else    if(cnt_wr_wait == 3'd7)
        wr_data_flag    <=  1'b1;
    else
        wr_data_flag    <=  1'b0;
//read_valid:数据读使能
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        read_valid  <=  1'b1;
    else    if(rd_fifo_num == 10'd30)
        read_valid  <=  1'b0;
//wr_data_in:写数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_data_in  <=  16'd0;
    else    if(cnt_wr_wait == 3'd7)
        wr_data_in  <=  wr_data_in + 1'b1;
    else
        wr_data_in  <=  wr_data_in;
//rd_en:读数据使能
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if(cnt_rd_data == 4'd9)
        rd_en   <=  1'd0;
    else    if((wr_en == 1'b0))
        rd_en   <=  1'b1;
    else
        rd_en   <=  rd_en;
//cnt_rd_data:读出数据计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd_data <=  0;
    else    if(rd_en == 1'b1)
        cnt_rd_data <=  cnt_rd_data + 1'b1;
    else
        cnt_rd_data <=  0;
 
 
//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
 
//------------- clk_gen_inst -------------
/* clk_gen clk_gen_inst (
    .inclk0     (sys_clk        ),
    .areset     (~sys_rst_n     ),
    .c0         (clk_50m        ),
    .c1         (clk_100m       ),
    .c2         (clk_100m_shift ),
 
    .locked     (locked         )
); */
 
//------------- sdram_top_inst -------------
sdram_pro_top   sdram_top_inst(
    .sys_clk			(sys_clk       ),  //sdram 控制器参考时钟
    //.clk_out            (clk_100m_shift ),  //用于输出的相位偏移时钟
    .sys_rst_n		(sys_rst_n          ),  //系统复位
//用户写端口
    .wr_fifo_wr_clk     (sys_clk        ),  //写端口FIFO: 写时钟
    .wr_fifo_wr_req     (wr_data_flag   ),  //写端口FIFO: 写使能
    .wr_fifo_wr_data    (wr_data_in     ),  //写端口FIFO: 写数据
    .sdram_wr_b_addr    (23'd0          ),  //写SDRAM的首地址
    .sdram_wr_e_addr    (23'd30         ),  //写SDRAM的末地址
    .wr_burst_len       (10'd10         ),  //写SDRAM时的数据突发长度
    //.wr_fifo_rst		(~rst_n         ),  //写地址复位信号
	.wr_fifo_num		(wr_fifo_num	),	//写fifo中的数据量
//用户读端口
    .rd_fifo_rd_clk     (sys_clk        ),  //读端口FIFO: 读时钟
    .rd_fifo_rd_req     (rd_en          ),  //读端口FIFO: 读使能
    .rd_fifo_rd_data    (rfifo_rd_data  ),  //读端口FIFO: 读数据
    .sdram_rd_b_addr    (23'd0          ),  //读SDRAM的首地址
    .sdram_rd_e_addr    (23'd30         ),  //读SDRAM的末地址
    .rd_burst_len       (10'd10         ),  //从SDRAM中读数据时的突发长度
    //.rd_fifo_rst		(~rst_n         ),  //读地址复位信号
    .rd_fifo_num        (rd_fifo_num    ),  //读fifo中的数据量
//用户控制端口
    .read_valid         (read_valid     ),  //SDRAM 读使能
	.init_end			(init_end		),
//SDRAM 芯片接口
    .sdram_clk_out		(sdram_clk_out	),  //SDRAM 芯片时钟
    .sdram_cke          (sdram_cke      ),  //SDRAM 时钟有效
    .sdram_cs_n         (sdram_cs_n    ),  //SDRAM 片选
    .sdram_ras_n        (sdram_ras_n   ),  //SDRAM 行有效
    .sdram_cas_n        (sdram_cas_n    ),  //SDRAM 列有效
    .sdram_we_n         (sdram_we_n    ),  //SDRAM 写有效
    .sdram_bank			(sdram_bank		),  //SDRAM Bank地址
    .sdram_addr         (sdram_addr     ),  //SDRAM 行/列地址
    .sdram_dq           (sdram_dq       ),  //SDRAM 数据
    .sdram_dqm          (sdram_dqm      )   //SDRAM 数据掩码
);
 
//-------------sdram_model_plus_inst-------------
sdram_model_plus    sdram_model_plus_inst(
    .Dq     (sdram_dq       ),
    .Addr   (sdram_addr     ),
    .Ba     (sdram_bank		),
    .Clk    (sys_clk	),
    .Cke    (sdram_cke      ),
    .Cs_n   (sdram_cs_n     ),
    .Ras_n  (sdram_ras_n    ),
    .Cas_n  (sdram_cas_n    ),
    .We_n   (sdram_we_n     ),
    .Dqm    (4'b0           ),
    .Debug  (1'b1           )
 
);
 
endmodule