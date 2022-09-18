/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_regmap.sv
 *  Purpose:  UART APB3 RegMap Control module
 * ----------------------------------------------------------------------------
 *  Copyright © 2020-2022, Kirill Lyubavin <kenezoer@gmail.com>
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 * ----------------------------------------------------------------------------
 */


`ifndef     __KENEZOER_UART_REGMAP_DEFINED__
`define     __KENEZOER_UART_REGMAP_DEFINED__

module uart_regmap
//|------- Required Packages ----------
    import uart_pkg::*;
//|------------------------------------
#(
    parameter                                   APB_ADDR_WIDTH          = 32,
    parameter                                   APB_DATA_WIDTH          = 32,
    parameter   bit                             FIFO_PARITY_CHECK_EN    = 1
)(

    //| APB3 Interface Signals
    input                                       i_apb_pclk,
    input                                       i_apb_presetn,

    input           [APB_ADDR_WIDTH-1:0]        i_apb_paddr,
    input           [APB_DATA_WIDTH-1:0]        i_apb_pwdata,
    input                                       i_apb_pwrite,
    input                                       i_apb_psel,
    input                                       i_apb_penable,
    
    output  logic                               o_apb_pslverr,
    output  logic   [APB_DATA_WIDTH-1:0]        o_apb_prdata,
    output  logic                               o_apb_pready,


    //| Stats
    input                                       i_rx_status,
    input                                       i_ufifo_full,
    input                                       i_ufifo_empty,
    input           [UFIFO_DEPTH_WIDTH-1:0]     i_ufifo_used,
    input                                       i_tx_status,
    input                                       i_dfifo_full,
    input                                       i_dfifo_empty,
    input           [DFIFO_DEPTH_WIDTH-1:0]     i_dfifo_used,
    input           [UFIFO_DATA_WIDTH-1:0]      i_ufifo_output,

    //| Control Signals
    output  logic   [DFIFO_DATA_WIDTH-1:0]      o_dfifo_input,
    output  logic                               o_dfifo_write_req,
    output  logic                               o_ufifo_read_req,

    //| Registers
    output  uart_regmap_t                       REGMAP_OUT
);

    /* --------------------------------------------------------------------------------------------------------- */

    //|-----------------------------
    //| Localparams
    //|-----------------------------
    localparam  TOTAL_REGS_BYTES        = $bits(REGMAP_OUT)     / 8;
    localparam  RW_REGS_BYTES           = $bits(REGMAP_OUT.RW)  / 8;
    localparam  APB_BYTES               = APB_DATA_WIDTH        / 8;
    localparam  ALLOWED_ADDR_RANGE      = TOTAL_REGS_BYTES  - APB_BYTES;
    localparam  ALLOWED_RW_ADDR_RANGE   = RW_REGS_BYTES     - APB_BYTES;

    //|-----------------------------
    //| Local Variables
    //|-----------------------------
    logic                                   ro_write_error;             //| Read Only regs write request occured
    logic                                   miss_address_error;         //| Requested reg doesn't exists
    logic                                   wr_en;                      //| Write Enable
    logic                                   rd_en;                      //| Read  Enable
    logic                                   flag_error;                 //| Error flag for internal use
    logic   [APB_ADDR_VALUABLE_WIDTH-1:0]   apb_paddr;

    /* ------------------------------------------ APB3 Slave Logic --------------------------------------------- */

    always_comb apb_paddr   =   i_apb_paddr[APB_ADDR_VALUABLE_WIDTH-1:0];

    /* ------------------------------------------------------------- */

    always_comb wr_en   = i_apb_psel && i_apb_penable &&  i_apb_pwrite; //| Write Enable
    always_comb rd_en   = i_apb_psel && i_apb_penable && !i_apb_pwrite; //| Read  Enable

    /* ------------------------------------------------------------- */

    always_comb ro_write_error      = (apb_paddr > ALLOWED_RW_ADDR_RANGE) &&  wr_en;
    always_comb miss_address_error  = (apb_paddr > ALLOWED_ADDR_RANGE)    && (wr_en || rd_en);

    /* ------------------------------------------------------------- */

    always_ff@(posedge i_apb_pclk or negedge i_apb_presetn)
    if(!i_apb_presetn)
        o_apb_pready        <= '0;
    else begin
        if(wr_en || rd_en)
            o_apb_pready    <= '1;
        else
            o_apb_pready    <= '0;
    end

    /* ------------------------------------------------------------- */

    always_comb flag_error      =   ro_write_error          ||
                                    miss_address_error;

    always_comb o_apb_pslverr   =   flag_error              && 
                                    o_apb_pready;

    /* ------------------------------------------------------------- */

    always_ff@(posedge i_apb_pclk or negedge i_apb_presetn)
    if(!i_apb_presetn)
        o_apb_prdata        <= '0;
    else begin
        if(rd_en && !flag_error)
            o_apb_pready    <= REGMAP_OUT[apb_paddr*8-:APB_BYTES*8];
        else
            o_apb_pready    <= '0;
    end

    /* ------------------------------------------------------------- */

    always_ff@(posedge i_apb_pclk or negedge i_apb_presetn)
    if(!i_apb_presetn) begin
        REGMAP_OUT          <= '0;
    end else begin

        if(wr_en && !flag_error) begin
            REGMAP_OUT[apb_paddr*8-:APB_BYTES*8]  <= i_apb_pwdata;
        end

        /* -------------- Hardware Info ---------------------------- */
        REGMAP_OUT.RO.HWINFO.parity_check_en    <= FIFO_PARITY_CHECK_EN;
        REGMAP_OUT.RO.HWINFO.reserved           <= '0;
        REGMAP_OUT.RO.HWINFO.ufifo_depth        <= UFIFO_DEPTH;
        REGMAP_OUT.RO.HWINFO.dfifo_depth        <= DFIFO_DEPTH;
        REGMAP_OUT.RO.HWINFO.ip_version[7:4]    <= IP_VERSION_MAJOR;
        REGMAP_OUT.RO.HWINFO.ip_version[3:0]    <= IP_VERSION_MINOR;

        /* ---------------- Stats Info ----------------------------- */
        REGMAP_OUT.RO.STATS.reserved_2          <= '0;
        REGMAP_OUT.RO.STATS.rx_status           <= i_rx_status;
        REGMAP_OUT.RO.STATS.ufifo_full          <= i_ufifo_full;
        REGMAP_OUT.RO.STATS.ufifo_empty         <= i_ufifo_empty;
        REGMAP_OUT.RO.STATS.ufifo_used          <= i_ufifo_used;
        REGMAP_OUT.RO.STATS.reserved_1          <= '0;
        REGMAP_OUT.RO.STATS.tx_status           <= i_tx_status;
        REGMAP_OUT.RO.STATS.dfifo_full          <= i_dfifo_full;
        REGMAP_OUT.RO.STATS.dfifo_empty         <= i_dfifo_empty;
        REGMAP_OUT.RO.STATS.dfifo_used          <= i_dfifo_used;

        /* ------------ Upstream FIFO Output ----------------------- */
        REGMAP_OUT.RO.UFIFO.reserved            <= '0;
        REGMAP_OUT.RO.UFIFO.ufifo_output        <= i_ufifo_output;

        /* ------------ IRQ Events auto-clear ---------------------- */
        if(|REGMAP_OUT.RW.IRQ_EVENT)
            REGMAP_OUT.RW.IRQ_EVENT             <= '0;

    end

    /* ------------------------------------------------------------- */

    always_comb o_ufifo_read_req    =   !flag_error                     && 
                                         rd_en                          && 
                                         o_apb_pready                   && 
                                        (apb_paddr == UFIFO_OFFSET)   ;

    /* ------------------------------------------------------------- */

    always_comb o_dfifo_input       =   REGMAP_OUT.RW.DFIFO.dfifo_input;

    always_ff@(posedge i_apb_pclk or negedge i_apb_presetn)
    if(!i_apb_presetn)
        o_dfifo_write_req           <= '0;
    else
        o_dfifo_write_req           <=  !flag_error                     && 
                                         wr_en                          && 
                                         o_apb_pready                   && 
                                        (apb_paddr == DFIFO_OFFSET)   ;


endmodule : uart_regmap


`endif    /*__KENEZOER_UART_REGMAP_DEFINED__*/