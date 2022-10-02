/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_tx.sv
 *  Purpose:  UART tranceiver Module
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


`ifndef     __KENEZOER_UART_TX_DEFINED__
`define     __KENEZOER_UART_TX_DEFINED__

module uart_tx
//|------- Required Packages ----------
    import uart_pkg::*;
//|------------------------------------
(
    input                           i_clk,
    input                           i_nrst,

    input                           i_valid,
    output  logic                   o_ready,

    input                           i_tx,
    input                           i_cts,
    input                           i_hw_flow_control_enable,

    input           [31:0]          i_bit_length,
    input                           i_msb_first,
    input           [7:0]           i_data

);


    /* ------------------------------------ VARIABLES ---------------------------------------------------------- */

    logic   [3:0]   bit_select;
    logic           cts;

    enum logic [2:0]    {
        IDLE                = 3'd0,
        START               = 3'd1,
        SEND_DATA           = 3'd2,
        SEND_PARITY         = 3'd3,
        SEND_STOP_BIT       = 3'd4,
        SEND_STOP_BIT_2     = 3'd5,
        FINISH              = 3'd6
    } tx_state, tx_state_next;

    /* ---------------------------------- Internal Logic ------------------------------------------------------- */

    always_comb cts     = i_hw_flow_control_enable ? '1 : i_cts;
    always_comb o_ready = cts && (tx_state == IDLE);

    /* --------------------------------------- FSM ------------------------------------------------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        tx_state    <= IDLE;
    else
        tx_state    <= tx_state_next;

    always_comb begin

        tx_state_next   = IDLE;

    end

endmodule : uart_tx


`endif    /*__KENEZOER_UART_TX_DEFINED__*/