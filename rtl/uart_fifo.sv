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
    parameter   bit                     FIFO_PARITY_ENABLE          = 1,
    parameter                           FIFO_AW                     = 2,
    parameter                           FIFO_DW                     = 8
)(
    //| Inputs
    input                               i_clk,
    input                               i_nrst,
    input                               i_rd_req,
    input                               i_wr_req,
    input           [FIFO_DW-1:0]       i_data_in,

    //| Outputs
    output  logic   [FIFO_DW-1:0]       o_data_out,
    output  logic   [FIFO_AW-1:0]       o_free,
    output  logic   [FIFO_AW-1:0]       o_used,
    output  logic                       o_valid,
    output  logic                       o_full,
    output  logic                       o_almost_full,
    output  logic                       o_empty,
    output  logic                       o_almost_empty,
    output  logic                       o_overflow,
    output  logic                       o_underflow,
    output  logic                       o_parity_error
);

    localparam  DW          = FIFO_DW + FIFO_PARITY_ENABLE;     //| Summary width of FIFO word
    localparam  FIFO_DEPTH  = 2 ** AW;

    //| Check correctness of parameter values
    generate
        if(DW < 1) $error("%s: %m : DW must be > 0. \n", KENEZOER_BAD_PARAM);
        if(AW < 1) $error("%s: %m : AW must be > 0. \n", KENEZOER_BAD_PARAM);
    endgenerate

    //|---------------------------
    //| Local Variables
    //|---------------------------

    logic   [FIFO_AW-1:0]   [DW-1:0]    memory_array;
    logic                               valid_read,     valid_write;
    logic   [DW-1:0]                    data_packet_in, data_packet_out;
    logic   [FIFO_AW-1:0]               read_ptr,       write_ptr;
    logic   [FIFO_AW:0]                 used_words,     free_words;


    /* ------------------------------------------------------------ */
    //| overflow/underflow protection

    always_comb valid_read  = i_rd_req && !o_empty;
    always_comb valid_write = i_wr_req && !o_full;

    /* ------------------------------------------------------------ */
    //| output flags

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst) begin
        o_overflow  <= '0;
        o_underflow <= '0;
    end else begin
        o_overflow  <= i_write_req && o_full;
        o_underflow <= i_read_req  && o_empty;
    end

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        o_valid     <= '0;
    else if(valid_read)
        o_valid     <= '1;
    else
        o_valid     <= '0;

    /* ------------------------------------------------------------ */
    //| Counters Logic

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst) begin
        read_ptr        <= '0;
        write_ptr       <= '0;
    end else begin

        if(valid_read)
            read_ptr    <= read_ptr + 1'b1;

        if(valid_write)
            write_ptr   <= write_ptr + 1'b1;

    end

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        used_words        <= '0;
    else begin
        if(valid_read && valid_write)
            used_words    <= used_words;
        else if(valid_write)
            used_words    <= used_words + 1'b1;
        else if(valid_read)
            used_words    <= used_words - 1'b1;
    end

    always_comb free_words  = FIFO_DEPTH - used_words;

    always_comb o_used          = used_words[FIFO_AW-1:0];
    always_comb o_free          = free_words[FIFO_AW-1:0];
    always_comb o_full          = (used_words ==  FIFO_DEPTH);
    always_comb o_almost_full   = (used_words >= (FIFO_DEPTH -1'b1));
    always_comb o_empty         = (used_words == '0);
    always_comb o_almost_empty  = (used_words <= 'd1);

    /* ------------------------------------------------------------ */
    //| I/O Data bus former

    always_comb begin
        if(FIFO_PARITY_ENABLE)
            data_packet_in  = {^i_data_in, data_in};
        else
            data_packet_in  = data_in;
    end

    always_comb o_parity_error  = (FIFO_PARITY_ENABLE) ? ^data_packet_out[DW-2:0] ^ data_packet_out[DW-1] : '0;
    always_comb o_data_out      = data_packet_out[FIFO_DW-1:0];

    /* ------------------------------------------------------------ */
    //| Memory Control

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        memory_array            <= '0;
    else if(valid_write)
        memory_array[write_ptr] <= data_packet_in;

    always_ff@(posedeg i_clk or negedge i_nrst)
    if(!i_nrst)
        data_packet_out     <= '0;
    else if(valid_read)
        data_packet_out     <= memory_array[read_ptr];

    /* ------------------------------------------------------------ */
    //| Assert Zone

    // pragma translate_off
    // pragma synthesis_off

    property x_propagation_output;
        @(posedge i_clk)
        disable iff(!i_nrst)
        (valid_read) |-> ##1 !($isunknown(fifo_read_do));
    endproperty

    property underflow_assrt;
        @(posedge i_clk)
        disable iff(!i_nrst)
        (valid_read) |-> ##1 !(o_underflow);
    endproperty

    property overflow_assrt;
        @(posedge i_clk)
        disable iff(!i_nrst)
        (valid_write) |-> ##1 !(o_overflow);
    endproperty

    fifo_overflow_assrt: assert property (overflow_assrt)
        else $warning("%s %m : FIFO OVERFLOW! \n", KENEZOER_WARNING);

    fifo_underflow_assrt: assert property (underflow_assrt)
        else $warning("%s %m : FIFO UNDERFLOW! \n", KENEZOER_WARNING);

    fifo_x_propagation_output: assert property (x_propagation_output)
        else $error("%s %m : 'X data appeared! \n", KENEZOER_ERROR);

    // pragma synthesis_on
    // pragma translate_on

endmodule : uart_fifo


`endif    /*__KENEZOER_UART_FIFO_DEFINED__*/