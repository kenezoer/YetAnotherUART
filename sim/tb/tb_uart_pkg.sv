/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: tb_uart_pkg.sv
 *  Purpose:  Package with Tasks for YAUART testbench
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


`ifndef         __TB_UART_PKG_DEFINED__
`define         __TB_UART_PKG_DEFINED__

package tb_uart_pkg;

    localparam  APB_BUS_AW  = 32;
    localparam  APB_BUS_DW  = 32;

    /* ------------------------------ */

    task apb_read(
        input           [APB_BUS_AW - 1 : 0]    addr,
        output  logic   [APB_BUS_DW - 1 : 0]    data
    );


    endtask : apb_read

    /* ------------------------------ */

    task apb_write(
        input   [APB_BUS_AW - 1 : 0]    addr,
        input   [APB_BUS_DW - 1 : 0]    data  
    );


    endtask : apb_write

    /* ------------------------------ */

    task    SendChar(
        input   [7:0]   char
    );


    endtask : SendChar

    /* ------------------------------ */

    task    GetChar();

    endtask : GetChar

    /* ------------------------------ */

endpackage : tb_uart_pkg

`endif       /* __TB_UART_PKG_DEFINED__ */