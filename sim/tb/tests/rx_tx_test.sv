/* -------------------- RX/TX TEST -------------------------- */
$display("@ %0d @ [TEST] RX/TX Test started! ", $time);
/* ----------------------------------------------------------- */

    /* ------------- 1. Make a global reset; -------------------------- */

        GlobalReset();

        //| 1.1 Setup IRQ detection
        
        uart_irq_reg.uart_bad_frame     = '1;
        uart_irq_reg.uart_parity_err    = '1;
        uart_irq_reg.ufifo_full         = '0;
        uart_irq_reg.ufifo_error        = '1;
        uart_irq_reg.dfifo_empty        = '0;
        uart_irq_reg.dfifo_error        = '1;
        uart_irq_reg.rx_done            = '0;
        uart_irq_reg.rx_started         = '0;
        uart_irq_reg.tx_done            = '0;
        uart_irq_reg.tx_started         = '0;

        apb_write(32'hC, uart_irq_reg);     //| IRQ Enable
        apb_write(32'h10, ~uart_irq_reg);   //| IRQ Mask

    /* ------------- 2. 'for' cycle with N iterations ----------------- */

    for(int i = 0; i < $urandom_range(128, 1024); i++) begin : rx_tx_test_iterations

        $display("----------------");
        $display("Iteration #%0d", i);

        //| 2.1 Setup BAUDRATE and registers
        apb_write(32'h8, $urandom_range(32'h10, 32'h100));   // Bit Period

        uart_settings.send_parity       = $urandom;
        uart_settings.msb_first         = $urandom;
        uart_settings.hw_flow_ctrl_en   = $urandom;
        uart_settings.stop_bit_value    = $urandom;
        uart_settings.stop_bit_mode     = stop_bit_mode_t'($urandom);

        apb_write(32'h4, uart_settings);

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

        //| 2.4 Get status flags
        apb_read(32'h14, uart_irq_reg);
        @(posedge clk);

        if(uart_irq_reg.uart_bad_frame)     begin
            $error("Detected UART Bad frame!");
            error_counter++;
        end

        if(uart_irq_reg.uart_parity_err)    begin
            $error("Detected UART Parity error in transaction!");
            error_counter++;
        end

        if(uart_irq_reg.ufifo_error)        begin
            $error("Detected UART UFIFO Parity error!");
            error_counter++;
        end

        if(uart_irq_reg.dfifo_error)        begin
            $error("Detected UART DFIFO Parity error!");
            error_counter++;
        end

        apb_write(32'h14, uart_irq_reg); // Disable active IRQ events


        //| 2.5 Get received data
        apb_read(UFIFO_OFFSET, read_data);
        @(posedge clk);

        $display("Read data     = 0x%2H", read_data[7:0]);

        @(posedge clk);

        //| 2.6 compare given data with sent data
        assert(read_data[7:0] == write_data[7:0])
            else begin
                error_counter++;
                $error("Sent/Received data differs! Read_data = 0x%2H, Write_data = 0x%2H", read_data[7:0], write_data[7:0]);
            end

    end 

    $display("----------------");

    if(error_counter)   $fatal("[RX/TX Test] finished with errors. Error counter = %0d", error_counter);
    else                $display("[RX/TX Test] finished succesfully!");
