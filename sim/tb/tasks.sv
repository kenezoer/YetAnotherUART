  /* ------------------------------ */

    task GlobalReset();

        rstn    = '0;
        @(posedge clk);
        #1fs;
        rstn    = '1;

    endtask : GlobalReset

    /* ------------------------------ */

    task apb_read(
        input           [APB_BUS_AW - 1 : 0]    addr,
        output  logic   [APB_BUS_DW - 1 : 0]    data
    );

        @(posedge clk);
        #1fs;
        APB.PSEL       = '1;
        APB.PWRITE     = '0;
        APB.PENABLE    = '0;
        APB.PWDATA     = '0;
        APB.PADDR      = addr;

        @(posedge   clk);
        #1fs;
        APB.PENABLE    = '1;

        if(!APB.PREADY) @(posedge APB.PREADY);

        @(posedge clk);
        data            = APB.PRDATA;
        #1fs;
        APB.PENABLE    = '0;
        APB.PSEL       = '0;
        APB.PWRITE     = '0;
        APB.PWDATA     = '0;
        APB.PADDR      = '0;
        @(posedge clk);
        #1fs;

    endtask : apb_read

    /* ------------------------------ */

    task apb_write(
        input   [APB_BUS_AW - 1 : 0]    addr,
        input   [APB_BUS_DW - 1 : 0]    data  
    );

        write_data  = data;

        @(posedge clk);
        #1fs;
        APB.PSEL       = '1;
        APB.PWRITE     = '1;
        APB.PENABLE    = '0;
        APB.PWDATA     = data;
        APB.PADDR      = addr;

        @(posedge   clk);
        #1fs;
        APB.PENABLE    = '1;

        if(!APB.PREADY)
            @(posedge APB.PREADY);

        @(posedge clk);
        #1fs;
        APB.PENABLE    = '0;
        APB.PSEL       = '0;
        APB.PWRITE     = '0;
        APB.PWDATA     = '0;
        APB.PADDR      = '0;
        @(posedge clk);
        #1fs;


    endtask : apb_write

    /* ------------------------------ */

    task    SendChar(
        input   [7:0]   char
    );


    endtask : SendChar

    /* ------------------------------ */

    task    GetChar();

    endtask : GetChar

    /* ------------------------------ */
