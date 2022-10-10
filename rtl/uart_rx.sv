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
    input   stop_bit_mode_t         i_stop_bit_mode,
    input           [1:0]           i_stop_bit_value,
    input                           i_parity_enable,
    input                           i_fifo_almfull,

    output  logic                   o_rx_done,
    output  logic                   o_rx_started,
    output  logic                   o_rx_status,
    output  logic                   o_rx_frame_error,
    output  logic                   o_rx_parity_error,
    output  logic   [7:0]           o_rx_word,

    input                           i_rx,
    output  logic                   o_rts
);

    /* --------------------------------------------------------------------------------------------------------- */

    enum logic [2:0]    {
        IDLE                = 3'd0,
        START               = 3'd1,
        GET_DATA            = 3'd2,
        GET_PARITY          = 3'd3,
        GET_STOP_BIT        = 3'd4,
        GET_STOP_BIT_2      = 3'd5,
        FINISH              = 3'd6
    } rx_state, rx_state_next;

    logic                           period_done;
    logic                           half_period_done;
    logic               [31:0]      bit_period_counter;
    logic               [31:0]      bit_period_buf;
    logic                           parity_enable_buf;
    logic               [3:0]       bit_select;
    logic               [15:0]      rcvd_data;
    stop_bit_mode_t                 stop_bit_mode;

    /* --------------------------------------- FSM ------------------------------------------------------------- */

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

                if(period_done)
                    rx_state_next   = GET_DATA;
                else
                    rx_state_next   = START;

            end

            /* ------------------------------ */

            GET_DATA:  begin

                if(bit_select >= 4'd8 && period_done)
                    rx_state_next   = parity_enable_buf ? GET_PARITY : GET_STOP_BIT;
                else
                    rx_state_next   = GET_DATA;

            end

            /* ------------------------------ */

            GET_PARITY:  begin

                if(period_done)
                    rx_state_next   = GET_STOP_BIT;
                else
                    rx_state_next   = GET_PARITY;

            end

            /* ------------------------------ */

            GET_STOP_BIT: begin
                
                if(stop_bit_mode < ONE_AND_HALF_PERIODS) begin

                    if(stop_bit_mode == HALF_PERIOD) begin

                        if(half_period_done)
                            rx_state_next   = FINISH;
                        else
                            rx_state_next   = GET_STOP_BIT;

                    end else begin 

                        if(period_done)
                            rx_state_next   = FINISH;
                        else
                            rx_state_next   = GET_STOP_BIT;
                    end

                end else begin

                    if(period_done)
                        rx_state_next   = GET_STOP_BIT_2;
                    else
                        rx_state_next   = GET_STOP_BIT;

                end
                    

            end

            /* ------------------------------ */

            GET_STOP_BIT_2: begin

                    if(stop_bit_mode == ONE_AND_HALF_PERIODS) begin

                        if(half_period_done)
                            rx_state_next   = FINISH;
                        else
                            rx_state_next   = GET_STOP_BIT_2;

                    end else begin 

                        if(period_done)
                            rx_state_next   = FINISH;
                        else
                            rx_state_next   = GET_STOP_BIT_2;

                    end

            end

        endcase

    end



    /* --------------------------------------- RX Logic ----------------------------------------------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        bit_period_buf  <= '0;
    else if(rx_state inside {IDLE, FINISH})
        bit_period_buf  <= i_bit_length;

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        parity_enable_buf   <= '0;
    else if(rx_state inside {IDLE, FINISH})
        parity_enable_buf   <= i_parity_enable;


        /* ----------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        bit_period_counter  <= '0;
    else begin

        if(rx_state inside {IDLE, FINISH})
            bit_period_counter  <= '0;
        else if(period_done)
            bit_period_counter  <= '0;
        else
            bit_period_counter  <= bit_period_counter + 1'b1;
        
    end

    always_comb period_done         = (bit_period_counter >=  bit_period_buf);
    always_comb half_period_done    = (bit_period_counter == ((bit_period_buf >> 1) - 1'b1)) || period_done;


    /* ------------------------------------------------------------------------------------------------------------ */

    /* ------------------------------------------------------------------------------------------------------------ */

    always_comb o_rx_started        =  (rx_state == START);
    always_comb o_rts               =  (rx_state == IDLE)   && (i_hw_flow_control_enable ? ~i_fifo_almfull : '1);
    always_comb o_rx_status         = !(rx_state == IDLE);

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        rcvd_data                   <= '0;
    else begin
        if(rx_state == IDLE)
            rcvd_data               <= '0;
        else if(rx_state == FINISH)
            rcvd_data               <= rcvd_data;
        else if(half_period_done && !period_done)
            rcvd_data[bit_select]   <= i_rx;
    end

    /* ------------------------------------------------------------------------------------------------------------ */

        /* ----------------------- */
    
    always_comb o_rx_parity_error   =  (rx_state == FINISH) && (^rcvd_data[8:1] != rcvd_data[9]) && parity_enable_buf;

        /* ----------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        stop_bit_mode   <= HALF_PERIOD;
    else if(rx_state inside {IDLE, FINISH}) begin
        stop_bit_mode   <= i_stop_bit_mode;
    end

        /* ----------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        o_rx_word       <= '0;
    else if(rx_state == FINISH) begin

        if(i_msb_first)
            o_rx_word   <= { << {rcvd_data[8:1]}}; // Bus reversing via streaming operators
        else
            o_rx_word   <=       rcvd_data[8:1];

    end

        /* ----------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        o_rx_done           <= '0;
    else
        o_rx_done           <= (rx_state == FINISH);

        /* ----------------------- */
    
    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        o_rx_frame_error    <= '0;
    else if(rx_state == FINISH) begin

        casez(i_stop_bit_mode)
            2'b0?: o_rx_frame_error <= (rcvd_data[9  + parity_enable_buf]      ^  i_stop_bit_value[1]);
            2'b1?: o_rx_frame_error <= (rcvd_data[10 + parity_enable_buf -:2]  ^ {i_stop_bit_value[0], i_stop_bit_value[1]});
        endcase

    end else
        o_rx_frame_error    <= '0;

        /* ----------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        bit_select  <= '0;
    else begin
        if(rx_state inside {IDLE, FINISH})
            bit_select  <= '0;
        else

            if((stop_bit_mode == HALF_PERIOD) && rx_state == GET_STOP_BIT)
                bit_select  <= bit_select + half_period_done;
            else if((stop_bit_mode == ONE_AND_HALF_PERIODS) && rx_state == GET_STOP_BIT_2)
                bit_select  <= bit_select + half_period_done;
            else
                bit_select  <= bit_select + period_done;

    end
    
endmodule : uart_rx


`endif    /*__KENEZOER_UART_RX_DEFINED__*/