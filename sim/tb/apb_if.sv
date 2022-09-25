/*
 * ----------------------------------------------------------------------------
 *  Project:  YetAnotherUART
 *  Filename: apb_if.sv
 *  Purpose:  SVI for APB3
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

`ifndef         __APB_IF_DEFINED__
`define         __APB_IF_DEFINED__

interface APB3_IF #(
    parameter   APB3_AW         = 32,
    parameter   APB3_DW         = 32
)(
    input       PCLK,
    input       PRESETN
);


    logic       [APB3_AW - 1 : 0]   PADDR;
    logic       [APB3_DW - 1 : 0]   PWDATA;
    logic                           PWRITE;
    logic                           PSEL;
    logic                           PENABLE;
    logic                           PSLVERR;
    logic       [APB3_DW - 1 : 0]   PRDATA;
    logic                           PREADY;

endinterface : APB3_IF

`endif       /* __APB_IF_DEFINED__ */