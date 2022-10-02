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
    input                           i_msb_first,
    input           [1:0]           i_stop_bit_mode,
    input                           i_fifo_full,

    output  logic                   o_rx_done,
    output  logic                   o_rx_started,
    output  logic                   o_rx_frame_error,
    output  logic                   o_rx_parity_error,
    output  logic   [8:0]           o_rx_word,                  //| 8 bits + parity bit

    input                           i_rx,
    output  logic                   o_rts
);

    /* --------------------------------------------------------------------------------------------------------- */

    logic   [31:0]                  bit_length_counter;
    logic   [3:0]                   bit_counter;
    logic                           bit_delay_done;
    logic   [31:0]                  bit_delay_counter;
    logic                           stop_2nd_bit_presents;
    logic                           rts;

    /* --------------------------------------- FSM ------------------------------------------------------------- */

    enum logic [2:0]    {
        IDLE                = 3'd0,
        START               = 3'd1,
        GET_DATA            = 3'd2,
        GET_PARITY          = 3'd3,
        GET_STOP_BIT        = 3'd4,
        GET_STOP_BIT_2      = 3'd5,
        FINISH              = 3'd6
    } rx_state, rx_state_next;

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        rx_state    <= IDLE;
    else
        rx_state    <= rx_state_next;

    always_comb begin

        case(rx_state)

            /* ------------------------------ */

            default /* IDLE, FINISH */: begin

                if(!i_rx)
                    rx_state_next   = START;
                else
                    rx_state_next   = IDLE;

            end

            /* ------------------------------ */

            START: begin

                if(bit_delay_done)
                    rx_state_next   = GET_DATA;
                else
                    rx_state_next   = START;

            end

            /* ------------------------------ */

            GET_DATA:  begin

                if(bit_counter >= 4'd7 && bit_delay_done)
                    rx_state_next   = GET_PARITY;
                else
                    rx_state_next   = GET_DATA;

            end

            /* ------------------------------ */

            GET_PARITY:  begin

                if(bit_delay_done)
                    rx_state_next   = GET_STOP_BIT;
                else
                    rx_state_next   = GET_PARITY;

            end

            /* ------------------------------ */

            GET_STOP_BIT:  begin

                if(bit_delay_done) begin
                    if(stop_2nd_bit_presents)
                        rx_state_next   = GET_STOP_BIT_2;
                    else
                        rx_state_next   = FINISH;
                end else
                    rx_state_next       = GET_STOP_BIT;

            end

            /* ------------------------------ */

            GET_STOP_BIT_2:  begin

                if(bit_delay_done)
                    rx_state_next   = IDLE;
                else
                    rx_state_next   = GET_STOP_BIT_2;

            end

            /* ------------------------------ */

        endcase

    end



    /* --------------------------------------- RX Logic ----------------------------------------------------------- */

    task    bit_delay_process(
        input       [31:0]  delay_value
    );

        if(bit_delay_counter <= 32'd1)
            bit_delay_counter   <= delay_value;
        else
            bit_delay_counter   <= bit_counter - 1'b1;

    endtask : bit_delay_process


    always_comb bit_delay_done = (bit_delay_counter == 32'd1);


    // always_ff@(posedge i_clk or negedge i_nrst)
    // if(!i_nrst)
    //     bit_counter <= '0;
    // else if(rx_state == GET_DATA)
    //     bit_counter <= bit_counter + bit_delay_done;

    /* ------------------------------------------------------------------------------------------------------------ */

    always_ff@(posedge i_clk or negedge i_nrst) 
    if(!i_nrst) begin
        bit_delay_counter   <= '0;
    end else begin

        case(rx_state)

            /* ------------------------------ */

            default /* IDLE, FINISH */: begin
                bit_delay_counter   <= '0;
            end

            /* ------------------------------ */

            GET_DATA, GET_PARITY:  begin
                bit_delay_process(i_bit_length);
            end

            /* ------------------------------ */

            GET_STOP_BIT:  begin

            end

            /* ------------------------------ */

            GET_STOP_BIT_2:  begin

            end

            /* ------------------------------ */

        endcase

    end

    /* ------------------------------------------------------------------------------------------------------------ */

    always_comb o_rx_done           = (rx_state == FINISH);
    always_comb o_rx_started        = (rx_state == START);
    always_comb o_rx_parity_error   = (rx_state == FINISH) && (^o_rx_word[7:0] != o_rx_word[8]);
    always_comb o_rts               = (rx_state == IDLE)   && (i_hw_flow_control_enable ? ~i_fifo_full : '1);


    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        bit_counter <= '0;
    else begin
        if(rx_state inside {IDLE, FINISH, START})
            bit_counter <= i_msb_first ? 4'd8 : '0;
        else if(i_msb_first)
            bit_counter <= bit_counter  - bit_delay_done;
        else
            bit_counter <= bit_counter  + bit_delay_done;
    end


    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        o_rx_word                   <= '0;
    else begin
        if(rx_state == START)
            o_rx_word               <= '0;
        else if(bit_delay_done)
            o_rx_word[bit_counter]  <= i_rx;
    end

    /* ------------------------------------------------------------------------------------------------------------ */
    
endmodule : uart_rx


`endif    /*__KENEZOER_UART_RX_DEFINED__*/