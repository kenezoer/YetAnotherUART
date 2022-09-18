/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_rx.sv
 *  Purpose:  UART receiver Module
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


`ifndef     __KENEZOER_UART_RX_DEFINED__
`define     __KENEZOER_UART_RX_DEFINED__

module uart_rx
//|------- Required Packages ----------
    import uart_pkg::*;
//|------------------------------------
(
    input                           i_clk,
    input                           i_nrst,

    input           [31:0]          i_bit_length,
    input                           i_hw_flow_control_enable,
    input                           i_rx,

    output  logic                   o_rx_done,
    output  logic                   o_rx_frame_error,
    output  logic                   o_rx_parity_error,
    output  logic   [8:0]           o_rx_word,                  //| 8 bits + parity bit
);

    /* --------------------------------------------------------------------------------------------------------- */
    logic   [31:0]                  bit_length_counter;
    



endmodule : uart_rx


`endif    /*__KENEZOER_UART_RX_DEFINED__*/