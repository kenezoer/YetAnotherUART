/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_top.sv
 *  Purpose:  UART with APB3 Interface top module
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

`ifndef     __KENEZOER_UART_TOP_DEFINED__
`define     __KENEZOER_UART_TOP_DEFINED__

module uart_top
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

    //| UART Signals
    output  logic                               o_tx,
    input                                       i_rx,

    //| Misc
    output  logic                               o_irq

);

    //| Stats
    logic                                       rx_status;
    logic                                       tx_status;

    logic                                       dfifo_full;
    logic                                       dfifo_empty;
    logic           [DFIFO_DEPTH_WIDTH-1:0]     dfifo_used;
    logic           [DFIFO_DATA_WIDTH-1:0]      dfifo_input;
    logic                                       dfifo_write_req;
    logic                                       dfifo_read_req;

    logic                                       ufifo_full;
    logic                                       ufifo_empty;
    logic           [UFIFO_DEPTH_WIDTH-1:0]     ufifo_used;
    logic           [UFIFO_DATA_WIDTH-1:0]      ufifo_output;
    logic                                       ufifo_read_req;
    logic                                       ufifo_write_req;

    /* --------------------------------------- Upstream FIFO INST ----------------------------------------- */

    // todo

    /* -------------------------------------- Downstream FIFO INST ---------------------------------------- */

    // todo

    /* ----------------------------------------- Receiver INST -------------------------------------------- */

    // todo

    /* ---------------------------------------- Tranceiver INST ------------------------------------------- */

    // todo

    /* ------------------------------------------ REGMAP INST --------------------------------------------- */

    uart_regmap #(
        .APB_ADDR_WIDTH         ( APB_ADDR_WIDTH            ),
        .APB_DATA_WIDTH         ( APB_DATA_WIDTH            ),
        .FIFO_PARITY_CHECK_EN   ( FIFO_PARITY_CHECK_EN      )
    ) regmap_inst (

        //| APB3 Interface Signals
        .i_apb_pclk             ( i_apb_pclk                ),
        .i_apb_presetn          ( i_apb_presetn             ),

        .i_apb_paddr            ( i_apb_paddr               ),
        .i_apb_pwdata           ( i_apb_pwdata              ),
        .i_apb_pwrite           ( i_apb_pwrite              ),
        .i_apb_psel             ( i_apb_psel                ),
        .i_apb_penable          ( i_apb_penable             ),
        
        .o_apb_pslverr          ( o_apb_pslverr             ),
        .o_apb_prdata           ( o_apb_prdata              ),
        .o_apb_pready           ( o_apb_pready              ),

        //| Stats
        .i_rx_status            ( rx_status                 ),
        .i_ufifo_full           ( ufifo_full                ),
        .i_ufifo_empty          ( ufifo_empty               ),
        .i_ufifo_used           ( ufifo_used                ),
        .i_tx_status            ( tx_status                 ),
        .i_dfifo_full           ( dfifo_full                ),
        .i_dfifo_empty          ( dfifo_empty               ),
        .i_dfifo_used           ( dfifo_used                ),
        .i_ufifo_output         ( ufifo_output              ),

        //| Control Signals
        .o_dfifo_input          ( dfifo_input               ),
        .o_dfifo_write_req      ( dfifo_write_req           ),
        .o_ufifo_read_req       ( ufifo_read_req            ),

        //| Registers
        .REGMAP_OUT             ( REGMAP                    ));


endmodule : uart_top

`endif    /*__KENEZOER_UART_TOP_DEFINED__*/