/*
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: tb_uart.sv
 *  Purpose:  YAUART testbench
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


`ifndef         __TB_UART_DEFINED__
`define         __TB_UART_DEFINED__

module tb_uart;

    import  tb_uart_pkg::*;
    import  uart_pkg::*;

    logic       clk     = '0;
    logic       rstn    = '0;

    logic       tx, rts;

    int         error_counter = 0;

    logic   [APB_BUS_DW-1:0]    write_data;
    logic   [APB_BUS_DW-1:0]    read_data;

    uart_control_regs_t uart_settings = '0;

    always#10ns clk     = ~clk;

    initial @(posedge clk) 
                rstn    = '1;

    /* -------------------------------------------------- */

    APB3_IF #(
        .APB3_AW                    ( APB_BUS_AW    ),
        .APB3_DW                    ( APB_BUS_DW    )
    ) APB (
        .PCLK                       ( clk           ),
        .PRESETN                    ( rstn          ));

    /* -------------------------------------------------- */

    initial begin : initial_apb_bus
        APB.PADDR   = '0;
        APB.PWDATA  = '0;
        APB.PWRITE  = '0;
        APB.PSEL    = '0;
        APB.PENABLE = '0;
    end

    /* -------------------------------------------------- */

    `include "tasks.sv"

    /* -------------------------------------------------- */

    initial begin : tests

        /* --------------------------*/
        // `include "tests/regmap_test.sv"     //| Register map test
        `include "tests/rx_tx_test.sv"      //| RX/TX Test

        /* --------------------------*/
        $finish;

    end

    /* -------------------------------------------------- */

    uart_top #(

        .APB_ADDR_WIDTH             ( APB_BUS_AW    ),
        .APB_DATA_WIDTH             ( APB_BUS_DW    ),
        .FIFO_PARITY_CHECK_EN       ( 1             )

    ) UART_INST (

    //| APB3 Interface Signals
        .i_apb_pclk                 ( APB.PCLK      ),
        .i_apb_presetn              ( APB.PRESETN   ),

        .i_apb_paddr                ( APB.PADDR     ),
        .i_apb_pwdata               ( APB.PWDATA    ),
        .i_apb_pwrite               ( APB.PWRITE    ),
        .i_apb_psel                 ( APB.PSEL      ),
        .i_apb_penable              ( APB.PENABLE   ),
    
        .o_apb_pslverr              ( APB.PSLVERR   ),
        .o_apb_prdata               ( APB.PRDATA    ),
        .o_apb_pready               ( APB.PREADY    ),

    //| UART Signals
        .o_tx                       ( tx            ),  //| ring connection to test uart by itself
        .i_rx                       ( tx            ),

        .o_rts                      ( rts           ),
        .i_cts                      ( rts           ),

    //| Misc
        .o_irq                      ( uart_irq      ));


endmodule : tb_uart

`endif        /* __TB_UART_DEFINED__ */