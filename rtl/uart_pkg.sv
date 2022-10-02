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


`ifndef     __KENEZOER_UART_PKG_DEFINED__
`define     __KENEZOER_UART_PKG_DEFINED__

package uart_pkg;

    /* ------------------------------------------------------------------------------ */
                            /* IRQ REGISTERS */

        typedef struct packed {

        /* [31:10]  */  logic   [23:0]  reserved;           /* [Read Only] reserved fields                  */
        /* [9]      */  logic           uart_bad_frame;     /* [Read Only] UART bad frame given             */
        /* [8]      */  logic           uart_parity_err;    /* [Read Only] UART parity error (in frame)     */
        
        /* [7]      */  logic           ufifo_full;         /* [Read Only] Upstream FIFO Full               */
        /* [6]      */  logic           ufifo_error;        /* [Read Only] Upstream FIFO parity error       */

        /* [5]      */  logic           dfifo_empty;        /* [Read Only] Downstream FIFO Empty            */
        /* [4]      */  logic           dfifo_error;        /* [Read Only] Downstream FIFO parity error     */

        /* [3]      */  logic           rx_done;            /* [Read Only] Receiving done (1 word)          */
        /* [2]      */  logic           rx_started;         /* [Read Only] Receiving started (1 word)       */
        /* [1]      */  logic           tx_done;            /* [Read Only] Tranceiving done (1 word)        */
        /* [0]      */  logic           tx_started;         /* [Read Only] Tranceiving started (1 word)     */

        } uart_irq_regs_t;

    /* ------------------------------------------------------------------------------ */
                            /* STATS REGISTERS */

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
                            /* HARDWARE INFO REGISTERS */

        typedef struct packed {
        /* [31]     */  logic           parity_check_en;    /* [Read Only]  FIFO Parity Check Enable        */
        /* [30:24]  */  logic   [6:0]   reserved;           /* [Read Only]  Reserved                        */
        /* [23:16]  */  logic   [7:0]   ufifo_depth;        /* [Read Only]  Upstream FIFO Depth             */
        /* [15:8]   */  logic   [7:0]   dfifo_depth;        /* [Read Only]  Downstream FIFO Depth           */
        /* [7:0]    */  logic   [7:0]   ip_version;         /* [Read Only]  IP Version                      */
        } uart_hwinfo_t;

    /* ------------------------------------------------------------------------------ */
                            /* CONTROL REGISTERS */

        typedef struct packed {
        /* [31:6]   */  logic   [25:0]  reserved;
        /* [5]      */  logic           ufifo_rst;
        /* [4]      */  logic           dfifo_rst;
        /* [3]      */  logic           msb_first;
        /* [2]      */  logic           hw_flow_ctrl_en;
        /* [1:0]    */  logic   [1:0]   stop_bit_mode;
        } uart_control_regs_t;

    /* ------------------------------------------------------------------------------ */
                            /* UPSTREAM FIFO REGISTERS */

        typedef struct packed {
        /* [31:8]   */  logic   [23:0]  reserved;           /* [Read Only]  Upstream FIFO input             */
        /* [7:0]    */  logic   [7:0]   ufifo_output;       /* [Read Only]  Upstream FIFO input             */
        } uart_ufifo_t;

    /* ------------------------------------------------------------------------------ */
                            /* DOWNSTREAM FIFO REGISTERS */

        typedef struct packed {
        /* [31:8]   */  logic   [23:0]  reserved;           /* [Read Only]  Downstream FIFO input           */
        /* [7:0]    */  logic   [7:0]   dfifo_input;        /* [Read/Write] Downstream FIFO input           */
        } uart_dfifo_t;

    /* ------------------------------------------------------------------------------ */
                            /* RW REGISTERS */
        
        typedef struct packed {
            uart_irq_regs_t                 IRQ_EVENT;          /* [4 dword] */
            uart_irq_regs_t                 IRQ_MASK;           /* [3 dword] */
            uart_irq_regs_t                 IRQ_EN;             /* [2 dword] */
            logic               [31:0]      UART_BIT_LENGTH;    /* [2 dword] */
            uart_control_regs_t             CTRL;               /* [1 dword] */  
            uart_dfifo_t                    DFIFO;              /* [0 dword] */  
        } uart_rw_regs_t;

    /* ------------------------------------------------------------------------------ */
                            /* RO REGISTERS */
        
        typedef struct packed {
            uart_hwinfo_t          HWINFO;                  /* [2 dword] */  
            uart_stats_t           STATS;                   /* [1 dword] */  
            uart_ufifo_t           UFIFO;                   /* [0 dword] */  
        } uart_ro_regs_t;

    /* ------------------------------------------------------------------------------ */
                            /* MAIN REGISTERS */
                
        typedef struct packed {
            uart_ro_regs_t         RO;                      /* [3 dwords] */ 
            uart_rw_regs_t         RW;                      /* [7 dwords] */ 
        } uart_regmap_t;

    /* ------------------------------------------------------------------------------ */

    localparam      UFIFO_OFFSET            = $bits(uart_rw_regs_t) / 8;
    localparam      DFIFO_OFFSET            = 0;

    localparam      IP_VERSION_MAJOR        = 1,                                        //| Major Version of IP Module
                    IP_VERSION_MINOR        = 0;                                        //| Minor Version of IP Module

    localparam      APB_ADDR_VALUABLE_WIDTH = 12;                                       //| 4K Range slave access

    localparam      DFIFO_DEPTH             = 8;                                        //| Downstream FIFO depth
    localparam      DFIFO_USED_WIDTH        = $clog2(DFIFO_DEPTH);
    localparam      DFIFO_WIDTH             = 8;
    
    localparam      UFIFO_DEPTH             = 8;                                        //| Upstream FIFO depth
    localparam      UFIFO_USED_WIDTH        = $clog2(UFIFO_DEPTH);
    localparam      UFIFO_WIDTH             = 8;

    string          KENEZOER_BAD_PARAM      = "[PARAM ERROR] Bad parameter value!";
    string          KENEZOER_ERROR          = "[ERROR] An error occured! Module: ";
    string          KENEZOER_WARNING        = "[ERROR] A warning occured! Module: ";

    localparam      IRQ_EVENTS_NUM          = 10;

    localparam      IRQ_TX_STARTED          = 0,
                    IRQ_TX_DONE             = 1,
                    IRQ_RX_STARTED          = 2,
                    IRQ_RX_DONE             = 3,
                    IRQ_DFIFO_ERROR         = 4,
                    IRQ_DFIFO_EMPTY         = 5,
                    IRQ_UFIFO_ERROR         = 6,
                    IRQ_UFIFO_FULL          = 7,
                    IRQ_UART_PARITY_ERR     = 8,
                    IRQ_UART_BAD_FRAME      = 9;

endpackage : uart_pkg


`endif    /*__KENEZOER_UART_PKG_DEFINED__*/