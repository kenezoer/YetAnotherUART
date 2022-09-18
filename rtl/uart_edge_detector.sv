/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_edge_detector.sv
 *  Purpose:  Simple edge detector/extractor
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


`ifndef     __KENEZOER_UART_REGMAP_DEFINED__
`define     __KENEZOER_UART_REGMAP_DEFINED__

module uart_edge_detector#(
    parameter                               BUS_WIDTH   = 32
)(
    input                                   i_clk,
    input                                   i_nrst,

    input           [BUS_WIDTH-1:0]         i_data,

    output          [BUS_WIDTH-1:0]         o_posedge,
    output          [BUS_WIDTH-1:0]         o_negedge,
    output          [BUS_WIDTH-1:0]         o_both_edges

);

    logic   [BUS_WIDTH-1:0]     delayed_data;

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        delayed_data    <= '0;
    else
        delayed_data    <= i_data;

    /* ---------------------------- posedge extractor ------------------------ */

    always_ff@(posedge i_clk or negedge i_nrst) 
    if(!i_nrst)
        o_posedge           <= '0;
    else foreach(o_posedge[i])
        o_posedge[i]        <= !delayed_data[i] && i_data[i];

    /* ---------------------------- negedge extractor ------------------------ */

    always_ff@(posedge i_clk or negedge i_nrst) 
    if(!i_nrst)
        o_negedge           <= '0;
    else foreach(o_negedge[i])
        o_negedge[i]        <= delayed_data[i] && !i_data[i];

    /* -------------------------- both edges extractor ----------------------- */

    always_ff@(posedge i_clk or negedge i_nrst) 
    if(!i_nrst)
        o_both_edges        <= '0;
    else foreach(o_both_edges[i])
        o_both_edges[i]     <= delayed_data[i] ^ i_data[i];

endmodule : uart_edge_detector