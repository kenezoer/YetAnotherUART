/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_fifo_fwft.sv
 *  Purpose:  Look-Ahead (FWFT) wrapper for Single Clock FIFO
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



`ifndef     __KENEZOER_UART_FIFO_FWFT_DEFINED__
`define     __KENEZOER_UART_FIFO_FWFT_DEFINED__

module uart_fifo_fwft
//|------- Required Packages ----------
    import uart_pkg::*;
//|------------------------------------
#(
    parameter   bit                     FIFO_PARITY_ENABLE          = 1,
    parameter                           FIFO_AW                     = 2,
    parameter                           FIFO_DW                     = 8,

    //| Be careful, localparams in 'headers' allowed only in modern simulators (e.g. xcelium20.09)
    localparam                          FIFO_DEPTH                  = 2 ** FIFO_AW,
    localparam                          FIFO_DEPTH_FWFT             = FIFO_DEPTH + 3,   //| actual size bcuz of fwft wrapper
    localparam                          USED_WIDTH                  = $clog2(FIFO_DEPTH_FWFT)
)(
    //| Inputs
    input                               i_clk,
    input                               i_nrst,
    input                               i_rd_req,
    input                               i_wr_req,
    input           [FIFO_DW-1:0]       i_data_in,

    //| Outputs
    output  logic   [FIFO_DW-1:0]       o_data_out,
    output  logic   [USED_WIDTH-1:0]    o_free,
    output  logic   [USED_WIDTH-1:0]    o_used,
    output  logic                       o_valid,
    output  logic                       o_full,
    output  logic                       o_almost_full,
    output  logic                       o_empty,
    output  logic                       o_almost_empty,
    output  logic                       o_overflow,
    output  logic                       o_underflow,
    output  logic                       o_parity_error
);

    /* -------------------------------------------------------------------------------------------------- */

    logic                               std_read_req;
    logic                               std_write_req;
    logic   [FIFO_DW-1:0]               std_data_in;
    logic   [FIFO_DW-1:0]               std_data_out;
    logic   [FIFO_AW-1:0]               std_used;
    logic   [FIFO_AW:0]                 std_used_extended;
    logic                               std_full;
    logic                               std_empty;
    logic                               std_parity_error;

    always_comb std_used_extended   = {std_full, std_used};
    always_comb std_write_req       = i_wr_req;
    always_comb std_data_in         = i_data_in;

    /* -------------------------------------------------------------------------------------------------- */
    
    /*
     * _________________________________________________
     *
     * FWFT adapter from https://github.com/olofk/fifo
     * _________________________________________________
     *
     */
    
    always_comb will_update_dout   = (middle_valid || std_fifo_valid)  &&  (i_rd_req || ~o_valid);
    always_comb will_update_middle =  std_fifo_valid    &&  (middle_valid == will_update_dout);
    always_comb std_read_req       = (~std_empty)       && ~(middle_valid && o_valid && std_fifo_valid);
    
    always @(posedge i_clk or negedge i_nrst)
    if (~i_nrst) begin
        std_fifo_valid          <= '0;
        
        middle_valid            <= '0;
        middle_dout             <= '0;
        middle_parity_error     <= '0;

        o_valid                 <= '0;
        o_empty                 <= '1;
        o_data_out              <= '0;
        o_parity_error          <= '0;
    end else begin

        if(std_read_req)
            std_fifo_valid      <= '1;
        else if(will_update_middle || will_update_dout)
            std_fifo_valid      <= '0;
        
        if(will_update_middle) begin
            middle_dout         <= std_data_out;
            middle_parity_error <= std_parity_error;
        end
        
        if(will_update_dout) begin
            o_data_out          <= middle_valid ? middle_dout         : std_data_out;
            o_parity_error      <= middle_valid ? middle_parity_error : std_parity_error;
        end
            
        if(will_update_middle)
            middle_valid        <= '1;
        else if(will_update_dout)
            middle_valid        <= '0;
            
        if(will_update_dout) begin
            o_valid             <= '1;
            o_empty             <= '0;
        end else if(i_rd_req) begin
            o_valid             <= '0;
            o_empty             <= '1;
        end

    end

    /* -------------------------------------------------------------------------------------------------- */

    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst)
        fwft_used   <= '0;
    else begin

        case({std_read_req, (i_rd_req && o_valid)})

            2'b01:      fwft_used   <= fwft_used - 1'b1;
            2'b10:      fwft_used   <= fwft_used + 1'b1;
            default:    fwft_used   <= fwft_used;

        endcase

    end

    always_comb o_used          = fwft_used + std_used_extended;
    always_comb o_almost_full   = (o_used >= (FIFO_DEPTH_FWFT - 1'b1));
    always_comb o_full          = std_full;
    always_comb o_almost_empty  = (o_used <= 'd1);
    
    /* -------------------------------------------------------------------------------------------------- */
    
    always_ff@(posedge i_clk or negedge i_nrst)
    if(!i_nrst) begin
        o_overflow  <= '0;
        o_underflow <= '0;
    end else begin
        o_overflow  <= i_wr_req && o_full;
        o_underflow <= i_rd_req  && o_empty;
    end

    /* ------------------------------------------ FIFO INST --------------------------------------------- */

    uart_fifo #(
        .FIFO_PARITY_ENABLE         ( FIFO_PARITY_ENABLE    ),
        .FIFO_AW                    ( FIFO_AW               ),
        .FIFO_DW                    ( FIFO_DW               )
    ) std_fifo_inst (
        
        //| Inputs
        .i_clk                      ( i_clk                 ),
        .i_nrst                     ( i_nrst                ),
        .i_rd_req                   ( std_read_req          ),
        .i_wr_req                   ( std_write_req         ),
        .i_data_in                  ( std_data_in           ),

        //| Outputs
        .o_data_out                 ( std_data_out          ),
        .o_free                     (  /* not used */       ),
        .o_used                     ( std_used              ),
        .o_valid                    (  /* not used */       ),
        .o_full                     ( std_full              ),
        .o_almost_full              ( std_empty             ),
        .o_empty                    (  /* not used */       ),
        .o_almost_empty             (  /* not used */       ),
        .o_overflow                 (  /* not used */       ),
        .o_underflow                (  /* not used */       ),
        .o_parity_error             ( std_parity_error      ));


endmodule : uart_fifo_fwft

`endif    /*__KENEZOER_UART_FIFO_FWFT_DEFINED__*/