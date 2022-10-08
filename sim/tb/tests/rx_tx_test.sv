/* -------------------- RX/TX TEST -------------------------- */
$display("@ [TEST] RX/TX Test started!");
/* ----------------------------------------------------------- */

    //| 1. Make a global reset;
    GlobalReset();

    //| 2. Setup BAUDRATE and registers
    apb_write(32'h8, 32'h10);   // Bit Period
    apb_write(32'h0, 32'hA1);   // Data to Send
    apb_write(32'h0, 32'hFF);   // Data to Send
    apb_write(32'h0, 32'hAA);   // Data to Send

/*
    do begin

        apb_read( ,  read_data);


    end while ();
*/
    // apb_write(32'h8, 32'h10);   // Bit Period
    // apb_write(32'h0, 32'hFF);   // Data to Send

    repeat(700) @(posedge clk);