/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_fifo.sv
 *  Purpose:  Single Clock FIFO
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


`ifndef     __KENEZOER_UART_FIFO_DEFINED__
`define     __KENEZOER_UART_FIFO_DEFINED__

module uart_fifo
//|------- Required Packages ----------
    import uart_pkg::*;
//|------------------------------------
#(
    parameter   bit         FIFO_PARITY_ENABLE  = 1,
    parameter               FIFO_DEPTH          = 8,
    parameter               FIFO_WIDTH          = 8
)(
    

);


endmodule : uart_fifo


`endif    /*__KENEZOER_UART_FIFO_DEFINED__*/