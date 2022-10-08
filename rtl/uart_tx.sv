/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_tx.sv
 *  Purpose:  UART tranceiver Module
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


`ifndef     __KENEZOER_UART_TX_DEFINED__
`define     __KENEZOER_UART_TX_DEFINED__

module uart_tx
//|------- Required Packages ----------
    import uart_pkg::*;
//|------------------------------------
(
    input                                       i_clk,
    input                                       i_nrst,

    input                                       i_valid,
    output  logic                               o_ready,

    output  logic                               o_tx,
    output  logic                               o_tx_status,

    input                                       i_fifo_empty,
    input                                       i_cts,
    input                                       i_hw_flow_control_enable,
    input                                       i_parity_enable,
    input   stop_bit_mode_t                     i_stop_bit_mode,
    input                       [1:0]           i_stop_bit_value,

    input                       [31:0]          i_bit_length,
    input                                       i_msb_first,
    input                       [8:0]           i_data

);


    /* ------------------------------------ VARIABLES ---------------------------------------------------------- */

    logic           [3:0]       bit_select;
    logic                       cts;
    logic           [7:0]       data_to_send;
    logic           [11:0]      data_packet;
    logic                       period_done;
    logic                       half_period_done;
    logic           [31:0]      bit_period_buf;
    logic           [31:0]      bit_period_counter;
    stop_bit_mode_t             stop_bit_mode;

    enum logic [2:0]    {
        IDLE                = 3'd0,
        START               = 3'd1,
        SEND_DATA           = 3'd2,
        SEND_PARITY         = 3'd3,
        SEND_STOP_BIT       = 3'd4,
        SEND_STOP_BIT_2     = 3'd5,
        FINISH              = 3'd6
    } tx_state, tx_state_next;

    /* ---------------------------------- Internal Logic ------------------------------------------------------- */

    always_comb cts         = i_hw_flow_control_enable ? i_cts : '1;
    always_comb o_ready     = cts && (tx_state == IDLE);
    always_comb o_tx_status = !(tx_state == IDLE);

    /* --------------------------------------- FSM ------------------------------------------------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        tx_state    <= IDLE;
    else
        tx_state    <= tx_state_next;

    always_comb begin

        tx_state_next   = IDLE;

        case(tx_state)

            /* ------------------------------ */

            default /* IDLE, FINISH */: begin

                if(i_valid && o_ready)
                    tx_state_next   = START;
                else
                    tx_state_next   = IDLE;

            end

            /* ------------------------------ */

            START: begin

                if(period_done)
                    tx_state_next   = SEND_DATA;
                else
                    tx_state_next   = START;

            end

            /* ------------------------------ */

            SEND_DATA: begin

                if(period_done && (bit_select >= 4'd8)) begin
                    tx_state_next   = i_parity_enable ? SEND_PARITY : SEND_STOP_BIT;
                end else
                    tx_state_next   = SEND_DATA;

            end

            /* ------------------------------ */

            SEND_PARITY: begin

                if(period_done)
                    tx_state_next   = SEND_STOP_BIT;
                else
                    tx_state_next   = SEND_PARITY;

            end

            /* ------------------------------ */

            SEND_STOP_BIT: begin
                
                if(stop_bit_mode < ONE_AND_HALF_PERIODS) begin

                    if(stop_bit_mode == HALF_PERIOD) begin

                        if(half_period_done)
                            tx_state_next   = FINISH;
                        else
                            tx_state_next   = SEND_STOP_BIT;

                    end else begin 

                        if(period_done)
                            tx_state_next   = FINISH;
                        else
                            tx_state_next   = SEND_STOP_BIT;
                    end

                end else begin

                    if(period_done)
                        tx_state_next   = SEND_STOP_BIT_2;
                    else
                        tx_state_next   = SEND_STOP_BIT;

                end
                    

            end

            /* ------------------------------ */

            SEND_STOP_BIT_2: begin

                    if(stop_bit_mode == ONE_AND_HALF_PERIODS) begin

                        if(half_period_done)
                            tx_state_next   = FINISH;
                        else
                            tx_state_next   = SEND_STOP_BIT_2;

                    end else begin 

                        if(period_done)
                            tx_state_next   = FINISH;
                        else
                            tx_state_next   = SEND_STOP_BIT_2;

                    end

            end

        endcase

    end



    /* --------------------------------------- TX -------------------------------------------------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        bit_period_buf  <= '0;
    else if(tx_state inside {IDLE, FINISH})
        bit_period_buf  <= i_bit_length;

        /* ----------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        bit_period_counter  <= '0;
    else begin

        if(tx_state inside {IDLE, FINISH})
            bit_period_counter  <= '0;
        else if(period_done)
            bit_period_counter  <= '0;
        else
            bit_period_counter  <= bit_period_counter + 1'b1;
        
    end

    always_comb period_done         = (bit_period_counter >=  bit_period_buf);
    always_comb half_period_done    = (bit_period_counter >= (bit_period_buf >> 1) );

        /* ----------------------- */

    always_comb begin
        if(i_msb_first)
            data_to_send    = {i_data[0], i_data[1], i_data[2], i_data[3], i_data[4], i_data[5], i_data[6], i_data[7]};
        else
            data_to_send    =  i_data;
    end

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        data_packet <= '0;
    else if(tx_state inside {IDLE, FINISH}) begin

        data_packet[0]      <= '0;
        data_packet[8:1]    <= data_to_send;
        data_packet[9]      <= i_parity_enable ? i_data[8] : '0;
        data_packet[11:10]  <= i_stop_bit_value;

    end

        /* ----------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        stop_bit_mode   <= HALF_PERIOD;
    else if(tx_state inside {IDLE, FINISH}) begin
        stop_bit_mode   <= i_stop_bit_mode;
    end

        /* ----------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        bit_select  <= '0;
    else begin
        if(tx_state inside {IDLE, FINISH})
            bit_select  <= '0;
        else

            if((stop_bit_mode == HALF_PERIOD) && tx_state == SEND_STOP_BIT)
                bit_select  <= bit_select + half_period_done;
            else if((stop_bit_mode == ONE_AND_HALF_PERIODS) && tx_state == SEND_STOP_BIT_2)
                bit_select  <= bit_select + half_period_done;
            else
                bit_select  <= bit_select + period_done;

    end

        /* ----------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        o_tx    <= '1;
    else begin

        if(tx_state inside {IDLE, FINISH})
            o_tx    <= '1;
        else
            o_tx    <= data_packet[bit_select];

    end

        /* ----------------------- */

endmodule : uart_tx


`endif    /*__KENEZOER_UART_TX_DEFINED__*/