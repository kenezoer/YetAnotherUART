/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_irq_gen.sv
 *  Purpose:  UART IRQ Generator
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


`ifndef     __KENEZOER_UART_IRQ_GEN_DEFINED__
`define     __KENEZOER_UART_IRQ_GEN_DEFINED__

module uart_irq_gen
//|------- Required Packages ----------
    import  uart_pkg::*;
//|------------------------------------
#(
    parameter                               EVENTS_NUM  = 32
)(
    input                                   i_clk,
    input                                   i_nrst,

    input           [EVENTS_NUM-1:0]        i_events_enable,
    input           [EVENTS_NUM-1:0]        i_events_mask,
    input           [EVENTS_NUM-1:0]        i_events_disable,
    input           [EVENTS_NUM-1:0]        i_events_itself,

    output  logic   [EVENTS_NUM-1:0]        o_irq_bus,
    output  logic   [EVENTS_NUM-1:0]        o_events_stats
);

    /* ------------------------------------------------------------ */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        o_events_stats   <= '0;
    else for(int i = 0; i < EVENTS_NUM; i++) begin

        if(i_events_disable[i])
            o_events_stats[i]   <= '0;
        else
            o_events_stats[i]   <= i_events_enable[i] || i_events_itself[i];

    end

    /* ------------------------------------------------------------ */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        o_irq_bust      <= '0;
    else for(int i = 0; i < EVENTS_NUM; i++) begin

        if(i_events_mask[i])
            o_irq_bus[i]   <= '0;   //| Used for immediate IRQ de-assertion
        else
            o_irq_bus[i]   <= o_events_stats[i];

    end


endmodule : uart_irq_gen


`endif    /*__KENEZOER_UART_IRQ_GEN_DEFINED__*/