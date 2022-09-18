/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_ndff.sv
 *  Purpose:  UART NDFF Bus CDC synchronizer
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


`ifndef     __KENEZOER_UART_NDFF_DEFINED__
`define     __KENEZOER_UART_NDFF_DEFINED__

module uart_ndff_bus#(
    parameter                           CDC_STAGES      = 2,
    parameter                           BUS_WIDTH       = 32,
)(
    input                               i_clk,
    input                               i_nrst,

    input           [BUS_WIDTH-1:0]     i_data_in,
    output          [BUS_WIDTH-1:0]     o_data_out
);

    /* --------------------------------------------------------------------------------------------------------- */
    logic   [CDC_STAGES-1:0]    [BUS_WIDTH-1:0]     cdc_bus;


    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        cdc_bus     <= '0;
    else
        cdc_bus     <= {cdc_bus[CDC_STAGES-2:0], i_data_in};

    always_comb o_data_out  = cdc_bus[CDC_STAGES-1];
    
endmodule : uart_rx


`endif    /*__KENEZOER_UART_NDFF_DEFINED__*/