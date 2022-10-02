/* -------------------- RX/TX TEST -------------------------- */
$display("@ [TEST] RX/TX Test started!");
/* ----------------------------------------------------------- */

    //| 1. Make a global reset;
    GlobalReset();

    //| 2. Setup BAUDRATE and registers
    apb_write(32'h8, 32'h30);   // Bit Period
    apb_write(32'h0, 32'hA1);   // Data to Send


    repeat(1000) @(posedge clk);