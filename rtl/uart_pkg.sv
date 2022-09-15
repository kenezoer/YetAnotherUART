/* 
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: uart_pkg.sv
 *  Purpose:  UART Package
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

package uart_pkg;

    localparam      IP_VERSION_MAJOR        = 1,            //| Major Version of IP Module
                    IP_VERSION_MINOR        = 0;            //| Minor Version of IP Module

    localparam      APB_ADDR_VALUABLE_WIDTH = 12;           //| 4K Range slave access

    localparam      DFIFO_DEPTH             = 8;            //| Downstream FIFO depth
    localparam      UFIFO_DEPTH             = 8;            //| Upstream FIFO depth


    /* ------------------------------------------------------------------------------ */

        typedef struct packed {

        /* [31:9]   */  logic   [22:0]  reserved;           /* [Read Only] reserved fields                  */
        /* [8]      */  logic           uart_bad_frame;     /* [Read Only] UART bad frame given             */
        /* [7]      */  logic           uart_parity_err;    /* [Read Only] UART parity error (in frame)     */
        
        /* [6]      */  logic           ufifo_overflow;     /* [Read Only] Upstream FIFO overflow           */
        /* [5]      */  logic           ufifo_not_empty;    /* [Read Only] Upstream FIFO not empty          */
        /* [4]      */  logic           ufifo_error;        /* [Read Only] Upstream FIFO parity error       */

        /* [3]      */  logic           dfifo_empty;        /* [Read Only] Downstream FIFO Empty            */
        /* [2]      */  logic           dfifo_error;        /* [Read Only] Downstream FIFO parity error     */

        /* [1]      */  logic           rx_done;            /* [Read Only] Receiving done (1 word)          */
        /* [0]      */  logic           tx_done;            /* [Read Only] Tranceiving done (1 word)        */

        } uart_irq_regs_t;

    /* ------------------------------------------------------------------------------ */

        typedef struct packed {

        /* [31:27]  */  logic           reserved_2;         /* [Read Only]  Reserved Fields                 */
        /* [26]     */  logic           rx_status;          /* [Read Only]  Receiver Status: [0] - IDLE     */
        /* [25]     */  logic           ufifo_full;         /* [Read Only]  Upstream FIFO full flag         */
        /* [24]     */  logic           ufifo_empty;        /* [Read Only]  Upstream FIFO empty flag        */
        /* [23:16]  */  logic   [7:0]   ufifo_used;         /* [Read Only]  Upstream FIFO used words        */

        /* [15:11]  */  logic           reserved_1;         /* [Read Only]  Reserved Fields                 */
        /* [10]     */  logic           tx_status;          /* [Read Only]  Tranceiver status: [0] - IDLE   */
        /* [9]      */  logic           dfifo_full;         /* [Read Only]  Downstream FIFO full flag       */
        /* [8]      */  logic           dfifo_empty;        /* [Read Only]  Downstream FIFO empty flag      */
        /* [7:0]    */  logic   [7:0]   dfifo_used;         /* [Read Only]  Downstream FIFO used words      */

        } uart_stats_t;

    /* ------------------------------------------------------------------------------ */

        typedef struct packed {
        /* [31]     */  logic           parity_check_en;    /* [Read Only]  FIFO Parity Check Enable        */
        /* [30:24]  */  logic   [6:0]   reserved;           /* [Read Only]  Reserved                        */
        /* [23:16]  */  logic   [7:0]   ufifo_depth;        /* [Read Only]  Upstream FIFO Depth             */
        /* [15:8]   */  logic   [7:0]   dfifo_depth;        /* [Read Only]  Downstream FIFO Depth           */
        /* [7:0]    */  logic   [7:0]   ip_version;         /* [Read Only]  IP Version                      */
        } uart_hwinfo_t;

    /* ------------------------------------------------------------------------------ */

        typedef struct packed {
        /* [31:8]   */  logic   [23:0]  reserved;           /* [Read Only]  Downstream FIFO input           */
        /* [7:0]    */  logic   [7:0]   ufifo_output;       /* [Read Only]  Downstream FIFO input           */
        } uart_ufifo_t;

    /* ------------------------------------------------------------------------------ */

        typedef struct packed {
        /* [31:8]   */  logic   [23:0]  reserved;           /* [Read Only]  Downstream FIFO input           */
        /* [7:0]    */  logic   [7:0]   dfifo_input;        /* [Read/Write] Downstream FIFO input           */
        } uart_ufifo_t;

    /* ------------------------------------------------------------------------------ */
                
        typedef struct packed {

        } uart_regmap_t;

    /* ------------------------------------------------------------------------------ */


endpackage : uart_pkg


`endif    /*__KENEZOER_UART_RX_DEFINED__*/