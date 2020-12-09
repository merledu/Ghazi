// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module ghazi_top_dffram_csv (
`ifdef USE_POWER_PINS
    inout VPWR,	// User area 1 1.8V supply
    inout VGND,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oen,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb
);

	wire RESET_n;
	wire rst_ni;
	wire rst_lc_ni;
	wire ndmreset_req_o;
	wire jtag_tck_i;
	wire jtag_tms_i;
	wire jtag_trst_ni;
	wire jtag_tdi_i;
	wire jtag_tdo_o;
	wire cio_uart_rx_p2d;
	wire cio_uart_tx_d2p;
	wire cio_uart_tx_en_d2p;
	wire [31:0] cio_gpio_gpio_p2d;
	wire [31:0] cio_gpio_gpio_d2p;
	wire [31:0] cio_gpio_gpio_en_d2p;
	wire cio_spi_device_sck_p2d;
	wire cio_spi_device_csb_p2d;
	wire cio_spi_device_sdi_p2d;
	wire cio_spi_device_sdo_d2p;
	wire cio_spi_device_sdo_en_d2p;
	wire [15:0] CLKS_PER_BIT;
	assign CLKS_PER_BIT = la_data_in[47:32];
	assign rst_lc_ni = la_data_in[64];
	assign la_data_out[31:0] = cio_gpio_gpio_en_d2p;
	assign la_data_out[32] = cio_uart_tx_en_d2p;
	assign la_data_out[33] = ndmreset_req_o;
	assign RESET_n = (~la_oen[0]) ? (~la_data_in[0]) : ~wb_rst_i;
	// assign RESET_n = ~wb_rst_i;
	assign jtag_tck_i = io_in[0];
	assign jtag_tms_i = io_in[1];
	assign jtag_trst_ni = io_in[2];
	assign jtag_tdi_i = io_in[3];
	assign io_out[4] = jtag_tdo_o;
	assign cio_uart_rx_p2d = io_in[5];
	assign cio_spi_device_sdi_p2d = io_in[18];
	assign cio_spi_device_csb_p2d = io_in[19];
	assign cio_spi_device_sck_p2d = io_in[20];
	assign cio_gpio_gpio_p2d = io_in[36:5];
	assign io_out[5] = cio_gpio_gpio_d2p[0];
	assign io_out[6] = (cio_uart_tx_en_d2p ? cio_uart_tx_d2p : cio_gpio_gpio_d2p[1]);
	assign io_out[16:7] = cio_gpio_gpio_d2p[11:2];
	assign io_out[17] = (cio_spi_device_sdo_en_d2p ? cio_spi_device_sdo_d2p : cio_gpio_gpio_d2p[12]);
	assign io_out[28:18] = cio_gpio_gpio_d2p[23:13];
	assign io_out[36:29] = cio_gpio_gpio_d2p[31:24];
	assign io_oeb[36:0] = {~cio_gpio_gpio_en_d2p[31:2], ~cio_gpio_gpio_en_d2p[1] | ~cio_uart_tx_en_d2p, ~cio_gpio_gpio_en_d2p[0], 1'b0, 4'b1111};
	wire ram_main_instr_req;
	wire ram_main_instr_we;
	wire [13:0] ram_main_instr_addr;
	wire [31:0] ram_main_instr_wdata;
	wire [31:0] ram_main_instr_wmask;
	wire [31:0] ram_main_instr_rdata;
	reg ram_main_instr_rvalid;
	wire [1:0] ram_main_instr_rerror;
	wire ram_main_data_req;
	wire ram_main_data_we;
	wire [13:0] ram_main_data_addr;
	wire [31:0] ram_main_data_wdata;
	wire [31:0] ram_main_data_wmask;
	wire [31:0] ram_main_data_rdata;
	reg ram_main_data_rvalid;
	wire [1:0] ram_main_data_rerror;
	ghazi_top ghazi_top(
		.clk_i(wb_clk_i),
		.rst_lc_ni(rst_lc_ni),
		.rst_ni(rst_ni),
		.ram_main_instr_req(ram_main_instr_req),
		.ram_main_instr_we(ram_main_instr_we),
		.ram_main_instr_addr(ram_main_instr_addr),
		.ram_main_instr_wdata(ram_main_instr_wdata),
		.ram_main_instr_wmask(ram_main_instr_wmask),
		.ram_main_instr_rdata(ram_main_instr_rdata),
		.ram_main_instr_rvalid(ram_main_instr_rvalid),
		.ram_main_instr_rerror(2'b00),
		.ram_main_data_req(ram_main_data_req),
		.ram_main_data_we(ram_main_data_we),
		.ram_main_data_addr(ram_main_data_addr),
		.ram_main_data_wdata(ram_main_data_wdata),
		.ram_main_data_wmask(ram_main_data_wmask),
		.ram_main_data_rdata(ram_main_data_rdata),
		.ram_main_data_rvalid(ram_main_data_rvalid),
		.ram_main_data_rerror(2'b00),
		.jtag_tck_i(jtag_tck_i),
		.jtag_tms_i(jtag_tms_i),
		.jtag_trst_ni(jtag_trst_ni),
		.jtag_tdi_i(jtag_tdi_i),
		.jtag_tdo_o(jtag_tdo_o),
		.cio_gpio_gpio_p2d(cio_gpio_gpio_p2d),
		.cio_gpio_gpio_d2p(cio_gpio_gpio_d2p),
		.cio_gpio_gpio_en_d2p(cio_gpio_gpio_en_d2p),
		.cio_uart_rx_p2d(cio_uart_rx_p2d),
		.cio_uart_tx_d2p(cio_uart_tx_d2p),
		.cio_uart_tx_en_d2p(cio_uart_tx_en_d2p),
		.cio_spi_device_sck_p2d(cio_spi_device_sck_p2d),
		.cio_spi_device_csb_p2d(cio_spi_device_csb_p2d),
		.cio_spi_device_sdi_p2d(cio_spi_device_sdi_p2d),
		.cio_spi_device_sdo_d2p(cio_spi_device_sdo_d2p),
		.cio_spi_device_sdo_en_d2p(cio_spi_device_sdo_en_d2p),
		.ndmreset_req_o(ndmreset_req_o)
	);
	wire [3:0] instr_WE;
	wire instr_EN;
	wire ram_prog_instr_we;
	wire [31:0] instr_Di;
	wire [31:0] ram_prog_instr_wdata;
	wire [13:0] instr_A;
	wire [13:0] ram_prog_instr_addr;
	assign instr_A = (rst_ni ? ram_main_instr_addr : ram_prog_instr_addr);
	assign instr_Di = (rst_ni ? ram_main_instr_wdata : ram_prog_instr_wdata);
	assign instr_WE = {4 {ram_prog_instr_we}} | ({ram_main_instr_wmask[31:24] != 8'b00000000, ram_main_instr_wmask[23:16] != 8'b00000000, ram_main_instr_wmask[15:8] != 8'b00000000, ram_main_instr_wmask[7:0] != 8'b00000000} & {4 {ram_main_instr_we}});
	assign instr_EN = ram_main_instr_req | ram_prog_instr_we;
	always @(posedge wb_clk_i)
		if (!rst_ni)
			ram_main_instr_rvalid <= 1'b0;
		else if (ram_main_instr_we || ram_prog_instr_we)
			ram_main_instr_rvalid <= 1'b0;
		else
			ram_main_instr_rvalid <= ram_main_instr_req;
	DFFRAM #(1) SRAMI(
	`ifdef USE_POWER_PINS
	        .VPWR(VPWR),
	        .VGND(VGND),
    	`endif
		.CLK(wb_clk_i),
		.WE(instr_WE),
		.EN(instr_EN),
		.Di(instr_Di),
		.Do(ram_main_instr_rdata),
		.A(instr_A[7:0])
	);
	wire [3:0] data_WE;
	assign data_WE = {ram_main_data_wmask[31:24] != 8'b00000000, ram_main_data_wmask[23:16] != 8'b00000000, ram_main_data_wmask[15:8] != 8'b00000000, ram_main_data_wmask[7:0] != 8'b00000000} & {4 {ram_main_data_we}};
	always @(posedge wb_clk_i)
		if (!rst_ni)
			ram_main_data_rvalid <= 1'b0;
		else if (ram_main_data_we)
			ram_main_data_rvalid <= 1'b0;
		else
			ram_main_data_rvalid <= ram_main_data_req;
	DFFRAM #(1) SRAMD(
	`ifdef USE_POWER_PINS
	        .VPWR(VPWR),
	        .VGND(VGND),
    	`endif
		.CLK(wb_clk_i),
		.WE(data_WE),
		.EN(ram_main_data_req),
		.Di(ram_main_data_wdata),
		.Do(ram_main_data_rdata),
		.A(ram_main_data_addr[7:0])
	);
	wire rx_dv_i;
	wire [7:0] rx_byte_i;
	iccm_controller u_dut(
		.clk_i(wb_clk_i),
		.rst_ni(RESET_n),
		.rx_dv_i(rx_dv_i),
		.rx_byte_i(rx_byte_i),
		.we_o(ram_prog_instr_we),
		.addr_o(ram_prog_instr_addr),
		.wdata_o(ram_prog_instr_wdata),
		.reset_o(rst_ni)
	);
	uart_rx_prog u_uart_rx(
		.i_Clock(wb_clk_i),
		.rst_ni(RESET_n),
		.i_Rx_Serial(cio_uart_rx_p2d),
		.CLKS_PER_BIT(CLKS_PER_BIT),
		.o_Rx_DV(rx_dv_i),
		.o_Rx_Byte(rx_byte_i)
	);
endmodule
