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

    //| UART Signals
    output  logic                               o_tx,
    input                                       i_rx,

    //| Misc
    output  logic                               o_irq

    

);


endmodule : uart_top


`endif    /*__KENEZOER_UART_TOP_DEFINED__*/