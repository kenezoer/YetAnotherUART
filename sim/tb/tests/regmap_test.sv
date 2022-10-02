/* -------------------- REGMAP TEST -------------------------- */
$display("@ [TEST] Regmap Test started!");
/* ----------------------------------------------------------- */

    //| 1. Make a global reset;
    GlobalReset();

    //| 2. Testing RW access for all RW registers
    for(int i = 0; i < 4; i++) begin : RW_ACCESS
        apb_write(  i*32'h4,   $urandom);
        apb_read(   i*32'h4,  read_data);
        @(posedge clk);
        assert(read_data == write_data)
            else begin
                $error("[ERROR] write data differs from readen data!");
                $display("Address:      0x%H", i*32'h4);
                $display("Write Data:   0x%H", write_data);
                $display("Read Data:    0x%H", read_data);
            end
    end

    //| Delay cycle
    repeat(50) @(posedge clk);