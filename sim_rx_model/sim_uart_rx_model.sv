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

`ifndef     __KENEZOER_UART_SIM_RX_DEFINED__
`define     __KENEZOER_UART_SIM_RX_DEFINED__

module sim_uart_rx_model#(

    parameter           CLK_FREQUENCY_HZ    =   1000,
    parameter           BAUDRATE            =   115200

)(
    input               i_clk,
    input               i_nrst,
    input               i_rx
);


endmodule : sim_uart_rx_model

`endif    /* __KENEZOER_UART_SIM_RX_DEFINED__ */
