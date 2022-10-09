/* -------------------- RX/TX TEST -------------------------- */
$display("@ %0d @ [TEST] RX/TX Test started! ", $time);
/* ----------------------------------------------------------- */

    /* ------------- 1. Make a global reset; -------------------------- */

        GlobalReset();

    /* ------------- 2. 'for' cycle with N iterations ----------------- */

    for(int i = 0; i < $urandom_range(128, 1024); i++) begin

        $display("----------------");
        $display("Iteration #%0d", i);

        //| 2.1 Setup BAUDRATE and registers
        apb_write(32'h8, 32'h10);   // Bit Period

        uart_settings.send_parity       = $urandom;
        uart_settings.msb_first         = $urandom;
        uart_settings.hw_flow_ctrl_en   = $urandom;
        uart_settings.stop_bit_value    = $urandom;
        uart_settings.stop_bit_mode     = $urandom;

        //| 2.2 Randomize data to transmit
        write_data              = '0;
        write_data[7:0]         = $urandom;
        apb_write(32'h0, write_data);   // Data to Send
        $display("Sending data  = 0x%2H", write_data[7:0]);

        //| 2.3 Wait for data to be in
        do begin

            repeat(100) @(posedge clk);
            apb_read(UFIFO_OFFSET + 32'h4,  read_data);

        end while (read_data[23:16] == '0);

        //| 2.4 Get received data
        apb_read(UFIFO_OFFSET, read_data);
        @(posedge clk);

        $display("Read data     = 0x%2H", read_data[7:0]);

        @(posedge clk);

        //| 2.5 compare given data with sent data
        assert(read_data == write_data)
            else begin
                error_counter++;
                $error("Sent/Received data differs!");
            end

    end 

    $display("----------------");

    if(error_counter)   $fatal("[RX/TX Test] finished with errors. Error counter = %0d", error_counter);
    else                $display("[RX/TX Test] finished succesfully!");
