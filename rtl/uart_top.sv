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


    /* ---------------------------------------- Internal Signals ----------------------------------------- */

    logic                                       rx_status;
    logic                                       tx_status;

    /* --------------------------------------- Upstream FIFO INST ----------------------------------------- */

    logic                                       ufifo_read_req;
    logic                                       ufifo_write_req;
    logic   [FIFO_WIDTH-1:0]                    ufifo_data_in;
    logic   [FIFO_WIDTH-1:0]                    ufifo_data_out;
    logic   [FIFO_USED_WIDTH:0]                 ufifo_free;
    logic   [FIFO_USED_WIDTH:0]                 ufifo_used;
    logic                                       ufifo_valid;
    logic                                       ufifo_full;
    logic                                       ufifo_almfull;
    logic                                       ufifo_empty;
    logic                                       ufifo_almempty;
    logic                                       ufifo_overflow;
    logic                                       ufifo_underflow;
    logic                                       ufifo_parity_error;

    always_comb ufifo_read_req  = '0; // todo
    always_comb ufifo_write_req = '0; // todo
    always_comb ufifo_data_in   = '0; // todo

    uart_fifo_fwft #(

        .FIFO_PARITY_ENABLE     ( FIFO_PARITY_CHECK_EN                          ),
        .FIFO_AW                ( UFIFO_USED_WIDTH                              ),
        .FIFO_DW                ( UFIFO_WIDTH                                   )

    ) upstream_fifo_inst (

        .i_clk                  ( i_apb_pclk                                    ),
        .i_nrst                 ( i_apb_presetn                                 ),
        .i_rd_req               ( ufifo_read_req                                ),
        .i_wr_req               ( ufifo_write_req                               ),
        .i_data_in              ( ufifo_data_in                                 ),

        .o_data_out             ( ufifo_data_out                                ),
        .o_free                 ( ufifo_free                                    ),
        .o_used                 ( ufifo_used                                    ),
        .o_valid                ( ufifo_valid                                   ),
        .o_full                 ( ufifo_full                                    ),
        .o_almost_full          ( ufifo_almfull                                 ),
        .o_empty                ( ufifo_empty                                   ),
        .o_almost_empty         ( ufifo_almempty                                ),
        .o_overflow             ( ufifo_overflow                                ),
        .o_underflow            ( ufifo_underflow                               ),
        .o_parity_error         ( ufifo_parity_error                            ));

    /* -------------------------------------- Downstream FIFO INST ---------------------------------------- */

    logic                                       dfifo_read_req;
    logic                                       dfifo_write_req;
    logic   [FIFO_WIDTH-1:0]                    dfifo_data_in;
    logic   [FIFO_WIDTH-1:0]                    dfifo_data_out;
    logic   [FIFO_USED_WIDTH:0]                 dfifo_free;
    logic   [FIFO_USED_WIDTH:0]                 dfifo_used;
    logic                                       dfifo_valid;
    logic                                       dfifo_full;
    logic                                       dfifo_almfull;
    logic                                       dfifo_empty;
    logic                                       dfifo_almempty;
    logic                                       dfifo_overflow;
    logic                                       dfifo_underflow;
    logic                                       dfifo_parity_error;

    always_comb dfifo_read_req  = '0; // todo
    always_comb dfifo_write_req = '0; // todo
    always_comb dfifo_data_in   = '0; // todo

    uart_fifo_fwft #(

        .FIFO_PARITY_ENABLE     ( FIFO_PARITY_CHECK_EN                          ),
        .FIFO_AW                ( UFIFO_USED_WIDTH                              ),
        .FIFO_DW                ( UFIFO_WIDTH                                   )

    ) upstream_fifo_inst (

        .i_clk                  ( i_apb_pclk                                    ),
        .i_nrst                 ( i_apb_presetn                                 ),
        .i_rd_req               ( dfifo_read_req                                ),
        .i_wr_req               ( dfifo_write_req                               ),
        .i_data_in              ( dfifo_data_in                                 ),

        .o_data_out             ( dfifo_data_out                                ),
        .o_free                 ( dfifo_free                                    ),
        .o_used                 ( dfifo_used                                    ),
        .o_valid                ( dfifo_valid                                   ),
        .o_full                 ( dfifo_full                                    ),
        .o_almost_full          ( dfifo_almfull                                 ),
        .o_empty                ( dfifo_empty                                   ),
        .o_almost_empty         ( dfifo_almempty                                ),
        .o_overflow             ( dfifo_overflow                                ),
        .o_underflow            ( dfifo_underflow                               ),
        .o_parity_error         ( dfifo_parity_error                            ));

    /* ----------------------------------------- Receiver INST -------------------------------------------- */

    // todo

    /* ---------------------------------------- Tranceiver INST ------------------------------------------- */

    // todo

    /* -------------------------------------- IRQ Generator INST ------------------------------------------ */

    logic           [31:0]                      irq_events_enable;
    logic           [31:0]                      irq_events_mask;
    logic           [31:0]                      irq_events;
    logic           [31:0]                      irq_events_stats_ext;

    logic           [IRQ_EVENTS_NUM-1:0]        irq_events_bus;
    logic           [IRQ_EVENTS_NUM-1:0]        internal_irqs;
    logic           [IRQ_EVENTS_NUM-1:0]        irq_events_stats;

    always_comb o_irq                   = |internal_irqs;
    always_comb irq_events_stats_ext    = '0 | irq_events_stats;

    uart_irq_gen #(
        
        .EVENTS_NUM             ( IRQ_EVENTS_NUM                                )

    ) irq_gen_inst  (
        .i_clk                  ( i_apb_pclk                                    ),
        .i_nrst                 ( i_apb_presetn                                 ),

        .i_events_enable        ( irq_events_enable [IRQ_EVENTS_NUM-1:0]        ),
        .i_events_mask          ( irq_events_mask   [IRQ_EVENTS_NUM-1:0]        ),
        .i_events_disable       ( irq_events        [IRQ_EVENTS_NUM-1:0]        ),
        .i_events_itself        ( irq_events_bus                                ),

        .o_irq_bus              ( internal_irqs                                 ),
        .o_events_stats         ( irq_events_stats                              ));

    /* ------------------------------------------ REGMAP INST --------------------------------------------- */

    uart_regmap #(

        .APB_ADDR_WIDTH         ( APB_ADDR_WIDTH                                ),
        .APB_DATA_WIDTH         ( APB_DATA_WIDTH                                ),
        .FIFO_PARITY_CHECK_EN   ( FIFO_PARITY_CHECK_EN                          )
        
    ) regmap_inst (

        //| APB3 Interface Signals
        .i_apb_pclk             ( i_apb_pclk                                    ),
        .i_apb_presetn          ( i_apb_presetn                                 ),

        .i_apb_paddr            ( i_apb_paddr                                   ),
        .i_apb_pwdata           ( i_apb_pwdata                                  ),
        .i_apb_pwrite           ( i_apb_pwrite                                  ),
        .i_apb_psel             ( i_apb_psel                                    ),
        .i_apb_penable          ( i_apb_penable                                 ),
        
        .o_apb_pslverr          ( o_apb_pslverr                                 ),
        .o_apb_prdata           ( o_apb_prdata                                  ),
        .o_apb_pready           ( o_apb_pready                                  ),

        //| Stats
        .i_rx_status            ( rx_status                                     ),
        .i_tx_status            ( tx_status                                     ),

        .i_ufifo_full           ( ufifo_full                                    ),
        .i_ufifo_empty          ( ufifo_empty                                   ),
        .i_ufifo_used           ( ufifo_used                                    ),
        .i_ufifo_output         ( ufifo_output                                  ),
        
        .i_dfifo_full           ( dfifo_full                                    ),
        .i_dfifo_empty          ( dfifo_empty                                   ),
        .i_dfifo_used           ( dfifo_used                                    ),

        .i_irq_stats            ( irq_events_stats_ext                          ),
        .o_irq_enable           ( irq_events_enable                             ),
        .o_irq_mask             ( irq_events_mask                               ),
        .o_irq_disable          ( irq_events                                    ),

        //| Control Signals
        .o_dfifo_input          ( dfifo_input                                   ),
        .o_dfifo_write_req      ( dfifo_write_req                               ),
        .o_ufifo_read_req       ( ufifo_read_req                                ),

        //| Registers
        .REGMAP_OUT             ( REGMAP                                        ));


endmodule : uart_top

`endif    /*__KENEZOER_UART_TOP_DEFINED__*/