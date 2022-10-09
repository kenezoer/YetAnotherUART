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

    output  logic                               o_rts,                  //| HW Flow control: Ready to send
    input                                       i_cts,                  //| HW Flow control: Clear to send

    //| Misc
    output  logic                               o_irq

);


    /* ---------------------------------------- Internal Signals ------------------------------------------ */

    logic                                       rx_status;
    logic                                       tx_status;
    logic                                       cts_sync;
    logic                                       rx_sync;
    uart_regmap_t                               REGMAP;

    /* ---------------------------------------- Receiver Signals ------------------------------------------ */

    logic                                       rx_bad_frame;
    logic                                       rx_parity_error;
    logic                                       rx_started;
    logic                                       rx_done;

    /* ---------------------------------------- Tranceiver Signals ---------------------------------------- */

    logic                                       tx_done;
    logic                                       tx_started;
    logic                                       tx_ready;
    

    /* --------------------------------------- CDC Synchronization ---------------------------------------- */

    uart_ndff_bus#(
        .CDC_STAGES                 ( 3                             ),
        .BUS_WIDTH                  ( 2                             ),
        .RESET_VALUE                ( 2'b01                         )
    ) inputs_sync (
        .i_clk                      ( i_apb_pclk                    ),
        .i_nrst                     ( i_apb_presetn                 ),

        .i_data_in                  ( {i_cts, i_rx}                 ),
        .o_data_out                 ( {cts_sync, rx_sync}           ));

    /* --------------------------------------- Upstream FIFO INST ----------------------------------------- */

    logic                                       ufifo_resetn;
    logic                                       ufifo_read_req;
    logic                                       ufifo_write_req;
    logic   [UFIFO_WIDTH-1:0]                   ufifo_data_in;
    logic   [UFIFO_WIDTH-1:0]                   ufifo_data_out;
    logic   [UFIFO_USED_WIDTH:0]                ufifo_free;
    logic   [UFIFO_USED_WIDTH:0]                ufifo_used;
    logic                                       ufifo_valid;
    logic                                       ufifo_full;
    logic                                       ufifo_almfull;
    logic                                       ufifo_empty;
    logic                                       ufifo_almempty;
    logic                                       ufifo_overflow;
    logic                                       ufifo_underflow;
    logic                                       ufifo_parity_error;

    always_comb ufifo_write_req = rx_done;

    always_ff@(posedge i_apb_pclk or negedge i_apb_presetn)
    if(!i_apb_presetn)
        ufifo_resetn    <= '0;
    else
        ufifo_resetn    <= ~REGMAP.RW.CTRL.ufifo_rst;

    uart_fifo_fwft #(

        .FIFO_PARITY_ENABLE         ( FIFO_PARITY_CHECK_EN          ),
        .FIFO_AW                    ( UFIFO_USED_WIDTH              ),
        .FIFO_DW                    ( UFIFO_WIDTH                   )

    ) upstream_fifo_inst (

        .i_clk                      ( i_apb_pclk                    ),
        .i_nrst                     ( ufifo_resetn                  ),
        .i_rd_req                   ( ufifo_read_req                ),
        .i_wr_req                   ( ufifo_write_req               ),
        .i_data_in                  ( ufifo_data_in                 ),

        .o_data_out                 ( ufifo_data_out                ),
        .o_free                     ( ufifo_free                    ),
        .o_used                     ( ufifo_used                    ),
        .o_valid                    ( ufifo_valid                   ),
        .o_full                     ( ufifo_full                    ),
        .o_almost_full              ( ufifo_almfull                 ),
        .o_empty                    ( ufifo_empty                   ),
        .o_almost_empty             ( ufifo_almempty                ),
        .o_overflow                 ( ufifo_overflow                ),
        .o_underflow                ( ufifo_underflow               ),
        .o_parity_error             ( ufifo_parity_error            ));

    /* -------------------------------------- Downstream FIFO INST ---------------------------------------- */

    logic                                       dfifo_resetn;
    logic                                       dfifo_read_req;
    logic                                       dfifo_write_req;
    logic   [DFIFO_WIDTH-1:0]                   dfifo_data_in;
    logic   [DFIFO_WIDTH-1:0]                   dfifo_data_out;
    logic   [DFIFO_USED_WIDTH:0]                dfifo_free;
    logic   [DFIFO_USED_WIDTH:0]                dfifo_used;
    logic                                       dfifo_valid;
    logic                                       dfifo_full;
    logic                                       dfifo_almfull;
    logic                                       dfifo_empty;
    logic                                       dfifo_almempty;
    logic                                       dfifo_overflow;
    logic                                       dfifo_underflow;
    logic                                       dfifo_parity_error;

    always_comb dfifo_read_req  = tx_ready && ~dfifo_empty;

    always_ff@(posedge i_apb_pclk or negedge i_apb_presetn)
    if(!i_apb_presetn)
        dfifo_resetn    <= '0;
    else
        dfifo_resetn    <= ~REGMAP.RW.CTRL.dfifo_rst;

    uart_fifo_fwft #(

        .FIFO_PARITY_ENABLE         ( FIFO_PARITY_CHECK_EN          ),
        .FIFO_AW                    ( DFIFO_USED_WIDTH              ),
        .FIFO_DW                    ( DFIFO_WIDTH                   )

    ) downstream_fifo_inst (

        .i_clk                      ( i_apb_pclk                    ),
        .i_nrst                     ( dfifo_resetn                  ),
        .i_rd_req                   ( dfifo_read_req                ),
        .i_wr_req                   ( dfifo_write_req               ),
        .i_data_in                  ( dfifo_data_in                 ),

        .o_data_out                 ( dfifo_data_out                ),
        .o_free                     ( dfifo_free                    ),
        .o_used                     ( dfifo_used                    ),
        .o_valid                    ( dfifo_valid                   ),
        .o_full                     ( dfifo_full                    ),
        .o_almost_full              ( dfifo_almfull                 ),
        .o_empty                    ( dfifo_empty                   ),
        .o_almost_empty             ( dfifo_almempty                ),
        .o_overflow                 ( dfifo_overflow                ),
        .o_underflow                ( dfifo_underflow               ),
        .o_parity_error             ( dfifo_parity_error            ));

    /* ----------------------------------------- Receiver INST -------------------------------------------- */

    uart_rx
    RX (

        .i_clk                      ( i_apb_pclk                    ),
        .i_nrst                     ( i_apb_presetn                 ),

        .i_rx                       ( rx_sync                       ),
        .o_rts                      ( o_rts                         ),

        .i_bit_length               ( REGMAP.RW.UART_BIT_LENGTH     ),
        .i_hw_flow_control_enable   ( REGMAP.RW.CTRL.hw_flow_ctrl_en),
        .i_parity_enable            ( REGMAP.RW.CTRL.send_parity    ),
        .i_fifo_almfull             ( ufifo_almfull                 ),
        .i_msb_first                ( REGMAP.RW.CTRL.msb_first      ),
        .i_stop_bit_mode            ( REGMAP.RW.CTRL.stop_bit_mode  ),
        .i_stop_bit_value           ( REGMAP.RW.CTRL.stop_bit_value ),

        .o_rx_done                  ( rx_done                       ),
        .o_rx_started               ( rx_started                    ),
        .o_rx_status                ( rx_status                     ),
        .o_rx_frame_error           ( rx_bad_frame                  ),
        .o_rx_parity_error          ( rx_parity_error               ),
        .o_rx_word                  ( ufifo_data_in                 ));

    /* ---------------------------------------- Tranceiver INST ------------------------------------------- */

    uart_tx
    TX (
        .i_clk                      ( i_apb_pclk                    ),
        .i_nrst                     ( i_apb_presetn                 ),

        .i_valid                    ( dfifo_valid                   ),
        .o_ready                    ( tx_ready                      ),
        .o_tx_status                ( tx_status                     ),
        .o_tx_done                  ( tx_done                       ),
        .o_tx_started               ( tx_started                    ),

        .i_parity_enable            ( REGMAP.RW.CTRL.send_parity    ),
        .i_stop_bit_mode            ( REGMAP.RW.CTRL.stop_bit_mode  ),
        .i_stop_bit_value           ( REGMAP.RW.CTRL.stop_bit_value ),
        .i_fifo_empty               ( dfifo_empty                   ),

        .o_tx                       ( o_tx                          ),
        .i_cts                      ( cts_sync                      ),
        .i_hw_flow_control_enable   ( REGMAP.RW.CTRL.hw_flow_ctrl_en),

        .i_bit_length               ( REGMAP.RW.UART_BIT_LENGTH     ),
        .i_msb_first                ( REGMAP.RW.CTRL.msb_first      ),
        .i_data                     ( dfifo_data_out                ));

    /* -------------------------------------- IRQ Generator INST ------------------------------------------ */

    logic           [IRQ_EVENTS_NUM-1:0]        irq_events_enable;
    logic           [IRQ_EVENTS_NUM-1:0]        irq_events_mask;
    logic           [IRQ_EVENTS_NUM-1:0]        irq_events;

    logic           [IRQ_EVENTS_NUM-1:0]        irq_events_bus;
    logic           [IRQ_EVENTS_NUM-1:0]        irq_events_bus_edged;
    logic           [IRQ_EVENTS_NUM-1:0]        internal_irqs;
    logic           [IRQ_EVENTS_NUM-1:0]        irq_events_stats;

    always_comb o_irq                               = |internal_irqs;

    always_comb irq_events_enable                   = REGMAP.RW.IRQ_EN      [IRQ_EVENTS_NUM-1:0];  
    always_comb irq_events_mask                     = REGMAP.RW.IRQ_MASK    [IRQ_EVENTS_NUM-1:0]; 
    always_comb irq_events                          = REGMAP.RW.IRQ_EVENT   [IRQ_EVENTS_NUM-1:0];

    always_comb irq_events_bus[IRQ_TX_DONE        ] = tx_done;
    always_comb irq_events_bus[IRQ_TX_STARTED     ] = tx_started;
    always_comb irq_events_bus[IRQ_RX_DONE        ] = rx_done;
    always_comb irq_events_bus[IRQ_RX_STARTED     ] = rx_started;
    always_comb irq_events_bus[IRQ_DFIFO_ERROR    ] = dfifo_parity_error;
    always_comb irq_events_bus[IRQ_DFIFO_EMPTY    ] = dfifo_empty;
    always_comb irq_events_bus[IRQ_UFIFO_ERROR    ] = ufifo_parity_error;
    always_comb irq_events_bus[IRQ_UFIFO_FULL     ] = ufifo_full;
    always_comb irq_events_bus[IRQ_UART_PARITY_ERR] = rx_parity_error;
    always_comb irq_events_bus[IRQ_UART_BAD_FRAME ] = rx_bad_frame;

    /* --------------------- */

    uart_edge_detector #(

        .BUS_WIDTH              ( IRQ_EVENTS_NUM            )

    ) irq_events_edge_detector (

        .i_clk                  ( i_apb_pclk                ),
        .i_nrst                 ( i_apb_presetn             ),

        .i_data                 ( irq_events_bus            ),

        .o_posedge              ( irq_events_bus_edged      ),
        .o_negedge              ( /* not used */            ),
        .o_both_edges           ( /* not used */            ));

    /* --------------------- */

    uart_irq_gen #(
        
        .EVENTS_NUM             ( IRQ_EVENTS_NUM            )

    ) irq_gen_inst  (

        .i_clk                  ( i_apb_pclk                ),
        .i_nrst                 ( i_apb_presetn             ),

        .i_events_enable        ( irq_events_enable         ),
        .i_events_mask          ( irq_events_mask           ),
        .i_events_disable       ( irq_events                ),
        .i_events_itself        ( irq_events_bus_edged      ),

        .o_irq_bus              ( internal_irqs             ),
        .o_events_stats         ( irq_events_stats          ));

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
        .i_tx_status            ( tx_status                 ),

        .i_ufifo_full           ( ufifo_full                ),
        .i_ufifo_empty          ( ufifo_empty               ),
        .i_ufifo_used           ( ufifo_used                ),
        .i_ufifo_output         ( ufifo_data_out            ),
        
        .i_dfifo_full           ( dfifo_full                ),
        .i_dfifo_empty          ( dfifo_empty               ),
        .i_dfifo_used           ( dfifo_used                ),

        .i_irq_stats            ( irq_events_stats          ),

    //| Control Signals
        .o_dfifo_input          ( dfifo_data_in             ),
        .o_dfifo_write_req      ( dfifo_write_req           ),
        .o_ufifo_read_req       ( ufifo_read_req            ),

    //| Registers
        .REGMAP_OUT             ( REGMAP                    ));


endmodule : uart_top

`endif    /*__KENEZOER_UART_TOP_DEFINED__*/