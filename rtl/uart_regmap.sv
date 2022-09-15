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
    parameter                                   APB_ADDR_WIDTH  = 32,
    parameter                                   APB_DATA_WIDTH  = 32
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

    //| Registers
    output  uart_regmap_t                       REGMAP_OUT
);

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
    logic                   ro_write_error;                             //| Read Only regs write request occured
    logic                   miss_address_error;                         //| Requested reg doesn't exists
    logic                   wr_en;                                      //| Write Enable
    logic                   rd_en;                                      //| Read  Enable
    logic                   flag_error;                                 //| Error flag for internal use

    /* ------------------------------------------ APB3 Slave Logic --------------------------------------------- */

    always_comb wr_en   = i_apb_psel && i_apb_penable &&  i_apb_pwrite; //| Write Enable
    always_comb rd_en   = i_apb_psel && i_apb_penable && !i_apb_pwrite; //| Read  Enable

    /* ------------------------------------------------------------- */

    always_comb ro_write_error      = (i_apb_paddr > ALLOWED_RW_ADDR_RANGE) &&  wr_en;
    always_comb miss_address_error  = (i_apb_paddr > ALLOWED_ADDR_RANGE)    && (wr_en || rd_en);

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




endmodule : uart_regmap


`endif    /*__KENEZOER_UART_REGMAP_DEFINED__*/