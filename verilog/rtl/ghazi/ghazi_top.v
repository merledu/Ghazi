// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module ghazi_top (
	clk_i,
	rst_lc_ni,
	rst_ni,
	ram_main_instr_req,
	ram_main_instr_we,
	ram_main_instr_addr,
	ram_main_instr_wdata,
	ram_main_instr_wmask,
	ram_main_instr_rdata,
	ram_main_instr_rvalid,
	ram_main_instr_rerror,
	ram_main_data_req,
	ram_main_data_we,
	ram_main_data_addr,
	ram_main_data_wdata,
	ram_main_data_wmask,
	ram_main_data_rdata,
	ram_main_data_rvalid,
	ram_main_data_rerror,
	jtag_tck_i,
	jtag_tms_i,
	jtag_trst_ni,
	jtag_tdi_i,
	jtag_tdo_o,
	cio_gpio_gpio_p2d,
	cio_gpio_gpio_d2p,
	cio_gpio_gpio_en_d2p,
	cio_uart_rx_p2d,
	cio_uart_tx_d2p,
	cio_uart_tx_en_d2p,
	cio_spi_device_sck_p2d,
	cio_spi_device_csb_p2d,
	cio_spi_device_sdi_p2d,
	cio_spi_device_sdo_d2p,
	cio_spi_device_sdo_en_d2p,
	ndmreset_req_o
);
	localparam integer brqrv_pkg_RegFileFF = 0;
	parameter integer BuraqRegFile = brqrv_pkg_RegFileFF;
	localparam integer brqrv_pkg_RV32MSingleCycle = 3;
	parameter integer BuraqM = brqrv_pkg_RV32MSingleCycle;
	parameter [0:0] BuraqPipeLine = 0;
	input clk_i;
	input rst_lc_ni;
	input rst_ni;
	output wire ram_main_instr_req;
	output wire ram_main_instr_we;
	output wire [13:0] ram_main_instr_addr;
	output wire [31:0] ram_main_instr_wdata;
	output wire [31:0] ram_main_instr_wmask;
	input wire [31:0] ram_main_instr_rdata;
	input wire ram_main_instr_rvalid;
	input wire [1:0] ram_main_instr_rerror;
	output wire ram_main_data_req;
	output wire ram_main_data_we;
	output wire [13:0] ram_main_data_addr;
	output wire [31:0] ram_main_data_wdata;
	output wire [31:0] ram_main_data_wmask;
	input wire [31:0] ram_main_data_rdata;
	input wire ram_main_data_rvalid;
	input wire [1:0] ram_main_data_rerror;
	input jtag_tck_i;
	input jtag_tms_i;
	input jtag_trst_ni;
	input jtag_tdi_i;
	output wire jtag_tdo_o;
	input [31:0] cio_gpio_gpio_p2d;
	output wire [31:0] cio_gpio_gpio_d2p;
	output wire [31:0] cio_gpio_gpio_en_d2p;
	input cio_uart_rx_p2d;
	output wire cio_uart_tx_d2p;
	output wire cio_uart_tx_en_d2p;
	input cio_spi_device_sck_p2d;
	input cio_spi_device_csb_p2d;
	input cio_spi_device_sdi_p2d;
	output wire cio_spi_device_sdo_d2p;
	output wire cio_spi_device_sdo_en_d2p;
	output wire        ndmreset_req_o;
	localparam [31:0] JTAG_IDCODE = {4'h0, 16'h4f54, 11'h426, 1'b1};
	localparam ArbiterImpl = "PPC";
	localparam [31:0] ADDR_SPACE_UART = 32'h40000000;
	localparam [31:0] ADDR_SPACE_GPIO = 32'h40010000;
	localparam [31:0] ADDR_SPACE_SRAMD = 32'h18000000;
	localparam [31:0] ADDR_SPACE_SRAMI = 32'h00080000;
	localparam [31:0] ADDR_SPACE_DEBUG_MEM = 32'h1a110000;
	localparam [31:0] ADDR_SPACE_RV_PLIC = 32'h40090000;
	localparam [31:0] ADDR_SPACE_SPI_DEVICE = 32'h40020000;
	localparam [31:0] ADDR_SPACE_RV_TIMER = 32'h40080000;
	localparam [31:0] ADDR_MASK_UART = 32'h00000fff;
	localparam [31:0] ADDR_MASK_GPIO = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SRAMD = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_SRAMI = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_DEBUG_MEM = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_PLIC = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SPI_DEVICE = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_TIMER = 32'h00000fff;
	localparam [2:0] PutFullData = 3'h0;
	localparam [2:0] PutPartialData = 3'h1;
	localparam [2:0] Get = 3'h4;
	localparam [2:0] AccessAck = 3'h0;
	localparam [2:0] AccessAckData = 3'h1;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	function automatic [top_pkg_TL_SZW - 1:0] sv2v_cast_F00AF;
		input reg [top_pkg_TL_SZW - 1:0] inp;
		sv2v_cast_F00AF = inp;
	endfunction
	function automatic [top_pkg_TL_AIW - 1:0] sv2v_cast_F1F18;
		input reg [top_pkg_TL_AIW - 1:0] inp;
		sv2v_cast_F1F18 = inp;
	endfunction
	function automatic [top_pkg_TL_AW - 1:0] sv2v_cast_4CD75;
		input reg [top_pkg_TL_AW - 1:0] inp;
		sv2v_cast_4CD75 = inp;
	endfunction
	function automatic [top_pkg_TL_DBW - 1:0] sv2v_cast_37199;
		input reg [top_pkg_TL_DBW - 1:0] inp;
		sv2v_cast_37199 = inp;
	endfunction
	function automatic [top_pkg_TL_DW - 1:0] sv2v_cast_2497D;
		input reg [top_pkg_TL_DW - 1:0] inp;
		sv2v_cast_2497D = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] TL_H2D_DEFAULT = {1'sb0, 3'b000, 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_4CD75(1'sb0), sv2v_cast_37199(1'sb0), sv2v_cast_2497D(1'sb0), 16'b0000000000000000, 1'b1};
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	function automatic [top_pkg_TL_DIW - 1:0] sv2v_cast_B5AB2;
		input reg [top_pkg_TL_DIW - 1:0] inp;
		sv2v_cast_B5AB2 = inp;
	endfunction
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	function automatic [top_pkg_TL_DUW - 1:0] sv2v_cast_92577;
		input reg [top_pkg_TL_DUW - 1:0] inp;
		sv2v_cast_92577 = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] TL_D2H_DEFAULT = {1'sb0, sv2v_cast_3(3'b000), 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_B5AB2(1'sb0), sv2v_cast_2497D(1'sb0), sv2v_cast_92577(1'sb0), 1'sb0, 1'b1};
	wire [2:0] unused_spi_device;
	wire core_sleep_o;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] main_tl_srami_req;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] main_tl_srami_rsp;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] main_tl_sramd_req;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] main_tl_sramd_rsp;
	wire [40:0] intr_vector;
	wire intr_rv_timer_timer_expired_0_0;
	wire intr_uart_tx_watermark;
	wire intr_uart_rx_watermark;
	wire intr_uart_tx_empty;
	wire intr_uart_rx_overflow;
	wire intr_uart_rx_frame_err;
	wire intr_uart_rx_break_err;
	wire intr_uart_rx_timeout;
	wire intr_uart_rx_parity_err;
	wire [31:0] intr_gpio_gpio;
	wire irq_plic;
	wire msip;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] gpio_tl_req;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] gpio_tl_rsp;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] uart_tl_req;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] uart_tl_rsp;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] rv_plic_tl_req;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] rv_plic_tl_rsp;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] rv_timer_tl_req;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] rv_timer_tl_rsp;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] main_tl_corei_req;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] main_tl_corei_rsp;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] main_tl_cored_req;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] main_tl_cored_rsp;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] main_tl_dm_sba_req;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] main_tl_dm_sba_rsp;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] main_tl_debug_mem_req;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] main_tl_debug_mem_rsp;
	wire debug_req;
	localparam integer brqrv_pkg_RV32BNone = 0;
	buraq_core_top #(
		.PMPEnable(1),
		.PMPGranularity(0),
		.PMPNumRegions(16),
		.MHPMCounterNum(10),
		.MHPMCounterWidth(32),
		.RV32E(0),
		.RV32M(BuraqM),
		.RV32B(brqrv_pkg_RV32BNone),
		.RegFile(BuraqRegFile),
		.BranchTargetALU(1),
		.WritebackStage(1),
		.ICache(0),
		.ICacheECC(0),
		.BranchPredictor(0),
		.DbgTriggerEn(1),
		.SecureBuraq(0),
		.PipeLine(BuraqPipeLine)
	) u_rv_buraq_core(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(1'b0),
		.hart_id_i(32'b00000000000000000000000000000000),
		.boot_addr_i(32'h00080000),
		.tl_i_o(main_tl_corei_req),
		.tl_i_i(main_tl_corei_rsp),
		.tl_d_o(main_tl_cored_req),
		.tl_d_i(main_tl_cored_rsp),
		.irq_software_i(msip),
		.irq_timer_i(intr_rv_timer_timer_expired_0_0),
		.irq_external_i(irq_plic),
		.esc_tx_i(),
		.esc_rx_o(),
		.debug_req_i(debug_req),
		.fetch_enable_i(1'b1),
		.core_sleep_o(core_sleep_o)
	);
	tlul_adapter_sram #(
		.SramAw(14),
		.SramDw(32),
		.Outstanding(2)
	) imem(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(main_tl_srami_req),
		.tl_o(main_tl_srami_rsp),
		.req_o(ram_main_instr_req),
		.gnt_i(1'b1),
		.we_o(ram_main_instr_we),
		.addr_o(ram_main_instr_addr),
		.wdata_o(ram_main_instr_wdata),
		.wmask_o(ram_main_instr_wmask),
		.rdata_i(ram_main_instr_rdata),
		.rvalid_i(ram_main_instr_rvalid),
		.rerror_i(ram_main_instr_rerror)
	);
	tlul_adapter_sram #(
		.SramAw(14),
		.SramDw(32),
		.Outstanding(2)
	) lmem(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(main_tl_sramd_req),
		.tl_o(main_tl_sramd_rsp),
		.req_o(ram_main_data_req),
		.gnt_i(1'b1),
		.we_o(ram_main_data_we),
		.addr_o(ram_main_data_addr),
		.wdata_o(ram_main_data_wdata),
		.wmask_o(ram_main_data_wmask),
		.rdata_i(ram_main_data_rdata),
		.rvalid_i(ram_main_data_rvalid),
		.rerror_i(ram_main_data_rerror)
	);
	rv_dm #(
		.NrHarts(1),
		.IdcodeValue(JTAG_IDCODE)
	) u_dm_top(
		.clk_i(clk_i),
		.rst_ni(rst_lc_ni),
		.testmode_i(1'b0),
		.ndmreset_o(ndmreset_req_o),
		.dmactive_o(),
		.debug_req_o(debug_req),
		.unavailable_i(1'b0),
		.tl_d_i(main_tl_debug_mem_req),
		.tl_d_o(main_tl_debug_mem_rsp),
		.tl_h_o(main_tl_dm_sba_req),
		.tl_h_i(main_tl_dm_sba_rsp),
		.tck_i(jtag_tck_i),
		.tms_i(jtag_tms_i),
		.trst_ni(jtag_trst_ni),
		.td_i(jtag_tdi_i),
		.td_o(jtag_tdo_o),
		.tdo_oe_o()
	);
	tlul_gpio u_gpio(
		.cio_gpio_i(cio_gpio_gpio_p2d),
		.cio_gpio_o(cio_gpio_gpio_d2p),
		.cio_gpio_en_o(cio_gpio_gpio_en_d2p),
		.intr_gpio_o(intr_gpio_gpio),
		.tl_i(gpio_tl_req),
		.tl_o(gpio_tl_rsp),
		.clk_i(clk_i),
		.rst_ni(rst_ni)
	);
	uart u_uart(
		.cio_rx_i(cio_uart_rx_p2d),
		.cio_tx_o(cio_uart_tx_d2p),
		.cio_tx_en_o(cio_uart_tx_en_d2p),
		.intr_tx_watermark_o(intr_uart_tx_watermark),
		.intr_rx_watermark_o(intr_uart_rx_watermark),
		.intr_tx_empty_o(intr_uart_tx_empty),
		.intr_rx_overflow_o(intr_uart_rx_overflow),
		.intr_rx_frame_err_o(intr_uart_rx_frame_err),
		.intr_rx_break_err_o(intr_uart_rx_break_err),
		.intr_rx_timeout_o(intr_uart_rx_timeout),
		.intr_rx_parity_err_o(intr_uart_rx_parity_err),
		.tl_i(uart_tl_req),
		.tl_o(uart_tl_rsp),
		.clk_i(clk_i),
		.rst_ni(rst_ni)
	);
	rv_plic u_rv_plic(
		.tl_i(rv_plic_tl_req),
		.tl_o(rv_plic_tl_rsp),
		.intr_src_i(intr_vector),
		.irq_o(irq_plic),
		.irq_id_o(),
		.msip_o(msip),
		.clk_i(clk_i),
		.rst_ni(rst_ni)
	);
	rv_timer u_rv_timer(
		.intr_timer_expired_0_0_o(intr_rv_timer_timer_expired_0_0),
		.tl_i(rv_timer_tl_req),
		.tl_o(rv_timer_tl_rsp),
		.clk_i(clk_i),
		.rst_ni(rst_ni)
	);
	xbar ghazi_xbar(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_corei_i(main_tl_corei_req),
		.tl_corei_o(main_tl_corei_rsp),
		.tl_cored_i(main_tl_cored_req),
		.tl_cored_o(main_tl_cored_rsp),
		.tl_dm_sba_i(main_tl_dm_sba_req),
		.tl_dm_sba_o(main_tl_dm_sba_rsp),
		.tl_srami_o(main_tl_srami_req),
		.tl_srami_i(main_tl_srami_rsp),
		.tl_sramd_o(main_tl_sramd_req),
		.tl_sramd_i(main_tl_sramd_rsp),
		.tl_gpio_o(gpio_tl_req),
		.tl_gpio_i(gpio_tl_rsp),
		.tl_uart_o(uart_tl_req),
		.tl_uart_i(uart_tl_rsp),
		.tl_debug_mem_o(main_tl_debug_mem_req),
		.tl_debug_mem_i(main_tl_debug_mem_rsp),
		.tl_rv_plic_o(rv_plic_tl_req),
		.tl_rv_plic_i(rv_plic_tl_rsp),
		.tl_spi_device_o(),
		.tl_spi_device_i(),
		.tl_rv_timer_o(rv_timer_tl_req),
		.tl_rv_timer_i(rv_timer_tl_rsp)
	);
	assign unused_spi_device = {cio_spi_device_sck_p2d, cio_spi_device_csb_p2d, cio_spi_device_sdi_p2d};
	assign cio_spi_device_sdo_d2p = 1'b0;
	assign cio_spi_device_sdo_en_d2p = 1'b0;
	assign intr_vector = {intr_uart_rx_parity_err, intr_uart_rx_timeout, intr_uart_rx_break_err, intr_uart_rx_frame_err, intr_uart_rx_overflow, intr_uart_tx_empty, intr_uart_rx_watermark, intr_uart_tx_watermark, intr_gpio_gpio, 1'b0};
endmodule // ghazi_top
module xbar (
	clk_i,
	rst_ni,
	tl_corei_i,
	tl_corei_o,
	tl_cored_i,
	tl_cored_o,
	tl_dm_sba_i,
	tl_dm_sba_o,
	tl_srami_o,
	tl_srami_i,
	tl_sramd_o,
	tl_sramd_i,
	tl_gpio_o,
	tl_gpio_i,
	tl_uart_o,
	tl_uart_i,
	tl_debug_mem_o,
	tl_debug_mem_i,
	tl_rv_plic_o,
	tl_rv_plic_i,
	tl_spi_device_o,
	tl_spi_device_i,
	tl_rv_timer_o,
	tl_rv_timer_i
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_corei_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_corei_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_cored_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_cored_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_dm_sba_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_dm_sba_o;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_srami_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_srami_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_sramd_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_sramd_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_gpio_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_gpio_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_uart_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_uart_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_debug_mem_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_debug_mem_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_rv_plic_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_rv_plic_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_spi_device_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_spi_device_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_rv_timer_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_rv_timer_i;
	localparam ArbiterImpl = "PPC";
	localparam [31:0] ADDR_SPACE_UART = 32'h40000000;
	localparam [31:0] ADDR_SPACE_GPIO = 32'h40010000;
	localparam [31:0] ADDR_SPACE_SRAMD = 32'h18000000;
	localparam [31:0] ADDR_SPACE_SRAMI = 32'h00080000;
	localparam [31:0] ADDR_SPACE_DEBUG_MEM = 32'h1a110000;
	localparam [31:0] ADDR_SPACE_RV_PLIC = 32'h40090000;
	localparam [31:0] ADDR_SPACE_SPI_DEVICE = 32'h40020000;
	localparam [31:0] ADDR_SPACE_RV_TIMER = 32'h40080000;
	localparam [31:0] ADDR_MASK_UART = 32'h00000fff;
	localparam [31:0] ADDR_MASK_GPIO = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SRAMD = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_SRAMI = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_DEBUG_MEM = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_PLIC = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SPI_DEVICE = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_TIMER = 32'h00000fff;
	localparam [2:0] PutFullData = 3'h0;
	localparam [2:0] PutPartialData = 3'h1;
	localparam [2:0] Get = 3'h4;
	localparam [2:0] AccessAck = 3'h0;
	localparam [2:0] AccessAckData = 3'h1;
	function automatic [top_pkg_TL_SZW - 1:0] sv2v_cast_F00AF;
		input reg [top_pkg_TL_SZW - 1:0] inp;
		sv2v_cast_F00AF = inp;
	endfunction
	function automatic [top_pkg_TL_AIW - 1:0] sv2v_cast_F1F18;
		input reg [top_pkg_TL_AIW - 1:0] inp;
		sv2v_cast_F1F18 = inp;
	endfunction
	function automatic [top_pkg_TL_AW - 1:0] sv2v_cast_4CD75;
		input reg [top_pkg_TL_AW - 1:0] inp;
		sv2v_cast_4CD75 = inp;
	endfunction
	function automatic [top_pkg_TL_DBW - 1:0] sv2v_cast_37199;
		input reg [top_pkg_TL_DBW - 1:0] inp;
		sv2v_cast_37199 = inp;
	endfunction
	function automatic [top_pkg_TL_DW - 1:0] sv2v_cast_2497D;
		input reg [top_pkg_TL_DW - 1:0] inp;
		sv2v_cast_2497D = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] TL_H2D_DEFAULT = {1'sb0, 3'b000, 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_4CD75(1'sb0), sv2v_cast_37199(1'sb0), sv2v_cast_2497D(1'sb0), 16'b0000000000000000, 1'b1};
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [top_pkg_TL_DIW - 1:0] sv2v_cast_B5AB2;
		input reg [top_pkg_TL_DIW - 1:0] inp;
		sv2v_cast_B5AB2 = inp;
	endfunction
	function automatic [top_pkg_TL_DUW - 1:0] sv2v_cast_92577;
		input reg [top_pkg_TL_DUW - 1:0] inp;
		sv2v_cast_92577 = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] TL_D2H_DEFAULT = {1'sb0, sv2v_cast_3(3'b000), 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_B5AB2(1'sb0), sv2v_cast_2497D(1'sb0), sv2v_cast_92577(1'sb0), 1'sb0, 1'b1};
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_s1n_12_us_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_s1n_12_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (7 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (7 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_s1n_12_ds_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (7 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (7 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_s1n_12_ds_d2h;
	reg [2:0] dev_sel_s1n_12;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_s1n_18_us_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_s1n_18_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_s1n_18_ds_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_s1n_18_ds_d2h;
	reg [1:0] dev_sel_s1n_18;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_sm1_19_us_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_sm1_19_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_sm1_19_ds_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_sm1_19_ds_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_sm1_20_us_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_sm1_20_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_sm1_20_ds_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_sm1_20_ds_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_sm1_21_us_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_sm1_21_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_sm1_21_ds_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_sm1_21_ds_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_sm1_25_us_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_sm1_25_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_sm1_25_ds_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_sm1_25_ds_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_sm1_26_us_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_sm1_26_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_sm1_26_ds_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_sm1_26_ds_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_sm1_29_us_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_sm1_29_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_sm1_29_ds_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_sm1_29_ds_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_sm1_30_us_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_sm1_30_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_sm1_30_ds_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_sm1_30_ds_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_sm1_31_us_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (2 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (2 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_sm1_31_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_sm1_31_ds_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_sm1_31_ds_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_s1n_35_us_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_s1n_35_us_d2h;
	wire [(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (7 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (7 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15)):(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] tl_s1n_35_ds_h2d;
	wire [(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (7 * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (7 * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW)):(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)] tl_s1n_35_ds_d2h;
	reg [2:0] dev_sel_s1n_35;
	wire [31:0] addr_test;
	assign addr_test = tl_s1n_12_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)];
	assign tl_sm1_21_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_12_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (6 * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_12_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (6 * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_21_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_25_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_12_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (5 * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_12_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (5 * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_25_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_26_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_12_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (4 * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_12_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (4 * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_26_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_20_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_12_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (3 * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_12_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (3 * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_20_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_29_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_12_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (2 * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_12_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (2 * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_29_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_30_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_12_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_12_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_30_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_31_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_12_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_12_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_31_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_19_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_18_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_18_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_19_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_20_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_18_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_18_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_20_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_19_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_35_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (6 * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_35_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (6 * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_19_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_21_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_35_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (5 * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_35_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (5 * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_21_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_25_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_35_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (4 * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_35_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (4 * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_25_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_26_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_35_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (3 * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_35_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (3 * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_26_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_29_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_35_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (2 * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_35_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (2 * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_29_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_30_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_35_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_35_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_30_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_sm1_31_us_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] = tl_s1n_35_ds_h2d[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))];
	assign tl_s1n_35_ds_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] = tl_sm1_31_us_d2h[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))];
	assign tl_s1n_12_us_h2d = tl_cored_i;
	assign tl_cored_o = tl_s1n_12_us_d2h;
	assign tl_s1n_18_us_h2d = tl_corei_i;
	assign tl_corei_o = tl_s1n_18_us_d2h;
	assign tl_srami_o = tl_sm1_19_ds_h2d;
	assign tl_sm1_19_ds_d2h = tl_srami_i;
	assign tl_sramd_o = tl_sm1_21_ds_h2d;
	assign tl_sm1_21_ds_d2h = tl_sramd_i;
	assign tl_gpio_o = tl_sm1_25_ds_h2d;
	assign tl_sm1_25_ds_d2h = tl_gpio_i;
	assign tl_uart_o = tl_sm1_26_ds_h2d;
	assign tl_sm1_26_ds_d2h = tl_uart_i;
	assign tl_rv_plic_o = tl_sm1_29_ds_h2d;
	assign tl_sm1_29_ds_d2h = tl_rv_plic_i;
	assign tl_debug_mem_o = tl_sm1_20_ds_h2d;
	assign tl_sm1_20_ds_d2h = tl_debug_mem_i;
	assign tl_spi_device_o = tl_sm1_30_ds_h2d;
	assign tl_sm1_30_ds_d2h = tl_spi_device_i;
	assign tl_rv_timer_o = tl_sm1_31_ds_h2d;
	assign tl_sm1_31_ds_d2h = tl_rv_timer_i;
	assign tl_s1n_35_us_h2d = tl_dm_sba_i;
	assign tl_dm_sba_o = tl_s1n_35_us_d2h;
	always @(*)
		if ((tl_s1n_12_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_SRAMD) == ADDR_SPACE_SRAMD)
			dev_sel_s1n_12 = 3'b000;
		else if ((tl_s1n_12_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_GPIO) == ADDR_SPACE_GPIO)
			dev_sel_s1n_12 = 3'b001;
		else if ((tl_s1n_12_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_UART) == ADDR_SPACE_UART)
			dev_sel_s1n_12 = 3'b010;
		else if ((tl_s1n_12_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_DEBUG_MEM) == ADDR_SPACE_DEBUG_MEM)
			dev_sel_s1n_12 = 3'b011;
		else if ((tl_s1n_12_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_RV_PLIC) == ADDR_SPACE_RV_PLIC)
			dev_sel_s1n_12 = 3'b100;
		else if ((tl_s1n_12_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_SPI_DEVICE) == ADDR_SPACE_SPI_DEVICE)
			dev_sel_s1n_12 = 3'b101;
		else if ((tl_s1n_12_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_RV_TIMER) == ADDR_SPACE_RV_TIMER)
			dev_sel_s1n_12 = 3'b110;
		else
			dev_sel_s1n_12 = 3'b111;
	always @(*)
		if ((tl_s1n_18_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_SRAMI) == ADDR_SPACE_SRAMI)
			dev_sel_s1n_18 = 2'b00;
		else if ((tl_s1n_18_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_DEBUG_MEM) == ADDR_SPACE_DEBUG_MEM)
			dev_sel_s1n_18 = 2'b01;
		else
			dev_sel_s1n_18 = 2'b10;
	always @(*)
		if ((tl_s1n_35_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_SRAMI) == ADDR_SPACE_SRAMI)
			dev_sel_s1n_35 = 3'b000;
		else if ((tl_s1n_35_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_SRAMD) == ADDR_SPACE_SRAMD)
			dev_sel_s1n_35 = 3'b001;
		else if ((tl_s1n_35_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_GPIO) == ADDR_SPACE_GPIO)
			dev_sel_s1n_35 = 3'b010;
		else if ((tl_s1n_35_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_UART) == ADDR_SPACE_UART)
			dev_sel_s1n_35 = 3'b011;
		else if ((tl_s1n_35_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_RV_PLIC) == ADDR_SPACE_RV_PLIC)
			dev_sel_s1n_35 = 3'b100;
		else if ((tl_s1n_35_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_SPI_DEVICE) == ADDR_SPACE_SPI_DEVICE)
			dev_sel_s1n_35 = 3'b101;
		else if ((tl_s1n_35_us_h2d[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] & ~ADDR_MASK_RV_TIMER) == ADDR_SPACE_RV_TIMER)
			dev_sel_s1n_35 = 3'b110;
		else
			dev_sel_s1n_35 = 3'b111;
	tlul_socket_1n #(
		.HReqDepth(4'h0),
		.HRspDepth(4'h0),
		.DReqDepth(16'h0000),
		.DRspDepth(16'h0000),
		.N(7)
	) u_s1n_12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_s1n_12_us_h2d),
		.tl_h_o(tl_s1n_12_us_d2h),
		.tl_d_o(tl_s1n_12_ds_h2d),
		.tl_d_i(tl_s1n_12_ds_d2h),
		.dev_select_i(dev_sel_s1n_12)
	);
	tlul_socket_1n #(
		.HReqDepth(4'h0),
		.HRspDepth(4'h0),
		.DReqDepth(8'h00),
		.DRspDepth(8'h00),
		.N(2)
	) u_s1n_18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_s1n_18_us_h2d),
		.tl_h_o(tl_s1n_18_us_d2h),
		.tl_d_o(tl_s1n_18_ds_h2d),
		.tl_d_i(tl_s1n_18_ds_d2h),
		.dev_select_i(dev_sel_s1n_18)
	);
	tlul_socket_m1 #(
		.HReqDepth(12'h000),
		.HRspDepth(12'h000),
		.DReqDepth(4'h0),
		.DRspDepth(4'h0),
		.M(2)
	) u_sm1_19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_sm1_19_us_h2d),
		.tl_h_o(tl_sm1_19_us_d2h),
		.tl_d_o(tl_sm1_19_ds_h2d),
		.tl_d_i(tl_sm1_19_ds_d2h)
	);
	tlul_socket_m1 #(
		.HReqDepth(8'h00),
		.HRspDepth(8'h00),
		.DReqPass(1'b0),
		.DRspPass(1'b0),
		.M(2)
	) u_sm1_20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_sm1_20_us_h2d),
		.tl_h_o(tl_sm1_20_us_d2h),
		.tl_d_o(tl_sm1_20_ds_h2d),
		.tl_d_i(tl_sm1_20_ds_d2h)
	);
	tlul_socket_m1 #(
		.HReqDepth(12'h000),
		.HRspDepth(12'h000),
		.DReqDepth(4'h0),
		.DRspDepth(4'h0),
		.M(2)
	) u_sm1_21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_sm1_21_us_h2d),
		.tl_h_o(tl_sm1_21_us_d2h),
		.tl_d_o(tl_sm1_21_ds_h2d),
		.tl_d_i(tl_sm1_21_ds_d2h)
	);
	tlul_socket_m1 #(
		.HReqDepth(8'h00),
		.HRspDepth(8'h00),
		.DReqDepth(4'h0),
		.DRspDepth(4'h0),
		.M(2)
	) u_sm1_25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_sm1_25_us_h2d),
		.tl_h_o(tl_sm1_25_us_d2h),
		.tl_d_o(tl_sm1_25_ds_h2d),
		.tl_d_i(tl_sm1_25_ds_d2h)
	);
	tlul_socket_m1 #(
		.HReqDepth(8'h00),
		.HRspDepth(8'h00),
		.DReqDepth(4'h0),
		.DRspDepth(4'h0),
		.M(2)
	) u_sm1_26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_sm1_26_us_h2d),
		.tl_h_o(tl_sm1_26_us_d2h),
		.tl_d_o(tl_sm1_26_ds_h2d),
		.tl_d_i(tl_sm1_26_ds_d2h)
	);
	tlul_socket_m1 #(
		.HReqDepth(8'h00),
		.HRspDepth(8'h00),
		.DReqPass(1'b0),
		.DRspPass(1'b0),
		.M(2)
	) u_sm1_29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_sm1_29_us_h2d),
		.tl_h_o(tl_sm1_29_us_d2h),
		.tl_d_o(tl_sm1_29_ds_h2d),
		.tl_d_i(tl_sm1_29_ds_d2h)
	);
	tlul_socket_m1 #(
		.HReqDepth(8'h00),
		.HRspDepth(8'h00),
		.DReqDepth(4'h0),
		.DRspDepth(4'h0),
		.M(2)
	) u_sm1_30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_sm1_30_us_h2d),
		.tl_h_o(tl_sm1_30_us_d2h),
		.tl_d_o(tl_sm1_30_ds_h2d),
		.tl_d_i(tl_sm1_30_ds_d2h)
	);
	tlul_socket_m1 #(
		.HReqDepth(8'h00),
		.HRspDepth(8'h00),
		.DReqDepth(4'h0),
		.DRspDepth(4'h0),
		.M(2)
	) u_sm1_31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_sm1_31_us_h2d),
		.tl_h_o(tl_sm1_31_us_d2h),
		.tl_d_o(tl_sm1_31_ds_h2d),
		.tl_d_i(tl_sm1_31_ds_d2h)
	);
	tlul_socket_1n #(
		.HReqDepth(4'h0),
		.HRspDepth(4'h0),
		.DReqDepth(16'h0000),
		.DRspDepth(16'h0000),
		.N(7)
	) u_s1n_35(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_s1n_35_us_h2d),
		.tl_h_o(tl_s1n_35_us_d2h),
		.tl_d_o(tl_s1n_35_ds_h2d),
		.tl_d_i(tl_s1n_35_ds_d2h),
		.dev_select_i(dev_sel_s1n_12)
	);
endmodule
module buraq_core_top (
	clk_i,
	rst_ni,
	test_en_i,
	hart_id_i,
	boot_addr_i,
	tl_i_o,
	tl_i_i,
	tl_d_o,
	tl_d_i,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	esc_tx_i,
	esc_rx_o,
	debug_req_i,
	fetch_enable_i,
	core_sleep_o
);
	parameter [0:0] PMPEnable = 1'b0;
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumRegions = 4;
	parameter [31:0] MHPMCounterNum = 10;
	parameter [31:0] MHPMCounterWidth = 32;
	parameter [0:0] RV32E = 0;
	localparam integer brqrv_pkg_RV32MSingleCycle = 3;
	parameter integer RV32M = brqrv_pkg_RV32MSingleCycle;
	localparam integer brqrv_pkg_RV32BNone = 0;
	parameter integer RV32B = brqrv_pkg_RV32BNone;
	localparam integer brqrv_pkg_RegFileFF = 0;
	parameter integer RegFile = brqrv_pkg_RegFileFF;
	parameter [0:0] BranchTargetALU = 1'b1;
	parameter [0:0] WritebackStage = 1'b1;
	parameter [0:0] ICache = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	parameter [0:0] BranchPredictor = 1'b0;
	parameter [0:0] DbgTriggerEn = 1'b1;
	parameter [0:0] SecureBuraq = 1'b0;
	parameter [31:0] DmHaltAddr = 32'h1a110800;
	parameter [31:0] DmExceptionAddr = 32'h1a110808;
	parameter [0:0] PipeLine = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire [31:0] hart_id_i;
	input wire [31:0] boot_addr_i;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i_o;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_i_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_d_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_d_i;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [1:0] esc_tx_i;
	output wire [1:0] esc_rx_o;
	input wire debug_req_i;
	input wire fetch_enable_i;
	output wire core_sleep_o;
	localparam signed [31:0] TL_AW = 32;
	localparam signed [31:0] TL_DW = 32;
	localparam signed [31:0] TL_AIW = 8;
	localparam signed [31:0] TL_DIW = 1;
	localparam signed [31:0] TL_DUW = 16;
	localparam signed [31:0] TL_DBW = TL_DW >> 3;
	localparam signed [31:0] TL_SZW = $clog2($clog2(TL_DBW) + 1);
	localparam signed [31:0] FLASH_BANKS = 2;
	localparam signed [31:0] FLASH_PAGES_PER_BANK = 256;
	localparam signed [31:0] FLASH_WORDS_PER_PAGE = 128;
	localparam signed [31:0] FLASH_INFO_TYPES = 2;
	localparam signed [(FLASH_INFO_TYPES * 32) - 1:0] FLASH_INFO_PER_BANK = {32'sd4, 32'sd4};
	localparam signed [31:0] FLASH_DATA_WIDTH = 64;
	localparam signed [31:0] FLASH_METADATA_WIDTH = 12;
	localparam signed [31:0] NUM_AST_ALERTS = 7;
	localparam signed [31:0] NUM_IO_RAILS = 2;
	localparam signed [31:0] ENTROPY_STREAM = 4;
	localparam signed [31:0] ADC_CHANNELS = 2;
	localparam signed [31:0] ADC_DATAW = 10;
	localparam ArbiterImpl = "PPC";
	localparam [31:0] ADDR_SPACE_UART = 32'h40000000;
	localparam [31:0] ADDR_SPACE_GPIO = 32'h40010000;
	localparam [31:0] ADDR_SPACE_SRAMD = 32'h18000000;
	localparam [31:0] ADDR_SPACE_SRAMI = 32'h00080000;
	localparam [31:0] ADDR_SPACE_DEBUG_MEM = 32'h1a110000;
	localparam [31:0] ADDR_SPACE_RV_PLIC = 32'h40090000;
	localparam [31:0] ADDR_SPACE_SPI_DEVICE = 32'h40020000;
	localparam [31:0] ADDR_SPACE_RV_TIMER = 32'h40080000;
	localparam [31:0] ADDR_MASK_UART = 32'h00000fff;
	localparam [31:0] ADDR_MASK_GPIO = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SRAMD = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_SRAMI = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_DEBUG_MEM = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_PLIC = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SPI_DEVICE = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_TIMER = 32'h00000fff;
	localparam [2:0] PutFullData = 3'h0;
	localparam [2:0] PutPartialData = 3'h1;
	localparam [2:0] Get = 3'h4;
	localparam [2:0] AccessAck = 3'h0;
	localparam [2:0] AccessAckData = 3'h1;
	function automatic [top_pkg_TL_SZW - 1:0] sv2v_cast_F00AF;
		input reg [top_pkg_TL_SZW - 1:0] inp;
		sv2v_cast_F00AF = inp;
	endfunction
	function automatic [top_pkg_TL_AIW - 1:0] sv2v_cast_F1F18;
		input reg [top_pkg_TL_AIW - 1:0] inp;
		sv2v_cast_F1F18 = inp;
	endfunction
	function automatic [top_pkg_TL_AW - 1:0] sv2v_cast_4CD75;
		input reg [top_pkg_TL_AW - 1:0] inp;
		sv2v_cast_4CD75 = inp;
	endfunction
	function automatic [top_pkg_TL_DBW - 1:0] sv2v_cast_37199;
		input reg [top_pkg_TL_DBW - 1:0] inp;
		sv2v_cast_37199 = inp;
	endfunction
	function automatic [top_pkg_TL_DW - 1:0] sv2v_cast_2497D;
		input reg [top_pkg_TL_DW - 1:0] inp;
		sv2v_cast_2497D = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] TL_H2D_DEFAULT = {1'sb0, 3'b000, 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_4CD75(1'sb0), sv2v_cast_37199(1'sb0), sv2v_cast_2497D(1'sb0), 16'b0000000000000000, 1'b1};
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [top_pkg_TL_DIW - 1:0] sv2v_cast_B5AB2;
		input reg [top_pkg_TL_DIW - 1:0] inp;
		sv2v_cast_B5AB2 = inp;
	endfunction
	function automatic [top_pkg_TL_DUW - 1:0] sv2v_cast_92577;
		input reg [top_pkg_TL_DUW - 1:0] inp;
		sv2v_cast_92577 = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] TL_D2H_DEFAULT = {1'sb0, sv2v_cast_3(3'b000), 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_B5AB2(1'sb0), sv2v_cast_2497D(1'sb0), sv2v_cast_92577(1'sb0), 1'sb0, 1'b1};
	localparam signed [31:0] FifoPass = (PipeLine ? 1'b0 : 1'b1);
	localparam signed [31:0] FifoDepth = (PipeLine ? 4'h2 : 4'h0);
	wire instr_req;
	wire instr_gnt;
	wire instr_rvalid;
	wire [31:0] instr_addr;
	wire [31:0] instr_rdata;
	wire instr_err;
	wire data_req;
	wire data_gnt;
	wire data_rvalid;
	wire data_we;
	wire [3:0] data_be;
	wire [31:0] data_addr;
	wire [31:0] data_wdata;
	wire [31:0] data_rdata;
	wire data_err;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i_brqrv2fifo;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_i_fifo2brqrv;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_d_brqrv2fifo;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_d_fifo2brqrv;
	wire irq_nm;
	prim_esc_receiver i_prim_esc_receiver(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.esc_en_o(irq_nm),
		.esc_rx_o(esc_rx_o),
		.esc_tx_i(esc_tx_i)
	);
	wire alert_minor;
	wire alert_major;
	wire unused_alert_minor;
	wire unused_alert_major;
	assign unused_alert_minor = alert_minor;
	assign unused_alert_major = alert_major;
	brqrv_core #(
		.PMPEnable(PMPEnable),
		.PMPGranularity(PMPGranularity),
		.PMPNumRegions(PMPNumRegions),
		.MHPMCounterNum(MHPMCounterNum),
		.MHPMCounterWidth(MHPMCounterWidth),
		.RV32E(RV32E),
		.RV32M(RV32M),
		.RV32B(RV32B),
		.RegFile(RegFile),
		.BranchTargetALU(BranchTargetALU),
		.WritebackStage(WritebackStage),
		.ICache(ICache),
		.ICacheECC(ICacheECC),
		.BranchPredictor(BranchPredictor),
		.DbgTriggerEn(DbgTriggerEn),
		.SecureBuraq(SecureBuraq),
		.DmHaltAddr(DmHaltAddr),
		.DmExceptionAddr(DmExceptionAddr)
	) u_core(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(test_en_i),
		.hart_id_i(hart_id_i),
		.boot_addr_i(boot_addr_i),
		.instr_req_o(instr_req),
		.instr_gnt_i(instr_gnt),
		.instr_rvalid_i(instr_rvalid),
		.instr_addr_o(instr_addr),
		.instr_rdata_i(instr_rdata),
		.instr_err_i(instr_err),
		.data_req_o(data_req),
		.data_gnt_i(data_gnt),
		.data_rvalid_i(data_rvalid),
		.data_we_o(data_we),
		.data_be_o(data_be),
		.data_addr_o(data_addr),
		.data_wdata_o(data_wdata),
		.data_rdata_i(data_rdata),
		.data_err_i(data_err),
		.irq_software_i(irq_software_i),
		.irq_timer_i(irq_timer_i),
		.irq_external_i(irq_external_i),
		.irq_fast_i({15 {1'sb0}}),
		.irq_nm_i(irq_nm),
		.debug_req_i(debug_req_i),
		.fetch_enable_i(fetch_enable_i),
		.alert_minor_o(alert_minor),
		.alert_major_o(alert_major),
		.core_sleep_o(core_sleep_o)
	);
	tlul_adapter_host #(.MAX_REQS(2)) tl_adapter_host_i_brqrv(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(instr_req),
		.gnt_o(instr_gnt),
		.addr_i(instr_addr),
		.we_i(1'b0),
		.wdata_i(32'b00000000000000000000000000000000),
		.be_i(4'hf),
		.valid_o(instr_rvalid),
		.rdata_o(instr_rdata),
		.err_o(instr_err),
		.tl_o(tl_i_brqrv2fifo),
		.tl_i(tl_i_fifo2brqrv)
	);
	tlul_fifo_sync #(
		.ReqPass(FifoPass),
		.RspPass(FifoPass),
		.ReqDepth(FifoDepth),
		.RspDepth(FifoDepth)
	) fifo_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_i_brqrv2fifo),
		.tl_h_o(tl_i_fifo2brqrv),
		.tl_d_o(tl_i_o),
		.tl_d_i(tl_i_i),
		.spare_req_i(1'b0),
		.spare_req_o(),
		.spare_rsp_i(1'b0),
		.spare_rsp_o()
	);
	tlul_adapter_host #(.MAX_REQS(2)) tl_adapter_host_d_brqrv(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(data_req),
		.gnt_o(data_gnt),
		.addr_i(data_addr),
		.we_i(data_we),
		.wdata_i(data_wdata),
		.be_i(data_be),
		.valid_o(data_rvalid),
		.rdata_o(data_rdata),
		.err_o(data_err),
		.tl_o(tl_d_brqrv2fifo),
		.tl_i(tl_d_fifo2brqrv)
	);
	tlul_fifo_sync #(
		.ReqPass(FifoPass),
		.RspPass(FifoPass),
		.ReqDepth(FifoDepth),
		.RspDepth(FifoDepth)
	) fifo_d(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_d_brqrv2fifo),
		.tl_h_o(tl_d_fifo2brqrv),
		.tl_d_o(tl_d_o),
		.tl_d_i(tl_d_i),
		.spare_req_i(1'b0),
		.spare_req_o(),
		.spare_rsp_i(1'b0),
		.spare_rsp_o()
	);
endmodule
module brqrv_core (
	clk_i,
	rst_ni,
	test_en_i,
	hart_id_i,
	boot_addr_i,
	instr_req_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_addr_o,
	instr_rdata_i,
	instr_err_i,
	data_req_o,
	data_gnt_i,
	data_rvalid_i,
	data_we_o,
	data_be_o,
	data_addr_o,
	data_wdata_o,
	data_rdata_i,
	data_err_i,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	irq_fast_i,
	irq_nm_i,
	debug_req_i,
	fetch_enable_i,
	alert_minor_o,
	alert_major_o,
	core_sleep_o
);
	parameter [0:0] PMPEnable = 1'b0;
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumRegions = 4;
	parameter [31:0] MHPMCounterNum = 0;
	parameter [31:0] MHPMCounterWidth = 40;
	parameter [0:0] RV32E = 1'b0;
	localparam integer brqrv_pkg_RV32MFast = 2;
	parameter integer RV32M = brqrv_pkg_RV32MFast;
	localparam integer brqrv_pkg_RV32BNone = 0;
	parameter integer RV32B = brqrv_pkg_RV32BNone;
	localparam integer brqrv_pkg_RegFileFF = 0;
	parameter integer RegFile = brqrv_pkg_RegFileFF;
	parameter [0:0] BranchTargetALU = 1'b0;
	parameter [0:0] WritebackStage = 1'b0;
	parameter [0:0] ICache = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	parameter [0:0] BranchPredictor = 1'b0;
	parameter [0:0] DbgTriggerEn = 1'b0;
	parameter [0:0] SecureBuraq = 1'b0;
	parameter [31:0] DmHaltAddr = 32'h1a110800;
	parameter [31:0] DmExceptionAddr = 32'h1a110808;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire [31:0] hart_id_i;
	input wire [31:0] boot_addr_i;
	output wire instr_req_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	output wire [31:0] instr_addr_o;
	input wire [31:0] instr_rdata_i;
	input wire instr_err_i;
	output wire data_req_o;
	input wire data_gnt_i;
	input wire data_rvalid_i;
	output wire data_we_o;
	output wire [3:0] data_be_o;
	output wire [31:0] data_addr_o;
	output wire [31:0] data_wdata_o;
	input wire [31:0] data_rdata_i;
	input wire data_err_i;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [14:0] irq_fast_i;
	input wire irq_nm_i;
	input wire debug_req_i;
	input wire fetch_enable_i;
	output wire alert_minor_o;
	output wire alert_major_o;
	output wire core_sleep_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	localparam [31:0] PMP_NUM_CHAN = 2;
	localparam [0:0] DataIndTiming = SecureBuraq;
	localparam [0:0] DummyInstructions = SecureBuraq;
	localparam [0:0] SpecBranch = PMPEnable & (PMPNumRegions == 16);
	localparam [0:0] RegFileECC = SecureBuraq;
	localparam [31:0] RegFileDataWidth = (RegFileECC ? 39 : 32);
	wire dummy_instr_id;
	wire instr_valid_id;
	wire instr_new_id;
	wire [31:0] instr_rdata_id;
	wire [31:0] instr_rdata_alu_id;
	wire [15:0] instr_rdata_c_id;
	wire instr_is_compressed_id;
	wire instr_bp_taken_id;
	wire instr_fetch_err;
	wire instr_fetch_err_plus2;
	wire illegal_c_insn_id;
	wire [31:0] pc_if;
	wire [31:0] pc_id;
	wire [31:0] pc_wb;
	wire [67:0] imd_val_d_ex;
	wire [67:0] imd_val_q_ex;
	wire [1:0] imd_val_we_ex;
	wire data_ind_timing;
	wire dummy_instr_en;
	wire [2:0] dummy_instr_mask;
	wire dummy_instr_seed_en;
	wire [31:0] dummy_instr_seed;
	wire icache_enable;
	wire icache_inval;
	wire pc_mismatch_alert;
	wire instr_first_cycle_id;
	wire instr_valid_clear;
	wire pc_set;
	wire pc_set_spec;
	wire nt_branch_mispredict;
	wire [2:0] pc_mux_id;
	wire [1:0] exc_pc_mux_id;
	wire [5:0] exc_cause;
	wire lsu_load_err;
	wire lsu_store_err;
	wire lsu_addr_incr_req;
	wire [31:0] lsu_addr_last;
	wire [31:0] branch_target_ex;
	wire branch_decision;
	wire ctrl_busy;
	wire if_busy;
	wire lsu_busy;
	wire core_busy_d;
	reg core_busy_q;
	wire [4:0] rf_raddr_a;
	wire [31:0] rf_rdata_a;
	wire [4:0] rf_raddr_b;
	wire [31:0] rf_rdata_b;
	wire rf_ren_a;
	wire rf_ren_b;
	wire [4:0] rf_waddr_wb;
	wire [31:0] rf_wdata_wb;
	wire [31:0] rf_wdata_fwd_wb;
	wire [31:0] rf_wdata_lsu;
	wire rf_we_wb;
	wire rf_we_lsu;
	wire [4:0] rf_waddr_id;
	wire [31:0] rf_wdata_id;
	wire rf_we_id;
	wire rf_rd_a_wb_match;
	wire rf_rd_b_wb_match;
	wire [5:0] alu_operator_ex;
	wire [31:0] alu_operand_a_ex;
	wire [31:0] alu_operand_b_ex;
	wire [31:0] bt_a_operand;
	wire [31:0] bt_b_operand;
	wire [31:0] alu_adder_result_ex;
	wire [31:0] result_ex;
	wire mult_en_ex;
	wire div_en_ex;
	wire mult_sel_ex;
	wire div_sel_ex;
	wire [1:0] multdiv_operator_ex;
	wire [1:0] multdiv_signed_mode_ex;
	wire [31:0] multdiv_operand_a_ex;
	wire [31:0] multdiv_operand_b_ex;
	wire multdiv_ready_id;
	wire csr_access;
	wire [1:0] csr_op;
	wire csr_op_en;
	wire [11:0] csr_addr;
	wire [31:0] csr_rdata;
	wire [31:0] csr_wdata;
	wire illegal_csr_insn_id;
	wire lsu_we;
	wire [1:0] lsu_type;
	wire lsu_sign_ext;
	wire lsu_req;
	wire [31:0] lsu_wdata;
	wire lsu_req_done;
	wire id_in_ready;
	wire ex_valid;
	wire lsu_resp_valid;
	wire instr_req_int;
	wire en_wb;
	wire [1:0] instr_type_wb;
	wire ready_wb;
	wire rf_write_wb;
	wire outstanding_load_wb;
	wire outstanding_store_wb;
	wire irq_pending;
	wire nmi_mode;
	wire [17:0] irqs;
	wire csr_mstatus_mie;
	wire [31:0] csr_mepc;
	wire [31:0] csr_depc;
	wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 34) + (((PMPNumRegions - 1) * 34) - 1) : (PMPNumRegions * 34) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 34 : 0)] csr_pmp_addr;
	wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 6) + (((PMPNumRegions - 1) * 6) - 1) : (PMPNumRegions * 6) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 6 : 0)] csr_pmp_cfg;
	wire [PMP_NUM_CHAN - 1:0] pmp_req_err;
	wire instr_req_out;
	wire data_req_out;
	wire csr_save_if;
	wire csr_save_id;
	wire csr_save_wb;
	wire csr_restore_mret_id;
	wire csr_restore_dret_id;
	wire csr_save_cause;
	wire csr_mtvec_init;
	wire [31:0] csr_mtvec;
	wire [31:0] csr_mtval;
	wire csr_mstatus_tw;
	wire [1:0] priv_mode_id;
	wire [1:0] priv_mode_if;
	wire [1:0] priv_mode_lsu;
	wire debug_mode;
	wire [2:0] debug_cause;
	wire debug_csr_save;
	wire debug_single_step;
	wire debug_ebreakm;
	wire debug_ebreaku;
	wire trigger_match;
	wire instr_id_done;
	wire instr_id_done_compressed;
	wire instr_done_wb;
	wire perf_iside_wait;
	wire perf_dside_wait;
	wire perf_mul_wait;
	wire perf_div_wait;
	wire perf_jump;
	wire perf_branch;
	wire perf_tbranch;
	wire perf_load;
	wire perf_store;
	wire illegal_insn_id;
	wire unused_illegal_insn_id;
	wire clk;
	wire clock_en;
	assign core_busy_d = (ctrl_busy | if_busy) | lsu_busy;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			core_busy_q <= 1'b0;
		else
			core_busy_q <= core_busy_d;
	reg fetch_enable_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			fetch_enable_q <= 1'b0;
		else if (fetch_enable_i)
			fetch_enable_q <= 1'b1;
	assign clock_en = fetch_enable_q & (((core_busy_q | debug_req_i) | irq_pending) | irq_nm_i);
	assign core_sleep_o = ~clock_en;
	prim_clock_gating core_clock_gate_i(
		.clk_i(clk_i),
		.en_i(clock_en),
		.test_en_i(test_en_i),
		.clk_o(clk)
	);
	brqrv_ifu #(
		.DmHaltAddr(DmHaltAddr),
		.DmExceptionAddr(DmExceptionAddr),
		.DummyInstructions(DummyInstructions),
		.ICache(ICache),
		.ICacheECC(ICacheECC),
		.SecureBuraq(SecureBuraq),
		.BranchPredictor(BranchPredictor)
	) if_stage_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.boot_addr_i(boot_addr_i),
		.req_i(instr_req_int),
		.instr_req_o(instr_req_out),
		.instr_addr_o(instr_addr_o),
		.instr_gnt_i(instr_gnt_i),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_rdata_i(instr_rdata_i),
		.instr_err_i(instr_err_i),
		.instr_pmp_err_i(pmp_req_err[PMP_I]),
		.instr_valid_id_o(instr_valid_id),
		.instr_new_id_o(instr_new_id),
		.instr_rdata_id_o(instr_rdata_id),
		.instr_rdata_alu_id_o(instr_rdata_alu_id),
		.instr_rdata_c_id_o(instr_rdata_c_id),
		.instr_is_compressed_id_o(instr_is_compressed_id),
		.instr_bp_taken_o(instr_bp_taken_id),
		.instr_fetch_err_o(instr_fetch_err),
		.instr_fetch_err_plus2_o(instr_fetch_err_plus2),
		.illegal_c_insn_id_o(illegal_c_insn_id),
		.dummy_instr_id_o(dummy_instr_id),
		.pc_if_o(pc_if),
		.pc_id_o(pc_id),
		.instr_valid_clear_i(instr_valid_clear),
		.pc_set_i(pc_set),
		.pc_set_spec_i(pc_set_spec),
		.pc_mux_i(pc_mux_id),
		.nt_branch_mispredict_i(nt_branch_mispredict),
		.exc_pc_mux_i(exc_pc_mux_id),
		.exc_cause(exc_cause),
		.dummy_instr_en_i(dummy_instr_en),
		.dummy_instr_mask_i(dummy_instr_mask),
		.dummy_instr_seed_en_i(dummy_instr_seed_en),
		.dummy_instr_seed_i(dummy_instr_seed),
		.icache_enable_i(icache_enable),
		.icache_inval_i(icache_inval),
		.branch_target_ex_i(branch_target_ex),
		.csr_mepc_i(csr_mepc),
		.csr_depc_i(csr_depc),
		.csr_mtvec_i(csr_mtvec),
		.csr_mtvec_init_o(csr_mtvec_init),
		.id_in_ready_i(id_in_ready),
		.pc_mismatch_alert_o(pc_mismatch_alert),
		.if_busy_o(if_busy)
	);
	assign perf_iside_wait = id_in_ready & ~instr_valid_id;
	assign instr_req_o = instr_req_out & ~pmp_req_err[PMP_I];
	brqrv_idu #(
		.RV32E(RV32E),
		.RV32M(RV32M),
		.RV32B(RV32B),
		.BranchTargetALU(BranchTargetALU),
		.DataIndTiming(DataIndTiming),
		.SpecBranch(SpecBranch),
		.WritebackStage(WritebackStage),
		.BranchPredictor(BranchPredictor)
	) id_stage_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.ctrl_busy_o(ctrl_busy),
		.illegal_insn_o(illegal_insn_id),
		.instr_valid_i(instr_valid_id),
		.instr_rdata_i(instr_rdata_id),
		.instr_rdata_alu_i(instr_rdata_alu_id),
		.instr_rdata_c_i(instr_rdata_c_id),
		.instr_is_compressed_i(instr_is_compressed_id),
		.instr_bp_taken_i(instr_bp_taken_id),
		.branch_decision_i(branch_decision),
		.instr_first_cycle_id_o(instr_first_cycle_id),
		.instr_valid_clear_o(instr_valid_clear),
		.id_in_ready_o(id_in_ready),
		.instr_req_o(instr_req_int),
		.pc_set_o(pc_set),
		.pc_set_spec_o(pc_set_spec),
		.pc_mux_o(pc_mux_id),
		.nt_branch_mispredict_o(nt_branch_mispredict),
		.exc_pc_mux_o(exc_pc_mux_id),
		.exc_cause_o(exc_cause),
		.icache_inval_o(icache_inval),
		.instr_fetch_err_i(instr_fetch_err),
		.instr_fetch_err_plus2_i(instr_fetch_err_plus2),
		.illegal_c_insn_i(illegal_c_insn_id),
		.pc_id_i(pc_id),
		.ex_valid_i(ex_valid),
		.lsu_resp_valid_i(lsu_resp_valid),
		.alu_operator_ex_o(alu_operator_ex),
		.alu_operand_a_ex_o(alu_operand_a_ex),
		.alu_operand_b_ex_o(alu_operand_b_ex),
		.imd_val_q_ex_o(imd_val_q_ex),
		.imd_val_d_ex_i(imd_val_d_ex),
		.imd_val_we_ex_i(imd_val_we_ex),
		.bt_a_operand_o(bt_a_operand),
		.bt_b_operand_o(bt_b_operand),
		.mult_en_ex_o(mult_en_ex),
		.div_en_ex_o(div_en_ex),
		.mult_sel_ex_o(mult_sel_ex),
		.div_sel_ex_o(div_sel_ex),
		.multdiv_operator_ex_o(multdiv_operator_ex),
		.multdiv_signed_mode_ex_o(multdiv_signed_mode_ex),
		.multdiv_operand_a_ex_o(multdiv_operand_a_ex),
		.multdiv_operand_b_ex_o(multdiv_operand_b_ex),
		.multdiv_ready_id_o(multdiv_ready_id),
		.csr_access_o(csr_access),
		.csr_op_o(csr_op),
		.csr_op_en_o(csr_op_en),
		.csr_save_if_o(csr_save_if),
		.csr_save_id_o(csr_save_id),
		.csr_save_wb_o(csr_save_wb),
		.csr_restore_mret_id_o(csr_restore_mret_id),
		.csr_restore_dret_id_o(csr_restore_dret_id),
		.csr_save_cause_o(csr_save_cause),
		.csr_mtval_o(csr_mtval),
		.priv_mode_i(priv_mode_id),
		.csr_mstatus_tw_i(csr_mstatus_tw),
		.illegal_csr_insn_i(illegal_csr_insn_id),
		.data_ind_timing_i(data_ind_timing),
		.lsu_req_o(lsu_req),
		.lsu_we_o(lsu_we),
		.lsu_type_o(lsu_type),
		.lsu_sign_ext_o(lsu_sign_ext),
		.lsu_wdata_o(lsu_wdata),
		.lsu_req_done_i(lsu_req_done),
		.lsu_addr_incr_req_i(lsu_addr_incr_req),
		.lsu_addr_last_i(lsu_addr_last),
		.lsu_load_err_i(lsu_load_err),
		.lsu_store_err_i(lsu_store_err),
		.csr_mstatus_mie_i(csr_mstatus_mie),
		.irq_pending_i(irq_pending),
		.irqs_i(irqs),
		.irq_nm_i(irq_nm_i),
		.nmi_mode_o(nmi_mode),
		.debug_mode_o(debug_mode),
		.debug_cause_o(debug_cause),
		.debug_csr_save_o(debug_csr_save),
		.debug_req_i(debug_req_i),
		.debug_single_step_i(debug_single_step),
		.debug_ebreakm_i(debug_ebreakm),
		.debug_ebreaku_i(debug_ebreaku),
		.trigger_match_i(trigger_match),
		.result_ex_i(result_ex),
		.csr_rdata_i(csr_rdata),
		.rf_raddr_a_o(rf_raddr_a),
		.rf_rdata_a_i(rf_rdata_a),
		.rf_raddr_b_o(rf_raddr_b),
		.rf_rdata_b_i(rf_rdata_b),
		.rf_ren_a_o(rf_ren_a),
		.rf_ren_b_o(rf_ren_b),
		.rf_waddr_id_o(rf_waddr_id),
		.rf_wdata_id_o(rf_wdata_id),
		.rf_we_id_o(rf_we_id),
		.rf_rd_a_wb_match_o(rf_rd_a_wb_match),
		.rf_rd_b_wb_match_o(rf_rd_b_wb_match),
		.rf_waddr_wb_i(rf_waddr_wb),
		.rf_wdata_fwd_wb_i(rf_wdata_fwd_wb),
		.rf_write_wb_i(rf_write_wb),
		.en_wb_o(en_wb),
		.instr_type_wb_o(instr_type_wb),
		.ready_wb_i(ready_wb),
		.outstanding_load_wb_i(outstanding_load_wb),
		.outstanding_store_wb_i(outstanding_store_wb),
		.perf_jump_o(perf_jump),
		.perf_branch_o(perf_branch),
		.perf_tbranch_o(perf_tbranch),
		.perf_dside_wait_o(perf_dside_wait),
		.perf_mul_wait_o(perf_mul_wait),
		.perf_div_wait_o(perf_div_wait),
		.instr_id_done_o(instr_id_done),
		.instr_id_done_compressed_o(instr_id_done_compressed)
	);
	assign unused_illegal_insn_id = illegal_insn_id;
	brqrv_exu #(
		.RV32M(RV32M),
		.RV32B(RV32B),
		.BranchTargetALU(BranchTargetALU)
	) ex_block_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.alu_operator_i(alu_operator_ex),
		.alu_operand_a_i(alu_operand_a_ex),
		.alu_operand_b_i(alu_operand_b_ex),
		.alu_instr_first_cycle_i(instr_first_cycle_id),
		.bt_a_operand_i(bt_a_operand),
		.bt_b_operand_i(bt_b_operand),
		.multdiv_operator_i(multdiv_operator_ex),
		.mult_en_i(mult_en_ex),
		.div_en_i(div_en_ex),
		.mult_sel_i(mult_sel_ex),
		.div_sel_i(div_sel_ex),
		.multdiv_signed_mode_i(multdiv_signed_mode_ex),
		.multdiv_operand_a_i(multdiv_operand_a_ex),
		.multdiv_operand_b_i(multdiv_operand_b_ex),
		.multdiv_ready_id_i(multdiv_ready_id),
		.data_ind_timing_i(data_ind_timing),
		.imd_val_we_o(imd_val_we_ex),
		.imd_val_d_o(imd_val_d_ex),
		.imd_val_q_i(imd_val_q_ex),
		.alu_adder_result_ex_o(alu_adder_result_ex),
		.result_ex_o(result_ex),
		.branch_target_o(branch_target_ex),
		.branch_decision_o(branch_decision),
		.ex_valid_o(ex_valid)
	);
	assign data_req_o = data_req_out & ~pmp_req_err[PMP_D];
	brqrv_lsu load_store_unit_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.data_req_o(data_req_out),
		.data_gnt_i(data_gnt_i),
		.data_rvalid_i(data_rvalid_i),
		.data_err_i(data_err_i),
		.data_pmp_err_i(pmp_req_err[PMP_D]),
		.data_addr_o(data_addr_o),
		.data_we_o(data_we_o),
		.data_be_o(data_be_o),
		.data_wdata_o(data_wdata_o),
		.data_rdata_i(data_rdata_i),
		.lsu_we_i(lsu_we),
		.lsu_type_i(lsu_type),
		.lsu_wdata_i(lsu_wdata),
		.lsu_sign_ext_i(lsu_sign_ext),
		.lsu_rdata_o(rf_wdata_lsu),
		.lsu_rdata_valid_o(rf_we_lsu),
		.lsu_req_i(lsu_req),
		.lsu_req_done_o(lsu_req_done),
		.adder_result_ex_i(alu_adder_result_ex),
		.addr_incr_req_o(lsu_addr_incr_req),
		.addr_last_o(lsu_addr_last),
		.lsu_resp_valid_o(lsu_resp_valid),
		.load_err_o(lsu_load_err),
		.store_err_o(lsu_store_err),
		.busy_o(lsu_busy),
		.perf_load_o(perf_load),
		.perf_store_o(perf_store)
	);
	brqrv_wbu #(.WritebackStage(WritebackStage)) wb_stage_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.en_wb_i(en_wb),
		.instr_type_wb_i(instr_type_wb),
		.pc_id_i(pc_id),
		.ready_wb_o(ready_wb),
		.rf_write_wb_o(rf_write_wb),
		.outstanding_load_wb_o(outstanding_load_wb),
		.outstanding_store_wb_o(outstanding_store_wb),
		.pc_wb_o(pc_wb),
		.rf_waddr_id_i(rf_waddr_id),
		.rf_wdata_id_i(rf_wdata_id),
		.rf_we_id_i(rf_we_id),
		.rf_wdata_lsu_i(rf_wdata_lsu),
		.rf_we_lsu_i(rf_we_lsu),
		.rf_wdata_fwd_wb_o(rf_wdata_fwd_wb),
		.rf_waddr_wb_o(rf_waddr_wb),
		.rf_wdata_wb_o(rf_wdata_wb),
		.rf_we_wb_o(rf_we_wb),
		.lsu_resp_valid_i(lsu_resp_valid),
		.instr_done_wb_o(instr_done_wb)
	);
	wire [RegFileDataWidth - 1:0] rf_wdata_wb_ecc;
	wire [RegFileDataWidth - 1:0] rf_rdata_a_ecc;
	wire [RegFileDataWidth - 1:0] rf_rdata_b_ecc;
	wire rf_ecc_err_comb;
	generate
		if (RegFileECC) begin : gen_regfile_ecc
			wire [1:0] rf_ecc_err_a;
			wire [1:0] rf_ecc_err_b;
			wire rf_ecc_err_a_id;
			wire rf_ecc_err_b_id;
			prim_secded_39_32_enc regfile_ecc_enc(
				.in(rf_wdata_wb),
				.out(rf_wdata_wb_ecc)
			);
			prim_secded_39_32_dec regfile_ecc_dec_a(
				.in(rf_rdata_a_ecc),
				.d_o(),
				.syndrome_o(),
				.err_o(rf_ecc_err_a)
			);
			prim_secded_39_32_dec regfile_ecc_dec_b(
				.in(rf_rdata_b_ecc),
				.d_o(),
				.syndrome_o(),
				.err_o(rf_ecc_err_b)
			);
			assign rf_rdata_a = rf_rdata_a_ecc[31:0];
			assign rf_rdata_b = rf_rdata_b_ecc[31:0];
			assign rf_ecc_err_a_id = (|rf_ecc_err_a & rf_ren_a) & ~rf_rd_a_wb_match;
			assign rf_ecc_err_b_id = (|rf_ecc_err_b & rf_ren_b) & ~rf_rd_b_wb_match;
			assign rf_ecc_err_comb = instr_valid_id & (rf_ecc_err_a_id | rf_ecc_err_b_id);
		end
		else begin : gen_no_regfile_ecc
			wire unused_rf_ren_a;
			wire unused_rf_ren_b;
			wire unused_rf_rd_a_wb_match;
			wire unused_rf_rd_b_wb_match;
			assign unused_rf_ren_a = rf_ren_a;
			assign unused_rf_ren_b = rf_ren_b;
			assign unused_rf_rd_a_wb_match = rf_rd_a_wb_match;
			assign unused_rf_rd_b_wb_match = rf_rd_b_wb_match;
			assign rf_wdata_wb_ecc = rf_wdata_wb;
			assign rf_rdata_a = rf_rdata_a_ecc;
			assign rf_rdata_b = rf_rdata_b_ecc;
			assign rf_ecc_err_comb = 1'b0;
		end
	endgenerate
	generate
		if (RegFile == RegFileFF) begin : gen_regfile_ff
			brqrv_register_file_ff #(
				.RV32E(RV32E),
				.DataWidth(RegFileDataWidth),
				.DummyInstructions(DummyInstructions)
			) register_file_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.test_en_i(test_en_i),
				.dummy_instr_id_i(dummy_instr_id),
				.raddr_a_i(rf_raddr_a),
				.rdata_a_o(rf_rdata_a_ecc),
				.raddr_b_i(rf_raddr_b),
				.rdata_b_o(rf_rdata_b_ecc),
				.waddr_a_i(rf_waddr_wb),
				.wdata_a_i(rf_wdata_wb_ecc),
				.we_a_i(rf_we_wb)
			);
		end
		else if (RegFile == RegFileFPGA) begin : gen_regfile_fpga
			brqrv_register_file_fpga #(
				.RV32E(RV32E),
				.DataWidth(RegFileDataWidth),
				.DummyInstructions(DummyInstructions)
			) register_file_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.test_en_i(test_en_i),
				.dummy_instr_id_i(dummy_instr_id),
				.raddr_a_i(rf_raddr_a),
				.rdata_a_o(rf_rdata_a_ecc),
				.raddr_b_i(rf_raddr_b),
				.rdata_b_o(rf_rdata_b_ecc),
				.waddr_a_i(rf_waddr_wb),
				.wdata_a_i(rf_wdata_wb_ecc),
				.we_a_i(rf_we_wb)
			);
		end
	endgenerate
	assign alert_minor_o = 1'b0;
	assign alert_major_o = rf_ecc_err_comb | pc_mismatch_alert;
	assign csr_wdata = alu_operand_a_ex;
	function automatic [11:0] sv2v_cast_12;
		input reg [11:0] inp;
		sv2v_cast_12 = inp;
	endfunction
	assign csr_addr = sv2v_cast_12((csr_access ? alu_operand_b_ex[11:0] : 12'b000000000000));
	brqrv_csr #(
		.DbgTriggerEn(DbgTriggerEn),
		.DataIndTiming(DataIndTiming),
		.DummyInstructions(DummyInstructions),
		.ICache(ICache),
		.MHPMCounterNum(MHPMCounterNum),
		.MHPMCounterWidth(MHPMCounterWidth),
		.PMPEnable(PMPEnable),
		.PMPGranularity(PMPGranularity),
		.PMPNumRegions(PMPNumRegions),
		.RV32E(RV32E),
		.RV32M(RV32M)
	) cs_registers_i(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.hart_id_i(hart_id_i),
		.priv_mode_id_o(priv_mode_id),
		.priv_mode_if_o(priv_mode_if),
		.priv_mode_lsu_o(priv_mode_lsu),
		.csr_mtvec_o(csr_mtvec),
		.csr_mtvec_init_i(csr_mtvec_init),
		.boot_addr_i(boot_addr_i),
		.csr_access_i(csr_access),
		.csr_addr_i(csr_addr),
		.csr_wdata_i(csr_wdata),
		.csr_op_i(csr_op),
		.csr_op_en_i(csr_op_en),
		.csr_rdata_o(csr_rdata),
		.irq_software_i(irq_software_i),
		.irq_timer_i(irq_timer_i),
		.irq_external_i(irq_external_i),
		.irq_fast_i(irq_fast_i),
		.nmi_mode_i(nmi_mode),
		.irq_pending_o(irq_pending),
		.irqs_o(irqs),
		.csr_mstatus_mie_o(csr_mstatus_mie),
		.csr_mstatus_tw_o(csr_mstatus_tw),
		.csr_mepc_o(csr_mepc),
		.csr_pmp_cfg_o(csr_pmp_cfg),
		.csr_pmp_addr_o(csr_pmp_addr),
		.csr_depc_o(csr_depc),
		.debug_mode_i(debug_mode),
		.debug_cause_i(debug_cause),
		.debug_csr_save_i(debug_csr_save),
		.debug_single_step_o(debug_single_step),
		.debug_ebreakm_o(debug_ebreakm),
		.debug_ebreaku_o(debug_ebreaku),
		.trigger_match_o(trigger_match),
		.pc_if_i(pc_if),
		.pc_id_i(pc_id),
		.pc_wb_i(pc_wb),
		.data_ind_timing_o(data_ind_timing),
		.dummy_instr_en_o(dummy_instr_en),
		.dummy_instr_mask_o(dummy_instr_mask),
		.dummy_instr_seed_en_o(dummy_instr_seed_en),
		.dummy_instr_seed_o(dummy_instr_seed),
		.icache_enable_o(icache_enable),
		.csr_save_if_i(csr_save_if),
		.csr_save_id_i(csr_save_id),
		.csr_save_wb_i(csr_save_wb),
		.csr_restore_mret_i(csr_restore_mret_id),
		.csr_restore_dret_i(csr_restore_dret_id),
		.csr_save_cause_i(csr_save_cause),
		.csr_mcause_i(exc_cause),
		.csr_mtval_i(csr_mtval),
		.illegal_csr_insn_o(illegal_csr_insn_id),
		.instr_ret_i(instr_id_done),
		.instr_ret_compressed_i(instr_id_done_compressed),
		.iside_wait_i(perf_iside_wait),
		.jump_i(perf_jump),
		.branch_i(perf_branch),
		.branch_taken_i(perf_tbranch),
		.mem_load_i(perf_load),
		.mem_store_i(perf_store),
		.dside_wait_i(perf_dside_wait),
		.mul_wait_i(perf_mul_wait),
		.div_wait_i(perf_div_wait)
	);
	generate
		if (PMPEnable) begin : g_pmp
			wire [(PMP_NUM_CHAN * 34) - 1:0] pmp_req_addr;
			wire [(PMP_NUM_CHAN * 2) - 1:0] pmp_req_type;
			wire [(PMP_NUM_CHAN * 2) - 1:0] pmp_priv_lvl;
			assign pmp_req_addr[((PMP_NUM_CHAN - 1) - PMP_I) * 34+:34] = {2'b00, instr_addr_o[31:0]};
			assign pmp_req_type[((PMP_NUM_CHAN - 1) - PMP_I) * 2+:2] = PMP_ACC_EXEC;
			assign pmp_priv_lvl[((PMP_NUM_CHAN - 1) - PMP_I) * 2+:2] = priv_mode_if;
			assign pmp_req_addr[((PMP_NUM_CHAN - 1) - PMP_D) * 34+:34] = {2'b00, data_addr_o[31:0]};
			assign pmp_req_type[((PMP_NUM_CHAN - 1) - PMP_D) * 2+:2] = (data_we_o ? PMP_ACC_WRITE : PMP_ACC_READ);
			assign pmp_priv_lvl[((PMP_NUM_CHAN - 1) - PMP_D) * 2+:2] = priv_mode_lsu;
			brqrv_pmp #(
				.PMPGranularity(PMPGranularity),
				.PMPNumChan(PMP_NUM_CHAN),
				.PMPNumRegions(PMPNumRegions)
			) pmp_i(
				.clk_i(clk),
				.rst_ni(rst_ni),
				.csr_pmp_cfg_i(csr_pmp_cfg),
				.csr_pmp_addr_i(csr_pmp_addr),
				.priv_mode_i(pmp_priv_lvl),
				.pmp_req_addr_i(pmp_req_addr),
				.pmp_req_type_i(pmp_req_type),
				.pmp_req_err_o(pmp_req_err)
			);
		end
		else begin : g_no_pmp
			wire [1:0] unused_priv_lvl_if;
			wire [1:0] unused_priv_lvl_ls;
			wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 34) + (((PMPNumRegions - 1) * 34) - 1) : (PMPNumRegions * 34) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 34 : 0)] unused_csr_pmp_addr;
			wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 6) + (((PMPNumRegions - 1) * 6) - 1) : (PMPNumRegions * 6) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 6 : 0)] unused_csr_pmp_cfg;
			assign unused_priv_lvl_if = priv_mode_if;
			assign unused_priv_lvl_ls = priv_mode_lsu;
			assign unused_csr_pmp_addr = csr_pmp_addr;
			assign unused_csr_pmp_cfg = csr_pmp_cfg;
			assign pmp_req_err[PMP_I] = 1'b0;
			assign pmp_req_err[PMP_D] = 1'b0;
		end
	endgenerate
endmodule
module brqrv_csr (
	clk_i,
	rst_ni,
	hart_id_i,
	priv_mode_id_o,
	priv_mode_if_o,
	priv_mode_lsu_o,
	csr_mstatus_tw_o,
	csr_mtvec_o,
	csr_mtvec_init_i,
	boot_addr_i,
	csr_access_i,
	csr_addr_i,
	csr_wdata_i,
	csr_op_i,
	csr_op_en_i,
	csr_rdata_o,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	irq_fast_i,
	nmi_mode_i,
	irq_pending_o,
	irqs_o,
	csr_mstatus_mie_o,
	csr_mepc_o,
	csr_pmp_cfg_o,
	csr_pmp_addr_o,
	debug_mode_i,
	debug_cause_i,
	debug_csr_save_i,
	csr_depc_o,
	debug_single_step_o,
	debug_ebreakm_o,
	debug_ebreaku_o,
	trigger_match_o,
	pc_if_i,
	pc_id_i,
	pc_wb_i,
	data_ind_timing_o,
	dummy_instr_en_o,
	dummy_instr_mask_o,
	dummy_instr_seed_en_o,
	dummy_instr_seed_o,
	icache_enable_o,
	csr_save_if_i,
	csr_save_id_i,
	csr_save_wb_i,
	csr_restore_mret_i,
	csr_restore_dret_i,
	csr_save_cause_i,
	csr_mcause_i,
	csr_mtval_i,
	illegal_csr_insn_o,
	instr_ret_i,
	instr_ret_compressed_i,
	iside_wait_i,
	jump_i,
	branch_i,
	branch_taken_i,
	mem_load_i,
	mem_store_i,
	dside_wait_i,
	mul_wait_i,
	div_wait_i
);
	parameter [0:0] DbgTriggerEn = 0;
	parameter [0:0] DataIndTiming = 1'b0;
	parameter [0:0] DummyInstructions = 1'b0;
	parameter [0:0] ICache = 1'b0;
	parameter [31:0] MHPMCounterNum = 10;
	parameter [31:0] MHPMCounterWidth = 40;
	parameter [0:0] PMPEnable = 0;
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumRegions = 4;
	parameter [0:0] RV32E = 0;
	localparam integer brqrv_pkg_RV32MFast = 2;
	parameter integer RV32M = brqrv_pkg_RV32MFast;
	input wire clk_i;
	input wire rst_ni;
	input wire [31:0] hart_id_i;
	output wire [1:0] priv_mode_id_o;
	output wire [1:0] priv_mode_if_o;
	output wire [1:0] priv_mode_lsu_o;
	output wire csr_mstatus_tw_o;
	output wire [31:0] csr_mtvec_o;
	input wire csr_mtvec_init_i;
	input wire [31:0] boot_addr_i;
	input wire csr_access_i;
	input wire [11:0] csr_addr_i;
	input wire [31:0] csr_wdata_i;
	input wire [1:0] csr_op_i;
	input csr_op_en_i;
	output wire [31:0] csr_rdata_o;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [14:0] irq_fast_i;
	input wire nmi_mode_i;
	output wire irq_pending_o;
	output wire [17:0] irqs_o;
	output wire csr_mstatus_mie_o;
	output wire [31:0] csr_mepc_o;
	output wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 6) + (((PMPNumRegions - 1) * 6) - 1) : (PMPNumRegions * 6) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 6 : 0)] csr_pmp_cfg_o;
	output wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 34) + (((PMPNumRegions - 1) * 34) - 1) : (PMPNumRegions * 34) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 34 : 0)] csr_pmp_addr_o;
	input wire debug_mode_i;
	input wire [2:0] debug_cause_i;
	input wire debug_csr_save_i;
	output wire [31:0] csr_depc_o;
	output wire debug_single_step_o;
	output wire debug_ebreakm_o;
	output wire debug_ebreaku_o;
	output wire trigger_match_o;
	input wire [31:0] pc_if_i;
	input wire [31:0] pc_id_i;
	input wire [31:0] pc_wb_i;
	output wire data_ind_timing_o;
	output wire dummy_instr_en_o;
	output wire [2:0] dummy_instr_mask_o;
	output wire dummy_instr_seed_en_o;
	output wire [31:0] dummy_instr_seed_o;
	output wire icache_enable_o;
	input wire csr_save_if_i;
	input wire csr_save_id_i;
	input wire csr_save_wb_i;
	input wire csr_restore_mret_i;
	input wire csr_restore_dret_i;
	input wire csr_save_cause_i;
	input wire [5:0] csr_mcause_i;
	input wire [31:0] csr_mtval_i;
	output wire illegal_csr_insn_o;
	input wire instr_ret_i;
	input wire instr_ret_compressed_i;
	input wire iside_wait_i;
	input wire jump_i;
	input wire branch_i;
	input wire branch_taken_i;
	input wire mem_load_i;
	input wire mem_store_i;
	input wire dside_wait_i;
	input wire mul_wait_i;
	input wire div_wait_i;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	localparam [31:0] RV32MEnabled = (RV32M == RV32MNone ? 0 : 1);
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	localparam [31:0] MISA_VALUE = ((((((((((0 | 4) | 0) | (sv2v_cast_32(RV32E) << 4)) | 0) | (sv2v_cast_32(!RV32E) << 8)) | (RV32MEnabled << 12)) | 0) | 0) | 1048576) | 0) | (sv2v_cast_32(CSR_MISA_MXL) << 30);
	reg [31:0] exception_pc;
	reg [1:0] priv_lvl_q;
	reg [1:0] priv_lvl_d;
	reg [5:0] mstatus_q;
	reg [5:0] mstatus_d;
	reg [17:0] mie_q;
	reg [17:0] mie_d;
	reg [31:0] mscratch_q;
	reg [31:0] mscratch_d;
	reg [31:0] mepc_q;
	reg [31:0] mepc_d;
	reg [5:0] mcause_q;
	reg [5:0] mcause_d;
	reg [31:0] mtval_q;
	reg [31:0] mtval_d;
	reg [31:0] mtvec_q;
	reg [31:0] mtvec_d;
	wire [17:0] mip;
	reg [31:0] dcsr_q;
	reg [31:0] dcsr_d;
	reg [31:0] depc_q;
	reg [31:0] depc_d;
	reg [31:0] dscratch0_q;
	reg [31:0] dscratch0_d;
	reg [31:0] dscratch1_q;
	reg [31:0] dscratch1_d;
	reg [2:0] mstack_q;
	reg [2:0] mstack_d;
	reg [31:0] mstack_epc_q;
	reg [31:0] mstack_epc_d;
	reg [5:0] mstack_cause_q;
	reg [5:0] mstack_cause_d;
	reg [31:0] pmp_addr_rdata [0:PMP_MAX_REGIONS - 1];
	wire [PMP_CFG_W - 1:0] pmp_cfg_rdata [0:PMP_MAX_REGIONS - 1];
	wire [31:0] mcountinhibit;
	reg [MHPMCounterNum + 2:0] mcountinhibit_d;
	reg [MHPMCounterNum + 2:0] mcountinhibit_q;
	reg mcountinhibit_we;
	wire [63:0] mhpmcounter [0:31];
	reg [31:0] mhpmcounter_we;
	reg [31:0] mhpmcounterh_we;
	reg [31:0] mhpmcounter_incr;
	reg [31:0] mhpmevent [0:31];
	wire [4:0] mhpmcounter_idx;
	wire [31:0] tselect_rdata;
	wire [31:0] tmatch_control_rdata;
	wire [31:0] tmatch_value_rdata;
	wire [31:0] cpuctrl_rdata;
	wire [31:0] cpuctrl_wdata;
	reg [31:0] csr_wdata_int;
	reg [31:0] csr_rdata_int;
	wire csr_we_int;
	wire csr_wreq;
	reg illegal_csr;
	wire illegal_csr_priv;
	wire illegal_csr_write;
	wire [7:0] unused_boot_addr;
	wire [2:0] unused_csr_addr;
	assign unused_boot_addr = boot_addr_i[7:0];
	wire [11:0] csr_addr;
	assign csr_addr = csr_addr_i;
	assign unused_csr_addr = csr_addr[7:5];
	assign mhpmcounter_idx = csr_addr[4:0];
	assign illegal_csr_priv = csr_addr[9:8] > priv_lvl_q;
	assign illegal_csr_write = (csr_addr[11:10] == 2'b11) && csr_wreq;
	assign illegal_csr_insn_o = csr_access_i & ((illegal_csr | illegal_csr_write) | illegal_csr_priv);
	assign mip[17] = irq_software_i;
	assign mip[16] = irq_timer_i;
	assign mip[15] = irq_external_i;
	assign mip[14-:15] = irq_fast_i;
	always @(*) begin
		csr_rdata_int = {32 {1'sb0}};
		illegal_csr = 1'b0;
		case (csr_addr_i)
			CSR_MHARTID: csr_rdata_int = hart_id_i;
			CSR_MSTATUS: begin
				csr_rdata_int = {32 {1'sb0}};
				csr_rdata_int[CSR_MSTATUS_MIE_BIT] = mstatus_q[5];
				csr_rdata_int[CSR_MSTATUS_MPIE_BIT] = mstatus_q[4];
				csr_rdata_int[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] = mstatus_q[3-:2];
				csr_rdata_int[CSR_MSTATUS_MPRV_BIT] = mstatus_q[1];
				csr_rdata_int[CSR_MSTATUS_TW_BIT] = mstatus_q[0];
			end
			CSR_MISA: csr_rdata_int = MISA_VALUE;
			CSR_MIE: begin
				csr_rdata_int = {32 {1'sb0}};
				csr_rdata_int[CSR_MSIX_BIT] = mie_q[17];
				csr_rdata_int[CSR_MTIX_BIT] = mie_q[16];
				csr_rdata_int[CSR_MEIX_BIT] = mie_q[15];
				csr_rdata_int[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW] = mie_q[14-:15];
			end
			CSR_MSCRATCH: csr_rdata_int = mscratch_q;
			CSR_MTVEC: csr_rdata_int = mtvec_q;
			CSR_MEPC: csr_rdata_int = mepc_q;
			CSR_MCAUSE: csr_rdata_int = {mcause_q[5], 26'b00000000000000000000000000, mcause_q[4:0]};
			CSR_MTVAL: csr_rdata_int = mtval_q;
			CSR_MIP: begin
				csr_rdata_int = {32 {1'sb0}};
				csr_rdata_int[CSR_MSIX_BIT] = mip[17];
				csr_rdata_int[CSR_MTIX_BIT] = mip[16];
				csr_rdata_int[CSR_MEIX_BIT] = mip[15];
				csr_rdata_int[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW] = mip[14-:15];
			end
			CSR_PMPCFG0: csr_rdata_int = {pmp_cfg_rdata[3], pmp_cfg_rdata[2], pmp_cfg_rdata[1], pmp_cfg_rdata[0]};
			CSR_PMPCFG1: csr_rdata_int = {pmp_cfg_rdata[7], pmp_cfg_rdata[6], pmp_cfg_rdata[5], pmp_cfg_rdata[4]};
			CSR_PMPCFG2: csr_rdata_int = {pmp_cfg_rdata[11], pmp_cfg_rdata[10], pmp_cfg_rdata[9], pmp_cfg_rdata[8]};
			CSR_PMPCFG3: csr_rdata_int = {pmp_cfg_rdata[15], pmp_cfg_rdata[14], pmp_cfg_rdata[13], pmp_cfg_rdata[12]};
			CSR_PMPADDR0: csr_rdata_int = pmp_addr_rdata[0];
			CSR_PMPADDR1: csr_rdata_int = pmp_addr_rdata[1];
			CSR_PMPADDR2: csr_rdata_int = pmp_addr_rdata[2];
			CSR_PMPADDR3: csr_rdata_int = pmp_addr_rdata[3];
			CSR_PMPADDR4: csr_rdata_int = pmp_addr_rdata[4];
			CSR_PMPADDR5: csr_rdata_int = pmp_addr_rdata[5];
			CSR_PMPADDR6: csr_rdata_int = pmp_addr_rdata[6];
			CSR_PMPADDR7: csr_rdata_int = pmp_addr_rdata[7];
			CSR_PMPADDR8: csr_rdata_int = pmp_addr_rdata[8];
			CSR_PMPADDR9: csr_rdata_int = pmp_addr_rdata[9];
			CSR_PMPADDR10: csr_rdata_int = pmp_addr_rdata[10];
			CSR_PMPADDR11: csr_rdata_int = pmp_addr_rdata[11];
			CSR_PMPADDR12: csr_rdata_int = pmp_addr_rdata[12];
			CSR_PMPADDR13: csr_rdata_int = pmp_addr_rdata[13];
			CSR_PMPADDR14: csr_rdata_int = pmp_addr_rdata[14];
			CSR_PMPADDR15: csr_rdata_int = pmp_addr_rdata[15];
			CSR_DCSR: begin
				csr_rdata_int = dcsr_q;
				illegal_csr = ~debug_mode_i;
			end
			CSR_DPC: begin
				csr_rdata_int = depc_q;
				illegal_csr = ~debug_mode_i;
			end
			CSR_DSCRATCH0: begin
				csr_rdata_int = dscratch0_q;
				illegal_csr = ~debug_mode_i;
			end
			CSR_DSCRATCH1: begin
				csr_rdata_int = dscratch1_q;
				illegal_csr = ~debug_mode_i;
			end
			CSR_MCOUNTINHIBIT: csr_rdata_int = mcountinhibit;
			CSR_MHPMEVENT3, CSR_MHPMEVENT4, CSR_MHPMEVENT5, CSR_MHPMEVENT6, CSR_MHPMEVENT7, CSR_MHPMEVENT8, CSR_MHPMEVENT9, CSR_MHPMEVENT10, CSR_MHPMEVENT11, CSR_MHPMEVENT12, CSR_MHPMEVENT13, CSR_MHPMEVENT14, CSR_MHPMEVENT15, CSR_MHPMEVENT16, CSR_MHPMEVENT17, CSR_MHPMEVENT18, CSR_MHPMEVENT19, CSR_MHPMEVENT20, CSR_MHPMEVENT21, CSR_MHPMEVENT22, CSR_MHPMEVENT23, CSR_MHPMEVENT24, CSR_MHPMEVENT25, CSR_MHPMEVENT26, CSR_MHPMEVENT27, CSR_MHPMEVENT28, CSR_MHPMEVENT29, CSR_MHPMEVENT30, CSR_MHPMEVENT31: csr_rdata_int = mhpmevent[mhpmcounter_idx];
			CSR_MCYCLE, CSR_MINSTRET, CSR_MHPMCOUNTER3, CSR_MHPMCOUNTER4, CSR_MHPMCOUNTER5, CSR_MHPMCOUNTER6, CSR_MHPMCOUNTER7, CSR_MHPMCOUNTER8, CSR_MHPMCOUNTER9, CSR_MHPMCOUNTER10, CSR_MHPMCOUNTER11, CSR_MHPMCOUNTER12, CSR_MHPMCOUNTER13, CSR_MHPMCOUNTER14, CSR_MHPMCOUNTER15, CSR_MHPMCOUNTER16, CSR_MHPMCOUNTER17, CSR_MHPMCOUNTER18, CSR_MHPMCOUNTER19, CSR_MHPMCOUNTER20, CSR_MHPMCOUNTER21, CSR_MHPMCOUNTER22, CSR_MHPMCOUNTER23, CSR_MHPMCOUNTER24, CSR_MHPMCOUNTER25, CSR_MHPMCOUNTER26, CSR_MHPMCOUNTER27, CSR_MHPMCOUNTER28, CSR_MHPMCOUNTER29, CSR_MHPMCOUNTER30, CSR_MHPMCOUNTER31: csr_rdata_int = mhpmcounter[mhpmcounter_idx][31:0];
			CSR_MCYCLEH, CSR_MINSTRETH, CSR_MHPMCOUNTER3H, CSR_MHPMCOUNTER4H, CSR_MHPMCOUNTER5H, CSR_MHPMCOUNTER6H, CSR_MHPMCOUNTER7H, CSR_MHPMCOUNTER8H, CSR_MHPMCOUNTER9H, CSR_MHPMCOUNTER10H, CSR_MHPMCOUNTER11H, CSR_MHPMCOUNTER12H, CSR_MHPMCOUNTER13H, CSR_MHPMCOUNTER14H, CSR_MHPMCOUNTER15H, CSR_MHPMCOUNTER16H, CSR_MHPMCOUNTER17H, CSR_MHPMCOUNTER18H, CSR_MHPMCOUNTER19H, CSR_MHPMCOUNTER20H, CSR_MHPMCOUNTER21H, CSR_MHPMCOUNTER22H, CSR_MHPMCOUNTER23H, CSR_MHPMCOUNTER24H, CSR_MHPMCOUNTER25H, CSR_MHPMCOUNTER26H, CSR_MHPMCOUNTER27H, CSR_MHPMCOUNTER28H, CSR_MHPMCOUNTER29H, CSR_MHPMCOUNTER30H, CSR_MHPMCOUNTER31H: csr_rdata_int = mhpmcounter[mhpmcounter_idx][63:32];
			CSR_TSELECT: begin
				csr_rdata_int = tselect_rdata;
				illegal_csr = ~DbgTriggerEn;
			end
			CSR_TDATA1: begin
				csr_rdata_int = tmatch_control_rdata;
				illegal_csr = ~DbgTriggerEn;
			end
			CSR_TDATA2: begin
				csr_rdata_int = tmatch_value_rdata;
				illegal_csr = ~DbgTriggerEn;
			end
			CSR_TDATA3: begin
				csr_rdata_int = {32 {1'sb0}};
				illegal_csr = ~DbgTriggerEn;
			end
			CSR_MCONTEXT: begin
				csr_rdata_int = {32 {1'sb0}};
				illegal_csr = ~DbgTriggerEn;
			end
			CSR_SCONTEXT: begin
				csr_rdata_int = {32 {1'sb0}};
				illegal_csr = ~DbgTriggerEn;
			end
			CSR_CPUCTRL: csr_rdata_int = cpuctrl_rdata;
			CSR_SECURESEED: csr_rdata_int = {32 {1'sb0}};
			default: illegal_csr = 1'b1;
		endcase
	end
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	always @(*) begin
		exception_pc = pc_id_i;
		priv_lvl_d = priv_lvl_q;
		mstatus_d = mstatus_q;
		mie_d = mie_q;
		mscratch_d = mscratch_q;
		mepc_d = mepc_q;
		mcause_d = mcause_q;
		mtval_d = mtval_q;
		mtvec_d = (csr_mtvec_init_i ? {boot_addr_i[31:8], 6'b000000, 2'b01} : mtvec_q);
		dcsr_d = dcsr_q;
		depc_d = depc_q;
		dscratch0_d = dscratch0_q;
		dscratch1_d = dscratch1_q;
		mstack_d = mstack_q;
		mstack_epc_d = mstack_epc_q;
		mstack_cause_d = mstack_cause_q;
		mcountinhibit_we = 1'b0;
		mhpmcounter_we = {32 {1'sb0}};
		mhpmcounterh_we = {32 {1'sb0}};
		if (csr_we_int)
			case (csr_addr_i)
				CSR_MSTATUS: begin
					mstatus_d = {sv2v_cast_1(csr_wdata_int[CSR_MSTATUS_MIE_BIT]), sv2v_cast_1(csr_wdata_int[CSR_MSTATUS_MPIE_BIT]), sv2v_cast_2(sv2v_cast_2(csr_wdata_int[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW])), sv2v_cast_1(csr_wdata_int[CSR_MSTATUS_MPRV_BIT]), sv2v_cast_1(csr_wdata_int[CSR_MSTATUS_TW_BIT])};
					if ((mstatus_d[3-:2] != PRIV_LVL_M) && (mstatus_d[3-:2] != PRIV_LVL_U))
						mstatus_d[3-:2] = PRIV_LVL_M;
				end
				CSR_MIE: begin
					mie_d[17] = csr_wdata_int[CSR_MSIX_BIT];
					mie_d[16] = csr_wdata_int[CSR_MTIX_BIT];
					mie_d[15] = csr_wdata_int[CSR_MEIX_BIT];
					mie_d[14-:15] = csr_wdata_int[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW];
				end
				CSR_MSCRATCH: mscratch_d = csr_wdata_int;
				CSR_MEPC: mepc_d = {csr_wdata_int[31:1], 1'b0};
				CSR_MCAUSE: mcause_d = {csr_wdata_int[31], csr_wdata_int[4:0]};
				CSR_MTVAL: mtval_d = csr_wdata_int;
				CSR_MTVEC: mtvec_d = {csr_wdata_int[31:8], 6'b000000, 2'b01};
				CSR_DCSR: begin
					dcsr_d = csr_wdata_int;
					dcsr_d[31-:4] = XDEBUGVER_STD;
					if ((dcsr_d[1-:2] != PRIV_LVL_M) && (dcsr_d[1-:2] != PRIV_LVL_U))
						dcsr_d[1-:2] = PRIV_LVL_M;
					dcsr_d[3] = 1'b0;
					dcsr_d[4] = 1'b0;
					dcsr_d[10] = 1'b0;
					dcsr_d[9] = 1'b0;
					dcsr_d[5] = 1'b0;
					dcsr_d[14] = 1'b0;
					dcsr_d[27-:12] = 12'h000;
				end
				CSR_DPC: depc_d = {csr_wdata_int[31:1], 1'b0};
				CSR_DSCRATCH0: dscratch0_d = csr_wdata_int;
				CSR_DSCRATCH1: dscratch1_d = csr_wdata_int;
				CSR_MCOUNTINHIBIT: mcountinhibit_we = 1'b1;
				CSR_MCYCLE, CSR_MINSTRET, CSR_MHPMCOUNTER3, CSR_MHPMCOUNTER4, CSR_MHPMCOUNTER5, CSR_MHPMCOUNTER6, CSR_MHPMCOUNTER7, CSR_MHPMCOUNTER8, CSR_MHPMCOUNTER9, CSR_MHPMCOUNTER10, CSR_MHPMCOUNTER11, CSR_MHPMCOUNTER12, CSR_MHPMCOUNTER13, CSR_MHPMCOUNTER14, CSR_MHPMCOUNTER15, CSR_MHPMCOUNTER16, CSR_MHPMCOUNTER17, CSR_MHPMCOUNTER18, CSR_MHPMCOUNTER19, CSR_MHPMCOUNTER20, CSR_MHPMCOUNTER21, CSR_MHPMCOUNTER22, CSR_MHPMCOUNTER23, CSR_MHPMCOUNTER24, CSR_MHPMCOUNTER25, CSR_MHPMCOUNTER26, CSR_MHPMCOUNTER27, CSR_MHPMCOUNTER28, CSR_MHPMCOUNTER29, CSR_MHPMCOUNTER30, CSR_MHPMCOUNTER31: mhpmcounter_we[mhpmcounter_idx] = 1'b1;
				CSR_MCYCLEH, CSR_MINSTRETH, CSR_MHPMCOUNTER3H, CSR_MHPMCOUNTER4H, CSR_MHPMCOUNTER5H, CSR_MHPMCOUNTER6H, CSR_MHPMCOUNTER7H, CSR_MHPMCOUNTER8H, CSR_MHPMCOUNTER9H, CSR_MHPMCOUNTER10H, CSR_MHPMCOUNTER11H, CSR_MHPMCOUNTER12H, CSR_MHPMCOUNTER13H, CSR_MHPMCOUNTER14H, CSR_MHPMCOUNTER15H, CSR_MHPMCOUNTER16H, CSR_MHPMCOUNTER17H, CSR_MHPMCOUNTER18H, CSR_MHPMCOUNTER19H, CSR_MHPMCOUNTER20H, CSR_MHPMCOUNTER21H, CSR_MHPMCOUNTER22H, CSR_MHPMCOUNTER23H, CSR_MHPMCOUNTER24H, CSR_MHPMCOUNTER25H, CSR_MHPMCOUNTER26H, CSR_MHPMCOUNTER27H, CSR_MHPMCOUNTER28H, CSR_MHPMCOUNTER29H, CSR_MHPMCOUNTER30H, CSR_MHPMCOUNTER31H: mhpmcounterh_we[mhpmcounter_idx] = 1'b1;
				default:
					;
			endcase
		case (1'b1)
			csr_save_cause_i: begin
				case (1'b1)
					csr_save_if_i: exception_pc = pc_if_i;
					csr_save_id_i: exception_pc = pc_id_i;
					csr_save_wb_i: exception_pc = pc_wb_i;
					default:
						;
				endcase
				priv_lvl_d = PRIV_LVL_M;
				if (debug_csr_save_i) begin
					dcsr_d[1-:2] = priv_lvl_q;
					dcsr_d[8-:3] = debug_cause_i;
					depc_d = exception_pc;
				end
				else if (!debug_mode_i) begin
					mtval_d = csr_mtval_i;
					mstatus_d[5] = 1'b0;
					mstatus_d[4] = mstatus_q[5];
					mstatus_d[3-:2] = priv_lvl_q;
					mepc_d = exception_pc;
					mcause_d = csr_mcause_i;
					mstack_d[2] = mstatus_q[4];
					mstack_d[1-:2] = mstatus_q[3-:2];
					mstack_epc_d = mepc_q;
					mstack_cause_d = mcause_q;
				end
			end
			csr_restore_dret_i: priv_lvl_d = dcsr_q[1-:2];
			csr_restore_mret_i: begin
				priv_lvl_d = mstatus_q[3-:2];
				mstatus_d[5] = mstatus_q[4];
				if (nmi_mode_i) begin
					mstatus_d[4] = mstack_q[2];
					mstatus_d[3-:2] = mstack_q[1-:2];
					mepc_d = mstack_epc_q;
					mcause_d = mstack_cause_q;
				end
				else begin
					mstatus_d[4] = 1'b1;
					mstatus_d[3-:2] = PRIV_LVL_U;
				end
			end
			default:
				;
		endcase
	end
	always @(*)
		case (csr_op_i)
			CSR_OP_WRITE: csr_wdata_int = csr_wdata_i;
			CSR_OP_SET: csr_wdata_int = csr_wdata_i | csr_rdata_o;
			CSR_OP_CLEAR: csr_wdata_int = ~csr_wdata_i & csr_rdata_o;
			CSR_OP_READ: csr_wdata_int = csr_wdata_i;
			default: csr_wdata_int = csr_wdata_i;
		endcase
	assign csr_wreq = csr_op_en_i & |{csr_op_i == CSR_OP_WRITE, csr_op_i == CSR_OP_SET, csr_op_i == CSR_OP_CLEAR};
	assign csr_we_int = csr_wreq & ~illegal_csr_insn_o;
	assign csr_rdata_o = csr_rdata_int;
	assign csr_mepc_o = mepc_q;
	assign csr_depc_o = depc_q;
	assign csr_mtvec_o = mtvec_q;
	assign csr_mstatus_mie_o = mstatus_q[5];
	assign csr_mstatus_tw_o = mstatus_q[0];
	assign debug_single_step_o = dcsr_q[2];
	assign debug_ebreakm_o = dcsr_q[15];
	assign debug_ebreaku_o = dcsr_q[12];
	assign irqs_o = mip & mie_q;
	assign irq_pending_o = |irqs_o;
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			priv_lvl_q <= PRIV_LVL_M;
			mstatus_q <= {1'b0, 1'b1, sv2v_cast_2(PRIV_LVL_U), 1'b0, 1'b0};
			mie_q <= {18 {1'sb0}};
			mscratch_q <= {32 {1'sb0}};
			mepc_q <= {32 {1'sb0}};
			mcause_q <= {6 {1'sb0}};
			mtval_q <= {32 {1'sb0}};
			mtvec_q <= 32'h00000001;
			dcsr_q <= {sv2v_cast_4(XDEBUGVER_STD), 12'b000000000000, 1'sb0, 1'sb0, 1'sb0, 1'sb0, 1'sb0, 1'sb0, 1'sb0, sv2v_cast_3(DBG_CAUSE_NONE), 1'sb0, 1'sb0, 1'sb0, 1'sb0, sv2v_cast_2(PRIV_LVL_M)};
			depc_q <= {32 {1'sb0}};
			dscratch0_q <= {32 {1'sb0}};
			dscratch1_q <= {32 {1'sb0}};
			mstack_q <= {1'b1, sv2v_cast_2(PRIV_LVL_U)};
			mstack_epc_q <= {32 {1'sb0}};
			mstack_cause_q <= {6 {1'sb0}};
		end
		else begin
			priv_lvl_q <= priv_lvl_d;
			mstatus_q <= mstatus_d;
			mie_q <= mie_d;
			mscratch_q <= mscratch_d;
			mepc_q <= mepc_d;
			mcause_q <= mcause_d;
			mtval_q <= mtval_d;
			mtvec_q <= mtvec_d;
			dcsr_q <= dcsr_d;
			depc_q <= depc_d;
			dscratch0_q <= dscratch0_d;
			dscratch1_q <= dscratch1_d;
			mstack_q <= mstack_d;
			mstack_epc_q <= mstack_epc_d;
			mstack_cause_q <= mstack_cause_d;
		end
	assign priv_mode_id_o = priv_lvl_q;
	assign priv_mode_if_o = priv_lvl_d;
	assign priv_mode_lsu_o = (mstatus_q[1] ? mstatus_q[3-:2] : priv_lvl_q);
	generate
		if (PMPEnable) begin : g_pmp_registers
			reg [5:0] pmp_cfg [0:PMPNumRegions - 1];
			reg [5:0] pmp_cfg_wdata [0:PMPNumRegions - 1];
			reg [31:0] pmp_addr [0:PMPNumRegions - 1];
			wire [PMPNumRegions - 1:0] pmp_cfg_we;
			wire [PMPNumRegions - 1:0] pmp_addr_we;
			genvar i;
			for (i = 0; i < PMP_MAX_REGIONS; i = i + 1) begin : g_exp_rd_data
				if (i < PMPNumRegions) begin : g_implemented_regions
					assign pmp_cfg_rdata[i] = {pmp_cfg[i][5], 2'b00, pmp_cfg[i][4-:2], pmp_cfg[i][2], pmp_cfg[i][1], pmp_cfg[i][0]};
					if (PMPGranularity == 0) begin : g_pmp_g0
						always @(*) pmp_addr_rdata[i] = pmp_addr[i];
					end
					else if (PMPGranularity == 1) begin : g_pmp_g1
						always @(*) begin
							pmp_addr_rdata[i] = pmp_addr[i];
							if ((pmp_cfg[i][4-:2] == PMP_MODE_OFF) || (pmp_cfg[i][4-:2] == PMP_MODE_TOR))
								pmp_addr_rdata[i][PMPGranularity - 1:0] = {PMPGranularity {1'sb0}};
						end
					end
					else begin : g_pmp_g2
						always @(*) begin
							pmp_addr_rdata[i] = pmp_addr[i];
							if ((pmp_cfg[i][4-:2] == PMP_MODE_OFF) || (pmp_cfg[i][4-:2] == PMP_MODE_TOR))
								pmp_addr_rdata[i][PMPGranularity - 1:0] = {PMPGranularity {1'sb0}};
							else if (pmp_cfg[i][4-:2] == PMP_MODE_NAPOT)
								pmp_addr_rdata[i][PMPGranularity - 2:0] = {((PMPGranularity - 2) >= 0 ? PMPGranularity - 1 : 3 - PMPGranularity) {1'sb1}};
						end
					end
				end
				else begin : g_other_regions
					assign pmp_cfg_rdata[i] = {PMP_CFG_W {1'sb0}};
					always @(*) pmp_addr_rdata[i] = {32 {1'sb0}};
				end
			end
			for (i = 0; i < PMPNumRegions; i = i + 1) begin : g_pmp_csrs
				assign pmp_cfg_we[i] = (csr_we_int & ~pmp_cfg[i][5]) & (csr_addr == (CSR_OFF_PMP_CFG + (i[11:0] >> 2)));
				always @(*) pmp_cfg_wdata[i][5] = csr_wdata_int[((i % 4) * PMP_CFG_W) + 7];
				always @(*)
					case (csr_wdata_int[((i % 4) * PMP_CFG_W) + 3+:2])
						2'b00: pmp_cfg_wdata[i][4-:2] = PMP_MODE_OFF;
						2'b01: pmp_cfg_wdata[i][4-:2] = PMP_MODE_TOR;
						2'b10: pmp_cfg_wdata[i][4-:2] = (PMPGranularity == 0 ? PMP_MODE_NA4 : PMP_MODE_OFF);
						2'b11: pmp_cfg_wdata[i][4-:2] = PMP_MODE_NAPOT;
						default: pmp_cfg_wdata[i][4-:2] = PMP_MODE_OFF;
					endcase
				always @(*) pmp_cfg_wdata[i][2] = csr_wdata_int[((i % 4) * PMP_CFG_W) + 2];
				always @(*) pmp_cfg_wdata[i][1] = &csr_wdata_int[(i % 4) * PMP_CFG_W+:2];
				always @(*) pmp_cfg_wdata[i][0] = csr_wdata_int[(i % 4) * PMP_CFG_W];
				function automatic [5:0] sv2v_cast_6;
					input reg [5:0] inp;
					sv2v_cast_6 = inp;
				endfunction
				always @(posedge clk_i or negedge rst_ni)
					if (!rst_ni)
						pmp_cfg[i] <= sv2v_cast_6('b0);
					else if (pmp_cfg_we[i])
						pmp_cfg[i] <= pmp_cfg_wdata[i];
				if (i < (PMPNumRegions - 1)) begin : g_lower
					assign pmp_addr_we[i] = ((csr_we_int & ~pmp_cfg[i][5]) & (~pmp_cfg[i + 1][5] | (pmp_cfg[i + 1][4-:2] != PMP_MODE_TOR))) & (csr_addr == (CSR_OFF_PMP_ADDR + i[11:0]));
				end
				else begin : g_upper
					assign pmp_addr_we[i] = (csr_we_int & ~pmp_cfg[i][5]) & (csr_addr == (CSR_OFF_PMP_ADDR + i[11:0]));
				end
				always @(posedge clk_i or negedge rst_ni)
					if (!rst_ni)
						pmp_addr[i] <= 'b0;
					else if (pmp_addr_we[i])
						pmp_addr[i] <= csr_wdata_int;
				assign csr_pmp_cfg_o[(0 >= (PMPNumRegions - 1) ? i : (PMPNumRegions - 1) - i) * 6+:6] = pmp_cfg[i];
				assign csr_pmp_addr_o[(0 >= (PMPNumRegions - 1) ? i : (PMPNumRegions - 1) - i) * 34+:34] = {pmp_addr[i], 2'b00};
			end
		end
		else begin : g_no_pmp_tieoffs
			genvar i;
			for (i = 0; i < PMP_MAX_REGIONS; i = i + 1) begin : g_rdata
				always @(*) pmp_addr_rdata[i] = {32 {1'sb0}};
				assign pmp_cfg_rdata[i] = {PMP_CFG_W {1'sb0}};
			end
			for (i = 0; i < PMPNumRegions; i = i + 1) begin : g_outputs
				function automatic [5:0] sv2v_cast_6;
					input reg [5:0] inp;
					sv2v_cast_6 = inp;
				endfunction
				assign csr_pmp_cfg_o[(0 >= (PMPNumRegions - 1) ? i : (PMPNumRegions - 1) - i) * 6+:6] = sv2v_cast_6(1'b0);
				assign csr_pmp_addr_o[(0 >= (PMPNumRegions - 1) ? i : (PMPNumRegions - 1) - i) * 34+:34] = {34 {1'sb0}};
			end
		end
	endgenerate
	always @(*) begin : mcountinhibit_update
		if (mcountinhibit_we == 1'b1)
			mcountinhibit_d = {csr_wdata_int[MHPMCounterNum + 2:2], 1'b0, csr_wdata_int[0]};
		else
			mcountinhibit_d = mcountinhibit_q;
	end
	always @(*) begin : gen_mhpmcounter_incr
		begin : sv2v_autoblock_53
			reg [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				begin : gen_mhpmcounter_incr_inactive
					mhpmcounter_incr[i] = 1'b0;
				end
		end
		mhpmcounter_incr[0] = 1'b1;
		mhpmcounter_incr[1] = 1'b0;
		mhpmcounter_incr[2] = instr_ret_i;
		mhpmcounter_incr[3] = dside_wait_i;
		mhpmcounter_incr[4] = iside_wait_i;
		mhpmcounter_incr[5] = mem_load_i;
		mhpmcounter_incr[6] = mem_store_i;
		mhpmcounter_incr[7] = jump_i;
		mhpmcounter_incr[8] = branch_i;
		mhpmcounter_incr[9] = branch_taken_i;
		mhpmcounter_incr[10] = instr_ret_compressed_i;
		mhpmcounter_incr[11] = mul_wait_i;
		mhpmcounter_incr[12] = div_wait_i;
	end
	always @(*) begin : gen_mhpmevent
		begin : sv2v_autoblock_54
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				begin : gen_mhpmevent_active
					mhpmevent[i] = {32 {1'sb0}};
					mhpmevent[i][i] = 1'b1;
				end
		end
		mhpmevent[1] = {32 {1'sb0}};
		begin : sv2v_autoblock_55
			reg [31:0] i;
			for (i = 3 + MHPMCounterNum; i < 32; i = i + 1)
				begin : gen_mhpmevent_inactive
					mhpmevent[i] = {32 {1'sb0}};
				end
		end
	end
	brqrv_csr_mcounter #(.CounterWidth(64)) mcycle_counter_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.counter_inc_i(mhpmcounter_incr[0] & ~mcountinhibit[0]),
		.counterh_we_i(mhpmcounterh_we[0]),
		.counter_we_i(mhpmcounter_we[0]),
		.counter_val_i(csr_wdata_int),
		.counter_val_o(mhpmcounter[0])
	);
	brqrv_csr_mcounter #(.CounterWidth(64)) minstret_counter_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.counter_inc_i(mhpmcounter_incr[2] & ~mcountinhibit[2]),
		.counterh_we_i(mhpmcounterh_we[2]),
		.counter_we_i(mhpmcounter_we[2]),
		.counter_val_i(csr_wdata_int),
		.counter_val_o(mhpmcounter[2])
	);
	assign mhpmcounter[1] = {64 {1'sb0}};
	generate
		genvar cnt;
		for (cnt = 0; cnt < MHPMCounterNum; cnt = cnt + 1) begin : gen_cntrs
			brqrv_csr_mcounter #(.CounterWidth(MHPMCounterWidth)) mcounters_variable_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.counter_inc_i(mhpmcounter_incr[cnt + 3] & ~mcountinhibit[cnt + 3]),
				.counterh_we_i(mhpmcounterh_we[cnt + 3]),
				.counter_we_i(mhpmcounter_we[cnt + 3]),
				.counter_val_i(csr_wdata_int),
				.counter_val_o(mhpmcounter[cnt + 3])
			);
		end
	endgenerate
	generate
		if (MHPMCounterNum < 29) begin : g_mcountinhibit_reduced
			wire [(29 - MHPMCounterNum) - 1:0] unused_mhphcounter_we;
			wire [(29 - MHPMCounterNum) - 1:0] unused_mhphcounterh_we;
			wire [(29 - MHPMCounterNum) - 1:0] unused_mhphcounter_incr;
			assign mcountinhibit = {{29 - MHPMCounterNum {1'b1}}, mcountinhibit_q};
			assign unused_mhphcounter_we = mhpmcounter_we[31:MHPMCounterNum + 3];
			assign unused_mhphcounterh_we = mhpmcounterh_we[31:MHPMCounterNum + 3];
			assign unused_mhphcounter_incr = mhpmcounter_incr[31:MHPMCounterNum + 3];
		end
		else begin : g_mcountinhibit_full
			assign mcountinhibit = mcountinhibit_q;
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			mcountinhibit_q <= {((MHPMCounterNum + 2) >= 0 ? MHPMCounterNum + 3 : 1 - (MHPMCounterNum + 2)) {1'sb0}};
		else
			mcountinhibit_q <= mcountinhibit_d;
	generate
		if (DbgTriggerEn) begin : gen_trigger_regs
			wire tmatch_control_d;
			reg tmatch_control_q;
			wire [31:0] tmatch_value_d;
			reg [31:0] tmatch_value_q;
			wire tmatch_control_we;
			wire tmatch_value_we;
			assign tmatch_control_we = (csr_we_int & debug_mode_i) & (csr_addr_i == CSR_TDATA1);
			assign tmatch_value_we = (csr_we_int & debug_mode_i) & (csr_addr_i == CSR_TDATA2);
			assign tmatch_control_d = (tmatch_control_we ? csr_wdata_int[2] : tmatch_control_q);
			assign tmatch_value_d = csr_wdata_int[31:0];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					tmatch_control_q <= 'b0;
				else
					tmatch_control_q <= tmatch_control_d;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					tmatch_value_q <= 'b0;
				else if (tmatch_value_we)
					tmatch_value_q <= tmatch_value_d;
			assign tselect_rdata = 'b0;
			assign tmatch_control_rdata = {4'h2, 1'b1, 6'h00, 1'b0, 1'b0, 1'b0, 2'b00, 4'h1, 1'b0, 4'h0, 1'b1, 1'b0, 1'b0, 1'b1, tmatch_control_q, 1'b0, 1'b0};
			assign tmatch_value_rdata = tmatch_value_q;
			assign trigger_match_o = tmatch_control_q & (pc_if_i[31:0] == tmatch_value_q[31:0]);
		end
		else begin : gen_no_trigger_regs
			assign tselect_rdata = 'b0;
			assign tmatch_control_rdata = 'b0;
			assign tmatch_value_rdata = 'b0;
			assign trigger_match_o = 'b0;
		end
	endgenerate
	assign cpuctrl_rdata[31-:26] = {26 {1'sb0}};
	assign cpuctrl_wdata = sv2v_cast_32(csr_wdata_int);
	generate
		if (DataIndTiming) begin : gen_dit
			wire data_ind_timing_d;
			reg data_ind_timing_q;
			assign data_ind_timing_d = (csr_we_int && (csr_addr == CSR_CPUCTRL) ? cpuctrl_wdata[1] : data_ind_timing_q);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					data_ind_timing_q <= 1'b0;
				else
					data_ind_timing_q <= data_ind_timing_d;
			assign cpuctrl_rdata[1] = data_ind_timing_q;
		end
		else begin : gen_no_dit
			wire unused_dit;
			assign unused_dit = cpuctrl_wdata[1];
			assign cpuctrl_rdata[1] = 1'b0;
		end
	endgenerate
	assign data_ind_timing_o = cpuctrl_rdata[1];
	generate
		if (DummyInstructions) begin : gen_dummy
			wire dummy_instr_en_d;
			reg dummy_instr_en_q;
			wire [2:0] dummy_instr_mask_d;
			reg [2:0] dummy_instr_mask_q;
			assign dummy_instr_en_d = (csr_we_int && (csr_addr == CSR_CPUCTRL) ? cpuctrl_wdata[2] : dummy_instr_en_q);
			assign dummy_instr_mask_d = (csr_we_int && (csr_addr == CSR_CPUCTRL) ? cpuctrl_wdata[5-:3] : dummy_instr_mask_q);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni) begin
					dummy_instr_en_q <= 1'b0;
					dummy_instr_mask_q <= 3'b000;
				end
				else begin
					dummy_instr_en_q <= dummy_instr_en_d;
					dummy_instr_mask_q <= dummy_instr_mask_d;
				end
			assign cpuctrl_rdata[2] = dummy_instr_en_q;
			assign cpuctrl_rdata[5-:3] = dummy_instr_mask_q;
			assign dummy_instr_seed_en_o = csr_we_int && (csr_addr == CSR_SECURESEED);
			assign dummy_instr_seed_o = csr_wdata_int;
		end
		else begin : gen_no_dummy
			wire unused_dummy_en;
			wire [2:0] unused_dummy_mask;
			assign unused_dummy_en = cpuctrl_wdata[2];
			assign unused_dummy_mask = cpuctrl_wdata[5-:3];
			assign cpuctrl_rdata[2] = 1'b0;
			assign cpuctrl_rdata[5-:3] = 3'b000;
			assign dummy_instr_seed_en_o = 1'b0;
			assign dummy_instr_seed_o = {32 {1'sb0}};
		end
	endgenerate
	assign dummy_instr_en_o = cpuctrl_rdata[2];
	assign dummy_instr_mask_o = cpuctrl_rdata[5-:3];
	generate
		if (ICache) begin : gen_icache_enable
			wire icache_enable_d;
			reg icache_enable_q;
			assign icache_enable_d = (csr_we_int & (csr_addr == CSR_CPUCTRL) ? cpuctrl_wdata[0] : icache_enable_q);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					icache_enable_q <= 1'b0;
				else
					icache_enable_q <= icache_enable_d;
			assign cpuctrl_rdata[0] = icache_enable_q;
		end
		else begin : gen_no_icache
			wire unused_icen;
			assign unused_icen = cpuctrl_wdata[0];
			assign cpuctrl_rdata[0] = 1'b0;
		end
	endgenerate
	assign icache_enable_o = cpuctrl_rdata[0];
	wire [31:6] unused_cpuctrl;
	assign unused_cpuctrl = cpuctrl_wdata[31:6];
endmodule
module brqrv_csr_mcounter (
	clk_i,
	rst_ni,
	counter_inc_i,
	counterh_we_i,
	counter_we_i,
	counter_val_i,
	counter_val_o
);
	parameter signed [31:0] CounterWidth = 32;
	input wire clk_i;
	input wire rst_ni;
	input wire counter_inc_i;
	input wire counterh_we_i;
	input wire counter_we_i;
	input wire [31:0] counter_val_i;
	output wire [63:0] counter_val_o;
	wire [63:0] counter;
	reg [CounterWidth - 1:0] counter_upd;
	reg [63:0] counter_load;
	reg we;
	reg [CounterWidth - 1:0] counter_d;
	always @(*) begin
		we = counter_we_i | counterh_we_i;
		counter_load[63:32] = counter[63:32];
		counter_load[31:0] = counter_val_i;
		if (counterh_we_i) begin
			counter_load[63:32] = counter_val_i;
			counter_load[31:0] = counter[31:0];
		end
		counter_upd = counter[CounterWidth - 1:0] + {{CounterWidth - 1 {1'b0}}, 1'b1};
		if (we)
			counter_d = counter_load[CounterWidth - 1:0];
		else if (counter_inc_i)
			counter_d = counter_upd[CounterWidth - 1:0];
		else
			counter_d = counter[CounterWidth - 1:0];
	end
	reg [CounterWidth - 1:0] counter_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			counter_q <= {CounterWidth {1'sb0}};
		else
			counter_q <= counter_d;
	generate
		if (CounterWidth < 64) begin : g_counter_narrow
			wire [63:CounterWidth] unused_counter_load;
			assign counter[CounterWidth - 1:0] = counter_q;
			assign counter[63:CounterWidth] = {(63 >= CounterWidth ? 64 - CounterWidth : CounterWidth - 62) {1'sb0}};
			assign unused_counter_load = counter_load[63:CounterWidth];
		end
		else begin : g_counter_full
			assign counter = counter_q;
		end
	endgenerate
	assign counter_val_o = counter;
endmodule
module brqrv_exu (
	clk_i,
	rst_ni,
	alu_operator_i,
	alu_operand_a_i,
	alu_operand_b_i,
	alu_instr_first_cycle_i,
	bt_a_operand_i,
	bt_b_operand_i,
	multdiv_operator_i,
	mult_en_i,
	div_en_i,
	mult_sel_i,
	div_sel_i,
	multdiv_signed_mode_i,
	multdiv_operand_a_i,
	multdiv_operand_b_i,
	multdiv_ready_id_i,
	data_ind_timing_i,
	imd_val_we_o,
	imd_val_d_o,
	imd_val_q_i,
	alu_adder_result_ex_o,
	result_ex_o,
	branch_target_o,
	branch_decision_o,
	ex_valid_o
);
	localparam integer brqrv_pkg_RV32MFast = 2;
	parameter integer RV32M = brqrv_pkg_RV32MFast;
	localparam integer brqrv_pkg_RV32BNone = 0;
	parameter integer RV32B = brqrv_pkg_RV32BNone;
	parameter [0:0] BranchTargetALU = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire [5:0] alu_operator_i;
	input wire [31:0] alu_operand_a_i;
	input wire [31:0] alu_operand_b_i;
	input wire alu_instr_first_cycle_i;
	input wire [31:0] bt_a_operand_i;
	input wire [31:0] bt_b_operand_i;
	input wire [1:0] multdiv_operator_i;
	input wire mult_en_i;
	input wire div_en_i;
	input wire mult_sel_i;
	input wire div_sel_i;
	input wire [1:0] multdiv_signed_mode_i;
	input wire [31:0] multdiv_operand_a_i;
	input wire [31:0] multdiv_operand_b_i;
	input wire multdiv_ready_id_i;
	input wire data_ind_timing_i;
	output wire [1:0] imd_val_we_o;
	output wire [67:0] imd_val_d_o;
	input wire [67:0] imd_val_q_i;
	output wire [31:0] alu_adder_result_ex_o;
	output wire [31:0] result_ex_o;
	output wire [31:0] branch_target_o;
	output wire branch_decision_o;
	output wire ex_valid_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	wire [31:0] alu_result;
	wire [31:0] multdiv_result;
	wire [32:0] multdiv_alu_operand_b;
	wire [32:0] multdiv_alu_operand_a;
	wire [33:0] alu_adder_result_ext;
	wire alu_cmp_result;
	wire alu_is_equal_result;
	wire multdiv_valid;
	wire multdiv_sel;
	wire [63:0] alu_imd_val_q;
	wire [63:0] alu_imd_val_d;
	wire [1:0] alu_imd_val_we;
	wire [67:0] multdiv_imd_val_d;
	wire [1:0] multdiv_imd_val_we;
	generate
		if (RV32M != RV32MNone) begin : gen_multdiv_m
			assign multdiv_sel = mult_sel_i | div_sel_i;
		end
		else begin : gen_multdiv_no_m
			assign multdiv_sel = 1'b0;
		end
	endgenerate
	assign imd_val_d_o[34+:34] = (multdiv_sel ? multdiv_imd_val_d[34+:34] : {2'b00, alu_imd_val_d[32+:32]});
	assign imd_val_d_o[0+:34] = (multdiv_sel ? multdiv_imd_val_d[0+:34] : {2'b00, alu_imd_val_d[0+:32]});
	assign imd_val_we_o = (multdiv_sel ? multdiv_imd_val_we : alu_imd_val_we);
	assign alu_imd_val_q = {imd_val_q_i[65-:32], imd_val_q_i[31-:32]};
	assign result_ex_o = (multdiv_sel ? multdiv_result : alu_result);
	assign branch_decision_o = alu_cmp_result;
	generate
		if (BranchTargetALU) begin : g_branch_target_alu
			wire [32:0] bt_alu_result;
			wire unused_bt_carry;
			assign bt_alu_result = bt_a_operand_i + bt_b_operand_i;
			assign unused_bt_carry = bt_alu_result[32];
			assign branch_target_o = bt_alu_result[31:0];
		end
		else begin : g_no_branch_target_alu
			wire [31:0] unused_bt_a_operand;
			wire [31:0] unused_bt_b_operand;
			assign unused_bt_a_operand = bt_a_operand_i;
			assign unused_bt_b_operand = bt_b_operand_i;
			assign branch_target_o = alu_adder_result_ex_o;
		end
	endgenerate
	brqrv_exu_alu #(.RV32B(RV32B)) alu_i(
		.operator_i(alu_operator_i),
		.operand_a_i(alu_operand_a_i),
		.operand_b_i(alu_operand_b_i),
		.instr_first_cycle_i(alu_instr_first_cycle_i),
		.imd_val_q_i(alu_imd_val_q),
		.imd_val_we_o(alu_imd_val_we),
		.imd_val_d_o(alu_imd_val_d),
		.multdiv_operand_a_i(multdiv_alu_operand_a),
		.multdiv_operand_b_i(multdiv_alu_operand_b),
		.multdiv_sel_i(multdiv_sel),
		.adder_result_o(alu_adder_result_ex_o),
		.adder_result_ext_o(alu_adder_result_ext),
		.result_o(alu_result),
		.comparison_result_o(alu_cmp_result),
		.is_equal_result_o(alu_is_equal_result)
	);
	generate
		if (RV32M == RV32MSlow) begin : gen_multdiv_slow
			brqrv_exu_multdiv_slow multdiv_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.mult_en_i(mult_en_i),
				.div_en_i(div_en_i),
				.mult_sel_i(mult_sel_i),
				.div_sel_i(div_sel_i),
				.operator_i(multdiv_operator_i),
				.signed_mode_i(multdiv_signed_mode_i),
				.op_a_i(multdiv_operand_a_i),
				.op_b_i(multdiv_operand_b_i),
				.alu_adder_ext_i(alu_adder_result_ext),
				.alu_adder_i(alu_adder_result_ex_o),
				.equal_to_zero_i(alu_is_equal_result),
				.data_ind_timing_i(data_ind_timing_i),
				.valid_o(multdiv_valid),
				.alu_operand_a_o(multdiv_alu_operand_a),
				.alu_operand_b_o(multdiv_alu_operand_b),
				.imd_val_q_i(imd_val_q_i),
				.imd_val_d_o(multdiv_imd_val_d),
				.imd_val_we_o(multdiv_imd_val_we),
				.multdiv_ready_id_i(multdiv_ready_id_i),
				.multdiv_result_o(multdiv_result)
			);
		end
		else if ((RV32M == RV32MFast) || (RV32M == RV32MSingleCycle)) begin : gen_multdiv_fast
			brqrv_exu_multdiv_fast #(.RV32M(RV32M)) multdiv_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.mult_en_i(mult_en_i),
				.div_en_i(div_en_i),
				.mult_sel_i(mult_sel_i),
				.div_sel_i(div_sel_i),
				.operator_i(multdiv_operator_i),
				.signed_mode_i(multdiv_signed_mode_i),
				.op_a_i(multdiv_operand_a_i),
				.op_b_i(multdiv_operand_b_i),
				.alu_operand_a_o(multdiv_alu_operand_a),
				.alu_operand_b_o(multdiv_alu_operand_b),
				.alu_adder_ext_i(alu_adder_result_ext),
				.alu_adder_i(alu_adder_result_ex_o),
				.equal_to_zero_i(alu_is_equal_result),
				.data_ind_timing_i(data_ind_timing_i),
				.imd_val_q_i(imd_val_q_i),
				.imd_val_d_o(multdiv_imd_val_d),
				.imd_val_we_o(multdiv_imd_val_we),
				.multdiv_ready_id_i(multdiv_ready_id_i),
				.valid_o(multdiv_valid),
				.multdiv_result_o(multdiv_result)
			);
		end
	endgenerate
	assign ex_valid_o = (multdiv_sel ? multdiv_valid : ~(|alu_imd_val_we));
endmodule
module brqrv_exu_alu (
	operator_i,
	operand_a_i,
	operand_b_i,
	instr_first_cycle_i,
	multdiv_operand_a_i,
	multdiv_operand_b_i,
	multdiv_sel_i,
	imd_val_q_i,
	imd_val_d_o,
	imd_val_we_o,
	adder_result_o,
	adder_result_ext_o,
	result_o,
	comparison_result_o,
	is_equal_result_o
);
	localparam integer brqrv_pkg_RV32BNone = 0;
	parameter integer RV32B = brqrv_pkg_RV32BNone;
	input wire [5:0] operator_i;
	input wire [31:0] operand_a_i;
	input wire [31:0] operand_b_i;
	input wire instr_first_cycle_i;
	input wire [32:0] multdiv_operand_a_i;
	input wire [32:0] multdiv_operand_b_i;
	input wire multdiv_sel_i;
	input wire [63:0] imd_val_q_i;
	output reg [63:0] imd_val_d_o;
	output reg [1:0] imd_val_we_o;
	output wire [31:0] adder_result_o;
	output wire [33:0] adder_result_ext_o;
	output reg [31:0] result_o;
	output wire comparison_result_o;
	output wire is_equal_result_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	wire [31:0] operand_a_rev;
	wire [32:0] operand_b_neg;
	generate
		genvar k;
		for (k = 0; k < 32; k = k + 1) begin : gen_rev_operand_a
			assign operand_a_rev[k] = operand_a_i[31 - k];
		end
	endgenerate
	reg adder_op_b_negate;
	wire [32:0] adder_in_a;
	reg [32:0] adder_in_b;
	wire [31:0] adder_result;
	always @(*) begin
		adder_op_b_negate = 1'b0;
		case (operator_i)
			ALU_SUB, ALU_EQ, ALU_NE, ALU_GE, ALU_GEU, ALU_LT, ALU_LTU, ALU_SLT, ALU_SLTU, ALU_MIN, ALU_MINU, ALU_MAX, ALU_MAXU: adder_op_b_negate = 1'b1;
			default:
				;
		endcase
	end
	assign adder_in_a = (multdiv_sel_i ? multdiv_operand_a_i : {operand_a_i, 1'b1});
	assign operand_b_neg = {operand_b_i, 1'b0} ^ {33 {1'b1}};
	always @(*)
		case (1'b1)
			multdiv_sel_i: adder_in_b = multdiv_operand_b_i;
			adder_op_b_negate: adder_in_b = operand_b_neg;
			default: adder_in_b = {operand_b_i, 1'b0};
		endcase
	assign adder_result_ext_o = $unsigned(adder_in_a) + $unsigned(adder_in_b);
	assign adder_result = adder_result_ext_o[32:1];
	assign adder_result_o = adder_result;
	wire is_equal;
	reg is_greater_equal;
	reg cmp_signed;
	always @(*)
		case (operator_i)
			ALU_GE, ALU_LT, ALU_SLT, ALU_MIN, ALU_MAX: cmp_signed = 1'b1;
			default: cmp_signed = 1'b0;
		endcase
	assign is_equal = adder_result == 32'b00000000000000000000000000000000;
	assign is_equal_result_o = is_equal;
	always @(*)
		if ((operand_a_i[31] ^ operand_b_i[31]) == 1'b0)
			is_greater_equal = adder_result[31] == 1'b0;
		else
			is_greater_equal = operand_a_i[31] ^ cmp_signed;
	reg cmp_result;
	always @(*)
		case (operator_i)
			ALU_EQ: cmp_result = is_equal;
			ALU_NE: cmp_result = ~is_equal;
			ALU_GE, ALU_GEU, ALU_MAX, ALU_MAXU: cmp_result = is_greater_equal;
			ALU_LT, ALU_LTU, ALU_MIN, ALU_MINU, ALU_SLT, ALU_SLTU: cmp_result = ~is_greater_equal;
			default: cmp_result = is_equal;
		endcase
	assign comparison_result_o = cmp_result;
	reg shift_left;
	wire shift_ones;
	wire shift_arith;
	wire shift_funnel;
	wire shift_sbmode;
	reg [5:0] shift_amt;
	wire [5:0] shift_amt_compl;
	reg [31:0] shift_result;
	reg [32:0] shift_result_ext;
	reg [31:0] shift_result_rev;
	wire bfp_op;
	wire [4:0] bfp_len;
	wire [4:0] bfp_off;
	wire [31:0] bfp_mask;
	wire [31:0] bfp_mask_rev;
	wire [31:0] bfp_result;
	assign bfp_op = (RV32B != RV32BNone ? operator_i == ALU_BFP : 1'b0);
	assign bfp_len = {~(|operand_b_i[27:24]), operand_b_i[27:24]};
	assign bfp_off = operand_b_i[20:16];
	assign bfp_mask = (RV32B != RV32BNone ? ~(32'hffffffff << bfp_len) : {32 {1'sb0}});
	generate
		genvar i;
		for (i = 0; i < 32; i = i + 1) begin : gen_rev_bfp_mask
			assign bfp_mask_rev[i] = bfp_mask[31 - i];
		end
	endgenerate
	assign bfp_result = (RV32B != RV32BNone ? (~shift_result & operand_a_i) | ((operand_b_i & bfp_mask) << bfp_off) : {32 {1'sb0}});
	always @(*) shift_amt[5] = operand_b_i[5] & shift_funnel;
	assign shift_amt_compl = 32 - operand_b_i[4:0];
	always @(*)
		if (bfp_op)
			shift_amt[4:0] = bfp_off;
		else
			shift_amt[4:0] = (instr_first_cycle_i ? (operand_b_i[5] && shift_funnel ? shift_amt_compl[4:0] : operand_b_i[4:0]) : (operand_b_i[5] && shift_funnel ? operand_b_i[4:0] : shift_amt_compl[4:0]));
	assign shift_sbmode = (RV32B != RV32BNone ? ((operator_i == ALU_SBSET) | (operator_i == ALU_SBCLR)) | (operator_i == ALU_SBINV) : 1'b0);
	always @(*) begin
		case (operator_i)
			ALU_SLL: shift_left = 1'b1;
			ALU_SLO, ALU_BFP: shift_left = (RV32B != RV32BNone ? 1'b1 : 1'b0);
			ALU_ROL: shift_left = (RV32B != RV32BNone ? instr_first_cycle_i : 0);
			ALU_ROR: shift_left = (RV32B != RV32BNone ? ~instr_first_cycle_i : 0);
			ALU_FSL: shift_left = (RV32B != RV32BNone ? (shift_amt[5] ? ~instr_first_cycle_i : instr_first_cycle_i) : 1'b0);
			ALU_FSR: shift_left = (RV32B != RV32BNone ? (shift_amt[5] ? instr_first_cycle_i : ~instr_first_cycle_i) : 1'b0);
			default: shift_left = 1'b0;
		endcase
		if (shift_sbmode)
			shift_left = 1'b1;
	end
	assign shift_arith = operator_i == ALU_SRA;
	assign shift_ones = (RV32B != RV32BNone ? (operator_i == ALU_SLO) | (operator_i == ALU_SRO) : 1'b0);
	assign shift_funnel = (RV32B != RV32BNone ? (operator_i == ALU_FSL) | (operator_i == ALU_FSR) : 1'b0);
	always @(*) begin
		if (RV32B == RV32BNone)
			shift_result = (shift_left ? operand_a_rev : operand_a_i);
		else
			case (1'b1)
				bfp_op: shift_result = bfp_mask_rev;
				shift_sbmode: shift_result = 32'h80000000;
				default: shift_result = (shift_left ? operand_a_rev : operand_a_i);
			endcase
		shift_result_ext = $signed({shift_ones | (shift_arith & shift_result[31]), shift_result}) >>> shift_amt[4:0];
		shift_result = shift_result_ext[31:0];
		begin : sv2v_autoblock_56
			reg [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				shift_result_rev[i] = shift_result[31 - i];
		end
		shift_result = (shift_left ? shift_result_rev : shift_result);
	end
	wire bwlogic_or;
	wire bwlogic_and;
	wire [31:0] bwlogic_operand_b;
	wire [31:0] bwlogic_or_result;
	wire [31:0] bwlogic_and_result;
	wire [31:0] bwlogic_xor_result;
	reg [31:0] bwlogic_result;
	reg bwlogic_op_b_negate;
	always @(*)
		case (operator_i)
			ALU_XNOR, ALU_ORN, ALU_ANDN: bwlogic_op_b_negate = (RV32B != RV32BNone ? 1'b1 : 1'b0);
			ALU_CMIX: bwlogic_op_b_negate = (RV32B != RV32BNone ? ~instr_first_cycle_i : 1'b0);
			default: bwlogic_op_b_negate = 1'b0;
		endcase
	assign bwlogic_operand_b = (bwlogic_op_b_negate ? operand_b_neg[32:1] : operand_b_i);
	assign bwlogic_or_result = operand_a_i | bwlogic_operand_b;
	assign bwlogic_and_result = operand_a_i & bwlogic_operand_b;
	assign bwlogic_xor_result = operand_a_i ^ bwlogic_operand_b;
	assign bwlogic_or = (operator_i == ALU_OR) | (operator_i == ALU_ORN);
	assign bwlogic_and = (operator_i == ALU_AND) | (operator_i == ALU_ANDN);
	always @(*)
		case (1'b1)
			bwlogic_or: bwlogic_result = bwlogic_or_result;
			bwlogic_and: bwlogic_result = bwlogic_and_result;
			default: bwlogic_result = bwlogic_xor_result;
		endcase
	wire [5:0] bitcnt_result;
	wire [31:0] minmax_result;
	reg [31:0] pack_result;
	wire [31:0] sext_result;
	reg [31:0] singlebit_result;
	reg [31:0] rev_result;
	reg [31:0] shuffle_result;
	reg [31:0] butterfly_result;
	reg [31:0] invbutterfly_result;
	reg [31:0] clmul_result;
	reg [31:0] multicycle_result;
	generate
		if (RV32B != RV32BNone) begin : g_alu_rvb
			wire zbe_op;
			wire bitcnt_ctz;
			wire bitcnt_clz;
			wire bitcnt_cz;
			reg [31:0] bitcnt_bits;
			wire [31:0] bitcnt_mask_op;
			reg [31:0] bitcnt_bit_mask;
			reg [191:0] bitcnt_partial;
			wire [31:0] bitcnt_partial_lsb_d;
			wire [31:0] bitcnt_partial_msb_d;
			assign bitcnt_ctz = operator_i == ALU_CTZ;
			assign bitcnt_clz = operator_i == ALU_CLZ;
			assign bitcnt_cz = bitcnt_ctz | bitcnt_clz;
			assign bitcnt_result = bitcnt_partial[0+:6];
			assign bitcnt_mask_op = (bitcnt_clz ? operand_a_rev : operand_a_i);
			always @(*) begin
				bitcnt_bit_mask = bitcnt_mask_op;
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 1);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 2);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 4);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 8);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 16);
				bitcnt_bit_mask = ~bitcnt_bit_mask;
			end
			assign zbe_op = (operator_i == ALU_BEXT) | (operator_i == ALU_BDEP);
			always @(*)
				case (1'b1)
					zbe_op: bitcnt_bits = operand_b_i;
					bitcnt_cz: bitcnt_bits = bitcnt_bit_mask & ~bitcnt_mask_op;
					default: bitcnt_bits = operand_a_i;
				endcase
			always @(*) begin
				bitcnt_partial = {32 {6'b000000}};
				begin : sv2v_autoblock_57
					reg [31:0] i;
					for (i = 1; i < 32; i = i + 2)
						bitcnt_partial[(31 - i) * 6+:6] = {5'h00, bitcnt_bits[i]} + {5'h00, bitcnt_bits[i - 1]};
				end
				begin : sv2v_autoblock_58
					reg [31:0] i;
					for (i = 3; i < 32; i = i + 4)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(33 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				begin : sv2v_autoblock_59
					reg [31:0] i;
					for (i = 7; i < 32; i = i + 8)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(35 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				begin : sv2v_autoblock_60
					reg [31:0] i;
					for (i = 15; i < 32; i = i + 16)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(39 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				bitcnt_partial[0+:6] = bitcnt_partial[96+:6] + bitcnt_partial[0+:6];
				bitcnt_partial[48+:6] = bitcnt_partial[96+:6] + bitcnt_partial[48+:6];
				begin : sv2v_autoblock_61
					reg [31:0] i;
					for (i = 11; i < 32; i = i + 8)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(35 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				begin : sv2v_autoblock_62
					reg [31:0] i;
					for (i = 5; i < 32; i = i + 4)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(33 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				bitcnt_partial[186+:6] = {5'h00, bitcnt_bits[0]};
				begin : sv2v_autoblock_63
					reg [31:0] i;
					for (i = 2; i < 32; i = i + 2)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(32 - i) * 6+:6] + {5'h00, bitcnt_bits[i]};
				end
			end
			assign minmax_result = (cmp_result ? operand_a_i : operand_b_i);
			wire packu;
			wire packh;
			assign packu = operator_i == ALU_PACKU;
			assign packh = operator_i == ALU_PACKH;
			always @(*)
				case (1'b1)
					packu: pack_result = {operand_b_i[31:16], operand_a_i[31:16]};
					packh: pack_result = {16'h0000, operand_b_i[7:0], operand_a_i[7:0]};
					default: pack_result = {operand_b_i[15:0], operand_a_i[15:0]};
				endcase
			assign sext_result = (operator_i == ALU_SEXTB ? {{24 {operand_a_i[7]}}, operand_a_i[7:0]} : {{16 {operand_a_i[15]}}, operand_a_i[15:0]});
			always @(*)
				case (operator_i)
					ALU_SBSET: singlebit_result = operand_a_i | shift_result;
					ALU_SBCLR: singlebit_result = operand_a_i & ~shift_result;
					ALU_SBINV: singlebit_result = operand_a_i ^ shift_result;
					default: singlebit_result = {31'h00000000, shift_result[0]};
				endcase
			wire [4:0] zbp_shift_amt;
			wire gorc_op;
			assign gorc_op = operator_i == ALU_GORC;
			assign zbp_shift_amt[2:0] = (RV32B == RV32BFull ? shift_amt[2:0] : {3 {&shift_amt[2:0]}});
			assign zbp_shift_amt[4:3] = (RV32B == RV32BFull ? shift_amt[4:3] : {2 {&shift_amt[4:3]}});
			always @(*) begin
				rev_result = operand_a_i;
				if (zbp_shift_amt[0])
					rev_result = ((gorc_op ? rev_result : 32'h00000000) | ((rev_result & 32'h55555555) << 1)) | ((rev_result & 32'haaaaaaaa) >> 1);
				if (zbp_shift_amt[1])
					rev_result = ((gorc_op ? rev_result : 32'h00000000) | ((rev_result & 32'h33333333) << 2)) | ((rev_result & 32'hcccccccc) >> 2);
				if (zbp_shift_amt[2])
					rev_result = ((gorc_op ? rev_result : 32'h00000000) | ((rev_result & 32'h0f0f0f0f) << 4)) | ((rev_result & 32'hf0f0f0f0) >> 4);
				if (zbp_shift_amt[3])
					rev_result = ((gorc_op & (RV32B == RV32BFull) ? rev_result : 32'h00000000) | ((rev_result & 32'h00ff00ff) << 8)) | ((rev_result & 32'hff00ff00) >> 8);
				if (zbp_shift_amt[4])
					rev_result = ((gorc_op & (RV32B == RV32BFull) ? rev_result : 32'h00000000) | ((rev_result & 32'h0000ffff) << 16)) | ((rev_result & 32'hffff0000) >> 16);
			end
			wire crc_hmode;
			wire crc_bmode;
			wire [31:0] clmul_result_rev;
			if (RV32B == RV32BFull) begin : gen_alu_rvb_full
				localparam [127:0] SHUFFLE_MASK_L = {32'h00ff0000, 32'h0f000f00, 32'h30303030, 32'h44444444};
				localparam [127:0] SHUFFLE_MASK_R = {32'h0000ff00, 32'h00f000f0, 32'h0c0c0c0c, 32'h22222222};
				localparam [127:0] FLIP_MASK_L = {32'h22001100, 32'h00440000, 32'h44110000, 32'h11000000};
				localparam [127:0] FLIP_MASK_R = {32'h00880044, 32'h00002200, 32'h00008822, 32'h00000088};
				wire [31:0] SHUFFLE_MASK_NOT [0:3];
				for (i = 0; i < 4; i = i + 1) begin : gen_shuffle_mask_not
					assign SHUFFLE_MASK_NOT[i] = ~(SHUFFLE_MASK_L[(3 - i) * 32+:32] | SHUFFLE_MASK_R[(3 - i) * 32+:32]);
				end
				wire shuffle_flip;
				assign shuffle_flip = operator_i == ALU_UNSHFL;
				reg [3:0] shuffle_mode;
				always @(*) begin
					shuffle_result = operand_a_i;
					if (shuffle_flip) begin
						shuffle_mode[3] = shift_amt[0];
						shuffle_mode[2] = shift_amt[1];
						shuffle_mode[1] = shift_amt[2];
						shuffle_mode[0] = shift_amt[3];
					end
					else
						shuffle_mode = shift_amt[3:0];
					if (shuffle_flip)
						shuffle_result = ((((((((shuffle_result & 32'h88224411) | ((shuffle_result << 6) & FLIP_MASK_L[96+:32])) | ((shuffle_result >> 6) & FLIP_MASK_R[96+:32])) | ((shuffle_result << 9) & FLIP_MASK_L[64+:32])) | ((shuffle_result >> 9) & FLIP_MASK_R[64+:32])) | ((shuffle_result << 15) & FLIP_MASK_L[32+:32])) | ((shuffle_result >> 15) & FLIP_MASK_R[32+:32])) | ((shuffle_result << 21) & FLIP_MASK_L[0+:32])) | ((shuffle_result >> 21) & FLIP_MASK_R[0+:32]);
					if (shuffle_mode[3])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[0]) | (((shuffle_result << 8) & SHUFFLE_MASK_L[96+:32]) | ((shuffle_result >> 8) & SHUFFLE_MASK_R[96+:32]));
					if (shuffle_mode[2])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[1]) | (((shuffle_result << 4) & SHUFFLE_MASK_L[64+:32]) | ((shuffle_result >> 4) & SHUFFLE_MASK_R[64+:32]));
					if (shuffle_mode[1])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[2]) | (((shuffle_result << 2) & SHUFFLE_MASK_L[32+:32]) | ((shuffle_result >> 2) & SHUFFLE_MASK_R[32+:32]));
					if (shuffle_mode[0])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[3]) | (((shuffle_result << 1) & SHUFFLE_MASK_L[0+:32]) | ((shuffle_result >> 1) & SHUFFLE_MASK_R[0+:32]));
					if (shuffle_flip)
						shuffle_result = ((((((((shuffle_result & 32'h88224411) | ((shuffle_result << 6) & FLIP_MASK_L[96+:32])) | ((shuffle_result >> 6) & FLIP_MASK_R[96+:32])) | ((shuffle_result << 9) & FLIP_MASK_L[64+:32])) | ((shuffle_result >> 9) & FLIP_MASK_R[64+:32])) | ((shuffle_result << 15) & FLIP_MASK_L[32+:32])) | ((shuffle_result >> 15) & FLIP_MASK_R[32+:32])) | ((shuffle_result << 21) & FLIP_MASK_L[0+:32])) | ((shuffle_result >> 21) & FLIP_MASK_R[0+:32]);
				end
				reg [191:0] bitcnt_partial_q;
				for (i = 0; i < 32; i = i + 1) begin : gen_bitcnt_reg_in_lsb
					assign bitcnt_partial_lsb_d[i] = bitcnt_partial[(31 - i) * 6];
				end
				for (i = 0; i < 16; i = i + 1) begin : gen_bitcnt_reg_in_b1
					assign bitcnt_partial_msb_d[i] = bitcnt_partial[((31 - ((2 * i) + 1)) * 6) + 1];
				end
				for (i = 0; i < 8; i = i + 1) begin : gen_bitcnt_reg_in_b2
					assign bitcnt_partial_msb_d[16 + i] = bitcnt_partial[((31 - ((4 * i) + 3)) * 6) + 2];
				end
				for (i = 0; i < 4; i = i + 1) begin : gen_bitcnt_reg_in_b3
					assign bitcnt_partial_msb_d[24 + i] = bitcnt_partial[((31 - ((8 * i) + 7)) * 6) + 3];
				end
				for (i = 0; i < 2; i = i + 1) begin : gen_bitcnt_reg_in_b4
					assign bitcnt_partial_msb_d[28 + i] = bitcnt_partial[((31 - ((16 * i) + 15)) * 6) + 4];
				end
				assign bitcnt_partial_msb_d[30] = bitcnt_partial[5];
				assign bitcnt_partial_msb_d[31] = 1'b0;
				always @(*) begin
					bitcnt_partial_q = {32 {6'b000000}};
					begin : sv2v_autoblock_64
						reg [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							begin : gen_bitcnt_reg_out_lsb
								bitcnt_partial_q[(31 - i) * 6] = imd_val_q_i[32 + i];
							end
					end
					begin : sv2v_autoblock_65
						reg [31:0] i;
						for (i = 0; i < 16; i = i + 1)
							begin : gen_bitcnt_reg_out_b1
								bitcnt_partial_q[((31 - ((2 * i) + 1)) * 6) + 1] = imd_val_q_i[i];
							end
					end
					begin : sv2v_autoblock_66
						reg [31:0] i;
						for (i = 0; i < 8; i = i + 1)
							begin : gen_bitcnt_reg_out_b2
								bitcnt_partial_q[((31 - ((4 * i) + 3)) * 6) + 2] = imd_val_q_i[16 + i];
							end
					end
					begin : sv2v_autoblock_67
						reg [31:0] i;
						for (i = 0; i < 4; i = i + 1)
							begin : gen_bitcnt_reg_out_b3
								bitcnt_partial_q[((31 - ((8 * i) + 7)) * 6) + 3] = imd_val_q_i[24 + i];
							end
					end
					begin : sv2v_autoblock_68
						reg [31:0] i;
						for (i = 0; i < 2; i = i + 1)
							begin : gen_bitcnt_reg_out_b4
								bitcnt_partial_q[((31 - ((16 * i) + 15)) * 6) + 4] = imd_val_q_i[28 + i];
							end
					end
					bitcnt_partial_q[5] = imd_val_q_i[30];
				end
				wire [31:0] butterfly_mask_l [0:4];
				wire [31:0] butterfly_mask_r [0:4];
				wire [31:0] butterfly_mask_not [0:4];
				wire [31:0] lrotc_stage [0:4];
				genvar stg;
				for (stg = 0; stg < 5; stg = stg + 1) begin : gen_butterfly_ctrl_stage
					genvar seg;
					for (seg = 0; seg < (2 ** stg); seg = seg + 1) begin : gen_butterfly_ctrl
						assign lrotc_stage[stg][((2 * (16 >> stg)) * (seg + 1)) - 1:(2 * (16 >> stg)) * seg] = {{16 >> stg {1'b0}}, {16 >> stg {1'b1}}} << bitcnt_partial_q[((32 - ((16 >> stg) * ((2 * seg) + 1))) * 6) + ($clog2(16 >> stg) >= 0 ? $clog2(16 >> stg) : ($clog2(16 >> stg) + ($clog2(16 >> stg) >= 0 ? $clog2(16 >> stg) + 1 : 1 - $clog2(16 >> stg))) - 1)-:($clog2(16 >> stg) >= 0 ? $clog2(16 >> stg) + 1 : 1 - $clog2(16 >> stg))];
						assign butterfly_mask_l[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)] = ~lrotc_stage[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)];
						assign butterfly_mask_r[stg][((16 >> stg) * ((2 * seg) + 1)) - 1:(16 >> stg) * (2 * seg)] = ~lrotc_stage[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)];
						assign butterfly_mask_l[stg][((16 >> stg) * ((2 * seg) + 1)) - 1:(16 >> stg) * (2 * seg)] = {((((16 >> stg) * ((2 * seg) + 1)) - 1) >= ((16 >> stg) * (2 * seg)) ? ((((16 >> stg) * ((2 * seg) + 1)) - 1) - ((16 >> stg) * (2 * seg))) + 1 : (((16 >> stg) * (2 * seg)) - (((16 >> stg) * ((2 * seg) + 1)) - 1)) + 1) {1'sb0}};
						assign butterfly_mask_r[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)] = {((((16 >> stg) * ((2 * seg) + 2)) - 1) >= ((16 >> stg) * ((2 * seg) + 1)) ? ((((16 >> stg) * ((2 * seg) + 2)) - 1) - ((16 >> stg) * ((2 * seg) + 1))) + 1 : (((16 >> stg) * ((2 * seg) + 1)) - (((16 >> stg) * ((2 * seg) + 2)) - 1)) + 1) {1'sb0}};
					end
				end
				for (stg = 0; stg < 5; stg = stg + 1) begin : gen_butterfly_not
					assign butterfly_mask_not[stg] = ~(butterfly_mask_l[stg] | butterfly_mask_r[stg]);
				end
				always @(*) begin
					butterfly_result = operand_a_i;
					butterfly_result = ((butterfly_result & butterfly_mask_not[0]) | ((butterfly_result & butterfly_mask_l[0]) >> 16)) | ((butterfly_result & butterfly_mask_r[0]) << 16);
					butterfly_result = ((butterfly_result & butterfly_mask_not[1]) | ((butterfly_result & butterfly_mask_l[1]) >> 8)) | ((butterfly_result & butterfly_mask_r[1]) << 8);
					butterfly_result = ((butterfly_result & butterfly_mask_not[2]) | ((butterfly_result & butterfly_mask_l[2]) >> 4)) | ((butterfly_result & butterfly_mask_r[2]) << 4);
					butterfly_result = ((butterfly_result & butterfly_mask_not[3]) | ((butterfly_result & butterfly_mask_l[3]) >> 2)) | ((butterfly_result & butterfly_mask_r[3]) << 2);
					butterfly_result = ((butterfly_result & butterfly_mask_not[4]) | ((butterfly_result & butterfly_mask_l[4]) >> 1)) | ((butterfly_result & butterfly_mask_r[4]) << 1);
					butterfly_result = butterfly_result & operand_b_i;
				end
				always @(*) begin
					invbutterfly_result = operand_a_i & operand_b_i;
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[4]) | ((invbutterfly_result & butterfly_mask_l[4]) >> 1)) | ((invbutterfly_result & butterfly_mask_r[4]) << 1);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[3]) | ((invbutterfly_result & butterfly_mask_l[3]) >> 2)) | ((invbutterfly_result & butterfly_mask_r[3]) << 2);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[2]) | ((invbutterfly_result & butterfly_mask_l[2]) >> 4)) | ((invbutterfly_result & butterfly_mask_r[2]) << 4);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[1]) | ((invbutterfly_result & butterfly_mask_l[1]) >> 8)) | ((invbutterfly_result & butterfly_mask_r[1]) << 8);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[0]) | ((invbutterfly_result & butterfly_mask_l[0]) >> 16)) | ((invbutterfly_result & butterfly_mask_r[0]) << 16);
				end
				wire clmul_rmode;
				wire clmul_hmode;
				reg [31:0] clmul_op_a;
				reg [31:0] clmul_op_b;
				wire [31:0] operand_b_rev;
				wire [31:0] clmul_and_stage [0:31];
				wire [31:0] clmul_xor_stage1 [0:15];
				wire [31:0] clmul_xor_stage2 [0:7];
				wire [31:0] clmul_xor_stage3 [0:3];
				wire [31:0] clmul_xor_stage4 [0:1];
				wire [31:0] clmul_result_raw;
				for (i = 0; i < 32; i = i + 1) begin : gen_rev_operand_b
					assign operand_b_rev[i] = operand_b_i[31 - i];
				end
				assign clmul_rmode = operator_i == ALU_CLMULR;
				assign clmul_hmode = operator_i == ALU_CLMULH;
				localparam [31:0] CRC32_POLYNOMIAL = 32'h04c11db7;
				localparam [31:0] CRC32_MU_REV = 32'hf7011641;
				localparam [31:0] CRC32C_POLYNOMIAL = 32'h1edc6f41;
				localparam [31:0] CRC32C_MU_REV = 32'hdea713f1;
				wire crc_op;
				wire crc_cpoly;
				reg [31:0] crc_operand;
				wire [31:0] crc_poly;
				wire [31:0] crc_mu_rev;
				assign crc_op = (((((operator_i == ALU_CRC32C_W) | (operator_i == ALU_CRC32_W)) | (operator_i == ALU_CRC32C_H)) | (operator_i == ALU_CRC32_H)) | (operator_i == ALU_CRC32C_B)) | (operator_i == ALU_CRC32_B);
				assign crc_cpoly = ((operator_i == ALU_CRC32C_W) | (operator_i == ALU_CRC32C_H)) | (operator_i == ALU_CRC32C_B);
				assign crc_hmode = (operator_i == ALU_CRC32_H) | (operator_i == ALU_CRC32C_H);
				assign crc_bmode = (operator_i == ALU_CRC32_B) | (operator_i == ALU_CRC32C_B);
				assign crc_poly = (crc_cpoly ? CRC32C_POLYNOMIAL : CRC32_POLYNOMIAL);
				assign crc_mu_rev = (crc_cpoly ? CRC32C_MU_REV : CRC32_MU_REV);
				always @(*)
					case (1'b1)
						crc_bmode: crc_operand = {operand_a_i[7:0], 24'h000000};
						crc_hmode: crc_operand = {operand_a_i[15:0], 16'h0000};
						default: crc_operand = operand_a_i;
					endcase
				always @(*)
					if (crc_op) begin
						clmul_op_a = (instr_first_cycle_i ? crc_operand : imd_val_q_i[32+:32]);
						clmul_op_b = (instr_first_cycle_i ? crc_mu_rev : crc_poly);
					end
					else begin
						clmul_op_a = (clmul_rmode | clmul_hmode ? operand_a_rev : operand_a_i);
						clmul_op_b = (clmul_rmode | clmul_hmode ? operand_b_rev : operand_b_i);
					end
				for (i = 0; i < 32; i = i + 1) begin : gen_clmul_and_op
					assign clmul_and_stage[i] = (clmul_op_b[i] ? clmul_op_a << i : {32 {1'sb0}});
				end
				for (i = 0; i < 16; i = i + 1) begin : gen_clmul_xor_op_l1
					assign clmul_xor_stage1[i] = clmul_and_stage[2 * i] ^ clmul_and_stage[(2 * i) + 1];
				end
				for (i = 0; i < 8; i = i + 1) begin : gen_clmul_xor_op_l2
					assign clmul_xor_stage2[i] = clmul_xor_stage1[2 * i] ^ clmul_xor_stage1[(2 * i) + 1];
				end
				for (i = 0; i < 4; i = i + 1) begin : gen_clmul_xor_op_l3
					assign clmul_xor_stage3[i] = clmul_xor_stage2[2 * i] ^ clmul_xor_stage2[(2 * i) + 1];
				end
				for (i = 0; i < 2; i = i + 1) begin : gen_clmul_xor_op_l4
					assign clmul_xor_stage4[i] = clmul_xor_stage3[2 * i] ^ clmul_xor_stage3[(2 * i) + 1];
				end
				assign clmul_result_raw = clmul_xor_stage4[0] ^ clmul_xor_stage4[1];
				for (i = 0; i < 32; i = i + 1) begin : gen_rev_clmul_result
					assign clmul_result_rev[i] = clmul_result_raw[31 - i];
				end
				always @(*)
					case (1'b1)
						clmul_rmode: clmul_result = clmul_result_rev;
						clmul_hmode: clmul_result = {1'b0, clmul_result_rev[31:1]};
						default: clmul_result = clmul_result_raw;
					endcase
			end
			else begin : gen_alu_rvb_notfull
				always @(*) shuffle_result = {32 {1'sb0}};
				always @(*) butterfly_result = {32 {1'sb0}};
				always @(*) invbutterfly_result = {32 {1'sb0}};
				always @(*) clmul_result = {32 {1'sb0}};
				assign bitcnt_partial_lsb_d = {32 {1'sb0}};
				assign bitcnt_partial_msb_d = {32 {1'sb0}};
				assign clmul_result_rev = {32 {1'sb0}};
				assign crc_bmode = 1'sb0;
				assign crc_hmode = 1'sb0;
			end
			always @(*)
				case (operator_i)
					ALU_CMOV: begin
						multicycle_result = (operand_b_i == 32'h00000000 ? operand_a_i : imd_val_q_i[32+:32]);
						imd_val_d_o = {operand_a_i, 32'h00000000};
						if (instr_first_cycle_i)
							imd_val_we_o = 2'b01;
						else
							imd_val_we_o = 2'b00;
					end
					ALU_CMIX: begin
						multicycle_result = imd_val_q_i[32+:32] | bwlogic_and_result;
						imd_val_d_o = {bwlogic_and_result, 32'h00000000};
						if (instr_first_cycle_i)
							imd_val_we_o = 2'b01;
						else
							imd_val_we_o = 2'b00;
					end
					ALU_FSR, ALU_FSL, ALU_ROL, ALU_ROR: begin
						if (shift_amt[4:0] == 5'h00)
							multicycle_result = (shift_amt[5] ? operand_a_i : imd_val_q_i[32+:32]);
						else
							multicycle_result = imd_val_q_i[32+:32] | shift_result;
						imd_val_d_o = {shift_result, 32'h00000000};
						if (instr_first_cycle_i)
							imd_val_we_o = 2'b01;
						else
							imd_val_we_o = 2'b00;
					end
					ALU_CRC32_W, ALU_CRC32C_W, ALU_CRC32_H, ALU_CRC32C_H, ALU_CRC32_B, ALU_CRC32C_B:
						if (RV32B == RV32BFull) begin
							case (1'b1)
								crc_bmode: multicycle_result = clmul_result_rev ^ (operand_a_i >> 8);
								crc_hmode: multicycle_result = clmul_result_rev ^ (operand_a_i >> 16);
								default: multicycle_result = clmul_result_rev;
							endcase
							imd_val_d_o = {clmul_result_rev, 32'h00000000};
							if (instr_first_cycle_i)
								imd_val_we_o = 2'b01;
							else
								imd_val_we_o = 2'b00;
						end
						else begin
							imd_val_d_o = {operand_a_i, 32'h00000000};
							imd_val_we_o = 2'b00;
							multicycle_result = {32 {1'sb0}};
						end
					ALU_BEXT, ALU_BDEP:
						if (RV32B == RV32BFull) begin
							multicycle_result = (operator_i == ALU_BDEP ? butterfly_result : invbutterfly_result);
							imd_val_d_o = {bitcnt_partial_lsb_d, bitcnt_partial_msb_d};
							if (instr_first_cycle_i)
								imd_val_we_o = 2'b11;
							else
								imd_val_we_o = 2'b00;
						end
						else begin
							imd_val_d_o = {operand_a_i, 32'h00000000};
							imd_val_we_o = 2'b00;
							multicycle_result = {32 {1'sb0}};
						end
					default: begin
						imd_val_d_o = {operand_a_i, 32'h00000000};
						imd_val_we_o = 2'b00;
						multicycle_result = {32 {1'sb0}};
					end
				endcase
		end
		else begin : g_no_alu_rvb
			assign bitcnt_result = {6 {1'sb0}};
			assign minmax_result = {32 {1'sb0}};
			always @(*) pack_result = {32 {1'sb0}};
			assign sext_result = {32 {1'sb0}};
			always @(*) singlebit_result = {32 {1'sb0}};
			always @(*) rev_result = {32 {1'sb0}};
			always @(*) shuffle_result = {32 {1'sb0}};
			always @(*) butterfly_result = {32 {1'sb0}};
			always @(*) invbutterfly_result = {32 {1'sb0}};
			always @(*) clmul_result = {32 {1'sb0}};
			always @(*) multicycle_result = {32 {1'sb0}};
			always @(*) imd_val_d_o = {2 {32'b00000000000000000000000000000000}};
			always @(*) imd_val_we_o = {2 {1'sb0}};
		end
	endgenerate
	always @(*) begin
		result_o = {32 {1'sb0}};
		case (operator_i)
			ALU_XOR, ALU_XNOR, ALU_OR, ALU_ORN, ALU_AND, ALU_ANDN: result_o = bwlogic_result;
			ALU_ADD, ALU_SUB: result_o = adder_result;
			ALU_SLL, ALU_SRL, ALU_SRA, ALU_SLO, ALU_SRO: result_o = shift_result;
			ALU_SHFL, ALU_UNSHFL: result_o = shuffle_result;
			ALU_EQ, ALU_NE, ALU_GE, ALU_GEU, ALU_LT, ALU_LTU, ALU_SLT, ALU_SLTU: result_o = {31'h00000000, cmp_result};
			ALU_MIN, ALU_MAX, ALU_MINU, ALU_MAXU: result_o = minmax_result;
			ALU_CLZ, ALU_CTZ, ALU_PCNT: result_o = {26'h0000000, bitcnt_result};
			ALU_PACK, ALU_PACKH, ALU_PACKU: result_o = pack_result;
			ALU_SEXTB, ALU_SEXTH: result_o = sext_result;
			ALU_CMIX, ALU_CMOV, ALU_FSL, ALU_FSR, ALU_ROL, ALU_ROR, ALU_CRC32_W, ALU_CRC32C_W, ALU_CRC32_H, ALU_CRC32C_H, ALU_CRC32_B, ALU_CRC32C_B, ALU_BEXT, ALU_BDEP: result_o = multicycle_result;
			ALU_SBSET, ALU_SBCLR, ALU_SBINV, ALU_SBEXT: result_o = singlebit_result;
			ALU_GREV, ALU_GORC: result_o = rev_result;
			ALU_BFP: result_o = bfp_result;
			ALU_CLMUL, ALU_CLMULR, ALU_CLMULH: result_o = clmul_result;
			default:
				;
		endcase
	end
endmodule
module brqrv_exu_multdiv_fast (
	clk_i,
	rst_ni,
	mult_en_i,
	div_en_i,
	mult_sel_i,
	div_sel_i,
	operator_i,
	signed_mode_i,
	op_a_i,
	op_b_i,
	alu_adder_ext_i,
	alu_adder_i,
	equal_to_zero_i,
	data_ind_timing_i,
	alu_operand_a_o,
	alu_operand_b_o,
	imd_val_q_i,
	imd_val_d_o,
	imd_val_we_o,
	multdiv_ready_id_i,
	multdiv_result_o,
	valid_o
);
	localparam integer brqrv_pkg_RV32MFast = 2;
	parameter integer RV32M = brqrv_pkg_RV32MFast;
	input wire clk_i;
	input wire rst_ni;
	input wire mult_en_i;
	input wire div_en_i;
	input wire mult_sel_i;
	input wire div_sel_i;
	input wire [1:0] operator_i;
	input wire [1:0] signed_mode_i;
	input wire [31:0] op_a_i;
	input wire [31:0] op_b_i;
	input wire [33:0] alu_adder_ext_i;
	input wire [31:0] alu_adder_i;
	input wire equal_to_zero_i;
	input wire data_ind_timing_i;
	output reg [32:0] alu_operand_a_o;
	output reg [32:0] alu_operand_b_o;
	input wire [67:0] imd_val_q_i;
	output wire [67:0] imd_val_d_o;
	output wire [1:0] imd_val_we_o;
	input wire multdiv_ready_id_i;
	output wire [31:0] multdiv_result_o;
	output wire valid_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	wire signed [34:0] mac_res_signed;
	wire [34:0] mac_res_ext;
	reg [33:0] accum;
	reg sign_a;
	reg sign_b;
	reg mult_valid;
	wire signed_mult;
	reg [33:0] mac_res_d;
	reg [33:0] op_remainder_d;
	wire [33:0] mac_res;
	wire div_sign_a;
	wire div_sign_b;
	reg is_greater_equal;
	wire div_change_sign;
	wire rem_change_sign;
	wire [31:0] one_shift;
	wire [31:0] op_denominator_q;
	reg [31:0] op_numerator_q;
	reg [31:0] op_quotient_q;
	reg [31:0] op_denominator_d;
	reg [31:0] op_numerator_d;
	reg [31:0] op_quotient_d;
	wire [31:0] next_remainder;
	wire [32:0] next_quotient;
	wire [32:0] res_adder_h;
	reg div_valid;
	reg [4:0] div_counter_q;
	reg [4:0] div_counter_d;
	wire multdiv_en;
	reg mult_hold;
	reg div_hold;
	reg div_by_zero_d;
	reg div_by_zero_q;
	wire mult_en_internal;
	wire div_en_internal;
	reg [2:0] md_state_q;
	reg [2:0] md_state_d;
	wire unused_mult_sel_i;
	assign unused_mult_sel_i = mult_sel_i;
	assign mult_en_internal = mult_en_i & ~mult_hold;
	assign div_en_internal = div_en_i & ~div_hold;
	localparam [2:0] MD_IDLE = 0;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			div_counter_q <= {5 {1'sb0}};
			md_state_q <= MD_IDLE;
			op_numerator_q <= {32 {1'sb0}};
			op_quotient_q <= {32 {1'sb0}};
			div_by_zero_q <= 1'sb0;
		end
		else if (div_en_internal) begin
			div_counter_q <= div_counter_d;
			op_numerator_q <= op_numerator_d;
			op_quotient_q <= op_quotient_d;
			md_state_q <= md_state_d;
			div_by_zero_q <= div_by_zero_d;
		end
	assign multdiv_en = mult_en_internal | div_en_internal;
	assign imd_val_d_o[34+:34] = (div_sel_i ? op_remainder_d : mac_res_d);
	assign imd_val_we_o[0] = multdiv_en;
	assign imd_val_d_o[0+:34] = {2'b00, op_denominator_d};
	assign imd_val_we_o[1] = div_en_internal;
	assign op_denominator_q = imd_val_q_i[31-:32];
	wire [1:0] unused_imd_val;
	assign unused_imd_val = imd_val_q_i[33-:2];
	assign signed_mult = signed_mode_i != 2'b00;
	assign multdiv_result_o = (div_sel_i ? imd_val_q_i[65-:32] : mac_res_d[31:0]);
	localparam [1:0] AHBH = 3;
	localparam [1:0] AHBL = 2;
	localparam [1:0] ALBH = 1;
	localparam [1:0] ALBL = 0;
	localparam [0:0] MULH = 1;
	localparam [0:0] MULL = 0;
	generate
		if (RV32M == RV32MSingleCycle) begin : gen_mult_single_cycle
			reg mult_state_q;
			reg mult_state_d;
			wire signed [33:0] mult1_res;
			wire signed [33:0] mult2_res;
			wire signed [33:0] mult3_res;
			wire [15:0] mult1_op_a;
			wire [15:0] mult1_op_b;
			wire [15:0] mult2_op_a;
			wire [15:0] mult2_op_b;
			reg [15:0] mult3_op_a;
			reg [15:0] mult3_op_b;
			wire mult1_sign_a;
			wire mult1_sign_b;
			wire mult2_sign_a;
			wire mult2_sign_b;
			reg mult3_sign_a;
			reg mult3_sign_b;
			reg [33:0] summand1;
			reg [33:0] summand2;
			reg [33:0] summand3;
			assign mult1_res = $signed({mult1_sign_a, mult1_op_a}) * $signed({mult1_sign_b, mult1_op_b});
			assign mult2_res = $signed({mult2_sign_a, mult2_op_a}) * $signed({mult2_sign_b, mult2_op_b});
			assign mult3_res = $signed({mult3_sign_a, mult3_op_a}) * $signed({mult3_sign_b, mult3_op_b});
			assign mac_res_signed = ($signed(summand1) + $signed(summand2)) + $signed(summand3);
			assign mac_res_ext = $unsigned(mac_res_signed);
			assign mac_res = mac_res_ext[33:0];
			always @(*) sign_a = signed_mode_i[0] & op_a_i[31];
			always @(*) sign_b = signed_mode_i[1] & op_b_i[31];
			assign mult1_sign_a = 1'b0;
			assign mult1_sign_b = 1'b0;
			assign mult1_op_a = op_a_i[15:0];
			assign mult1_op_b = op_b_i[15:0];
			assign mult2_sign_a = 1'b0;
			assign mult2_sign_b = sign_b;
			assign mult2_op_a = op_a_i[15:0];
			assign mult2_op_b = op_b_i[31:16];
			always @(*) accum[17:0] = imd_val_q_i[67-:18];
			always @(*) accum[33:18] = {16 {signed_mult & imd_val_q_i[67]}};
			always @(*) begin
				mult3_sign_a = sign_a;
				mult3_sign_b = 1'b0;
				mult3_op_a = op_a_i[31:16];
				mult3_op_b = op_b_i[15:0];
				summand1 = {18'h00000, mult1_res[31:16]};
				summand2 = mult2_res;
				summand3 = mult3_res;
				mac_res_d = {2'b00, mac_res[15:0], mult1_res[15:0]};
				mult_valid = mult_en_i;
				mult_state_d = MULL;
				mult_hold = 1'b0;
				case (mult_state_q)
					MULL:
						if (operator_i != MD_OP_MULL) begin
							mac_res_d = mac_res;
							mult_valid = 1'b0;
							mult_state_d = MULH;
						end
						else
							mult_hold = ~multdiv_ready_id_i;
					MULH: begin
						mult3_sign_a = sign_a;
						mult3_sign_b = sign_b;
						mult3_op_a = op_a_i[31:16];
						mult3_op_b = op_b_i[31:16];
						mac_res_d = mac_res;
						summand1 = {34 {1'sb0}};
						summand2 = accum;
						summand3 = mult3_res;
						mult_state_d = MULL;
						mult_valid = 1'b1;
						mult_hold = ~multdiv_ready_id_i;
					end
					default: mult_state_d = MULL;
				endcase
			end
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mult_state_q <= MULL;
				else if (mult_en_internal)
					mult_state_q <= mult_state_d;
		end
		else begin : gen_mult_fast
			reg [15:0] mult_op_a;
			reg [15:0] mult_op_b;
			reg [1:0] mult_state_q;
			reg [1:0] mult_state_d;
			assign mac_res_signed = ($signed({sign_a, mult_op_a}) * $signed({sign_b, mult_op_b})) + $signed(accum);
			assign mac_res_ext = $unsigned(mac_res_signed);
			assign mac_res = mac_res_ext[33:0];
			always @(*) begin
				mult_op_a = op_a_i[15:0];
				mult_op_b = op_b_i[15:0];
				sign_a = 1'b0;
				sign_b = 1'b0;
				accum = imd_val_q_i[34+:34];
				mac_res_d = mac_res;
				mult_state_d = mult_state_q;
				mult_valid = 1'b0;
				mult_hold = 1'b0;
				case (mult_state_q)
					ALBL: begin
						mult_op_a = op_a_i[15:0];
						mult_op_b = op_b_i[15:0];
						sign_a = 1'b0;
						sign_b = 1'b0;
						accum = {34 {1'sb0}};
						mac_res_d = mac_res;
						mult_state_d = ALBH;
					end
					ALBH: begin
						mult_op_a = op_a_i[15:0];
						mult_op_b = op_b_i[31:16];
						sign_a = 1'b0;
						sign_b = signed_mode_i[1] & op_b_i[31];
						accum = {18'b000000000000000000, imd_val_q_i[65-:16]};
						if (operator_i == MD_OP_MULL)
							mac_res_d = {2'b00, mac_res[15:0], imd_val_q_i[49-:16]};
						else
							mac_res_d = mac_res;
						mult_state_d = AHBL;
					end
					AHBL: begin
						mult_op_a = op_a_i[31:16];
						mult_op_b = op_b_i[15:0];
						sign_a = signed_mode_i[0] & op_a_i[31];
						sign_b = 1'b0;
						if (operator_i == MD_OP_MULL) begin
							accum = {18'b000000000000000000, imd_val_q_i[65-:16]};
							mac_res_d = {2'b00, mac_res[15:0], imd_val_q_i[49-:16]};
							mult_valid = 1'b1;
							mult_state_d = ALBL;
							mult_hold = ~multdiv_ready_id_i;
						end
						else begin
							accum = imd_val_q_i[34+:34];
							mac_res_d = mac_res;
							mult_state_d = AHBH;
						end
					end
					AHBH: begin
						mult_op_a = op_a_i[31:16];
						mult_op_b = op_b_i[31:16];
						sign_a = signed_mode_i[0] & op_a_i[31];
						sign_b = signed_mode_i[1] & op_b_i[31];
						accum[17:0] = imd_val_q_i[67-:18];
						accum[33:18] = {16 {signed_mult & imd_val_q_i[67]}};
						mac_res_d = mac_res;
						mult_valid = 1'b1;
						mult_state_d = ALBL;
						mult_hold = ~multdiv_ready_id_i;
					end
					default: mult_state_d = ALBL;
				endcase
			end
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mult_state_q <= ALBL;
				else if (mult_en_internal)
					mult_state_q <= mult_state_d;
		end
	endgenerate
	assign res_adder_h = alu_adder_ext_i[33:1];
	assign next_remainder = (is_greater_equal ? res_adder_h[31:0] : imd_val_q_i[65-:32]);
	assign next_quotient = (is_greater_equal ? {1'b0, op_quotient_q} | {1'b0, one_shift} : {1'b0, op_quotient_q});
	assign one_shift = {31'b0000000000000000000000000000000, 1'b1} << div_counter_q;
	always @(*)
		if ((imd_val_q_i[65] ^ op_denominator_q[31]) == 1'b0)
			is_greater_equal = res_adder_h[31] == 1'b0;
		else
			is_greater_equal = imd_val_q_i[65];
	assign div_sign_a = op_a_i[31] & signed_mode_i[0];
	assign div_sign_b = op_b_i[31] & signed_mode_i[1];
	assign div_change_sign = (div_sign_a ^ div_sign_b) & ~div_by_zero_q;
	assign rem_change_sign = div_sign_a;
	localparam [2:0] MD_ABS_A = 1;
	localparam [2:0] MD_ABS_B = 2;
	localparam [2:0] MD_CHANGE_SIGN = 5;
	localparam [2:0] MD_COMP = 3;
	localparam [2:0] MD_FINISH = 6;
	localparam [2:0] MD_LAST = 4;
	always @(*) begin
		div_counter_d = div_counter_q - 5'h01;
		op_remainder_d = imd_val_q_i[34+:34];
		op_quotient_d = op_quotient_q;
		md_state_d = md_state_q;
		op_numerator_d = op_numerator_q;
		op_denominator_d = op_denominator_q;
		alu_operand_a_o = {32'h00000000, 1'b1};
		alu_operand_b_o = {~op_b_i, 1'b1};
		div_valid = 1'b0;
		div_hold = 1'b0;
		div_by_zero_d = div_by_zero_q;
		case (md_state_q)
			MD_IDLE: begin
				if (operator_i == MD_OP_DIV) begin
					op_remainder_d = {34 {1'sb1}};
					md_state_d = (!data_ind_timing_i && equal_to_zero_i ? MD_FINISH : MD_ABS_A);
					div_by_zero_d = equal_to_zero_i;
				end
				else begin
					op_remainder_d = {2'b00, op_a_i};
					md_state_d = (!data_ind_timing_i && equal_to_zero_i ? MD_FINISH : MD_ABS_A);
				end
				alu_operand_a_o = {32'h00000000, 1'b1};
				alu_operand_b_o = {~op_b_i, 1'b1};
				div_counter_d = 5'd31;
			end
			MD_ABS_A: begin
				op_quotient_d = {32 {1'sb0}};
				op_numerator_d = (div_sign_a ? alu_adder_i : op_a_i);
				md_state_d = MD_ABS_B;
				div_counter_d = 5'd31;
				alu_operand_a_o = {32'h00000000, 1'b1};
				alu_operand_b_o = {~op_a_i, 1'b1};
			end
			MD_ABS_B: begin
				op_remainder_d = {33'h000000000, op_numerator_q[31]};
				op_denominator_d = (div_sign_b ? alu_adder_i : op_b_i);
				md_state_d = MD_COMP;
				div_counter_d = 5'd31;
				alu_operand_a_o = {32'h00000000, 1'b1};
				alu_operand_b_o = {~op_b_i, 1'b1};
			end
			MD_COMP: begin
				op_remainder_d = {1'b0, next_remainder[31:0], op_numerator_q[div_counter_d]};
				op_quotient_d = next_quotient[31:0];
				md_state_d = (div_counter_q == 5'd1 ? MD_LAST : MD_COMP);
				alu_operand_a_o = {imd_val_q_i[65-:32], 1'b1};
				alu_operand_b_o = {~op_denominator_q[31:0], 1'b1};
			end
			MD_LAST: begin
				if (operator_i == MD_OP_DIV)
					op_remainder_d = {1'b0, next_quotient};
				else
					op_remainder_d = {2'b00, next_remainder[31:0]};
				alu_operand_a_o = {imd_val_q_i[65-:32], 1'b1};
				alu_operand_b_o = {~op_denominator_q[31:0], 1'b1};
				md_state_d = MD_CHANGE_SIGN;
			end
			MD_CHANGE_SIGN: begin
				md_state_d = MD_FINISH;
				if (operator_i == MD_OP_DIV)
					op_remainder_d = (div_change_sign ? {2'h0, alu_adder_i} : imd_val_q_i[34+:34]);
				else
					op_remainder_d = (rem_change_sign ? {2'h0, alu_adder_i} : imd_val_q_i[34+:34]);
				alu_operand_a_o = {32'h00000000, 1'b1};
				alu_operand_b_o = {~imd_val_q_i[65-:32], 1'b1};
			end
			MD_FINISH: begin
				md_state_d = MD_IDLE;
				div_hold = ~multdiv_ready_id_i;
				div_valid = 1'b1;
			end
			default: md_state_d = MD_IDLE;
		endcase
	end
	assign valid_o = mult_valid | div_valid;
endmodule
module brqrv_exu_multdiv_slow (
	clk_i,
	rst_ni,
	mult_en_i,
	div_en_i,
	mult_sel_i,
	div_sel_i,
	operator_i,
	signed_mode_i,
	op_a_i,
	op_b_i,
	alu_adder_ext_i,
	alu_adder_i,
	equal_to_zero_i,
	data_ind_timing_i,
	alu_operand_a_o,
	alu_operand_b_o,
	imd_val_q_i,
	imd_val_d_o,
	imd_val_we_o,
	multdiv_ready_id_i,
	multdiv_result_o,
	valid_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire mult_en_i;
	input wire div_en_i;
	input wire mult_sel_i;
	input wire div_sel_i;
	input wire [1:0] operator_i;
	input wire [1:0] signed_mode_i;
	input wire [31:0] op_a_i;
	input wire [31:0] op_b_i;
	input wire [33:0] alu_adder_ext_i;
	input wire [31:0] alu_adder_i;
	input wire equal_to_zero_i;
	input wire data_ind_timing_i;
	output reg [32:0] alu_operand_a_o;
	output reg [32:0] alu_operand_b_o;
	input wire [67:0] imd_val_q_i;
	output wire [67:0] imd_val_d_o;
	output wire [1:0] imd_val_we_o;
	input wire multdiv_ready_id_i;
	output wire [31:0] multdiv_result_o;
	output wire valid_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	reg [2:0] md_state_q;
	reg [2:0] md_state_d;
	wire [32:0] accum_window_q;
	reg [32:0] accum_window_d;
	wire unused_imd_val0;
	wire [1:0] unused_imd_val1;
	wire [32:0] res_adder_l;
	wire [32:0] res_adder_h;
	reg [4:0] multdiv_count_q;
	reg [4:0] multdiv_count_d;
	reg [32:0] op_b_shift_q;
	reg [32:0] op_b_shift_d;
	reg [32:0] op_a_shift_q;
	reg [32:0] op_a_shift_d;
	wire [32:0] op_a_ext;
	wire [32:0] op_b_ext;
	wire [32:0] one_shift;
	wire [32:0] op_a_bw_pp;
	wire [32:0] op_a_bw_last_pp;
	wire [31:0] b_0;
	wire sign_a;
	wire sign_b;
	wire [32:0] next_quotient;
	wire [31:0] next_remainder;
	wire [31:0] op_numerator_q;
	reg [31:0] op_numerator_d;
	wire is_greater_equal;
	wire div_change_sign;
	wire rem_change_sign;
	reg div_by_zero_d;
	reg div_by_zero_q;
	reg multdiv_hold;
	wire multdiv_en;
	assign res_adder_l = alu_adder_ext_i[32:0];
	assign res_adder_h = alu_adder_ext_i[33:1];
	assign imd_val_d_o[34+:34] = {1'b0, accum_window_d};
	assign imd_val_we_o[0] = ~multdiv_hold;
	assign accum_window_q = imd_val_q_i[66-:33];
	assign unused_imd_val0 = imd_val_q_i[67];
	assign imd_val_d_o[0+:34] = {2'b00, op_numerator_d};
	assign imd_val_we_o[1] = multdiv_en;
	assign op_numerator_q = imd_val_q_i[31-:32];
	assign unused_imd_val1 = imd_val_q_i[33-:2];
	localparam [2:0] MD_ABS_A = 1;
	localparam [2:0] MD_ABS_B = 2;
	localparam [2:0] MD_CHANGE_SIGN = 5;
	localparam [2:0] MD_IDLE = 0;
	localparam [2:0] MD_LAST = 4;
	always @(*) begin
		alu_operand_a_o = accum_window_q;
		case (operator_i)
			MD_OP_MULL: alu_operand_b_o = op_a_bw_pp;
			MD_OP_MULH: alu_operand_b_o = (md_state_q == MD_LAST ? op_a_bw_last_pp : op_a_bw_pp);
			MD_OP_DIV, MD_OP_REM:
				case (md_state_q)
					MD_IDLE: begin
						alu_operand_a_o = {32'h00000000, 1'b1};
						alu_operand_b_o = {~op_b_i, 1'b1};
					end
					MD_ABS_A: begin
						alu_operand_a_o = {32'h00000000, 1'b1};
						alu_operand_b_o = {~op_a_i, 1'b1};
					end
					MD_ABS_B: begin
						alu_operand_a_o = {32'h00000000, 1'b1};
						alu_operand_b_o = {~op_b_i, 1'b1};
					end
					MD_CHANGE_SIGN: begin
						alu_operand_a_o = {32'h00000000, 1'b1};
						alu_operand_b_o = {~accum_window_q[31:0], 1'b1};
					end
					default: begin
						alu_operand_a_o = {accum_window_q[31:0], 1'b1};
						alu_operand_b_o = {~op_b_shift_q[31:0], 1'b1};
					end
				endcase
			default: begin
				alu_operand_a_o = accum_window_q;
				alu_operand_b_o = {~op_b_shift_q[31:0], 1'b1};
			end
		endcase
	end
	assign b_0 = {32 {op_b_shift_q[0]}};
	assign op_a_bw_pp = {~(op_a_shift_q[32] & op_b_shift_q[0]), op_a_shift_q[31:0] & b_0};
	assign op_a_bw_last_pp = {op_a_shift_q[32] & op_b_shift_q[0], ~(op_a_shift_q[31:0] & b_0)};
	assign sign_a = op_a_i[31] & signed_mode_i[0];
	assign sign_b = op_b_i[31] & signed_mode_i[1];
	assign op_a_ext = {sign_a, op_a_i};
	assign op_b_ext = {sign_b, op_b_i};
	assign is_greater_equal = (accum_window_q[31] == op_b_shift_q[31] ? ~res_adder_h[31] : accum_window_q[31]);
	assign one_shift = {32'b00000000000000000000000000000000, 1'b1} << multdiv_count_q;
	assign next_remainder = (is_greater_equal ? res_adder_h[31:0] : accum_window_q[31:0]);
	assign next_quotient = (is_greater_equal ? op_a_shift_q | one_shift : op_a_shift_q);
	assign div_change_sign = (sign_a ^ sign_b) & ~div_by_zero_q;
	assign rem_change_sign = sign_a;
	localparam [2:0] MD_COMP = 3;
	localparam [2:0] MD_FINISH = 6;
	always @(*) begin
		multdiv_count_d = multdiv_count_q;
		accum_window_d = accum_window_q;
		op_b_shift_d = op_b_shift_q;
		op_a_shift_d = op_a_shift_q;
		op_numerator_d = op_numerator_q;
		md_state_d = md_state_q;
		multdiv_hold = 1'b0;
		div_by_zero_d = div_by_zero_q;
		if (mult_sel_i || div_sel_i)
			case (md_state_q)
				MD_IDLE: begin
					case (operator_i)
						MD_OP_MULL: begin
							op_a_shift_d = op_a_ext << 1;
							accum_window_d = {~(op_a_ext[32] & op_b_i[0]), op_a_ext[31:0] & {32 {op_b_i[0]}}};
							op_b_shift_d = op_b_ext >> 1;
							md_state_d = (!data_ind_timing_i && ((op_b_ext >> 1) == 0) ? MD_LAST : MD_COMP);
						end
						MD_OP_MULH: begin
							op_a_shift_d = op_a_ext;
							accum_window_d = {1'b1, ~(op_a_ext[32] & op_b_i[0]), op_a_ext[31:1] & {31 {op_b_i[0]}}};
							op_b_shift_d = op_b_ext >> 1;
							md_state_d = MD_COMP;
						end
						MD_OP_DIV: begin
							accum_window_d = {33 {1'b1}};
							md_state_d = (!data_ind_timing_i && equal_to_zero_i ? MD_FINISH : MD_ABS_A);
							div_by_zero_d = equal_to_zero_i;
						end
						MD_OP_REM: begin
							accum_window_d = op_a_ext;
							md_state_d = (!data_ind_timing_i && equal_to_zero_i ? MD_FINISH : MD_ABS_A);
						end
						default:
							;
					endcase
					multdiv_count_d = 5'd31;
				end
				MD_ABS_A: begin
					op_a_shift_d = {33 {1'sb0}};
					op_numerator_d = (sign_a ? alu_adder_i : op_a_i);
					md_state_d = MD_ABS_B;
				end
				MD_ABS_B: begin
					accum_window_d = {32'h00000000, op_numerator_q[31]};
					op_b_shift_d = (sign_b ? {1'b0, alu_adder_i} : {1'b0, op_b_i});
					md_state_d = MD_COMP;
				end
				MD_COMP: begin
					multdiv_count_d = multdiv_count_q - 5'h01;
					case (operator_i)
						MD_OP_MULL: begin
							accum_window_d = res_adder_l;
							op_a_shift_d = op_a_shift_q << 1;
							op_b_shift_d = op_b_shift_q >> 1;
							md_state_d = ((!data_ind_timing_i && (op_b_shift_d == 0)) || (multdiv_count_q == 5'd1) ? MD_LAST : MD_COMP);
						end
						MD_OP_MULH: begin
							accum_window_d = res_adder_h;
							op_a_shift_d = op_a_shift_q;
							op_b_shift_d = op_b_shift_q >> 1;
							md_state_d = (multdiv_count_q == 5'd1 ? MD_LAST : MD_COMP);
						end
						MD_OP_DIV, MD_OP_REM: begin
							accum_window_d = {next_remainder[31:0], op_numerator_q[multdiv_count_d]};
							op_a_shift_d = next_quotient;
							md_state_d = (multdiv_count_q == 5'd1 ? MD_LAST : MD_COMP);
						end
						default:
							;
					endcase
				end
				MD_LAST:
					case (operator_i)
						MD_OP_MULL: begin
							accum_window_d = res_adder_l;
							md_state_d = MD_IDLE;
							multdiv_hold = ~multdiv_ready_id_i;
						end
						MD_OP_MULH: begin
							accum_window_d = res_adder_l;
							md_state_d = MD_IDLE;
							md_state_d = MD_IDLE;
							multdiv_hold = ~multdiv_ready_id_i;
						end
						MD_OP_DIV: begin
							accum_window_d = next_quotient;
							md_state_d = MD_CHANGE_SIGN;
						end
						MD_OP_REM: begin
							accum_window_d = {1'b0, next_remainder[31:0]};
							md_state_d = MD_CHANGE_SIGN;
						end
						default:
							;
					endcase
				MD_CHANGE_SIGN: begin
					md_state_d = MD_FINISH;
					case (operator_i)
						MD_OP_DIV: accum_window_d = (div_change_sign ? {1'b0, alu_adder_i} : accum_window_q);
						MD_OP_REM: accum_window_d = (rem_change_sign ? {1'b0, alu_adder_i} : accum_window_q);
						default:
							;
					endcase
				end
				MD_FINISH: begin
					md_state_d = MD_IDLE;
					multdiv_hold = ~multdiv_ready_id_i;
				end
				default: md_state_d = MD_IDLE;
			endcase
	end
	assign multdiv_en = (mult_en_i | div_en_i) & ~multdiv_hold;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			multdiv_count_q <= 5'h00;
			op_b_shift_q <= 33'h000000000;
			op_a_shift_q <= 33'h000000000;
			md_state_q <= MD_IDLE;
			div_by_zero_q <= 1'b0;
		end
		else if (multdiv_en) begin
			multdiv_count_q <= multdiv_count_d;
			op_b_shift_q <= op_b_shift_d;
			op_a_shift_q <= op_a_shift_d;
			md_state_q <= md_state_d;
			div_by_zero_q <= div_by_zero_d;
		end
	assign valid_o = (md_state_q == MD_FINISH) | ((md_state_q == MD_LAST) & ((operator_i == MD_OP_MULL) | (operator_i == MD_OP_MULH)));
	assign multdiv_result_o = (div_en_i ? accum_window_q[31:0] : res_adder_l[31:0]);
endmodule
module brqrv_idu (
	clk_i,
	rst_ni,
	ctrl_busy_o,
	illegal_insn_o,
	instr_valid_i,
	instr_rdata_i,
	instr_rdata_alu_i,
	instr_rdata_c_i,
	instr_is_compressed_i,
	instr_bp_taken_i,
	instr_req_o,
	instr_first_cycle_id_o,
	instr_valid_clear_o,
	id_in_ready_o,
	icache_inval_o,
	branch_decision_i,
	pc_set_o,
	pc_set_spec_o,
	pc_mux_o,
	nt_branch_mispredict_o,
	exc_pc_mux_o,
	exc_cause_o,
	illegal_c_insn_i,
	instr_fetch_err_i,
	instr_fetch_err_plus2_i,
	pc_id_i,
	ex_valid_i,
	lsu_resp_valid_i,
	alu_operator_ex_o,
	alu_operand_a_ex_o,
	alu_operand_b_ex_o,
	imd_val_we_ex_i,
	imd_val_d_ex_i,
	imd_val_q_ex_o,
	bt_a_operand_o,
	bt_b_operand_o,
	mult_en_ex_o,
	div_en_ex_o,
	mult_sel_ex_o,
	div_sel_ex_o,
	multdiv_operator_ex_o,
	multdiv_signed_mode_ex_o,
	multdiv_operand_a_ex_o,
	multdiv_operand_b_ex_o,
	multdiv_ready_id_o,
	csr_access_o,
	csr_op_o,
	csr_op_en_o,
	csr_save_if_o,
	csr_save_id_o,
	csr_save_wb_o,
	csr_restore_mret_id_o,
	csr_restore_dret_id_o,
	csr_save_cause_o,
	csr_mtval_o,
	priv_mode_i,
	csr_mstatus_tw_i,
	illegal_csr_insn_i,
	data_ind_timing_i,
	lsu_req_o,
	lsu_we_o,
	lsu_type_o,
	lsu_sign_ext_o,
	lsu_wdata_o,
	lsu_req_done_i,
	lsu_addr_incr_req_i,
	lsu_addr_last_i,
	csr_mstatus_mie_i,
	irq_pending_i,
	irqs_i,
	irq_nm_i,
	nmi_mode_o,
	lsu_load_err_i,
	lsu_store_err_i,
	debug_mode_o,
	debug_cause_o,
	debug_csr_save_o,
	debug_req_i,
	debug_single_step_i,
	debug_ebreakm_i,
	debug_ebreaku_i,
	trigger_match_i,
	result_ex_i,
	csr_rdata_i,
	rf_raddr_a_o,
	rf_rdata_a_i,
	rf_raddr_b_o,
	rf_rdata_b_i,
	rf_ren_a_o,
	rf_ren_b_o,
	rf_waddr_id_o,
	rf_wdata_id_o,
	rf_we_id_o,
	rf_rd_a_wb_match_o,
	rf_rd_b_wb_match_o,
	rf_waddr_wb_i,
	rf_wdata_fwd_wb_i,
	rf_write_wb_i,
	en_wb_o,
	instr_type_wb_o,
	ready_wb_i,
	outstanding_load_wb_i,
	outstanding_store_wb_i,
	perf_jump_o,
	perf_branch_o,
	perf_tbranch_o,
	perf_dside_wait_o,
	perf_mul_wait_o,
	perf_div_wait_o,
	instr_id_done_o,
	instr_id_done_compressed_o
);
	parameter [0:0] RV32E = 0;
	localparam integer brqrv_pkg_RV32MFast = 2;
	parameter integer RV32M = brqrv_pkg_RV32MFast;
	localparam integer brqrv_pkg_RV32BNone = 0;
	parameter integer RV32B = brqrv_pkg_RV32BNone;
	parameter [0:0] DataIndTiming = 1'b0;
	parameter [0:0] BranchTargetALU = 0;
	parameter [0:0] SpecBranch = 0;
	parameter [0:0] WritebackStage = 0;
	parameter [0:0] BranchPredictor = 0;
	input wire clk_i;
	input wire rst_ni;
	output wire ctrl_busy_o;
	output wire illegal_insn_o;
	input wire instr_valid_i;
	input wire [31:0] instr_rdata_i;
	input wire [31:0] instr_rdata_alu_i;
	input wire [15:0] instr_rdata_c_i;
	input wire instr_is_compressed_i;
	input wire instr_bp_taken_i;
	output wire instr_req_o;
	output wire instr_first_cycle_id_o;
	output wire instr_valid_clear_o;
	output wire id_in_ready_o;
	output wire icache_inval_o;
	input wire branch_decision_i;
	output wire pc_set_o;
	output wire pc_set_spec_o;
	output wire [2:0] pc_mux_o;
	output wire nt_branch_mispredict_o;
	output wire [1:0] exc_pc_mux_o;
	output wire [5:0] exc_cause_o;
	input wire illegal_c_insn_i;
	input wire instr_fetch_err_i;
	input wire instr_fetch_err_plus2_i;
	input wire [31:0] pc_id_i;
	input wire ex_valid_i;
	input wire lsu_resp_valid_i;
	output wire [5:0] alu_operator_ex_o;
	output wire [31:0] alu_operand_a_ex_o;
	output wire [31:0] alu_operand_b_ex_o;
	input wire [1:0] imd_val_we_ex_i;
	input wire [67:0] imd_val_d_ex_i;
	output wire [67:0] imd_val_q_ex_o;
	output reg [31:0] bt_a_operand_o;
	output reg [31:0] bt_b_operand_o;
	output wire mult_en_ex_o;
	output wire div_en_ex_o;
	output wire mult_sel_ex_o;
	output wire div_sel_ex_o;
	output wire [1:0] multdiv_operator_ex_o;
	output wire [1:0] multdiv_signed_mode_ex_o;
	output wire [31:0] multdiv_operand_a_ex_o;
	output wire [31:0] multdiv_operand_b_ex_o;
	output wire multdiv_ready_id_o;
	output wire csr_access_o;
	output wire [1:0] csr_op_o;
	output wire csr_op_en_o;
	output wire csr_save_if_o;
	output wire csr_save_id_o;
	output wire csr_save_wb_o;
	output wire csr_restore_mret_id_o;
	output wire csr_restore_dret_id_o;
	output wire csr_save_cause_o;
	output wire [31:0] csr_mtval_o;
	input wire [1:0] priv_mode_i;
	input wire csr_mstatus_tw_i;
	input wire illegal_csr_insn_i;
	input wire data_ind_timing_i;
	output wire lsu_req_o;
	output wire lsu_we_o;
	output wire [1:0] lsu_type_o;
	output wire lsu_sign_ext_o;
	output wire [31:0] lsu_wdata_o;
	input wire lsu_req_done_i;
	input wire lsu_addr_incr_req_i;
	input wire [31:0] lsu_addr_last_i;
	input wire csr_mstatus_mie_i;
	input wire irq_pending_i;
	input wire [17:0] irqs_i;
	input wire irq_nm_i;
	output wire nmi_mode_o;
	input wire lsu_load_err_i;
	input wire lsu_store_err_i;
	output wire debug_mode_o;
	output wire [2:0] debug_cause_o;
	output wire debug_csr_save_o;
	input wire debug_req_i;
	input wire debug_single_step_i;
	input wire debug_ebreakm_i;
	input wire debug_ebreaku_i;
	input wire trigger_match_i;
	input wire [31:0] result_ex_i;
	input wire [31:0] csr_rdata_i;
	output wire [4:0] rf_raddr_a_o;
	input wire [31:0] rf_rdata_a_i;
	output wire [4:0] rf_raddr_b_o;
	input wire [31:0] rf_rdata_b_i;
	output wire rf_ren_a_o;
	output wire rf_ren_b_o;
	output wire [4:0] rf_waddr_id_o;
	output reg [31:0] rf_wdata_id_o;
	output wire rf_we_id_o;
	output wire rf_rd_a_wb_match_o;
	output wire rf_rd_b_wb_match_o;
	input wire [4:0] rf_waddr_wb_i;
	input wire [31:0] rf_wdata_fwd_wb_i;
	input wire rf_write_wb_i;
	output wire en_wb_o;
	output wire [1:0] instr_type_wb_o;
	input wire ready_wb_i;
	input wire outstanding_load_wb_i;
	input wire outstanding_store_wb_i;
	output wire perf_jump_o;
	output reg perf_branch_o;
	output wire perf_tbranch_o;
	output wire perf_dside_wait_o;
	output wire perf_mul_wait_o;
	output wire perf_div_wait_o;
	output wire instr_id_done_o;
	output wire instr_id_done_compressed_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	wire illegal_insn_dec;
	wire ebrk_insn;
	wire mret_insn_dec;
	wire dret_insn_dec;
	wire ecall_insn_dec;
	wire wfi_insn_dec;
	wire wb_exception;
	wire branch_in_dec;
	reg branch_spec;
	wire branch_set_spec;
	wire branch_set;
	reg branch_set_d;
	reg branch_not_set;
	wire branch_taken;
	wire jump_in_dec;
	wire jump_set_dec;
	reg jump_set;
	wire instr_first_cycle;
	wire instr_executing;
	wire instr_done;
	wire controller_run;
	wire stall_ld_hz;
	wire stall_mem;
	reg stall_multdiv;
	reg stall_branch;
	reg stall_jump;
	wire stall_id;
	wire stall_wb;
	wire flush_id;
	wire multicycle_done;
	wire [31:0] imm_i_type;
	wire [31:0] imm_s_type;
	wire [31:0] imm_b_type;
	wire [31:0] imm_u_type;
	wire [31:0] imm_j_type;
	wire [31:0] zimm_rs1_type;
	wire [31:0] imm_a;
	reg [31:0] imm_b;
	wire rf_wdata_sel;
	wire rf_we_dec;
	reg rf_we_raw;
	wire rf_ren_a;
	wire rf_ren_b;
	assign rf_ren_a_o = rf_ren_a;
	assign rf_ren_b_o = rf_ren_b;
	wire [31:0] rf_rdata_a_fwd;
	wire [31:0] rf_rdata_b_fwd;
	wire [5:0] alu_operator;
	wire [1:0] alu_op_a_mux_sel;
	wire [1:0] alu_op_a_mux_sel_dec;
	wire alu_op_b_mux_sel;
	wire alu_op_b_mux_sel_dec;
	wire alu_multicycle_dec;
	reg stall_alu;
	reg [67:0] imd_val_q;
	wire [1:0] bt_a_mux_sel;
	wire [2:0] bt_b_mux_sel;
	wire imm_a_mux_sel;
	wire [2:0] imm_b_mux_sel;
	wire [2:0] imm_b_mux_sel_dec;
	wire mult_en_id;
	wire mult_en_dec;
	wire div_en_id;
	wire div_en_dec;
	wire multdiv_en_dec;
	wire [1:0] multdiv_operator;
	wire [1:0] multdiv_signed_mode;
	wire lsu_we;
	wire [1:0] lsu_type;
	wire lsu_sign_ext;
	wire lsu_req;
	wire lsu_req_dec;
	wire data_req_allowed;
	reg csr_pipe_flush;
	reg [31:0] alu_operand_a;
	wire [31:0] alu_operand_b;
	assign alu_op_a_mux_sel = (lsu_addr_incr_req_i ? OP_A_FWD : alu_op_a_mux_sel_dec);
	assign alu_op_b_mux_sel = (lsu_addr_incr_req_i ? OP_B_IMM : alu_op_b_mux_sel_dec);
	assign imm_b_mux_sel = (lsu_addr_incr_req_i ? IMM_B_INCR_ADDR : imm_b_mux_sel_dec);
	assign imm_a = (imm_a_mux_sel == IMM_A_Z ? zimm_rs1_type : {32 {1'sb0}});
	always @(*) begin : alu_operand_a_mux
		case (alu_op_a_mux_sel)
			OP_A_REG_A: alu_operand_a = rf_rdata_a_fwd;
			OP_A_FWD: alu_operand_a = lsu_addr_last_i;
			OP_A_CURRPC: alu_operand_a = pc_id_i;
			OP_A_IMM: alu_operand_a = imm_a;
			default: alu_operand_a = pc_id_i;
		endcase
	end
	generate
		if (BranchTargetALU) begin : g_btalu_muxes
			always @(*) begin : bt_operand_a_mux
				case (bt_a_mux_sel)
					OP_A_REG_A: bt_a_operand_o = rf_rdata_a_fwd;
					OP_A_CURRPC: bt_a_operand_o = pc_id_i;
					default: bt_a_operand_o = pc_id_i;
				endcase
			end
			always @(*) begin : bt_immediate_b_mux
				case (bt_b_mux_sel)
					IMM_B_I: bt_b_operand_o = imm_i_type;
					IMM_B_B: bt_b_operand_o = imm_b_type;
					IMM_B_J: bt_b_operand_o = imm_j_type;
					IMM_B_INCR_PC: bt_b_operand_o = (instr_is_compressed_i ? 32'h00000002 : 32'h00000004);
					default: bt_b_operand_o = (instr_is_compressed_i ? 32'h00000002 : 32'h00000004);
				endcase
			end
			always @(*) begin : immediate_b_mux
				case (imm_b_mux_sel)
					IMM_B_I: imm_b = imm_i_type;
					IMM_B_S: imm_b = imm_s_type;
					IMM_B_U: imm_b = imm_u_type;
					IMM_B_INCR_PC: imm_b = (instr_is_compressed_i ? 32'h00000002 : 32'h00000004);
					IMM_B_INCR_ADDR: imm_b = 32'h00000004;
					default: imm_b = 32'h00000004;
				endcase
			end
		end
		else begin : g_nobtalu
			wire [1:0] unused_a_mux_sel;
			wire [2:0] unused_b_mux_sel;
			assign unused_a_mux_sel = bt_a_mux_sel;
			assign unused_b_mux_sel = bt_b_mux_sel;
			always @(*) bt_a_operand_o = {32 {1'sb0}};
			always @(*) bt_b_operand_o = {32 {1'sb0}};
			always @(*) begin : immediate_b_mux
				case (imm_b_mux_sel)
					IMM_B_I: imm_b = imm_i_type;
					IMM_B_S: imm_b = imm_s_type;
					IMM_B_B: imm_b = imm_b_type;
					IMM_B_U: imm_b = imm_u_type;
					IMM_B_J: imm_b = imm_j_type;
					IMM_B_INCR_PC: imm_b = (instr_is_compressed_i ? 32'h00000002 : 32'h00000004);
					IMM_B_INCR_ADDR: imm_b = 32'h00000004;
					default: imm_b = 32'h00000004;
				endcase
			end
		end
	endgenerate
	assign alu_operand_b = (alu_op_b_mux_sel == OP_B_IMM ? imm_b : rf_rdata_b_fwd);
	generate
		genvar i;
		for (i = 0; i < 2; i = i + 1) begin : gen_intermediate_val_reg
			always @(posedge clk_i or negedge rst_ni) begin : intermediate_val_reg
				if (!rst_ni)
					imd_val_q[(1 - i) * 34+:34] <= {34 {1'sb0}};
				else if (imd_val_we_ex_i[i])
					imd_val_q[(1 - i) * 34+:34] <= imd_val_d_ex_i[(1 - i) * 34+:34];
			end
		end
	endgenerate
	assign imd_val_q_ex_o = imd_val_q;
	assign rf_we_id_o = (rf_we_raw & instr_executing) & ~illegal_csr_insn_i;
	always @(*) begin : rf_wdata_id_mux
		case (rf_wdata_sel)
			RF_WD_EX: rf_wdata_id_o = result_ex_i;
			RF_WD_CSR: rf_wdata_id_o = csr_rdata_i;
			default: rf_wdata_id_o = result_ex_i;
		endcase
	end
	brqrv_idu_dec #(
		.RV32E(RV32E),
		.RV32M(RV32M),
		.RV32B(RV32B),
		.BranchTargetALU(BranchTargetALU)
	) decoder_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.illegal_insn_o(illegal_insn_dec),
		.ebrk_insn_o(ebrk_insn),
		.mret_insn_o(mret_insn_dec),
		.dret_insn_o(dret_insn_dec),
		.ecall_insn_o(ecall_insn_dec),
		.wfi_insn_o(wfi_insn_dec),
		.jump_set_o(jump_set_dec),
		.branch_taken_i(branch_taken),
		.icache_inval_o(icache_inval_o),
		.instr_first_cycle_i(instr_first_cycle),
		.instr_rdata_i(instr_rdata_i),
		.instr_rdata_alu_i(instr_rdata_alu_i),
		.illegal_c_insn_i(illegal_c_insn_i),
		.imm_a_mux_sel_o(imm_a_mux_sel),
		.imm_b_mux_sel_o(imm_b_mux_sel_dec),
		.bt_a_mux_sel_o(bt_a_mux_sel),
		.bt_b_mux_sel_o(bt_b_mux_sel),
		.imm_i_type_o(imm_i_type),
		.imm_s_type_o(imm_s_type),
		.imm_b_type_o(imm_b_type),
		.imm_u_type_o(imm_u_type),
		.imm_j_type_o(imm_j_type),
		.zimm_rs1_type_o(zimm_rs1_type),
		.rf_wdata_sel_o(rf_wdata_sel),
		.rf_we_o(rf_we_dec),
		.rf_raddr_a_o(rf_raddr_a_o),
		.rf_raddr_b_o(rf_raddr_b_o),
		.rf_waddr_o(rf_waddr_id_o),
		.rf_ren_a_o(rf_ren_a),
		.rf_ren_b_o(rf_ren_b),
		.alu_operator_o(alu_operator),
		.alu_op_a_mux_sel_o(alu_op_a_mux_sel_dec),
		.alu_op_b_mux_sel_o(alu_op_b_mux_sel_dec),
		.alu_multicycle_o(alu_multicycle_dec),
		.mult_en_o(mult_en_dec),
		.div_en_o(div_en_dec),
		.mult_sel_o(mult_sel_ex_o),
		.div_sel_o(div_sel_ex_o),
		.multdiv_operator_o(multdiv_operator),
		.multdiv_signed_mode_o(multdiv_signed_mode),
		.csr_access_o(csr_access_o),
		.csr_op_o(csr_op_o),
		.data_req_o(lsu_req_dec),
		.data_we_o(lsu_we),
		.data_type_o(lsu_type),
		.data_sign_extension_o(lsu_sign_ext),
		.jump_in_dec_o(jump_in_dec),
		.branch_in_dec_o(branch_in_dec)
	);
	function automatic [11:0] sv2v_cast_12;
		input reg [11:0] inp;
		sv2v_cast_12 = inp;
	endfunction
	always @(*) begin : csr_pipeline_flushes
		csr_pipe_flush = 1'b0;
		if ((csr_op_en_o == 1'b1) && ((csr_op_o == CSR_OP_WRITE) || (csr_op_o == CSR_OP_SET))) begin
			if ((sv2v_cast_12(instr_rdata_i[31:20]) == CSR_MSTATUS) || (sv2v_cast_12(instr_rdata_i[31:20]) == CSR_MIE))
				csr_pipe_flush = 1'b1;
		end
		else if ((csr_op_en_o == 1'b1) && (csr_op_o != CSR_OP_READ))
			if ((((sv2v_cast_12(instr_rdata_i[31:20]) == CSR_DCSR) || (sv2v_cast_12(instr_rdata_i[31:20]) == CSR_DPC)) || (sv2v_cast_12(instr_rdata_i[31:20]) == CSR_DSCRATCH0)) || (sv2v_cast_12(instr_rdata_i[31:20]) == CSR_DSCRATCH1))
				csr_pipe_flush = 1'b1;
	end
	assign illegal_insn_o = instr_valid_i & (illegal_insn_dec | illegal_csr_insn_i);
	brqrv_idu_controller #(
		.WritebackStage(WritebackStage),
		.BranchPredictor(BranchPredictor)
	) controller_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.ctrl_busy_o(ctrl_busy_o),
		.illegal_insn_i(illegal_insn_o),
		.ecall_insn_i(ecall_insn_dec),
		.mret_insn_i(mret_insn_dec),
		.dret_insn_i(dret_insn_dec),
		.wfi_insn_i(wfi_insn_dec),
		.ebrk_insn_i(ebrk_insn),
		.csr_pipe_flush_i(csr_pipe_flush),
		.instr_valid_i(instr_valid_i),
		.instr_i(instr_rdata_i),
		.instr_compressed_i(instr_rdata_c_i),
		.instr_is_compressed_i(instr_is_compressed_i),
		.instr_bp_taken_i(instr_bp_taken_i),
		.instr_fetch_err_i(instr_fetch_err_i),
		.instr_fetch_err_plus2_i(instr_fetch_err_plus2_i),
		.pc_id_i(pc_id_i),
		.instr_valid_clear_o(instr_valid_clear_o),
		.id_in_ready_o(id_in_ready_o),
		.controller_run_o(controller_run),
		.instr_req_o(instr_req_o),
		.pc_set_o(pc_set_o),
		.pc_set_spec_o(pc_set_spec_o),
		.pc_mux_o(pc_mux_o),
		.nt_branch_mispredict_o(nt_branch_mispredict_o),
		.exc_pc_mux_o(exc_pc_mux_o),
		.exc_cause_o(exc_cause_o),
		.lsu_addr_last_i(lsu_addr_last_i),
		.load_err_i(lsu_load_err_i),
		.store_err_i(lsu_store_err_i),
		.wb_exception_o(wb_exception),
		.branch_set_i(branch_set),
		.branch_set_spec_i(branch_set_spec),
		.branch_not_set_i(branch_not_set),
		.jump_set_i(jump_set),
		.csr_mstatus_mie_i(csr_mstatus_mie_i),
		.irq_pending_i(irq_pending_i),
		.irqs_i(irqs_i),
		.irq_nm_i(irq_nm_i),
		.nmi_mode_o(nmi_mode_o),
		.csr_save_if_o(csr_save_if_o),
		.csr_save_id_o(csr_save_id_o),
		.csr_save_wb_o(csr_save_wb_o),
		.csr_restore_mret_id_o(csr_restore_mret_id_o),
		.csr_restore_dret_id_o(csr_restore_dret_id_o),
		.csr_save_cause_o(csr_save_cause_o),
		.csr_mtval_o(csr_mtval_o),
		.priv_mode_i(priv_mode_i),
		.csr_mstatus_tw_i(csr_mstatus_tw_i),
		.debug_mode_o(debug_mode_o),
		.debug_cause_o(debug_cause_o),
		.debug_csr_save_o(debug_csr_save_o),
		.debug_req_i(debug_req_i),
		.debug_single_step_i(debug_single_step_i),
		.debug_ebreakm_i(debug_ebreakm_i),
		.debug_ebreaku_i(debug_ebreaku_i),
		.trigger_match_i(trigger_match_i),
		.stall_id_i(stall_id),
		.stall_wb_i(stall_wb),
		.flush_id_o(flush_id),
		.ready_wb_i(ready_wb_i),
		.perf_jump_o(perf_jump_o),
		.perf_tbranch_o(perf_tbranch_o)
	);
	assign multdiv_en_dec = mult_en_dec | div_en_dec;
	assign lsu_req = (instr_executing ? data_req_allowed & lsu_req_dec : 1'b0);
	assign mult_en_id = (instr_executing ? mult_en_dec : 1'b0);
	assign div_en_id = (instr_executing ? div_en_dec : 1'b0);
	assign lsu_req_o = lsu_req;
	assign lsu_we_o = lsu_we;
	assign lsu_type_o = lsu_type;
	assign lsu_sign_ext_o = lsu_sign_ext;
	assign lsu_wdata_o = rf_rdata_b_fwd;
	assign csr_op_en_o = (csr_access_o & instr_executing) & instr_id_done_o;
	assign alu_operator_ex_o = alu_operator;
	assign alu_operand_a_ex_o = alu_operand_a;
	assign alu_operand_b_ex_o = alu_operand_b;
	assign mult_en_ex_o = mult_en_id;
	assign div_en_ex_o = div_en_id;
	assign multdiv_operator_ex_o = multdiv_operator;
	assign multdiv_signed_mode_ex_o = multdiv_signed_mode;
	assign multdiv_operand_a_ex_o = rf_rdata_a_fwd;
	assign multdiv_operand_b_ex_o = rf_rdata_b_fwd;
	generate
		if (BranchTargetALU && !DataIndTiming) begin : g_branch_set_direct
			assign branch_set = branch_set_d;
			assign branch_set_spec = branch_spec;
		end
		else begin : g_branch_set_flop
			reg branch_set_q;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					branch_set_q <= 1'b0;
				else
					branch_set_q <= branch_set_d;
			assign branch_set = (BranchTargetALU && !data_ind_timing_i ? branch_set_d : branch_set_q);
			assign branch_set_spec = (BranchTargetALU && !data_ind_timing_i ? branch_spec : branch_set_q);
		end
	endgenerate
	generate
		if (DataIndTiming) begin : g_sec_branch_taken
			reg branch_taken_q;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					branch_taken_q <= 1'b0;
				else
					branch_taken_q <= branch_decision_i;
			assign branch_taken = ~data_ind_timing_i | branch_taken_q;
		end
		else begin : g_nosec_branch_taken
			assign branch_taken = 1'b1;
		end
	endgenerate
	reg id_fsm_q;
	reg id_fsm_d;
	localparam [0:0] FIRST_CYCLE = 0;
	always @(posedge clk_i or negedge rst_ni) begin : id_pipeline_reg
		if (!rst_ni)
			id_fsm_q <= FIRST_CYCLE;
		else
			id_fsm_q <= id_fsm_d;
	end
	localparam [0:0] MULTI_CYCLE = 1;
	always @(*) begin
		id_fsm_d = id_fsm_q;
		rf_we_raw = rf_we_dec;
		stall_multdiv = 1'b0;
		stall_jump = 1'b0;
		stall_branch = 1'b0;
		stall_alu = 1'b0;
		branch_set_d = 1'b0;
		branch_spec = 1'b0;
		branch_not_set = 1'b0;
		jump_set = 1'b0;
		perf_branch_o = 1'b0;
		if (instr_executing)
			case (id_fsm_q)
				FIRST_CYCLE:
					case (1'b1)
						lsu_req_dec:
							if (!WritebackStage)
								id_fsm_d = MULTI_CYCLE;
							else if (~lsu_req_done_i)
								id_fsm_d = MULTI_CYCLE;
						multdiv_en_dec:
							if (~ex_valid_i) begin
								id_fsm_d = MULTI_CYCLE;
								rf_we_raw = 1'b0;
								stall_multdiv = 1'b1;
							end
						branch_in_dec: begin
							id_fsm_d = (data_ind_timing_i || (!BranchTargetALU && branch_decision_i) ? MULTI_CYCLE : FIRST_CYCLE);
							stall_branch = (~BranchTargetALU & branch_decision_i) | data_ind_timing_i;
							branch_set_d = branch_decision_i | data_ind_timing_i;
							if (BranchPredictor)
								branch_not_set = ~branch_decision_i;
							branch_spec = (SpecBranch ? 1'b1 : branch_decision_i);
							perf_branch_o = 1'b1;
						end
						jump_in_dec: begin
							id_fsm_d = (BranchTargetALU ? FIRST_CYCLE : MULTI_CYCLE);
							stall_jump = ~BranchTargetALU;
							jump_set = jump_set_dec;
						end
						alu_multicycle_dec: begin
							stall_alu = 1'b1;
							id_fsm_d = MULTI_CYCLE;
							rf_we_raw = 1'b0;
						end
						default: id_fsm_d = FIRST_CYCLE;
					endcase
				MULTI_CYCLE: begin
					if (multdiv_en_dec)
						rf_we_raw = rf_we_dec & ex_valid_i;
					if (multicycle_done & ready_wb_i)
						id_fsm_d = FIRST_CYCLE;
					else begin
						stall_multdiv = multdiv_en_dec;
						stall_branch = branch_in_dec;
						stall_jump = jump_in_dec;
					end
				end
				default: id_fsm_d = FIRST_CYCLE;
			endcase
	end
	assign multdiv_ready_id_o = ready_wb_i;
	assign stall_id = ((((stall_ld_hz | stall_mem) | stall_multdiv) | stall_jump) | stall_branch) | stall_alu;
	assign instr_done = (~stall_id & ~flush_id) & instr_executing;
	assign instr_first_cycle = instr_valid_i & (id_fsm_q == FIRST_CYCLE);
	assign instr_first_cycle_id_o = instr_first_cycle;
	generate
		if (WritebackStage) begin : gen_stall_mem
			wire rf_rd_a_wb_match;
			wire rf_rd_b_wb_match;
			wire rf_rd_a_hz;
			wire rf_rd_b_hz;
			wire outstanding_memory_access;
			wire instr_kill;
			assign multicycle_done = (lsu_req_dec ? ~stall_mem : ex_valid_i);
			assign outstanding_memory_access = (outstanding_load_wb_i | outstanding_store_wb_i) & ~lsu_resp_valid_i;
			assign data_req_allowed = ~outstanding_memory_access;
			assign instr_kill = (instr_fetch_err_i | wb_exception) | ~controller_run;
			assign instr_executing = ((instr_valid_i & ~instr_kill) & ~stall_ld_hz) & ~outstanding_memory_access;
			assign stall_mem = instr_valid_i & (outstanding_memory_access | (lsu_req_dec & ~lsu_req_done_i));
			assign rf_rd_a_wb_match = (rf_waddr_wb_i == rf_raddr_a_o) & |rf_raddr_a_o;
			assign rf_rd_b_wb_match = (rf_waddr_wb_i == rf_raddr_b_o) & |rf_raddr_b_o;
			assign rf_rd_a_wb_match_o = rf_rd_a_wb_match;
			assign rf_rd_b_wb_match_o = rf_rd_b_wb_match;
			assign rf_rd_a_hz = rf_rd_a_wb_match & rf_ren_a;
			assign rf_rd_b_hz = rf_rd_b_wb_match & rf_ren_b;
			assign rf_rdata_a_fwd = (rf_rd_a_wb_match & rf_write_wb_i ? rf_wdata_fwd_wb_i : rf_rdata_a_i);
			assign rf_rdata_b_fwd = (rf_rd_b_wb_match & rf_write_wb_i ? rf_wdata_fwd_wb_i : rf_rdata_b_i);
			assign stall_ld_hz = outstanding_load_wb_i & (rf_rd_a_hz | rf_rd_b_hz);
			assign instr_type_wb_o = (~lsu_req_dec ? WB_INSTR_OTHER : (lsu_we ? WB_INSTR_STORE : WB_INSTR_LOAD));
			assign en_wb_o = instr_done;
			assign instr_id_done_o = en_wb_o & ready_wb_i;
			assign stall_wb = en_wb_o & ~ready_wb_i;
			assign perf_dside_wait_o = (instr_valid_i & ~instr_kill) & (outstanding_memory_access | stall_ld_hz);
		end
		else begin : gen_no_stall_mem
			assign multicycle_done = (lsu_req_dec ? lsu_resp_valid_i : ex_valid_i);
			assign data_req_allowed = instr_first_cycle;
			assign stall_mem = instr_valid_i & (lsu_req_dec & (~lsu_resp_valid_i | instr_first_cycle));
			assign stall_ld_hz = 1'b0;
			assign instr_executing = (instr_valid_i & ~instr_fetch_err_i) & controller_run;
			assign rf_rdata_a_fwd = rf_rdata_a_i;
			assign rf_rdata_b_fwd = rf_rdata_b_i;
			assign rf_rd_a_wb_match_o = 1'b0;
			assign rf_rd_b_wb_match_o = 1'b0;
			wire unused_data_req_done_ex;
			wire unused_lsu_load;
			wire [4:0] unused_rf_waddr_wb;
			wire unused_rf_write_wb;
			wire unused_outstanding_load_wb;
			wire unused_outstanding_store_wb;
			wire unused_wb_exception;
			wire [31:0] unused_rf_wdata_fwd_wb;
			assign unused_data_req_done_ex = lsu_req_done_i;
			assign unused_rf_waddr_wb = rf_waddr_wb_i;
			assign unused_rf_write_wb = rf_write_wb_i;
			assign unused_outstanding_load_wb = outstanding_load_wb_i;
			assign unused_outstanding_store_wb = outstanding_store_wb_i;
			assign unused_wb_exception = wb_exception;
			assign unused_rf_wdata_fwd_wb = rf_wdata_fwd_wb_i;
			assign instr_type_wb_o = WB_INSTR_OTHER;
			assign stall_wb = 1'b0;
			assign perf_dside_wait_o = (instr_executing & lsu_req_dec) & ~lsu_resp_valid_i;
			assign en_wb_o = 1'b0;
			assign instr_id_done_o = instr_done;
		end
	endgenerate
	assign perf_mul_wait_o = stall_multdiv & mult_en_dec;
	assign perf_div_wait_o = stall_multdiv & div_en_dec;
	assign instr_id_done_compressed_o = instr_id_done_o & instr_is_compressed_i;
endmodule
module brqrv_idu_controller (
	clk_i,
	rst_ni,
	ctrl_busy_o,
	illegal_insn_i,
	ecall_insn_i,
	mret_insn_i,
	dret_insn_i,
	wfi_insn_i,
	ebrk_insn_i,
	csr_pipe_flush_i,
	instr_valid_i,
	instr_i,
	instr_compressed_i,
	instr_is_compressed_i,
	instr_bp_taken_i,
	instr_fetch_err_i,
	instr_fetch_err_plus2_i,
	pc_id_i,
	instr_valid_clear_o,
	id_in_ready_o,
	controller_run_o,
	instr_req_o,
	pc_set_o,
	pc_set_spec_o,
	pc_mux_o,
	nt_branch_mispredict_o,
	exc_pc_mux_o,
	exc_cause_o,
	lsu_addr_last_i,
	load_err_i,
	store_err_i,
	wb_exception_o,
	branch_set_i,
	branch_set_spec_i,
	branch_not_set_i,
	jump_set_i,
	csr_mstatus_mie_i,
	irq_pending_i,
	irqs_i,
	irq_nm_i,
	nmi_mode_o,
	debug_req_i,
	debug_cause_o,
	debug_csr_save_o,
	debug_mode_o,
	debug_single_step_i,
	debug_ebreakm_i,
	debug_ebreaku_i,
	trigger_match_i,
	csr_save_if_o,
	csr_save_id_o,
	csr_save_wb_o,
	csr_restore_mret_id_o,
	csr_restore_dret_id_o,
	csr_save_cause_o,
	csr_mtval_o,
	priv_mode_i,
	csr_mstatus_tw_i,
	stall_id_i,
	stall_wb_i,
	flush_id_o,
	ready_wb_i,
	perf_jump_o,
	perf_tbranch_o
);
	parameter [0:0] WritebackStage = 0;
	parameter [0:0] BranchPredictor = 0;
	input wire clk_i;
	input wire rst_ni;
	output reg ctrl_busy_o;
	input wire illegal_insn_i;
	input wire ecall_insn_i;
	input wire mret_insn_i;
	input wire dret_insn_i;
	input wire wfi_insn_i;
	input wire ebrk_insn_i;
	input wire csr_pipe_flush_i;
	input wire instr_valid_i;
	input wire [31:0] instr_i;
	input wire [15:0] instr_compressed_i;
	input wire instr_is_compressed_i;
	input wire instr_bp_taken_i;
	input wire instr_fetch_err_i;
	input wire instr_fetch_err_plus2_i;
	input wire [31:0] pc_id_i;
	output wire instr_valid_clear_o;
	output wire id_in_ready_o;
	output reg controller_run_o;
	output reg instr_req_o;
	output reg pc_set_o;
	output reg pc_set_spec_o;
	output reg [2:0] pc_mux_o;
	output reg nt_branch_mispredict_o;
	output reg [1:0] exc_pc_mux_o;
	output reg [5:0] exc_cause_o;
	input wire [31:0] lsu_addr_last_i;
	input wire load_err_i;
	input wire store_err_i;
	output wire wb_exception_o;
	input wire branch_set_i;
	input wire branch_set_spec_i;
	input wire branch_not_set_i;
	input wire jump_set_i;
	input wire csr_mstatus_mie_i;
	input wire irq_pending_i;
	input wire [17:0] irqs_i;
	input wire irq_nm_i;
	output wire nmi_mode_o;
	input wire debug_req_i;
	output reg [2:0] debug_cause_o;
	output reg debug_csr_save_o;
	output wire debug_mode_o;
	input wire debug_single_step_i;
	input wire debug_ebreakm_i;
	input wire debug_ebreaku_i;
	input wire trigger_match_i;
	output reg csr_save_if_o;
	output reg csr_save_id_o;
	output reg csr_save_wb_o;
	output reg csr_restore_mret_id_o;
	output reg csr_restore_dret_id_o;
	output reg csr_save_cause_o;
	output reg [31:0] csr_mtval_o;
	input wire [1:0] priv_mode_i;
	input wire csr_mstatus_tw_i;
	input wire stall_id_i;
	input wire stall_wb_i;
	output wire flush_id_o;
	input wire ready_wb_i;
	output reg perf_jump_o;
	output reg perf_tbranch_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	reg [3:0] ctrl_fsm_cs;
	reg [3:0] ctrl_fsm_ns;
	reg nmi_mode_q;
	reg nmi_mode_d;
	reg debug_mode_q;
	reg debug_mode_d;
	reg load_err_q;
	wire load_err_d;
	reg store_err_q;
	wire store_err_d;
	reg exc_req_q;
	wire exc_req_d;
	reg illegal_insn_q;
	wire illegal_insn_d;
	reg instr_fetch_err_prio;
	reg illegal_insn_prio;
	reg ecall_insn_prio;
	reg ebrk_insn_prio;
	reg store_err_prio;
	reg load_err_prio;
	wire stall;
	reg halt_if;
	reg retain_id;
	reg flush_id;
	wire illegal_dret;
	wire illegal_umode;
	wire exc_req_lsu;
	wire special_req_all;
	wire special_req_branch;
	wire enter_debug_mode;
	wire ebreak_into_debug;
	wire handle_irq;
	reg [3:0] mfip_id;
	wire unused_irq_timer;
	wire ecall_insn;
	wire mret_insn;
	wire dret_insn;
	wire wfi_insn;
	wire ebrk_insn;
	wire csr_pipe_flush;
	wire instr_fetch_err;
	localparam [3:0] DECODE = 5;
	/*always @(negedge clk_i)
		if ((((ctrl_fsm_cs == DECODE) && instr_valid_i) && !instr_fetch_err_i) && illegal_insn_d)
			$display("%t: Illegal instruction (hart %0x) at PC 0x%h: 0x%h", $time, brqrv_core.hart_id_i, brqrv_idu.pc_id_i, brqrv_idu.instr_rdata_i);
	*/
	assign load_err_d = load_err_i;
	assign store_err_d = store_err_i;
	assign ecall_insn = ecall_insn_i & instr_valid_i;
	assign mret_insn = mret_insn_i & instr_valid_i;
	assign dret_insn = dret_insn_i & instr_valid_i;
	assign wfi_insn = wfi_insn_i & instr_valid_i;
	assign ebrk_insn = ebrk_insn_i & instr_valid_i;
	assign csr_pipe_flush = csr_pipe_flush_i & instr_valid_i;
	assign instr_fetch_err = instr_fetch_err_i & instr_valid_i;
	assign illegal_dret = dret_insn & ~debug_mode_q;
	assign illegal_umode = (priv_mode_i != PRIV_LVL_M) & (mret_insn | (csr_mstatus_tw_i & wfi_insn));
	localparam [3:0] FLUSH = 6;
	assign illegal_insn_d = ((illegal_insn_i | illegal_dret) | illegal_umode) & (ctrl_fsm_cs != FLUSH);
	assign exc_req_d = (((ecall_insn | ebrk_insn) | illegal_insn_d) | instr_fetch_err) & (ctrl_fsm_cs != FLUSH);
	assign exc_req_lsu = store_err_i | load_err_i;
	assign special_req_all = ((((mret_insn | dret_insn) | wfi_insn) | csr_pipe_flush) | exc_req_d) | exc_req_lsu;
	assign special_req_branch = instr_fetch_err & (ctrl_fsm_cs != FLUSH);
	generate
		if (WritebackStage) begin : g_wb_exceptions
			always @(*) begin
				instr_fetch_err_prio = 0;
				illegal_insn_prio = 0;
				ecall_insn_prio = 0;
				ebrk_insn_prio = 0;
				store_err_prio = 0;
				load_err_prio = 0;
				if (store_err_q)
					store_err_prio = 1'b1;
				else if (load_err_q)
					load_err_prio = 1'b1;
				else if (instr_fetch_err)
					instr_fetch_err_prio = 1'b1;
				else if (illegal_insn_q)
					illegal_insn_prio = 1'b1;
				else if (ecall_insn)
					ecall_insn_prio = 1'b1;
				else if (ebrk_insn)
					ebrk_insn_prio = 1'b1;
			end
			assign wb_exception_o = ((load_err_q | store_err_q) | load_err_i) | store_err_i;
		end
		else begin : g_no_wb_exceptions
			always @(*) begin
				instr_fetch_err_prio = 0;
				illegal_insn_prio = 0;
				ecall_insn_prio = 0;
				ebrk_insn_prio = 0;
				store_err_prio = 0;
				load_err_prio = 0;
				if (instr_fetch_err)
					instr_fetch_err_prio = 1'b1;
				else if (illegal_insn_q)
					illegal_insn_prio = 1'b1;
				else if (ecall_insn)
					ecall_insn_prio = 1'b1;
				else if (ebrk_insn)
					ebrk_insn_prio = 1'b1;
				else if (store_err_q)
					store_err_prio = 1'b1;
				else if (load_err_q)
					load_err_prio = 1'b1;
			end
			assign wb_exception_o = 1'b0;
		end
	endgenerate
	assign enter_debug_mode = ((debug_req_i | (debug_single_step_i & instr_valid_i)) | trigger_match_i) & ~debug_mode_q;
	assign ebreak_into_debug = (priv_mode_i == PRIV_LVL_M ? debug_ebreakm_i : (priv_mode_i == PRIV_LVL_U ? debug_ebreaku_i : 1'b0));
	assign handle_irq = (~debug_mode_q & ~nmi_mode_q) & (irq_nm_i | (irq_pending_i & csr_mstatus_mie_i));
	always @(*) begin : gen_mfip_id
		if (irqs_i[14])
			mfip_id = 4'd14;
		else if (irqs_i[13])
			mfip_id = 4'd13;
		else if (irqs_i[12])
			mfip_id = 4'd12;
		else if (irqs_i[11])
			mfip_id = 4'd11;
		else if (irqs_i[10])
			mfip_id = 4'd10;
		else if (irqs_i[9])
			mfip_id = 4'd9;
		else if (irqs_i[8])
			mfip_id = 4'd8;
		else if (irqs_i[7])
			mfip_id = 4'd7;
		else if (irqs_i[6])
			mfip_id = 4'd6;
		else if (irqs_i[5])
			mfip_id = 4'd5;
		else if (irqs_i[4])
			mfip_id = 4'd4;
		else if (irqs_i[3])
			mfip_id = 4'd3;
		else if (irqs_i[2])
			mfip_id = 4'd2;
		else if (irqs_i[1])
			mfip_id = 4'd1;
		else
			mfip_id = 4'd0;
	end
	assign unused_irq_timer = irqs_i[16];
	function automatic [5:0] sv2v_cast_6;
		input reg [5:0] inp;
		sv2v_cast_6 = inp;
	endfunction
	localparam [3:0] BOOT_SET = 1;
	localparam [3:0] DBG_TAKEN_ID = 9;
	localparam [3:0] DBG_TAKEN_IF = 8;
	localparam [3:0] FIRST_FETCH = 4;
	localparam [3:0] IRQ_TAKEN = 7;
	localparam [3:0] RESET = 0;
	localparam [3:0] SLEEP = 3;
	localparam [3:0] WAIT_SLEEP = 2;
	always @(*) begin
		instr_req_o = 1'b1;
		csr_save_if_o = 1'b0;
		csr_save_id_o = 1'b0;
		csr_save_wb_o = 1'b0;
		csr_restore_mret_id_o = 1'b0;
		csr_restore_dret_id_o = 1'b0;
		csr_save_cause_o = 1'b0;
		csr_mtval_o = {32 {1'sb0}};
		pc_mux_o = PC_BOOT;
		pc_set_o = 1'b0;
		pc_set_spec_o = 1'b0;
		nt_branch_mispredict_o = 1'b0;
		exc_pc_mux_o = EXC_PC_IRQ;
		exc_cause_o = EXC_CAUSE_INSN_ADDR_MISA;
		ctrl_fsm_ns = ctrl_fsm_cs;
		ctrl_busy_o = 1'b1;
		halt_if = 1'b0;
		retain_id = 1'b0;
		flush_id = 1'b0;
		debug_csr_save_o = 1'b0;
		debug_cause_o = DBG_CAUSE_EBREAK;
		debug_mode_d = debug_mode_q;
		nmi_mode_d = nmi_mode_q;
		perf_tbranch_o = 1'b0;
		perf_jump_o = 1'b0;
		controller_run_o = 1'b0;
		case (ctrl_fsm_cs)
			RESET: begin
				instr_req_o = 1'b0;
				pc_mux_o = PC_BOOT;
				pc_set_o = 1'b1;
				pc_set_spec_o = 1'b1;
				ctrl_fsm_ns = BOOT_SET;
			end
			BOOT_SET: begin
				instr_req_o = 1'b1;
				pc_mux_o = PC_BOOT;
				pc_set_o = 1'b1;
				pc_set_spec_o = 1'b1;
				ctrl_fsm_ns = FIRST_FETCH;
			end
			WAIT_SLEEP: begin
				ctrl_busy_o = 1'b0;
				instr_req_o = 1'b0;
				halt_if = 1'b1;
				flush_id = 1'b1;
				ctrl_fsm_ns = SLEEP;
			end
			SLEEP: begin
				instr_req_o = 1'b0;
				halt_if = 1'b1;
				flush_id = 1'b1;
				if ((((irq_nm_i || irq_pending_i) || debug_req_i) || debug_mode_q) || debug_single_step_i)
					ctrl_fsm_ns = FIRST_FETCH;
				else
					ctrl_busy_o = 1'b0;
			end
			FIRST_FETCH: begin
				if (id_in_ready_o)
					ctrl_fsm_ns = DECODE;
				if (handle_irq) begin
					ctrl_fsm_ns = IRQ_TAKEN;
					halt_if = 1'b1;
				end
				if (enter_debug_mode) begin
					ctrl_fsm_ns = DBG_TAKEN_IF;
					halt_if = 1'b1;
				end
			end
			DECODE: begin
				controller_run_o = 1'b1;
				pc_mux_o = PC_JUMP;
				if (special_req_all) begin
					retain_id = 1'b1;
					if (ready_wb_i | wb_exception_o)
						ctrl_fsm_ns = FLUSH;
				end
				if (!special_req_branch) begin
					if (branch_set_i || jump_set_i) begin
						pc_set_o = (BranchPredictor ? ~instr_bp_taken_i : 1'b1);
						perf_tbranch_o = branch_set_i;
						perf_jump_o = jump_set_i;
					end
					if (BranchPredictor)
						if (instr_bp_taken_i & branch_not_set_i)
							nt_branch_mispredict_o = 1'b1;
				end
				if ((branch_set_spec_i || jump_set_i) && !special_req_branch)
					pc_set_spec_o = (BranchPredictor ? ~instr_bp_taken_i : 1'b1);
				if ((enter_debug_mode || handle_irq) && stall)
					halt_if = 1'b1;
				if (!stall && !special_req_all)
					if (enter_debug_mode) begin
						ctrl_fsm_ns = DBG_TAKEN_IF;
						halt_if = 1'b1;
					end
					else if (handle_irq) begin
						ctrl_fsm_ns = IRQ_TAKEN;
						halt_if = 1'b1;
					end
			end
			IRQ_TAKEN: begin
				pc_mux_o = PC_EXC;
				exc_pc_mux_o = EXC_PC_IRQ;
				if (handle_irq) begin
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					csr_save_if_o = 1'b1;
					csr_save_cause_o = 1'b1;
					if (irq_nm_i && !nmi_mode_q) begin
						exc_cause_o = EXC_CAUSE_IRQ_NM;
						nmi_mode_d = 1'b1;
					end
					else if (irqs_i[14-:15] != 15'b000000000000000)
						exc_cause_o = sv2v_cast_6({2'b11, mfip_id});
					else if (irqs_i[15])
						exc_cause_o = EXC_CAUSE_IRQ_EXTERNAL_M;
					else if (irqs_i[17])
						exc_cause_o = EXC_CAUSE_IRQ_SOFTWARE_M;
					else
						exc_cause_o = EXC_CAUSE_IRQ_TIMER_M;
				end
				ctrl_fsm_ns = DECODE;
			end
			DBG_TAKEN_IF: begin
				pc_mux_o = PC_EXC;
				exc_pc_mux_o = EXC_PC_DBD;
				if ((debug_single_step_i || debug_req_i) || trigger_match_i) begin
					flush_id = 1'b1;
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					csr_save_if_o = 1'b1;
					debug_csr_save_o = 1'b1;
					csr_save_cause_o = 1'b1;
					if (trigger_match_i)
						debug_cause_o = DBG_CAUSE_TRIGGER;
					else if (debug_single_step_i)
						debug_cause_o = DBG_CAUSE_STEP;
					else
						debug_cause_o = DBG_CAUSE_HALTREQ;
					debug_mode_d = 1'b1;
				end
				ctrl_fsm_ns = DECODE;
			end
			DBG_TAKEN_ID: begin
				flush_id = 1'b1;
				pc_mux_o = PC_EXC;
				pc_set_o = 1'b1;
				pc_set_spec_o = 1'b1;
				exc_pc_mux_o = EXC_PC_DBD;
				if (ebreak_into_debug && !debug_mode_q) begin
					csr_save_cause_o = 1'b1;
					csr_save_id_o = 1'b1;
					debug_csr_save_o = 1'b1;
					debug_cause_o = DBG_CAUSE_EBREAK;
				end
				debug_mode_d = 1'b1;
				ctrl_fsm_ns = DECODE;
			end
			FLUSH: begin
				halt_if = 1'b1;
				flush_id = 1'b1;
				ctrl_fsm_ns = DECODE;
				if ((exc_req_q || store_err_q) || load_err_q) begin
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					pc_mux_o = PC_EXC;
					exc_pc_mux_o = (debug_mode_q ? EXC_PC_DBG_EXC : EXC_PC_EXC);
					if (WritebackStage) begin : g_writeback_mepc_save
						csr_save_id_o = ~(store_err_q | load_err_q);
						csr_save_wb_o = store_err_q | load_err_q;
					end
					else begin : g_no_writeback_mepc_save
						csr_save_id_o = 1'b0;
					end
					csr_save_cause_o = 1'b1;
					case (1'b1)
						instr_fetch_err_prio: begin
							exc_cause_o = EXC_CAUSE_INSTR_ACCESS_FAULT;
							csr_mtval_o = (instr_fetch_err_plus2_i ? pc_id_i + 32'd2 : pc_id_i);
						end
						illegal_insn_prio: begin
							exc_cause_o = EXC_CAUSE_ILLEGAL_INSN;
							csr_mtval_o = (instr_is_compressed_i ? {16'b0000000000000000, instr_compressed_i} : instr_i);
						end
						ecall_insn_prio: exc_cause_o = (priv_mode_i == PRIV_LVL_M ? EXC_CAUSE_ECALL_MMODE : EXC_CAUSE_ECALL_UMODE);
						ebrk_insn_prio:
							if (debug_mode_q | ebreak_into_debug) begin
								pc_set_o = 1'b0;
								pc_set_spec_o = 1'b0;
								csr_save_id_o = 1'b0;
								csr_save_cause_o = 1'b0;
								ctrl_fsm_ns = DBG_TAKEN_ID;
								flush_id = 1'b0;
							end
							else
								exc_cause_o = EXC_CAUSE_BREAKPOINT;
						store_err_prio: begin
							exc_cause_o = EXC_CAUSE_STORE_ACCESS_FAULT;
							csr_mtval_o = lsu_addr_last_i;
						end
						load_err_prio: begin
							exc_cause_o = EXC_CAUSE_LOAD_ACCESS_FAULT;
							csr_mtval_o = lsu_addr_last_i;
						end
						default:
							;
					endcase
				end
				else if (mret_insn) begin
					pc_mux_o = PC_ERET;
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					csr_restore_mret_id_o = 1'b1;
					if (nmi_mode_q)
						nmi_mode_d = 1'b0;
				end
				else if (dret_insn) begin
					pc_mux_o = PC_DRET;
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					debug_mode_d = 1'b0;
					csr_restore_dret_id_o = 1'b1;
				end
				else if (wfi_insn)
					ctrl_fsm_ns = WAIT_SLEEP;
				else if (csr_pipe_flush && handle_irq)
					ctrl_fsm_ns = IRQ_TAKEN;
				if (enter_debug_mode && !(ebrk_insn_prio && ebreak_into_debug))
					ctrl_fsm_ns = DBG_TAKEN_IF;
			end
			default: begin
				instr_req_o = 1'b0;
				ctrl_fsm_ns = RESET;
			end
		endcase
	end
	assign flush_id_o = flush_id;
	assign debug_mode_o = debug_mode_q;
	assign nmi_mode_o = nmi_mode_q;
	assign stall = stall_id_i | stall_wb_i;
	assign id_in_ready_o = (~stall & ~halt_if) & ~retain_id;
	assign instr_valid_clear_o = ~(stall | retain_id) | flush_id;
	always @(posedge clk_i or negedge rst_ni) begin : update_regs
		if (!rst_ni) begin
			ctrl_fsm_cs <= RESET;
			nmi_mode_q <= 1'b0;
			debug_mode_q <= 1'b0;
			load_err_q <= 1'b0;
			store_err_q <= 1'b0;
			exc_req_q <= 1'b0;
			illegal_insn_q <= 1'b0;
		end
		else begin
			ctrl_fsm_cs <= ctrl_fsm_ns;
			nmi_mode_q <= nmi_mode_d;
			debug_mode_q <= debug_mode_d;
			load_err_q <= load_err_d;
			store_err_q <= store_err_d;
			exc_req_q <= exc_req_d;
			illegal_insn_q <= illegal_insn_d;
		end
	end
endmodule
module brqrv_idu_dec (
	clk_i,
	rst_ni,
	illegal_insn_o,
	ebrk_insn_o,
	mret_insn_o,
	dret_insn_o,
	ecall_insn_o,
	wfi_insn_o,
	jump_set_o,
	branch_taken_i,
	icache_inval_o,
	instr_first_cycle_i,
	instr_rdata_i,
	instr_rdata_alu_i,
	illegal_c_insn_i,
	imm_a_mux_sel_o,
	imm_b_mux_sel_o,
	bt_a_mux_sel_o,
	bt_b_mux_sel_o,
	imm_i_type_o,
	imm_s_type_o,
	imm_b_type_o,
	imm_u_type_o,
	imm_j_type_o,
	zimm_rs1_type_o,
	rf_wdata_sel_o,
	rf_we_o,
	rf_raddr_a_o,
	rf_raddr_b_o,
	rf_waddr_o,
	rf_ren_a_o,
	rf_ren_b_o,
	alu_operator_o,
	alu_op_a_mux_sel_o,
	alu_op_b_mux_sel_o,
	alu_multicycle_o,
	mult_en_o,
	div_en_o,
	mult_sel_o,
	div_sel_o,
	multdiv_operator_o,
	multdiv_signed_mode_o,
	csr_access_o,
	csr_op_o,
	data_req_o,
	data_we_o,
	data_type_o,
	data_sign_extension_o,
	jump_in_dec_o,
	branch_in_dec_o
);
	parameter [0:0] RV32E = 0;
	localparam integer brqrv_pkg_RV32MFast = 2;
	parameter integer RV32M = brqrv_pkg_RV32MFast;
	localparam integer brqrv_pkg_RV32BNone = 0;
	parameter integer RV32B = brqrv_pkg_RV32BNone;
	parameter [0:0] BranchTargetALU = 0;
	input wire clk_i;
	input wire rst_ni;
	output wire illegal_insn_o;
	output reg ebrk_insn_o;
	output reg mret_insn_o;
	output reg dret_insn_o;
	output reg ecall_insn_o;
	output reg wfi_insn_o;
	output reg jump_set_o;
	input wire branch_taken_i;
	output reg icache_inval_o;
	input wire instr_first_cycle_i;
	input wire [31:0] instr_rdata_i;
	input wire [31:0] instr_rdata_alu_i;
	input wire illegal_c_insn_i;
	output reg imm_a_mux_sel_o;
	output reg [2:0] imm_b_mux_sel_o;
	output reg [1:0] bt_a_mux_sel_o;
	output reg [2:0] bt_b_mux_sel_o;
	output wire [31:0] imm_i_type_o;
	output wire [31:0] imm_s_type_o;
	output wire [31:0] imm_b_type_o;
	output wire [31:0] imm_u_type_o;
	output wire [31:0] imm_j_type_o;
	output wire [31:0] zimm_rs1_type_o;
	output reg rf_wdata_sel_o;
	output wire rf_we_o;
	output wire [4:0] rf_raddr_a_o;
	output wire [4:0] rf_raddr_b_o;
	output wire [4:0] rf_waddr_o;
	output reg rf_ren_a_o;
	output reg rf_ren_b_o;
	output reg [5:0] alu_operator_o;
	output reg [1:0] alu_op_a_mux_sel_o;
	output reg alu_op_b_mux_sel_o;
	output reg alu_multicycle_o;
	output wire mult_en_o;
	output wire div_en_o;
	output reg mult_sel_o;
	output reg div_sel_o;
	output reg [1:0] multdiv_operator_o;
	output reg [1:0] multdiv_signed_mode_o;
	output reg csr_access_o;
	output reg [1:0] csr_op_o;
	output reg data_req_o;
	output reg data_we_o;
	output reg [1:0] data_type_o;
	output reg data_sign_extension_o;
	output reg jump_in_dec_o;
	output reg branch_in_dec_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	reg illegal_insn;
	wire illegal_reg_rv32e;
	reg csr_illegal;
	reg rf_we;
	wire [31:0] instr;
	wire [31:0] instr_alu;
	wire [4:0] instr_rs1;
	wire [4:0] instr_rs2;
	wire [4:0] instr_rs3;
	wire [4:0] instr_rd;
	reg use_rs3_d;
	reg use_rs3_q;
	reg [1:0] csr_op;
	reg [6:0] opcode;
	reg [6:0] opcode_alu;
	assign instr = instr_rdata_i;
	assign instr_alu = instr_rdata_alu_i;
	assign imm_i_type_o = {{20 {instr[31]}}, instr[31:20]};
	assign imm_s_type_o = {{20 {instr[31]}}, instr[31:25], instr[11:7]};
	assign imm_b_type_o = {{19 {instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
	assign imm_u_type_o = {instr[31:12], 12'b000000000000};
	assign imm_j_type_o = {{12 {instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
	assign zimm_rs1_type_o = {27'b000000000000000000000000000, instr_rs1};
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			use_rs3_q <= 1'b0;
		else
			use_rs3_q <= use_rs3_d;
	assign instr_rs1 = instr[19:15];
	assign instr_rs2 = instr[24:20];
	assign instr_rs3 = instr[31:27];
	assign rf_raddr_a_o = (use_rs3_q & ~instr_first_cycle_i ? instr_rs3 : instr_rs1);
	assign rf_raddr_b_o = instr_rs2;
	assign instr_rd = instr[11:7];
	assign rf_waddr_o = instr_rd;
	generate
		if (RV32E) begin : gen_rv32e_reg_check_active
			assign illegal_reg_rv32e = ((rf_raddr_a_o[4] & (alu_op_a_mux_sel_o == OP_A_REG_A)) | (rf_raddr_b_o[4] & (alu_op_b_mux_sel_o == OP_B_REG_B))) | (rf_waddr_o[4] & rf_we);
		end
		else begin : gen_rv32e_reg_check_inactive
			assign illegal_reg_rv32e = 1'b0;
		end
	endgenerate
	always @(*) begin : csr_operand_check
		csr_op_o = csr_op;
		if (((csr_op == CSR_OP_SET) || (csr_op == CSR_OP_CLEAR)) && (instr_rs1 == {5 {1'sb0}}))
			csr_op_o = CSR_OP_READ;
	end
	function automatic [6:0] sv2v_cast_7;
		input reg [6:0] inp;
		sv2v_cast_7 = inp;
	endfunction
	always @(*) begin
		jump_in_dec_o = 1'b0;
		jump_set_o = 1'b0;
		branch_in_dec_o = 1'b0;
		icache_inval_o = 1'b0;
		multdiv_operator_o = MD_OP_MULL;
		multdiv_signed_mode_o = 2'b00;
		rf_wdata_sel_o = RF_WD_EX;
		rf_we = 1'b0;
		rf_ren_a_o = 1'b0;
		rf_ren_b_o = 1'b0;
		csr_access_o = 1'b0;
		csr_illegal = 1'b0;
		csr_op = CSR_OP_READ;
		data_we_o = 1'b0;
		data_type_o = 2'b00;
		data_sign_extension_o = 1'b0;
		data_req_o = 1'b0;
		illegal_insn = 1'b0;
		ebrk_insn_o = 1'b0;
		mret_insn_o = 1'b0;
		dret_insn_o = 1'b0;
		ecall_insn_o = 1'b0;
		wfi_insn_o = 1'b0;
		opcode = sv2v_cast_7(instr[6:0]);
		case (opcode)
			OPCODE_JAL: begin
				jump_in_dec_o = 1'b1;
				if (instr_first_cycle_i) begin
					rf_we = BranchTargetALU;
					jump_set_o = 1'b1;
				end
				else
					rf_we = 1'b1;
			end
			OPCODE_JALR: begin
				jump_in_dec_o = 1'b1;
				if (instr_first_cycle_i) begin
					rf_we = BranchTargetALU;
					jump_set_o = 1'b1;
				end
				else
					rf_we = 1'b1;
				if (instr[14:12] != 3'b000)
					illegal_insn = 1'b1;
				rf_ren_a_o = 1'b1;
			end
			OPCODE_BRANCH: begin
				branch_in_dec_o = 1'b1;
				case (instr[14:12])
					3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111: illegal_insn = 1'b0;
					default: illegal_insn = 1'b1;
				endcase
				rf_ren_a_o = 1'b1;
				rf_ren_b_o = 1'b1;
			end
			OPCODE_STORE: begin
				rf_ren_a_o = 1'b1;
				rf_ren_b_o = 1'b1;
				data_req_o = 1'b1;
				data_we_o = 1'b1;
				if (instr[14])
					illegal_insn = 1'b1;
				case (instr[13:12])
					2'b00: data_type_o = 2'b10;
					2'b01: data_type_o = 2'b01;
					2'b10: data_type_o = 2'b00;
					default: illegal_insn = 1'b1;
				endcase
			end
			OPCODE_LOAD: begin
				rf_ren_a_o = 1'b1;
				data_req_o = 1'b1;
				data_type_o = 2'b00;
				data_sign_extension_o = ~instr[14];
				case (instr[13:12])
					2'b00: data_type_o = 2'b10;
					2'b01: data_type_o = 2'b01;
					2'b10: begin
						data_type_o = 2'b00;
						if (instr[14])
							illegal_insn = 1'b1;
					end
					default: illegal_insn = 1'b1;
				endcase
			end
			OPCODE_LUI: rf_we = 1'b1;
			OPCODE_AUIPC: rf_we = 1'b1;
			OPCODE_OP_IMM: begin
				rf_ren_a_o = 1'b1;
				rf_we = 1'b1;
				case (instr[14:12])
					3'b000, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111: illegal_insn = 1'b0;
					3'b001:
						case (instr[31:27])
							5'b00000: illegal_insn = (instr[26:25] == 2'b00 ? 1'b0 : 1'b1);
							5'b00100, 5'b01001, 5'b00101, 5'b01101: illegal_insn = (RV32B != RV32BNone ? 1'b0 : 1'b1);
							5'b00001:
								if (instr[26] == 1'b0)
									illegal_insn = (RV32B == RV32BFull ? 1'b0 : 1'b1);
								else
									illegal_insn = 1'b1;
							5'b01100:
								case (instr[26:20])
									7'b0000000, 7'b0000001, 7'b0000010, 7'b0000100, 7'b0000101: illegal_insn = (RV32B != RV32BNone ? 1'b0 : 1'b1);
									7'b0010000, 7'b0010001, 7'b0010010, 7'b0011000, 7'b0011001, 7'b0011010: illegal_insn = (RV32B == RV32BFull ? 1'b0 : 1'b1);
									default: illegal_insn = 1'b1;
								endcase
							default: illegal_insn = 1'b1;
						endcase
					3'b101:
						if (instr[26])
							illegal_insn = (RV32B != RV32BNone ? 1'b0 : 1'b1);
						else
							case (instr[31:27])
								5'b00000, 5'b01000: illegal_insn = (instr[26:25] == 2'b00 ? 1'b0 : 1'b1);
								5'b00100, 5'b01100, 5'b01001: illegal_insn = (RV32B != RV32BNone ? 1'b0 : 1'b1);
								5'b01101:
									if (RV32B == RV32BFull)
										illegal_insn = 1'b0;
									else
										case (instr[24:20])
											5'b11111, 5'b11000: illegal_insn = (RV32B == RV32BBalanced ? 1'b0 : 1'b1);
											default: illegal_insn = 1'b1;
										endcase
								5'b00101:
									if (RV32B == RV32BFull)
										illegal_insn = 1'b0;
									else if (instr[24:20] == 5'b00111)
										illegal_insn = (RV32B == RV32BBalanced ? 1'b0 : 1'b1);
								5'b00001:
									if (instr[26] == 1'b0)
										illegal_insn = (RV32B == RV32BFull ? 1'b0 : 1'b1);
									else
										illegal_insn = 1'b1;
								default: illegal_insn = 1'b1;
							endcase
					default: illegal_insn = 1'b1;
				endcase
			end
			OPCODE_OP: begin
				rf_ren_a_o = 1'b1;
				rf_ren_b_o = 1'b1;
				rf_we = 1'b1;
				if ({instr[26], instr[13:12]} == {1'b1, 2'b01})
					illegal_insn = (RV32B != RV32BNone ? 1'b0 : 1'b1);
				else
					case ({instr[31:25], instr[14:12]})
						{7'b0000000, 3'b000}, {7'b0100000, 3'b000}, {7'b0000000, 3'b010}, {7'b0000000, 3'b011}, {7'b0000000, 3'b100}, {7'b0000000, 3'b110}, {7'b0000000, 3'b111}, {7'b0000000, 3'b001}, {7'b0000000, 3'b101}, {7'b0100000, 3'b101}: illegal_insn = 1'b0;
						{7'b0100000, 3'b111}, {7'b0100000, 3'b110}, {7'b0100000, 3'b100}, {7'b0010000, 3'b001}, {7'b0010000, 3'b101}, {7'b0110000, 3'b001}, {7'b0110000, 3'b101}, {7'b0000101, 3'b100}, {7'b0000101, 3'b101}, {7'b0000101, 3'b110}, {7'b0000101, 3'b111}, {7'b0000100, 3'b100}, {7'b0100100, 3'b100}, {7'b0000100, 3'b111}, {7'b0100100, 3'b001}, {7'b0010100, 3'b001}, {7'b0110100, 3'b001}, {7'b0100100, 3'b101}, {7'b0100100, 3'b111}: illegal_insn = (RV32B != RV32BNone ? 1'b0 : 1'b1);
						{7'b0100100, 3'b110}, {7'b0000100, 3'b110}, {7'b0110100, 3'b101}, {7'b0010100, 3'b101}, {7'b0000100, 3'b001}, {7'b0000100, 3'b101}, {7'b0000101, 3'b001}, {7'b0000101, 3'b010}, {7'b0000101, 3'b011}: illegal_insn = (RV32B == RV32BFull ? 1'b0 : 1'b1);
						{7'b0000001, 3'b000}: begin
							multdiv_operator_o = MD_OP_MULL;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b001}: begin
							multdiv_operator_o = MD_OP_MULH;
							multdiv_signed_mode_o = 2'b11;
							illegal_insn = (RV32M == RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b010}: begin
							multdiv_operator_o = MD_OP_MULH;
							multdiv_signed_mode_o = 2'b01;
							illegal_insn = (RV32M == RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b011}: begin
							multdiv_operator_o = MD_OP_MULH;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b100}: begin
							multdiv_operator_o = MD_OP_DIV;
							multdiv_signed_mode_o = 2'b11;
							illegal_insn = (RV32M == RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b101}: begin
							multdiv_operator_o = MD_OP_DIV;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b110}: begin
							multdiv_operator_o = MD_OP_REM;
							multdiv_signed_mode_o = 2'b11;
							illegal_insn = (RV32M == RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b111}: begin
							multdiv_operator_o = MD_OP_REM;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == RV32MNone ? 1'b1 : 1'b0);
						end
						default: illegal_insn = 1'b1;
					endcase
			end
			OPCODE_MISC_MEM:
				case (instr[14:12])
					3'b000: rf_we = 1'b0;
					3'b001: begin
						jump_in_dec_o = 1'b1;
						rf_we = 1'b0;
						if (instr_first_cycle_i) begin
							jump_set_o = 1'b1;
							icache_inval_o = 1'b1;
						end
					end
					default: illegal_insn = 1'b1;
				endcase
			OPCODE_SYSTEM:
				if (instr[14:12] == 3'b000) begin
					case (instr[31:20])
						12'h000: ecall_insn_o = 1'b1;
						12'h001: ebrk_insn_o = 1'b1;
						12'h302: mret_insn_o = 1'b1;
						12'h7b2: dret_insn_o = 1'b1;
						12'h105: wfi_insn_o = 1'b1;
						default: illegal_insn = 1'b1;
					endcase
					if ((instr_rs1 != 5'b00000) || (instr_rd != 5'b00000))
						illegal_insn = 1'b1;
				end
				else begin
					csr_access_o = 1'b1;
					rf_wdata_sel_o = RF_WD_CSR;
					rf_we = 1'b1;
					if (~instr[14])
						rf_ren_a_o = 1'b1;
					case (instr[13:12])
						2'b01: csr_op = CSR_OP_WRITE;
						2'b10: csr_op = CSR_OP_SET;
						2'b11: csr_op = CSR_OP_CLEAR;
						default: csr_illegal = 1'b1;
					endcase
					illegal_insn = csr_illegal;
				end
			default: illegal_insn = 1'b1;
		endcase
		if (illegal_c_insn_i)
			illegal_insn = 1'b1;
		if (illegal_insn) begin
			rf_we = 1'b0;
			data_req_o = 1'b0;
			data_we_o = 1'b0;
			jump_in_dec_o = 1'b0;
			jump_set_o = 1'b0;
			branch_in_dec_o = 1'b0;
			csr_access_o = 1'b0;
		end
	end
	always @(*) begin
		alu_operator_o = ALU_SLTU;
		alu_op_a_mux_sel_o = OP_A_IMM;
		alu_op_b_mux_sel_o = OP_B_IMM;
		imm_a_mux_sel_o = IMM_A_ZERO;
		imm_b_mux_sel_o = IMM_B_I;
		bt_a_mux_sel_o = OP_A_CURRPC;
		bt_b_mux_sel_o = IMM_B_I;
		opcode_alu = sv2v_cast_7(instr_alu[6:0]);
		use_rs3_d = 1'b0;
		alu_multicycle_o = 1'b0;
		mult_sel_o = 1'b0;
		div_sel_o = 1'b0;
		case (opcode_alu)
			OPCODE_JAL: begin
				if (BranchTargetALU) begin
					bt_a_mux_sel_o = OP_A_CURRPC;
					bt_b_mux_sel_o = IMM_B_J;
				end
				if (instr_first_cycle_i && !BranchTargetALU) begin
					alu_op_a_mux_sel_o = OP_A_CURRPC;
					alu_op_b_mux_sel_o = OP_B_IMM;
					imm_b_mux_sel_o = IMM_B_J;
					alu_operator_o = ALU_ADD;
				end
				else begin
					alu_op_a_mux_sel_o = OP_A_CURRPC;
					alu_op_b_mux_sel_o = OP_B_IMM;
					imm_b_mux_sel_o = IMM_B_INCR_PC;
					alu_operator_o = ALU_ADD;
				end
			end
			OPCODE_JALR: begin
				if (BranchTargetALU) begin
					bt_a_mux_sel_o = OP_A_REG_A;
					bt_b_mux_sel_o = IMM_B_I;
				end
				if (instr_first_cycle_i && !BranchTargetALU) begin
					alu_op_a_mux_sel_o = OP_A_REG_A;
					alu_op_b_mux_sel_o = OP_B_IMM;
					imm_b_mux_sel_o = IMM_B_I;
					alu_operator_o = ALU_ADD;
				end
				else begin
					alu_op_a_mux_sel_o = OP_A_CURRPC;
					alu_op_b_mux_sel_o = OP_B_IMM;
					imm_b_mux_sel_o = IMM_B_INCR_PC;
					alu_operator_o = ALU_ADD;
				end
			end
			OPCODE_BRANCH: begin
				case (instr_alu[14:12])
					3'b000: alu_operator_o = ALU_EQ;
					3'b001: alu_operator_o = ALU_NE;
					3'b100: alu_operator_o = ALU_LT;
					3'b101: alu_operator_o = ALU_GE;
					3'b110: alu_operator_o = ALU_LTU;
					3'b111: alu_operator_o = ALU_GEU;
					default:
						;
				endcase
				if (BranchTargetALU) begin
					bt_a_mux_sel_o = OP_A_CURRPC;
					bt_b_mux_sel_o = (branch_taken_i ? IMM_B_B : IMM_B_INCR_PC);
				end
				if (instr_first_cycle_i) begin
					alu_op_a_mux_sel_o = OP_A_REG_A;
					alu_op_b_mux_sel_o = OP_B_REG_B;
				end
				else begin
					alu_op_a_mux_sel_o = OP_A_CURRPC;
					alu_op_b_mux_sel_o = OP_B_IMM;
					imm_b_mux_sel_o = (branch_taken_i ? IMM_B_B : IMM_B_INCR_PC);
					alu_operator_o = ALU_ADD;
				end
			end
			OPCODE_STORE: begin
				alu_op_a_mux_sel_o = OP_A_REG_A;
				alu_op_b_mux_sel_o = OP_B_REG_B;
				alu_operator_o = ALU_ADD;
				if (!instr_alu[14]) begin
					imm_b_mux_sel_o = IMM_B_S;
					alu_op_b_mux_sel_o = OP_B_IMM;
				end
			end
			OPCODE_LOAD: begin
				alu_op_a_mux_sel_o = OP_A_REG_A;
				alu_operator_o = ALU_ADD;
				alu_op_b_mux_sel_o = OP_B_IMM;
				imm_b_mux_sel_o = IMM_B_I;
			end
			OPCODE_LUI: begin
				alu_op_a_mux_sel_o = OP_A_IMM;
				alu_op_b_mux_sel_o = OP_B_IMM;
				imm_a_mux_sel_o = IMM_A_ZERO;
				imm_b_mux_sel_o = IMM_B_U;
				alu_operator_o = ALU_ADD;
			end
			OPCODE_AUIPC: begin
				alu_op_a_mux_sel_o = OP_A_CURRPC;
				alu_op_b_mux_sel_o = OP_B_IMM;
				imm_b_mux_sel_o = IMM_B_U;
				alu_operator_o = ALU_ADD;
			end
			OPCODE_OP_IMM: begin
				alu_op_a_mux_sel_o = OP_A_REG_A;
				alu_op_b_mux_sel_o = OP_B_IMM;
				imm_b_mux_sel_o = IMM_B_I;
				case (instr_alu[14:12])
					3'b000: alu_operator_o = ALU_ADD;
					3'b010: alu_operator_o = ALU_SLT;
					3'b011: alu_operator_o = ALU_SLTU;
					3'b100: alu_operator_o = ALU_XOR;
					3'b110: alu_operator_o = ALU_OR;
					3'b111: alu_operator_o = ALU_AND;
					3'b001:
						if (RV32B != RV32BNone)
							case (instr_alu[31:27])
								5'b00000: alu_operator_o = ALU_SLL;
								5'b00100: alu_operator_o = ALU_SLO;
								5'b01001: alu_operator_o = ALU_SBCLR;
								5'b00101: alu_operator_o = ALU_SBSET;
								5'b01101: alu_operator_o = ALU_SBINV;
								5'b00001:
									if (instr_alu[26] == 0)
										alu_operator_o = ALU_SHFL;
								5'b01100:
									case (instr_alu[26:20])
										7'b0000000: alu_operator_o = ALU_CLZ;
										7'b0000001: alu_operator_o = ALU_CTZ;
										7'b0000010: alu_operator_o = ALU_PCNT;
										7'b0000100: alu_operator_o = ALU_SEXTB;
										7'b0000101: alu_operator_o = ALU_SEXTH;
										7'b0010000:
											if (RV32B == RV32BFull) begin
												alu_operator_o = ALU_CRC32_B;
												alu_multicycle_o = 1'b1;
											end
										7'b0010001:
											if (RV32B == RV32BFull) begin
												alu_operator_o = ALU_CRC32_H;
												alu_multicycle_o = 1'b1;
											end
										7'b0010010:
											if (RV32B == RV32BFull) begin
												alu_operator_o = ALU_CRC32_W;
												alu_multicycle_o = 1'b1;
											end
										7'b0011000:
											if (RV32B == RV32BFull) begin
												alu_operator_o = ALU_CRC32C_B;
												alu_multicycle_o = 1'b1;
											end
										7'b0011001:
											if (RV32B == RV32BFull) begin
												alu_operator_o = ALU_CRC32C_H;
												alu_multicycle_o = 1'b1;
											end
										7'b0011010:
											if (RV32B == RV32BFull) begin
												alu_operator_o = ALU_CRC32C_W;
												alu_multicycle_o = 1'b1;
											end
										default:
											;
									endcase
								default:
									;
							endcase
						else
							alu_operator_o = ALU_SLL;
					3'b101:
						if (RV32B != RV32BNone) begin
							if (instr_alu[26] == 1'b1) begin
								alu_operator_o = ALU_FSR;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							else
								case (instr_alu[31:27])
									5'b00000: alu_operator_o = ALU_SRL;
									5'b01000: alu_operator_o = ALU_SRA;
									5'b00100: alu_operator_o = ALU_SRO;
									5'b01001: alu_operator_o = ALU_SBEXT;
									5'b01100: begin
										alu_operator_o = ALU_ROR;
										alu_multicycle_o = 1'b1;
									end
									5'b01101: alu_operator_o = ALU_GREV;
									5'b00101: alu_operator_o = ALU_GORC;
									5'b00001:
										if (RV32B == RV32BFull)
											if (instr_alu[26] == 1'b0)
												alu_operator_o = ALU_UNSHFL;
									default:
										;
								endcase
						end
						else if (instr_alu[31:27] == 5'b00000)
							alu_operator_o = ALU_SRL;
						else if (instr_alu[31:27] == 5'b01000)
							alu_operator_o = ALU_SRA;
					default:
						;
				endcase
			end
			OPCODE_OP: begin
				alu_op_a_mux_sel_o = OP_A_REG_A;
				alu_op_b_mux_sel_o = OP_B_REG_B;
				if (instr_alu[26]) begin
					if (RV32B != RV32BNone)
						case ({instr_alu[26:25], instr_alu[14:12]})
							{2'b11, 3'b001}: begin
								alu_operator_o = ALU_CMIX;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							{2'b11, 3'b101}: begin
								alu_operator_o = ALU_CMOV;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							{2'b10, 3'b001}: begin
								alu_operator_o = ALU_FSL;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							{2'b10, 3'b101}: begin
								alu_operator_o = ALU_FSR;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							default:
								;
						endcase
				end
				else
					case ({instr_alu[31:25], instr_alu[14:12]})
						{7'b0000000, 3'b000}: alu_operator_o = ALU_ADD;
						{7'b0100000, 3'b000}: alu_operator_o = ALU_SUB;
						{7'b0000000, 3'b010}: alu_operator_o = ALU_SLT;
						{7'b0000000, 3'b011}: alu_operator_o = ALU_SLTU;
						{7'b0000000, 3'b100}: alu_operator_o = ALU_XOR;
						{7'b0000000, 3'b110}: alu_operator_o = ALU_OR;
						{7'b0000000, 3'b111}: alu_operator_o = ALU_AND;
						{7'b0000000, 3'b001}: alu_operator_o = ALU_SLL;
						{7'b0000000, 3'b101}: alu_operator_o = ALU_SRL;
						{7'b0100000, 3'b101}: alu_operator_o = ALU_SRA;
						{7'b0010000, 3'b001}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_SLO;
						{7'b0010000, 3'b101}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_SRO;
						{7'b0110000, 3'b001}:
							if (RV32B != RV32BNone) begin
								alu_operator_o = ALU_ROL;
								alu_multicycle_o = 1'b1;
							end
						{7'b0110000, 3'b101}:
							if (RV32B != RV32BNone) begin
								alu_operator_o = ALU_ROR;
								alu_multicycle_o = 1'b1;
							end
						{7'b0000101, 3'b100}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_MIN;
						{7'b0000101, 3'b101}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_MAX;
						{7'b0000101, 3'b110}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_MINU;
						{7'b0000101, 3'b111}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_MAXU;
						{7'b0000100, 3'b100}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_PACK;
						{7'b0100100, 3'b100}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_PACKU;
						{7'b0000100, 3'b111}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_PACKH;
						{7'b0100000, 3'b100}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_XNOR;
						{7'b0100000, 3'b110}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_ORN;
						{7'b0100000, 3'b111}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_ANDN;
						{7'b0100100, 3'b001}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_SBCLR;
						{7'b0010100, 3'b001}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_SBSET;
						{7'b0110100, 3'b001}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_SBINV;
						{7'b0100100, 3'b101}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_SBEXT;
						{7'b0100100, 3'b111}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_BFP;
						{7'b0110100, 3'b101}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_GREV;
						{7'b0010100, 3'b101}:
							if (RV32B != RV32BNone)
								alu_operator_o = ALU_GORC;
						{7'b0000100, 3'b001}:
							if (RV32B == RV32BFull)
								alu_operator_o = ALU_SHFL;
						{7'b0000100, 3'b101}:
							if (RV32B == RV32BFull)
								alu_operator_o = ALU_UNSHFL;
						{7'b0000101, 3'b001}:
							if (RV32B == RV32BFull)
								alu_operator_o = ALU_CLMUL;
						{7'b0000101, 3'b010}:
							if (RV32B == RV32BFull)
								alu_operator_o = ALU_CLMULR;
						{7'b0000101, 3'b011}:
							if (RV32B == RV32BFull)
								alu_operator_o = ALU_CLMULH;
						{7'b0100100, 3'b110}:
							if (RV32B == RV32BFull) begin
								alu_operator_o = ALU_BDEP;
								alu_multicycle_o = 1'b1;
							end
						{7'b0000100, 3'b110}:
							if (RV32B == RV32BFull) begin
								alu_operator_o = ALU_BEXT;
								alu_multicycle_o = 1'b1;
							end
						{7'b0000001, 3'b000}: begin
							alu_operator_o = ALU_ADD;
							mult_sel_o = (RV32M == RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b001}: begin
							alu_operator_o = ALU_ADD;
							mult_sel_o = (RV32M == RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b010}: begin
							alu_operator_o = ALU_ADD;
							mult_sel_o = (RV32M == RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b011}: begin
							alu_operator_o = ALU_ADD;
							mult_sel_o = (RV32M == RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b100}: begin
							alu_operator_o = ALU_ADD;
							div_sel_o = (RV32M == RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b101}: begin
							alu_operator_o = ALU_ADD;
							div_sel_o = (RV32M == RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b110}: begin
							alu_operator_o = ALU_ADD;
							div_sel_o = (RV32M == RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b111}: begin
							alu_operator_o = ALU_ADD;
							div_sel_o = (RV32M == RV32MNone ? 1'b0 : 1'b1);
						end
						default:
							;
					endcase
			end
			OPCODE_MISC_MEM:
				case (instr_alu[14:12])
					3'b000: begin
						alu_operator_o = ALU_ADD;
						alu_op_a_mux_sel_o = OP_A_REG_A;
						alu_op_b_mux_sel_o = OP_B_IMM;
					end
					3'b001:
						if (BranchTargetALU) begin
							bt_a_mux_sel_o = OP_A_CURRPC;
							bt_b_mux_sel_o = IMM_B_INCR_PC;
						end
						else begin
							alu_op_a_mux_sel_o = OP_A_CURRPC;
							alu_op_b_mux_sel_o = OP_B_IMM;
							imm_b_mux_sel_o = IMM_B_INCR_PC;
							alu_operator_o = ALU_ADD;
						end
					default:
						;
				endcase
			OPCODE_SYSTEM:
				if (instr_alu[14:12] == 3'b000) begin
					alu_op_a_mux_sel_o = OP_A_REG_A;
					alu_op_b_mux_sel_o = OP_B_IMM;
				end
				else begin
					alu_op_b_mux_sel_o = OP_B_IMM;
					imm_a_mux_sel_o = IMM_A_Z;
					imm_b_mux_sel_o = IMM_B_I;
					if (instr_alu[14])
						alu_op_a_mux_sel_o = OP_A_IMM;
					else
						alu_op_a_mux_sel_o = OP_A_REG_A;
				end
			default:
				;
		endcase
	end
	assign mult_en_o = (illegal_insn ? 1'b0 : mult_sel_o);
	assign div_en_o = (illegal_insn ? 1'b0 : div_sel_o);
	assign illegal_insn_o = illegal_insn | illegal_reg_rv32e;
	assign rf_we_o = rf_we & ~illegal_reg_rv32e;
endmodule
module brqrv_ifu (
	clk_i,
	rst_ni,
	boot_addr_i,
	req_i,
	instr_req_o,
	instr_addr_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_rdata_i,
	instr_err_i,
	instr_pmp_err_i,
	instr_valid_id_o,
	instr_new_id_o,
	instr_rdata_id_o,
	instr_rdata_alu_id_o,
	instr_rdata_c_id_o,
	instr_is_compressed_id_o,
	instr_bp_taken_o,
	instr_fetch_err_o,
	instr_fetch_err_plus2_o,
	illegal_c_insn_id_o,
	dummy_instr_id_o,
	pc_if_o,
	pc_id_o,
	instr_valid_clear_i,
	pc_set_i,
	pc_set_spec_i,
	pc_mux_i,
	nt_branch_mispredict_i,
	exc_pc_mux_i,
	exc_cause,
	dummy_instr_en_i,
	dummy_instr_mask_i,
	dummy_instr_seed_en_i,
	dummy_instr_seed_i,
	icache_enable_i,
	icache_inval_i,
	branch_target_ex_i,
	csr_mepc_i,
	csr_depc_i,
	csr_mtvec_i,
	csr_mtvec_init_o,
	id_in_ready_i,
	pc_mismatch_alert_o,
	if_busy_o
);
	parameter [31:0] DmHaltAddr = 32'h1a110800;
	parameter [31:0] DmExceptionAddr = 32'h1a110808;
	parameter [0:0] DummyInstructions = 1'b0;
	parameter [0:0] ICache = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	parameter [0:0] SecureBuraq = 1'b0;
	parameter [0:0] BranchPredictor = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire [31:0] boot_addr_i;
	input wire req_i;
	output wire instr_req_o;
	output wire [31:0] instr_addr_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	input wire [31:0] instr_rdata_i;
	input wire instr_err_i;
	input wire instr_pmp_err_i;
	output wire instr_valid_id_o;
	output wire instr_new_id_o;
	output reg [31:0] instr_rdata_id_o;
	output reg [31:0] instr_rdata_alu_id_o;
	output reg [15:0] instr_rdata_c_id_o;
	output reg instr_is_compressed_id_o;
	output wire instr_bp_taken_o;
	output reg instr_fetch_err_o;
	output reg instr_fetch_err_plus2_o;
	output reg illegal_c_insn_id_o;
	output wire dummy_instr_id_o;
	output wire [31:0] pc_if_o;
	output reg [31:0] pc_id_o;
	input wire instr_valid_clear_i;
	input wire pc_set_i;
	input wire pc_set_spec_i;
	input wire [2:0] pc_mux_i;
	input wire nt_branch_mispredict_i;
	input wire [1:0] exc_pc_mux_i;
	input wire [5:0] exc_cause;
	input wire dummy_instr_en_i;
	input wire [2:0] dummy_instr_mask_i;
	input wire dummy_instr_seed_en_i;
	input wire [31:0] dummy_instr_seed_i;
	input wire icache_enable_i;
	input wire icache_inval_i;
	input wire [31:0] branch_target_ex_i;
	input wire [31:0] csr_mepc_i;
	input wire [31:0] csr_depc_i;
	input wire [31:0] csr_mtvec_i;
	output wire csr_mtvec_init_o;
	input wire id_in_ready_i;
	output wire pc_mismatch_alert_o;
	output wire if_busy_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	wire instr_valid_id_d;
	reg instr_valid_id_q;
	wire instr_new_id_d;
	reg instr_new_id_q;
	wire prefetch_busy;
	wire branch_req;
	wire branch_spec;
	wire predicted_branch;
	reg [31:0] fetch_addr_n;
	wire fetch_valid;
	wire fetch_ready;
	wire [31:0] fetch_rdata;
	wire [31:0] fetch_addr;
	wire fetch_err;
	wire fetch_err_plus2;
	wire if_instr_valid;
	wire [31:0] if_instr_rdata;
	wire [31:0] if_instr_addr;
	wire if_instr_err;
	reg [31:0] exc_pc;
	wire [5:0] irq_id;
	wire unused_irq_bit;
	wire if_id_pipe_reg_we;
	wire stall_dummy_instr;
	wire [31:0] instr_out;
	wire instr_is_compressed_out;
	wire illegal_c_instr_out;
	wire instr_err_out;
	wire predict_branch_taken;
	wire [31:0] predict_branch_pc;
	wire [2:0] pc_mux_internal;
	wire [7:0] unused_boot_addr;
	wire [7:0] unused_csr_mtvec;
	assign unused_boot_addr = boot_addr_i[7:0];
	assign unused_csr_mtvec = csr_mtvec_i[7:0];
	assign irq_id = exc_cause;
	assign unused_irq_bit = irq_id[5];
	always @(*) begin : exc_pc_mux
		case (exc_pc_mux_i)
			EXC_PC_EXC: exc_pc = {csr_mtvec_i[31:8], 8'h00};
			EXC_PC_IRQ: exc_pc = {csr_mtvec_i[31:8], 1'b0, irq_id[4:0], 2'b00};
			EXC_PC_DBD: exc_pc = DmHaltAddr;
			EXC_PC_DBG_EXC: exc_pc = DmExceptionAddr;
			default: exc_pc = {csr_mtvec_i[31:8], 8'h00};
		endcase
	end
	assign pc_mux_internal = ((BranchPredictor && predict_branch_taken) && !pc_set_i ? PC_BP : pc_mux_i);
	always @(*) begin : fetch_addr_mux
		case (pc_mux_internal)
			PC_BOOT: fetch_addr_n = {boot_addr_i[31:8], 8'h80};
			PC_JUMP: fetch_addr_n = branch_target_ex_i;
			PC_EXC: fetch_addr_n = exc_pc;
			PC_ERET: fetch_addr_n = csr_mepc_i;
			PC_DRET: fetch_addr_n = csr_depc_i;
			PC_BP: fetch_addr_n = (BranchPredictor ? predict_branch_pc : {boot_addr_i[31:8], 8'h80});
			default: fetch_addr_n = {boot_addr_i[31:8], 8'h80};
		endcase
	end
	assign csr_mtvec_init_o = (pc_mux_i == PC_BOOT) & pc_set_i;
	brqrv_ifu_prefetch #(.BranchPredictor(BranchPredictor)) prefetch_buffer_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(req_i),
		.branch_i(branch_req),
		.branch_spec_i(branch_spec),
		.predicted_branch_i(predicted_branch),
		.branch_mispredict_i(nt_branch_mispredict_i),
		.addr_i({fetch_addr_n[31:1], 1'b0}),
		.ready_i(fetch_ready),
		.valid_o(fetch_valid),
		.rdata_o(fetch_rdata),
		.addr_o(fetch_addr),
		.err_o(fetch_err),
		.err_plus2_o(fetch_err_plus2),
		.instr_req_o(instr_req_o),
		.instr_addr_o(instr_addr_o),
		.instr_gnt_i(instr_gnt_i),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_rdata_i(instr_rdata_i),
		.instr_err_i(instr_err_i),
		.instr_pmp_err_i(instr_pmp_err_i),
		.busy_o(prefetch_busy)
	);
	wire unused_icen;
	wire unused_icinv;
	assign unused_icen = icache_enable_i;
	assign unused_icinv = icache_inval_i;
	assign branch_req = pc_set_i | predict_branch_taken;
	assign branch_spec = pc_set_spec_i | predict_branch_taken;
	assign pc_if_o = if_instr_addr;
	assign if_busy_o = prefetch_busy;
	wire [31:0] instr_decompressed;
	wire illegal_c_insn;
	wire instr_is_compressed;
	brqrv_ifu_compressed_decoder compressed_decoder_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(fetch_valid & ~fetch_err),
		.instr_i(if_instr_rdata),
		.instr_o(instr_decompressed),
		.is_compressed_o(instr_is_compressed),
		.illegal_instr_o(illegal_c_insn)
	);
	wire unused_dummy_en;
	wire [2:0] unused_dummy_mask;
	wire unused_dummy_seed_en;
	wire [31:0] unused_dummy_seed;
	assign unused_dummy_en = dummy_instr_en_i;
	assign unused_dummy_mask = dummy_instr_mask_i;
	assign unused_dummy_seed_en = dummy_instr_seed_en_i;
	assign unused_dummy_seed = dummy_instr_seed_i;
	assign instr_out = instr_decompressed;
	assign instr_is_compressed_out = instr_is_compressed;
	assign illegal_c_instr_out = illegal_c_insn;
	assign instr_err_out = if_instr_err;
	assign stall_dummy_instr = 1'b0;
	assign dummy_instr_id_o = 1'b0;
	assign instr_valid_id_d = ((if_instr_valid & id_in_ready_i) & ~pc_set_i) | (instr_valid_id_q & ~instr_valid_clear_i);
	assign instr_new_id_d = if_instr_valid & id_in_ready_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			instr_valid_id_q <= 1'b0;
			instr_new_id_q <= 1'b0;
		end
		else begin
			instr_valid_id_q <= instr_valid_id_d;
			instr_new_id_q <= instr_new_id_d;
		end
	assign instr_valid_id_o = instr_valid_id_q;
	assign instr_new_id_o = instr_new_id_q;
	assign if_id_pipe_reg_we = instr_new_id_d;
	always @(posedge clk_i)
		if (if_id_pipe_reg_we) begin
			instr_rdata_id_o <= instr_out;
			instr_rdata_alu_id_o <= instr_out;
			instr_fetch_err_o <= instr_err_out;
			instr_fetch_err_plus2_o <= fetch_err_plus2;
			instr_rdata_c_id_o <= if_instr_rdata[15:0];
			instr_is_compressed_id_o <= instr_is_compressed_out;
			illegal_c_insn_id_o <= illegal_c_instr_out;
			pc_id_o <= pc_if_o;
		end
	generate
		if (SecureBuraq) begin : g_secure_pc
			wire [31:0] prev_instr_addr_incr;
			reg prev_instr_seq_q;
			wire prev_instr_seq_d;
			assign prev_instr_seq_d = (prev_instr_seq_q | instr_new_id_d) & ~branch_req;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					prev_instr_seq_q <= 1'b0;
				else
					prev_instr_seq_q <= prev_instr_seq_d;
			assign prev_instr_addr_incr = pc_id_o + (instr_is_compressed_id_o ? 32'd2 : 32'd4);
			assign pc_mismatch_alert_o = prev_instr_seq_q & (pc_if_o != prev_instr_addr_incr);
		end
		else begin : g_no_secure_pc
			assign pc_mismatch_alert_o = 1'b0;
		end
	endgenerate
	assign instr_bp_taken_o = 1'b0;
	assign predict_branch_taken = 1'b0;
	assign predicted_branch = 1'b0;
	assign predict_branch_pc = 32'b00000000000000000000000000000000;
	assign if_instr_valid = fetch_valid;
	assign if_instr_rdata = fetch_rdata;
	assign if_instr_addr = fetch_addr;
	assign if_instr_err = fetch_err;
	assign fetch_ready = id_in_ready_i & ~stall_dummy_instr;
endmodule
module brqrv_ifu_compressed_decoder (
	clk_i,
	rst_ni,
	valid_i,
	instr_i,
	instr_o,
	is_compressed_o,
	illegal_instr_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire valid_i;
	input wire [31:0] instr_i;
	output reg [31:0] instr_o;
	output wire is_compressed_o;
	output reg illegal_instr_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	wire unused_valid;
	assign unused_valid = valid_i;
	always @(*) begin
		instr_o = instr_i;
		illegal_instr_o = 1'b0;
		case (instr_i[1:0])
			2'b00:
				case (instr_i[15:13])
					3'b000: begin
						instr_o = {2'b00, instr_i[10:7], instr_i[12:11], instr_i[5], instr_i[6], 2'b00, 5'h02, 3'b000, 2'b01, instr_i[4:2], OPCODE_OP_IMM};
						if (instr_i[12:5] == 8'b00000000)
							illegal_instr_o = 1'b1;
					end
					3'b010: instr_o = {5'b00000, instr_i[5], instr_i[12:10], instr_i[6], 2'b00, 2'b01, instr_i[9:7], 3'b010, 2'b01, instr_i[4:2], OPCODE_LOAD};
					3'b110: instr_o = {5'b00000, instr_i[5], instr_i[12], 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b010, instr_i[11:10], instr_i[6], 2'b00, OPCODE_STORE};
					3'b001, 3'b011, 3'b100, 3'b101, 3'b111: illegal_instr_o = 1'b1;
					default: illegal_instr_o = 1'b1;
				endcase
			2'b01:
				case (instr_i[15:13])
					3'b000: instr_o = {{6 {instr_i[12]}}, instr_i[12], instr_i[6:2], instr_i[11:7], 3'b000, instr_i[11:7], OPCODE_OP_IMM};
					3'b001, 3'b101: instr_o = {instr_i[12], instr_i[8], instr_i[10:9], instr_i[6], instr_i[7], instr_i[2], instr_i[11], instr_i[5:3], {9 {instr_i[12]}}, 4'b0000, ~instr_i[15], OPCODE_JAL};
					3'b010: instr_o = {{6 {instr_i[12]}}, instr_i[12], instr_i[6:2], 5'b00000, 3'b000, instr_i[11:7], OPCODE_OP_IMM};
					3'b011: begin
						instr_o = {{15 {instr_i[12]}}, instr_i[6:2], instr_i[11:7], OPCODE_LUI};
						if (instr_i[11:7] == 5'h02)
							instr_o = {{3 {instr_i[12]}}, instr_i[4:3], instr_i[5], instr_i[2], instr_i[6], 4'b0000, 5'h02, 3'b000, 5'h02, OPCODE_OP_IMM};
						if ({instr_i[12], instr_i[6:2]} == 6'b000000)
							illegal_instr_o = 1'b1;
					end
					3'b100:
						case (instr_i[11:10])
							2'b00, 2'b01: begin
								instr_o = {1'b0, instr_i[10], 5'b00000, instr_i[6:2], 2'b01, instr_i[9:7], 3'b101, 2'b01, instr_i[9:7], OPCODE_OP_IMM};
								if (instr_i[12] == 1'b1)
									illegal_instr_o = 1'b1;
							end
							2'b10: instr_o = {{6 {instr_i[12]}}, instr_i[12], instr_i[6:2], 2'b01, instr_i[9:7], 3'b111, 2'b01, instr_i[9:7], OPCODE_OP_IMM};
							2'b11:
								case ({instr_i[12], instr_i[6:5]})
									3'b000: instr_o = {2'b01, 5'b00000, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b000, 2'b01, instr_i[9:7], OPCODE_OP};
									3'b001: instr_o = {7'b0000000, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b100, 2'b01, instr_i[9:7], OPCODE_OP};
									3'b010: instr_o = {7'b0000000, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b110, 2'b01, instr_i[9:7], OPCODE_OP};
									3'b011: instr_o = {7'b0000000, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b111, 2'b01, instr_i[9:7], OPCODE_OP};
									3'b100, 3'b101, 3'b110, 3'b111: illegal_instr_o = 1'b1;
									default: illegal_instr_o = 1'b1;
								endcase
							default: illegal_instr_o = 1'b1;
						endcase
					3'b110, 3'b111: instr_o = {{4 {instr_i[12]}}, instr_i[6:5], instr_i[2], 5'b00000, 2'b01, instr_i[9:7], 2'b00, instr_i[13], instr_i[11:10], instr_i[4:3], instr_i[12], OPCODE_BRANCH};
					default: illegal_instr_o = 1'b1;
				endcase
			2'b10:
				case (instr_i[15:13])
					3'b000: begin
						instr_o = {7'b0000000, instr_i[6:2], instr_i[11:7], 3'b001, instr_i[11:7], OPCODE_OP_IMM};
						if (instr_i[12] == 1'b1)
							illegal_instr_o = 1'b1;
					end
					3'b010: begin
						instr_o = {4'b0000, instr_i[3:2], instr_i[12], instr_i[6:4], 2'b00, 5'h02, 3'b010, instr_i[11:7], OPCODE_LOAD};
						if (instr_i[11:7] == 5'b00000)
							illegal_instr_o = 1'b1;
					end
					3'b100:
						if (instr_i[12] == 1'b0) begin
							if (instr_i[6:2] != 5'b00000)
								instr_o = {7'b0000000, instr_i[6:2], 5'b00000, 3'b000, instr_i[11:7], OPCODE_OP};
							else begin
								instr_o = {12'b000000000000, instr_i[11:7], 3'b000, 5'b00000, OPCODE_JALR};
								if (instr_i[11:7] == 5'b00000)
									illegal_instr_o = 1'b1;
							end
						end
						else if (instr_i[6:2] != 5'b00000)
							instr_o = {7'b0000000, instr_i[6:2], instr_i[11:7], 3'b000, instr_i[11:7], OPCODE_OP};
						else if (instr_i[11:7] == 5'b00000)
							instr_o = 32'h00100073;
						else
							instr_o = {12'b000000000000, instr_i[11:7], 3'b000, 5'b00001, OPCODE_JALR};
					3'b110: instr_o = {4'b0000, instr_i[8:7], instr_i[12], instr_i[6:2], 5'h02, 3'b010, instr_i[11:9], 2'b00, OPCODE_STORE};
					3'b001, 3'b011, 3'b101, 3'b111: illegal_instr_o = 1'b1;
					default: illegal_instr_o = 1'b1;
				endcase
			2'b11:
				;
			default: illegal_instr_o = 1'b1;
		endcase
	end
	assign is_compressed_o = instr_i[1:0] != 2'b11;
endmodule
/*module brqrv_ifu_dummy_instr (
	clk_i,
	rst_ni,
	dummy_instr_en_i,
	dummy_instr_mask_i,
	dummy_instr_seed_en_i,
	dummy_instr_seed_i,
	fetch_valid_i,
	id_in_ready_i,
	insert_dummy_instr_o,
	dummy_instr_data_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire dummy_instr_en_i;
	input wire [2:0] dummy_instr_mask_i;
	input wire dummy_instr_seed_en_i;
	input wire [31:0] dummy_instr_seed_i;
	input wire fetch_valid_i;
	input wire id_in_ready_i;
	output wire insert_dummy_instr_o;
	output wire [31:0] dummy_instr_data_o;
	localparam [31:0] TIMEOUT_CNT_W = 5;
	localparam [31:0] OP_W = 5;
	localparam [31:0] LFSR_OUT_W = ((2 + OP_W) + OP_W) + TIMEOUT_CNT_W;
	wire [(((2 + OP_W) + OP_W) + TIMEOUT_CNT_W) - 1:0] lfsr_data;
	wire [TIMEOUT_CNT_W - 1:0] dummy_cnt_incr;
	wire [TIMEOUT_CNT_W - 1:0] dummy_cnt_threshold;
	wire [TIMEOUT_CNT_W - 1:0] dummy_cnt_d;
	reg [TIMEOUT_CNT_W - 1:0] dummy_cnt_q;
	wire dummy_cnt_en;
	wire lfsr_en;
	wire [LFSR_OUT_W - 1:0] lfsr_state;
	wire insert_dummy_instr;
	reg [6:0] dummy_set;
	reg [2:0] dummy_opcode;
	wire [31:0] dummy_instr;
	reg [31:0] dummy_instr_seed_q;
	wire [31:0] dummy_instr_seed_d;
	assign lfsr_en = insert_dummy_instr & id_in_ready_i;
	assign dummy_instr_seed_d = dummy_instr_seed_q ^ dummy_instr_seed_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			dummy_instr_seed_q <= {32 {1'sb0}};
		else if (dummy_instr_seed_en_i)
			dummy_instr_seed_q <= dummy_instr_seed_d;
	prim_lfsr #(
		.LfsrDw(32),
		.StateOutDw(LFSR_OUT_W)
	) lfsr_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.seed_en_i(dummy_instr_seed_en_i),
		.seed_i(dummy_instr_seed_d),
		.lfsr_en_i(lfsr_en),
		.entropy_i('0),
		.state_o(lfsr_state)
	);
	function automatic [(((2 + OP_W) + OP_W) + TIMEOUT_CNT_W) - 1:0] sv2v_cast_4AF33;
		input reg [(((2 + OP_W) + OP_W) + TIMEOUT_CNT_W) - 1:0] inp;
		sv2v_cast_4AF33 = inp;
	endfunction
	assign lfsr_data = sv2v_cast_4AF33(lfsr_state);
	assign dummy_cnt_threshold = lfsr_data[TIMEOUT_CNT_W - 1-:TIMEOUT_CNT_W] & {dummy_instr_mask_i, {TIMEOUT_CNT_W - 3 {1'b1}}};
	assign dummy_cnt_incr = dummy_cnt_q + {{TIMEOUT_CNT_W - 1 {1'b0}}, 1'b1};
	assign dummy_cnt_d = (insert_dummy_instr ? {TIMEOUT_CNT_W {1'sb0}} : dummy_cnt_incr);
	assign dummy_cnt_en = (dummy_instr_en_i & id_in_ready_i) & (fetch_valid_i | insert_dummy_instr);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			dummy_cnt_q <= {TIMEOUT_CNT_W {1'sb0}};
		else if (dummy_cnt_en)
			dummy_cnt_q <= dummy_cnt_d;
	assign insert_dummy_instr = dummy_instr_en_i & (dummy_cnt_q == dummy_cnt_threshold);
	localparam [1:0] DUMMY_ADD = 2'b00;
	localparam [1:0] DUMMY_AND = 2'b11;
	localparam [1:0] DUMMY_DIV = 2'b10;
	localparam [1:0] DUMMY_MUL = 2'b01;
	always @(*)
		case (lfsr_data[2 + (OP_W + (OP_W + (TIMEOUT_CNT_W - 1)))-:((2 + (OP_W + (OP_W + (TIMEOUT_CNT_W - 1)))) - (OP_W + (OP_W + TIMEOUT_CNT_W))) + 1])
			DUMMY_ADD: begin
				dummy_set = 7'b0000000;
				dummy_opcode = 3'b000;
			end
			DUMMY_MUL: begin
				dummy_set = 7'b0000001;
				dummy_opcode = 3'b000;
			end
			DUMMY_DIV: begin
				dummy_set = 7'b0000001;
				dummy_opcode = 3'b100;
			end
			DUMMY_AND: begin
				dummy_set = 7'b0000000;
				dummy_opcode = 3'b111;
			end
			default: begin
				dummy_set = 7'b0000000;
				dummy_opcode = 3'b000;
			end
		endcase
	assign dummy_instr = {dummy_set, lfsr_data[OP_W + (OP_W + (TIMEOUT_CNT_W - 1))-:((OP_W + (OP_W + (TIMEOUT_CNT_W - 1))) - (OP_W + TIMEOUT_CNT_W)) + 1], lfsr_data[OP_W + (TIMEOUT_CNT_W - 1)-:((OP_W + (TIMEOUT_CNT_W - 1)) - TIMEOUT_CNT_W) + 1], dummy_opcode, 5'h00, 7'h33};
	assign insert_dummy_instr_o = insert_dummy_instr;
	assign dummy_instr_data_o = dummy_instr;
endmodule
*/
module brqrv_ifu_prefetch (
	clk_i,
	rst_ni,
	req_i,
	branch_i,
	branch_spec_i,
	predicted_branch_i,
	branch_mispredict_i,
	addr_i,
	ready_i,
	valid_o,
	rdata_o,
	addr_o,
	err_o,
	err_plus2_o,
	instr_req_o,
	instr_gnt_i,
	instr_addr_o,
	instr_rdata_i,
	instr_err_i,
	instr_pmp_err_i,
	instr_rvalid_i,
	busy_o
);
	parameter [0:0] BranchPredictor = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire req_i;
	input wire branch_i;
	input wire branch_spec_i;
	input wire predicted_branch_i;
	input wire branch_mispredict_i;
	input wire [31:0] addr_i;
	input wire ready_i;
	output wire valid_o;
	output wire [31:0] rdata_o;
	output wire [31:0] addr_o;
	output wire err_o;
	output wire err_plus2_o;
	output wire instr_req_o;
	input wire instr_gnt_i;
	output wire [31:0] instr_addr_o;
	input wire [31:0] instr_rdata_i;
	input wire instr_err_i;
	input wire instr_pmp_err_i;
	input wire instr_rvalid_i;
	output wire busy_o;
	localparam [31:0] NUM_REQS = 2;
	wire branch_suppress;
	wire valid_new_req;
	wire valid_req;
	wire valid_req_d;
	reg valid_req_q;
	wire discard_req_d;
	reg discard_req_q;
	wire gnt_or_pmp_err;
	wire rvalid_or_pmp_err;
	wire [NUM_REQS - 1:0] rdata_outstanding_n;
	wire [NUM_REQS - 1:0] rdata_outstanding_s;
	reg [NUM_REQS - 1:0] rdata_outstanding_q;
	wire [NUM_REQS - 1:0] branch_discard_n;
	wire [NUM_REQS - 1:0] branch_discard_s;
	reg [NUM_REQS - 1:0] branch_discard_q;
	wire [NUM_REQS - 1:0] rdata_pmp_err_n;
	wire [NUM_REQS - 1:0] rdata_pmp_err_s;
	reg [NUM_REQS - 1:0] rdata_pmp_err_q;
	wire [NUM_REQS - 1:0] rdata_outstanding_rev;
	wire [31:0] stored_addr_d;
	reg [31:0] stored_addr_q;
	wire stored_addr_en;
	wire [31:0] fetch_addr_d;
	reg [31:0] fetch_addr_q;
	wire fetch_addr_en;
	wire [31:0] branch_mispredict_addr;
	wire [31:0] instr_addr;
	wire [31:0] instr_addr_w_aligned;
	wire instr_or_pmp_err;
	wire fifo_valid;
	wire [31:0] fifo_addr;
	wire fifo_ready;
	wire fifo_clear;
	wire [NUM_REQS - 1:0] fifo_busy;
	wire valid_raw;
	wire [31:0] addr_next;
	wire branch_or_mispredict;
	assign busy_o = |rdata_outstanding_q | instr_req_o;
	assign branch_or_mispredict = branch_i | branch_mispredict_i;
	assign instr_or_pmp_err = instr_err_i | rdata_pmp_err_q[0];
	assign fifo_clear = branch_or_mispredict;
	generate
		genvar i;
		for (i = 0; i < NUM_REQS; i = i + 1) begin : gen_rd_rev
			assign rdata_outstanding_rev[i] = rdata_outstanding_q[(NUM_REQS - 1) - i];
		end
	endgenerate
	assign fifo_ready = ~&(fifo_busy | rdata_outstanding_rev);
	brqrv_ifu_prefetch_fifo #(.NUM_REQS(NUM_REQS)) fifo_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clear_i(fifo_clear),
		.busy_o(fifo_busy),
		.in_valid_i(fifo_valid),
		.in_addr_i(fifo_addr),
		.in_rdata_i(instr_rdata_i),
		.in_err_i(instr_or_pmp_err),
		.out_valid_o(valid_raw),
		.out_ready_i(ready_i),
		.out_rdata_o(rdata_o),
		.out_addr_o(addr_o),
		.out_addr_next_o(addr_next),
		.out_err_o(err_o),
		.out_err_plus2_o(err_plus2_o)
	);
	assign branch_suppress = branch_spec_i & ~branch_i;
	assign valid_new_req = ((~branch_suppress & req_i) & (fifo_ready | branch_or_mispredict)) & ~rdata_outstanding_q[NUM_REQS - 1];
	assign valid_req = valid_req_q | valid_new_req;
	assign gnt_or_pmp_err = instr_gnt_i | instr_pmp_err_i;
	assign rvalid_or_pmp_err = rdata_outstanding_q[0] & (instr_rvalid_i | rdata_pmp_err_q[0]);
	assign valid_req_d = valid_req & ~gnt_or_pmp_err;
	assign discard_req_d = valid_req_q & (branch_or_mispredict | discard_req_q);
	assign stored_addr_en = (valid_new_req & ~valid_req_q) & ~gnt_or_pmp_err;
	assign stored_addr_d = instr_addr;
	always @(posedge clk_i)
		if (stored_addr_en)
			stored_addr_q <= stored_addr_d;
	generate
		if (BranchPredictor) begin : g_branch_predictor
			reg [31:0] branch_mispredict_addr_q;
			wire branch_mispredict_addr_en;
			assign branch_mispredict_addr_en = branch_i & predicted_branch_i;
			always @(posedge clk_i)
				if (branch_mispredict_addr_en)
					branch_mispredict_addr_q <= addr_next;
			assign branch_mispredict_addr = branch_mispredict_addr_q;
		end
		else begin : g_no_branch_predictor
			wire unused_predicted_branch;
			wire [31:0] unused_addr_next;
			assign unused_predicted_branch = predicted_branch_i;
			assign unused_addr_next = addr_next;
			assign branch_mispredict_addr = {32 {1'sb0}};
		end
	endgenerate
	assign fetch_addr_en = branch_or_mispredict | (valid_new_req & ~valid_req_q);
	assign fetch_addr_d = (branch_i ? addr_i : (branch_mispredict_i ? {branch_mispredict_addr[31:2], 2'b00} : {fetch_addr_q[31:2], 2'b00})) + {{29 {1'b0}}, valid_new_req & ~valid_req_q, 2'b00};
	always @(posedge clk_i)
		if (fetch_addr_en)
			fetch_addr_q <= fetch_addr_d;
	assign instr_addr = (valid_req_q ? stored_addr_q : (branch_spec_i ? addr_i : (branch_mispredict_i ? branch_mispredict_addr : fetch_addr_q)));
	assign instr_addr_w_aligned = {instr_addr[31:2], 2'b00};
	generate
		for (i = 0; i < NUM_REQS; i = i + 1) begin : g_outstanding_reqs
			if (i == 0) begin : g_req0
				assign rdata_outstanding_n[i] = (valid_req & gnt_or_pmp_err) | rdata_outstanding_q[i];
				assign branch_discard_n[i] = (((valid_req & gnt_or_pmp_err) & discard_req_d) | (branch_or_mispredict & rdata_outstanding_q[i])) | branch_discard_q[i];
				assign rdata_pmp_err_n[i] = ((valid_req & ~rdata_outstanding_q[i]) & instr_pmp_err_i) | rdata_pmp_err_q[i];
			end
			else begin : g_reqtop
				assign rdata_outstanding_n[i] = ((valid_req & gnt_or_pmp_err) & rdata_outstanding_q[i - 1]) | rdata_outstanding_q[i];
				assign branch_discard_n[i] = ((((valid_req & gnt_or_pmp_err) & discard_req_d) & rdata_outstanding_q[i - 1]) | (branch_or_mispredict & rdata_outstanding_q[i])) | branch_discard_q[i];
				assign rdata_pmp_err_n[i] = (((valid_req & ~rdata_outstanding_q[i]) & instr_pmp_err_i) & rdata_outstanding_q[i - 1]) | rdata_pmp_err_q[i];
			end
		end
	endgenerate
	assign rdata_outstanding_s = (rvalid_or_pmp_err ? {1'b0, rdata_outstanding_n[NUM_REQS - 1:1]} : rdata_outstanding_n);
	assign branch_discard_s = (rvalid_or_pmp_err ? {1'b0, branch_discard_n[NUM_REQS - 1:1]} : branch_discard_n);
	assign rdata_pmp_err_s = (rvalid_or_pmp_err ? {1'b0, rdata_pmp_err_n[NUM_REQS - 1:1]} : rdata_pmp_err_n);
	assign fifo_valid = rvalid_or_pmp_err & ~branch_discard_q[0];
	assign fifo_addr = (branch_mispredict_i ? branch_mispredict_addr : addr_i);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			valid_req_q <= 1'b0;
			discard_req_q <= 1'b0;
			rdata_outstanding_q <= 'b0;
			branch_discard_q <= 'b0;
			rdata_pmp_err_q <= 'b0;
		end
		else begin
			valid_req_q <= valid_req_d;
			discard_req_q <= discard_req_d;
			rdata_outstanding_q <= rdata_outstanding_s;
			branch_discard_q <= branch_discard_s;
			rdata_pmp_err_q <= rdata_pmp_err_s;
		end
	assign instr_req_o = valid_req;
	assign instr_addr_o = instr_addr_w_aligned;
	assign valid_o = valid_raw & ~branch_mispredict_i;
endmodule
module brqrv_ifu_prefetch_fifo (
	clk_i,
	rst_ni,
	clear_i,
	busy_o,
	in_valid_i,
	in_addr_i,
	in_rdata_i,
	in_err_i,
	out_valid_o,
	out_ready_i,
	out_addr_o,
	out_addr_next_o,
	out_rdata_o,
	out_err_o,
	out_err_plus2_o
);
	parameter [31:0] NUM_REQS = 2;
	input wire clk_i;
	input wire rst_ni;
	input wire clear_i;
	output wire [NUM_REQS - 1:0] busy_o;
	input wire in_valid_i;
	input wire [31:0] in_addr_i;
	input wire [31:0] in_rdata_i;
	input wire in_err_i;
	output reg out_valid_o;
	input wire out_ready_i;
	output wire [31:0] out_addr_o;
	output wire [31:0] out_addr_next_o;
	output reg [31:0] out_rdata_o;
	output reg out_err_o;
	output reg out_err_plus2_o;
	localparam [31:0] DEPTH = NUM_REQS + 1;
	wire [(DEPTH * 32) - 1:0] rdata_d;
	reg [(DEPTH * 32) - 1:0] rdata_q;
	wire [DEPTH - 1:0] err_d;
	reg [DEPTH - 1:0] err_q;
	wire [DEPTH - 1:0] valid_d;
	reg [DEPTH - 1:0] valid_q;
	wire [DEPTH - 1:0] lowest_free_entry;
	wire [DEPTH - 1:0] valid_pushed;
	wire [DEPTH - 1:0] valid_popped;
	wire [DEPTH - 1:0] entry_en;
	wire pop_fifo;
	wire [31:0] rdata;
	wire [31:0] rdata_unaligned;
	wire err;
	wire err_unaligned;
	wire err_plus2;
	wire valid;
	wire valid_unaligned;
	wire aligned_is_compressed;
	wire unaligned_is_compressed;
	wire addr_incr_two;
	wire [31:1] instr_addr_next;
	wire [31:1] instr_addr_d;
	reg [31:1] instr_addr_q;
	wire instr_addr_en;
	wire unused_addr_in;
	assign rdata = (valid_q[0] ? rdata_q[0+:32] : in_rdata_i);
	assign err = (valid_q[0] ? err_q[0] : in_err_i);
	assign valid = valid_q[0] | in_valid_i;
	assign rdata_unaligned = (valid_q[1] ? {rdata_q[47-:16], rdata[31:16]} : {in_rdata_i[15:0], rdata[31:16]});
	assign err_unaligned = (valid_q[1] ? (err_q[1] & ~unaligned_is_compressed) | err_q[0] : (valid_q[0] & err_q[0]) | (in_err_i & (~valid_q[0] | ~unaligned_is_compressed)));
	assign err_plus2 = (valid_q[1] ? err_q[1] & ~err_q[0] : (in_err_i & valid_q[0]) & ~err_q[0]);
	assign valid_unaligned = (valid_q[1] ? 1'b1 : valid_q[0] & in_valid_i);
	assign unaligned_is_compressed = (rdata[17:16] != 2'b11) | err;
	assign aligned_is_compressed = (rdata[1:0] != 2'b11) & ~err;
	always @(*)
		if (out_addr_o[1]) begin
			out_rdata_o = rdata_unaligned;
			out_err_o = err_unaligned;
			out_err_plus2_o = err_plus2;
			if (unaligned_is_compressed)
				out_valid_o = valid;
			else
				out_valid_o = valid_unaligned;
		end
		else begin
			out_rdata_o = rdata;
			out_err_o = err;
			out_err_plus2_o = 1'b0;
			out_valid_o = valid;
		end
	assign instr_addr_en = clear_i | (out_ready_i & out_valid_o);
	assign addr_incr_two = (instr_addr_q[1] ? unaligned_is_compressed : aligned_is_compressed);
	assign instr_addr_next = instr_addr_q[31:1] + {29'd0, ~addr_incr_two, addr_incr_two};
	assign instr_addr_d = (clear_i ? in_addr_i[31:1] : instr_addr_next);
	always @(posedge clk_i)
		if (instr_addr_en)
			instr_addr_q <= instr_addr_d;
	assign out_addr_next_o = {instr_addr_next, 1'b0};
	assign out_addr_o = {instr_addr_q, 1'b0};
	assign unused_addr_in = in_addr_i[0];
	assign busy_o = valid_q[DEPTH - 1:DEPTH - NUM_REQS];
	assign pop_fifo = (out_ready_i & out_valid_o) & (~aligned_is_compressed | out_addr_o[1]);
	generate
		genvar i;
		for (i = 0; i < (DEPTH - 1); i = i + 1) begin : g_fifo_next
			if (i == 0) begin : g_ent0
				assign lowest_free_entry[i] = ~valid_q[i];
			end
			else begin : g_ent_others
				assign lowest_free_entry[i] = ~valid_q[i] & valid_q[i - 1];
			end
			assign valid_pushed[i] = (in_valid_i & lowest_free_entry[i]) | valid_q[i];
			assign valid_popped[i] = (pop_fifo ? valid_pushed[i + 1] : valid_pushed[i]);
			assign valid_d[i] = valid_popped[i] & ~clear_i;
			assign entry_en[i] = (valid_pushed[i + 1] & pop_fifo) | ((in_valid_i & lowest_free_entry[i]) & ~pop_fifo);
			assign rdata_d[i * 32+:32] = (valid_q[i + 1] ? rdata_q[(i + 1) * 32+:32] : in_rdata_i);
			assign err_d[i] = (valid_q[i + 1] ? err_q[i + 1] : in_err_i);
		end
	endgenerate
	assign lowest_free_entry[DEPTH - 1] = ~valid_q[DEPTH - 1] & valid_q[DEPTH - 2];
	assign valid_pushed[DEPTH - 1] = valid_q[DEPTH - 1] | (in_valid_i & lowest_free_entry[DEPTH - 1]);
	assign valid_popped[DEPTH - 1] = (pop_fifo ? 1'b0 : valid_pushed[DEPTH - 1]);
	assign valid_d[DEPTH - 1] = valid_popped[DEPTH - 1] & ~clear_i;
	assign entry_en[DEPTH - 1] = in_valid_i & lowest_free_entry[DEPTH - 1];
	assign rdata_d[(DEPTH - 1) * 32+:32] = in_rdata_i;
	assign err_d[DEPTH - 1] = in_err_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			valid_q <= {DEPTH {1'sb0}};
		else
			valid_q <= valid_d;
	generate
		for (i = 0; i < DEPTH; i = i + 1) begin : g_fifo_regs
			always @(posedge clk_i)
				if (entry_en[i]) begin
					rdata_q[i * 32+:32] <= rdata_d[i * 32+:32];
					err_q[i] <= err_d[i];
				end
		end
	endgenerate
endmodule
module brqrv_lsu (
	clk_i,
	rst_ni,
	data_req_o,
	data_gnt_i,
	data_rvalid_i,
	data_err_i,
	data_pmp_err_i,
	data_addr_o,
	data_we_o,
	data_be_o,
	data_wdata_o,
	data_rdata_i,
	lsu_we_i,
	lsu_type_i,
	lsu_wdata_i,
	lsu_sign_ext_i,
	lsu_rdata_o,
	lsu_rdata_valid_o,
	lsu_req_i,
	adder_result_ex_i,
	addr_incr_req_o,
	addr_last_o,
	lsu_req_done_o,
	lsu_resp_valid_o,
	load_err_o,
	store_err_o,
	busy_o,
	perf_load_o,
	perf_store_o
);
	input wire clk_i;
	input wire rst_ni;
	output reg data_req_o;
	input wire data_gnt_i;
	input wire data_rvalid_i;
	input wire data_err_i;
	input wire data_pmp_err_i;
	output wire [31:0] data_addr_o;
	output wire data_we_o;
	output wire [3:0] data_be_o;
	output wire [31:0] data_wdata_o;
	input wire [31:0] data_rdata_i;
	input wire lsu_we_i;
	input wire [1:0] lsu_type_i;
	input wire [31:0] lsu_wdata_i;
	input wire lsu_sign_ext_i;
	output wire [31:0] lsu_rdata_o;
	output wire lsu_rdata_valid_o;
	input wire lsu_req_i;
	input wire [31:0] adder_result_ex_i;
	output reg addr_incr_req_o;
	output wire [31:0] addr_last_o;
	output wire lsu_req_done_o;
	output wire lsu_resp_valid_o;
	output wire load_err_o;
	output wire store_err_o;
	output wire busy_o;
	output reg perf_load_o;
	output reg perf_store_o;
	wire [31:0] data_addr;
	wire [31:0] data_addr_w_aligned;
	reg [31:0] addr_last_q;
	reg addr_update;
	reg ctrl_update;
	reg rdata_update;
	reg [31:8] rdata_q;
	reg [1:0] rdata_offset_q;
	reg [1:0] data_type_q;
	reg data_sign_ext_q;
	reg data_we_q;
	wire [1:0] data_offset;
	reg [3:0] data_be;
	reg [31:0] data_wdata;
	reg [31:0] data_rdata_ext;
	reg [31:0] rdata_w_ext;
	reg [31:0] rdata_h_ext;
	reg [31:0] rdata_b_ext;
	wire split_misaligned_access;
	reg handle_misaligned_q;
	reg handle_misaligned_d;
	reg pmp_err_q;
	reg pmp_err_d;
	reg lsu_err_q;
	reg lsu_err_d;
	wire data_or_pmp_err;
	reg [2:0] ls_fsm_cs;
	reg [2:0] ls_fsm_ns;
	assign data_addr = adder_result_ex_i;
	assign data_offset = data_addr[1:0];
	always @(*)
		case (lsu_type_i)
			2'b00:
				if (!handle_misaligned_q)
					case (data_offset)
						2'b00: data_be = 4'b1111;
						2'b01: data_be = 4'b1110;
						2'b10: data_be = 4'b1100;
						2'b11: data_be = 4'b1000;
						default: data_be = 4'b1111;
					endcase
				else
					case (data_offset)
						2'b00: data_be = 4'b0000;
						2'b01: data_be = 4'b0001;
						2'b10: data_be = 4'b0011;
						2'b11: data_be = 4'b0111;
						default: data_be = 4'b1111;
					endcase
			2'b01:
				if (!handle_misaligned_q)
					case (data_offset)
						2'b00: data_be = 4'b0011;
						2'b01: data_be = 4'b0110;
						2'b10: data_be = 4'b1100;
						2'b11: data_be = 4'b1000;
						default: data_be = 4'b1111;
					endcase
				else
					data_be = 4'b0001;
			2'b10, 2'b11:
				case (data_offset)
					2'b00: data_be = 4'b0001;
					2'b01: data_be = 4'b0010;
					2'b10: data_be = 4'b0100;
					2'b11: data_be = 4'b1000;
					default: data_be = 4'b1111;
				endcase
			default: data_be = 4'b1111;
		endcase
	always @(*)
		case (data_offset)
			2'b00: data_wdata = lsu_wdata_i[31:0];
			2'b01: data_wdata = {lsu_wdata_i[23:0], lsu_wdata_i[31:24]};
			2'b10: data_wdata = {lsu_wdata_i[15:0], lsu_wdata_i[31:16]};
			2'b11: data_wdata = {lsu_wdata_i[7:0], lsu_wdata_i[31:8]};
			default: data_wdata = lsu_wdata_i[31:0];
		endcase
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			rdata_q <= {24 {1'sb0}};
		else if (rdata_update)
			rdata_q <= data_rdata_i[31:8];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rdata_offset_q <= 2'h0;
			data_type_q <= 2'h0;
			data_sign_ext_q <= 1'b0;
			data_we_q <= 1'b0;
		end
		else if (ctrl_update) begin
			rdata_offset_q <= data_offset;
			data_type_q <= lsu_type_i;
			data_sign_ext_q <= lsu_sign_ext_i;
			data_we_q <= lsu_we_i;
		end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			addr_last_q <= {32 {1'sb0}};
		else if (addr_update)
			addr_last_q <= data_addr;
	always @(*)
		case (rdata_offset_q)
			2'b00: rdata_w_ext = data_rdata_i[31:0];
			2'b01: rdata_w_ext = {data_rdata_i[7:0], rdata_q[31:8]};
			2'b10: rdata_w_ext = {data_rdata_i[15:0], rdata_q[31:16]};
			2'b11: rdata_w_ext = {data_rdata_i[23:0], rdata_q[31:24]};
			default: rdata_w_ext = data_rdata_i[31:0];
		endcase
	always @(*)
		case (rdata_offset_q)
			2'b00:
				if (!data_sign_ext_q)
					rdata_h_ext = {16'h0000, data_rdata_i[15:0]};
				else
					rdata_h_ext = {{16 {data_rdata_i[15]}}, data_rdata_i[15:0]};
			2'b01:
				if (!data_sign_ext_q)
					rdata_h_ext = {16'h0000, data_rdata_i[23:8]};
				else
					rdata_h_ext = {{16 {data_rdata_i[23]}}, data_rdata_i[23:8]};
			2'b10:
				if (!data_sign_ext_q)
					rdata_h_ext = {16'h0000, data_rdata_i[31:16]};
				else
					rdata_h_ext = {{16 {data_rdata_i[31]}}, data_rdata_i[31:16]};
			2'b11:
				if (!data_sign_ext_q)
					rdata_h_ext = {16'h0000, data_rdata_i[7:0], rdata_q[31:24]};
				else
					rdata_h_ext = {{16 {data_rdata_i[7]}}, data_rdata_i[7:0], rdata_q[31:24]};
			default: rdata_h_ext = {16'h0000, data_rdata_i[15:0]};
		endcase
	always @(*)
		case (rdata_offset_q)
			2'b00:
				if (!data_sign_ext_q)
					rdata_b_ext = {24'h000000, data_rdata_i[7:0]};
				else
					rdata_b_ext = {{24 {data_rdata_i[7]}}, data_rdata_i[7:0]};
			2'b01:
				if (!data_sign_ext_q)
					rdata_b_ext = {24'h000000, data_rdata_i[15:8]};
				else
					rdata_b_ext = {{24 {data_rdata_i[15]}}, data_rdata_i[15:8]};
			2'b10:
				if (!data_sign_ext_q)
					rdata_b_ext = {24'h000000, data_rdata_i[23:16]};
				else
					rdata_b_ext = {{24 {data_rdata_i[23]}}, data_rdata_i[23:16]};
			2'b11:
				if (!data_sign_ext_q)
					rdata_b_ext = {24'h000000, data_rdata_i[31:24]};
				else
					rdata_b_ext = {{24 {data_rdata_i[31]}}, data_rdata_i[31:24]};
			default: rdata_b_ext = {24'h000000, data_rdata_i[7:0]};
		endcase
	always @(*)
		case (data_type_q)
			2'b00: data_rdata_ext = rdata_w_ext;
			2'b01: data_rdata_ext = rdata_h_ext;
			2'b10, 2'b11: data_rdata_ext = rdata_b_ext;
			default: data_rdata_ext = rdata_w_ext;
		endcase
	assign split_misaligned_access = ((lsu_type_i == 2'b00) && (data_offset != 2'b00)) || ((lsu_type_i == 2'b01) && (data_offset == 2'b11));
	localparam [2:0] IDLE = 0;
	localparam [2:0] WAIT_GNT = 3;
	localparam [2:0] WAIT_GNT_MIS = 1;
	localparam [2:0] WAIT_RVALID_MIS = 2;
	localparam [2:0] WAIT_RVALID_MIS_GNTS_DONE = 4;
	always @(*) begin
		ls_fsm_ns = ls_fsm_cs;
		data_req_o = 1'b0;
		addr_incr_req_o = 1'b0;
		handle_misaligned_d = handle_misaligned_q;
		pmp_err_d = pmp_err_q;
		lsu_err_d = lsu_err_q;
		addr_update = 1'b0;
		ctrl_update = 1'b0;
		rdata_update = 1'b0;
		perf_load_o = 1'b0;
		perf_store_o = 1'b0;
		case (ls_fsm_cs)
			IDLE: begin
				pmp_err_d = 1'b0;
				if (lsu_req_i) begin
					data_req_o = 1'b1;
					pmp_err_d = data_pmp_err_i;
					lsu_err_d = 1'b0;
					perf_load_o = ~lsu_we_i;
					perf_store_o = lsu_we_i;
					if (data_gnt_i) begin
						ctrl_update = 1'b1;
						addr_update = 1'b1;
						handle_misaligned_d = split_misaligned_access;
						ls_fsm_ns = (split_misaligned_access ? WAIT_RVALID_MIS : IDLE);
					end
					else
						ls_fsm_ns = (split_misaligned_access ? WAIT_GNT_MIS : WAIT_GNT);
				end
			end
			WAIT_GNT_MIS: begin
				data_req_o = 1'b1;
				if (data_gnt_i || pmp_err_q) begin
					addr_update = 1'b1;
					ctrl_update = 1'b1;
					handle_misaligned_d = 1'b1;
					ls_fsm_ns = WAIT_RVALID_MIS;
				end
			end
			WAIT_RVALID_MIS: begin
				data_req_o = 1'b1;
				addr_incr_req_o = 1'b1;
				if (data_rvalid_i || pmp_err_q) begin
					pmp_err_d = data_pmp_err_i;
					lsu_err_d = data_err_i | pmp_err_q;
					rdata_update = ~data_we_q;
					ls_fsm_ns = (data_gnt_i ? IDLE : WAIT_GNT);
					addr_update = data_gnt_i & ~(data_err_i | pmp_err_q);
					handle_misaligned_d = ~data_gnt_i;
				end
				else if (data_gnt_i) begin
					ls_fsm_ns = WAIT_RVALID_MIS_GNTS_DONE;
					handle_misaligned_d = 1'b0;
				end
			end
			WAIT_GNT: begin
				addr_incr_req_o = handle_misaligned_q;
				data_req_o = 1'b1;
				if (data_gnt_i || pmp_err_q) begin
					ctrl_update = 1'b1;
					addr_update = ~lsu_err_q;
					ls_fsm_ns = IDLE;
					handle_misaligned_d = 1'b0;
				end
			end
			WAIT_RVALID_MIS_GNTS_DONE: begin
				addr_incr_req_o = 1'b1;
				if (data_rvalid_i) begin
					pmp_err_d = data_pmp_err_i;
					lsu_err_d = data_err_i;
					addr_update = ~data_err_i;
					rdata_update = ~data_we_q;
					ls_fsm_ns = IDLE;
				end
			end
			default: ls_fsm_ns = IDLE;
		endcase
	end
	assign lsu_req_done_o = (lsu_req_i | (ls_fsm_cs != IDLE)) & (ls_fsm_ns == IDLE);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			ls_fsm_cs <= IDLE;
			handle_misaligned_q <= 1'sb0;
			pmp_err_q <= 1'sb0;
			lsu_err_q <= 1'sb0;
		end
		else begin
			ls_fsm_cs <= ls_fsm_ns;
			handle_misaligned_q <= handle_misaligned_d;
			pmp_err_q <= pmp_err_d;
			lsu_err_q <= lsu_err_d;
		end
	assign data_or_pmp_err = (lsu_err_q | data_err_i) | pmp_err_q;
	assign lsu_resp_valid_o = (data_rvalid_i | pmp_err_q) & (ls_fsm_cs == IDLE);
	assign lsu_rdata_valid_o = (((ls_fsm_cs == IDLE) & data_rvalid_i) & ~data_or_pmp_err) & ~data_we_q;
	assign lsu_rdata_o = data_rdata_ext;
	assign data_addr_w_aligned = {data_addr[31:2], 2'b00};
	assign data_addr_o = data_addr_w_aligned;
	assign data_wdata_o = data_wdata;
	assign data_we_o = lsu_we_i;
	assign data_be_o = data_be;
	assign addr_last_o = addr_last_q;
	assign load_err_o = (data_or_pmp_err & ~data_we_q) & lsu_resp_valid_o;
	assign store_err_o = (data_or_pmp_err & data_we_q) & lsu_resp_valid_o;
	assign busy_o = ls_fsm_cs != IDLE;
endmodule
module brqrv_pmp (
	clk_i,
	rst_ni,
	csr_pmp_cfg_i,
	csr_pmp_addr_i,
	priv_mode_i,
	pmp_req_addr_i,
	pmp_req_type_i,
	pmp_req_err_o
);
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumChan = 2;
	parameter [31:0] PMPNumRegions = 4;
	input wire clk_i;
	input wire rst_ni;
	input wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 6) + (((PMPNumRegions - 1) * 6) - 1) : (PMPNumRegions * 6) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 6 : 0)] csr_pmp_cfg_i;
	input wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 34) + (((PMPNumRegions - 1) * 34) - 1) : (PMPNumRegions * 34) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 34 : 0)] csr_pmp_addr_i;
	input wire [(0 >= (PMPNumChan - 1) ? ((2 - PMPNumChan) * 2) + (((PMPNumChan - 1) * 2) - 1) : (PMPNumChan * 2) - 1):(0 >= (PMPNumChan - 1) ? (PMPNumChan - 1) * 2 : 0)] priv_mode_i;
	input wire [(0 >= (PMPNumChan - 1) ? ((2 - PMPNumChan) * 34) + (((PMPNumChan - 1) * 34) - 1) : (PMPNumChan * 34) - 1):(0 >= (PMPNumChan - 1) ? (PMPNumChan - 1) * 34 : 0)] pmp_req_addr_i;
	input wire [(0 >= (PMPNumChan - 1) ? ((2 - PMPNumChan) * 2) + (((PMPNumChan - 1) * 2) - 1) : (PMPNumChan * 2) - 1):(0 >= (PMPNumChan - 1) ? (PMPNumChan - 1) * 2 : 0)] pmp_req_type_i;
	output wire [PMPNumChan - 1:0] pmp_req_err_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	wire [33:0] region_start_addr [0:PMPNumRegions - 1];
	wire [33:PMPGranularity + 2] region_addr_mask [0:PMPNumRegions - 1];
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_match_gt;
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_match_lt;
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_match_eq;
	reg [(PMPNumChan * PMPNumRegions) - 1:0] region_match_all;
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_perm_check;
	reg [PMPNumChan - 1:0] access_fault;
	generate
		genvar r;
		for (r = 0; r < PMPNumRegions; r = r + 1) begin : g_addr_exp
			if (r == 0) begin : g_entry0
				assign region_start_addr[r] = (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] == PMP_MODE_TOR ? 34'h000000000 : csr_pmp_addr_i[(0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34+:34]);
			end
			else begin : g_oth
				assign region_start_addr[r] = (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] == PMP_MODE_TOR ? csr_pmp_addr_i[(0 >= (PMPNumRegions - 1) ? r - 1 : (PMPNumRegions - 1) - (r - 1)) * 34+:34] : csr_pmp_addr_i[(0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34+:34]);
			end
			genvar b;
			for (b = PMPGranularity + 2; b < 34; b = b + 1) begin : g_bitmask
				if (b == (PMPGranularity + 2)) begin : g_bit0
					assign region_addr_mask[r][b] = csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] != PMP_MODE_NAPOT;
				end
				else begin : g_others
					assign region_addr_mask[r][b] = (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] != PMP_MODE_NAPOT) | ~&csr_pmp_addr_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34) + ((b - 1) >= (PMPGranularity + 2) ? b - 1 : ((b - 1) + ((b - 1) >= (PMPGranularity + 2) ? ((b - 1) - (PMPGranularity + 2)) + 1 : ((PMPGranularity + 2) - (b - 1)) + 1)) - 1)-:((b - 1) >= (PMPGranularity + 2) ? ((b - 1) - (PMPGranularity + 2)) + 1 : ((PMPGranularity + 2) - (b - 1)) + 1)];
				end
			end
		end
	endgenerate
	generate
		genvar c;
		for (c = 0; c < PMPNumChan; c = c + 1) begin : g_access_check
			for (r = 0; r < PMPNumRegions; r = r + 1) begin : g_regions
				assign region_match_eq[(c * PMPNumRegions) + r] = (pmp_req_addr_i[((0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)] & region_addr_mask[r]) == (region_start_addr[r][33:PMPGranularity + 2] & region_addr_mask[r]);
				assign region_match_gt[(c * PMPNumRegions) + r] = pmp_req_addr_i[((0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)] > region_start_addr[r][33:PMPGranularity + 2];
				assign region_match_lt[(c * PMPNumRegions) + r] = pmp_req_addr_i[((0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)] < csr_pmp_addr_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)];
				always @(*) begin
					region_match_all[(c * PMPNumRegions) + r] = 1'b0;
					case (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2])
						PMP_MODE_OFF: region_match_all[(c * PMPNumRegions) + r] = 1'b0;
						PMP_MODE_NA4: region_match_all[(c * PMPNumRegions) + r] = region_match_eq[(c * PMPNumRegions) + r];
						PMP_MODE_NAPOT: region_match_all[(c * PMPNumRegions) + r] = region_match_eq[(c * PMPNumRegions) + r];
						PMP_MODE_TOR: region_match_all[(c * PMPNumRegions) + r] = (region_match_eq[(c * PMPNumRegions) + r] | region_match_gt[(c * PMPNumRegions) + r]) & region_match_lt[(c * PMPNumRegions) + r];
						default: region_match_all[(c * PMPNumRegions) + r] = 1'b0;
					endcase
				end
				assign region_perm_check[(c * PMPNumRegions) + r] = (((pmp_req_type_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == PMP_ACC_EXEC) & csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 2]) | ((pmp_req_type_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == PMP_ACC_WRITE) & csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 1])) | ((pmp_req_type_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == PMP_ACC_READ) & csr_pmp_cfg_i[(0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6]);
			end
			always @(*) begin
				access_fault[c] = priv_mode_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] != PRIV_LVL_M;
				begin : sv2v_autoblock_69
					reg signed [31:0] r;
					for (r = PMPNumRegions - 1; r >= 0; r = r - 1)
						if (region_match_all[(c * PMPNumRegions) + r])
							access_fault[c] = (priv_mode_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == PRIV_LVL_M ? csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 5] & ~region_perm_check[(c * PMPNumRegions) + r] : ~region_perm_check[(c * PMPNumRegions) + r]);
				end
			end
			assign pmp_req_err_o[c] = access_fault[c];
		end
	endgenerate
endmodule
module brqrv_register_file_ff (
	clk_i,
	rst_ni,
	test_en_i,
	dummy_instr_id_i,
	raddr_a_i,
	rdata_a_o,
	raddr_b_i,
	rdata_b_o,
	waddr_a_i,
	wdata_a_i,
	we_a_i
);
	parameter [0:0] RV32E = 0;
	parameter [31:0] DataWidth = 32;
	parameter [0:0] DummyInstructions = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire dummy_instr_id_i;
	input wire [4:0] raddr_a_i;
	output wire [DataWidth - 1:0] rdata_a_o;
	input wire [4:0] raddr_b_i;
	output wire [DataWidth - 1:0] rdata_b_o;
	input wire [4:0] waddr_a_i;
	input wire [DataWidth - 1:0] wdata_a_i;
	input wire we_a_i;
	localparam [31:0] ADDR_WIDTH = (RV32E ? 4 : 5);
	localparam [31:0] NUM_WORDS = 2 ** ADDR_WIDTH;
	wire [(NUM_WORDS * DataWidth) - 1:0] rf_reg;
	reg [((NUM_WORDS - 1) >= 1 ? ((NUM_WORDS - 1) * DataWidth) + (DataWidth - 1) : ((3 - NUM_WORDS) * DataWidth) + (((NUM_WORDS - 1) * DataWidth) - 1)):((NUM_WORDS - 1) >= 1 ? DataWidth : (NUM_WORDS - 1) * DataWidth)] rf_reg_q;
	reg [NUM_WORDS - 1:1] we_a_dec;
	function automatic [4:0] sv2v_cast_5_unsigned;
		input reg [4:0] inp;
		sv2v_cast_5_unsigned = inp;
	endfunction
	always @(*) begin : we_a_decoder
		begin : sv2v_autoblock_70
			reg [31:0] i;
			for (i = 1; i < NUM_WORDS; i = i + 1)
				we_a_dec[i] = (waddr_a_i == sv2v_cast_5_unsigned(i) ? we_a_i : 1'b0);
		end
	end
	generate
		genvar i;
		for (i = 1; i < NUM_WORDS; i = i + 1) begin : g_rf_flops
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					rf_reg_q[((NUM_WORDS - 1) >= 1 ? i : 1 - (i - (NUM_WORDS - 1))) * DataWidth+:DataWidth] <= {DataWidth {1'sb0}};
				else if (we_a_dec[i])
					rf_reg_q[((NUM_WORDS - 1) >= 1 ? i : 1 - (i - (NUM_WORDS - 1))) * DataWidth+:DataWidth] <= wdata_a_i;
		end
	endgenerate
	generate
		if (DummyInstructions) begin : g_dummy_r0
			wire we_r0_dummy;
			reg [DataWidth - 1:0] rf_r0_q;
			assign we_r0_dummy = we_a_i & dummy_instr_id_i;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					rf_r0_q <= {DataWidth {1'sb0}};
				else if (we_r0_dummy)
					rf_r0_q <= wdata_a_i;
			assign rf_reg[0+:DataWidth] = (dummy_instr_id_i ? rf_r0_q : {DataWidth {1'sb0}});
		end
		else begin : g_normal_r0
			wire unused_dummy_instr_id;
			assign unused_dummy_instr_id = dummy_instr_id_i;
			assign rf_reg[0+:DataWidth] = {DataWidth {1'sb0}};
		end
	endgenerate
	assign rf_reg[DataWidth * (((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : ((NUM_WORDS - 1) + ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)) - 1) - (((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS) - 1))+:DataWidth * ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)] = rf_reg_q[DataWidth * ((NUM_WORDS - 1) >= 1 ? ((NUM_WORDS - 1) >= 1 ? ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : ((NUM_WORDS - 1) + ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)) - 1) - (((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS) - 1) : ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : ((NUM_WORDS - 1) + ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)) - 1)) : 1 - (((NUM_WORDS - 1) >= 1 ? ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : ((NUM_WORDS - 1) + ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)) - 1) - (((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS) - 1) : ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : ((NUM_WORDS - 1) + ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)) - 1)) - (NUM_WORDS - 1)))+:DataWidth * ((NUM_WORDS - 1) >= 1 ? NUM_WORDS - 1 : 3 - NUM_WORDS)];
	assign rdata_a_o = rf_reg[raddr_a_i * DataWidth+:DataWidth];
	assign rdata_b_o = rf_reg[raddr_b_i * DataWidth+:DataWidth];
endmodule
module brqrv_register_file_fpga (
	clk_i,
	rst_ni,
	test_en_i,
	dummy_instr_id_i,
	raddr_a_i,
	rdata_a_o,
	raddr_b_i,
	rdata_b_o,
	waddr_a_i,
	wdata_a_i,
	we_a_i
);
	parameter [0:0] RV32E = 0;
	parameter [31:0] DataWidth = 32;
	parameter [0:0] DummyInstructions = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire dummy_instr_id_i;
	input wire [4:0] raddr_a_i;
	output wire [DataWidth - 1:0] rdata_a_o;
	input wire [4:0] raddr_b_i;
	output wire [DataWidth - 1:0] rdata_b_o;
	input wire [4:0] waddr_a_i;
	input wire [DataWidth - 1:0] wdata_a_i;
	input wire we_a_i;
	localparam signed [31:0] ADDR_WIDTH = (RV32E ? 4 : 5);
	localparam signed [31:0] NUM_WORDS = 2 ** ADDR_WIDTH;
	reg [DataWidth - 1:0] mem [0:NUM_WORDS - 1];
	wire we;
	assign rdata_a_o = (raddr_a_i == {5 {1'sb0}} ? {DataWidth {1'sb0}} : mem[raddr_a_i]);
	assign rdata_b_o = (raddr_b_i == {5 {1'sb0}} ? {DataWidth {1'sb0}} : mem[raddr_b_i]);
	assign we = (waddr_a_i == {5 {1'sb0}} ? 1'b0 : we_a_i);
	always @(posedge clk_i) begin : sync_write
		if (we == 1'b1)
			mem[waddr_a_i] <= wdata_a_i;
	end
	wire unused_rst_ni;
	assign unused_rst_ni = rst_ni;
	wire unused_dummy_instr;
	assign unused_dummy_instr = dummy_instr_id_i;
endmodule
module brqrv_wbu (
	clk_i,
	rst_ni,
	en_wb_i,
	instr_type_wb_i,
	pc_id_i,
	ready_wb_o,
	rf_write_wb_o,
	outstanding_load_wb_o,
	outstanding_store_wb_o,
	pc_wb_o,
	rf_waddr_id_i,
	rf_wdata_id_i,
	rf_we_id_i,
	rf_wdata_lsu_i,
	rf_we_lsu_i,
	rf_wdata_fwd_wb_o,
	rf_waddr_wb_o,
	rf_wdata_wb_o,
	rf_we_wb_o,
	lsu_resp_valid_i,
	instr_done_wb_o
);
	parameter [0:0] WritebackStage = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire en_wb_i;
	input wire [1:0] instr_type_wb_i;
	input wire [31:0] pc_id_i;
	output wire ready_wb_o;
	output wire rf_write_wb_o;
	output wire outstanding_load_wb_o;
	output wire outstanding_store_wb_o;
	output wire [31:0] pc_wb_o;
	input wire [4:0] rf_waddr_id_i;
	input wire [31:0] rf_wdata_id_i;
	input wire rf_we_id_i;
	input wire [31:0] rf_wdata_lsu_i;
	input wire rf_we_lsu_i;
	output wire [31:0] rf_wdata_fwd_wb_o;
	output wire [4:0] rf_waddr_wb_o;
	output wire [31:0] rf_wdata_wb_o;
	output wire rf_we_wb_o;
	input wire lsu_resp_valid_i;
	output wire instr_done_wb_o;
	localparam integer RegFileFF = 0;
	localparam integer RegFileFPGA = 1;
	localparam integer RegFileLatch = 2;
	localparam integer RV32MNone = 0;
	localparam integer RV32MSlow = 1;
	localparam integer RV32MFast = 2;
	localparam integer RV32MSingleCycle = 3;
	localparam integer RV32BNone = 0;
	localparam integer RV32BBalanced = 1;
	localparam integer RV32BFull = 2;
	localparam [6:0] OPCODE_LOAD = 7'h03;
	localparam [6:0] OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] OPCODE_OP_IMM = 7'h13;
	localparam [6:0] OPCODE_AUIPC = 7'h17;
	localparam [6:0] OPCODE_STORE = 7'h23;
	localparam [6:0] OPCODE_OP = 7'h33;
	localparam [6:0] OPCODE_LUI = 7'h37;
	localparam [6:0] OPCODE_BRANCH = 7'h63;
	localparam [6:0] OPCODE_JALR = 7'h67;
	localparam [6:0] OPCODE_JAL = 7'h6f;
	localparam [6:0] OPCODE_SYSTEM = 7'h73;
	localparam [5:0] ALU_ADD = 0;
	localparam [5:0] ALU_SUB = 1;
	localparam [5:0] ALU_XOR = 2;
	localparam [5:0] ALU_OR = 3;
	localparam [5:0] ALU_AND = 4;
	localparam [5:0] ALU_XNOR = 5;
	localparam [5:0] ALU_ORN = 6;
	localparam [5:0] ALU_ANDN = 7;
	localparam [5:0] ALU_SRA = 8;
	localparam [5:0] ALU_SRL = 9;
	localparam [5:0] ALU_SLL = 10;
	localparam [5:0] ALU_SRO = 11;
	localparam [5:0] ALU_SLO = 12;
	localparam [5:0] ALU_ROR = 13;
	localparam [5:0] ALU_ROL = 14;
	localparam [5:0] ALU_GREV = 15;
	localparam [5:0] ALU_GORC = 16;
	localparam [5:0] ALU_SHFL = 17;
	localparam [5:0] ALU_UNSHFL = 18;
	localparam [5:0] ALU_LT = 19;
	localparam [5:0] ALU_LTU = 20;
	localparam [5:0] ALU_GE = 21;
	localparam [5:0] ALU_GEU = 22;
	localparam [5:0] ALU_EQ = 23;
	localparam [5:0] ALU_NE = 24;
	localparam [5:0] ALU_MIN = 25;
	localparam [5:0] ALU_MINU = 26;
	localparam [5:0] ALU_MAX = 27;
	localparam [5:0] ALU_MAXU = 28;
	localparam [5:0] ALU_PACK = 29;
	localparam [5:0] ALU_PACKU = 30;
	localparam [5:0] ALU_PACKH = 31;
	localparam [5:0] ALU_SEXTB = 32;
	localparam [5:0] ALU_SEXTH = 33;
	localparam [5:0] ALU_CLZ = 34;
	localparam [5:0] ALU_CTZ = 35;
	localparam [5:0] ALU_PCNT = 36;
	localparam [5:0] ALU_SLT = 37;
	localparam [5:0] ALU_SLTU = 38;
	localparam [5:0] ALU_CMOV = 39;
	localparam [5:0] ALU_CMIX = 40;
	localparam [5:0] ALU_FSL = 41;
	localparam [5:0] ALU_FSR = 42;
	localparam [5:0] ALU_SBSET = 43;
	localparam [5:0] ALU_SBCLR = 44;
	localparam [5:0] ALU_SBINV = 45;
	localparam [5:0] ALU_SBEXT = 46;
	localparam [5:0] ALU_BEXT = 47;
	localparam [5:0] ALU_BDEP = 48;
	localparam [5:0] ALU_BFP = 49;
	localparam [5:0] ALU_CLMUL = 50;
	localparam [5:0] ALU_CLMULR = 51;
	localparam [5:0] ALU_CLMULH = 52;
	localparam [5:0] ALU_CRC32_B = 53;
	localparam [5:0] ALU_CRC32C_B = 54;
	localparam [5:0] ALU_CRC32_H = 55;
	localparam [5:0] ALU_CRC32C_H = 56;
	localparam [5:0] ALU_CRC32_W = 57;
	localparam [5:0] ALU_CRC32C_W = 58;
	localparam [1:0] MD_OP_MULL = 0;
	localparam [1:0] MD_OP_MULH = 1;
	localparam [1:0] MD_OP_DIV = 2;
	localparam [1:0] MD_OP_REM = 3;
	localparam [1:0] CSR_OP_READ = 0;
	localparam [1:0] CSR_OP_WRITE = 1;
	localparam [1:0] CSR_OP_SET = 2;
	localparam [1:0] CSR_OP_CLEAR = 3;
	localparam [1:0] PRIV_LVL_M = 2'b11;
	localparam [1:0] PRIV_LVL_H = 2'b10;
	localparam [1:0] PRIV_LVL_S = 2'b01;
	localparam [1:0] PRIV_LVL_U = 2'b00;
	localparam [3:0] XDEBUGVER_NO = 4'd0;
	localparam [3:0] XDEBUGVER_STD = 4'd4;
	localparam [3:0] XDEBUGVER_NONSTD = 4'd15;
	localparam [1:0] WB_INSTR_LOAD = 0;
	localparam [1:0] WB_INSTR_STORE = 1;
	localparam [1:0] WB_INSTR_OTHER = 2;
	localparam [1:0] OP_A_REG_A = 0;
	localparam [1:0] OP_A_FWD = 1;
	localparam [1:0] OP_A_CURRPC = 2;
	localparam [1:0] OP_A_IMM = 3;
	localparam [0:0] IMM_A_Z = 0;
	localparam [0:0] IMM_A_ZERO = 1;
	localparam [0:0] OP_B_REG_B = 0;
	localparam [0:0] OP_B_IMM = 1;
	localparam [2:0] IMM_B_I = 0;
	localparam [2:0] IMM_B_S = 1;
	localparam [2:0] IMM_B_B = 2;
	localparam [2:0] IMM_B_U = 3;
	localparam [2:0] IMM_B_J = 4;
	localparam [2:0] IMM_B_INCR_PC = 5;
	localparam [2:0] IMM_B_INCR_ADDR = 6;
	localparam [0:0] RF_WD_EX = 0;
	localparam [0:0] RF_WD_CSR = 1;
	localparam [2:0] PC_BOOT = 0;
	localparam [2:0] PC_JUMP = 1;
	localparam [2:0] PC_EXC = 2;
	localparam [2:0] PC_ERET = 3;
	localparam [2:0] PC_DRET = 4;
	localparam [2:0] PC_BP = 5;
	localparam [1:0] EXC_PC_EXC = 0;
	localparam [1:0] EXC_PC_IRQ = 1;
	localparam [1:0] EXC_PC_DBD = 2;
	localparam [1:0] EXC_PC_DBG_EXC = 3;
	localparam [5:0] EXC_CAUSE_IRQ_SOFTWARE_M = {1'b1, 5'd3};
	localparam [5:0] EXC_CAUSE_IRQ_TIMER_M = {1'b1, 5'd7};
	localparam [5:0] EXC_CAUSE_IRQ_EXTERNAL_M = {1'b1, 5'd11};
	localparam [5:0] EXC_CAUSE_IRQ_NM = {1'b1, 5'd31};
	localparam [5:0] EXC_CAUSE_INSN_ADDR_MISA = {1'b0, 5'd0};
	localparam [5:0] EXC_CAUSE_INSTR_ACCESS_FAULT = {1'b0, 5'd1};
	localparam [5:0] EXC_CAUSE_ILLEGAL_INSN = {1'b0, 5'd2};
	localparam [5:0] EXC_CAUSE_BREAKPOINT = {1'b0, 5'd3};
	localparam [5:0] EXC_CAUSE_LOAD_ACCESS_FAULT = {1'b0, 5'd5};
	localparam [5:0] EXC_CAUSE_STORE_ACCESS_FAULT = {1'b0, 5'd7};
	localparam [5:0] EXC_CAUSE_ECALL_UMODE = {1'b0, 5'd8};
	localparam [5:0] EXC_CAUSE_ECALL_MMODE = {1'b0, 5'd11};
	localparam [2:0] DBG_CAUSE_NONE = 3'h0;
	localparam [2:0] DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] DBG_CAUSE_TRIGGER = 3'h2;
	localparam [2:0] DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] DBG_CAUSE_STEP = 3'h4;
	localparam [31:0] PMP_MAX_REGIONS = 16;
	localparam [31:0] PMP_CFG_W = 8;
	localparam [31:0] PMP_I = 0;
	localparam [31:0] PMP_D = 1;
	localparam [1:0] PMP_ACC_EXEC = 2'b00;
	localparam [1:0] PMP_ACC_WRITE = 2'b01;
	localparam [1:0] PMP_ACC_READ = 2'b10;
	localparam [1:0] PMP_MODE_OFF = 2'b00;
	localparam [1:0] PMP_MODE_TOR = 2'b01;
	localparam [1:0] PMP_MODE_NA4 = 2'b10;
	localparam [1:0] PMP_MODE_NAPOT = 2'b11;
	localparam [11:0] CSR_MHARTID = 12'hf14;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MISA = 12'h301;
	localparam [11:0] CSR_MIE = 12'h304;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MSCRATCH = 12'h340;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MTVAL = 12'h343;
	localparam [11:0] CSR_MIP = 12'h344;
	localparam [11:0] CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] CSR_TSELECT = 12'h7a0;
	localparam [11:0] CSR_TDATA1 = 12'h7a1;
	localparam [11:0] CSR_TDATA2 = 12'h7a2;
	localparam [11:0] CSR_TDATA3 = 12'h7a3;
	localparam [11:0] CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] CSR_DCSR = 12'h7b0;
	localparam [11:0] CSR_DPC = 12'h7b1;
	localparam [11:0] CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] CSR_MCYCLE = 12'hb00;
	localparam [11:0] CSR_MINSTRET = 12'hb02;
	localparam [11:0] CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] CSR_MCYCLEH = 12'hb80;
	localparam [11:0] CSR_MINSTRETH = 12'hb82;
	localparam [11:0] CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] CSR_CPUCTRL = 12'h7c0;
	localparam [11:0] CSR_SECURESEED = 12'h7c1;
	localparam [11:0] CSR_OFF_PMP_CFG = 12'h3a0;
	localparam [11:0] CSR_OFF_PMP_ADDR = 12'h3b0;
	localparam [31:0] CSR_MSTATUS_MIE_BIT = 3;
	localparam [31:0] CSR_MSTATUS_MPIE_BIT = 7;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_LOW = 11;
	localparam [31:0] CSR_MSTATUS_MPP_BIT_HIGH = 12;
	localparam [31:0] CSR_MSTATUS_MPRV_BIT = 17;
	localparam [31:0] CSR_MSTATUS_TW_BIT = 21;
	localparam [1:0] CSR_MISA_MXL = 2'd1;
	localparam [31:0] CSR_MSIX_BIT = 3;
	localparam [31:0] CSR_MTIX_BIT = 7;
	localparam [31:0] CSR_MEIX_BIT = 11;
	localparam [31:0] CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] CSR_MFIX_BIT_HIGH = 30;
	wire [31:0] rf_wdata_wb_mux [0:1];
	wire [1:0] rf_wdata_wb_mux_we;
	generate
		if (WritebackStage) begin : g_writeback_stage
			reg [31:0] rf_wdata_wb_q;
			reg rf_we_wb_q;
			reg [4:0] rf_waddr_wb_q;
			wire wb_done;
			reg wb_valid_q;
			reg [31:0] wb_pc_q;
			reg [1:0] wb_instr_type_q;
			wire wb_valid_d;
			assign wb_valid_d = (en_wb_i & ready_wb_o) | (wb_valid_q & ~wb_done);
			assign wb_done = (wb_instr_type_q == WB_INSTR_OTHER) | lsu_resp_valid_i;
			always @(posedge clk_i or negedge rst_ni)
				if (~rst_ni)
					wb_valid_q <= 1'b0;
				else
					wb_valid_q <= wb_valid_d;
			always @(posedge clk_i)
				if (en_wb_i) begin
					rf_we_wb_q <= rf_we_id_i;
					rf_waddr_wb_q <= rf_waddr_id_i;
					rf_wdata_wb_q <= rf_wdata_id_i;
					wb_instr_type_q <= instr_type_wb_i;
					wb_pc_q <= pc_id_i;
				end
			assign rf_waddr_wb_o = rf_waddr_wb_q;
			assign rf_wdata_wb_mux[0] = rf_wdata_wb_q;
			assign rf_wdata_wb_mux_we[0] = rf_we_wb_q & wb_valid_q;
			assign ready_wb_o = ~wb_valid_q | wb_done;
			assign rf_write_wb_o = wb_valid_q & (rf_we_wb_q | (wb_instr_type_q == WB_INSTR_LOAD));
			assign outstanding_load_wb_o = wb_valid_q & (wb_instr_type_q == WB_INSTR_LOAD);
			assign outstanding_store_wb_o = wb_valid_q & (wb_instr_type_q == WB_INSTR_STORE);
			assign pc_wb_o = wb_pc_q;
			assign instr_done_wb_o = wb_valid_q & wb_done;
			assign rf_wdata_fwd_wb_o = rf_wdata_wb_q;
		end
		else begin : g_bypass_wb
			assign rf_waddr_wb_o = rf_waddr_id_i;
			assign rf_wdata_wb_mux[0] = rf_wdata_id_i;
			assign rf_wdata_wb_mux_we[0] = rf_we_id_i;
			assign ready_wb_o = 1'b1;
			wire unused_clk;
			wire unused_rst;
			wire unused_en_wb;
			wire [1:0] unused_instr_type_wb;
			wire [31:0] unused_pc_id;
			wire unused_lsu_resp_valid;
			assign unused_clk = clk_i;
			assign unused_rst = rst_ni;
			assign unused_en_wb = en_wb_i;
			assign unused_instr_type_wb = instr_type_wb_i;
			assign unused_pc_id = pc_id_i;
			assign unused_lsu_resp_valid = lsu_resp_valid_i;
			assign outstanding_load_wb_o = 1'b0;
			assign outstanding_store_wb_o = 1'b0;
			assign pc_wb_o = {32 {1'sb0}};
			assign rf_write_wb_o = 1'b0;
			assign rf_wdata_fwd_wb_o = 32'b00000000000000000000000000000000;
			assign instr_done_wb_o = 1'b0;
		end
	endgenerate
	assign rf_wdata_wb_mux[1] = rf_wdata_lsu_i;
	assign rf_wdata_wb_mux_we[1] = rf_we_lsu_i;
	assign rf_wdata_wb_o = (rf_wdata_wb_mux_we[0] ? rf_wdata_wb_mux[0] : rf_wdata_wb_mux[1]);
	assign rf_we_wb_o = |rf_wdata_wb_mux_we;
endmodule
module tlul_gpio (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	cio_gpio_i,
	cio_gpio_o,
	cio_gpio_en_o,
	intr_gpio_o
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_o;
	input [31:0] cio_gpio_i;
	output wire [31:0] cio_gpio_o;
	output wire [31:0] cio_gpio_en_o;
	output wire [31:0] intr_gpio_o;
	localparam [5:0] GPIO_INTR_STATE_OFFSET = 6'h00;
	localparam [5:0] GPIO_INTR_ENABLE_OFFSET = 6'h04;
	localparam [5:0] GPIO_INTR_TEST_OFFSET = 6'h08;
	localparam [5:0] GPIO_DATA_IN_OFFSET = 6'h0c;
	localparam [5:0] GPIO_DIRECT_OUT_OFFSET = 6'h10;
	localparam [5:0] GPIO_MASKED_OUT_LOWER_OFFSET = 6'h14;
	localparam [5:0] GPIO_MASKED_OUT_UPPER_OFFSET = 6'h18;
	localparam [5:0] GPIO_DIRECT_OE_OFFSET = 6'h1c;
	localparam [5:0] GPIO_MASKED_OE_LOWER_OFFSET = 6'h20;
	localparam [5:0] GPIO_MASKED_OE_UPPER_OFFSET = 6'h24;
	localparam [5:0] GPIO_INTR_CTRL_EN_RISING_OFFSET = 6'h28;
	localparam [5:0] GPIO_INTR_CTRL_EN_FALLING_OFFSET = 6'h2c;
	localparam [5:0] GPIO_INTR_CTRL_EN_LVLHIGH_OFFSET = 6'h30;
	localparam [5:0] GPIO_INTR_CTRL_EN_LVLLOW_OFFSET = 6'h34;
	localparam [5:0] GPIO_CTRL_EN_INPUT_FILTER_OFFSET = 6'h38;
	localparam signed [31:0] GPIO_INTR_STATE = 0;
	localparam signed [31:0] GPIO_INTR_ENABLE = 1;
	localparam signed [31:0] GPIO_INTR_TEST = 2;
	localparam signed [31:0] GPIO_DATA_IN = 3;
	localparam signed [31:0] GPIO_DIRECT_OUT = 4;
	localparam signed [31:0] GPIO_MASKED_OUT_LOWER = 5;
	localparam signed [31:0] GPIO_MASKED_OUT_UPPER = 6;
	localparam signed [31:0] GPIO_DIRECT_OE = 7;
	localparam signed [31:0] GPIO_MASKED_OE_LOWER = 8;
	localparam signed [31:0] GPIO_MASKED_OE_UPPER = 9;
	localparam signed [31:0] GPIO_INTR_CTRL_EN_RISING = 10;
	localparam signed [31:0] GPIO_INTR_CTRL_EN_FALLING = 11;
	localparam signed [31:0] GPIO_INTR_CTRL_EN_LVLHIGH = 12;
	localparam signed [31:0] GPIO_INTR_CTRL_EN_LVLLOW = 13;
	localparam signed [31:0] GPIO_CTRL_EN_INPUT_FILTER = 14;
	localparam [59:0] GPIO_PERMIT = {4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111};
	wire [458:0] reg2hw;
	wire [257:0] hw2reg;
	reg [31:0] cio_gpio_q;
	reg [31:0] cio_gpio_en_q;
	wire [31:0] data_in_d;
	generate
		genvar i;
		for (i = 0; i < 32; i = i + 1) begin : gen_filter
			prim_filter_ctr #(.Cycles(16)) filter(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.enable_i(reg2hw[i]),
				.filter_i(cio_gpio_i[i]),
				.filter_o(data_in_d[i])
			);
		end
	endgenerate
	assign hw2reg[192] = 1'b1;
	assign hw2reg[224-:32] = data_in_d;
	assign cio_gpio_o = cio_gpio_q;
	assign cio_gpio_en_o = cio_gpio_en_q;
	assign hw2reg[191-:32] = cio_gpio_q;
	assign hw2reg[127-:16] = cio_gpio_q[31:16];
	assign hw2reg[111-:16] = 16'h0000;
	assign hw2reg[159-:16] = cio_gpio_q[15:0];
	assign hw2reg[143-:16] = 16'h0000;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			cio_gpio_q <= {32 {1'sb0}};
		else if (reg2hw[329])
			cio_gpio_q <= reg2hw[361-:32];
		else if (reg2hw[278])
			cio_gpio_q[31:16] <= (reg2hw[277-:16] & reg2hw[294-:16]) | (~reg2hw[277-:16] & cio_gpio_q[31:16]);
		else if (reg2hw[312])
			cio_gpio_q[15:0] <= (reg2hw[311-:16] & reg2hw[328-:16]) | (~reg2hw[311-:16] & cio_gpio_q[15:0]);
	assign hw2reg[95-:32] = cio_gpio_en_q;
	assign hw2reg[31-:16] = cio_gpio_en_q[31:16];
	assign hw2reg[15-:16] = 16'h0000;
	assign hw2reg[63-:16] = cio_gpio_en_q[15:0];
	assign hw2reg[47-:16] = 16'h0000;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			cio_gpio_en_q <= {32 {1'sb0}};
		else if (reg2hw[228])
			cio_gpio_en_q <= reg2hw[260-:32];
		else if (reg2hw[177])
			cio_gpio_en_q[31:16] <= (reg2hw[176-:16] & reg2hw[193-:16]) | (~reg2hw[176-:16] & cio_gpio_en_q[31:16]);
		else if (reg2hw[211])
			cio_gpio_en_q[15:0] <= (reg2hw[210-:16] & reg2hw[227-:16]) | (~reg2hw[210-:16] & cio_gpio_en_q[15:0]);
	reg [31:0] data_in_q;
	always @(posedge clk_i) data_in_q <= data_in_d;
	wire [31:0] event_intr_rise;
	wire [31:0] event_intr_fall;
	wire [31:0] event_intr_actlow;
	wire [31:0] event_intr_acthigh;
	wire [31:0] event_intr_combined;
	prim_intr_hw #(.Width(32)) intr_hw(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.event_intr_i(event_intr_combined),
		.reg2hw_intr_enable_q_i(reg2hw[426-:32]),
		.reg2hw_intr_test_q_i(reg2hw[394-:32]),
		.reg2hw_intr_test_qe_i(reg2hw[362]),
		.reg2hw_intr_state_q_i(reg2hw[458-:32]),
		.hw2reg_intr_state_de_o(hw2reg[225]),
		.hw2reg_intr_state_d_o(hw2reg[257-:32]),
		.intr_o(intr_gpio_o)
	);
	assign event_intr_rise = (~data_in_q & data_in_d) & reg2hw[159-:32];
	assign event_intr_fall = (data_in_q & ~data_in_d) & reg2hw[127-:32];
	assign event_intr_acthigh = data_in_d & reg2hw[95-:32];
	assign event_intr_actlow = ~data_in_d & reg2hw[63-:32];
	assign event_intr_combined = ((event_intr_rise | event_intr_fall) | event_intr_actlow) | event_intr_acthigh;
	gpio_reg_top u_reg(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.devmode_i(1'b1)
	);
endmodule
module gpio_reg_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	reg2hw,
	hw2reg,
	devmode_i
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_o;
	output wire [458:0] reg2hw;
	input wire [257:0] hw2reg;
	input devmode_i;
	localparam [5:0] GPIO_INTR_STATE_OFFSET = 6'h00;
	localparam [5:0] GPIO_INTR_ENABLE_OFFSET = 6'h04;
	localparam [5:0] GPIO_INTR_TEST_OFFSET = 6'h08;
	localparam [5:0] GPIO_DATA_IN_OFFSET = 6'h0c;
	localparam [5:0] GPIO_DIRECT_OUT_OFFSET = 6'h10;
	localparam [5:0] GPIO_MASKED_OUT_LOWER_OFFSET = 6'h14;
	localparam [5:0] GPIO_MASKED_OUT_UPPER_OFFSET = 6'h18;
	localparam [5:0] GPIO_DIRECT_OE_OFFSET = 6'h1c;
	localparam [5:0] GPIO_MASKED_OE_LOWER_OFFSET = 6'h20;
	localparam [5:0] GPIO_MASKED_OE_UPPER_OFFSET = 6'h24;
	localparam [5:0] GPIO_INTR_CTRL_EN_RISING_OFFSET = 6'h28;
	localparam [5:0] GPIO_INTR_CTRL_EN_FALLING_OFFSET = 6'h2c;
	localparam [5:0] GPIO_INTR_CTRL_EN_LVLHIGH_OFFSET = 6'h30;
	localparam [5:0] GPIO_INTR_CTRL_EN_LVLLOW_OFFSET = 6'h34;
	localparam [5:0] GPIO_CTRL_EN_INPUT_FILTER_OFFSET = 6'h38;
	localparam signed [31:0] GPIO_INTR_STATE = 0;
	localparam signed [31:0] GPIO_INTR_ENABLE = 1;
	localparam signed [31:0] GPIO_INTR_TEST = 2;
	localparam signed [31:0] GPIO_DATA_IN = 3;
	localparam signed [31:0] GPIO_DIRECT_OUT = 4;
	localparam signed [31:0] GPIO_MASKED_OUT_LOWER = 5;
	localparam signed [31:0] GPIO_MASKED_OUT_UPPER = 6;
	localparam signed [31:0] GPIO_DIRECT_OE = 7;
	localparam signed [31:0] GPIO_MASKED_OE_LOWER = 8;
	localparam signed [31:0] GPIO_MASKED_OE_UPPER = 9;
	localparam signed [31:0] GPIO_INTR_CTRL_EN_RISING = 10;
	localparam signed [31:0] GPIO_INTR_CTRL_EN_FALLING = 11;
	localparam signed [31:0] GPIO_INTR_CTRL_EN_LVLHIGH = 12;
	localparam signed [31:0] GPIO_INTR_CTRL_EN_LVLLOW = 13;
	localparam signed [31:0] GPIO_CTRL_EN_INPUT_FILTER = 14;
	localparam [59:0] GPIO_PERMIT = {4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111};
	localparam signed [31:0] AW = 6;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] DBW = DW / 8;
	wire reg_we;
	wire reg_re;
	wire [AW - 1:0] reg_addr;
	wire [DW - 1:0] reg_wdata;
	wire [DBW - 1:0] reg_be;
	wire [DW - 1:0] reg_rdata;
	wire reg_error;
	wire addrmiss;
	reg wr_err;
	reg [DW - 1:0] reg_rdata_next;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_reg_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_reg_d2h;
	assign tl_reg_h2d = tl_i;
	assign tl_o = tl_reg_d2h;
	tlul_adapter_reg #(
		.RegAw(AW),
		.RegDw(DW)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_reg_h2d),
		.tl_o(tl_reg_d2h),
		.we_o(reg_we),
		.re_o(reg_re),
		.addr_o(reg_addr),
		.wdata_o(reg_wdata),
		.be_o(reg_be),
		.rdata_i(reg_rdata),
		.error_i(reg_error)
	);
	assign reg_rdata = reg_rdata_next;
	assign reg_error = (devmode_i & addrmiss) | wr_err;
	wire [31:0] intr_state_qs;
	wire [31:0] intr_state_wd;
	wire intr_state_we;
	wire [31:0] intr_enable_qs;
	wire [31:0] intr_enable_wd;
	wire intr_enable_we;
	wire [31:0] intr_test_wd;
	wire intr_test_we;
	wire [31:0] data_in_qs;
	wire [31:0] direct_out_qs;
	wire [31:0] direct_out_wd;
	wire direct_out_we;
	wire direct_out_re;
	wire [15:0] masked_out_lower_data_qs;
	wire [15:0] masked_out_lower_data_wd;
	wire masked_out_lower_data_we;
	wire masked_out_lower_data_re;
	wire [15:0] masked_out_lower_mask_wd;
	wire masked_out_lower_mask_we;
	wire [15:0] masked_out_upper_data_qs;
	wire [15:0] masked_out_upper_data_wd;
	wire masked_out_upper_data_we;
	wire masked_out_upper_data_re;
	wire [15:0] masked_out_upper_mask_wd;
	wire masked_out_upper_mask_we;
	wire [31:0] direct_oe_qs;
	wire [31:0] direct_oe_wd;
	wire direct_oe_we;
	wire direct_oe_re;
	wire [15:0] masked_oe_lower_data_qs;
	wire [15:0] masked_oe_lower_data_wd;
	wire masked_oe_lower_data_we;
	wire masked_oe_lower_data_re;
	wire [15:0] masked_oe_lower_mask_qs;
	wire [15:0] masked_oe_lower_mask_wd;
	wire masked_oe_lower_mask_we;
	wire masked_oe_lower_mask_re;
	wire [15:0] masked_oe_upper_data_qs;
	wire [15:0] masked_oe_upper_data_wd;
	wire masked_oe_upper_data_we;
	wire masked_oe_upper_data_re;
	wire [15:0] masked_oe_upper_mask_qs;
	wire [15:0] masked_oe_upper_mask_wd;
	wire masked_oe_upper_mask_we;
	wire masked_oe_upper_mask_re;
	wire [31:0] intr_ctrl_en_rising_qs;
	wire [31:0] intr_ctrl_en_rising_wd;
	wire intr_ctrl_en_rising_we;
	wire [31:0] intr_ctrl_en_falling_qs;
	wire [31:0] intr_ctrl_en_falling_wd;
	wire intr_ctrl_en_falling_we;
	wire [31:0] intr_ctrl_en_lvlhigh_qs;
	wire [31:0] intr_ctrl_en_lvlhigh_wd;
	wire intr_ctrl_en_lvlhigh_we;
	wire [31:0] intr_ctrl_en_lvllow_qs;
	wire [31:0] intr_ctrl_en_lvllow_wd;
	wire intr_ctrl_en_lvllow_we;
	wire [31:0] ctrl_en_input_filter_qs;
	wire [31:0] ctrl_en_input_filter_wd;
	wire ctrl_en_input_filter_we;
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(24),
		.SWACCESS("W1C"),
		.RESVAL(32'h00000000)
	) u_intr_state(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_we),
		.wd(intr_state_wd),
		.de(hw2reg[225]),
		.d(hw2reg[257-:32]),
		.qe(),
		.q(reg2hw[458-:32]),
		.qs(intr_state_qs)
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_enable(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_we),
		.wd(intr_enable_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[426-:32]),
		.qs(intr_enable_qs)
	);
	prim_subreg_ext #(.DW(32)) u_intr_test(
		.re(1'b0),
		.we(intr_test_we),
		.wd(intr_test_wd),
		.d({32 {1'sb0}}),
		.qre(),
		.qe(reg2hw[362]),
		.q(reg2hw[394-:32]),
		.qs()
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(32'h00000000)
	) u_data_in(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd({32 {1'sb0}}),
		.de(hw2reg[192]),
		.d(hw2reg[224-:32]),
		.qe(),
		.q(),
		.qs(data_in_qs)
	);
	prim_subreg_ext #(.DW(32)) u_direct_out(
		.re(direct_out_re),
		.we(direct_out_we),
		.wd(direct_out_wd),
		.d(hw2reg[191-:32]),
		.qre(),
		.qe(reg2hw[329]),
		.q(reg2hw[361-:32]),
		.qs(direct_out_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_lower_data(
		.re(masked_out_lower_data_re),
		.we(masked_out_lower_data_we),
		.wd(masked_out_lower_data_wd),
		.d(hw2reg[159-:16]),
		.qre(),
		.qe(reg2hw[312]),
		.q(reg2hw[328-:16]),
		.qs(masked_out_lower_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_lower_mask(
		.re(1'b0),
		.we(masked_out_lower_mask_we),
		.wd(masked_out_lower_mask_wd),
		.d(hw2reg[143-:16]),
		.qre(),
		.qe(reg2hw[295]),
		.q(reg2hw[311-:16]),
		.qs()
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_upper_data(
		.re(masked_out_upper_data_re),
		.we(masked_out_upper_data_we),
		.wd(masked_out_upper_data_wd),
		.d(hw2reg[127-:16]),
		.qre(),
		.qe(reg2hw[278]),
		.q(reg2hw[294-:16]),
		.qs(masked_out_upper_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_upper_mask(
		.re(1'b0),
		.we(masked_out_upper_mask_we),
		.wd(masked_out_upper_mask_wd),
		.d(hw2reg[111-:16]),
		.qre(),
		.qe(reg2hw[261]),
		.q(reg2hw[277-:16]),
		.qs()
	);
	prim_subreg_ext #(.DW(32)) u_direct_oe(
		.re(direct_oe_re),
		.we(direct_oe_we),
		.wd(direct_oe_wd),
		.d(hw2reg[95-:32]),
		.qre(),
		.qe(reg2hw[228]),
		.q(reg2hw[260-:32]),
		.qs(direct_oe_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_lower_data(
		.re(masked_oe_lower_data_re),
		.we(masked_oe_lower_data_we),
		.wd(masked_oe_lower_data_wd),
		.d(hw2reg[63-:16]),
		.qre(),
		.qe(reg2hw[211]),
		.q(reg2hw[227-:16]),
		.qs(masked_oe_lower_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_lower_mask(
		.re(masked_oe_lower_mask_re),
		.we(masked_oe_lower_mask_we),
		.wd(masked_oe_lower_mask_wd),
		.d(hw2reg[47-:16]),
		.qre(),
		.qe(reg2hw[194]),
		.q(reg2hw[210-:16]),
		.qs(masked_oe_lower_mask_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_upper_data(
		.re(masked_oe_upper_data_re),
		.we(masked_oe_upper_data_we),
		.wd(masked_oe_upper_data_wd),
		.d(hw2reg[31-:16]),
		.qre(),
		.qe(reg2hw[177]),
		.q(reg2hw[193-:16]),
		.qs(masked_oe_upper_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_upper_mask(
		.re(masked_oe_upper_mask_re),
		.we(masked_oe_upper_mask_we),
		.wd(masked_oe_upper_mask_wd),
		.d(hw2reg[15-:16]),
		.qre(),
		.qe(reg2hw[160]),
		.q(reg2hw[176-:16]),
		.qs(masked_oe_upper_mask_qs)
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_rising(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_rising_we),
		.wd(intr_ctrl_en_rising_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[159-:32]),
		.qs(intr_ctrl_en_rising_qs)
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_falling(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_falling_we),
		.wd(intr_ctrl_en_falling_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[127-:32]),
		.qs(intr_ctrl_en_falling_qs)
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_lvlhigh(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_lvlhigh_we),
		.wd(intr_ctrl_en_lvlhigh_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[95-:32]),
		.qs(intr_ctrl_en_lvlhigh_qs)
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_lvllow(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_lvllow_we),
		.wd(intr_ctrl_en_lvllow_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[63-:32]),
		.qs(intr_ctrl_en_lvllow_qs)
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_ctrl_en_input_filter(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_en_input_filter_we),
		.wd(ctrl_en_input_filter_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(),
		.q(reg2hw[31-:32]),
		.qs(ctrl_en_input_filter_qs)
	);
	reg [14:0] addr_hit;
	always @(*) begin
		addr_hit = {15 {1'sb0}};
		addr_hit[0] = reg_addr == GPIO_INTR_STATE_OFFSET;
		addr_hit[1] = reg_addr == GPIO_INTR_ENABLE_OFFSET;
		addr_hit[2] = reg_addr == GPIO_INTR_TEST_OFFSET;
		addr_hit[3] = reg_addr == GPIO_DATA_IN_OFFSET;
		addr_hit[4] = reg_addr == GPIO_DIRECT_OUT_OFFSET;
		addr_hit[5] = reg_addr == GPIO_MASKED_OUT_LOWER_OFFSET;
		addr_hit[6] = reg_addr == GPIO_MASKED_OUT_UPPER_OFFSET;
		addr_hit[7] = reg_addr == GPIO_DIRECT_OE_OFFSET;
		addr_hit[8] = reg_addr == GPIO_MASKED_OE_LOWER_OFFSET;
		addr_hit[9] = reg_addr == GPIO_MASKED_OE_UPPER_OFFSET;
		addr_hit[10] = reg_addr == GPIO_INTR_CTRL_EN_RISING_OFFSET;
		addr_hit[11] = reg_addr == GPIO_INTR_CTRL_EN_FALLING_OFFSET;
		addr_hit[12] = reg_addr == GPIO_INTR_CTRL_EN_LVLHIGH_OFFSET;
		addr_hit[13] = reg_addr == GPIO_INTR_CTRL_EN_LVLLOW_OFFSET;
		addr_hit[14] = reg_addr == GPIO_CTRL_EN_INPUT_FILTER_OFFSET;
	end
	assign addrmiss = (reg_re || reg_we ? ~|addr_hit : 1'b0);
	always @(*) begin
		wr_err = 1'b0;
		if ((addr_hit[0] && reg_we) && (GPIO_PERMIT[56+:4] != (GPIO_PERMIT[56+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[1] && reg_we) && (GPIO_PERMIT[52+:4] != (GPIO_PERMIT[52+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[2] && reg_we) && (GPIO_PERMIT[48+:4] != (GPIO_PERMIT[48+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[3] && reg_we) && (GPIO_PERMIT[44+:4] != (GPIO_PERMIT[44+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[4] && reg_we) && (GPIO_PERMIT[40+:4] != (GPIO_PERMIT[40+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[5] && reg_we) && (GPIO_PERMIT[36+:4] != (GPIO_PERMIT[36+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[6] && reg_we) && (GPIO_PERMIT[32+:4] != (GPIO_PERMIT[32+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[7] && reg_we) && (GPIO_PERMIT[28+:4] != (GPIO_PERMIT[28+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[8] && reg_we) && (GPIO_PERMIT[24+:4] != (GPIO_PERMIT[24+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[9] && reg_we) && (GPIO_PERMIT[20+:4] != (GPIO_PERMIT[20+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[10] && reg_we) && (GPIO_PERMIT[16+:4] != (GPIO_PERMIT[16+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[11] && reg_we) && (GPIO_PERMIT[12+:4] != (GPIO_PERMIT[12+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[12] && reg_we) && (GPIO_PERMIT[8+:4] != (GPIO_PERMIT[8+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[13] && reg_we) && (GPIO_PERMIT[4+:4] != (GPIO_PERMIT[4+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[14] && reg_we) && (GPIO_PERMIT[0+:4] != (GPIO_PERMIT[0+:4] & reg_be)))
			wr_err = 1'b1;
	end
	assign intr_state_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_wd = reg_wdata[31:0];
	assign intr_enable_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_wd = reg_wdata[31:0];
	assign intr_test_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_wd = reg_wdata[31:0];
	assign direct_out_we = (addr_hit[4] & reg_we) & ~wr_err;
	assign direct_out_wd = reg_wdata[31:0];
	assign direct_out_re = addr_hit[4] && reg_re;
	assign masked_out_lower_data_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign masked_out_lower_data_wd = reg_wdata[15:0];
	assign masked_out_lower_data_re = addr_hit[5] && reg_re;
	assign masked_out_lower_mask_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign masked_out_lower_mask_wd = reg_wdata[31:16];
	assign masked_out_upper_data_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign masked_out_upper_data_wd = reg_wdata[15:0];
	assign masked_out_upper_data_re = addr_hit[6] && reg_re;
	assign masked_out_upper_mask_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign masked_out_upper_mask_wd = reg_wdata[31:16];
	assign direct_oe_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign direct_oe_wd = reg_wdata[31:0];
	assign direct_oe_re = addr_hit[7] && reg_re;
	assign masked_oe_lower_data_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign masked_oe_lower_data_wd = reg_wdata[15:0];
	assign masked_oe_lower_data_re = addr_hit[8] && reg_re;
	assign masked_oe_lower_mask_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign masked_oe_lower_mask_wd = reg_wdata[31:16];
	assign masked_oe_lower_mask_re = addr_hit[8] && reg_re;
	assign masked_oe_upper_data_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign masked_oe_upper_data_wd = reg_wdata[15:0];
	assign masked_oe_upper_data_re = addr_hit[9] && reg_re;
	assign masked_oe_upper_mask_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign masked_oe_upper_mask_wd = reg_wdata[31:16];
	assign masked_oe_upper_mask_re = addr_hit[9] && reg_re;
	assign intr_ctrl_en_rising_we = (addr_hit[10] & reg_we) & ~wr_err;
	assign intr_ctrl_en_rising_wd = reg_wdata[31:0];
	assign intr_ctrl_en_falling_we = (addr_hit[11] & reg_we) & ~wr_err;
	assign intr_ctrl_en_falling_wd = reg_wdata[31:0];
	assign intr_ctrl_en_lvlhigh_we = (addr_hit[12] & reg_we) & ~wr_err;
	assign intr_ctrl_en_lvlhigh_wd = reg_wdata[31:0];
	assign intr_ctrl_en_lvllow_we = (addr_hit[13] & reg_we) & ~wr_err;
	assign intr_ctrl_en_lvllow_wd = reg_wdata[31:0];
	assign ctrl_en_input_filter_we = (addr_hit[14] & reg_we) & ~wr_err;
	assign ctrl_en_input_filter_wd = reg_wdata[31:0];
	always @(*) begin
		reg_rdata_next = {DW {1'sb0}};
		case (1'b1)
			addr_hit[0]: reg_rdata_next[31:0] = intr_state_qs;
			addr_hit[1]: reg_rdata_next[31:0] = intr_enable_qs;
			addr_hit[2]: reg_rdata_next[31:0] = {32 {1'sb0}};
			addr_hit[3]: reg_rdata_next[31:0] = data_in_qs;
			addr_hit[4]: reg_rdata_next[31:0] = direct_out_qs;
			addr_hit[5]: begin
				reg_rdata_next[15:0] = masked_out_lower_data_qs;
				reg_rdata_next[31:16] = {16 {1'sb0}};
			end
			addr_hit[6]: begin
				reg_rdata_next[15:0] = masked_out_upper_data_qs;
				reg_rdata_next[31:16] = {16 {1'sb0}};
			end
			addr_hit[7]: reg_rdata_next[31:0] = direct_oe_qs;
			addr_hit[8]: begin
				reg_rdata_next[15:0] = masked_oe_lower_data_qs;
				reg_rdata_next[31:16] = masked_oe_lower_mask_qs;
			end
			addr_hit[9]: begin
				reg_rdata_next[15:0] = masked_oe_upper_data_qs;
				reg_rdata_next[31:16] = masked_oe_upper_mask_qs;
			end
			addr_hit[10]: reg_rdata_next[31:0] = intr_ctrl_en_rising_qs;
			addr_hit[11]: reg_rdata_next[31:0] = intr_ctrl_en_falling_qs;
			addr_hit[12]: reg_rdata_next[31:0] = intr_ctrl_en_lvlhigh_qs;
			addr_hit[13]: reg_rdata_next[31:0] = intr_ctrl_en_lvllow_qs;
			addr_hit[14]: reg_rdata_next[31:0] = ctrl_en_input_filter_qs;
			default: reg_rdata_next = {DW {1'sb1}};
		endcase
	end
endmodule
module prim_arbiter_ppc (
	clk_i,
	rst_ni,
	req_i,
	data_i,
	gnt_o,
	idx_o,
	valid_o,
	data_o,
	ready_i
);
	parameter [31:0] N = 8;
	parameter [31:0] DW = 32;
	parameter [0:0] EnDataPort = 1;
	parameter [0:0] EnReqStabA = 1;
	localparam signed [31:0] IdxW = $clog2(N);
	input clk_i;
	input rst_ni;
	input [N - 1:0] req_i;
	input [(0 >= (N - 1) ? ((2 - N) * DW) + (((N - 1) * DW) - 1) : (N * DW) - 1):(0 >= (N - 1) ? (N - 1) * DW : 0)] data_i;
	output wire [N - 1:0] gnt_o;
	output reg [IdxW - 1:0] idx_o;
	output wire valid_o;
	output reg [DW - 1:0] data_o;
	input ready_i;
	generate
		if (N == 1) begin : gen_degenerate_case
			assign valid_o = req_i[0];
			always @(*) data_o = data_i[(0 >= (N - 1) ? 0 : N - 1) * DW+:DW];
			assign gnt_o[0] = valid_o & ready_i;
			always @(*) idx_o = {IdxW {1'sb0}};
		end
		else begin : gen_normal_case
			wire [N - 1:0] masked_req;
			reg [N - 1:0] ppc_out;
			wire [N - 1:0] arb_req;
			reg [N - 1:0] mask;
			wire [N - 1:0] mask_next;
			wire [N - 1:0] winner;
			assign masked_req = mask & req_i;
			assign arb_req = (|masked_req ? masked_req : req_i);
			always @(*) begin
				ppc_out[0] = arb_req[0];
				begin : sv2v_autoblock_71
					reg signed [31:0] i;
					for (i = 1; i < N; i = i + 1)
						ppc_out[i] = ppc_out[i - 1] | arb_req[i];
				end
			end
			assign winner = ppc_out ^ {ppc_out[N - 2:0], 1'b0};
			assign gnt_o = (ready_i ? winner : {N {1'sb0}});
			assign valid_o = |req_i;
			assign mask_next = {ppc_out[N - 2:0], 1'b0};
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mask <= {N {1'sb0}};
				else if (valid_o && ready_i)
					mask <= mask_next;
				else if (valid_o && !ready_i)
					mask <= ppc_out;
			if (EnDataPort == 1) begin : gen_datapath
				always @(*) begin
					data_o = {DW {1'sb0}};
					begin : sv2v_autoblock_72
						reg signed [31:0] i;
						for (i = 0; i < N; i = i + 1)
							if (winner[i])
								data_o = data_i[(0 >= (N - 1) ? i : (N - 1) - i) * DW+:DW];
					end
				end
			end
			else begin : gen_nodatapath
				always @(*) data_o = {DW {1'sb1}};
			end
			always @(*) begin
				idx_o = {IdxW {1'sb0}};
				begin : sv2v_autoblock_73
					reg signed [31:0] i;
					for (i = 0; i < N; i = i + 1)
						if (winner[i])
							idx_o = i[IdxW - 1:0];
				end
			end
		end
	endgenerate
endmodule
module prim_clock_gating (
	clk_i,
	en_i,
	test_en_i,
	clk_o
);
	input clk_i;
	input en_i;
	input test_en_i;
	output wire clk_o;
	localparam integer prim_pkg_ImplGeneric = 0;
	parameter integer Impl = prim_pkg_ImplGeneric;
	generate
		if (Impl == prim_pkg_ImplGeneric) begin : gen_generic
			prim_generic_clock_gating u_impl_generic(
				.clk_i(clk_i),
				.en_i(en_i),
				.test_en_i(test_en_i),
				.clk_o(clk_o)
			);
		end
	endgenerate
endmodule
module prim_diff_decode (
	clk_i,
	rst_ni,
	diff_pi,
	diff_ni,
	level_o,
	rise_o,
	fall_o,
	event_o,
	sigint_o
);
	parameter [0:0] AsyncOn = 1'b0;
	input clk_i;
	input rst_ni;
	input diff_pi;
	input diff_ni;
	output wire level_o;
	output reg rise_o;
	output reg fall_o;
	output wire event_o;
	output reg sigint_o;
	reg level_d;
	reg level_q;
	localparam [1:0] IsSkewed = 1;
	localparam [1:0] IsStd = 0;
	localparam [1:0] SigInt = 2;
	generate
		if (AsyncOn) begin : gen_async
			reg [1:0] state_d;
			reg [1:0] state_q;
			wire diff_p_edge;
			wire diff_n_edge;
			wire diff_check_ok;
			wire level;
			reg diff_pq;
			reg diff_nq;
			wire diff_pd;
			wire diff_nd;
			prim_generic_flop_2sync #(
				.Width(1),
				.ResetValue(1'sb0)
			) i_sync_p(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.d_i(diff_pi),
				.q_o(diff_pd)
			);
			prim_generic_flop_2sync #(
				.Width(1),
				.ResetValue(1'b1)
			) i_sync_n(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.d_i(diff_ni),
				.q_o(diff_nd)
			);
			assign diff_p_edge = diff_pq ^ diff_pd;
			assign diff_n_edge = diff_nq ^ diff_nd;
			assign diff_check_ok = diff_pd ^ diff_nd;
			assign level = diff_pd;
			assign level_o = level_d;
			assign event_o = rise_o | fall_o;
			always @(*) begin : p_diff_fsm
				state_d = state_q;
				level_d = level_q;
				rise_o = 1'b0;
				fall_o = 1'b0;
				sigint_o = 1'b0;
				case (state_q)
					IsStd:
						if (diff_check_ok) begin
							level_d = level;
							if (diff_p_edge && diff_n_edge)
								if (level)
									rise_o = 1'b1;
								else
									fall_o = 1'b1;
						end
						else if (diff_p_edge || diff_n_edge)
							state_d = IsSkewed;
						else begin
							state_d = SigInt;
							sigint_o = 1'b1;
						end
					IsSkewed:
						if (diff_check_ok) begin
							state_d = IsStd;
							level_d = level;
							if (level)
								rise_o = 1'b1;
							else
								fall_o = 1'b1;
						end
						else begin
							state_d = SigInt;
							sigint_o = 1'b1;
						end
					SigInt: begin
						sigint_o = 1'b1;
						if (diff_check_ok) begin
							state_d = IsStd;
							sigint_o = 1'b0;
						end
					end
					default:
						;
				endcase
			end
			always @(posedge clk_i or negedge rst_ni) begin : p_sync_reg
				if (!rst_ni) begin
					state_q <= IsStd;
					diff_pq <= 1'b0;
					diff_nq <= 1'b1;
					level_q <= 1'b0;
				end
				else begin
					state_q <= state_d;
					diff_pq <= diff_pd;
					diff_nq <= diff_nd;
					level_q <= level_d;
				end
			end
		end
		else begin : gen_no_async
			reg diff_pq;
			wire diff_pd;
			assign diff_pd = diff_pi;
			always @(*) sigint_o = ~(diff_pi ^ diff_ni);
			assign level_o = (sigint_o ? level_q : diff_pi);
			always @(*) level_d = level_o;
			always @(*) rise_o = (~diff_pq & diff_pi) & ~sigint_o;
			always @(*) fall_o = (diff_pq & ~diff_pi) & ~sigint_o;
			assign event_o = rise_o | fall_o;
			always @(posedge clk_i or negedge rst_ni) begin : p_edge_reg
				if (!rst_ni) begin
					diff_pq <= 1'b0;
					level_q <= 1'b0;
				end
				else begin
					diff_pq <= diff_pd;
					level_q <= level_d;
				end
			end
		end
	endgenerate
endmodule
module prim_esc_receiver (
	clk_i,
	rst_ni,
	esc_en_o,
	esc_rx_o,
	esc_tx_i
);
	input clk_i;
	input rst_ni;
	output reg esc_en_o;
	output wire [1:0] esc_rx_o;
	input wire [1:0] esc_tx_i;
	wire esc_level;
	wire sigint_detected;
	prim_diff_decode #(.AsyncOn(1'b0)) i_decode_esc(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.diff_pi(esc_tx_i[1]),
		.diff_ni(esc_tx_i[0]),
		.level_o(esc_level),
		.rise_o(),
		.fall_o(),
		.event_o(),
		.sigint_o(sigint_detected)
	);
	reg [2:0] state_d;
	reg [2:0] state_q;
	reg resp_pd;
	reg resp_pq;
	reg resp_nd;
	reg resp_nq;
	assign esc_rx_o[1] = resp_pq;
	assign esc_rx_o[0] = resp_nq;
	localparam [2:0] Check = 1;
	localparam [2:0] EscResp = 3;
	localparam [2:0] Idle = 0;
	localparam [2:0] PingResp = 2;
	localparam [2:0] SigInt = 4;
	always @(*) begin : p_fsm
		state_d = state_q;
		resp_pd = 1'b0;
		resp_nd = 1'b1;
		esc_en_o = 1'b0;
		case (state_q)
			Idle:
				if (esc_level) begin
					state_d = Check;
					resp_pd = 1'b1;
					resp_nd = 1'b0;
				end
			Check: begin
				state_d = PingResp;
				if (esc_level) begin
					state_d = EscResp;
					esc_en_o = 1'b1;
				end
			end
			PingResp: begin
				state_d = Idle;
				resp_pd = 1'b1;
				resp_nd = 1'b0;
				if (esc_level) begin
					state_d = EscResp;
					esc_en_o = 1'b1;
				end
			end
			EscResp: begin
				state_d = Idle;
				if (esc_level) begin
					state_d = EscResp;
					resp_pd = ~resp_pq;
					resp_nd = resp_pq;
					esc_en_o = 1'b1;
				end
			end
			SigInt: begin
				state_d = Idle;
				if (sigint_detected) begin
					state_d = SigInt;
					resp_pd = ~resp_pq;
					resp_nd = ~resp_pq;
				end
			end
			default: state_d = Idle;
		endcase
		if (sigint_detected && (state_q != SigInt)) begin
			state_d = SigInt;
			resp_pd = 1'b0;
			resp_nd = 1'b0;
		end
	end
	always @(posedge clk_i or negedge rst_ni) begin : p_regs
		if (!rst_ni) begin
			state_q <= Idle;
			resp_pq <= 1'b0;
			resp_nq <= 1'b1;
		end
		else begin
			state_q <= state_d;
			resp_pq <= resp_pd;
			resp_nq <= resp_nd;
		end
	end
endmodule
module prim_fifo_async (
	clk_wr_i,
	rst_wr_ni,
	wvalid_i,
	wready_o,
	wdata_i,
	wdepth_o,
	clk_rd_i,
	rst_rd_ni,
	rvalid_o,
	rready_i,
	rdata_o,
	rdepth_o
);
	parameter [31:0] Width = 16;
	parameter [31:0] Depth = 3;
	localparam [31:0] DepthW = $clog2(Depth + 1);
	input clk_wr_i;
	input rst_wr_ni;
	input wvalid_i;
	output wready_o;
	input [Width - 1:0] wdata_i;
	output [DepthW - 1:0] wdepth_o;
	input clk_rd_i;
	input rst_rd_ni;
	output rvalid_o;
	input rready_i;
	output [Width - 1:0] rdata_o;
	output [DepthW - 1:0] rdepth_o;
	localparam [31:0] PTRV_W = $clog2(Depth);
	function automatic [PTRV_W - 1:0] sv2v_cast_2173F_unsigned;
		input reg [PTRV_W - 1:0] inp;
		sv2v_cast_2173F_unsigned = inp;
	endfunction
	localparam [PTRV_W - 1:0] DepthMinus1 = sv2v_cast_2173F_unsigned(Depth - 1);
	localparam [31:0] PTR_WIDTH = PTRV_W + 1;
	reg [PTR_WIDTH - 1:0] fifo_wptr;
	reg [PTR_WIDTH - 1:0] fifo_rptr;
	wire [PTR_WIDTH - 1:0] fifo_wptr_sync_combi;
	reg [PTR_WIDTH - 1:0] fifo_rptr_sync;
	wire [PTR_WIDTH - 1:0] fifo_wptr_gray_sync;
	wire [PTR_WIDTH - 1:0] fifo_rptr_gray_sync;
	reg [PTR_WIDTH - 1:0] fifo_wptr_gray;
	reg [PTR_WIDTH - 1:0] fifo_rptr_gray;
	wire fifo_incr_wptr;
	wire fifo_incr_rptr;
	wire empty;
	wire full_wclk;
	wire full_rclk;
	assign wready_o = !full_wclk;
	assign rvalid_o = !empty;
	assign fifo_incr_wptr = wvalid_i & wready_o;
	assign fifo_incr_rptr = rvalid_o & rready_i;
	always @(posedge clk_wr_i or negedge rst_wr_ni)
		if (!rst_wr_ni)
			fifo_wptr <= {PTR_WIDTH {1'b0}};
		else if (fifo_incr_wptr)
			if (fifo_wptr[PTR_WIDTH - 2:0] == DepthMinus1)
				fifo_wptr <= {~fifo_wptr[PTR_WIDTH - 1], {PTR_WIDTH - 1 {1'b0}}};
			else
				fifo_wptr <= fifo_wptr + {{PTR_WIDTH - 1 {1'b0}}, 1'b1};
	function automatic [PTR_WIDTH - 1:0] dec2gray;
		input reg [PTR_WIDTH - 1:0] decval;
		reg [PTR_WIDTH - 1:0] decval_sub;
		reg [PTR_WIDTH - 2:0] decval_in;
		reg unused_decval_msb;
		begin
			decval_sub = (Depth - {1'b0, decval[PTR_WIDTH - 2:0]}) - 1'b1;
			{unused_decval_msb, decval_in} = (decval[PTR_WIDTH - 1] ? decval_sub : decval);
			dec2gray = {decval[PTR_WIDTH - 1], {1'b0, decval_in[PTR_WIDTH - 2:1]} ^ decval_in[PTR_WIDTH - 2:0]};
		end
	endfunction
	always @(posedge clk_wr_i or negedge rst_wr_ni)
		if (!rst_wr_ni)
			fifo_wptr_gray <= {PTR_WIDTH {1'b0}};
		else if (fifo_incr_wptr)
			if (fifo_wptr[PTR_WIDTH - 2:0] == DepthMinus1)
				fifo_wptr_gray <= dec2gray({~fifo_wptr[PTR_WIDTH - 1], {PTR_WIDTH - 1 {1'b0}}});
			else
				fifo_wptr_gray <= dec2gray(fifo_wptr + {{PTR_WIDTH - 1 {1'b0}}, 1'b1});
	prim_generic_flop_2sync #(.Width(PTR_WIDTH)) sync_wptr(
		.clk_i(clk_rd_i),
		.rst_ni(rst_rd_ni),
		.d_i(fifo_wptr_gray),
		.q_o(fifo_wptr_gray_sync)
	);
	function automatic [PTR_WIDTH - 1:0] gray2dec;
		input reg [PTR_WIDTH - 1:0] grayval;
		reg [PTR_WIDTH - 2:0] dec_tmp;
		reg [PTR_WIDTH - 2:0] dec_tmp_sub;
		reg unused_decsub_msb;
		begin
			dec_tmp[PTR_WIDTH - 2] = grayval[PTR_WIDTH - 2];
			begin : sv2v_autoblock_74
				reg signed [31:0] i;
				for (i = PTR_WIDTH - 3; i >= 0; i = i - 1)
					dec_tmp[i] = dec_tmp[i + 1] ^ grayval[i];
			end
			{unused_decsub_msb, dec_tmp_sub} = (Depth - {1'b0, dec_tmp}) - 1'b1;
			if (grayval[PTR_WIDTH - 1])
				gray2dec = {1'b1, dec_tmp_sub};
			else
				gray2dec = {1'b0, dec_tmp};
		end
	endfunction
	assign fifo_wptr_sync_combi = gray2dec(fifo_wptr_gray_sync);
	always @(posedge clk_rd_i or negedge rst_rd_ni)
		if (!rst_rd_ni)
			fifo_rptr <= {PTR_WIDTH {1'b0}};
		else if (fifo_incr_rptr)
			if (fifo_rptr[PTR_WIDTH - 2:0] == DepthMinus1)
				fifo_rptr <= {~fifo_rptr[PTR_WIDTH - 1], {PTR_WIDTH - 1 {1'b0}}};
			else
				fifo_rptr <= fifo_rptr + {{PTR_WIDTH - 1 {1'b0}}, 1'b1};
	always @(posedge clk_rd_i or negedge rst_rd_ni)
		if (!rst_rd_ni)
			fifo_rptr_gray <= {PTR_WIDTH {1'b0}};
		else if (fifo_incr_rptr)
			if (fifo_rptr[PTR_WIDTH - 2:0] == DepthMinus1)
				fifo_rptr_gray <= dec2gray({~fifo_rptr[PTR_WIDTH - 1], {PTR_WIDTH - 1 {1'b0}}});
			else
				fifo_rptr_gray <= dec2gray(fifo_rptr + {{PTR_WIDTH - 1 {1'b0}}, 1'b1});
	prim_generic_flop_2sync #(.Width(PTR_WIDTH)) sync_rptr(
		.clk_i(clk_wr_i),
		.rst_ni(rst_wr_ni),
		.d_i(fifo_rptr_gray),
		.q_o(fifo_rptr_gray_sync)
	);
	always @(posedge clk_wr_i or negedge rst_wr_ni)
		if (!rst_wr_ni)
			fifo_rptr_sync <= {PTR_WIDTH {1'b0}};
		else
			fifo_rptr_sync <= gray2dec(fifo_rptr_gray_sync);
	assign full_wclk = fifo_wptr == (fifo_rptr_sync ^ {1'b1, {PTR_WIDTH - 1 {1'b0}}});
	assign full_rclk = fifo_wptr_sync_combi == (fifo_rptr ^ {1'b1, {PTR_WIDTH - 1 {1'b0}}});
	wire wptr_msb;
	wire rptr_sync_msb;
	wire [PTRV_W - 1:0] wptr_value;
	wire [PTRV_W - 1:0] rptr_sync_value;
	assign wptr_msb = fifo_wptr[PTR_WIDTH - 1];
	assign rptr_sync_msb = fifo_rptr_sync[PTR_WIDTH - 1];
	assign wptr_value = fifo_wptr[0+:PTRV_W];
	assign rptr_sync_value = fifo_rptr_sync[0+:PTRV_W];
	function automatic [DepthW - 1:0] sv2v_cast_37EEB_unsigned;
		input reg [DepthW - 1:0] inp;
		sv2v_cast_37EEB_unsigned = inp;
	endfunction
	function automatic [DepthW - 1:0] sv2v_cast_37EEB;
		input reg [DepthW - 1:0] inp;
		sv2v_cast_37EEB = inp;
	endfunction
	assign wdepth_o = (full_wclk ? sv2v_cast_37EEB_unsigned(Depth) : (wptr_msb == rptr_sync_msb ? sv2v_cast_37EEB(wptr_value) - sv2v_cast_37EEB(rptr_sync_value) : (sv2v_cast_37EEB_unsigned(Depth) - sv2v_cast_37EEB(rptr_sync_value)) + sv2v_cast_37EEB(wptr_value)));
	assign empty = fifo_wptr_sync_combi == fifo_rptr;
	wire rptr_msb;
	wire wptr_sync_msb;
	wire [PTRV_W - 1:0] rptr_value;
	wire [PTRV_W - 1:0] wptr_sync_value;
	assign wptr_sync_msb = fifo_wptr_sync_combi[PTR_WIDTH - 1];
	assign rptr_msb = fifo_rptr[PTR_WIDTH - 1];
	assign wptr_sync_value = fifo_wptr_sync_combi[0+:PTRV_W];
	assign rptr_value = fifo_rptr[0+:PTRV_W];
	assign rdepth_o = (full_rclk ? sv2v_cast_37EEB_unsigned(Depth) : (wptr_sync_msb == rptr_msb ? sv2v_cast_37EEB(wptr_sync_value) - sv2v_cast_37EEB(rptr_value) : (sv2v_cast_37EEB_unsigned(Depth) - sv2v_cast_37EEB(rptr_value)) + sv2v_cast_37EEB(wptr_sync_value)));
	reg [Width - 1:0] storage [0:Depth - 1];
	always @(posedge clk_wr_i)
		if (fifo_incr_wptr)
			storage[fifo_wptr[PTR_WIDTH - 2:0]] <= wdata_i;
	assign rdata_o = storage[fifo_rptr[PTR_WIDTH - 2:0]];
endmodule
module prim_fifo_sync (
	clk_i,
	rst_ni,
	clr_i,
	wvalid_i,
	wready_o,
	wdata_i,
	rvalid_o,
	rready_i,
	rdata_o,
	depth_o
);
	parameter [31:0] Width = 16;
	parameter [0:0] Pass = 1'b1;
	parameter [31:0] Depth = 4;
	parameter [0:0] OutputZeroIfEmpty = 1'b1;
	function automatic integer prim_util_pkg_vbits;
		input integer value;
		prim_util_pkg_vbits = (value == 1 ? 1 : $clog2(value));
	endfunction
	localparam signed [31:0] DepthW = prim_util_pkg_vbits(Depth + 1);
	input clk_i;
	input rst_ni;
	input clr_i;
	input wvalid_i;
	output wready_o;
	input [Width - 1:0] wdata_i;
	output rvalid_o;
	input rready_i;
	output [Width - 1:0] rdata_o;
	output [DepthW - 1:0] depth_o;
	generate
		if (Depth == 0) begin : gen_passthru_fifo
			assign depth_o = 1'b0;
			assign rvalid_o = wvalid_i;
			assign rdata_o = wdata_i;
			assign wready_o = rready_i;
			wire unused_clr;
			assign unused_clr = clr_i;
		end
		else begin : gen_normal_fifo
			localparam [31:0] PTRV_W = prim_util_pkg_vbits(Depth);
			localparam [31:0] PTR_WIDTH = PTRV_W + 1;
			reg [PTR_WIDTH - 1:0] fifo_wptr;
			reg [PTR_WIDTH - 1:0] fifo_rptr;
			wire fifo_incr_wptr;
			wire fifo_incr_rptr;
			wire fifo_empty;
			wire full;
			wire empty;
			wire wptr_msb;
			wire rptr_msb;
			wire [PTRV_W - 1:0] wptr_value;
			wire [PTRV_W - 1:0] rptr_value;
			assign wptr_msb = fifo_wptr[PTR_WIDTH - 1];
			assign rptr_msb = fifo_rptr[PTR_WIDTH - 1];
			assign wptr_value = fifo_wptr[0+:PTRV_W];
			assign rptr_value = fifo_rptr[0+:PTRV_W];
			function automatic [DepthW - 1:0] sv2v_cast_37EEB_unsigned;
				input reg [DepthW - 1:0] inp;
				sv2v_cast_37EEB_unsigned = inp;
			endfunction
			function automatic [DepthW - 1:0] sv2v_cast_37EEB;
				input reg [DepthW - 1:0] inp;
				sv2v_cast_37EEB = inp;
			endfunction
			assign depth_o = (full ? sv2v_cast_37EEB_unsigned(Depth) : (wptr_msb == rptr_msb ? sv2v_cast_37EEB(wptr_value) - sv2v_cast_37EEB(rptr_value) : (sv2v_cast_37EEB_unsigned(Depth) - sv2v_cast_37EEB(rptr_value)) + sv2v_cast_37EEB(wptr_value)));
			assign fifo_incr_wptr = wvalid_i & wready_o;
			assign fifo_incr_rptr = rvalid_o & rready_i;
			assign wready_o = ~full;
			assign rvalid_o = ~empty;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					fifo_wptr <= {PTR_WIDTH {1'b0}};
				else if (clr_i)
					fifo_wptr <= {PTR_WIDTH {1'b0}};
				else if (fifo_incr_wptr)
					if (fifo_wptr[PTR_WIDTH - 2:0] == (Depth - 1))
						fifo_wptr <= {~fifo_wptr[PTR_WIDTH - 1], {PTR_WIDTH - 1 {1'b0}}};
					else
						fifo_wptr <= fifo_wptr + {{PTR_WIDTH - 1 {1'b0}}, 1'b1};
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					fifo_rptr <= {PTR_WIDTH {1'b0}};
				else if (clr_i)
					fifo_rptr <= {PTR_WIDTH {1'b0}};
				else if (fifo_incr_rptr)
					if (fifo_rptr[PTR_WIDTH - 2:0] == (Depth - 1))
						fifo_rptr <= {~fifo_rptr[PTR_WIDTH - 1], {PTR_WIDTH - 1 {1'b0}}};
					else
						fifo_rptr <= fifo_rptr + {{PTR_WIDTH - 1 {1'b0}}, 1'b1};
			assign full = fifo_wptr == (fifo_rptr ^ {1'b1, {PTR_WIDTH - 1 {1'b0}}});
			assign fifo_empty = fifo_wptr == fifo_rptr;
			reg [(Depth * Width) - 1:0] storage;
			wire [Width - 1:0] storage_rdata;
			if (Depth == 1) begin : gen_depth_eq1
				assign storage_rdata = storage[0+:Width];
				always @(posedge clk_i)
					if (fifo_incr_wptr)
						storage[0+:Width] <= wdata_i;
			end
			else begin : gen_depth_gt1
				assign storage_rdata = storage[fifo_rptr[PTR_WIDTH - 2:0] * Width+:Width];
				always @(posedge clk_i)
					if (fifo_incr_wptr)
						storage[fifo_wptr[PTR_WIDTH - 2:0] * Width+:Width] <= wdata_i;
			end
			wire [Width - 1:0] rdata_int;
			if (Pass == 1'b1) begin : gen_pass
				assign rdata_int = (fifo_empty && wvalid_i ? wdata_i : storage_rdata);
				assign empty = fifo_empty & ~wvalid_i;
			end
			else begin : gen_nopass
				assign rdata_int = storage_rdata;
				assign empty = fifo_empty;
			end
			if (OutputZeroIfEmpty == 1'b1) begin : gen_output_zero
				assign rdata_o = (empty ? 'b0 : rdata_int);
			end
			else begin : gen_no_output_zero
				assign rdata_o = rdata_int;
			end
		end
	endgenerate
endmodule
module prim_filter_ctr (
	clk_i,
	rst_ni,
	enable_i,
	filter_i,
	filter_o
);
	parameter [31:0] Cycles = 4;
	input clk_i;
	input rst_ni;
	input enable_i;
	input filter_i;
	output filter_o;
	localparam [31:0] CTR_WIDTH = $clog2(Cycles);
	function automatic [CTR_WIDTH - 1:0] sv2v_cast_AF84E_unsigned;
		input reg [CTR_WIDTH - 1:0] inp;
		sv2v_cast_AF84E_unsigned = inp;
	endfunction
	localparam [CTR_WIDTH - 1:0] CYCLESM1 = sv2v_cast_AF84E_unsigned(Cycles - 1);
	reg [CTR_WIDTH - 1:0] diff_ctr_q;
	wire [CTR_WIDTH - 1:0] diff_ctr_d;
	reg filter_q;
	reg stored_value_q;
	wire update_stored_value;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			filter_q <= 1'b0;
		else
			filter_q <= filter_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			stored_value_q <= 1'b0;
		else if (update_stored_value)
			stored_value_q <= filter_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			diff_ctr_q <= {CTR_WIDTH {1'b0}};
		else
			diff_ctr_q <= diff_ctr_d;
	assign diff_ctr_d = (filter_i != filter_q ? {CTR_WIDTH {1'sb0}} : (diff_ctr_q == CYCLESM1 ? CYCLESM1 : diff_ctr_q + 1'b1));
	assign update_stored_value = diff_ctr_d == CYCLESM1;
	assign filter_o = (enable_i ? stored_value_q : filter_i);
endmodule
module prim_generic_clock_gating (
	clk_i,
	en_i,
	test_en_i,
	clk_o
);
	input clk_i;
	input en_i;
	input test_en_i;
	output wire clk_o;
	reg en_latch;
	/*always @(clk_i or en_i or test_en_i)
		if (!clk_i)
			en_latch = en_i | test_en_i;
		//else
			//en_latch = 1;
	assign clk_o = en_latch & clk_i;*/
	sky130_fd_sc_hd__dlclkp_1 CG( .CLK(clk_i), .GCLK(clk_o), .GATE(en_i | test_en_i));
 /*sky130_fd_sc_hd__dlclkp cell_1 (
        .GCLK(clk_o),
        .GATE(en_i),
        .CLK(clk_i)
    );*/
endmodule

/*`ifndef SKY130_FD_SC_HD__UDP_DLATCH_P_V
`define SKY130_FD_SC_HD__UDP_DLATCH_P_V

`timescale 1ns / 1ps
//`default_nettype none

`ifdef NO_PRIMITIVES
//`include "./sky130_fd_sc_hd__udp_dlatch_p.blackbox.v"
`else
primitive sky130_fd_sc_hd__udp_dlatch$P (
    Q   ,
    D   ,
    GATE
);

    output Q   ;
    input  D   ;
    input  GATE;

    reg Q;

    table
     //  D  GATE :  Qt : Qt+1
         ?   0   :  ?  :  -    ; // hold
         0   1   :  ?  :  0    ; // pass 0
         1   1   :  ?  :  1    ; // pass 1
         0   x   :  0  :  0    ; // reduce pessimism
         1   x   :  1  :  1    ; // reduce pessimism
    endtable
endprimitive
`endif // NO_PRIMITIVES

`default_nettype wire
`endif  // SKY130_FD_SC_HD__UDP_DLATCH_P_V
*/

/*`ifndef SKY130_FD_SC_HD__DLCLKP_FUNCTIONAL_V
`define SKY130_FD_SC_HD__DLCLKP_FUNCTIONAL_V


`timescale 1ns / 1ps
//`default_nettype none

// Import user defined primitives.
//`include "../../models/udp_dlatch_p/sky130_fd_sc_hd__udp_dlatch_p.v"

`celldefine
module sky130_fd_sc_hd__dlclkp (
    GCLK,
    GATE,
    CLK
);

    // Module ports
    output GCLK;
    input  GATE;
    input  CLK ;

    // Local signals
    wire m0  ;
    wire clkn;

    //                            Name     Output  Other arguments
    not                           not0    (clkn  , CLK            );
    sky130_fd_sc_hd__udp_dlatch$P dlatch0 (m0    , GATE, clkn     );
    and                           and0    (GCLK  , m0, CLK        );

endmodule
`endcelldefine

`default_nettype wire
`endif  // SKY130_FD_SC_HD__DLCLKP_FUNCTIONAL_V
*/
module prim_generic_clock_inv (
	clk_i,
	scanmode_i,
	clk_no
);
	parameter [0:0] HasScanMode = 1'b1;
	input clk_i;
	input scanmode_i;
	output wire clk_no;
	generate
		if (HasScanMode) begin : gen_scan
			prim_generic_clock_mux2 i_dft_tck_mux(
				.clk0_i(~clk_i),
				.clk1_i(clk_i),
				.sel_i(scanmode_i),
				.clk_o(clk_no)
			);
		end
		else begin : gen_noscan
			wire unused_scanmode;
			assign unused_scanmode = scanmode_i;
			assign clk_no = ~clk_i;
		end
	endgenerate
endmodule
module prim_generic_clock_mux2 (
	clk0_i,
	clk1_i,
	sel_i,
	clk_o
);
	input clk0_i;
	input clk1_i;
	input sel_i;
	output wire clk_o;
	assign clk_o = (sel_i ? clk1_i : clk0_i);
endmodule
module prim_generic_flop (
	clk_i,
	rst_ni,
	d_i,
	q_o
);
	parameter signed [31:0] Width = 1;
	localparam signed [31:0] WidthSubOne = Width - 1;
	parameter [WidthSubOne:0] ResetValue = 0;
	input clk_i;
	input rst_ni;
	input [Width - 1:0] d_i;
	output reg [Width - 1:0] q_o;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			q_o <= ResetValue;
		else
			q_o <= d_i;
endmodule
module prim_generic_flop_2sync (
	clk_i,
	rst_ni,
	d_i,
	q_o
);
	parameter signed [31:0] Width = 16;
	localparam signed [31:0] WidthSubOne = Width - 1;
	parameter [WidthSubOne:0] ResetValue = 1'sb0;
	input clk_i;
	input rst_ni;
	input [Width - 1:0] d_i;
	output wire [Width - 1:0] q_o;
	wire [Width - 1:0] intq;
	prim_generic_flop #(
		.Width(Width),
		.ResetValue(ResetValue)
	) u_sync_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i(d_i),
		.q_o(intq)
	);
	prim_generic_flop #(
		.Width(Width),
		.ResetValue(ResetValue)
	) u_sync_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i(intq),
		.q_o(q_o)
	);
endmodule
module prim_intr_hw (
	clk_i,
	rst_ni,
	event_intr_i,
	reg2hw_intr_enable_q_i,
	reg2hw_intr_test_q_i,
	reg2hw_intr_test_qe_i,
	reg2hw_intr_state_q_i,
	hw2reg_intr_state_de_o,
	hw2reg_intr_state_d_o,
	intr_o
);
	parameter [31:0] Width = 1;
	parameter [0:0] FlopOutput = 1;
	input clk_i;
	input rst_ni;
	input [Width - 1:0] event_intr_i;
	input [Width - 1:0] reg2hw_intr_enable_q_i;
	input [Width - 1:0] reg2hw_intr_test_q_i;
	input reg2hw_intr_test_qe_i;
	input [Width - 1:0] reg2hw_intr_state_q_i;
	output hw2reg_intr_state_de_o;
	output [Width - 1:0] hw2reg_intr_state_d_o;
	output reg [Width - 1:0] intr_o;
	wire [Width - 1:0] new_event;
	assign new_event = ({Width {reg2hw_intr_test_qe_i}} & reg2hw_intr_test_q_i) | event_intr_i;
	assign hw2reg_intr_state_de_o = |new_event;
	assign hw2reg_intr_state_d_o = new_event | reg2hw_intr_state_q_i;
	generate
		if (FlopOutput == 1) begin : gen_flop_intr_output
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					intr_o <= 1'b0;
				else
					intr_o <= reg2hw_intr_state_q_i & reg2hw_intr_enable_q_i;
		end
		else begin : gen_intr_passthrough_output
			wire unused_clk;
			wire unused_rst_n;
			assign unused_clk = clk_i;
			assign unused_rst_n = rst_ni;
			always @(*) intr_o = reg2hw_intr_state_q_i & reg2hw_intr_enable_q_i;
		end
	endgenerate
endmodule
module prim_subreg (
	clk_i,
	rst_ni,
	we,
	wd,
	de,
	d,
	qe,
	q,
	qs
);
	parameter signed [31:0] DW = 32;
	parameter _sv2v_width_SWACCESS = 16;
	parameter [_sv2v_width_SWACCESS - 1:0] SWACCESS = "RW";
	parameter [DW - 1:0] RESVAL = 1'sb0;
	input clk_i;
	input rst_ni;
	input we;
	input [DW - 1:0] wd;
	input de;
	input [DW - 1:0] d;
	output reg qe;
	output reg [DW - 1:0] q;
	output wire [DW - 1:0] qs;
	wire wr_en;
	wire [DW - 1:0] wr_data;
	prim_subreg_arb #(
		.DW(DW),
		._sv2v_width_SWACCESS(_sv2v_width_SWACCESS),
		.SWACCESS(SWACCESS)
	) wr_en_data_arb(
		.we(we),
		.wd(wd),
		.de(de),
		.d(d),
		.q(q),
		.wr_en(wr_en),
		.wr_data(wr_data)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			qe <= 1'b0;
		else
			qe <= we;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			q <= RESVAL;
		else if (wr_en)
			q <= wr_data;
	assign qs = q;
endmodule
module prim_subreg_arb (
	we,
	wd,
	de,
	d,
	q,
	wr_en,
	wr_data
);
	parameter signed [31:0] DW = 32;
	parameter _sv2v_width_SWACCESS = 16;
	parameter [_sv2v_width_SWACCESS - 1:0] SWACCESS = "RW";
	input we;
	input [DW - 1:0] wd;
	input de;
	input [DW - 1:0] d;
	input [DW - 1:0] q;
	output wire wr_en;
	output wire [DW - 1:0] wr_data;
	generate
		if ((SWACCESS == "RW") || (SWACCESS == "WO")) begin : gen_w
			assign wr_en = we | de;
			assign wr_data = (we == 1'b1 ? wd : d);
			wire [DW - 1:0] unused_q;
			assign unused_q = q;
		end
		else if (SWACCESS == "RO") begin : gen_ro
			assign wr_en = de;
			assign wr_data = d;
			wire unused_we;
			wire [DW - 1:0] unused_wd;
			wire [DW - 1:0] unused_q;
			assign unused_we = we;
			assign unused_wd = wd;
			assign unused_q = q;
		end
		else if (SWACCESS == "W1S") begin : gen_w1s
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) | (we ? wd : {DW {1'sb0}});
		end
		else if (SWACCESS == "W1C") begin : gen_w1c
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) & (we ? ~wd : {DW {1'sb1}});
		end
		else if (SWACCESS == "W0C") begin : gen_w0c
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) & (we ? wd : {DW {1'sb1}});
		end
		else if (SWACCESS == "RC") begin : gen_rc
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) & (we ? {DW {1'sb0}} : {DW {1'sb1}});
			wire [DW - 1:0] unused_wd;
			assign unused_wd = wd;
		end
		else begin : gen_hw
			assign wr_en = de;
			assign wr_data = d;
			wire unused_we;
			wire [DW - 1:0] unused_wd;
			wire [DW - 1:0] unused_q;
			assign unused_we = we;
			assign unused_wd = wd;
			assign unused_q = q;
		end
	endgenerate
endmodule
module prim_subreg_ext (
	re,
	we,
	wd,
	d,
	qe,
	qre,
	q,
	qs
);
	parameter [31:0] DW = 32;
	input re;
	input we;
	input [DW - 1:0] wd;
	input [DW - 1:0] d;
	output wire qe;
	output wire qre;
	output wire [DW - 1:0] q;
	output wire [DW - 1:0] qs;
	assign qs = d;
	assign q = wd;
	assign qe = we;
	assign qre = re;
endmodule
module debug_rom (
	clk_i,
	req_i,
	addr_i,
	rdata_o
);
	input wire clk_i;
	input wire req_i;
	input wire [63:0] addr_i;
	output reg [63:0] rdata_o;
	localparam [31:0] RomSize = 19;
	wire [(RomSize * 64) - 1:0] mem = {64'h000000007b200073, 64'h7b2024737b302573, 64'h10852423f1402473, 64'ha85ff06f7b202473, 64'h7b30257310052223, 64'h001000737b202473, 64'h7b30257310052623, 64'h00c5151300c55513, 64'h00000517fd5ff06f, 64'hfa041ce300247413, 64'h4004440300a40433, 64'hf140247302041c63, 64'h0014741340044403, 64'h00a4043310852023, 64'hf140247300c51513, 64'h00c5551300000517, 64'h7b3510737b241073, 64'h0ff0000f04c0006f, 64'h07c0006f00c0006f};
	reg [4:0] addr_q;
	always @(posedge clk_i)
		if (req_i)
			addr_q <= addr_i[7:3];
	function automatic [4:0] sv2v_cast_5_unsigned;
		input reg [4:0] inp;
		sv2v_cast_5_unsigned = inp;
	endfunction
	always @(*) begin : p_outmux
		rdata_o = {64 {1'sb0}};
		if (addr_q < sv2v_cast_5_unsigned(RomSize))
			rdata_o = mem[addr_q * 64+:64];
	end
endmodule
module dm_csrs (
	clk_i,
	rst_ni,
	testmode_i,
	dmi_rst_ni,
	dmi_req_valid_i,
	dmi_req_ready_o,
	dmi_req_i,
	dmi_resp_valid_o,
	dmi_resp_ready_i,
	dmi_resp_o,
	ndmreset_o,
	dmactive_o,
	hartinfo_i,
	halted_i,
	unavailable_i,
	resumeack_i,
	hartsel_o,
	haltreq_o,
	resumereq_o,
	clear_resumeack_o,
	cmd_valid_o,
	cmd_o,
	cmderror_valid_i,
	cmderror_i,
	cmdbusy_i,
	progbuf_o,
	data_o,
	data_i,
	data_valid_i,
	sbaddress_o,
	sbaddress_i,
	sbaddress_write_valid_o,
	sbreadonaddr_o,
	sbautoincrement_o,
	sbaccess_o,
	sbreadondata_o,
	sbdata_o,
	sbdata_read_valid_o,
	sbdata_write_valid_o,
	sbdata_i,
	sbdata_valid_i,
	sbbusy_i,
	sberror_valid_i,
	sberror_i
);
	parameter [31:0] NrHarts = 1;
	parameter [31:0] BusWidth = 32;
	parameter [NrHarts - 1:0] SelectableHarts = {NrHarts {1'b1}};
	input wire clk_i;
	input wire rst_ni;
	input wire testmode_i;
	input wire dmi_rst_ni;
	input wire dmi_req_valid_i;
	output wire dmi_req_ready_o;
	input wire [40:0] dmi_req_i;
	output wire dmi_resp_valid_o;
	input wire dmi_resp_ready_i;
	output wire [33:0] dmi_resp_o;
	output wire ndmreset_o;
	output wire dmactive_o;
	input wire [(NrHarts * 32) - 1:0] hartinfo_i;
	input wire [NrHarts - 1:0] halted_i;
	input wire [NrHarts - 1:0] unavailable_i;
	input wire [NrHarts - 1:0] resumeack_i;
	output wire [19:0] hartsel_o;
	output reg [NrHarts - 1:0] haltreq_o;
	output reg [NrHarts - 1:0] resumereq_o;
	output reg clear_resumeack_o;
	output wire cmd_valid_o;
	output wire [31:0] cmd_o;
	input wire cmderror_valid_i;
	input wire [2:0] cmderror_i;
	input wire cmdbusy_i;
	localparam [4:0] dm_ProgBufSize = 5'h08;
	output wire [(dm_ProgBufSize * 32) - 1:0] progbuf_o;
	localparam [3:0] dm_DataCount = 4'h2;
	output wire [(dm_DataCount * 32) - 1:0] data_o;
	input wire [(dm_DataCount * 32) - 1:0] data_i;
	input wire data_valid_i;
	output wire [BusWidth - 1:0] sbaddress_o;
	input wire [BusWidth - 1:0] sbaddress_i;
	output reg sbaddress_write_valid_o;
	output wire sbreadonaddr_o;
	output wire sbautoincrement_o;
	output wire [2:0] sbaccess_o;
	output wire sbreadondata_o;
	output wire [BusWidth - 1:0] sbdata_o;
	output reg sbdata_read_valid_o;
	output reg sbdata_write_valid_o;
	input wire [BusWidth - 1:0] sbdata_i;
	input wire sbdata_valid_i;
	input wire sbbusy_i;
	input wire sberror_valid_i;
	input wire [2:0] sberror_i;
	localparam [31:0] HartSelLen = (NrHarts == 1 ? 1 : $clog2(NrHarts));
	localparam [31:0] NrHartsAligned = 2 ** HartSelLen;
	wire [1:0] dtm_op;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	assign dtm_op = sv2v_cast_2(dmi_req_i[33-:2]);
	reg [31:0] resp_queue_data;
	localparam [7:0] dm_Data0 = 8'h04;
	function automatic [7:0] sv2v_cast_8;
		input reg [7:0] inp;
		sv2v_cast_8 = inp;
	endfunction
	localparam [7:0] DataEnd = sv2v_cast_8((dm_Data0 + {4'b0000, dm_DataCount}) - 8'h01);
	localparam [7:0] dm_ProgBuf0 = 8'h20;
	localparam [7:0] ProgBufEnd = sv2v_cast_8((dm_ProgBuf0 + {4'b0000, dm_ProgBufSize}) - 8'h01);
	reg [31:0] haltsum0;
	reg [31:0] haltsum1;
	reg [31:0] haltsum2;
	reg [31:0] haltsum3;
	reg [((((NrHarts - 1) / 32) + 1) * 32) - 1:0] halted;
	reg [(((NrHarts - 1) / 32) >= 0 ? ((((NrHarts - 1) / 32) + 1) * 32) - 1 : ((1 - ((NrHarts - 1) / 32)) * 32) + ((((NrHarts - 1) / 32) * 32) - 1)):(((NrHarts - 1) / 32) >= 0 ? 0 : ((NrHarts - 1) / 32) * 32)] halted_reshaped0;
	reg [(((NrHarts - 1) / 1024) >= 0 ? ((((NrHarts - 1) / 1024) + 1) * 32) - 1 : ((1 - ((NrHarts - 1) / 1024)) * 32) + ((((NrHarts - 1) / 1024) * 32) - 1)):(((NrHarts - 1) / 1024) >= 0 ? 0 : ((NrHarts - 1) / 1024) * 32)] halted_reshaped1;
	reg [(((NrHarts - 1) / 32768) >= 0 ? ((((NrHarts - 1) / 32768) + 1) * 32) - 1 : ((1 - ((NrHarts - 1) / 32768)) * 32) + ((((NrHarts - 1) / 32768) * 32) - 1)):(((NrHarts - 1) / 32768) >= 0 ? 0 : ((NrHarts - 1) / 32768) * 32)] halted_reshaped2;
	reg [((((NrHarts - 1) / 1024) + 1) * 32) - 1:0] halted_flat1;
	reg [((((NrHarts - 1) / 32768) + 1) * 32) - 1:0] halted_flat2;
	reg [31:0] halted_flat3;
	reg [14:0] hartsel_idx0;
	function automatic [14:0] sv2v_cast_15_unsigned;
		input reg [14:0] inp;
		sv2v_cast_15_unsigned = inp;
	endfunction
	always @(*) begin : p_haltsum0
		halted = {(((NrHarts - 1) / 32) + 1) * 32 {1'sb0}};
		haltsum0 = {32 {1'sb0}};
		hartsel_idx0 = hartsel_o[19:5];
		halted[NrHarts - 1:0] = halted_i;
		halted_reshaped0 = halted;
		if (hartsel_idx0 < sv2v_cast_15_unsigned(((NrHarts - 1) / 32) + 1))
			haltsum0 = halted_reshaped0[(((NrHarts - 1) / 32) >= 0 ? hartsel_idx0 : ((NrHarts - 1) / 32) - hartsel_idx0) * 32+:32];
	end
	reg [9:0] hartsel_idx1;
	function automatic [9:0] sv2v_cast_10_unsigned;
		input reg [9:0] inp;
		sv2v_cast_10_unsigned = inp;
	endfunction
	always @(*) begin : p_reduction1
		halted_flat1 = {(((NrHarts - 1) / 1024) + 1) * 32 {1'sb0}};
		haltsum1 = {32 {1'sb0}};
		hartsel_idx1 = hartsel_o[19:10];
		begin : sv2v_autoblock_75
			reg [31:0] k;
			for (k = 0; k < (((NrHarts - 1) / 32) + 1); k = k + 1)
				halted_flat1[k] = |halted_reshaped0[(((NrHarts - 1) / 32) >= 0 ? k : ((NrHarts - 1) / 32) - k) * 32+:32];
		end
		halted_reshaped1 = halted_flat1;
		if (hartsel_idx1 < sv2v_cast_10_unsigned(((NrHarts - 1) / 1024) + 1))
			haltsum1 = halted_reshaped1[(((NrHarts - 1) / 1024) >= 0 ? hartsel_idx1 : ((NrHarts - 1) / 1024) - hartsel_idx1) * 32+:32];
	end
	reg [4:0] hartsel_idx2;
	function automatic [4:0] sv2v_cast_5_unsigned;
		input reg [4:0] inp;
		sv2v_cast_5_unsigned = inp;
	endfunction
	always @(*) begin : p_reduction2
		halted_flat2 = {(((NrHarts - 1) / 32768) + 1) * 32 {1'sb0}};
		haltsum2 = {32 {1'sb0}};
		hartsel_idx2 = hartsel_o[19:15];
		begin : sv2v_autoblock_76
			reg [31:0] k;
			for (k = 0; k < (((NrHarts - 1) / 1024) + 1); k = k + 1)
				halted_flat2[k] = |halted_reshaped1[(((NrHarts - 1) / 1024) >= 0 ? k : ((NrHarts - 1) / 1024) - k) * 32+:32];
		end
		halted_reshaped2 = halted_flat2;
		if (hartsel_idx2 < sv2v_cast_5_unsigned(((NrHarts - 1) / 32768) + 1))
			haltsum2 = halted_reshaped2[(((NrHarts - 1) / 32768) >= 0 ? hartsel_idx2 : ((NrHarts - 1) / 32768) - hartsel_idx2) * 32+:32];
	end
	always @(*) begin : p_reduction3
		halted_flat3 = {32 {1'sb0}};
		begin : sv2v_autoblock_77
			reg [31:0] k;
			for (k = 0; k < ((NrHarts / 32768) + 1); k = k + 1)
				halted_flat3[k] = |halted_reshaped2[(((NrHarts - 1) / 32768) >= 0 ? k : ((NrHarts - 1) / 32768) - k) * 32+:32];
		end
		haltsum3 = halted_flat3;
	end
	reg [31:0] dmstatus;
	reg [31:0] dmcontrol_d;
	reg [31:0] dmcontrol_q;
	reg [31:0] abstractcs;
	reg [2:0] cmderr_d;
	reg [2:0] cmderr_q;
	reg [31:0] command_d;
	reg [31:0] command_q;
	reg cmd_valid_d;
	reg cmd_valid_q;
	reg [31:0] abstractauto_d;
	reg [31:0] abstractauto_q;
	reg [31:0] sbcs_d;
	reg [31:0] sbcs_q;
	reg [63:0] sbaddr_d;
	reg [63:0] sbaddr_q;
	reg [63:0] sbdata_d;
	reg [63:0] sbdata_q;
	wire [NrHarts - 1:0] havereset_d;
	reg [NrHarts - 1:0] havereset_q;
	reg [(dm_ProgBufSize * 32) - 1:0] progbuf_d;
	reg [(dm_ProgBufSize * 32) - 1:0] progbuf_q;
	reg [(dm_DataCount * 32) - 1:0] data_d;
	reg [(dm_DataCount * 32) - 1:0] data_q;
	reg [HartSelLen - 1:0] selected_hart;
	localparam [1:0] dm_DTM_SUCCESS = 2'h0;
	assign dmi_resp_o[1-:2] = dm_DTM_SUCCESS;
	assign sbautoincrement_o = sbcs_q[16];
	assign sbreadonaddr_o = sbcs_q[20];
	assign sbreadondata_o = sbcs_q[15];
	assign sbaccess_o = sbcs_q[19-:3];
	assign sbdata_o = sbdata_q[BusWidth - 1:0];
	assign sbaddress_o = sbaddr_q[BusWidth - 1:0];
	assign hartsel_o = {dmcontrol_q[15-:10], dmcontrol_q[25-:10]};
	reg [NrHartsAligned - 1:0] havereset_d_aligned;
	wire [NrHartsAligned - 1:0] havereset_q_aligned;
	wire [NrHartsAligned - 1:0] resumeack_aligned;
	wire [NrHartsAligned - 1:0] unavailable_aligned;
	wire [NrHartsAligned - 1:0] halted_aligned;
	function automatic [NrHartsAligned - 1:0] sv2v_cast_8FC1C;
		input reg [NrHartsAligned - 1:0] inp;
		sv2v_cast_8FC1C = inp;
	endfunction
	assign resumeack_aligned = sv2v_cast_8FC1C(resumeack_i);
	assign unavailable_aligned = sv2v_cast_8FC1C(unavailable_i);
	assign halted_aligned = sv2v_cast_8FC1C(halted_i);
	function automatic [NrHarts - 1:0] sv2v_cast_50608;
		input reg [NrHarts - 1:0] inp;
		sv2v_cast_50608 = inp;
	endfunction
	assign havereset_d = sv2v_cast_50608(havereset_d_aligned);
	assign havereset_q_aligned = sv2v_cast_8FC1C(havereset_q);
	reg [(NrHartsAligned * 32) - 1:0] hartinfo_aligned;
	always @(*) begin : p_hartinfo_align
		hartinfo_aligned = {NrHartsAligned * 32 {1'sb0}};
		hartinfo_aligned[32 * ((NrHarts - 1) - (NrHarts - 1))+:32 * NrHarts] = hartinfo_i;
	end
	reg [31:0] sbcs;
	reg [31:0] dmcontrol;
	reg [31:0] a_abstractcs;
	reg [4:0] autoexecdata_idx;
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	function automatic [63:0] sv2v_cast_64;
		input reg [63:0] inp;
		sv2v_cast_64 = inp;
	endfunction
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	function automatic [$clog2(4'h2) - 1:0] sv2v_cast_48325;
		input reg [$clog2(4'h2) - 1:0] inp;
		sv2v_cast_48325 = inp;
	endfunction
	function automatic [11:0] sv2v_cast_12;
		input reg [11:0] inp;
		sv2v_cast_12 = inp;
	endfunction
	function automatic [15:0] sv2v_cast_16;
		input reg [15:0] inp;
		sv2v_cast_16 = inp;
	endfunction
	localparam [7:0] dm_AbstractAuto = 8'h18;
	localparam [7:0] dm_AbstractCS = 8'h16;
	localparam [2:0] dm_CmdErrBusy = 1;
	localparam [2:0] dm_CmdErrNone = 0;
	localparam [7:0] dm_Command = 8'h17;
	localparam [7:0] dm_DMControl = 8'h10;
	localparam [7:0] dm_DMStatus = 8'h11;
	localparam [1:0] dm_DTM_READ = 2'h1;
	localparam [1:0] dm_DTM_WRITE = 2'h2;
	localparam [3:0] dm_DbgVersion013 = 4'h2;
	localparam [7:0] dm_HaltSum0 = 8'h40;
	localparam [7:0] dm_HaltSum1 = 8'h13;
	localparam [7:0] dm_HaltSum2 = 8'h34;
	localparam [7:0] dm_HaltSum3 = 8'h35;
	localparam [7:0] dm_Hartinfo = 8'h12;
	localparam [7:0] dm_SBAddress0 = 8'h39;
	localparam [7:0] dm_SBAddress1 = 8'h3a;
	localparam [7:0] dm_SBCS = 8'h38;
	localparam [7:0] dm_SBData0 = 8'h3c;
	localparam [7:0] dm_SBData1 = 8'h3d;
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [6:0] sv2v_cast_7;
		input reg [6:0] inp;
		sv2v_cast_7 = inp;
	endfunction
	always @(*) begin : csr_read_write
		dmstatus = {32 {1'sb0}};
		dmstatus[3-:4] = dm_DbgVersion013;
		dmstatus[7] = 1'b1;
		dmstatus[5] = 1'b0;
		dmstatus[19] = havereset_q_aligned[selected_hart];
		dmstatus[18] = havereset_q_aligned[selected_hart];
		dmstatus[17] = resumeack_aligned[selected_hart];
		dmstatus[16] = resumeack_aligned[selected_hart];
		dmstatus[13] = unavailable_aligned[selected_hart];
		dmstatus[12] = unavailable_aligned[selected_hart];
		dmstatus[15] = sv2v_cast_1(sv2v_cast_32(hartsel_o) > (NrHarts - 1));
		dmstatus[14] = sv2v_cast_1(sv2v_cast_32(hartsel_o) > (NrHarts - 1));
		dmstatus[9] = halted_aligned[selected_hart] & ~unavailable_aligned[selected_hart];
		dmstatus[8] = halted_aligned[selected_hart] & ~unavailable_aligned[selected_hart];
		dmstatus[11] = ~halted_aligned[selected_hart] & ~unavailable_aligned[selected_hart];
		dmstatus[10] = ~halted_aligned[selected_hart] & ~unavailable_aligned[selected_hart];
		abstractcs = {32 {1'sb0}};
		abstractcs[3-:4] = dm_DataCount;
		abstractcs[28-:5] = dm_ProgBufSize;
		abstractcs[12] = cmdbusy_i;
		abstractcs[10-:3] = cmderr_q;
		abstractauto_d = abstractauto_q;
		abstractauto_d[15-:4] = {4 {1'sb0}};
		havereset_d_aligned = sv2v_cast_8FC1C(havereset_q);
		dmcontrol_d = dmcontrol_q;
		cmderr_d = cmderr_q;
		command_d = command_q;
		progbuf_d = progbuf_q;
		data_d = data_q;
		sbcs_d = sbcs_q;
		sbaddr_d = sv2v_cast_64(sbaddress_i);
		sbdata_d = sbdata_q;
		resp_queue_data = 32'b00000000000000000000000000000000;
		cmd_valid_d = 1'b0;
		sbaddress_write_valid_o = 1'b0;
		sbdata_read_valid_o = 1'b0;
		sbdata_write_valid_o = 1'b0;
		clear_resumeack_o = 1'b0;
		sbcs = {32 {1'sb0}};
		dmcontrol = {32 {1'sb0}};
		a_abstractcs = {32 {1'sb0}};
		autoexecdata_idx = dmi_req_i[38:34] - sv2v_cast_5(dm_Data0);
		if ((dmi_req_ready_o && dmi_req_valid_i) && (dtm_op == dm_DTM_READ))
			if ((dm_Data0 <= {1'b0, dmi_req_i[40-:7]}) && (DataEnd >= {1'b0, dmi_req_i[40-:7]})) begin
				resp_queue_data = data_q[sv2v_cast_48325(autoexecdata_idx) * 32+:32];
				if (!cmdbusy_i)
					if (autoexecdata_idx < 12)
						cmd_valid_d = abstractauto_q[autoexecdata_idx];
			end
			else if ({1'b0, dmi_req_i[40-:7]} == dm_DMControl)
				resp_queue_data = dmcontrol_q;
			else if ({1'b0, dmi_req_i[40-:7]} == dm_DMStatus)
				resp_queue_data = dmstatus;
			else if ({1'b0, dmi_req_i[40-:7]} == dm_Hartinfo)
				resp_queue_data = hartinfo_aligned[selected_hart * 32+:32];
			else if ({1'b0, dmi_req_i[40-:7]} == dm_AbstractCS)
				resp_queue_data = abstractcs;
			else if ({1'b0, dmi_req_i[40-:7]} == dm_AbstractAuto)
				resp_queue_data = abstractauto_q;
			else if ({1'b0, dmi_req_i[40-:7]} == dm_Command)
				resp_queue_data = {32 {1'sb0}};
			else if ((dm_ProgBuf0 <= {1'b0, dmi_req_i[40-:7]}) && (ProgBufEnd >= {1'b0, dmi_req_i[40-:7]})) begin
				resp_queue_data = progbuf_q[dmi_req_i[$clog2(5'h08) + 33:34] * 32+:32];
				if (!cmdbusy_i)
					cmd_valid_d = abstractauto_q[{1'b1, dmi_req_i[37:34]}];
			end
			else if ({1'b0, dmi_req_i[40-:7]} == dm_HaltSum0)
				resp_queue_data = haltsum0;
			else if ({1'b0, dmi_req_i[40-:7]} == dm_HaltSum1)
				resp_queue_data = haltsum1;
			else if ({1'b0, dmi_req_i[40-:7]} == dm_HaltSum2)
				resp_queue_data = haltsum2;
			else if ({1'b0, dmi_req_i[40-:7]} == dm_HaltSum3)
				resp_queue_data = haltsum3;
			else if ({1'b0, dmi_req_i[40-:7]} == dm_SBCS)
				resp_queue_data = sbcs_q;
			else if ({1'b0, dmi_req_i[40-:7]} == dm_SBAddress0) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else
					resp_queue_data = sbaddr_q[31:0];
			end
			else if ({1'b0, dmi_req_i[40-:7]} == dm_SBAddress1) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else
					resp_queue_data = sbaddr_q[63:32];
			end
			else if ({1'b0, dmi_req_i[40-:7]} == dm_SBData0) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else begin
					sbdata_read_valid_o = sbcs_q[14-:3] == {3 {1'sb0}};
					resp_queue_data = sbdata_q[31:0];
				end
			end
			else if ({1'b0, dmi_req_i[40-:7]} == dm_SBData1)
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else
					resp_queue_data = sbdata_q[63:32];
		if ((dmi_req_ready_o && dmi_req_valid_i) && (dtm_op == dm_DTM_WRITE))
			if ((dm_Data0 <= sv2v_cast_8({1'b0, dmi_req_i[40-:7]})) && (DataEnd >= sv2v_cast_8({1'b0, dmi_req_i[40-:7]}))) begin
				if (!cmdbusy_i && (dm_DataCount > 0)) begin
					data_d[dmi_req_i[$clog2(4'h2) + 33:34] * 32+:32] = dmi_req_i[31-:32];
					if (autoexecdata_idx < 12)
						cmd_valid_d = abstractauto_q[autoexecdata_idx];
				end
			end
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_DMControl) begin
				dmcontrol = sv2v_cast_32(dmi_req_i[31-:32]);
				if (dmcontrol[28])
					havereset_d_aligned[selected_hart] = 1'b0;
				dmcontrol_d = dmi_req_i[31-:32];
			end
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_DMStatus)
				;
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_Hartinfo)
				;
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_AbstractCS) begin
				a_abstractcs = sv2v_cast_32(dmi_req_i[31-:32]);
				if (!cmdbusy_i)
					cmderr_d = sv2v_cast_3(~a_abstractcs[10-:3] & cmderr_q);
				else if (cmderr_q == dm_CmdErrNone)
					cmderr_d = dm_CmdErrBusy;
			end
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_Command) begin
				if (!cmdbusy_i) begin
					cmd_valid_d = 1'b1;
					command_d = sv2v_cast_32(dmi_req_i[31-:32]);
				end
				else if (cmderr_q == dm_CmdErrNone)
					cmderr_d = dm_CmdErrBusy;
			end
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_AbstractAuto) begin
				if (!cmdbusy_i) begin
					abstractauto_d = 32'b00000000000000000000000000000000;
					abstractauto_d[11-:12] = sv2v_cast_12(dmi_req_i[dm_DataCount - 1:0]);
					abstractauto_d[31-:16] = sv2v_cast_16(dmi_req_i[dm_ProgBufSize + 15:16]);
				end
				else if (cmderr_q == dm_CmdErrNone)
					cmderr_d = dm_CmdErrBusy;
			end
			else if ((dm_ProgBuf0 <= sv2v_cast_8({1'b0, dmi_req_i[40-:7]})) && (ProgBufEnd >= sv2v_cast_8({1'b0, dmi_req_i[40-:7]}))) begin
				if (!cmdbusy_i) begin
					progbuf_d[dmi_req_i[$clog2(5'h08) + 33:34] * 32+:32] = dmi_req_i[31-:32];
					cmd_valid_d = abstractauto_q[{1'b1, dmi_req_i[37:34]}];
				end
			end
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_SBCS) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else begin
					sbcs = sv2v_cast_32(dmi_req_i[31-:32]);
					sbcs_d = sbcs;
					sbcs_d[22] = sbcs_q[22] & ~sbcs[22];
					sbcs_d[14-:3] = sbcs_q[14-:3] & ~sbcs[14-:3];
				end
			end
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_SBAddress0) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else begin
					sbaddr_d[31:0] = dmi_req_i[31-:32];
					sbaddress_write_valid_o = sbcs_q[14-:3] == {3 {1'sb0}};
				end
			end
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_SBAddress1) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else
					sbaddr_d[63:32] = dmi_req_i[31-:32];
			end
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_SBData0) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else begin
					sbdata_d[31:0] = dmi_req_i[31-:32];
					sbdata_write_valid_o = sbcs_q[14-:3] == {3 {1'sb0}};
				end
			end
			else if (sv2v_cast_8({1'b0, dmi_req_i[40-:7]}) == dm_SBData1)
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else
					sbdata_d[63:32] = dmi_req_i[31-:32];
		if (cmderror_valid_i)
			cmderr_d = cmderror_i;
		if (data_valid_i)
			data_d = data_i;
		if (ndmreset_o)
			havereset_d_aligned[NrHarts - 1:0] = {NrHarts {1'sb1}};
		if (sberror_valid_i)
			sbcs_d[14-:3] = sberror_i;
		if (sbdata_valid_i)
			sbdata_d = sv2v_cast_64(sbdata_i);
		dmcontrol_d[26] = 1'b0;
		dmcontrol_d[29] = 1'b0;
		dmcontrol_d[3] = 1'b0;
		dmcontrol_d[2] = 1'b0;
		dmcontrol_d[27] = 1'sb0;
		dmcontrol_d[5-:2] = {2 {1'sb0}};
		dmcontrol_d[28] = 1'b0;
		if (!dmcontrol_q[30] && dmcontrol_d[30])
			clear_resumeack_o = 1'b1;
		if (dmcontrol_q[30] && resumeack_i)
			dmcontrol_d[30] = 1'b0;
		sbcs_d[31-:3] = 3'd1;
		sbcs_d[21] = sbbusy_i;
		sbcs_d[11-:7] = sv2v_cast_7(BusWidth);
		sbcs_d[4] = 1'b0;
		sbcs_d[3] = sv2v_cast_1(BusWidth == 32'd64);
		sbcs_d[2] = sv2v_cast_1(BusWidth == 32'd32);
		sbcs_d[1] = 1'b0;
		sbcs_d[0] = 1'b0;
		sbcs_d[19-:3] = (BusWidth == 32'd64 ? 3'd3 : 3'd2);
	end
	function automatic [HartSelLen:0] sv2v_cast_7DE8E_unsigned;
		input reg [HartSelLen:0] inp;
		sv2v_cast_7DE8E_unsigned = inp;
	endfunction
	always @(*) begin : p_outmux
		selected_hart = hartsel_o[HartSelLen - 1:0];
		haltreq_o = {NrHarts {1'sb0}};
		resumereq_o = {NrHarts {1'sb0}};
		if (selected_hart < sv2v_cast_7DE8E_unsigned(NrHarts)) begin
			haltreq_o[selected_hart] = dmcontrol_q[31];
			resumereq_o[selected_hart] = dmcontrol_q[30];
		end
	end
	assign dmactive_o = dmcontrol_q[0];
	assign cmd_o = command_q;
	assign cmd_valid_o = cmd_valid_q;
	assign progbuf_o = progbuf_q;
	assign data_o = data_q;
	assign ndmreset_o = dmcontrol_q[1];
	wire unused_testmode;
	assign unused_testmode = testmode_i;
	prim_fifo_sync #(
		.Width(32),
		.Pass(1'b0),
		.Depth(2)
	) i_fifo(
		.clk_i(clk_i),
		.rst_ni(dmi_rst_ni),
		.clr_i(1'b0),
		.wdata_i(resp_queue_data),
		.wvalid_i(dmi_req_valid_i),
		.wready_o(dmi_req_ready_o),
		.rdata_o(dmi_resp_o[33-:32]),
		.rvalid_o(dmi_resp_valid_o),
		.rready_i(dmi_resp_ready_i),
		.depth_o()
	);
	always @(posedge clk_i or negedge rst_ni) begin : p_regs
		if (!rst_ni) begin
			dmcontrol_q <= {32 {1'sb0}};
			cmderr_q <= dm_CmdErrNone;
			command_q <= {32 {1'sb0}};
			cmd_valid_q <= 1'sb0;
			abstractauto_q <= {32 {1'sb0}};
			progbuf_q <= {dm_ProgBufSize * 32 {1'sb0}};
			data_q <= {dm_DataCount * 32 {1'sb0}};
			sbcs_q <= {32 {1'sb0}};
			sbaddr_q <= {64 {1'sb0}};
			sbdata_q <= {64 {1'sb0}};
			havereset_q <= {NrHarts {1'sb1}};
		end
		else begin
			havereset_q <= SelectableHarts & havereset_d;
			if (!dmcontrol_q[0]) begin
				dmcontrol_q[31] <= 1'sb0;
				dmcontrol_q[30] <= 1'sb0;
				dmcontrol_q[29] <= 1'sb0;
				dmcontrol_q[28] <= 1'sb0;
				dmcontrol_q[27] <= 1'sb0;
				dmcontrol_q[26] <= 1'sb0;
				dmcontrol_q[25-:10] <= {10 {1'sb0}};
				dmcontrol_q[15-:10] <= {10 {1'sb0}};
				dmcontrol_q[5-:2] <= {2 {1'sb0}};
				dmcontrol_q[3] <= 1'sb0;
				dmcontrol_q[2] <= 1'sb0;
				dmcontrol_q[1] <= 1'sb0;
				dmcontrol_q[0] <= dmcontrol_d[0];
				cmderr_q <= dm_CmdErrNone;
				command_q <= {32 {1'sb0}};
				cmd_valid_q <= 1'sb0;
				abstractauto_q <= {32 {1'sb0}};
				progbuf_q <= {dm_ProgBufSize * 32 {1'sb0}};
				data_q <= {dm_DataCount * 32 {1'sb0}};
				sbcs_q <= {32 {1'sb0}};
				sbaddr_q <= {64 {1'sb0}};
				sbdata_q <= {64 {1'sb0}};
			end
			else begin
				dmcontrol_q <= dmcontrol_d;
				cmderr_q <= cmderr_d;
				command_q <= command_d;
				cmd_valid_q <= cmd_valid_d;
				abstractauto_q <= abstractauto_d;
				progbuf_q <= progbuf_d;
				data_q <= data_d;
				sbcs_q <= sbcs_d;
				sbaddr_q <= sbaddr_d;
				sbdata_q <= sbdata_d;
			end
		end
	end
endmodule
module dm_mem (
	clk_i,
	rst_ni,
	debug_req_o,
	hartsel_i,
	haltreq_i,
	resumereq_i,
	clear_resumeack_i,
	halted_o,
	resuming_o,
	progbuf_i,
	data_i,
	data_o,
	data_valid_o,
	cmd_valid_i,
	cmd_i,
	cmderror_valid_o,
	cmderror_o,
	cmdbusy_o,
	req_i,
	we_i,
	addr_i,
	wdata_i,
	be_i,
	rdata_o
);
	parameter [31:0] NrHarts = 1;
	parameter [31:0] BusWidth = 32;
	parameter [NrHarts - 1:0] SelectableHarts = {NrHarts {1'b1}};
	parameter [31:0] DmBaseAddress = 1'sb0;
	input wire clk_i;
	input wire rst_ni;
	output wire [NrHarts - 1:0] debug_req_o;
	input wire [19:0] hartsel_i;
	input wire [NrHarts - 1:0] haltreq_i;
	input wire [NrHarts - 1:0] resumereq_i;
	input wire clear_resumeack_i;
	output wire [NrHarts - 1:0] halted_o;
	output wire [NrHarts - 1:0] resuming_o;
	localparam [4:0] dm_ProgBufSize = 5'h08;
	input wire [(dm_ProgBufSize * 32) - 1:0] progbuf_i;
	localparam [3:0] dm_DataCount = 4'h2;
	input wire [(dm_DataCount * 32) - 1:0] data_i;
	output reg [(dm_DataCount * 32) - 1:0] data_o;
	output reg data_valid_o;
	input wire cmd_valid_i;
	input wire [31:0] cmd_i;
	output reg cmderror_valid_o;
	output reg [2:0] cmderror_o;
	output reg cmdbusy_o;
	input wire req_i;
	input wire we_i;
	input wire [BusWidth - 1:0] addr_i;
	input wire [BusWidth - 1:0] wdata_i;
	input wire [(BusWidth / 8) - 1:0] be_i;
	output wire [BusWidth - 1:0] rdata_o;
	localparam [31:0] DbgAddressBits = 12;
	localparam [31:0] HartSelLen = (NrHarts == 1 ? 1 : $clog2(NrHarts));
	localparam [31:0] NrHartsAligned = 2 ** HartSelLen;
	localparam [31:0] MaxAar = (BusWidth == 64 ? 4 : 3);
	localparam [0:0] HasSndScratch = DmBaseAddress != 0;
	localparam [4:0] LoadBaseAddr = (DmBaseAddress == 0 ? 5'd0 : 5'd10);
	localparam [11:0] dm_DataAddr = 12'h380;
	localparam [DbgAddressBits - 1:0] DataBaseAddr = dm_DataAddr;
	localparam [DbgAddressBits - 1:0] DataEndAddr = (dm_DataAddr + (4 * dm_DataCount)) - 1;
	localparam [DbgAddressBits - 1:0] ProgBufBaseAddr = dm_DataAddr - (4 * dm_ProgBufSize);
	localparam [DbgAddressBits - 1:0] ProgBufEndAddr = dm_DataAddr - 1;
	localparam [DbgAddressBits - 1:0] AbstractCmdBaseAddr = ProgBufBaseAddr - 40;
	localparam [DbgAddressBits - 1:0] AbstractCmdEndAddr = ProgBufBaseAddr - 1;
	localparam [DbgAddressBits - 1:0] WhereToAddr = 'h300;
	localparam [DbgAddressBits - 1:0] FlagsBaseAddr = 'h400;
	localparam [DbgAddressBits - 1:0] FlagsEndAddr = 'h7ff;
	localparam [DbgAddressBits - 1:0] HaltedAddr = 'h100;
	localparam [DbgAddressBits - 1:0] GoingAddr = 'h104;
	localparam [DbgAddressBits - 1:0] ResumingAddr = 'h108;
	localparam [DbgAddressBits - 1:0] ExceptionAddr = 'h10c;
	wire [((dm_ProgBufSize / 2) * 64) - 1:0] progbuf;
	reg [511:0] abstract_cmd;
	wire [NrHarts - 1:0] halted_d;
	reg [NrHarts - 1:0] halted_q;
	wire [NrHarts - 1:0] resuming_d;
	reg [NrHarts - 1:0] resuming_q;
	reg resume;
	reg go;
	reg going;
	reg exception;
	reg unsupported_command;
	wire [63:0] rom_rdata;
	reg [63:0] rdata_d;
	reg [63:0] rdata_q;
	reg word_enable32_q;
	wire [HartSelLen - 1:0] hartsel;
	wire [HartSelLen - 1:0] wdata_hartsel;
	assign hartsel = hartsel_i[HartSelLen - 1:0];
	assign wdata_hartsel = wdata_i[HartSelLen - 1:0];
	wire [NrHartsAligned - 1:0] resumereq_aligned;
	wire [NrHartsAligned - 1:0] haltreq_aligned;
	reg [NrHartsAligned - 1:0] halted_d_aligned;
	wire [NrHartsAligned - 1:0] halted_q_aligned;
	reg [NrHartsAligned - 1:0] halted_aligned;
	wire [NrHartsAligned - 1:0] resumereq_wdata_aligned;
	reg [NrHartsAligned - 1:0] resuming_d_aligned;
	wire [NrHartsAligned - 1:0] resuming_q_aligned;
	function automatic [NrHartsAligned - 1:0] sv2v_cast_8FC1C;
		input reg [NrHartsAligned - 1:0] inp;
		sv2v_cast_8FC1C = inp;
	endfunction
	assign resumereq_aligned = sv2v_cast_8FC1C(resumereq_i);
	assign haltreq_aligned = sv2v_cast_8FC1C(haltreq_i);
	assign resumereq_wdata_aligned = sv2v_cast_8FC1C(resumereq_i);
	assign halted_q_aligned = sv2v_cast_8FC1C(halted_q);
	function automatic [NrHarts - 1:0] sv2v_cast_50608;
		input reg [NrHarts - 1:0] inp;
		sv2v_cast_50608 = inp;
	endfunction
	assign halted_d = sv2v_cast_50608(halted_d_aligned);
	assign resuming_q_aligned = sv2v_cast_8FC1C(resuming_q);
	assign resuming_d = sv2v_cast_50608(resuming_d_aligned);
	wire fwd_rom_d;
	reg fwd_rom_q;
	wire [23:0] ac_ar;
	function automatic [23:0] sv2v_cast_24;
		input reg [23:0] inp;
		sv2v_cast_24 = inp;
	endfunction
	assign ac_ar = sv2v_cast_24(cmd_i[23-:24]);
	assign debug_req_o = haltreq_i;
	assign halted_o = halted_q;
	assign resuming_o = resuming_q;
	assign progbuf = progbuf_i;
	reg [1:0] state_d;
	reg [1:0] state_q;
	localparam [1:0] CmdExecuting = 3;
	localparam [1:0] Go = 1;
	localparam [2:0] Idle = 0;
	localparam [1:0] Resume = 2;
	localparam [2:0] dm_CmdErrNone = 0;
	localparam [2:0] dm_CmdErrNotSupported = 2;
	localparam [2:0] dm_CmdErrorException = 3;
	localparam [2:0] dm_CmdErrorHaltResume = 4;
	always @(*) begin : p_hart_ctrl_queue
		cmderror_valid_o = 1'b0;
		cmderror_o = dm_CmdErrNone;
		state_d = state_q;
		go = 1'b0;
		resume = 1'b0;
		cmdbusy_o = 1'b1;
		case (state_q)
			Idle: begin
				cmdbusy_o = 1'b0;
				if ((cmd_valid_i && halted_q_aligned[hartsel]) && !unsupported_command)
					state_d = Go;
				else if (cmd_valid_i) begin
					cmderror_valid_o = 1'b1;
					cmderror_o = dm_CmdErrorHaltResume;
				end
				if (((resumereq_aligned[hartsel] && !resuming_q_aligned[hartsel]) && !haltreq_aligned[hartsel]) && halted_q_aligned[hartsel])
					state_d = Resume;
			end
			Go: begin
				cmdbusy_o = 1'b1;
				go = 1'b1;
				if (going)
					state_d = CmdExecuting;
			end
			Resume: begin
				cmdbusy_o = 1'b1;
				resume = 1'b1;
				if (resuming_q_aligned[hartsel])
					state_d = Idle;
			end
			CmdExecuting: begin
				cmdbusy_o = 1'b1;
				go = 1'b0;
				if (halted_aligned[hartsel])
					state_d = Idle;
			end
			default:
				;
		endcase
		if (unsupported_command && cmd_valid_i) begin
			cmderror_valid_o = 1'b1;
			cmderror_o = dm_CmdErrNotSupported;
		end
		if (exception) begin
			cmderror_valid_o = 1'b1;
			cmderror_o = dm_CmdErrorException;
		end
	end
	wire [63:0] word_mux;
	assign word_mux = (fwd_rom_q ? rom_rdata : rdata_q);
	generate
		if (BusWidth == 64) begin : gen_word_mux64
			assign rdata_o = word_mux;
		end
		else begin : gen_word_mux32
			assign rdata_o = (word_enable32_q ? word_mux[32+:32] : word_mux[0+:32]);
		end
	endgenerate
	reg [63:0] data_bits;
	reg [63:0] rdata;
	function automatic [20:0] sv2v_cast_21;
		input reg [20:0] inp;
		sv2v_cast_21 = inp;
	endfunction
	function automatic [$clog2(5'h08) - 1:0] sv2v_cast_D971A;
		input reg [$clog2(5'h08) - 1:0] inp;
		sv2v_cast_D971A = inp;
	endfunction
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [11:0] sv2v_cast_12;
		input reg [11:0] inp;
		sv2v_cast_12 = inp;
	endfunction
	localparam [7:0] dm_AccessRegister = 8'h00;
	localparam [63:0] dm_HaltAddress = 64'h0000000000000800;
	localparam [63:0] dm_ResumeAddress = dm_HaltAddress + 4;
	function automatic [31:0] dm_jal;
		input reg [4:0] rd;
		input reg [20:0] imm;
		dm_jal = {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'h6f};
	endfunction
	always @(*) begin : p_rw_logic
		halted_d_aligned = sv2v_cast_8FC1C(halted_q);
		resuming_d_aligned = sv2v_cast_8FC1C(resuming_q);
		rdata_d = rdata_q;
		data_bits = data_i;
		rdata = {64 {1'sb0}};
		data_valid_o = 1'b0;
		exception = 1'b0;
		halted_aligned = {NrHartsAligned {1'sb0}};
		going = 1'b0;
		if (clear_resumeack_i)
			resuming_d_aligned[hartsel] = 1'b0;
		if (req_i)
			if (we_i) begin
				if (addr_i[DbgAddressBits - 1:0] == HaltedAddr) begin
					halted_aligned[wdata_hartsel] = 1'b1;
					halted_d_aligned[wdata_hartsel] = 1'b1;
				end
				else if (addr_i[DbgAddressBits - 1:0] == GoingAddr)
					going = 1'b1;
				else if (addr_i[DbgAddressBits - 1:0] == ResumingAddr) begin
					halted_d_aligned[wdata_hartsel] = 1'b0;
					resuming_d_aligned[wdata_hartsel] = 1'b1;
				end
				else if (addr_i[DbgAddressBits - 1:0] == ExceptionAddr)
					exception = 1'b1;
				else if ((DataBaseAddr <= addr_i[DbgAddressBits - 1:0]) && (DataEndAddr >= addr_i[DbgAddressBits - 1:0])) begin
					data_valid_o = 1'b1;
					begin : sv2v_autoblock_78
						reg signed [31:0] i;
						for (i = 0; i < (BusWidth / 8); i = i + 1)
							if (be_i[i])
								data_bits[i * 8+:8] = wdata_i[i * 8+:8];
					end
				end
			end
			else if (addr_i[DbgAddressBits - 1:0] == WhereToAddr) begin
				if (resumereq_wdata_aligned[wdata_hartsel])
					rdata_d = {32'b00000000000000000000000000000000, dm_jal(1'sb0, sv2v_cast_21(dm_ResumeAddress[11:0]) - sv2v_cast_21(WhereToAddr))};
				if (cmdbusy_o)
					if (((cmd_i[31-:8] == dm_AccessRegister) && !ac_ar[17]) && ac_ar[18])
						rdata_d = {32'b00000000000000000000000000000000, dm_jal(1'sb0, sv2v_cast_21(ProgBufBaseAddr) - sv2v_cast_21(WhereToAddr))};
					else
						rdata_d = {32'b00000000000000000000000000000000, dm_jal(1'sb0, sv2v_cast_21(AbstractCmdBaseAddr) - sv2v_cast_21(WhereToAddr))};
			end
			else if ((DataBaseAddr <= addr_i[DbgAddressBits - 1:0]) && (DataEndAddr >= addr_i[DbgAddressBits - 1:0]))
				rdata_d = {data_i[sv2v_cast_D971A((addr_i[DbgAddressBits - 1:3] - DataBaseAddr[DbgAddressBits - 1:3]) + 1'b1) * 32+:32], data_i[sv2v_cast_D971A(addr_i[DbgAddressBits - 1:3] - DataBaseAddr[DbgAddressBits - 1:3]) * 32+:32]};
			else if ((ProgBufBaseAddr <= addr_i[DbgAddressBits - 1:0]) && (ProgBufEndAddr >= addr_i[DbgAddressBits - 1:0]))
				rdata_d = progbuf[sv2v_cast_D971A(addr_i[DbgAddressBits - 1:3] - ProgBufBaseAddr[DbgAddressBits - 1:3]) * 64+:64];
			else if ((AbstractCmdBaseAddr <= addr_i[DbgAddressBits - 1:0]) && (AbstractCmdEndAddr >= addr_i[DbgAddressBits - 1:0]))
				rdata_d = abstract_cmd[sv2v_cast_3(addr_i[DbgAddressBits - 1:3] - AbstractCmdBaseAddr[DbgAddressBits - 1:3]) * 64+:64];
			else if ((FlagsBaseAddr <= addr_i[DbgAddressBits - 1:0]) && (FlagsEndAddr >= addr_i[DbgAddressBits - 1:0])) begin
				if (({addr_i[DbgAddressBits - 1:3], 3'b000} - FlagsBaseAddr[DbgAddressBits - 1:0]) == (sv2v_cast_12(hartsel) & {{DbgAddressBits - 3 {1'b1}}, 3'b000}))
					rdata[(sv2v_cast_12(hartsel) & sv2v_cast_12(3'b111)) * 8+:8] = {6'b000000, resume, go};
				rdata_d = rdata;
			end
		data_o = data_bits;
	end
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	localparam [11:0] dm_CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] dm_CSR_DSCRATCH1 = 12'h7b3;
	function automatic [31:0] dm_auipc;
		input reg [4:0] rd;
		input reg [20:0] imm;
		dm_auipc = {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'h17};
	endfunction
	function automatic [31:0] dm_csrr;
		input reg [11:0] csr;
		input reg [4:0] dest;
		dm_csrr = {csr, 5'h00, 3'h2, dest, 7'h73};
	endfunction
	function automatic [31:0] dm_csrw;
		input reg [11:0] csr;
		input reg [4:0] rs1;
		dm_csrw = {csr, rs1, 3'h1, 5'h00, 7'h73};
	endfunction
	function automatic [31:0] dm_ebreak;
		input _sv2v_unused;
		dm_ebreak = 32'h00100073;
	endfunction
	function automatic [31:0] dm_float_load;
		input reg [2:0] size;
		input reg [4:0] dest;
		input reg [4:0] base;
		input reg [11:0] offset;
		dm_float_load = {offset[11:0], base, size, dest, 7'b0000111};
	endfunction
	function automatic [31:0] dm_float_store;
		input reg [2:0] size;
		input reg [4:0] src;
		input reg [4:0] base;
		input reg [11:0] offset;
		dm_float_store = {offset[11:5], src, base, size, offset[4:0], 7'b0100111};
	endfunction
	function automatic [31:0] dm_illegal;
		input _sv2v_unused;
		dm_illegal = 32'h00000000;
	endfunction
	function automatic [31:0] dm_load;
		input reg [2:0] size;
		input reg [4:0] dest;
		input reg [4:0] base;
		input reg [11:0] offset;
		dm_load = {offset[11:0], base, size, dest, 7'h03};
	endfunction
	function automatic [31:0] dm_nop;
		input _sv2v_unused;
		dm_nop = 32'h00000013;
	endfunction
	function automatic [31:0] dm_slli;
		input reg [4:0] rd;
		input reg [4:0] rs1;
		input reg [5:0] shamt;
		dm_slli = {6'b000000, shamt[5:0], rs1, 3'h1, rd, 7'h13};
	endfunction
	function automatic [31:0] dm_srli;
		input reg [4:0] rd;
		input reg [4:0] rs1;
		input reg [5:0] shamt;
		dm_srli = {6'b000000, shamt[5:0], rs1, 3'h5, rd, 7'h13};
	endfunction
	function automatic [31:0] dm_store;
		input reg [2:0] size;
		input reg [4:0] src;
		input reg [4:0] base;
		input reg [11:0] offset;
		dm_store = {offset[11:5], src, base, size, offset[4:0], 7'h23};
	endfunction
	always @(*) begin : p_abstract_cmd_rom
		unsupported_command = 1'b0;
		abstract_cmd[31-:32] = dm_illegal(0);
		abstract_cmd[63-:32] = (HasSndScratch ? dm_auipc(5'd10, 1'sb0) : dm_nop(0));
		abstract_cmd[95-:32] = (HasSndScratch ? dm_srli(5'd10, 5'd10, 6'd12) : dm_nop(0));
		abstract_cmd[127-:32] = (HasSndScratch ? dm_slli(5'd10, 5'd10, 6'd12) : dm_nop(0));
		abstract_cmd[159-:32] = dm_nop(0);
		abstract_cmd[191-:32] = dm_nop(0);
		abstract_cmd[223-:32] = dm_nop(0);
		abstract_cmd[255-:32] = dm_nop(0);
		abstract_cmd[287-:32] = (HasSndScratch ? dm_csrr(dm_CSR_DSCRATCH1, 5'd10) : dm_nop(0));
		abstract_cmd[319-:32] = dm_ebreak(0);
		abstract_cmd[320+:192] = {192 {1'sb0}};
		case (cmd_i[31-:8])
			dm_AccessRegister: begin
				if (((sv2v_cast_32(ac_ar[22-:3]) < MaxAar) && ac_ar[17]) && ac_ar[16]) begin
					abstract_cmd[31-:32] = (HasSndScratch ? dm_csrr(dm_CSR_DSCRATCH1, 5'd10) : dm_nop(0));
					if (ac_ar[15:14] != {2 {1'sb0}}) begin
						abstract_cmd[31-:32] = dm_ebreak(0);
						unsupported_command = 1'b1;
					end
					else if (((HasSndScratch && ac_ar[12]) && !ac_ar[5]) && (ac_ar[4:0] == 5'd10)) begin
						abstract_cmd[159-:32] = dm_csrw(dm_CSR_DSCRATCH0, 5'd8);
						abstract_cmd[191-:32] = dm_load(ac_ar[22-:3], 5'd8, LoadBaseAddr, dm_DataAddr);
						abstract_cmd[223-:32] = dm_csrw(dm_CSR_DSCRATCH1, 5'd8);
						abstract_cmd[255-:32] = dm_csrr(dm_CSR_DSCRATCH0, 5'd8);
					end
					else if (ac_ar[12]) begin
						if (ac_ar[5])
							abstract_cmd[159-:32] = dm_float_load(ac_ar[22-:3], ac_ar[4:0], LoadBaseAddr, dm_DataAddr);
						else
							abstract_cmd[159-:32] = dm_load(ac_ar[22-:3], ac_ar[4:0], LoadBaseAddr, dm_DataAddr);
					end
					else begin
						abstract_cmd[159-:32] = dm_csrw(dm_CSR_DSCRATCH0, 5'd8);
						abstract_cmd[191-:32] = dm_load(ac_ar[22-:3], 5'd8, LoadBaseAddr, dm_DataAddr);
						abstract_cmd[223-:32] = dm_csrw(sv2v_cast_12(ac_ar[11:0]), 5'd8);
						abstract_cmd[255-:32] = dm_csrr(dm_CSR_DSCRATCH0, 5'd8);
					end
				end
				else if (((sv2v_cast_32(ac_ar[22-:3]) < MaxAar) && ac_ar[17]) && !ac_ar[16]) begin
					abstract_cmd[31-:32] = (HasSndScratch ? dm_csrr(dm_CSR_DSCRATCH1, LoadBaseAddr) : dm_nop(0));
					if (ac_ar[15:14] != {2 {1'sb0}}) begin
						abstract_cmd[31-:32] = dm_ebreak(0);
						unsupported_command = 1'b1;
					end
					else if (((HasSndScratch && ac_ar[12]) && !ac_ar[5]) && (ac_ar[4:0] == 5'd10)) begin
						abstract_cmd[159-:32] = dm_csrw(dm_CSR_DSCRATCH0, 5'd8);
						abstract_cmd[191-:32] = dm_csrr(dm_CSR_DSCRATCH1, 5'd8);
						abstract_cmd[223-:32] = dm_store(ac_ar[22-:3], 5'd8, LoadBaseAddr, dm_DataAddr);
						abstract_cmd[255-:32] = dm_csrr(dm_CSR_DSCRATCH0, 5'd8);
					end
					else if (ac_ar[12]) begin
						if (ac_ar[5])
							abstract_cmd[159-:32] = dm_float_store(ac_ar[22-:3], ac_ar[4:0], LoadBaseAddr, dm_DataAddr);
						else
							abstract_cmd[159-:32] = dm_store(ac_ar[22-:3], ac_ar[4:0], LoadBaseAddr, dm_DataAddr);
					end
					else begin
						abstract_cmd[159-:32] = dm_csrw(dm_CSR_DSCRATCH0, 5'd8);
						abstract_cmd[191-:32] = dm_csrr(sv2v_cast_12(ac_ar[11:0]), 5'd8);
						abstract_cmd[223-:32] = dm_store(ac_ar[22-:3], 5'd8, LoadBaseAddr, dm_DataAddr);
						abstract_cmd[255-:32] = dm_csrr(dm_CSR_DSCRATCH0, 5'd8);
					end
				end
				else if ((sv2v_cast_32(ac_ar[22-:3]) >= MaxAar) || (ac_ar[19] == 1'b1)) begin
					abstract_cmd[31-:32] = dm_ebreak(0);
					unsupported_command = 1'b1;
				end
				if (ac_ar[18] && !unsupported_command)
					abstract_cmd[319-:32] = dm_nop(0);
			end
			default: begin
				abstract_cmd[31-:32] = dm_ebreak(0);
				unsupported_command = 1'b1;
			end
		endcase
	end
	wire [63:0] rom_addr;
	function automatic [63:0] sv2v_cast_64;
		input reg [63:0] inp;
		sv2v_cast_64 = inp;
	endfunction
	assign rom_addr = sv2v_cast_64(addr_i);
	generate
		if (HasSndScratch) begin : gen_rom_snd_scratch
			debug_rom i_debug_rom(
				.clk_i(clk_i),
				.req_i(req_i),
				.addr_i(rom_addr),
				.rdata_o(rom_rdata)
			);
		end
		/*else begin : gen_rom_one_scratch
			debug_rom_one_scratch i_debug_rom(
				.clk_i(clk_i),
				.req_i(req_i),
				.addr_i(rom_addr),
				.rdata_o(rom_rdata)
			);
		end*/
	endgenerate
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	assign fwd_rom_d = sv2v_cast_1(addr_i[DbgAddressBits - 1:0] >= dm_HaltAddress[DbgAddressBits - 1:0]);
	always @(posedge clk_i or negedge rst_ni) begin : p_regs
		if (!rst_ni) begin
			fwd_rom_q <= 1'b0;
			rdata_q <= {64 {1'sb0}};
			state_q <= Idle;
			word_enable32_q <= 1'b0;
		end
		else begin
			fwd_rom_q <= fwd_rom_d;
			rdata_q <= rdata_d;
			state_q <= state_d;
			word_enable32_q <= addr_i[2];
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			halted_q <= 1'b0;
			resuming_q <= 1'b0;
		end
		else begin
			halted_q <= SelectableHarts & halted_d;
			resuming_q <= SelectableHarts & resuming_d;
		end
endmodule
module dm_sba (
	clk_i,
	rst_ni,
	dmactive_i,
	master_req_o,
	master_add_o,
	master_we_o,
	master_wdata_o,
	master_be_o,
	master_gnt_i,
	master_r_valid_i,
	master_r_rdata_i,
	sbaddress_i,
	sbaddress_write_valid_i,
	sbreadonaddr_i,
	sbaddress_o,
	sbautoincrement_i,
	sbaccess_i,
	sbreadondata_i,
	sbdata_i,
	sbdata_read_valid_i,
	sbdata_write_valid_i,
	sbdata_o,
	sbdata_valid_o,
	sbbusy_o,
	sberror_valid_o,
	sberror_o
);
	parameter [31:0] BusWidth = 32;
	input wire clk_i;
	input wire rst_ni;
	input wire dmactive_i;
	output wire master_req_o;
	output wire [BusWidth - 1:0] master_add_o;
	output wire master_we_o;
	output wire [BusWidth - 1:0] master_wdata_o;
	output wire [(BusWidth / 8) - 1:0] master_be_o;
	input wire master_gnt_i;
	input wire master_r_valid_i;
	input wire [BusWidth - 1:0] master_r_rdata_i;
	input wire [BusWidth - 1:0] sbaddress_i;
	input wire sbaddress_write_valid_i;
	input wire sbreadonaddr_i;
	output reg [BusWidth - 1:0] sbaddress_o;
	input wire sbautoincrement_i;
	input wire [2:0] sbaccess_i;
	input wire sbreadondata_i;
	input wire [BusWidth - 1:0] sbdata_i;
	input wire sbdata_read_valid_i;
	input wire sbdata_write_valid_i;
	output wire [BusWidth - 1:0] sbdata_o;
	output wire sbdata_valid_o;
	output wire sbbusy_o;
	output reg sberror_valid_o;
	output reg [2:0] sberror_o;
	reg [2:0] state_d;
	reg [2:0] state_q;
	reg [BusWidth - 1:0] address;
	reg req;
	wire gnt;
	reg we;
	reg [(BusWidth / 8) - 1:0] be;
	reg [$clog2(BusWidth / 8) - 1:0] be_idx;
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	localparam [2:0] Idle = 0;
	assign sbbusy_o = sv2v_cast_1(state_q != Idle);
	localparam [2:0] Read = 1;
	localparam [2:0] WaitRead = 3;
	localparam [2:0] WaitWrite = 4;
	localparam [2:0] Write = 2;
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	always @(*) begin : p_fsm
		req = 1'b0;
		address = sbaddress_i;
		we = 1'b0;
		be = {BusWidth / 8 {1'sb0}};
		be_idx = sbaddress_i[$clog2(BusWidth / 8) - 1:0];
		sberror_o = {3 {1'sb0}};
		sberror_valid_o = 1'b0;
		sbaddress_o = sbaddress_i;
		state_d = state_q;
		case (state_q)
			Idle: begin
				if (sbaddress_write_valid_i && sbreadonaddr_i)
					state_d = Read;
				if (sbdata_write_valid_i)
					state_d = Write;
				if (sbdata_read_valid_i && sbreadondata_i)
					state_d = Read;
			end
			Read: begin
				req = 1'b1;
				if (gnt)
					state_d = WaitRead;
			end
			Write: begin
				req = 1'b1;
				we = 1'b1;
				case (sbaccess_i)
					3'b000: be[be_idx] = 1'sb1;
					3'b001: be[sv2v_cast_32_signed({be_idx[$clog2(BusWidth / 8) - 1:1], 1'b0})+:2] = {2 {1'sb1}};
					3'b010:
						if (BusWidth == 32'd64)
							be[sv2v_cast_32_signed({be_idx[$clog2(BusWidth / 8) - 1], 2'h0})+:4] = {4 {1'sb1}};
						else
							be = {BusWidth / 8 {1'sb1}};
					3'b011: be = {BusWidth / 8 {1'sb1}};
					default:
						;
				endcase
				if (gnt)
					state_d = WaitWrite;
			end
			WaitRead:
				if (sbdata_valid_o) begin
					state_d = Idle;
					if (sbautoincrement_i)
						sbaddress_o = sbaddress_i + (32'h00000001 << sbaccess_i);
				end
			WaitWrite:
				if (sbdata_valid_o) begin
					state_d = Idle;
					if (sbautoincrement_i)
						sbaddress_o = sbaddress_i + (32'h00000001 << sbaccess_i);
				end
			default: state_d = Idle;
		endcase
		if ((sbaccess_i > 3) && (state_q != Idle)) begin
			req = 1'b0;
			state_d = Idle;
			sberror_valid_o = 1'b1;
			sberror_o = 3'd3;
		end
	end
	always @(posedge clk_i or negedge rst_ni) begin : p_regs
		if (!rst_ni)
			state_q <= Idle;
		else
			state_q <= state_d;
	end
	assign master_req_o = req;
	assign master_add_o = address[BusWidth - 1:0];
	assign master_we_o = we;
	assign master_wdata_o = sbdata_i[BusWidth - 1:0];
	assign master_be_o = be[(BusWidth / 8) - 1:0];
	assign gnt = master_gnt_i;
	assign sbdata_valid_o = master_r_valid_i;
	assign sbdata_o = master_r_rdata_i[BusWidth - 1:0];
endmodule
module dmi_cdc (
	tck_i,
	trst_ni,
	jtag_dmi_req_i,
	jtag_dmi_ready_o,
	jtag_dmi_valid_i,
	jtag_dmi_resp_o,
	jtag_dmi_valid_o,
	jtag_dmi_ready_i,
	clk_i,
	rst_ni,
	core_dmi_req_o,
	core_dmi_valid_o,
	core_dmi_ready_i,
	core_dmi_resp_i,
	core_dmi_ready_o,
	core_dmi_valid_i
);
	input wire tck_i;
	input wire trst_ni;
	input wire [40:0] jtag_dmi_req_i;
	output wire jtag_dmi_ready_o;
	input wire jtag_dmi_valid_i;
	output wire [33:0] jtag_dmi_resp_o;
	output wire jtag_dmi_valid_o;
	input wire jtag_dmi_ready_i;
	input wire clk_i;
	input wire rst_ni;
	output wire [40:0] core_dmi_req_o;
	output wire core_dmi_valid_o;
	input wire core_dmi_ready_i;
	input wire [33:0] core_dmi_resp_i;
	output wire core_dmi_ready_o;
	input wire core_dmi_valid_i;
	prim_fifo_async #(
		.Width(41),
		.Depth(4)
	) i_cdc_req(
		.clk_wr_i(tck_i),
		.rst_wr_ni(trst_ni),
		.wvalid_i(jtag_dmi_valid_i),
		.wready_o(jtag_dmi_ready_o),
		.wdata_i(jtag_dmi_req_i),
		.wdepth_o(),
		.clk_rd_i(clk_i),
		.rst_rd_ni(rst_ni),
		.rvalid_o(core_dmi_valid_o),
		.rready_i(core_dmi_ready_i),
		.rdata_o(core_dmi_req_o),
		.rdepth_o()
	);
	prim_fifo_async #(
		.Width(34),
		.Depth(4)
	) i_cdc_resp(
		.clk_wr_i(clk_i),
		.rst_wr_ni(rst_ni),
		.wvalid_i(core_dmi_valid_i),
		.wready_o(core_dmi_ready_o),
		.wdata_i(core_dmi_resp_i),
		.wdepth_o(),
		.clk_rd_i(tck_i),
		.rst_rd_ni(trst_ni),
		.rvalid_o(jtag_dmi_valid_o),
		.rready_i(jtag_dmi_ready_i),
		.rdata_o(jtag_dmi_resp_o),
		.rdepth_o()
	);
endmodule
module dmi_jtag (
	clk_i,
	rst_ni,
	testmode_i,
	dmi_rst_no,
	dmi_req_o,
	dmi_req_valid_o,
	dmi_req_ready_i,
	dmi_resp_i,
	dmi_resp_ready_o,
	dmi_resp_valid_i,
	tck_i,
	tms_i,
	trst_ni,
	td_i,
	td_o,
	tdo_oe_o
);
	parameter [31:0] IdcodeValue = 32'h00000001;
	input wire clk_i;
	input wire rst_ni;
	input wire testmode_i;
	output wire dmi_rst_no;
	output wire [40:0] dmi_req_o;
	output wire dmi_req_valid_o;
	input wire dmi_req_ready_i;
	input wire [33:0] dmi_resp_i;
	output wire dmi_resp_ready_o;
	input wire dmi_resp_valid_i;
	input wire tck_i;
	input wire tms_i;
	input wire trst_ni;
	input wire td_i;
	output wire td_o;
	output wire tdo_oe_o;
	assign dmi_rst_no = rst_ni;
	wire test_logic_reset;
	wire shift_dr;
	wire update_dr;
	wire capture_dr;
	wire dmi_access;
	wire dtmcs_select;
	wire dmi_reset;
	wire dmi_tdi;
	wire dmi_tdo;
	wire [40:0] dmi_req;
	wire dmi_req_ready;
	reg dmi_req_valid;
	wire [33:0] dmi_resp;
	wire dmi_resp_valid;
	wire dmi_resp_ready;
	reg [2:0] state_d;
	reg [2:0] state_q;
	reg [40:0] dr_d;
	reg [40:0] dr_q;
	reg [6:0] address_d;
	reg [6:0] address_q;
	reg [31:0] data_d;
	reg [31:0] data_q;
	wire [40:0] dmi;
	function automatic [40:0] sv2v_cast_41;
		input reg [40:0] inp;
		sv2v_cast_41 = inp;
	endfunction
	assign dmi = sv2v_cast_41(dr_q);
	assign dmi_req[40-:7] = address_q;
	assign dmi_req[31-:32] = data_q;
	localparam [2:0] Write = 3;
	localparam [1:0] dm_DTM_READ = 2'h1;
	localparam [1:0] dm_DTM_WRITE = 2'h2;
	assign dmi_req[33-:2] = (state_q == Write ? dm_DTM_WRITE : dm_DTM_READ);
	assign dmi_resp_ready = 1'b1;
	reg error_dmi_busy;
	reg [1:0] error_d;
	reg [1:0] error_q;
	localparam [1:0] DMIBusy = 2'h3;
	localparam [1:0] DMINoError = 2'h0;
	localparam [2:0] Idle = 0;
	localparam [2:0] Read = 1;
	localparam [2:0] WaitReadValid = 2;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	always @(*) begin : p_fsm
		error_dmi_busy = 1'b0;
		state_d = state_q;
		address_d = address_q;
		data_d = data_q;
		error_d = error_q;
		dmi_req_valid = 1'b0;
		case (state_q)
			Idle:
				if ((dmi_access && update_dr) && (error_q == DMINoError)) begin
					address_d = dmi[40-:7];
					data_d = dmi[33-:32];
					if (sv2v_cast_2(dmi[1-:2]) == dm_DTM_READ)
						state_d = Read;
					else if (sv2v_cast_2(dmi[1-:2]) == dm_DTM_WRITE)
						state_d = Write;
				end
			Read: begin
				dmi_req_valid = 1'b1;
				if (dmi_req_ready)
					state_d = WaitReadValid;
			end
			WaitReadValid:
				if (dmi_resp_valid) begin
					data_d = dmi_resp[33-:32];
					state_d = Idle;
				end
			Write: begin
				dmi_req_valid = 1'b1;
				if (dmi_req_ready)
					state_d = Idle;
			end
			default:
				if (dmi_resp_valid)
					state_d = Idle;
		endcase
		if (update_dr && (state_q != Idle))
			error_dmi_busy = 1'b1;
		if (capture_dr && |{state_q == Read, state_q == WaitReadValid})
			error_dmi_busy = 1'b1;
		if (error_dmi_busy)
			error_d = DMIBusy;
		if (dmi_reset && dtmcs_select)
			error_d = DMINoError;
	end
	assign dmi_tdo = dr_q[0];
	always @(*) begin : p_shift
		dr_d = dr_q;
		if (capture_dr)
			if (dmi_access)
				if ((error_q == DMINoError) && !error_dmi_busy)
					dr_d = {address_q, data_q, DMINoError};
				else if ((error_q == DMIBusy) || error_dmi_busy)
					dr_d = {address_q, data_q, DMIBusy};
		if (shift_dr)
			if (dmi_access)
				dr_d = {dmi_tdi, dr_q[40:1]};
		if (test_logic_reset)
			dr_d = {41 {1'sb0}};
	end
	always @(posedge tck_i or negedge trst_ni) begin : p_regs
		if (!trst_ni) begin
			dr_q <= {41 {1'sb0}};
			state_q <= Idle;
			address_q <= {7 {1'sb0}};
			data_q <= {32 {1'sb0}};
			error_q <= DMINoError;
		end
		else begin
			dr_q <= dr_d;
			state_q <= state_d;
			address_q <= address_d;
			data_q <= data_d;
			error_q <= error_d;
		end
	end
	dmi_jtag_tap #(
		.IrLength(5),
		.IdcodeValue(IdcodeValue)
	) i_dmi_jtag_tap(
		.tck_i(tck_i),
		.tms_i(tms_i),
		.trst_ni(trst_ni),
		.td_i(td_i),
		.td_o(td_o),
		.tdo_oe_o(tdo_oe_o),
		.testmode_i(testmode_i),
		.test_logic_reset_o(test_logic_reset),
		.shift_dr_o(shift_dr),
		.update_dr_o(update_dr),
		.capture_dr_o(capture_dr),
		.dmi_access_o(dmi_access),
		.dtmcs_select_o(dtmcs_select),
		.dmi_reset_o(dmi_reset),
		.dmi_error_i(error_q),
		.dmi_tdi_o(dmi_tdi),
		.dmi_tdo_i(dmi_tdo)
	);
	dmi_cdc i_dmi_cdc(
		.tck_i(tck_i),
		.trst_ni(trst_ni),
		.jtag_dmi_req_i(dmi_req),
		.jtag_dmi_ready_o(dmi_req_ready),
		.jtag_dmi_valid_i(dmi_req_valid),
		.jtag_dmi_resp_o(dmi_resp),
		.jtag_dmi_valid_o(dmi_resp_valid),
		.jtag_dmi_ready_i(dmi_resp_ready),
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.core_dmi_req_o(dmi_req_o),
		.core_dmi_valid_o(dmi_req_valid_o),
		.core_dmi_ready_i(dmi_req_ready_i),
		.core_dmi_resp_i(dmi_resp_i),
		.core_dmi_ready_o(dmi_resp_ready_o),
		.core_dmi_valid_i(dmi_resp_valid_i)
	);
endmodule
module dmi_jtag_tap (
	tck_i,
	tms_i,
	trst_ni,
	td_i,
	td_o,
	tdo_oe_o,
	testmode_i,
	test_logic_reset_o,
	shift_dr_o,
	update_dr_o,
	capture_dr_o,
	dmi_access_o,
	dtmcs_select_o,
	dmi_reset_o,
	dmi_error_i,
	dmi_tdi_o,
	dmi_tdo_i
);
	parameter [31:0] IrLength = 5;
	parameter [31:0] IdcodeValue = 32'h00000001;
	input wire tck_i;
	input wire tms_i;
	input wire trst_ni;
	input wire td_i;
	output reg td_o;
	output reg tdo_oe_o;
	input wire testmode_i;
	output reg test_logic_reset_o;
	output reg shift_dr_o;
	output reg update_dr_o;
	output reg capture_dr_o;
	output reg dmi_access_o;
	output reg dtmcs_select_o;
	output wire dmi_reset_o;
	input wire [1:0] dmi_error_i;
	output wire dmi_tdi_o;
	input wire dmi_tdo_i;
	assign dmi_tdi_o = td_i;
	reg [3:0] tap_state_q;
	reg [3:0] tap_state_d;
	reg [IrLength - 1:0] jtag_ir_shift_d;
	reg [IrLength - 1:0] jtag_ir_shift_q;
	reg [IrLength - 1:0] jtag_ir_d;
	reg [IrLength - 1:0] jtag_ir_q;
	reg capture_ir;
	reg shift_ir;
	reg update_ir;
	function automatic [IrLength - 1:0] sv2v_cast_AFF3E;
		input reg [IrLength - 1:0] inp;
		sv2v_cast_AFF3E = inp;
	endfunction
	function automatic [IrLength - 1:0] sv2v_cast_42A93;
		input reg [IrLength - 1:0] inp;
		sv2v_cast_42A93 = inp;
	endfunction
	localparam [IrLength - 1:0] IDCODE = 'h1;
	always @(*) begin : p_jtag
		jtag_ir_shift_d = jtag_ir_shift_q;
		jtag_ir_d = jtag_ir_q;
		if (shift_ir)
			jtag_ir_shift_d = {td_i, jtag_ir_shift_q[IrLength - 1:1]};
		if (capture_ir)
			jtag_ir_shift_d = sv2v_cast_AFF3E(4'b0101);
		if (update_ir)
			jtag_ir_d = sv2v_cast_42A93(jtag_ir_shift_q);
		if (test_logic_reset_o) begin
			jtag_ir_shift_d = {IrLength {1'sb0}};
			jtag_ir_d = IDCODE;
		end
	end
	always @(posedge tck_i or negedge trst_ni) begin : p_jtag_ir_reg
		if (!trst_ni) begin
			jtag_ir_shift_q <= {IrLength {1'sb0}};
			jtag_ir_q <= IDCODE;
		end
		else begin
			jtag_ir_shift_q <= jtag_ir_shift_d;
			jtag_ir_q <= jtag_ir_d;
		end
	end
	reg [31:0] idcode_d;
	reg [31:0] idcode_q;
	reg idcode_select;
	reg bypass_select;
	reg [31:0] dtmcs_d;
	reg [31:0] dtmcs_q;
	reg bypass_d;
	reg bypass_q;
	assign dmi_reset_o = dtmcs_q[16];
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	function automatic [30:0] sv2v_cast_31;
		input reg [30:0] inp;
		sv2v_cast_31 = inp;
	endfunction
	always @(*) begin
		idcode_d = idcode_q;
		bypass_d = bypass_q;
		dtmcs_d = dtmcs_q;
		if (capture_dr_o) begin
			if (idcode_select)
				idcode_d = IdcodeValue;
			if (bypass_select)
				bypass_d = 1'b0;
			if (dtmcs_select_o)
				dtmcs_d = {14'b00000000000000, 1'b0, 1'b0, 1'sb0, 3'd1, sv2v_cast_2(dmi_error_i), 6'd7, 4'd1};
		end
		if (shift_dr_o) begin
			if (idcode_select)
				idcode_d = {td_i, sv2v_cast_31(idcode_q >> 1)};
			if (bypass_select)
				bypass_d = td_i;
			if (dtmcs_select_o)
				dtmcs_d = {td_i, sv2v_cast_31(dtmcs_q >> 1)};
		end
		if (test_logic_reset_o) begin
			idcode_d = IdcodeValue;
			bypass_d = 1'b0;
		end
	end
	localparam [IrLength - 1:0] BYPASS0 = 'h0;
	localparam [IrLength - 1:0] BYPASS1 = 'h1f;
	localparam [IrLength - 1:0] DMIACCESS = 'h11;
	localparam [IrLength - 1:0] DTMCSR = 'h10;
	always @(*) begin : p_data_reg_sel
		dmi_access_o = 1'b0;
		dtmcs_select_o = 1'b0;
		idcode_select = 1'b0;
		bypass_select = 1'b0;
		case (jtag_ir_q)
			BYPASS0: bypass_select = 1'b1;
			IDCODE: idcode_select = 1'b1;
			DTMCSR: dtmcs_select_o = 1'b1;
			DMIACCESS: dmi_access_o = 1'b1;
			BYPASS1: bypass_select = 1'b1;
			default: bypass_select = 1'b1;
		endcase
	end
	reg tdo_mux;
	always @(*) begin : p_out_sel
		if (shift_ir)
			tdo_mux = jtag_ir_shift_q[0];
		else
			case (jtag_ir_q)
				IDCODE: tdo_mux = idcode_q[0];
				DTMCSR: tdo_mux = dtmcs_q[0];
				DMIACCESS: tdo_mux = dmi_tdo_i;
				default: tdo_mux = bypass_q;
			endcase
	end
	wire tck_n;
	prim_generic_clock_inv #(.HasScanMode(1'b1)) i_tck_inv(
		.clk_i(tck_i),
		.clk_no(tck_n),
		.scanmode_i(testmode_i)
	);
	always @(posedge tck_n or negedge trst_ni) begin : p_tdo_regs
		if (!trst_ni) begin
			td_o <= 1'b0;
			tdo_oe_o <= 1'b0;
		end
		else begin
			td_o <= tdo_mux;
			tdo_oe_o <= shift_ir | shift_dr_o;
		end
	end
	localparam [3:0] CaptureDr = 3;
	localparam [3:0] CaptureIr = 10;
	localparam [3:0] Exit1Dr = 5;
	localparam [3:0] Exit1Ir = 12;
	localparam [3:0] Exit2Dr = 7;
	localparam [3:0] Exit2Ir = 14;
	localparam [3:0] PauseDr = 6;
	localparam [3:0] PauseIr = 13;
	localparam [3:0] RunTestIdle = 1;
	localparam [3:0] SelectDrScan = 2;
	localparam [3:0] SelectIrScan = 9;
	localparam [3:0] ShiftDr = 4;
	localparam [3:0] ShiftIr = 11;
	localparam [3:0] TestLogicReset = 0;
	localparam [3:0] UpdateDr = 8;
	localparam [3:0] UpdateIr = 15;
	always @(*) begin : p_tap_fsm
		test_logic_reset_o = 1'b0;
		capture_dr_o = 1'b0;
		shift_dr_o = 1'b0;
		update_dr_o = 1'b0;
		capture_ir = 1'b0;
		shift_ir = 1'b0;
		update_ir = 1'b0;
		case (tap_state_q)
			TestLogicReset: begin
				tap_state_d = (tms_i ? TestLogicReset : RunTestIdle);
				test_logic_reset_o = 1'b1;
			end
			RunTestIdle: tap_state_d = (tms_i ? SelectDrScan : RunTestIdle);
			SelectDrScan: tap_state_d = (tms_i ? SelectIrScan : CaptureDr);
			CaptureDr: begin
				capture_dr_o = 1'b1;
				tap_state_d = (tms_i ? Exit1Dr : ShiftDr);
			end
			ShiftDr: begin
				shift_dr_o = 1'b1;
				tap_state_d = (tms_i ? Exit1Dr : ShiftDr);
			end
			Exit1Dr: tap_state_d = (tms_i ? UpdateDr : PauseDr);
			PauseDr: tap_state_d = (tms_i ? Exit2Dr : PauseDr);
			Exit2Dr: tap_state_d = (tms_i ? UpdateDr : ShiftDr);
			UpdateDr: begin
				update_dr_o = 1'b1;
				tap_state_d = (tms_i ? SelectDrScan : RunTestIdle);
			end
			SelectIrScan: tap_state_d = (tms_i ? TestLogicReset : CaptureIr);
			CaptureIr: begin
				capture_ir = 1'b1;
				tap_state_d = (tms_i ? Exit1Ir : ShiftIr);
			end
			ShiftIr: begin
				shift_ir = 1'b1;
				tap_state_d = (tms_i ? Exit1Ir : ShiftIr);
			end
			Exit1Ir: tap_state_d = (tms_i ? UpdateIr : PauseIr);
			PauseIr: tap_state_d = (tms_i ? Exit2Ir : PauseIr);
			Exit2Ir: tap_state_d = (tms_i ? UpdateIr : ShiftIr);
			UpdateIr: begin
				update_ir = 1'b1;
				tap_state_d = (tms_i ? SelectDrScan : RunTestIdle);
			end
			default:
				;
		endcase
	end
	always @(posedge tck_i or negedge trst_ni) begin : p_regs
		if (!trst_ni) begin
			tap_state_q <= RunTestIdle;
			idcode_q <= IdcodeValue;
			bypass_q <= 1'b0;
			dtmcs_q <= {32 {1'sb0}};
		end
		else begin
			tap_state_q <= tap_state_d;
			idcode_q <= idcode_d;
			bypass_q <= bypass_d;
			dtmcs_q <= dtmcs_d;
		end
	end
endmodule
module rv_dm (
	clk_i,
	rst_ni,
	testmode_i,
	ndmreset_o,
	dmactive_o,
	debug_req_o,
	unavailable_i,
	tl_d_i,
	tl_d_o,
	tl_h_o,
	tl_h_i,
	tck_i,
	tms_i,
	trst_ni,
	td_i,
	td_o,
	tdo_oe_o
);
	parameter signed [31:0] NrHarts = 1;
	parameter [31:0] IdcodeValue = 32'h00000001;
	input wire clk_i;
	input wire rst_ni;
	input wire testmode_i;
	output wire ndmreset_o;
	output wire dmactive_o;
	output wire [NrHarts - 1:0] debug_req_o;
	input wire [NrHarts - 1:0] unavailable_i;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_d_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_d_o;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_h_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_h_i;
	input wire tck_i;
	input wire tms_i;
	input wire trst_ni;
	input wire td_i;
	output wire td_o;
	output wire tdo_oe_o;
	localparam signed [31:0] BusWidth = 32;
	localparam [NrHarts - 1:0] SelectableHarts = {NrHarts {1'b1}};
	wire [(NrHarts * 32) - 1:0] hartinfo;
	wire [NrHarts - 1:0] halted;
	wire [NrHarts - 1:0] resumeack;
	wire [NrHarts - 1:0] haltreq;
	wire [NrHarts - 1:0] resumereq;
	wire clear_resumeack;
	wire cmd_valid;
	wire [31:0] cmd;
	wire cmderror_valid;
	wire [2:0] cmderror;
	wire cmdbusy;
	localparam [4:0] dm_ProgBufSize = 5'h08;
	wire [(dm_ProgBufSize * 32) - 1:0] progbuf;
	localparam [3:0] dm_DataCount = 4'h2;
	wire [(dm_DataCount * 32) - 1:0] data_csrs_mem;
	wire [(dm_DataCount * 32) - 1:0] data_mem_csrs;
	wire data_valid;
	wire [19:0] hartsel;
	wire [BusWidth - 1:0] sbaddress_csrs_sba;
	wire [BusWidth - 1:0] sbaddress_sba_csrs;
	wire sbaddress_write_valid;
	wire sbreadonaddr;
	wire sbautoincrement;
	wire [2:0] sbaccess;
	wire sbreadondata;
	wire [BusWidth - 1:0] sbdata_write;
	wire sbdata_read_valid;
	wire sbdata_write_valid;
	wire [BusWidth - 1:0] sbdata_read;
	wire sbdata_valid;
	wire sbbusy;
	wire sberror_valid;
	wire [2:0] sberror;
	wire [40:0] dmi_req;
	wire [33:0] dmi_rsp;
	wire dmi_req_valid;
	wire dmi_req_ready;
	wire dmi_rsp_valid;
	wire dmi_rsp_ready;
	wire dmi_rst_n;
	localparam [11:0] dm_DataAddr = 12'h380;
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	function automatic [11:0] sv2v_cast_12;
		input reg [11:0] inp;
		sv2v_cast_12 = inp;
	endfunction
	localparam [31:0] DebugHartInfo = {8'b00000000, 4'd2, 3'd0, 1'b1, sv2v_cast_4(dm_DataCount), sv2v_cast_12(dm_DataAddr)};
	generate
		genvar i;
		for (i = 0; i < NrHarts; i = i + 1) begin : gen_dm_hart_ctrl
			assign hartinfo[i * 32+:32] = DebugHartInfo;
		end
	endgenerate
	dm_csrs #(
		.NrHarts(NrHarts),
		.BusWidth(BusWidth),
		.SelectableHarts(SelectableHarts)
	) i_dm_csrs(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.testmode_i(testmode_i),
		.dmi_rst_ni(dmi_rst_n),
		.dmi_req_valid_i(dmi_req_valid),
		.dmi_req_ready_o(dmi_req_ready),
		.dmi_req_i(dmi_req),
		.dmi_resp_valid_o(dmi_rsp_valid),
		.dmi_resp_ready_i(dmi_rsp_ready),
		.dmi_resp_o(dmi_rsp),
		.ndmreset_o(ndmreset_o),
		.dmactive_o(dmactive_o),
		.hartsel_o(hartsel),
		.hartinfo_i(hartinfo),
		.halted_i(halted),
		.unavailable_i(unavailable_i),
		.resumeack_i(resumeack),
		.haltreq_o(haltreq),
		.resumereq_o(resumereq),
		.clear_resumeack_o(clear_resumeack),
		.cmd_valid_o(cmd_valid),
		.cmd_o(cmd),
		.cmderror_valid_i(cmderror_valid),
		.cmderror_i(cmderror),
		.cmdbusy_i(cmdbusy),
		.progbuf_o(progbuf),
		.data_i(data_mem_csrs),
		.data_valid_i(data_valid),
		.data_o(data_csrs_mem),
		.sbaddress_o(sbaddress_csrs_sba),
		.sbaddress_i(sbaddress_sba_csrs),
		.sbaddress_write_valid_o(sbaddress_write_valid),
		.sbreadonaddr_o(sbreadonaddr),
		.sbautoincrement_o(sbautoincrement),
		.sbaccess_o(sbaccess),
		.sbreadondata_o(sbreadondata),
		.sbdata_o(sbdata_write),
		.sbdata_read_valid_o(sbdata_read_valid),
		.sbdata_write_valid_o(sbdata_write_valid),
		.sbdata_i(sbdata_read),
		.sbdata_valid_i(sbdata_valid),
		.sbbusy_i(sbbusy),
		.sberror_valid_i(sberror_valid),
		.sberror_i(sberror)
	);
	wire host_req;
	wire [BusWidth - 1:0] host_add;
	wire host_we;
	wire [BusWidth - 1:0] host_wdata;
	wire [(BusWidth / 8) - 1:0] host_be;
	wire host_gnt;
	wire host_r_valid;
	wire [BusWidth - 1:0] host_r_rdata;
	wire host_r_err;
	dm_sba #(.BusWidth(BusWidth)) i_dm_sba(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.master_req_o(host_req),
		.master_add_o(host_add),
		.master_we_o(host_we),
		.master_wdata_o(host_wdata),
		.master_be_o(host_be),
		.master_gnt_i(host_gnt),
		.master_r_valid_i(host_r_valid),
		.master_r_rdata_i(host_r_rdata),
		.dmactive_i(dmactive_o),
		.sbaddress_i(sbaddress_csrs_sba),
		.sbaddress_o(sbaddress_sba_csrs),
		.sbaddress_write_valid_i(sbaddress_write_valid),
		.sbreadonaddr_i(sbreadonaddr),
		.sbautoincrement_i(sbautoincrement),
		.sbaccess_i(sbaccess),
		.sbreadondata_i(sbreadondata),
		.sbdata_i(sbdata_write),
		.sbdata_read_valid_i(sbdata_read_valid),
		.sbdata_write_valid_i(sbdata_write_valid),
		.sbdata_o(sbdata_read),
		.sbdata_valid_o(sbdata_valid),
		.sbbusy_o(sbbusy),
		.sberror_valid_o(sberror_valid),
		.sberror_o(sberror)
	);
	tlul_adapter_host #(.MAX_REQS(1)) tl_adapter_host_sba(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(host_req),
		.gnt_o(host_gnt),
		.addr_i(host_add),
		.we_i(host_we),
		.wdata_i(host_wdata),
		.be_i(host_be),
		.valid_o(host_r_valid),
		.rdata_o(host_r_rdata),
		.err_o(host_r_err),
		.tl_o(tl_h_o),
		.tl_i(tl_h_i)
	);
	localparam [31:0] AddressWidthWords = BusWidth - 2;
	wire req;
	wire we;
	wire [(BusWidth / 8) - 1:0] be;
	wire [BusWidth - 1:0] wdata;
	wire [BusWidth - 1:0] rdata;
	reg rvalid;
	wire [BusWidth - 1:0] addr_b;
	wire [AddressWidthWords - 1:0] addr_w;
	assign be = {BusWidth / 8 {1'b1}};
	assign addr_b = {addr_w, {2 {1'b0}}};
	dm_mem #(
		.NrHarts(NrHarts),
		.BusWidth(BusWidth),
		.SelectableHarts(SelectableHarts),
		.DmBaseAddress(1)
	) i_dm_mem(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.debug_req_o(debug_req_o),
		.hartsel_i(hartsel),
		.haltreq_i(haltreq),
		.resumereq_i(resumereq),
		.clear_resumeack_i(clear_resumeack),
		.halted_o(halted),
		.resuming_o(resumeack),
		.cmd_valid_i(cmd_valid),
		.cmd_i(cmd),
		.cmderror_valid_o(cmderror_valid),
		.cmderror_o(cmderror),
		.cmdbusy_o(cmdbusy),
		.progbuf_i(progbuf),
		.data_i(data_csrs_mem),
		.data_o(data_mem_csrs),
		.data_valid_o(data_valid),
		.req_i(req),
		.we_i(we),
		.addr_i(addr_b),
		.wdata_i(wdata),
		.be_i(be),
		.rdata_o(rdata)
	);
	dmi_jtag #(.IdcodeValue(IdcodeValue)) dap(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.testmode_i(testmode_i),
		.dmi_rst_no(dmi_rst_n),
		.dmi_req_o(dmi_req),
		.dmi_req_valid_o(dmi_req_valid),
		.dmi_req_ready_i(dmi_req_ready),
		.dmi_resp_i(dmi_rsp),
		.dmi_resp_ready_o(dmi_rsp_ready),
		.dmi_resp_valid_i(dmi_rsp_valid),
		.tck_i(tck_i),
		.tms_i(tms_i),
		.trst_ni(trst_ni),
		.td_i(td_i),
		.td_o(td_o),
		.tdo_oe_o(tdo_oe_o)
	);
	tlul_adapter_sram #(
		.SramAw(AddressWidthWords),
		.SramDw(BusWidth),
		.Outstanding(1),
		.ByteAccess(0)
	) tl_adapter_device_mem(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_o(req),
		.gnt_i(1'b1),
		.we_o(we),
		.addr_o(addr_w),
		.wdata_o(wdata),
		.wmask_o(),
		.rdata_i(rdata),
		.rvalid_i(rvalid),
		.rerror_i(2'b00),
		.tl_o(tl_d_o),
		.tl_i(tl_d_i)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			rvalid <= 1'sb0;
		else
			rvalid <= req & ~we;
endmodule
module rv_plic (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	intr_src_i,
	irq_o,
	irq_id_o,
	msip_o
);
	localparam signed [31:0] NumSrc = 41;
	localparam signed [31:0] NumTarget = 1;
	localparam [8:0] RV_PLIC_IP_OFFSET = 9'h000;
	localparam [8:0] RV_PLIC_LE_OFFSET = 9'h004;
	localparam [8:0] RV_PLIC_PRIO0_OFFSET = 9'h008;
	localparam [8:0] RV_PLIC_PRIO1_OFFSET = 9'h00c;
	localparam [8:0] RV_PLIC_PRIO2_OFFSET = 9'h010;
	localparam [8:0] RV_PLIC_PRIO3_OFFSET = 9'h014;
	localparam [8:0] RV_PLIC_PRIO4_OFFSET = 9'h018;
	localparam [8:0] RV_PLIC_PRIO5_OFFSET = 9'h01c;
	localparam [8:0] RV_PLIC_PRIO6_OFFSET = 9'h020;
	localparam [8:0] RV_PLIC_PRIO7_OFFSET = 9'h024;
	localparam [8:0] RV_PLIC_PRIO8_OFFSET = 9'h028;
	localparam [8:0] RV_PLIC_PRIO9_OFFSET = 9'h02c;
	localparam [8:0] RV_PLIC_PRIO10_OFFSET = 9'h030;
	localparam [8:0] RV_PLIC_PRIO11_OFFSET = 9'h034;
	localparam [8:0] RV_PLIC_PRIO12_OFFSET = 9'h038;
	localparam [8:0] RV_PLIC_PRIO13_OFFSET = 9'h03c;
	localparam [8:0] RV_PLIC_PRIO14_OFFSET = 9'h040;
	localparam [8:0] RV_PLIC_PRIO15_OFFSET = 9'h044;
	localparam [8:0] RV_PLIC_PRIO16_OFFSET = 9'h048;
	localparam [8:0] RV_PLIC_PRIO17_OFFSET = 9'h04c;
	localparam [8:0] RV_PLIC_PRIO18_OFFSET = 9'h050;
	localparam [8:0] RV_PLIC_PRIO19_OFFSET = 9'h054;
	localparam [8:0] RV_PLIC_PRIO20_OFFSET = 9'h058;
	localparam [8:0] RV_PLIC_PRIO21_OFFSET = 9'h05c;
	localparam [8:0] RV_PLIC_PRIO22_OFFSET = 9'h060;
	localparam [8:0] RV_PLIC_PRIO23_OFFSET = 9'h064;
	localparam [8:0] RV_PLIC_PRIO24_OFFSET = 9'h068;
	localparam [8:0] RV_PLIC_PRIO25_OFFSET = 9'h06c;
	localparam [8:0] RV_PLIC_PRIO26_OFFSET = 9'h070;
	localparam [8:0] RV_PLIC_PRIO27_OFFSET = 9'h074;
	localparam [8:0] RV_PLIC_PRIO28_OFFSET = 9'h078;
	localparam [8:0] RV_PLIC_PRIO29_OFFSET = 9'h07c;
	localparam [8:0] RV_PLIC_PRIO30_OFFSET = 9'h080;
	localparam [8:0] RV_PLIC_PRIO31_OFFSET = 9'h084;
	localparam [8:0] RV_PLIC_IE0_OFFSET = 9'h100;
	localparam [8:0] RV_PLIC_THRESHOLD0_OFFSET = 9'h104;
	localparam [8:0] RV_PLIC_CC0_OFFSET = 9'h108;
	localparam [8:0] RV_PLIC_MSIP0_OFFSET = 9'h10c;
	localparam signed [31:0] RV_PLIC_IP = 0;
	localparam signed [31:0] RV_PLIC_LE = 1;
	localparam signed [31:0] RV_PLIC_PRIO0 = 2;
	localparam signed [31:0] RV_PLIC_PRIO1 = 3;
	localparam signed [31:0] RV_PLIC_PRIO2 = 4;
	localparam signed [31:0] RV_PLIC_PRIO3 = 5;
	localparam signed [31:0] RV_PLIC_PRIO4 = 6;
	localparam signed [31:0] RV_PLIC_PRIO5 = 7;
	localparam signed [31:0] RV_PLIC_PRIO6 = 8;
	localparam signed [31:0] RV_PLIC_PRIO7 = 9;
	localparam signed [31:0] RV_PLIC_PRIO8 = 10;
	localparam signed [31:0] RV_PLIC_PRIO9 = 11;
	localparam signed [31:0] RV_PLIC_PRIO10 = 12;
	localparam signed [31:0] RV_PLIC_PRIO11 = 13;
	localparam signed [31:0] RV_PLIC_PRIO12 = 14;
	localparam signed [31:0] RV_PLIC_PRIO13 = 15;
	localparam signed [31:0] RV_PLIC_PRIO14 = 16;
	localparam signed [31:0] RV_PLIC_PRIO15 = 17;
	localparam signed [31:0] RV_PLIC_PRIO16 = 18;
	localparam signed [31:0] RV_PLIC_PRIO17 = 19;
	localparam signed [31:0] RV_PLIC_PRIO18 = 20;
	localparam signed [31:0] RV_PLIC_PRIO19 = 21;
	localparam signed [31:0] RV_PLIC_PRIO20 = 22;
	localparam signed [31:0] RV_PLIC_PRIO21 = 23;
	localparam signed [31:0] RV_PLIC_PRIO22 = 24;
	localparam signed [31:0] RV_PLIC_PRIO23 = 25;
	localparam signed [31:0] RV_PLIC_PRIO24 = 26;
	localparam signed [31:0] RV_PLIC_PRIO25 = 27;
	localparam signed [31:0] RV_PLIC_PRIO26 = 28;
	localparam signed [31:0] RV_PLIC_PRIO27 = 29;
	localparam signed [31:0] RV_PLIC_PRIO28 = 30;
	localparam signed [31:0] RV_PLIC_PRIO29 = 31;
	localparam signed [31:0] RV_PLIC_PRIO30 = 32;
	localparam signed [31:0] RV_PLIC_PRIO31 = 33;
	localparam signed [31:0] RV_PLIC_IE0 = 34;
	localparam signed [31:0] RV_PLIC_THRESHOLD0 = 35;
	localparam signed [31:0] RV_PLIC_CC0 = 36;
	localparam signed [31:0] RV_PLIC_MSIP0 = 37;
	localparam [151:0] RV_PLIC_PERMIT = {4'b1111, 4'b1111, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b1111, 4'b0001, 4'b0001, 4'b0001};
	localparam signed [31:0] SRCW = 6;
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_o;
	input [NumSrc - 1:0] intr_src_i;
	output [NumTarget - 1:0] irq_o;
	output [((2 - NumTarget) * SRCW) + (((NumTarget - 1) * SRCW) - 1):(NumTarget - 1) * SRCW] irq_id_o;
	output wire [NumTarget - 1:0] msip_o;
	wire [171:0] reg2hw;
	wire [69:0] hw2reg;
	localparam signed [31:0] MAX_PRIO = 7;
	localparam signed [31:0] PRIOW = 3;
	wire [NumSrc - 1:0] le;
	wire [NumSrc - 1:0] ip;
	wire [NumSrc - 1:0] ie [0:NumTarget - 1];
	wire [NumTarget - 1:0] claim_re;
	wire [SRCW - 1:0] claim_id [0:NumTarget - 1];
	reg [NumSrc - 1:0] claim;
	wire [NumTarget - 1:0] complete_we;
	wire [SRCW - 1:0] complete_id [0:NumTarget - 1];
	reg [NumSrc - 1:0] complete;
	wire [((2 - NumTarget) * SRCW) + (((NumTarget - 1) * SRCW) - 1):(NumTarget - 1) * SRCW] cc_id;
	wire [(NumSrc * PRIOW) - 1:0] prio;
	wire [PRIOW - 1:0] threshold [0:NumTarget - 1];
	assign cc_id = irq_id_o;
	always @(*) begin
		claim = {NumSrc {1'sb0}};
		begin : sv2v_autoblock_79
			reg signed [31:0] i;
			for (i = 0; i < NumTarget; i = i + 1)
				if (claim_re[i])
					claim[claim_id[i]] = 1'b1;
		end
	end
	always @(*) begin
		complete = {NumSrc {1'sb0}};
		begin : sv2v_autoblock_80
			reg signed [31:0] i;
			for (i = 0; i < NumTarget; i = i + 1)
				if (complete_we[i])
					complete[complete_id[i]] = 1'b1;
		end
	end
	assign prio[(NumSrc - 1) * PRIOW+:PRIOW] = reg2hw[139-:3];
	assign prio[(NumSrc - 2) * PRIOW+:PRIOW] = reg2hw[136-:3];
	assign prio[(NumSrc - 3) * PRIOW+:PRIOW] = reg2hw[133-:3];
	assign prio[(NumSrc - 4) * PRIOW+:PRIOW] = reg2hw[130-:3];
	assign prio[(NumSrc - 5) * PRIOW+:PRIOW] = reg2hw[127-:3];
	assign prio[(NumSrc - 6) * PRIOW+:PRIOW] = reg2hw[124-:3];
	assign prio[(NumSrc - 7) * PRIOW+:PRIOW] = reg2hw[121-:3];
	assign prio[(NumSrc - 8) * PRIOW+:PRIOW] = reg2hw[118-:3];
	assign prio[(NumSrc - 9) * PRIOW+:PRIOW] = reg2hw[115-:3];
	assign prio[(NumSrc - 10) * PRIOW+:PRIOW] = reg2hw[112-:3];
	assign prio[(NumSrc - 11) * PRIOW+:PRIOW] = reg2hw[109-:3];
	assign prio[(NumSrc - 12) * PRIOW+:PRIOW] = reg2hw[106-:3];
	assign prio[(NumSrc - 13) * PRIOW+:PRIOW] = reg2hw[103-:3];
	assign prio[(NumSrc - 14) * PRIOW+:PRIOW] = reg2hw[100-:3];
	assign prio[(NumSrc - 15) * PRIOW+:PRIOW] = reg2hw[97-:3];
	assign prio[(NumSrc - 16) * PRIOW+:PRIOW] = reg2hw[94-:3];
	assign prio[(NumSrc - 17) * PRIOW+:PRIOW] = reg2hw[91-:3];
	assign prio[(NumSrc - 18) * PRIOW+:PRIOW] = reg2hw[88-:3];
	assign prio[(NumSrc - 19) * PRIOW+:PRIOW] = reg2hw[85-:3];
	assign prio[(NumSrc - 20) * PRIOW+:PRIOW] = reg2hw[82-:3];
	assign prio[(NumSrc - 21) * PRIOW+:PRIOW] = reg2hw[79-:3];
	assign prio[(NumSrc - 22) * PRIOW+:PRIOW] = reg2hw[76-:3];
	assign prio[(NumSrc - 23) * PRIOW+:PRIOW] = reg2hw[73-:3];
	assign prio[(NumSrc - 24) * PRIOW+:PRIOW] = reg2hw[70-:3];
	assign prio[(NumSrc - 25) * PRIOW+:PRIOW] = reg2hw[67-:3];
	assign prio[(NumSrc - 26) * PRIOW+:PRIOW] = reg2hw[64-:3];
	assign prio[(NumSrc - 27) * PRIOW+:PRIOW] = reg2hw[61-:3];
	assign prio[(NumSrc - 28) * PRIOW+:PRIOW] = reg2hw[58-:3];
	assign prio[(NumSrc - 29) * PRIOW+:PRIOW] = reg2hw[55-:3];
	assign prio[(NumSrc - 30) * PRIOW+:PRIOW] = reg2hw[52-:3];
	assign prio[(NumSrc - 31) * PRIOW+:PRIOW] = reg2hw[49-:3];
	assign prio[(NumSrc - 32) * PRIOW+:PRIOW] = reg2hw[46-:3];
	generate
		genvar s;
		for (s = 0; s < 32; s = s + 1) begin : gen_ie0
			assign ie[0][s] = reg2hw[12 + s];
		end
	endgenerate
	assign threshold[0] = reg2hw[11-:3];
	assign claim_re[0] = reg2hw[1];
	assign claim_id[0] = irq_id_o[0+:SRCW];
	assign complete_we[0] = reg2hw[2];
	assign complete_id[0] = reg2hw[8-:6];
	assign hw2reg[5-:6] = cc_id[0+:SRCW];
	assign msip_o[0] = reg2hw[-0];
	generate
		for (s = 0; s < 32; s = s + 1) begin : gen_ip
			assign hw2reg[6 + (s * 2)] = 1'b1;
			assign hw2reg[6 + ((s * 2) + 1)] = ip[s];
		end
	endgenerate
	generate
		for (s = 0; s < 32; s = s + 1) begin : gen_le
			assign le[s] = reg2hw[140 + s];
		end
	endgenerate
	rv_plic_gateway #(.N_SOURCE(NumSrc)) u_gateway(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.src_i(intr_src_i),
		.le_i(le),
		.claim_i(claim),
		.complete_i(complete),
		.ip_o(ip)
	);
	generate
		genvar i;
		for (i = 0; i < NumTarget; i = i + 1) begin : gen_target
			rv_plic_target #(
				.N_SOURCE(NumSrc),
				.MAX_PRIO(MAX_PRIO)
			) u_target(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.ip_i(ip),
				.ie_i(ie[i]),
				.prio_i(prio),
				.threshold_i(threshold[i]),
				.irq_o(irq_o[i]),
				.irq_id_o(irq_id_o[i * SRCW+:SRCW])
			);
		end
	endgenerate
	rv_plic_reg_top u_reg(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.devmode_i(1'b1)
	);
endmodule
module rv_plic_gateway (
	clk_i,
	rst_ni,
	src_i,
	le_i,
	claim_i,
	complete_i,
	ip_o
);
	parameter signed [31:0] N_SOURCE = 32;
	input clk_i;
	input rst_ni;
	input [N_SOURCE - 1:0] src_i;
	input [N_SOURCE - 1:0] le_i;
	input [N_SOURCE - 1:0] claim_i;
	input [N_SOURCE - 1:0] complete_i;
	output reg [N_SOURCE - 1:0] ip_o;
	reg [N_SOURCE - 1:0] ia;
	reg [N_SOURCE - 1:0] set;
	reg [N_SOURCE - 1:0] src_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			src_q <= {N_SOURCE {1'sb0}};
		else
			src_q <= src_i;
	always @(*) begin : sv2v_autoblock_81
		reg signed [31:0] i;
		for (i = 0; i < N_SOURCE; i = i + 1)
			set[i] = (le_i[i] ? src_i[i] & ~src_q[i] : src_i[i]);
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			ip_o <= {N_SOURCE {1'sb0}};
		else
			ip_o <= (ip_o | ((set & ~ia) & ~ip_o)) & ~(ip_o & claim_i);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			ia <= {N_SOURCE {1'sb0}};
		else
			ia <= (ia | (set & ~ia)) & ~((ia & complete_i) & ~ip_o);
endmodule
module rv_plic_reg_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	reg2hw,
	hw2reg,
	devmode_i
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_o;
	output wire [171:0] reg2hw;
	input wire [69:0] hw2reg;
	input devmode_i;
	localparam signed [31:0] NumSrc = 41;
	localparam signed [31:0] NumTarget = 1;
	localparam [8:0] RV_PLIC_IP_OFFSET = 9'h000;
	localparam [8:0] RV_PLIC_LE_OFFSET = 9'h004;
	localparam [8:0] RV_PLIC_PRIO0_OFFSET = 9'h008;
	localparam [8:0] RV_PLIC_PRIO1_OFFSET = 9'h00c;
	localparam [8:0] RV_PLIC_PRIO2_OFFSET = 9'h010;
	localparam [8:0] RV_PLIC_PRIO3_OFFSET = 9'h014;
	localparam [8:0] RV_PLIC_PRIO4_OFFSET = 9'h018;
	localparam [8:0] RV_PLIC_PRIO5_OFFSET = 9'h01c;
	localparam [8:0] RV_PLIC_PRIO6_OFFSET = 9'h020;
	localparam [8:0] RV_PLIC_PRIO7_OFFSET = 9'h024;
	localparam [8:0] RV_PLIC_PRIO8_OFFSET = 9'h028;
	localparam [8:0] RV_PLIC_PRIO9_OFFSET = 9'h02c;
	localparam [8:0] RV_PLIC_PRIO10_OFFSET = 9'h030;
	localparam [8:0] RV_PLIC_PRIO11_OFFSET = 9'h034;
	localparam [8:0] RV_PLIC_PRIO12_OFFSET = 9'h038;
	localparam [8:0] RV_PLIC_PRIO13_OFFSET = 9'h03c;
	localparam [8:0] RV_PLIC_PRIO14_OFFSET = 9'h040;
	localparam [8:0] RV_PLIC_PRIO15_OFFSET = 9'h044;
	localparam [8:0] RV_PLIC_PRIO16_OFFSET = 9'h048;
	localparam [8:0] RV_PLIC_PRIO17_OFFSET = 9'h04c;
	localparam [8:0] RV_PLIC_PRIO18_OFFSET = 9'h050;
	localparam [8:0] RV_PLIC_PRIO19_OFFSET = 9'h054;
	localparam [8:0] RV_PLIC_PRIO20_OFFSET = 9'h058;
	localparam [8:0] RV_PLIC_PRIO21_OFFSET = 9'h05c;
	localparam [8:0] RV_PLIC_PRIO22_OFFSET = 9'h060;
	localparam [8:0] RV_PLIC_PRIO23_OFFSET = 9'h064;
	localparam [8:0] RV_PLIC_PRIO24_OFFSET = 9'h068;
	localparam [8:0] RV_PLIC_PRIO25_OFFSET = 9'h06c;
	localparam [8:0] RV_PLIC_PRIO26_OFFSET = 9'h070;
	localparam [8:0] RV_PLIC_PRIO27_OFFSET = 9'h074;
	localparam [8:0] RV_PLIC_PRIO28_OFFSET = 9'h078;
	localparam [8:0] RV_PLIC_PRIO29_OFFSET = 9'h07c;
	localparam [8:0] RV_PLIC_PRIO30_OFFSET = 9'h080;
	localparam [8:0] RV_PLIC_PRIO31_OFFSET = 9'h084;
	localparam [8:0] RV_PLIC_IE0_OFFSET = 9'h100;
	localparam [8:0] RV_PLIC_THRESHOLD0_OFFSET = 9'h104;
	localparam [8:0] RV_PLIC_CC0_OFFSET = 9'h108;
	localparam [8:0] RV_PLIC_MSIP0_OFFSET = 9'h10c;
	localparam signed [31:0] RV_PLIC_IP = 0;
	localparam signed [31:0] RV_PLIC_LE = 1;
	localparam signed [31:0] RV_PLIC_PRIO0 = 2;
	localparam signed [31:0] RV_PLIC_PRIO1 = 3;
	localparam signed [31:0] RV_PLIC_PRIO2 = 4;
	localparam signed [31:0] RV_PLIC_PRIO3 = 5;
	localparam signed [31:0] RV_PLIC_PRIO4 = 6;
	localparam signed [31:0] RV_PLIC_PRIO5 = 7;
	localparam signed [31:0] RV_PLIC_PRIO6 = 8;
	localparam signed [31:0] RV_PLIC_PRIO7 = 9;
	localparam signed [31:0] RV_PLIC_PRIO8 = 10;
	localparam signed [31:0] RV_PLIC_PRIO9 = 11;
	localparam signed [31:0] RV_PLIC_PRIO10 = 12;
	localparam signed [31:0] RV_PLIC_PRIO11 = 13;
	localparam signed [31:0] RV_PLIC_PRIO12 = 14;
	localparam signed [31:0] RV_PLIC_PRIO13 = 15;
	localparam signed [31:0] RV_PLIC_PRIO14 = 16;
	localparam signed [31:0] RV_PLIC_PRIO15 = 17;
	localparam signed [31:0] RV_PLIC_PRIO16 = 18;
	localparam signed [31:0] RV_PLIC_PRIO17 = 19;
	localparam signed [31:0] RV_PLIC_PRIO18 = 20;
	localparam signed [31:0] RV_PLIC_PRIO19 = 21;
	localparam signed [31:0] RV_PLIC_PRIO20 = 22;
	localparam signed [31:0] RV_PLIC_PRIO21 = 23;
	localparam signed [31:0] RV_PLIC_PRIO22 = 24;
	localparam signed [31:0] RV_PLIC_PRIO23 = 25;
	localparam signed [31:0] RV_PLIC_PRIO24 = 26;
	localparam signed [31:0] RV_PLIC_PRIO25 = 27;
	localparam signed [31:0] RV_PLIC_PRIO26 = 28;
	localparam signed [31:0] RV_PLIC_PRIO27 = 29;
	localparam signed [31:0] RV_PLIC_PRIO28 = 30;
	localparam signed [31:0] RV_PLIC_PRIO29 = 31;
	localparam signed [31:0] RV_PLIC_PRIO30 = 32;
	localparam signed [31:0] RV_PLIC_PRIO31 = 33;
	localparam signed [31:0] RV_PLIC_IE0 = 34;
	localparam signed [31:0] RV_PLIC_THRESHOLD0 = 35;
	localparam signed [31:0] RV_PLIC_CC0 = 36;
	localparam signed [31:0] RV_PLIC_MSIP0 = 37;
	localparam [151:0] RV_PLIC_PERMIT = {4'b1111, 4'b1111, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b1111, 4'b0001, 4'b0001, 4'b0001};
	localparam signed [31:0] AW = 9;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] DBW = DW / 8;
	wire reg_we;
	wire reg_re;
	wire [AW - 1:0] reg_addr;
	wire [DW - 1:0] reg_wdata;
	wire [DBW - 1:0] reg_be;
	wire [DW - 1:0] reg_rdata;
	wire reg_error;
	wire addrmiss;
	reg wr_err;
	reg [DW - 1:0] reg_rdata_next;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_reg_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_reg_d2h;
	assign tl_reg_h2d = tl_i;
	assign tl_o = tl_reg_d2h;
	tlul_adapter_reg #(
		.RegAw(AW),
		.RegDw(DW)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_reg_h2d),
		.tl_o(tl_reg_d2h),
		.we_o(reg_we),
		.re_o(reg_re),
		.addr_o(reg_addr),
		.wdata_o(reg_wdata),
		.be_o(reg_be),
		.rdata_i(reg_rdata),
		.error_i(reg_error)
	);
	assign reg_rdata = reg_rdata_next;
	assign reg_error = (devmode_i & addrmiss) | wr_err;
	wire ip_p_0_qs;
	wire ip_p_1_qs;
	wire ip_p_2_qs;
	wire ip_p_3_qs;
	wire ip_p_4_qs;
	wire ip_p_5_qs;
	wire ip_p_6_qs;
	wire ip_p_7_qs;
	wire ip_p_8_qs;
	wire ip_p_9_qs;
	wire ip_p_10_qs;
	wire ip_p_11_qs;
	wire ip_p_12_qs;
	wire ip_p_13_qs;
	wire ip_p_14_qs;
	wire ip_p_15_qs;
	wire ip_p_16_qs;
	wire ip_p_17_qs;
	wire ip_p_18_qs;
	wire ip_p_19_qs;
	wire ip_p_20_qs;
	wire ip_p_21_qs;
	wire ip_p_22_qs;
	wire ip_p_23_qs;
	wire ip_p_24_qs;
	wire ip_p_25_qs;
	wire ip_p_26_qs;
	wire ip_p_27_qs;
	wire ip_p_28_qs;
	wire ip_p_29_qs;
	wire ip_p_30_qs;
	wire ip_p_31_qs;
	wire le_le_0_qs;
	wire le_le_0_wd;
	wire le_le_0_we;
	wire le_le_1_qs;
	wire le_le_1_wd;
	wire le_le_1_we;
	wire le_le_2_qs;
	wire le_le_2_wd;
	wire le_le_2_we;
	wire le_le_3_qs;
	wire le_le_3_wd;
	wire le_le_3_we;
	wire le_le_4_qs;
	wire le_le_4_wd;
	wire le_le_4_we;
	wire le_le_5_qs;
	wire le_le_5_wd;
	wire le_le_5_we;
	wire le_le_6_qs;
	wire le_le_6_wd;
	wire le_le_6_we;
	wire le_le_7_qs;
	wire le_le_7_wd;
	wire le_le_7_we;
	wire le_le_8_qs;
	wire le_le_8_wd;
	wire le_le_8_we;
	wire le_le_9_qs;
	wire le_le_9_wd;
	wire le_le_9_we;
	wire le_le_10_qs;
	wire le_le_10_wd;
	wire le_le_10_we;
	wire le_le_11_qs;
	wire le_le_11_wd;
	wire le_le_11_we;
	wire le_le_12_qs;
	wire le_le_12_wd;
	wire le_le_12_we;
	wire le_le_13_qs;
	wire le_le_13_wd;
	wire le_le_13_we;
	wire le_le_14_qs;
	wire le_le_14_wd;
	wire le_le_14_we;
	wire le_le_15_qs;
	wire le_le_15_wd;
	wire le_le_15_we;
	wire le_le_16_qs;
	wire le_le_16_wd;
	wire le_le_16_we;
	wire le_le_17_qs;
	wire le_le_17_wd;
	wire le_le_17_we;
	wire le_le_18_qs;
	wire le_le_18_wd;
	wire le_le_18_we;
	wire le_le_19_qs;
	wire le_le_19_wd;
	wire le_le_19_we;
	wire le_le_20_qs;
	wire le_le_20_wd;
	wire le_le_20_we;
	wire le_le_21_qs;
	wire le_le_21_wd;
	wire le_le_21_we;
	wire le_le_22_qs;
	wire le_le_22_wd;
	wire le_le_22_we;
	wire le_le_23_qs;
	wire le_le_23_wd;
	wire le_le_23_we;
	wire le_le_24_qs;
	wire le_le_24_wd;
	wire le_le_24_we;
	wire le_le_25_qs;
	wire le_le_25_wd;
	wire le_le_25_we;
	wire le_le_26_qs;
	wire le_le_26_wd;
	wire le_le_26_we;
	wire le_le_27_qs;
	wire le_le_27_wd;
	wire le_le_27_we;
	wire le_le_28_qs;
	wire le_le_28_wd;
	wire le_le_28_we;
	wire le_le_29_qs;
	wire le_le_29_wd;
	wire le_le_29_we;
	wire le_le_30_qs;
	wire le_le_30_wd;
	wire le_le_30_we;
	wire le_le_31_qs;
	wire le_le_31_wd;
	wire le_le_31_we;
	wire [2:0] prio0_qs;
	wire [2:0] prio0_wd;
	wire prio0_we;
	wire [2:0] prio1_qs;
	wire [2:0] prio1_wd;
	wire prio1_we;
	wire [2:0] prio2_qs;
	wire [2:0] prio2_wd;
	wire prio2_we;
	wire [2:0] prio3_qs;
	wire [2:0] prio3_wd;
	wire prio3_we;
	wire [2:0] prio4_qs;
	wire [2:0] prio4_wd;
	wire prio4_we;
	wire [2:0] prio5_qs;
	wire [2:0] prio5_wd;
	wire prio5_we;
	wire [2:0] prio6_qs;
	wire [2:0] prio6_wd;
	wire prio6_we;
	wire [2:0] prio7_qs;
	wire [2:0] prio7_wd;
	wire prio7_we;
	wire [2:0] prio8_qs;
	wire [2:0] prio8_wd;
	wire prio8_we;
	wire [2:0] prio9_qs;
	wire [2:0] prio9_wd;
	wire prio9_we;
	wire [2:0] prio10_qs;
	wire [2:0] prio10_wd;
	wire prio10_we;
	wire [2:0] prio11_qs;
	wire [2:0] prio11_wd;
	wire prio11_we;
	wire [2:0] prio12_qs;
	wire [2:0] prio12_wd;
	wire prio12_we;
	wire [2:0] prio13_qs;
	wire [2:0] prio13_wd;
	wire prio13_we;
	wire [2:0] prio14_qs;
	wire [2:0] prio14_wd;
	wire prio14_we;
	wire [2:0] prio15_qs;
	wire [2:0] prio15_wd;
	wire prio15_we;
	wire [2:0] prio16_qs;
	wire [2:0] prio16_wd;
	wire prio16_we;
	wire [2:0] prio17_qs;
	wire [2:0] prio17_wd;
	wire prio17_we;
	wire [2:0] prio18_qs;
	wire [2:0] prio18_wd;
	wire prio18_we;
	wire [2:0] prio19_qs;
	wire [2:0] prio19_wd;
	wire prio19_we;
	wire [2:0] prio20_qs;
	wire [2:0] prio20_wd;
	wire prio20_we;
	wire [2:0] prio21_qs;
	wire [2:0] prio21_wd;
	wire prio21_we;
	wire [2:0] prio22_qs;
	wire [2:0] prio22_wd;
	wire prio22_we;
	wire [2:0] prio23_qs;
	wire [2:0] prio23_wd;
	wire prio23_we;
	wire [2:0] prio24_qs;
	wire [2:0] prio24_wd;
	wire prio24_we;
	wire [2:0] prio25_qs;
	wire [2:0] prio25_wd;
	wire prio25_we;
	wire [2:0] prio26_qs;
	wire [2:0] prio26_wd;
	wire prio26_we;
	wire [2:0] prio27_qs;
	wire [2:0] prio27_wd;
	wire prio27_we;
	wire [2:0] prio28_qs;
	wire [2:0] prio28_wd;
	wire prio28_we;
	wire [2:0] prio29_qs;
	wire [2:0] prio29_wd;
	wire prio29_we;
	wire [2:0] prio30_qs;
	wire [2:0] prio30_wd;
	wire prio30_we;
	wire [2:0] prio31_qs;
	wire [2:0] prio31_wd;
	wire prio31_we;
	wire ie0_e_0_qs;
	wire ie0_e_0_wd;
	wire ie0_e_0_we;
	wire ie0_e_1_qs;
	wire ie0_e_1_wd;
	wire ie0_e_1_we;
	wire ie0_e_2_qs;
	wire ie0_e_2_wd;
	wire ie0_e_2_we;
	wire ie0_e_3_qs;
	wire ie0_e_3_wd;
	wire ie0_e_3_we;
	wire ie0_e_4_qs;
	wire ie0_e_4_wd;
	wire ie0_e_4_we;
	wire ie0_e_5_qs;
	wire ie0_e_5_wd;
	wire ie0_e_5_we;
	wire ie0_e_6_qs;
	wire ie0_e_6_wd;
	wire ie0_e_6_we;
	wire ie0_e_7_qs;
	wire ie0_e_7_wd;
	wire ie0_e_7_we;
	wire ie0_e_8_qs;
	wire ie0_e_8_wd;
	wire ie0_e_8_we;
	wire ie0_e_9_qs;
	wire ie0_e_9_wd;
	wire ie0_e_9_we;
	wire ie0_e_10_qs;
	wire ie0_e_10_wd;
	wire ie0_e_10_we;
	wire ie0_e_11_qs;
	wire ie0_e_11_wd;
	wire ie0_e_11_we;
	wire ie0_e_12_qs;
	wire ie0_e_12_wd;
	wire ie0_e_12_we;
	wire ie0_e_13_qs;
	wire ie0_e_13_wd;
	wire ie0_e_13_we;
	wire ie0_e_14_qs;
	wire ie0_e_14_wd;
	wire ie0_e_14_we;
	wire ie0_e_15_qs;
	wire ie0_e_15_wd;
	wire ie0_e_15_we;
	wire ie0_e_16_qs;
	wire ie0_e_16_wd;
	wire ie0_e_16_we;
	wire ie0_e_17_qs;
	wire ie0_e_17_wd;
	wire ie0_e_17_we;
	wire ie0_e_18_qs;
	wire ie0_e_18_wd;
	wire ie0_e_18_we;
	wire ie0_e_19_qs;
	wire ie0_e_19_wd;
	wire ie0_e_19_we;
	wire ie0_e_20_qs;
	wire ie0_e_20_wd;
	wire ie0_e_20_we;
	wire ie0_e_21_qs;
	wire ie0_e_21_wd;
	wire ie0_e_21_we;
	wire ie0_e_22_qs;
	wire ie0_e_22_wd;
	wire ie0_e_22_we;
	wire ie0_e_23_qs;
	wire ie0_e_23_wd;
	wire ie0_e_23_we;
	wire ie0_e_24_qs;
	wire ie0_e_24_wd;
	wire ie0_e_24_we;
	wire ie0_e_25_qs;
	wire ie0_e_25_wd;
	wire ie0_e_25_we;
	wire ie0_e_26_qs;
	wire ie0_e_26_wd;
	wire ie0_e_26_we;
	wire ie0_e_27_qs;
	wire ie0_e_27_wd;
	wire ie0_e_27_we;
	wire ie0_e_28_qs;
	wire ie0_e_28_wd;
	wire ie0_e_28_we;
	wire ie0_e_29_qs;
	wire ie0_e_29_wd;
	wire ie0_e_29_we;
	wire ie0_e_30_qs;
	wire ie0_e_30_wd;
	wire ie0_e_30_we;
	wire ie0_e_31_qs;
	wire ie0_e_31_wd;
	wire ie0_e_31_we;
	wire [2:0] threshold0_qs;
	wire [2:0] threshold0_wd;
	wire threshold0_we;
	wire [5:0] cc0_qs;
	wire [5:0] cc0_wd;
	wire cc0_we;
	wire cc0_re;
	wire msip0_qs;
	wire msip0_wd;
	wire msip0_we;
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[6]),
		.d(hw2reg[7]),
		.qe(),
		.q(),
		.qs(ip_p_0_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[8]),
		.d(hw2reg[9]),
		.qe(),
		.q(),
		.qs(ip_p_1_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[10]),
		.d(hw2reg[11]),
		.qe(),
		.q(),
		.qs(ip_p_2_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[12]),
		.d(hw2reg[13]),
		.qe(),
		.q(),
		.qs(ip_p_3_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[14]),
		.d(hw2reg[15]),
		.qe(),
		.q(),
		.qs(ip_p_4_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[16]),
		.d(hw2reg[17]),
		.qe(),
		.q(),
		.qs(ip_p_5_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[18]),
		.d(hw2reg[19]),
		.qe(),
		.q(),
		.qs(ip_p_6_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[20]),
		.d(hw2reg[21]),
		.qe(),
		.q(),
		.qs(ip_p_7_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[22]),
		.d(hw2reg[23]),
		.qe(),
		.q(),
		.qs(ip_p_8_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[24]),
		.d(hw2reg[25]),
		.qe(),
		.q(),
		.qs(ip_p_9_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[26]),
		.d(hw2reg[27]),
		.qe(),
		.q(),
		.qs(ip_p_10_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[28]),
		.d(hw2reg[29]),
		.qe(),
		.q(),
		.qs(ip_p_11_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[30]),
		.d(hw2reg[31]),
		.qe(),
		.q(),
		.qs(ip_p_12_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[32]),
		.d(hw2reg[33]),
		.qe(),
		.q(),
		.qs(ip_p_13_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[34]),
		.d(hw2reg[35]),
		.qe(),
		.q(),
		.qs(ip_p_14_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[36]),
		.d(hw2reg[37]),
		.qe(),
		.q(),
		.qs(ip_p_15_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[38]),
		.d(hw2reg[39]),
		.qe(),
		.q(),
		.qs(ip_p_16_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[40]),
		.d(hw2reg[41]),
		.qe(),
		.q(),
		.qs(ip_p_17_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[42]),
		.d(hw2reg[43]),
		.qe(),
		.q(),
		.qs(ip_p_18_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[44]),
		.d(hw2reg[45]),
		.qe(),
		.q(),
		.qs(ip_p_19_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[46]),
		.d(hw2reg[47]),
		.qe(),
		.q(),
		.qs(ip_p_20_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[48]),
		.d(hw2reg[49]),
		.qe(),
		.q(),
		.qs(ip_p_21_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[50]),
		.d(hw2reg[51]),
		.qe(),
		.q(),
		.qs(ip_p_22_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[52]),
		.d(hw2reg[53]),
		.qe(),
		.q(),
		.qs(ip_p_23_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[54]),
		.d(hw2reg[55]),
		.qe(),
		.q(),
		.qs(ip_p_24_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[56]),
		.d(hw2reg[57]),
		.qe(),
		.q(),
		.qs(ip_p_25_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[58]),
		.d(hw2reg[59]),
		.qe(),
		.q(),
		.qs(ip_p_26_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[60]),
		.d(hw2reg[61]),
		.qe(),
		.q(),
		.qs(ip_p_27_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[62]),
		.d(hw2reg[63]),
		.qe(),
		.q(),
		.qs(ip_p_28_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[64]),
		.d(hw2reg[65]),
		.qe(),
		.q(),
		.qs(ip_p_29_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[66]),
		.d(hw2reg[67]),
		.qe(),
		.q(),
		.qs(ip_p_30_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd(1'sb0),
		.de(hw2reg[68]),
		.d(hw2reg[69]),
		.qe(),
		.q(),
		.qs(ip_p_31_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_0_we),
		.wd(le_le_0_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[140]),
		.qs(le_le_0_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_1_we),
		.wd(le_le_1_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[141]),
		.qs(le_le_1_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_2_we),
		.wd(le_le_2_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[142]),
		.qs(le_le_2_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_3_we),
		.wd(le_le_3_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[143]),
		.qs(le_le_3_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_4_we),
		.wd(le_le_4_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[144]),
		.qs(le_le_4_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_5_we),
		.wd(le_le_5_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[145]),
		.qs(le_le_5_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_6_we),
		.wd(le_le_6_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[146]),
		.qs(le_le_6_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_7_we),
		.wd(le_le_7_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[147]),
		.qs(le_le_7_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_8_we),
		.wd(le_le_8_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[148]),
		.qs(le_le_8_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_9_we),
		.wd(le_le_9_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[149]),
		.qs(le_le_9_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_10_we),
		.wd(le_le_10_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[150]),
		.qs(le_le_10_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_11_we),
		.wd(le_le_11_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[151]),
		.qs(le_le_11_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_12_we),
		.wd(le_le_12_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[152]),
		.qs(le_le_12_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_13_we),
		.wd(le_le_13_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[153]),
		.qs(le_le_13_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_14_we),
		.wd(le_le_14_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[154]),
		.qs(le_le_14_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_15_we),
		.wd(le_le_15_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[155]),
		.qs(le_le_15_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_16_we),
		.wd(le_le_16_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[156]),
		.qs(le_le_16_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_17_we),
		.wd(le_le_17_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[157]),
		.qs(le_le_17_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_18_we),
		.wd(le_le_18_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[158]),
		.qs(le_le_18_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_19_we),
		.wd(le_le_19_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[159]),
		.qs(le_le_19_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_20_we),
		.wd(le_le_20_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[160]),
		.qs(le_le_20_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_21_we),
		.wd(le_le_21_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[161]),
		.qs(le_le_21_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_22_we),
		.wd(le_le_22_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[162]),
		.qs(le_le_22_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_23_we),
		.wd(le_le_23_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[163]),
		.qs(le_le_23_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_24_we),
		.wd(le_le_24_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[164]),
		.qs(le_le_24_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_25_we),
		.wd(le_le_25_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[165]),
		.qs(le_le_25_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_26_we),
		.wd(le_le_26_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[166]),
		.qs(le_le_26_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_27_we),
		.wd(le_le_27_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[167]),
		.qs(le_le_27_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_28_we),
		.wd(le_le_28_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[168]),
		.qs(le_le_28_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_29_we),
		.wd(le_le_29_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[169]),
		.qs(le_le_29_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_30_we),
		.wd(le_le_30_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[170]),
		.qs(le_le_30_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_31_we),
		.wd(le_le_31_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[171]),
		.qs(le_le_31_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio0_we),
		.wd(prio0_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[139-:3]),
		.qs(prio0_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio1_we),
		.wd(prio1_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[136-:3]),
		.qs(prio1_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio2_we),
		.wd(prio2_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[133-:3]),
		.qs(prio2_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio3_we),
		.wd(prio3_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[130-:3]),
		.qs(prio3_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio4_we),
		.wd(prio4_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[127-:3]),
		.qs(prio4_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio5_we),
		.wd(prio5_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[124-:3]),
		.qs(prio5_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio6_we),
		.wd(prio6_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[121-:3]),
		.qs(prio6_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio7_we),
		.wd(prio7_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[118-:3]),
		.qs(prio7_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio8_we),
		.wd(prio8_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[115-:3]),
		.qs(prio8_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio9_we),
		.wd(prio9_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[112-:3]),
		.qs(prio9_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio10_we),
		.wd(prio10_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[109-:3]),
		.qs(prio10_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio11_we),
		.wd(prio11_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[106-:3]),
		.qs(prio11_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio12_we),
		.wd(prio12_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[103-:3]),
		.qs(prio12_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio13_we),
		.wd(prio13_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[100-:3]),
		.qs(prio13_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio14_we),
		.wd(prio14_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[97-:3]),
		.qs(prio14_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio15_we),
		.wd(prio15_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[94-:3]),
		.qs(prio15_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio16_we),
		.wd(prio16_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[91-:3]),
		.qs(prio16_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio17_we),
		.wd(prio17_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[88-:3]),
		.qs(prio17_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio18_we),
		.wd(prio18_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[85-:3]),
		.qs(prio18_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio19_we),
		.wd(prio19_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[82-:3]),
		.qs(prio19_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio20_we),
		.wd(prio20_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[79-:3]),
		.qs(prio20_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio21_we),
		.wd(prio21_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[76-:3]),
		.qs(prio21_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio22_we),
		.wd(prio22_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[73-:3]),
		.qs(prio22_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio23_we),
		.wd(prio23_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[70-:3]),
		.qs(prio23_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio24_we),
		.wd(prio24_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[67-:3]),
		.qs(prio24_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio25_we),
		.wd(prio25_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[64-:3]),
		.qs(prio25_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio26_we),
		.wd(prio26_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[61-:3]),
		.qs(prio26_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio27_we),
		.wd(prio27_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[58-:3]),
		.qs(prio27_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio28_we),
		.wd(prio28_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[55-:3]),
		.qs(prio28_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio29_we),
		.wd(prio29_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[52-:3]),
		.qs(prio29_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio30_we),
		.wd(prio30_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[49-:3]),
		.qs(prio30_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio31_we),
		.wd(prio31_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[46-:3]),
		.qs(prio31_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_0_we),
		.wd(ie0_e_0_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[12]),
		.qs(ie0_e_0_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_1_we),
		.wd(ie0_e_1_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[13]),
		.qs(ie0_e_1_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_2_we),
		.wd(ie0_e_2_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[14]),
		.qs(ie0_e_2_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_3_we),
		.wd(ie0_e_3_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[15]),
		.qs(ie0_e_3_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_4_we),
		.wd(ie0_e_4_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[16]),
		.qs(ie0_e_4_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_5_we),
		.wd(ie0_e_5_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[17]),
		.qs(ie0_e_5_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_6_we),
		.wd(ie0_e_6_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[18]),
		.qs(ie0_e_6_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_7_we),
		.wd(ie0_e_7_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[19]),
		.qs(ie0_e_7_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_8_we),
		.wd(ie0_e_8_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[20]),
		.qs(ie0_e_8_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_9_we),
		.wd(ie0_e_9_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[21]),
		.qs(ie0_e_9_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_10_we),
		.wd(ie0_e_10_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[22]),
		.qs(ie0_e_10_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_11_we),
		.wd(ie0_e_11_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[23]),
		.qs(ie0_e_11_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_12_we),
		.wd(ie0_e_12_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[24]),
		.qs(ie0_e_12_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_13_we),
		.wd(ie0_e_13_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[25]),
		.qs(ie0_e_13_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_14_we),
		.wd(ie0_e_14_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[26]),
		.qs(ie0_e_14_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_15_we),
		.wd(ie0_e_15_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[27]),
		.qs(ie0_e_15_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_16_we),
		.wd(ie0_e_16_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[28]),
		.qs(ie0_e_16_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_17_we),
		.wd(ie0_e_17_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[29]),
		.qs(ie0_e_17_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_18_we),
		.wd(ie0_e_18_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[30]),
		.qs(ie0_e_18_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_19_we),
		.wd(ie0_e_19_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[31]),
		.qs(ie0_e_19_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_20_we),
		.wd(ie0_e_20_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[32]),
		.qs(ie0_e_20_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_21_we),
		.wd(ie0_e_21_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[33]),
		.qs(ie0_e_21_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_22_we),
		.wd(ie0_e_22_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[34]),
		.qs(ie0_e_22_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_23_we),
		.wd(ie0_e_23_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[35]),
		.qs(ie0_e_23_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_24_we),
		.wd(ie0_e_24_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[36]),
		.qs(ie0_e_24_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_25_we),
		.wd(ie0_e_25_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[37]),
		.qs(ie0_e_25_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_26_we),
		.wd(ie0_e_26_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[38]),
		.qs(ie0_e_26_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_27_we),
		.wd(ie0_e_27_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[39]),
		.qs(ie0_e_27_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_28_we),
		.wd(ie0_e_28_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[40]),
		.qs(ie0_e_28_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_29_we),
		.wd(ie0_e_29_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[41]),
		.qs(ie0_e_29_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_30_we),
		.wd(ie0_e_30_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[42]),
		.qs(ie0_e_30_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_31_we),
		.wd(ie0_e_31_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[43]),
		.qs(ie0_e_31_qs)
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_threshold0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(threshold0_we),
		.wd(threshold0_wd),
		.de(1'b0),
		.d({3 {1'sb0}}),
		.qe(),
		.q(reg2hw[11-:3]),
		.qs(threshold0_qs)
	);
	prim_subreg_ext #(.DW(6)) u_cc0(
		.re(cc0_re),
		.we(cc0_we),
		.wd(cc0_wd),
		.d(hw2reg[5-:6]),
		.qre(reg2hw[1]),
		.qe(reg2hw[2]),
		.q(reg2hw[8-:6]),
		.qs(cc0_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_msip0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(msip0_we),
		.wd(msip0_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[-0]),
		.qs(msip0_qs)
	);
	reg [37:0] addr_hit;
	always @(*) begin
		addr_hit = {38 {1'sb0}};
		addr_hit[0] = reg_addr == RV_PLIC_IP_OFFSET;
		addr_hit[1] = reg_addr == RV_PLIC_LE_OFFSET;
		addr_hit[2] = reg_addr == RV_PLIC_PRIO0_OFFSET;
		addr_hit[3] = reg_addr == RV_PLIC_PRIO1_OFFSET;
		addr_hit[4] = reg_addr == RV_PLIC_PRIO2_OFFSET;
		addr_hit[5] = reg_addr == RV_PLIC_PRIO3_OFFSET;
		addr_hit[6] = reg_addr == RV_PLIC_PRIO4_OFFSET;
		addr_hit[7] = reg_addr == RV_PLIC_PRIO5_OFFSET;
		addr_hit[8] = reg_addr == RV_PLIC_PRIO6_OFFSET;
		addr_hit[9] = reg_addr == RV_PLIC_PRIO7_OFFSET;
		addr_hit[10] = reg_addr == RV_PLIC_PRIO8_OFFSET;
		addr_hit[11] = reg_addr == RV_PLIC_PRIO9_OFFSET;
		addr_hit[12] = reg_addr == RV_PLIC_PRIO10_OFFSET;
		addr_hit[13] = reg_addr == RV_PLIC_PRIO11_OFFSET;
		addr_hit[14] = reg_addr == RV_PLIC_PRIO12_OFFSET;
		addr_hit[15] = reg_addr == RV_PLIC_PRIO13_OFFSET;
		addr_hit[16] = reg_addr == RV_PLIC_PRIO14_OFFSET;
		addr_hit[17] = reg_addr == RV_PLIC_PRIO15_OFFSET;
		addr_hit[18] = reg_addr == RV_PLIC_PRIO16_OFFSET;
		addr_hit[19] = reg_addr == RV_PLIC_PRIO17_OFFSET;
		addr_hit[20] = reg_addr == RV_PLIC_PRIO18_OFFSET;
		addr_hit[21] = reg_addr == RV_PLIC_PRIO19_OFFSET;
		addr_hit[22] = reg_addr == RV_PLIC_PRIO20_OFFSET;
		addr_hit[23] = reg_addr == RV_PLIC_PRIO21_OFFSET;
		addr_hit[24] = reg_addr == RV_PLIC_PRIO22_OFFSET;
		addr_hit[25] = reg_addr == RV_PLIC_PRIO23_OFFSET;
		addr_hit[26] = reg_addr == RV_PLIC_PRIO24_OFFSET;
		addr_hit[27] = reg_addr == RV_PLIC_PRIO25_OFFSET;
		addr_hit[28] = reg_addr == RV_PLIC_PRIO26_OFFSET;
		addr_hit[29] = reg_addr == RV_PLIC_PRIO27_OFFSET;
		addr_hit[30] = reg_addr == RV_PLIC_PRIO28_OFFSET;
		addr_hit[31] = reg_addr == RV_PLIC_PRIO29_OFFSET;
		addr_hit[32] = reg_addr == RV_PLIC_PRIO30_OFFSET;
		addr_hit[33] = reg_addr == RV_PLIC_PRIO31_OFFSET;
		addr_hit[34] = reg_addr == RV_PLIC_IE0_OFFSET;
		addr_hit[35] = reg_addr == RV_PLIC_THRESHOLD0_OFFSET;
		addr_hit[36] = reg_addr == RV_PLIC_CC0_OFFSET;
		addr_hit[37] = reg_addr == RV_PLIC_MSIP0_OFFSET;
	end
	assign addrmiss = (reg_re || reg_we ? ~|addr_hit : 1'b0);
	always @(*) begin
		wr_err = 1'b0;
		if ((addr_hit[0] && reg_we) && (RV_PLIC_PERMIT[148+:4] != (RV_PLIC_PERMIT[148+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[1] && reg_we) && (RV_PLIC_PERMIT[144+:4] != (RV_PLIC_PERMIT[144+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[2] && reg_we) && (RV_PLIC_PERMIT[140+:4] != (RV_PLIC_PERMIT[140+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[3] && reg_we) && (RV_PLIC_PERMIT[136+:4] != (RV_PLIC_PERMIT[136+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[4] && reg_we) && (RV_PLIC_PERMIT[132+:4] != (RV_PLIC_PERMIT[132+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[5] && reg_we) && (RV_PLIC_PERMIT[128+:4] != (RV_PLIC_PERMIT[128+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[6] && reg_we) && (RV_PLIC_PERMIT[124+:4] != (RV_PLIC_PERMIT[124+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[7] && reg_we) && (RV_PLIC_PERMIT[120+:4] != (RV_PLIC_PERMIT[120+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[8] && reg_we) && (RV_PLIC_PERMIT[116+:4] != (RV_PLIC_PERMIT[116+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[9] && reg_we) && (RV_PLIC_PERMIT[112+:4] != (RV_PLIC_PERMIT[112+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[10] && reg_we) && (RV_PLIC_PERMIT[108+:4] != (RV_PLIC_PERMIT[108+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[11] && reg_we) && (RV_PLIC_PERMIT[104+:4] != (RV_PLIC_PERMIT[104+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[12] && reg_we) && (RV_PLIC_PERMIT[100+:4] != (RV_PLIC_PERMIT[100+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[13] && reg_we) && (RV_PLIC_PERMIT[96+:4] != (RV_PLIC_PERMIT[96+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[14] && reg_we) && (RV_PLIC_PERMIT[92+:4] != (RV_PLIC_PERMIT[92+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[15] && reg_we) && (RV_PLIC_PERMIT[88+:4] != (RV_PLIC_PERMIT[88+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[16] && reg_we) && (RV_PLIC_PERMIT[84+:4] != (RV_PLIC_PERMIT[84+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[17] && reg_we) && (RV_PLIC_PERMIT[80+:4] != (RV_PLIC_PERMIT[80+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[18] && reg_we) && (RV_PLIC_PERMIT[76+:4] != (RV_PLIC_PERMIT[76+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[19] && reg_we) && (RV_PLIC_PERMIT[72+:4] != (RV_PLIC_PERMIT[72+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[20] && reg_we) && (RV_PLIC_PERMIT[68+:4] != (RV_PLIC_PERMIT[68+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[21] && reg_we) && (RV_PLIC_PERMIT[64+:4] != (RV_PLIC_PERMIT[64+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[22] && reg_we) && (RV_PLIC_PERMIT[60+:4] != (RV_PLIC_PERMIT[60+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[23] && reg_we) && (RV_PLIC_PERMIT[56+:4] != (RV_PLIC_PERMIT[56+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[24] && reg_we) && (RV_PLIC_PERMIT[52+:4] != (RV_PLIC_PERMIT[52+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[25] && reg_we) && (RV_PLIC_PERMIT[48+:4] != (RV_PLIC_PERMIT[48+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[26] && reg_we) && (RV_PLIC_PERMIT[44+:4] != (RV_PLIC_PERMIT[44+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[27] && reg_we) && (RV_PLIC_PERMIT[40+:4] != (RV_PLIC_PERMIT[40+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[28] && reg_we) && (RV_PLIC_PERMIT[36+:4] != (RV_PLIC_PERMIT[36+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[29] && reg_we) && (RV_PLIC_PERMIT[32+:4] != (RV_PLIC_PERMIT[32+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[30] && reg_we) && (RV_PLIC_PERMIT[28+:4] != (RV_PLIC_PERMIT[28+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[31] && reg_we) && (RV_PLIC_PERMIT[24+:4] != (RV_PLIC_PERMIT[24+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[32] && reg_we) && (RV_PLIC_PERMIT[20+:4] != (RV_PLIC_PERMIT[20+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[33] && reg_we) && (RV_PLIC_PERMIT[16+:4] != (RV_PLIC_PERMIT[16+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[34] && reg_we) && (RV_PLIC_PERMIT[12+:4] != (RV_PLIC_PERMIT[12+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[35] && reg_we) && (RV_PLIC_PERMIT[8+:4] != (RV_PLIC_PERMIT[8+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[36] && reg_we) && (RV_PLIC_PERMIT[4+:4] != (RV_PLIC_PERMIT[4+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[37] && reg_we) && (RV_PLIC_PERMIT[0+:4] != (RV_PLIC_PERMIT[0+:4] & reg_be)))
			wr_err = 1'b1;
	end
	assign le_le_0_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_0_wd = reg_wdata[0];
	assign le_le_1_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_1_wd = reg_wdata[1];
	assign le_le_2_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_2_wd = reg_wdata[2];
	assign le_le_3_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_3_wd = reg_wdata[3];
	assign le_le_4_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_4_wd = reg_wdata[4];
	assign le_le_5_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_5_wd = reg_wdata[5];
	assign le_le_6_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_6_wd = reg_wdata[6];
	assign le_le_7_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_7_wd = reg_wdata[7];
	assign le_le_8_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_8_wd = reg_wdata[8];
	assign le_le_9_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_9_wd = reg_wdata[9];
	assign le_le_10_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_10_wd = reg_wdata[10];
	assign le_le_11_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_11_wd = reg_wdata[11];
	assign le_le_12_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_12_wd = reg_wdata[12];
	assign le_le_13_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_13_wd = reg_wdata[13];
	assign le_le_14_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_14_wd = reg_wdata[14];
	assign le_le_15_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_15_wd = reg_wdata[15];
	assign le_le_16_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_16_wd = reg_wdata[16];
	assign le_le_17_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_17_wd = reg_wdata[17];
	assign le_le_18_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_18_wd = reg_wdata[18];
	assign le_le_19_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_19_wd = reg_wdata[19];
	assign le_le_20_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_20_wd = reg_wdata[20];
	assign le_le_21_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_21_wd = reg_wdata[21];
	assign le_le_22_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_22_wd = reg_wdata[22];
	assign le_le_23_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_23_wd = reg_wdata[23];
	assign le_le_24_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_24_wd = reg_wdata[24];
	assign le_le_25_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_25_wd = reg_wdata[25];
	assign le_le_26_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_26_wd = reg_wdata[26];
	assign le_le_27_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_27_wd = reg_wdata[27];
	assign le_le_28_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_28_wd = reg_wdata[28];
	assign le_le_29_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_29_wd = reg_wdata[29];
	assign le_le_30_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_30_wd = reg_wdata[30];
	assign le_le_31_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_31_wd = reg_wdata[31];
	assign prio0_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign prio0_wd = reg_wdata[2:0];
	assign prio1_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign prio1_wd = reg_wdata[2:0];
	assign prio2_we = (addr_hit[4] & reg_we) & ~wr_err;
	assign prio2_wd = reg_wdata[2:0];
	assign prio3_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign prio3_wd = reg_wdata[2:0];
	assign prio4_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign prio4_wd = reg_wdata[2:0];
	assign prio5_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign prio5_wd = reg_wdata[2:0];
	assign prio6_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign prio6_wd = reg_wdata[2:0];
	assign prio7_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign prio7_wd = reg_wdata[2:0];
	assign prio8_we = (addr_hit[10] & reg_we) & ~wr_err;
	assign prio8_wd = reg_wdata[2:0];
	assign prio9_we = (addr_hit[11] & reg_we) & ~wr_err;
	assign prio9_wd = reg_wdata[2:0];
	assign prio10_we = (addr_hit[12] & reg_we) & ~wr_err;
	assign prio10_wd = reg_wdata[2:0];
	assign prio11_we = (addr_hit[13] & reg_we) & ~wr_err;
	assign prio11_wd = reg_wdata[2:0];
	assign prio12_we = (addr_hit[14] & reg_we) & ~wr_err;
	assign prio12_wd = reg_wdata[2:0];
	assign prio13_we = (addr_hit[15] & reg_we) & ~wr_err;
	assign prio13_wd = reg_wdata[2:0];
	assign prio14_we = (addr_hit[16] & reg_we) & ~wr_err;
	assign prio14_wd = reg_wdata[2:0];
	assign prio15_we = (addr_hit[17] & reg_we) & ~wr_err;
	assign prio15_wd = reg_wdata[2:0];
	assign prio16_we = (addr_hit[18] & reg_we) & ~wr_err;
	assign prio16_wd = reg_wdata[2:0];
	assign prio17_we = (addr_hit[19] & reg_we) & ~wr_err;
	assign prio17_wd = reg_wdata[2:0];
	assign prio18_we = (addr_hit[20] & reg_we) & ~wr_err;
	assign prio18_wd = reg_wdata[2:0];
	assign prio19_we = (addr_hit[21] & reg_we) & ~wr_err;
	assign prio19_wd = reg_wdata[2:0];
	assign prio20_we = (addr_hit[22] & reg_we) & ~wr_err;
	assign prio20_wd = reg_wdata[2:0];
	assign prio21_we = (addr_hit[23] & reg_we) & ~wr_err;
	assign prio21_wd = reg_wdata[2:0];
	assign prio22_we = (addr_hit[24] & reg_we) & ~wr_err;
	assign prio22_wd = reg_wdata[2:0];
	assign prio23_we = (addr_hit[25] & reg_we) & ~wr_err;
	assign prio23_wd = reg_wdata[2:0];
	assign prio24_we = (addr_hit[26] & reg_we) & ~wr_err;
	assign prio24_wd = reg_wdata[2:0];
	assign prio25_we = (addr_hit[27] & reg_we) & ~wr_err;
	assign prio25_wd = reg_wdata[2:0];
	assign prio26_we = (addr_hit[28] & reg_we) & ~wr_err;
	assign prio26_wd = reg_wdata[2:0];
	assign prio27_we = (addr_hit[29] & reg_we) & ~wr_err;
	assign prio27_wd = reg_wdata[2:0];
	assign prio28_we = (addr_hit[30] & reg_we) & ~wr_err;
	assign prio28_wd = reg_wdata[2:0];
	assign prio29_we = (addr_hit[31] & reg_we) & ~wr_err;
	assign prio29_wd = reg_wdata[2:0];
	assign prio30_we = (addr_hit[32] & reg_we) & ~wr_err;
	assign prio30_wd = reg_wdata[2:0];
	assign prio31_we = (addr_hit[33] & reg_we) & ~wr_err;
	assign prio31_wd = reg_wdata[2:0];
	assign ie0_e_0_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_0_wd = reg_wdata[0];
	assign ie0_e_1_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_1_wd = reg_wdata[1];
	assign ie0_e_2_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_2_wd = reg_wdata[2];
	assign ie0_e_3_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_3_wd = reg_wdata[3];
	assign ie0_e_4_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_4_wd = reg_wdata[4];
	assign ie0_e_5_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_5_wd = reg_wdata[5];
	assign ie0_e_6_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_6_wd = reg_wdata[6];
	assign ie0_e_7_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_7_wd = reg_wdata[7];
	assign ie0_e_8_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_8_wd = reg_wdata[8];
	assign ie0_e_9_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_9_wd = reg_wdata[9];
	assign ie0_e_10_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_10_wd = reg_wdata[10];
	assign ie0_e_11_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_11_wd = reg_wdata[11];
	assign ie0_e_12_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_12_wd = reg_wdata[12];
	assign ie0_e_13_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_13_wd = reg_wdata[13];
	assign ie0_e_14_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_14_wd = reg_wdata[14];
	assign ie0_e_15_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_15_wd = reg_wdata[15];
	assign ie0_e_16_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_16_wd = reg_wdata[16];
	assign ie0_e_17_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_17_wd = reg_wdata[17];
	assign ie0_e_18_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_18_wd = reg_wdata[18];
	assign ie0_e_19_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_19_wd = reg_wdata[19];
	assign ie0_e_20_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_20_wd = reg_wdata[20];
	assign ie0_e_21_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_21_wd = reg_wdata[21];
	assign ie0_e_22_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_22_wd = reg_wdata[22];
	assign ie0_e_23_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_23_wd = reg_wdata[23];
	assign ie0_e_24_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_24_wd = reg_wdata[24];
	assign ie0_e_25_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_25_wd = reg_wdata[25];
	assign ie0_e_26_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_26_wd = reg_wdata[26];
	assign ie0_e_27_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_27_wd = reg_wdata[27];
	assign ie0_e_28_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_28_wd = reg_wdata[28];
	assign ie0_e_29_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_29_wd = reg_wdata[29];
	assign ie0_e_30_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_30_wd = reg_wdata[30];
	assign ie0_e_31_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_31_wd = reg_wdata[31];
	assign threshold0_we = (addr_hit[35] & reg_we) & ~wr_err;
	assign threshold0_wd = reg_wdata[2:0];
	assign cc0_we = (addr_hit[36] & reg_we) & ~wr_err;
	assign cc0_wd = reg_wdata[5:0];
	assign cc0_re = addr_hit[36] && reg_re;
	assign msip0_we = (addr_hit[37] & reg_we) & ~wr_err;
	assign msip0_wd = reg_wdata[0];
	always @(*) begin
		reg_rdata_next = {DW {1'sb0}};
		case (1'b1)
			addr_hit[0]: begin
				reg_rdata_next[0] = ip_p_0_qs;
				reg_rdata_next[1] = ip_p_1_qs;
				reg_rdata_next[2] = ip_p_2_qs;
				reg_rdata_next[3] = ip_p_3_qs;
				reg_rdata_next[4] = ip_p_4_qs;
				reg_rdata_next[5] = ip_p_5_qs;
				reg_rdata_next[6] = ip_p_6_qs;
				reg_rdata_next[7] = ip_p_7_qs;
				reg_rdata_next[8] = ip_p_8_qs;
				reg_rdata_next[9] = ip_p_9_qs;
				reg_rdata_next[10] = ip_p_10_qs;
				reg_rdata_next[11] = ip_p_11_qs;
				reg_rdata_next[12] = ip_p_12_qs;
				reg_rdata_next[13] = ip_p_13_qs;
				reg_rdata_next[14] = ip_p_14_qs;
				reg_rdata_next[15] = ip_p_15_qs;
				reg_rdata_next[16] = ip_p_16_qs;
				reg_rdata_next[17] = ip_p_17_qs;
				reg_rdata_next[18] = ip_p_18_qs;
				reg_rdata_next[19] = ip_p_19_qs;
				reg_rdata_next[20] = ip_p_20_qs;
				reg_rdata_next[21] = ip_p_21_qs;
				reg_rdata_next[22] = ip_p_22_qs;
				reg_rdata_next[23] = ip_p_23_qs;
				reg_rdata_next[24] = ip_p_24_qs;
				reg_rdata_next[25] = ip_p_25_qs;
				reg_rdata_next[26] = ip_p_26_qs;
				reg_rdata_next[27] = ip_p_27_qs;
				reg_rdata_next[28] = ip_p_28_qs;
				reg_rdata_next[29] = ip_p_29_qs;
				reg_rdata_next[30] = ip_p_30_qs;
				reg_rdata_next[31] = ip_p_31_qs;
			end
			addr_hit[1]: begin
				reg_rdata_next[0] = le_le_0_qs;
				reg_rdata_next[1] = le_le_1_qs;
				reg_rdata_next[2] = le_le_2_qs;
				reg_rdata_next[3] = le_le_3_qs;
				reg_rdata_next[4] = le_le_4_qs;
				reg_rdata_next[5] = le_le_5_qs;
				reg_rdata_next[6] = le_le_6_qs;
				reg_rdata_next[7] = le_le_7_qs;
				reg_rdata_next[8] = le_le_8_qs;
				reg_rdata_next[9] = le_le_9_qs;
				reg_rdata_next[10] = le_le_10_qs;
				reg_rdata_next[11] = le_le_11_qs;
				reg_rdata_next[12] = le_le_12_qs;
				reg_rdata_next[13] = le_le_13_qs;
				reg_rdata_next[14] = le_le_14_qs;
				reg_rdata_next[15] = le_le_15_qs;
				reg_rdata_next[16] = le_le_16_qs;
				reg_rdata_next[17] = le_le_17_qs;
				reg_rdata_next[18] = le_le_18_qs;
				reg_rdata_next[19] = le_le_19_qs;
				reg_rdata_next[20] = le_le_20_qs;
				reg_rdata_next[21] = le_le_21_qs;
				reg_rdata_next[22] = le_le_22_qs;
				reg_rdata_next[23] = le_le_23_qs;
				reg_rdata_next[24] = le_le_24_qs;
				reg_rdata_next[25] = le_le_25_qs;
				reg_rdata_next[26] = le_le_26_qs;
				reg_rdata_next[27] = le_le_27_qs;
				reg_rdata_next[28] = le_le_28_qs;
				reg_rdata_next[29] = le_le_29_qs;
				reg_rdata_next[30] = le_le_30_qs;
				reg_rdata_next[31] = le_le_31_qs;
			end
			addr_hit[2]: reg_rdata_next[2:0] = prio0_qs;
			addr_hit[3]: reg_rdata_next[2:0] = prio1_qs;
			addr_hit[4]: reg_rdata_next[2:0] = prio2_qs;
			addr_hit[5]: reg_rdata_next[2:0] = prio3_qs;
			addr_hit[6]: reg_rdata_next[2:0] = prio4_qs;
			addr_hit[7]: reg_rdata_next[2:0] = prio5_qs;
			addr_hit[8]: reg_rdata_next[2:0] = prio6_qs;
			addr_hit[9]: reg_rdata_next[2:0] = prio7_qs;
			addr_hit[10]: reg_rdata_next[2:0] = prio8_qs;
			addr_hit[11]: reg_rdata_next[2:0] = prio9_qs;
			addr_hit[12]: reg_rdata_next[2:0] = prio10_qs;
			addr_hit[13]: reg_rdata_next[2:0] = prio11_qs;
			addr_hit[14]: reg_rdata_next[2:0] = prio12_qs;
			addr_hit[15]: reg_rdata_next[2:0] = prio13_qs;
			addr_hit[16]: reg_rdata_next[2:0] = prio14_qs;
			addr_hit[17]: reg_rdata_next[2:0] = prio15_qs;
			addr_hit[18]: reg_rdata_next[2:0] = prio16_qs;
			addr_hit[19]: reg_rdata_next[2:0] = prio17_qs;
			addr_hit[20]: reg_rdata_next[2:0] = prio18_qs;
			addr_hit[21]: reg_rdata_next[2:0] = prio19_qs;
			addr_hit[22]: reg_rdata_next[2:0] = prio20_qs;
			addr_hit[23]: reg_rdata_next[2:0] = prio21_qs;
			addr_hit[24]: reg_rdata_next[2:0] = prio22_qs;
			addr_hit[25]: reg_rdata_next[2:0] = prio23_qs;
			addr_hit[26]: reg_rdata_next[2:0] = prio24_qs;
			addr_hit[27]: reg_rdata_next[2:0] = prio25_qs;
			addr_hit[28]: reg_rdata_next[2:0] = prio26_qs;
			addr_hit[29]: reg_rdata_next[2:0] = prio27_qs;
			addr_hit[30]: reg_rdata_next[2:0] = prio28_qs;
			addr_hit[31]: reg_rdata_next[2:0] = prio29_qs;
			addr_hit[32]: reg_rdata_next[2:0] = prio30_qs;
			addr_hit[33]: reg_rdata_next[2:0] = prio31_qs;
			addr_hit[34]: begin
				reg_rdata_next[0] = ie0_e_0_qs;
				reg_rdata_next[1] = ie0_e_1_qs;
				reg_rdata_next[2] = ie0_e_2_qs;
				reg_rdata_next[3] = ie0_e_3_qs;
				reg_rdata_next[4] = ie0_e_4_qs;
				reg_rdata_next[5] = ie0_e_5_qs;
				reg_rdata_next[6] = ie0_e_6_qs;
				reg_rdata_next[7] = ie0_e_7_qs;
				reg_rdata_next[8] = ie0_e_8_qs;
				reg_rdata_next[9] = ie0_e_9_qs;
				reg_rdata_next[10] = ie0_e_10_qs;
				reg_rdata_next[11] = ie0_e_11_qs;
				reg_rdata_next[12] = ie0_e_12_qs;
				reg_rdata_next[13] = ie0_e_13_qs;
				reg_rdata_next[14] = ie0_e_14_qs;
				reg_rdata_next[15] = ie0_e_15_qs;
				reg_rdata_next[16] = ie0_e_16_qs;
				reg_rdata_next[17] = ie0_e_17_qs;
				reg_rdata_next[18] = ie0_e_18_qs;
				reg_rdata_next[19] = ie0_e_19_qs;
				reg_rdata_next[20] = ie0_e_20_qs;
				reg_rdata_next[21] = ie0_e_21_qs;
				reg_rdata_next[22] = ie0_e_22_qs;
				reg_rdata_next[23] = ie0_e_23_qs;
				reg_rdata_next[24] = ie0_e_24_qs;
				reg_rdata_next[25] = ie0_e_25_qs;
				reg_rdata_next[26] = ie0_e_26_qs;
				reg_rdata_next[27] = ie0_e_27_qs;
				reg_rdata_next[28] = ie0_e_28_qs;
				reg_rdata_next[29] = ie0_e_29_qs;
				reg_rdata_next[30] = ie0_e_30_qs;
				reg_rdata_next[31] = ie0_e_31_qs;
			end
			addr_hit[35]: reg_rdata_next[2:0] = threshold0_qs;
			addr_hit[36]: reg_rdata_next[5:0] = cc0_qs;
			addr_hit[37]: reg_rdata_next[0] = msip0_qs;
			default: reg_rdata_next = {DW {1'sb1}};
		endcase
	end
endmodule
module rv_plic_target (
	clk_i,
	rst_ni,
	ip_i,
	ie_i,
	prio_i,
	threshold_i,
	irq_o,
	irq_id_o
);
	parameter signed [31:0] N_SOURCE = 32;
	parameter signed [31:0] MAX_PRIO = 7;
	localparam signed [31:0] SrcWidth = $clog2(N_SOURCE + 1);
	localparam signed [31:0] PrioWidth = $clog2(MAX_PRIO + 1);
	input clk_i;
	input rst_ni;
	input [N_SOURCE - 1:0] ip_i;
	input [N_SOURCE - 1:0] ie_i;
	input [(0 >= (N_SOURCE - 1) ? ((2 - N_SOURCE) * PrioWidth) + (((N_SOURCE - 1) * PrioWidth) - 1) : (N_SOURCE * PrioWidth) - 1):(0 >= (N_SOURCE - 1) ? (N_SOURCE - 1) * PrioWidth : 0)] prio_i;
	input [PrioWidth - 1:0] threshold_i;
	output wire irq_o;
	output wire [SrcWidth - 1:0] irq_id_o;
	localparam signed [31:0] NumLevels = $clog2(N_SOURCE);
	wire [(2 ** (NumLevels + 1)) - 2:0] is_tree;
	wire [(((2 ** (NumLevels + 1)) - 2) >= 0 ? (((2 ** (NumLevels + 1)) - 1) * SrcWidth) - 1 : ((3 - (2 ** (NumLevels + 1))) * SrcWidth) + ((((2 ** (NumLevels + 1)) - 2) * SrcWidth) - 1)):(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : ((2 ** (NumLevels + 1)) - 2) * SrcWidth)] id_tree;
	wire [(((2 ** (NumLevels + 1)) - 2) >= 0 ? (((2 ** (NumLevels + 1)) - 1) * PrioWidth) - 1 : ((3 - (2 ** (NumLevels + 1))) * PrioWidth) + ((((2 ** (NumLevels + 1)) - 2) * PrioWidth) - 1)):(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : ((2 ** (NumLevels + 1)) - 2) * PrioWidth)] max_tree;
	generate
		genvar level;
		for (level = 0; level < (NumLevels + 1); level = level + 1) begin : gen_tree
			localparam signed [31:0] Base0 = (2 ** level) - 1;
			localparam signed [31:0] Base1 = (2 ** (level + 1)) - 1;
			genvar offset;
			for (offset = 0; offset < (2 ** level); offset = offset + 1) begin : gen_level
				localparam signed [31:0] Pa = Base0 + offset;
				localparam signed [31:0] C0 = Base1 + (2 * offset);
				localparam signed [31:0] C1 = (Base1 + (2 * offset)) + 1;
				if (level == NumLevels) begin : gen_leafs
					if (offset < N_SOURCE) begin : gen_assign
						assign is_tree[Pa] = ip_i[offset] & ie_i[offset];
						assign id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * SrcWidth+:SrcWidth] = offset;
						assign max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * PrioWidth+:PrioWidth] = prio_i[(0 >= (N_SOURCE - 1) ? offset : (N_SOURCE - 1) - offset) * PrioWidth+:PrioWidth];
					end
					else begin : gen_tie_off
						assign is_tree[Pa] = 1'sb0;
						assign id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * SrcWidth+:SrcWidth] = {SrcWidth {1'sb0}};
						assign max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * PrioWidth+:PrioWidth] = {PrioWidth {1'sb0}};
					end
				end
				else begin : gen_nodes
					wire sel;
					function automatic [0:0] sv2v_cast_1;
						input reg [0:0] inp;
						sv2v_cast_1 = inp;
					endfunction
					assign sel = (~is_tree[C0] & is_tree[C1]) | ((is_tree[C0] & is_tree[C1]) & sv2v_cast_1(max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C1 : ((2 ** (NumLevels + 1)) - 2) - C1) * PrioWidth+:PrioWidth] > max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C0 : ((2 ** (NumLevels + 1)) - 2) - C0) * PrioWidth+:PrioWidth]));
					assign is_tree[Pa] = (sel & is_tree[C1]) | (~sel & is_tree[C0]);
					assign id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * SrcWidth+:SrcWidth] = ({SrcWidth {sel}} & id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C1 : ((2 ** (NumLevels + 1)) - 2) - C1) * SrcWidth+:SrcWidth]) | ({SrcWidth {~sel}} & id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C0 : ((2 ** (NumLevels + 1)) - 2) - C0) * SrcWidth+:SrcWidth]);
					assign max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * PrioWidth+:PrioWidth] = ({PrioWidth {sel}} & max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C1 : ((2 ** (NumLevels + 1)) - 2) - C1) * PrioWidth+:PrioWidth]) | ({PrioWidth {~sel}} & max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C0 : ((2 ** (NumLevels + 1)) - 2) - C0) * PrioWidth+:PrioWidth]);
				end
			end
		end
	endgenerate
	wire irq_d;
	reg irq_q;
	wire [SrcWidth - 1:0] irq_id_d;
	reg [SrcWidth - 1:0] irq_id_q;
	assign irq_d = (max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : (2 ** (NumLevels + 1)) - 2) * PrioWidth+:PrioWidth] > threshold_i ? is_tree[0] : 1'b0);
	assign irq_id_d = (is_tree[0] ? id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : (2 ** (NumLevels + 1)) - 2) * SrcWidth+:SrcWidth] : {SrcWidth {1'sb0}});
	always @(posedge clk_i or negedge rst_ni) begin : gen_regs
		if (!rst_ni) begin
			irq_q <= 1'b0;
			irq_id_q <= {SrcWidth {1'sb0}};
		end
		else begin
			irq_q <= irq_d;
			irq_id_q <= irq_id_d;
		end
	end
	assign irq_o = irq_q;
	assign irq_id_o = irq_id_q;
endmodule
module rv_timer (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	intr_timer_expired_0_0_o
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_o;
	output wire intr_timer_expired_0_0_o;
	localparam signed [31:0] N_HARTS = 1;
	localparam signed [31:0] N_TIMERS = 1;
	localparam signed [31:0] rv_timer_reg_pkg_N_HARTS = 1;
	localparam signed [31:0] rv_timer_reg_pkg_N_TIMERS = 1;
	localparam [8:0] RV_TIMER_CTRL_OFFSET = 9'h000;
	localparam [8:0] RV_TIMER_CFG0_OFFSET = 9'h100;
	localparam [8:0] RV_TIMER_TIMER_V_LOWER0_OFFSET = 9'h104;
	localparam [8:0] RV_TIMER_TIMER_V_UPPER0_OFFSET = 9'h108;
	localparam [8:0] RV_TIMER_COMPARE_LOWER0_0_OFFSET = 9'h10c;
	localparam [8:0] RV_TIMER_COMPARE_UPPER0_0_OFFSET = 9'h110;
	localparam [8:0] RV_TIMER_INTR_ENABLE0_OFFSET = 9'h114;
	localparam [8:0] RV_TIMER_INTR_STATE0_OFFSET = 9'h118;
	localparam [8:0] RV_TIMER_INTR_TEST0_OFFSET = 9'h11c;
	localparam signed [31:0] RV_TIMER_CTRL = 0;
	localparam signed [31:0] RV_TIMER_CFG0 = 1;
	localparam signed [31:0] RV_TIMER_TIMER_V_LOWER0 = 2;
	localparam signed [31:0] RV_TIMER_TIMER_V_UPPER0 = 3;
	localparam signed [31:0] RV_TIMER_COMPARE_LOWER0_0 = 4;
	localparam signed [31:0] RV_TIMER_COMPARE_UPPER0_0 = 5;
	localparam signed [31:0] RV_TIMER_INTR_ENABLE0 = 6;
	localparam signed [31:0] RV_TIMER_INTR_STATE0 = 7;
	localparam signed [31:0] RV_TIMER_INTR_TEST0 = 8;
	localparam [35:0] RV_TIMER_PERMIT = {4'b0001, 4'b0111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b0001, 4'b0001, 4'b0001};
	wire [154:0] reg2hw;
	wire [67:0] hw2reg;
	wire [N_HARTS - 1:0] active;
	wire [((2 - N_HARTS) * 12) + (((N_HARTS - 1) * 12) - 1):(N_HARTS - 1) * 12] prescaler;
	wire [((2 - N_HARTS) * 8) + (((N_HARTS - 1) * 8) - 1):(N_HARTS - 1) * 8] step;
	wire [N_HARTS - 1:0] tick;
	wire [63:0] mtime_d [0:N_HARTS - 1];
	wire [63:0] mtime [0:N_HARTS - 1];
	wire [((((((2 - N_HARTS) * (2 - N_TIMERS)) + (((N_TIMERS - 1) + ((N_HARTS - 1) * (2 - N_TIMERS))) - 1)) - ((N_TIMERS - 1) + ((N_HARTS - 1) * (2 - N_TIMERS)))) + 1) * 64) + ((((N_TIMERS - 1) + ((N_HARTS - 1) * (2 - N_TIMERS))) * 64) - 1):((N_TIMERS - 1) + ((N_HARTS - 1) * (2 - N_TIMERS))) * 64] mtimecmp;
	wire mtimecmp_update [0:N_HARTS - 1][0:N_TIMERS - 1];
	wire [(N_HARTS * N_TIMERS) - 1:0] intr_timer_set;
	wire [(N_HARTS * N_TIMERS) - 1:0] intr_timer_en;
	wire [(N_HARTS * N_TIMERS) - 1:0] intr_timer_test_q;
	wire [N_HARTS - 1:0] intr_timer_test_qe;
	wire [(N_HARTS * N_TIMERS) - 1:0] intr_timer_state_q;
	wire [N_HARTS - 1:0] intr_timer_state_de;
	wire [(N_HARTS * N_TIMERS) - 1:0] intr_timer_state_d;
	wire [(N_HARTS * N_TIMERS) - 1:0] intr_out;
	assign active[0] = reg2hw[154];
	assign prescaler = reg2hw[153-:12];
	assign step = reg2hw[141-:8];
	assign hw2reg[2] = tick[0];
	assign hw2reg[35] = tick[0];
	assign hw2reg[34-:32] = mtime_d[0][63:32];
	assign hw2reg[67-:32] = mtime_d[0][31:0];
	assign mtime[0] = {reg2hw[101-:32], reg2hw[133-:32]};
	assign mtimecmp = {reg2hw[36-:32], reg2hw[69-:32]};
	assign mtimecmp_update[0][0] = reg2hw[4] | reg2hw[37];
	assign intr_timer_expired_0_0_o = intr_out[0];
	assign intr_timer_en = reg2hw[3];
	assign intr_timer_state_q = reg2hw[2];
	assign intr_timer_test_q = reg2hw[1];
	assign intr_timer_test_qe = reg2hw[0];
	assign hw2reg[0] = intr_timer_state_de | mtimecmp_update[0][0];
	assign hw2reg[1] = intr_timer_state_d & ~mtimecmp_update[0][0];
	generate
		genvar h;
		for (h = 0; h < N_HARTS; h = h + 1) begin : gen_harts
			prim_intr_hw #(.Width(N_TIMERS)) u_intr_hw(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.event_intr_i(intr_timer_set),
				.reg2hw_intr_enable_q_i(intr_timer_en[h * N_TIMERS+:N_TIMERS]),
				.reg2hw_intr_test_q_i(intr_timer_test_q[h * N_TIMERS+:N_TIMERS]),
				.reg2hw_intr_test_qe_i(intr_timer_test_qe[h]),
				.reg2hw_intr_state_q_i(intr_timer_state_q[h * N_TIMERS+:N_TIMERS]),
				.hw2reg_intr_state_de_o(intr_timer_state_de),
				.hw2reg_intr_state_d_o(intr_timer_state_d[h * N_TIMERS+:N_TIMERS]),
				.intr_o(intr_out[h * N_TIMERS+:N_TIMERS])
			);
			timer_core #(.N(N_TIMERS)) u_core(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.active(active[h]),
				.prescaler(prescaler[h * 12+:12]),
				.step(step[h * 8+:8]),
				.tick(tick[h]),
				.mtime_d(mtime_d[h]),
				.mtime(mtime[h]),
				.mtimecmp(mtimecmp[64 * ((N_TIMERS - 1) + (h * (2 - N_TIMERS)))+:64 * (2 - N_TIMERS)]),
				.intr(intr_timer_set[h * N_TIMERS+:N_TIMERS])
			);
		end
	endgenerate
	rv_timer_reg_top u_reg(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.devmode_i(1'b1)
	);
endmodule
module rv_timer_reg_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	reg2hw,
	hw2reg,
	devmode_i
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_o;
	output wire [154:0] reg2hw;
	input wire [67:0] hw2reg;
	input devmode_i;
	localparam signed [31:0] N_HARTS = 1;
	localparam signed [31:0] N_TIMERS = 1;
	localparam [8:0] RV_TIMER_CTRL_OFFSET = 9'h000;
	localparam [8:0] RV_TIMER_CFG0_OFFSET = 9'h100;
	localparam [8:0] RV_TIMER_TIMER_V_LOWER0_OFFSET = 9'h104;
	localparam [8:0] RV_TIMER_TIMER_V_UPPER0_OFFSET = 9'h108;
	localparam [8:0] RV_TIMER_COMPARE_LOWER0_0_OFFSET = 9'h10c;
	localparam [8:0] RV_TIMER_COMPARE_UPPER0_0_OFFSET = 9'h110;
	localparam [8:0] RV_TIMER_INTR_ENABLE0_OFFSET = 9'h114;
	localparam [8:0] RV_TIMER_INTR_STATE0_OFFSET = 9'h118;
	localparam [8:0] RV_TIMER_INTR_TEST0_OFFSET = 9'h11c;
	localparam signed [31:0] RV_TIMER_CTRL = 0;
	localparam signed [31:0] RV_TIMER_CFG0 = 1;
	localparam signed [31:0] RV_TIMER_TIMER_V_LOWER0 = 2;
	localparam signed [31:0] RV_TIMER_TIMER_V_UPPER0 = 3;
	localparam signed [31:0] RV_TIMER_COMPARE_LOWER0_0 = 4;
	localparam signed [31:0] RV_TIMER_COMPARE_UPPER0_0 = 5;
	localparam signed [31:0] RV_TIMER_INTR_ENABLE0 = 6;
	localparam signed [31:0] RV_TIMER_INTR_STATE0 = 7;
	localparam signed [31:0] RV_TIMER_INTR_TEST0 = 8;
	localparam [35:0] RV_TIMER_PERMIT = {4'b0001, 4'b0111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b0001, 4'b0001, 4'b0001};
	localparam signed [31:0] AW = 9;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] DBW = DW / 8;
	wire reg_we;
	wire reg_re;
	wire [AW - 1:0] reg_addr;
	wire [DW - 1:0] reg_wdata;
	wire [DBW - 1:0] reg_be;
	wire [DW - 1:0] reg_rdata;
	wire reg_error;
	wire addrmiss;
	reg wr_err;
	reg [DW - 1:0] reg_rdata_next;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_reg_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_reg_d2h;
	assign tl_reg_h2d = tl_i;
	assign tl_o = tl_reg_d2h;
	tlul_adapter_reg #(
		.RegAw(AW),
		.RegDw(DW)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_reg_h2d),
		.tl_o(tl_reg_d2h),
		.we_o(reg_we),
		.re_o(reg_re),
		.addr_o(reg_addr),
		.wdata_o(reg_wdata),
		.be_o(reg_be),
		.rdata_i(reg_rdata),
		.error_i(reg_error)
	);
	assign reg_rdata = reg_rdata_next;
	assign reg_error = (devmode_i & addrmiss) | wr_err;
	wire ctrl_qs;
	wire ctrl_wd;
	wire ctrl_we;
	wire [11:0] cfg0_prescale_qs;
	wire [11:0] cfg0_prescale_wd;
	wire cfg0_prescale_we;
	wire [7:0] cfg0_step_qs;
	wire [7:0] cfg0_step_wd;
	wire cfg0_step_we;
	wire [31:0] timer_v_lower0_qs;
	wire [31:0] timer_v_lower0_wd;
	wire timer_v_lower0_we;
	wire [31:0] timer_v_upper0_qs;
	wire [31:0] timer_v_upper0_wd;
	wire timer_v_upper0_we;
	wire [31:0] compare_lower0_0_qs;
	wire [31:0] compare_lower0_0_wd;
	wire compare_lower0_0_we;
	wire [31:0] compare_upper0_0_qs;
	wire [31:0] compare_upper0_0_wd;
	wire compare_upper0_0_we;
	wire intr_enable0_qs;
	wire intr_enable0_wd;
	wire intr_enable0_we;
	wire intr_state0_qs;
	wire intr_state0_wd;
	wire intr_state0_we;
	wire intr_test0_wd;
	wire intr_test0_we;
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_we),
		.wd(ctrl_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[154]),
		.qs(ctrl_qs)
	);
	prim_subreg #(
		.DW(12),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(12'h000)
	) u_cfg0_prescale(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(cfg0_prescale_we),
		.wd(cfg0_prescale_wd),
		.de(1'b0),
		.d({12 {1'sb0}}),
		.qe(),
		.q(reg2hw[153-:12]),
		.qs(cfg0_prescale_qs)
	);
	prim_subreg #(
		.DW(8),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(8'h01)
	) u_cfg0_step(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(cfg0_step_we),
		.wd(cfg0_step_wd),
		.de(1'b0),
		.d({8 {1'sb0}}),
		.qe(),
		.q(reg2hw[141-:8]),
		.qs(cfg0_step_qs)
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_timer_v_lower0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(timer_v_lower0_we),
		.wd(timer_v_lower0_wd),
		.de(hw2reg[35]),
		.d(hw2reg[67-:32]),
		.qe(),
		.q(reg2hw[133-:32]),
		.qs(timer_v_lower0_qs)
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_timer_v_upper0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(timer_v_upper0_we),
		.wd(timer_v_upper0_wd),
		.de(hw2reg[2]),
		.d(hw2reg[34-:32]),
		.qe(),
		.q(reg2hw[101-:32]),
		.qs(timer_v_upper0_qs)
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(32'hffffffff)
	) u_compare_lower0_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(compare_lower0_0_we),
		.wd(compare_lower0_0_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(reg2hw[37]),
		.q(reg2hw[69-:32]),
		.qs(compare_lower0_0_qs)
	);
	prim_subreg #(
		.DW(32),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(32'hffffffff)
	) u_compare_upper0_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(compare_upper0_0_we),
		.wd(compare_upper0_0_wd),
		.de(1'b0),
		.d({32 {1'sb0}}),
		.qe(reg2hw[4]),
		.q(reg2hw[36-:32]),
		.qs(compare_upper0_0_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable0_we),
		.wd(intr_enable0_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[3]),
		.qs(intr_enable0_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(24),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state0_we),
		.wd(intr_state0_wd),
		.de(hw2reg[0]),
		.d(hw2reg[1]),
		.qe(),
		.q(reg2hw[2]),
		.qs(intr_state0_qs)
	);
	prim_subreg_ext #(.DW(1)) u_intr_test0(
		.re(1'b0),
		.we(intr_test0_we),
		.wd(intr_test0_wd),
		.d(1'sb0),
		.qre(),
		.qe(reg2hw[0]),
		.q(reg2hw[1]),
		.qs()
	);
	reg [8:0] addr_hit;
	always @(*) begin
		addr_hit = {9 {1'sb0}};
		addr_hit[0] = reg_addr == RV_TIMER_CTRL_OFFSET;
		addr_hit[1] = reg_addr == RV_TIMER_CFG0_OFFSET;
		addr_hit[2] = reg_addr == RV_TIMER_TIMER_V_LOWER0_OFFSET;
		addr_hit[3] = reg_addr == RV_TIMER_TIMER_V_UPPER0_OFFSET;
		addr_hit[4] = reg_addr == RV_TIMER_COMPARE_LOWER0_0_OFFSET;
		addr_hit[5] = reg_addr == RV_TIMER_COMPARE_UPPER0_0_OFFSET;
		addr_hit[6] = reg_addr == RV_TIMER_INTR_ENABLE0_OFFSET;
		addr_hit[7] = reg_addr == RV_TIMER_INTR_STATE0_OFFSET;
		addr_hit[8] = reg_addr == RV_TIMER_INTR_TEST0_OFFSET;
	end
	assign addrmiss = (reg_re || reg_we ? ~|addr_hit : 1'b0);
	always @(*) begin
		wr_err = 1'b0;
		if ((addr_hit[0] && reg_we) && (RV_TIMER_PERMIT[32+:4] != (RV_TIMER_PERMIT[32+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[1] && reg_we) && (RV_TIMER_PERMIT[28+:4] != (RV_TIMER_PERMIT[28+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[2] && reg_we) && (RV_TIMER_PERMIT[24+:4] != (RV_TIMER_PERMIT[24+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[3] && reg_we) && (RV_TIMER_PERMIT[20+:4] != (RV_TIMER_PERMIT[20+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[4] && reg_we) && (RV_TIMER_PERMIT[16+:4] != (RV_TIMER_PERMIT[16+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[5] && reg_we) && (RV_TIMER_PERMIT[12+:4] != (RV_TIMER_PERMIT[12+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[6] && reg_we) && (RV_TIMER_PERMIT[8+:4] != (RV_TIMER_PERMIT[8+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[7] && reg_we) && (RV_TIMER_PERMIT[4+:4] != (RV_TIMER_PERMIT[4+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[8] && reg_we) && (RV_TIMER_PERMIT[0+:4] != (RV_TIMER_PERMIT[0+:4] & reg_be)))
			wr_err = 1'b1;
	end
	assign ctrl_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign ctrl_wd = reg_wdata[0];
	assign cfg0_prescale_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign cfg0_prescale_wd = reg_wdata[11:0];
	assign cfg0_step_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign cfg0_step_wd = reg_wdata[23:16];
	assign timer_v_lower0_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign timer_v_lower0_wd = reg_wdata[31:0];
	assign timer_v_upper0_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign timer_v_upper0_wd = reg_wdata[31:0];
	assign compare_lower0_0_we = (addr_hit[4] & reg_we) & ~wr_err;
	assign compare_lower0_0_wd = reg_wdata[31:0];
	assign compare_upper0_0_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign compare_upper0_0_wd = reg_wdata[31:0];
	assign intr_enable0_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign intr_enable0_wd = reg_wdata[0];
	assign intr_state0_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign intr_state0_wd = reg_wdata[0];
	assign intr_test0_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign intr_test0_wd = reg_wdata[0];
	always @(*) begin
		reg_rdata_next = {DW {1'sb0}};
		case (1'b1)
			addr_hit[0]: reg_rdata_next[0] = ctrl_qs;
			addr_hit[1]: begin
				reg_rdata_next[11:0] = cfg0_prescale_qs;
				reg_rdata_next[23:16] = cfg0_step_qs;
			end
			addr_hit[2]: reg_rdata_next[31:0] = timer_v_lower0_qs;
			addr_hit[3]: reg_rdata_next[31:0] = timer_v_upper0_qs;
			addr_hit[4]: reg_rdata_next[31:0] = compare_lower0_0_qs;
			addr_hit[5]: reg_rdata_next[31:0] = compare_upper0_0_qs;
			addr_hit[6]: reg_rdata_next[0] = intr_enable0_qs;
			addr_hit[7]: reg_rdata_next[0] = intr_state0_qs;
			addr_hit[8]: reg_rdata_next[0] = 1'sb0;
			default: reg_rdata_next = {DW {1'sb1}};
		endcase
	end
endmodule
module timer_core (
	clk_i,
	rst_ni,
	active,
	prescaler,
	step,
	tick,
	mtime_d,
	mtime,
	mtimecmp,
	intr
);
	parameter signed [31:0] N = 1;
	input clk_i;
	input rst_ni;
	input active;
	input [11:0] prescaler;
	input [7:0] step;
	output wire tick;
	output wire [63:0] mtime_d;
	input [63:0] mtime;
	input [(0 >= (N - 1) ? ((2 - N) * 64) + (((N - 1) * 64) - 1) : (N * 64) - 1):(0 >= (N - 1) ? (N - 1) * 64 : 0)] mtimecmp;
	output wire [N - 1:0] intr;
	reg [11:0] tick_count;
	always @(posedge clk_i or negedge rst_ni) begin : generate_tick
		if (!rst_ni)
			tick_count <= 12'h000;
		else if (!active)
			tick_count <= 12'h000;
		else if (tick_count == prescaler)
			tick_count <= 12'h000;
		else
			tick_count <= tick_count + 1'b1;
	end
	assign tick = active & (tick_count >= prescaler);
	function automatic [63:0] sv2v_cast_64;
		input reg [63:0] inp;
		sv2v_cast_64 = inp;
	endfunction
	assign mtime_d = mtime + sv2v_cast_64(step);
	generate
		genvar t;
		for (t = 0; t < N; t = t + 1) begin : gen_intr
			assign intr[t] = active & (mtime >= mtimecmp[(0 >= (N - 1) ? t : (N - 1) - t) * 64+:64]);
		end
	endgenerate
endmodule
module tlul_adapter_host (
	clk_i,
	rst_ni,
	req_i,
	gnt_o,
	addr_i,
	we_i,
	wdata_i,
	be_i,
	valid_o,
	rdata_o,
	err_o,
	tl_o,
	tl_i
);
	parameter [31:0] MAX_REQS = 2;
	input clk_i;
	input rst_ni;
	input req_i;
	output wire gnt_o;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	input wire [top_pkg_TL_AW - 1:0] addr_i;
	input wire we_i;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	input wire [top_pkg_TL_DW - 1:0] wdata_i;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	input wire [top_pkg_TL_DBW - 1:0] be_i;
	output wire valid_o;
	output wire [top_pkg_TL_DW - 1:0] rdata_o;
	output wire err_o;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_o;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_i;
	localparam signed [31:0] WordSize = $clog2(top_pkg_TL_DBW);
	wire [top_pkg_TL_AIW - 1:0] tl_source;
	wire [top_pkg_TL_DBW - 1:0] tl_be;
	generate
		if (MAX_REQS == 1) begin : g_single_req
			assign tl_source = {top_pkg_TL_AIW {1'sb0}};
		end
		else begin : g_multiple_reqs
			localparam signed [31:0] ReqNumW = $clog2(MAX_REQS);
			reg [ReqNumW - 1:0] source_d;
			reg [ReqNumW - 1:0] source_q;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					source_q <= {ReqNumW {1'sb0}};
				else
					source_q <= source_d;
			always @(*) begin
				source_d = source_q;
				if (req_i && gnt_o)
					if (source_q == (MAX_REQS - 1))
						source_d = {ReqNumW {1'sb0}};
					else
						source_d = source_q + 1;
			end
			function automatic [7:0] sv2v_cast_8;
				input reg [7:0] inp;
				sv2v_cast_8 = inp;
			endfunction
			assign tl_source = sv2v_cast_8(source_q);
		end
	endgenerate
	assign tl_be = (~we_i ? {top_pkg_TL_DBW {1'b1}} : be_i);
	localparam [2:0] tlul_pkg_Get = 3'h4;
	localparam [2:0] tlul_pkg_PutFullData = 3'h0;
	localparam [2:0] tlul_pkg_PutPartialData = 3'h1;
	function automatic signed [top_pkg_TL_SZW - 1:0] sv2v_cast_38DDD_signed;
		input reg signed [top_pkg_TL_SZW - 1:0] inp;
		sv2v_cast_38DDD_signed = inp;
	endfunction
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [top_pkg_TL_SZW - 1:0] sv2v_cast_F00AF;
		input reg [top_pkg_TL_SZW - 1:0] inp;
		sv2v_cast_F00AF = inp;
	endfunction
	function automatic [top_pkg_TL_AIW - 1:0] sv2v_cast_F1F18;
		input reg [top_pkg_TL_AIW - 1:0] inp;
		sv2v_cast_F1F18 = inp;
	endfunction
	function automatic [top_pkg_TL_AW - 1:0] sv2v_cast_4CD75;
		input reg [top_pkg_TL_AW - 1:0] inp;
		sv2v_cast_4CD75 = inp;
	endfunction
	function automatic [top_pkg_TL_DBW - 1:0] sv2v_cast_37199;
		input reg [top_pkg_TL_DBW - 1:0] inp;
		sv2v_cast_37199 = inp;
	endfunction
	function automatic [top_pkg_TL_DW - 1:0] sv2v_cast_2497D;
		input reg [top_pkg_TL_DW - 1:0] inp;
		sv2v_cast_2497D = inp;
	endfunction
	function automatic [15:0] sv2v_cast_16;
		input reg [15:0] inp;
		sv2v_cast_16 = inp;
	endfunction
	assign tl_o = {sv2v_cast_1(req_i), sv2v_cast_3((~we_i ? tlul_pkg_Get : (&be_i ? tlul_pkg_PutFullData : tlul_pkg_PutPartialData))), 3'h0, sv2v_cast_F00AF(sv2v_cast_38DDD_signed(WordSize)), sv2v_cast_F1F18(tl_source), sv2v_cast_4CD75({addr_i[31:WordSize], {WordSize {1'b0}}}), sv2v_cast_37199(tl_be), sv2v_cast_2497D(wdata_i), sv2v_cast_16({7'b0000000, 1'sb0, 8'b00000000}), 1'b1};
	assign gnt_o = tl_i[0];
	assign valid_o = tl_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))];
	assign rdata_o = tl_i[top_pkg_TL_DW + (top_pkg_TL_DUW + 1)-:((top_pkg_TL_DW + (top_pkg_TL_DUW + 1)) - (top_pkg_TL_DUW + 2)) + 1];
	assign err_o = tl_i[1];
endmodule
module tlul_adapter_reg (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	re_o,
	we_o,
	addr_o,
	wdata_o,
	be_o,
	rdata_i,
	error_i
);
	localparam ArbiterImpl = "PPC";
	localparam [31:0] ADDR_SPACE_UART = 32'h40000000;
	localparam [31:0] ADDR_SPACE_GPIO = 32'h40010000;
	localparam [31:0] ADDR_SPACE_SRAMD = 32'h18000000;
	localparam [31:0] ADDR_SPACE_SRAMI = 32'h00080000;
	localparam [31:0] ADDR_SPACE_DEBUG_MEM = 32'h1a110000;
	localparam [31:0] ADDR_SPACE_RV_PLIC = 32'h40090000;
	localparam [31:0] ADDR_SPACE_SPI_DEVICE = 32'h40020000;
	localparam [31:0] ADDR_SPACE_RV_TIMER = 32'h40080000;
	localparam [31:0] ADDR_MASK_UART = 32'h00000fff;
	localparam [31:0] ADDR_MASK_GPIO = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SRAMD = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_SRAMI = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_DEBUG_MEM = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_PLIC = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SPI_DEVICE = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_TIMER = 32'h00000fff;
	localparam [2:0] PutFullData = 3'h0;
	localparam [2:0] PutPartialData = 3'h1;
	localparam [2:0] Get = 3'h4;
	localparam [2:0] AccessAck = 3'h0;
	localparam [2:0] AccessAckData = 3'h1;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	function automatic [top_pkg_TL_SZW - 1:0] sv2v_cast_F00AF;
		input reg [top_pkg_TL_SZW - 1:0] inp;
		sv2v_cast_F00AF = inp;
	endfunction
	function automatic [top_pkg_TL_AIW - 1:0] sv2v_cast_F1F18;
		input reg [top_pkg_TL_AIW - 1:0] inp;
		sv2v_cast_F1F18 = inp;
	endfunction
	function automatic [top_pkg_TL_AW - 1:0] sv2v_cast_4CD75;
		input reg [top_pkg_TL_AW - 1:0] inp;
		sv2v_cast_4CD75 = inp;
	endfunction
	function automatic [top_pkg_TL_DBW - 1:0] sv2v_cast_37199;
		input reg [top_pkg_TL_DBW - 1:0] inp;
		sv2v_cast_37199 = inp;
	endfunction
	function automatic [top_pkg_TL_DW - 1:0] sv2v_cast_2497D;
		input reg [top_pkg_TL_DW - 1:0] inp;
		sv2v_cast_2497D = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] TL_H2D_DEFAULT = {1'sb0, 3'b000, 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_4CD75(1'sb0), sv2v_cast_37199(1'sb0), sv2v_cast_2497D(1'sb0), 16'b0000000000000000, 1'b1};
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	function automatic [top_pkg_TL_DIW - 1:0] sv2v_cast_B5AB2;
		input reg [top_pkg_TL_DIW - 1:0] inp;
		sv2v_cast_B5AB2 = inp;
	endfunction
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	function automatic [top_pkg_TL_DUW - 1:0] sv2v_cast_92577;
		input reg [top_pkg_TL_DUW - 1:0] inp;
		sv2v_cast_92577 = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] TL_D2H_DEFAULT = {1'sb0, sv2v_cast_3(3'b000), 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_B5AB2(1'sb0), sv2v_cast_2497D(1'sb0), sv2v_cast_92577(1'sb0), 1'sb0, 1'b1};
	parameter signed [31:0] RegAw = 8;
	parameter signed [31:0] RegDw = 32;
	localparam signed [31:0] RegBw = RegDw / 8;
	input clk_i;
	input rst_ni;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_o;
	output wire re_o;
	output wire we_o;
	output wire [RegAw - 1:0] addr_o;
	output wire [RegDw - 1:0] wdata_o;
	output wire [RegBw - 1:0] be_o;
	input [RegDw - 1:0] rdata_i;
	input error_i;
	localparam signed [31:0] IW = top_pkg_TL_AIW;
	localparam signed [31:0] SZW = top_pkg_TL_SZW;
	reg outstanding;
	wire a_ack;
	wire d_ack;
	reg [RegDw - 1:0] rdata;
	reg error;
	wire err_internal;
	reg addr_align_err;
	wire malformed_meta_err;
	wire tl_err;
	reg [IW - 1:0] reqid;
	reg [SZW - 1:0] reqsz;
	reg [2:0] rspop;
	wire rd_req;
	wire wr_req;
	assign a_ack = tl_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] & tl_o[0];
	assign d_ack = tl_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))] & tl_i[0];
	assign wr_req = a_ack & ((tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == PutFullData) | (tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == PutPartialData));
	assign rd_req = a_ack & (tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == Get);
	assign we_o = wr_req & ~err_internal;
	assign re_o = rd_req & ~err_internal;
	assign addr_o = {tl_i[(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - ((top_pkg_TL_AW - 1) - (RegAw - 1)):(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_AW - 3)], 2'b00};
	assign wdata_o = tl_i[top_pkg_TL_DW + 16-:top_pkg_TL_DW];
	assign be_o = tl_i[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			outstanding <= 1'b0;
		else if (a_ack)
			outstanding <= 1'b1;
		else if (d_ack)
			outstanding <= 1'b0;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			reqid <= {IW {1'sb0}};
			reqsz <= {SZW {1'sb0}};
			rspop <= AccessAck;
		end
		else if (a_ack) begin
			reqid <= tl_i[top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))-:((40 + (top_pkg_TL_DBW + 48)) >= (32 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) + 1 : ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + 1)];
			reqsz <= tl_i[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)];
			rspop <= (rd_req ? AccessAckData : AccessAck);
		end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rdata <= {RegDw {1'sb0}};
			error <= 1'b0;
		end
		else if (a_ack) begin
			rdata <= (err_internal ? {RegDw {1'sb1}} : rdata_i);
			error <= error_i | err_internal;
		end
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	assign tl_o = {sv2v_cast_1(outstanding), sv2v_cast_3(rspop), 3'b000, sv2v_cast_F00AF(reqsz), sv2v_cast_F1F18(reqid), sv2v_cast_B5AB2(1'sb0), sv2v_cast_2497D(rdata), sv2v_cast_92577(1'sb0), sv2v_cast_1(error), sv2v_cast_1(~outstanding)};
	assign err_internal = (addr_align_err | malformed_meta_err) | tl_err;
	assign malformed_meta_err = tl_i[9] == 1'b1;
	always @(*)
		if (wr_req)
			addr_align_err = |tl_i[(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_AW - 2):(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_AW - 1)];
		else
			addr_align_err = 1'b0;
	tlul_err u_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.err_o(tl_err)
	);
endmodule
module tlul_adapter_sram (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	req_o,
	gnt_i,
	we_o,
	addr_o,
	wdata_o,
	wmask_o,
	rdata_i,
	rvalid_i,
	rerror_i
);
	parameter signed [31:0] SramAw = 12;
	parameter signed [31:0] SramDw = 32;
	parameter signed [31:0] Outstanding = 1;
	parameter [0:0] ByteAccess = 1;
	parameter [0:0] ErrOnWrite = 0;
	parameter [0:0] ErrOnRead = 0;
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_o;
	output wire req_o;
	input gnt_i;
	output wire we_o;
	output wire [SramAw - 1:0] addr_o;
	output wire [SramDw - 1:0] wdata_o;
	output wire [SramDw - 1:0] wmask_o;
	input [SramDw - 1:0] rdata_i;
	input rvalid_i;
	input [1:0] rerror_i;
	localparam ArbiterImpl = "PPC";
	localparam [31:0] ADDR_SPACE_UART = 32'h40000000;
	localparam [31:0] ADDR_SPACE_GPIO = 32'h40010000;
	localparam [31:0] ADDR_SPACE_SRAMD = 32'h18000000;
	localparam [31:0] ADDR_SPACE_SRAMI = 32'h00080000;
	localparam [31:0] ADDR_SPACE_DEBUG_MEM = 32'h1a110000;
	localparam [31:0] ADDR_SPACE_RV_PLIC = 32'h40090000;
	localparam [31:0] ADDR_SPACE_SPI_DEVICE = 32'h40020000;
	localparam [31:0] ADDR_SPACE_RV_TIMER = 32'h40080000;
	localparam [31:0] ADDR_MASK_UART = 32'h00000fff;
	localparam [31:0] ADDR_MASK_GPIO = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SRAMD = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_SRAMI = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_DEBUG_MEM = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_PLIC = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SPI_DEVICE = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_TIMER = 32'h00000fff;
	localparam [2:0] PutFullData = 3'h0;
	localparam [2:0] PutPartialData = 3'h1;
	localparam [2:0] Get = 3'h4;
	localparam [2:0] AccessAck = 3'h0;
	localparam [2:0] AccessAckData = 3'h1;
	function automatic [top_pkg_TL_SZW - 1:0] sv2v_cast_F00AF;
		input reg [top_pkg_TL_SZW - 1:0] inp;
		sv2v_cast_F00AF = inp;
	endfunction
	function automatic [top_pkg_TL_AIW - 1:0] sv2v_cast_F1F18;
		input reg [top_pkg_TL_AIW - 1:0] inp;
		sv2v_cast_F1F18 = inp;
	endfunction
	function automatic [top_pkg_TL_AW - 1:0] sv2v_cast_4CD75;
		input reg [top_pkg_TL_AW - 1:0] inp;
		sv2v_cast_4CD75 = inp;
	endfunction
	function automatic [top_pkg_TL_DBW - 1:0] sv2v_cast_37199;
		input reg [top_pkg_TL_DBW - 1:0] inp;
		sv2v_cast_37199 = inp;
	endfunction
	function automatic [top_pkg_TL_DW - 1:0] sv2v_cast_2497D;
		input reg [top_pkg_TL_DW - 1:0] inp;
		sv2v_cast_2497D = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] TL_H2D_DEFAULT = {1'sb0, 3'b000, 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_4CD75(1'sb0), sv2v_cast_37199(1'sb0), sv2v_cast_2497D(1'sb0), 16'b0000000000000000, 1'b1};
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [top_pkg_TL_DIW - 1:0] sv2v_cast_B5AB2;
		input reg [top_pkg_TL_DIW - 1:0] inp;
		sv2v_cast_B5AB2 = inp;
	endfunction
	function automatic [top_pkg_TL_DUW - 1:0] sv2v_cast_92577;
		input reg [top_pkg_TL_DUW - 1:0] inp;
		sv2v_cast_92577 = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] TL_D2H_DEFAULT = {1'sb0, sv2v_cast_3(3'b000), 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_B5AB2(1'sb0), sv2v_cast_2497D(1'sb0), sv2v_cast_92577(1'sb0), 1'sb0, 1'b1};
	localparam signed [31:0] SramByte = SramDw / 8;
	function automatic integer prim_util_pkg_vbits;
		input integer value;
		prim_util_pkg_vbits = (value == 1 ? 1 : $clog2(value));
	endfunction
	localparam signed [31:0] DataBitWidth = prim_util_pkg_vbits(SramByte);
	localparam signed [31:0] WidthMult = SramDw / top_pkg_TL_DW;
	localparam signed [31:0] WoffsetWidth = (SramByte == top_pkg_TL_DBW ? 1 : DataBitWidth - prim_util_pkg_vbits(top_pkg_TL_DBW));
	localparam signed [31:0] SramReqFifoWidth = top_pkg_TL_DBW + WoffsetWidth;
	localparam signed [31:0] ReqFifoWidth = (3 + top_pkg_TL_SZW) + top_pkg_TL_AIW;
	localparam signed [31:0] RspFifoWidth = (SramDw >= 0 ? SramDw + 1 : 1 - SramDw);
	wire reqfifo_wvalid;
	wire reqfifo_wready;
	wire reqfifo_rvalid;
	wire reqfifo_rready;
	wire [((3 + top_pkg_TL_SZW) + top_pkg_TL_AIW) - 1:0] reqfifo_wdata;
	wire [((3 + top_pkg_TL_SZW) + top_pkg_TL_AIW) - 1:0] reqfifo_rdata;
	wire sramreqfifo_wvalid;
	wire sramreqfifo_wready;
	wire sramreqfifo_rready;
	wire [(top_pkg_TL_DBW + WoffsetWidth) - 1:0] sramreqfifo_wdata;
	wire [(top_pkg_TL_DBW + WoffsetWidth) - 1:0] sramreqfifo_rdata;
	wire rspfifo_wvalid;
	wire rspfifo_wready;
	wire rspfifo_rvalid;
	wire rspfifo_rready;
	wire [SramDw:0] rspfifo_wdata;
	wire [SramDw:0] rspfifo_rdata;
	wire error_internal;
	wire wr_attr_error;
	wire wr_vld_error;
	wire rd_vld_error;
	wire tlul_error;
	wire a_ack;
	wire d_ack;
	wire sram_ack;
	assign a_ack = tl_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] & tl_o[0];
	assign d_ack = tl_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))] & tl_i[0];
	assign sram_ack = req_o & gnt_i;
	reg d_valid;
	reg d_error;
	localparam [1:0] OpRead = 1;
	always @(*) begin
		d_valid = 1'b0;
		if (reqfifo_rvalid) begin
			if (reqfifo_rdata[1 + (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1))])
				d_valid = 1'b1;
			else if (reqfifo_rdata[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1))-:((3 + (top_pkg_TL_SZW + 7)) >= (1 + (top_pkg_TL_SZW + 8)) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1))) - (1 + (top_pkg_TL_SZW + top_pkg_TL_AIW))) + 1 : ((1 + (top_pkg_TL_SZW + top_pkg_TL_AIW)) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1)))) + 1)] == OpRead)
				d_valid = rspfifo_rvalid;
			else
				d_valid = 1'b1;
		end
		else
			d_valid = 1'b0;
	end
	always @(*) begin
		d_error = 1'b0;
		if (reqfifo_rvalid) begin
			if (reqfifo_rdata[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1))-:((3 + (top_pkg_TL_SZW + 7)) >= (1 + (top_pkg_TL_SZW + 8)) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1))) - (1 + (top_pkg_TL_SZW + top_pkg_TL_AIW))) + 1 : ((1 + (top_pkg_TL_SZW + top_pkg_TL_AIW)) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1)))) + 1)] == OpRead)
				d_error = rspfifo_rdata[0] | reqfifo_rdata[1 + (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1))];
			else
				d_error = reqfifo_rdata[1 + (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1))];
		end
		else
			d_error = 1'b0;
	end
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	assign tl_o = {sv2v_cast_1(d_valid), sv2v_cast_3((d_valid && (reqfifo_rdata[3 + (top_pkg_TL_SZW + 7)-:((3 + (top_pkg_TL_SZW + 7)) >= (1 + (top_pkg_TL_SZW + 8)) ? ((3 + (top_pkg_TL_SZW + 7)) - (1 + (top_pkg_TL_SZW + 8))) + 1 : ((1 + (top_pkg_TL_SZW + 8)) - (3 + (top_pkg_TL_SZW + 7))) + 1)] != 1) ? AccessAck : AccessAckData)), 3'b000, sv2v_cast_F00AF((d_valid ? reqfifo_rdata[top_pkg_TL_SZW + (top_pkg_TL_AIW - 1)-:((top_pkg_TL_SZW + 7) >= 8 ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW - 1)) - top_pkg_TL_AIW) + 1 : (top_pkg_TL_AIW - (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1))) + 1)] : {((top_pkg_TL_SZW + 7) >= 8 ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW - 1)) - top_pkg_TL_AIW) + 1 : (top_pkg_TL_AIW - (top_pkg_TL_SZW + (top_pkg_TL_AIW - 1))) + 1) {1'sb0}})), sv2v_cast_F1F18((d_valid ? reqfifo_rdata[top_pkg_TL_AIW - 1-:top_pkg_TL_AIW] : {top_pkg_TL_AIW {1'sb0}})), sv2v_cast_B5AB2(1'b0), sv2v_cast_2497D(((d_valid && rspfifo_rvalid) && (reqfifo_rdata[3 + (top_pkg_TL_SZW + 7)-:((3 + (top_pkg_TL_SZW + 7)) >= (1 + (top_pkg_TL_SZW + 8)) ? ((3 + (top_pkg_TL_SZW + 7)) - (1 + (top_pkg_TL_SZW + 8))) + 1 : ((1 + (top_pkg_TL_SZW + 8)) - (3 + (top_pkg_TL_SZW + 7))) + 1)] == 1) ? rspfifo_rdata[SramDw-:(SramDw >= 1 ? SramDw : 2 - SramDw)] : {(SramDw >= 1 ? SramDw : 2 - SramDw) {1'sb0}})), sv2v_cast_92577(1'sb0), sv2v_cast_1(d_valid && d_error), sv2v_cast_1(((gnt_i | error_internal) & reqfifo_wready) & sramreqfifo_wready)};
	assign req_o = (tl_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] & reqfifo_wready) & ~error_internal;
	assign we_o = tl_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] & sv2v_cast_1(|{tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == PutFullData, tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == PutPartialData});
	assign addr_o = (tl_i[7 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))] ? tl_i[(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - ((top_pkg_TL_AW - 1) - DataBitWidth)+:SramAw] : {SramAw {1'sb0}});
	wire [WoffsetWidth - 1:0] woffset;
	generate
		if (top_pkg_TL_DW != SramDw) begin : gen_wordwidthadapt
			assign woffset = tl_i[(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - ((top_pkg_TL_AW - 1) - (DataBitWidth - 1)):(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - ((top_pkg_TL_AW - 1) - prim_util_pkg_vbits(top_pkg_TL_DBW))];
		end
		else begin : gen_no_wordwidthadapt
			assign woffset = {WoffsetWidth {1'sb0}};
		end
	endgenerate
	reg [(WidthMult * top_pkg_TL_DW) - 1:0] wmask_int;
	reg [(WidthMult * top_pkg_TL_DW) - 1:0] wdata_int;
	always @(*) begin
		wmask_int = {WidthMult * top_pkg_TL_DW {1'sb0}};
		wdata_int = {WidthMult * top_pkg_TL_DW {1'sb0}};
		if (tl_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))]) begin : sv2v_autoblock_82
			reg signed [31:0] i;
			for (i = 0; i < (top_pkg_TL_DW / 8); i = i + 1)
				begin
					wmask_int[(woffset * top_pkg_TL_DW) + (8 * i)+:8] = {8 {tl_i[(top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - ((top_pkg_TL_DBW - 1) - i)]}};
					wdata_int[(woffset * top_pkg_TL_DW) + (8 * i)+:8] = (tl_i[(top_pkg_TL_DBW + 48) - ((top_pkg_TL_DBW - 1) - i)] && we_o ? tl_i[(top_pkg_TL_DW + 16) - ((top_pkg_TL_DW - 1) - (8 * i))+:8] : {8 {1'sb0}});
				end
		end
	end
	assign wmask_o = wmask_int;
	assign wdata_o = wdata_int;
	assign wr_attr_error = ((tl_i[6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) - (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))))) + 1 : ((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) - (6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))))) + 1)] == 3'h0) || (tl_i[6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) - (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))))) + 1 : ((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) - (6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))))) + 1)] == 3'h1) ? (ByteAccess == 0 ? (tl_i[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)] != {top_pkg_TL_DBW {1'sb1}}) || (tl_i[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)] != 2'h2) : 1'b0) : 1'b0);
	generate
		if (ErrOnWrite == 1) begin : gen_no_writes
			assign wr_vld_error = tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] != Get;
		end
		else begin : gen_writes_allowed
			assign wr_vld_error = 1'b0;
		end
	endgenerate
	generate
		if (ErrOnRead == 1) begin : gen_no_reads
			assign rd_vld_error = tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == Get;
		end
		else begin : gen_reads_allowed
			assign rd_vld_error = 1'b0;
		end
	endgenerate
	tlul_err u_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.err_o(tlul_error)
	);
	assign error_internal = ((wr_attr_error | wr_vld_error) | rd_vld_error) | tlul_error;
	assign reqfifo_wvalid = a_ack;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	localparam [1:0] OpWrite = 0;
	assign reqfifo_wdata = {sv2v_cast_2((tl_i[6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) - (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))))) + 1 : ((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) - (6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))))) + 1)] != 3'h4 ? OpWrite : OpRead)), sv2v_cast_1(error_internal), sv2v_cast_F00AF(tl_i[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)]), sv2v_cast_F1F18(tl_i[top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))-:((40 + (top_pkg_TL_DBW + 48)) >= (32 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) + 1 : ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + 1)])};
	assign reqfifo_rready = d_ack;
	function automatic [WoffsetWidth - 1:0] sv2v_cast_4AB74;
		input reg [WoffsetWidth - 1:0] inp;
		sv2v_cast_4AB74 = inp;
	endfunction
	assign sramreqfifo_wdata = {sv2v_cast_37199(tl_i[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)]), sv2v_cast_4AB74(woffset)};
	assign sramreqfifo_wvalid = sram_ack & ~we_o;
	assign sramreqfifo_rready = rspfifo_wvalid;
	assign rspfifo_wvalid = rvalid_i & reqfifo_rvalid;
	wire [(WidthMult * top_pkg_TL_DW) - 1:0] rdata;
	reg [(WidthMult * top_pkg_TL_DW) - 1:0] rmask;
	wire [top_pkg_TL_DW - 1:0] rdata_tlword;
	always @(*) begin
		rmask = {WidthMult * top_pkg_TL_DW {1'sb0}};
		begin : sv2v_autoblock_83
			reg signed [31:0] i;
			for (i = 0; i < (top_pkg_TL_DW / 8); i = i + 1)
				rmask[(sramreqfifo_rdata[WoffsetWidth - 1-:WoffsetWidth] * top_pkg_TL_DW) + (8 * i)+:8] = {8 {sramreqfifo_rdata[(top_pkg_TL_DBW + (WoffsetWidth - 1)) - ((top_pkg_TL_DBW - 1) - i)]}};
		end
	end
	assign rdata = rdata_i & rmask;
	assign rdata_tlword = rdata[sramreqfifo_rdata[WoffsetWidth - 1-:WoffsetWidth] * top_pkg_TL_DW+:top_pkg_TL_DW];
	function automatic [SramDw - 1:0] sv2v_cast_D11AA;
		input reg [SramDw - 1:0] inp;
		sv2v_cast_D11AA = inp;
	endfunction
	assign rspfifo_wdata = {sv2v_cast_D11AA(rdata_tlword), sv2v_cast_1(rerror_i[1])};
	assign rspfifo_rready = ((reqfifo_rdata[3 + (top_pkg_TL_SZW + 7)-:((3 + (top_pkg_TL_SZW + 7)) >= (1 + (top_pkg_TL_SZW + 8)) ? ((3 + (top_pkg_TL_SZW + 7)) - (1 + (top_pkg_TL_SZW + 8))) + 1 : ((1 + (top_pkg_TL_SZW + 8)) - (3 + (top_pkg_TL_SZW + 7))) + 1)] == 1) & ~reqfifo_rdata[1 + (top_pkg_TL_SZW + 7)] ? reqfifo_rready : 1'b0);
	wire unused_rerror;
	assign unused_rerror = rerror_i[0];
	prim_fifo_sync #(
		.Width(ReqFifoWidth),
		.Pass(1'b0),
		.Depth(Outstanding)
	) u_reqfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(reqfifo_wvalid),
		.wready_o(reqfifo_wready),
		.wdata_i(reqfifo_wdata),
		.depth_o(),
		.rvalid_o(reqfifo_rvalid),
		.rready_i(reqfifo_rready),
		.rdata_o(reqfifo_rdata)
	);
	prim_fifo_sync #(
		.Width(SramReqFifoWidth),
		.Pass(1'b0),
		.Depth(Outstanding)
	) u_sramreqfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(sramreqfifo_wvalid),
		.wready_o(sramreqfifo_wready),
		.wdata_i(sramreqfifo_wdata),
		.depth_o(),
		.rvalid_o(),
		.rready_i(sramreqfifo_rready),
		.rdata_o(sramreqfifo_rdata)
	);
	prim_fifo_sync #(
		.Width(RspFifoWidth),
		.Pass(1'b1),
		.Depth(Outstanding)
	) u_rspfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(rspfifo_wvalid),
		.wready_o(rspfifo_wready),
		.wdata_i(rspfifo_wdata),
		.depth_o(),
		.rvalid_o(rspfifo_rvalid),
		.rready_i(rspfifo_rready),
		.rdata_o(rspfifo_rdata)
	);
endmodule
module tlul_err (
	clk_i,
	rst_ni,
	tl_i,
	err_o
);
	localparam ArbiterImpl = "PPC";
	localparam [31:0] ADDR_SPACE_UART = 32'h40000000;
	localparam [31:0] ADDR_SPACE_GPIO = 32'h40010000;
	localparam [31:0] ADDR_SPACE_SRAMD = 32'h18000000;
	localparam [31:0] ADDR_SPACE_SRAMI = 32'h00080000;
	localparam [31:0] ADDR_SPACE_DEBUG_MEM = 32'h1a110000;
	localparam [31:0] ADDR_SPACE_RV_PLIC = 32'h40090000;
	localparam [31:0] ADDR_SPACE_SPI_DEVICE = 32'h40020000;
	localparam [31:0] ADDR_SPACE_RV_TIMER = 32'h40080000;
	localparam [31:0] ADDR_MASK_UART = 32'h00000fff;
	localparam [31:0] ADDR_MASK_GPIO = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SRAMD = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_SRAMI = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_DEBUG_MEM = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_PLIC = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SPI_DEVICE = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_TIMER = 32'h00000fff;
	localparam [2:0] PutFullData = 3'h0;
	localparam [2:0] PutPartialData = 3'h1;
	localparam [2:0] Get = 3'h4;
	localparam [2:0] AccessAck = 3'h0;
	localparam [2:0] AccessAckData = 3'h1;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	function automatic [top_pkg_TL_SZW - 1:0] sv2v_cast_F00AF;
		input reg [top_pkg_TL_SZW - 1:0] inp;
		sv2v_cast_F00AF = inp;
	endfunction
	function automatic [top_pkg_TL_AIW - 1:0] sv2v_cast_F1F18;
		input reg [top_pkg_TL_AIW - 1:0] inp;
		sv2v_cast_F1F18 = inp;
	endfunction
	function automatic [top_pkg_TL_AW - 1:0] sv2v_cast_4CD75;
		input reg [top_pkg_TL_AW - 1:0] inp;
		sv2v_cast_4CD75 = inp;
	endfunction
	function automatic [top_pkg_TL_DBW - 1:0] sv2v_cast_37199;
		input reg [top_pkg_TL_DBW - 1:0] inp;
		sv2v_cast_37199 = inp;
	endfunction
	function automatic [top_pkg_TL_DW - 1:0] sv2v_cast_2497D;
		input reg [top_pkg_TL_DW - 1:0] inp;
		sv2v_cast_2497D = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] TL_H2D_DEFAULT = {1'sb0, 3'b000, 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_4CD75(1'sb0), sv2v_cast_37199(1'sb0), sv2v_cast_2497D(1'sb0), 16'b0000000000000000, 1'b1};
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	function automatic [top_pkg_TL_DIW - 1:0] sv2v_cast_B5AB2;
		input reg [top_pkg_TL_DIW - 1:0] inp;
		sv2v_cast_B5AB2 = inp;
	endfunction
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	function automatic [top_pkg_TL_DUW - 1:0] sv2v_cast_92577;
		input reg [top_pkg_TL_DUW - 1:0] inp;
		sv2v_cast_92577 = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] TL_D2H_DEFAULT = {1'sb0, sv2v_cast_3(3'b000), 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_B5AB2(1'sb0), sv2v_cast_2497D(1'sb0), sv2v_cast_92577(1'sb0), 1'sb0, 1'b1};
	input clk_i;
	input rst_ni;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	output wire err_o;
	localparam signed [31:0] IW = top_pkg_TL_AIW;
	localparam signed [31:0] SZW = top_pkg_TL_SZW;
	localparam signed [31:0] DW = top_pkg_TL_DW;
	localparam signed [31:0] MW = top_pkg_TL_DBW;
	localparam signed [31:0] SubAW = 2;
	wire opcode_allowed;
	wire a_config_allowed;
	wire op_full;
	wire op_partial;
	wire op_get;
	assign op_full = tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == PutFullData;
	assign op_partial = tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == PutPartialData;
	assign op_get = tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == Get;
	assign err_o = ~(opcode_allowed & a_config_allowed);
	assign opcode_allowed = ((tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == PutFullData) | (tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == PutPartialData)) | (tl_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] == Get);
	reg addr_sz_chk;
	reg mask_chk;
	reg fulldata_chk;
	wire [MW - 1:0] mask;
	assign mask = 1 << tl_i[(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - ((top_pkg_TL_AW - 1) - (SubAW - 1)):(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_AW - 1)];
	always @(*) begin
		addr_sz_chk = 1'b0;
		mask_chk = 1'b0;
		fulldata_chk = 1'b0;
		if (tl_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))])
			case (tl_i[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)])
				'h0: begin
					addr_sz_chk = 1'b1;
					mask_chk = ~|(tl_i[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)] & ~mask);
					fulldata_chk = |(tl_i[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)] & mask);
				end
				'h1: begin
					addr_sz_chk = ~tl_i[(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_AW - 1)];
					mask_chk = (tl_i[(32 + (top_pkg_TL_DBW + 48)) - 30] ? ~|(tl_i[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)] & 4'b0011) : ~|(tl_i[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)] & 4'b1100));
					fulldata_chk = (tl_i[(32 + (top_pkg_TL_DBW + 48)) - 30] ? &tl_i[(top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DBW - 4):(top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DBW - 3)] : &tl_i[(top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DBW - 2):(top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DBW - 1)]);
				end
				'h2: begin
					addr_sz_chk = ~|tl_i[(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - ((top_pkg_TL_AW - 1) - (SubAW - 1)):(top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_AW - 1)];
					mask_chk = 1'b1;
					fulldata_chk = &tl_i[(top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DBW - 4):(top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DBW - 1)];
				end
				default: begin
					addr_sz_chk = 1'b0;
					mask_chk = 1'b0;
					fulldata_chk = 1'b0;
				end
			endcase
		else begin
			addr_sz_chk = 1'b0;
			mask_chk = 1'b0;
			fulldata_chk = 1'b0;
		end
	end
	assign a_config_allowed = (addr_sz_chk & mask_chk) & ((op_get | op_partial) | fulldata_chk);
endmodule
module tlul_err_resp (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_h_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_h_o;
	localparam ArbiterImpl = "PPC";
	localparam [31:0] ADDR_SPACE_UART = 32'h40000000;
	localparam [31:0] ADDR_SPACE_GPIO = 32'h40010000;
	localparam [31:0] ADDR_SPACE_SRAMD = 32'h18000000;
	localparam [31:0] ADDR_SPACE_SRAMI = 32'h00080000;
	localparam [31:0] ADDR_SPACE_DEBUG_MEM = 32'h1a110000;
	localparam [31:0] ADDR_SPACE_RV_PLIC = 32'h40090000;
	localparam [31:0] ADDR_SPACE_SPI_DEVICE = 32'h40020000;
	localparam [31:0] ADDR_SPACE_RV_TIMER = 32'h40080000;
	localparam [31:0] ADDR_MASK_UART = 32'h00000fff;
	localparam [31:0] ADDR_MASK_GPIO = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SRAMD = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_SRAMI = 32'h0000ffff;
	localparam [31:0] ADDR_MASK_DEBUG_MEM = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_PLIC = 32'h00000fff;
	localparam [31:0] ADDR_MASK_SPI_DEVICE = 32'h00000fff;
	localparam [31:0] ADDR_MASK_RV_TIMER = 32'h00000fff;
	localparam [2:0] PutFullData = 3'h0;
	localparam [2:0] PutPartialData = 3'h1;
	localparam [2:0] Get = 3'h4;
	localparam [2:0] AccessAck = 3'h0;
	localparam [2:0] AccessAckData = 3'h1;
	function automatic [top_pkg_TL_SZW - 1:0] sv2v_cast_F00AF;
		input reg [top_pkg_TL_SZW - 1:0] inp;
		sv2v_cast_F00AF = inp;
	endfunction
	function automatic [top_pkg_TL_AIW - 1:0] sv2v_cast_F1F18;
		input reg [top_pkg_TL_AIW - 1:0] inp;
		sv2v_cast_F1F18 = inp;
	endfunction
	function automatic [top_pkg_TL_AW - 1:0] sv2v_cast_4CD75;
		input reg [top_pkg_TL_AW - 1:0] inp;
		sv2v_cast_4CD75 = inp;
	endfunction
	function automatic [top_pkg_TL_DBW - 1:0] sv2v_cast_37199;
		input reg [top_pkg_TL_DBW - 1:0] inp;
		sv2v_cast_37199 = inp;
	endfunction
	function automatic [top_pkg_TL_DW - 1:0] sv2v_cast_2497D;
		input reg [top_pkg_TL_DW - 1:0] inp;
		sv2v_cast_2497D = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] TL_H2D_DEFAULT = {1'sb0, 3'b000, 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_4CD75(1'sb0), sv2v_cast_37199(1'sb0), sv2v_cast_2497D(1'sb0), 16'b0000000000000000, 1'b1};
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [top_pkg_TL_DIW - 1:0] sv2v_cast_B5AB2;
		input reg [top_pkg_TL_DIW - 1:0] inp;
		sv2v_cast_B5AB2 = inp;
	endfunction
	function automatic [top_pkg_TL_DUW - 1:0] sv2v_cast_92577;
		input reg [top_pkg_TL_DUW - 1:0] inp;
		sv2v_cast_92577 = inp;
	endfunction
	localparam [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] TL_D2H_DEFAULT = {1'sb0, sv2v_cast_3(3'b000), 3'b000, sv2v_cast_F00AF(1'sb0), sv2v_cast_F1F18(1'sb0), sv2v_cast_B5AB2(1'sb0), sv2v_cast_2497D(1'sb0), sv2v_cast_92577(1'sb0), 1'sb0, 1'b1};
	reg [2:0] err_opcode;
	reg [top_pkg_TL_AIW - 1:0] err_source;
	reg [top_pkg_TL_SZW - 1:0] err_size;
	reg err_req_pending;
	reg err_rsp_pending;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			err_req_pending <= 1'b0;
			err_source <= {top_pkg_TL_AIW {1'b0}};
			err_opcode <= Get;
			err_size <= {top_pkg_TL_SZW {1'sb0}};
		end
		else if (tl_h_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] && tl_h_o[0]) begin
			err_req_pending <= 1'b1;
			err_source <= tl_h_i[top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))-:((40 + (top_pkg_TL_DBW + 48)) >= (32 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) + 1 : ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + 1)];
			err_opcode <= tl_h_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)];
			err_size <= tl_h_i[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)];
		end
		else if (!err_rsp_pending)
			err_req_pending <= 1'b0;
	assign tl_h_o[0] = ~err_rsp_pending & ~(err_req_pending & ~tl_h_i[0]);
	assign tl_h_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))] = err_req_pending | err_rsp_pending;
	assign tl_h_o[top_pkg_TL_DW + (top_pkg_TL_DUW + 1)-:((top_pkg_TL_DW + (top_pkg_TL_DUW + 1)) - (top_pkg_TL_DUW + 2)) + 1] = {((top_pkg_TL_DW + (top_pkg_TL_DUW + 1)) - (((top_pkg_TL_DW + (top_pkg_TL_DUW + 1)) - (((top_pkg_TL_DW + (top_pkg_TL_DUW + 1)) - (top_pkg_TL_DUW + 2)) + 1)) + 1)) + 1 {1'sb1}};
	assign tl_h_o[top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))-:((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))) - (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) + 1] = err_source;
	assign tl_h_o[top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))-:((top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))) - (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))) + 1] = {((top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))) - (((top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))) - (((top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))) - (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))) + 1)) + 1)) + 1 {1'sb0}};
	assign tl_h_o[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((3 + (top_pkg_TL_SZW + 58)) >= (top_pkg_TL_SZW + 59) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)] = {((3 + (top_pkg_TL_SZW + 58)) >= (((3 + (top_pkg_TL_SZW + 58)) - ((3 + (top_pkg_TL_SZW + 58)) >= (top_pkg_TL_SZW + 59) ? ((3 + (top_pkg_TL_SZW + 58)) - (top_pkg_TL_SZW + 59)) + 1 : ((top_pkg_TL_SZW + 59) - (3 + (top_pkg_TL_SZW + 58))) + 1)) + 1) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - ((3 + (top_pkg_TL_SZW + 58)) >= (top_pkg_TL_SZW + 59) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)) + 1)) + 1 : ((((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - ((3 + (top_pkg_TL_SZW + 58)) >= (top_pkg_TL_SZW + 59) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)) + 1) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1) {1'sb0}};
	assign tl_h_o[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))-:((top_pkg_TL_SZW + 58) >= 59 ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))) - (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) + 1)] = err_size;
	assign tl_h_o[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((6 + (top_pkg_TL_SZW + 58)) >= (3 + (top_pkg_TL_SZW + 59)) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)] = (err_opcode == Get ? AccessAckData : AccessAck);
	assign tl_h_o[top_pkg_TL_DUW + 1-:top_pkg_TL_DUW] = {((top_pkg_TL_DUW + 1) - (((top_pkg_TL_DUW + 1) - top_pkg_TL_DUW) + 1)) + 1 {1'sb0}};
	assign tl_h_o[1] = 1'b1;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			err_rsp_pending <= 1'b0;
		else if ((err_req_pending || err_rsp_pending) && !tl_h_i[0])
			err_rsp_pending <= 1'b1;
		else
			err_rsp_pending <= 1'b0;
endmodule
module tlul_fifo_sync (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o,
	tl_d_o,
	tl_d_i,
	spare_req_i,
	spare_req_o,
	spare_rsp_i,
	spare_rsp_o
);
	parameter [31:0] ReqPass = 1'b1;
	parameter [31:0] RspPass = 1'b1;
	parameter [31:0] ReqDepth = 2;
	parameter [31:0] RspDepth = 2;
	parameter [31:0] SpareReqW = 1;
	parameter [31:0] SpareRspW = 1;
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_h_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_h_o;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_d_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_d_i;
	input [SpareReqW - 1:0] spare_req_i;
	output [SpareReqW - 1:0] spare_req_o;
	input [SpareRspW - 1:0] spare_rsp_i;
	output [SpareRspW - 1:0] spare_rsp_o;
	localparam [31:0] REQFIFO_WIDTH = ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15) + SpareReqW;
	prim_fifo_sync #(
		.Width(REQFIFO_WIDTH),
		.Pass(ReqPass),
		.Depth(ReqDepth)
	) reqfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(tl_h_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))]),
		.wready_o(tl_h_o[0]),
		.wdata_i({tl_h_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)], tl_h_i[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)], tl_h_i[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)], tl_h_i[top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))-:((40 + (top_pkg_TL_DBW + 48)) >= (32 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) + 1 : ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + 1)], tl_h_i[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)], tl_h_i[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)], tl_h_i[top_pkg_TL_DW + 16-:top_pkg_TL_DW], tl_h_i[16-:16], spare_req_i}),
		.depth_o(),
		.rvalid_o(tl_d_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))]),
		.rready_i(tl_d_i[0]),
		.rdata_o({tl_d_o[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)], tl_d_o[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)], tl_d_o[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)], tl_d_o[top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))-:((40 + (top_pkg_TL_DBW + 48)) >= (32 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) + 1 : ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + 1)], tl_d_o[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)], tl_d_o[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)], tl_d_o[top_pkg_TL_DW + 16-:top_pkg_TL_DW], tl_d_o[16-:16], spare_req_o})
	);
	localparam [31:0] RSPFIFO_WIDTH = ((((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)) - 2) + SpareRspW;
	localparam [2:0] tlul_pkg_AccessAckData = 3'h1;
	prim_fifo_sync #(
		.Width(RSPFIFO_WIDTH),
		.Pass(RspPass),
		.Depth(RspDepth)
	) rspfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(tl_d_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))]),
		.wready_o(tl_d_o[0]),
		.wdata_i({tl_d_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((6 + (top_pkg_TL_SZW + 58)) >= (3 + (top_pkg_TL_SZW + 59)) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)], tl_d_i[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((3 + (top_pkg_TL_SZW + 58)) >= (top_pkg_TL_SZW + 59) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)], tl_d_i[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))-:((top_pkg_TL_SZW + 58) >= 59 ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))) - (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) + 1)], tl_d_i[top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))-:((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))) - (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) + 1], tl_d_i[top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))-:((top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))) - (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))) + 1], (tl_d_i[6 + (top_pkg_TL_SZW + 58)-:((6 + (top_pkg_TL_SZW + 58)) >= (3 + (top_pkg_TL_SZW + 59)) ? ((6 + (top_pkg_TL_SZW + 58)) - (3 + (top_pkg_TL_SZW + 59))) + 1 : ((3 + (top_pkg_TL_SZW + 59)) - (6 + (top_pkg_TL_SZW + 58))) + 1)] == 3'h1 ? tl_d_i[top_pkg_TL_DW + (top_pkg_TL_DUW + 1)-:((top_pkg_TL_DW + (top_pkg_TL_DUW + 1)) - (top_pkg_TL_DUW + 2)) + 1] : {top_pkg_TL_DW {1'b0}}), tl_d_i[top_pkg_TL_DUW + 1-:top_pkg_TL_DUW], tl_d_i[1], spare_rsp_i}),
		.depth_o(),
		.rvalid_o(tl_h_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))]),
		.rready_i(tl_h_i[0]),
		.rdata_o({tl_h_o[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((6 + (top_pkg_TL_SZW + 58)) >= (3 + (top_pkg_TL_SZW + 59)) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)], tl_h_o[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((3 + (top_pkg_TL_SZW + 58)) >= (top_pkg_TL_SZW + 59) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)], tl_h_o[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))-:((top_pkg_TL_SZW + 58) >= 59 ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))) - (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) + 1)], tl_h_o[top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))-:((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))) - (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) + 1], tl_h_o[top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))-:((top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))) - (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))) + 1], tl_h_o[top_pkg_TL_DW + (top_pkg_TL_DUW + 1)-:((top_pkg_TL_DW + (top_pkg_TL_DUW + 1)) - (top_pkg_TL_DUW + 2)) + 1], tl_h_o[top_pkg_TL_DUW + 1-:top_pkg_TL_DUW], tl_h_o[1], spare_rsp_o})
	);
endmodule
module tlul_socket_1n (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o,
	tl_d_o,
	tl_d_i,
	dev_select_i
);
	parameter [31:0] N = 4;
	parameter [0:0] HReqPass = 1'b1;
	parameter [0:0] HRspPass = 1'b1;
	parameter [N - 1:0] DReqPass = {N {1'b1}};
	parameter [N - 1:0] DRspPass = {N {1'b1}};
	parameter [3:0] HReqDepth = 4'h2;
	parameter [3:0] HRspDepth = 4'h2;
	parameter [(N * 4) - 1:0] DReqDepth = {N {4'h2}};
	parameter [(N * 4) - 1:0] DRspDepth = {N {4'h2}};
	localparam [31:0] NWD = $clog2(N + 1);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_h_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_h_o;
	output wire [(0 >= (N - 1) ? (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((2 - N) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) + (((N - 1) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1) : ((2 - N) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + ((N - 1) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))) - 1)) : (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (N * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (N * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15))):(0 >= (N - 1) ? (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (N - 1) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + ((N - 1) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))) : (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] tl_d_o;
	input wire [(0 >= (N - 1) ? (((7 + top_pkg_TL_SZW) + 58) >= 0 ? ((2 - N) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) + (((N - 1) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1) : ((2 - N) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + ((((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + ((N - 1) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))) - 1)) : (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (N * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (N * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW))):(0 >= (N - 1) ? (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (N - 1) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + ((N - 1) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))) : (((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] tl_d_i;
	input [NWD - 1:0] dev_select_i;
	wire [NWD - 1:0] dev_select_t;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_t_o;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_t_i;
	tlul_fifo_sync #(
		.ReqPass(HReqPass),
		.RspPass(HRspPass),
		.ReqDepth(HReqDepth),
		.RspDepth(HRspDepth),
		.SpareReqW(NWD)
	) fifo_h(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_h_i),
		.tl_h_o(tl_h_o),
		.tl_d_o(tl_t_o),
		.tl_d_i(tl_t_i),
		.spare_req_i(dev_select_i),
		.spare_req_o(dev_select_t),
		.spare_rsp_i(1'b0),
		.spare_rsp_o()
	);
	reg [7:0] num_req_outstanding;
	reg [NWD - 1:0] dev_select_outstanding;
	wire hold_all_requests;
	wire accept_t_req;
	wire accept_t_rsp;
	assign accept_t_req = tl_t_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] & tl_t_i[0];
	assign accept_t_rsp = tl_t_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))] & tl_t_o[0];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			num_req_outstanding <= 8'h00;
			dev_select_outstanding <= {NWD {1'sb0}};
		end
		else if (accept_t_req) begin
			if (!accept_t_rsp)
				num_req_outstanding <= num_req_outstanding + 8'h01;
			dev_select_outstanding <= dev_select_t;
		end
		else if (accept_t_rsp)
			num_req_outstanding <= num_req_outstanding - 8'h01;
	assign hold_all_requests = (num_req_outstanding != 8'h00) & (dev_select_t != dev_select_outstanding);
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_u_o [0:N];
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_u_i [0:N];
	generate
		genvar i;
		for (i = 0; i < N; i = i + 1) begin : gen_u_o
			function automatic signed [NWD - 1:0] sv2v_cast_3B809_signed;
				input reg signed [NWD - 1:0] inp;
				sv2v_cast_3B809_signed = inp;
			endfunction
			assign tl_u_o[i][7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] = (tl_t_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] & (dev_select_t == sv2v_cast_3B809_signed(i))) & ~hold_all_requests;
			assign tl_u_o[i][6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] = tl_t_o[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)];
			assign tl_u_o[i][3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] = tl_t_o[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)];
			assign tl_u_o[i][top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)] = tl_t_o[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)];
			assign tl_u_o[i][top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))-:((40 + (top_pkg_TL_DBW + 48)) >= (32 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) + 1 : ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + 1)] = tl_t_o[top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))-:((40 + (top_pkg_TL_DBW + 48)) >= (32 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) + 1 : ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + 1)];
			assign tl_u_o[i][top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] = tl_t_o[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)];
			assign tl_u_o[i][top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)] = tl_t_o[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)];
			assign tl_u_o[i][top_pkg_TL_DW + 16-:top_pkg_TL_DW] = tl_t_o[top_pkg_TL_DW + 16-:top_pkg_TL_DW];
			assign tl_u_o[i][16-:16] = tl_t_o[16-:16];
		end
	endgenerate
	reg [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_t_p;
	reg hfifo_reqready;
	function automatic signed [NWD - 1:0] sv2v_cast_3B809_signed;
		input reg signed [NWD - 1:0] inp;
		sv2v_cast_3B809_signed = inp;
	endfunction
	always @(*) begin
		hfifo_reqready = tl_u_i[N][0];
		begin : sv2v_autoblock_84
			reg signed [31:0] idx;
			for (idx = 0; idx < N; idx = idx + 1)
				if (dev_select_t == sv2v_cast_3B809_signed(idx))
					hfifo_reqready = tl_u_i[idx][0];
		end
		if (hold_all_requests)
			hfifo_reqready = 1'b0;
	end
	assign tl_t_i[0] = tl_t_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] & hfifo_reqready;
	always @(*) begin
		tl_t_p = tl_u_i[N];
		begin : sv2v_autoblock_85
			reg signed [31:0] idx;
			for (idx = 0; idx < N; idx = idx + 1)
				if (dev_select_outstanding == sv2v_cast_3B809_signed(idx))
					tl_t_p = tl_u_i[idx];
		end
	end
	assign tl_t_i[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))] = tl_t_p[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))];
	assign tl_t_i[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((6 + (top_pkg_TL_SZW + 58)) >= (3 + (top_pkg_TL_SZW + 59)) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)] = tl_t_p[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((6 + (top_pkg_TL_SZW + 58)) >= (3 + (top_pkg_TL_SZW + 59)) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)];
	assign tl_t_i[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((3 + (top_pkg_TL_SZW + 58)) >= (top_pkg_TL_SZW + 59) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)] = tl_t_p[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((3 + (top_pkg_TL_SZW + 58)) >= (top_pkg_TL_SZW + 59) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)];
	assign tl_t_i[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))-:((top_pkg_TL_SZW + 58) >= 59 ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))) - (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) + 1)] = tl_t_p[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))-:((top_pkg_TL_SZW + 58) >= 59 ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))) - (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) + 1)];
	assign tl_t_i[top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))-:((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))) - (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) + 1] = tl_t_p[top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))-:((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))) - (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) + 1];
	assign tl_t_i[top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))-:((top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))) - (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))) + 1] = tl_t_p[top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))-:((top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))) - (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))) + 1];
	assign tl_t_i[top_pkg_TL_DW + (top_pkg_TL_DUW + 1)-:((top_pkg_TL_DW + (top_pkg_TL_DUW + 1)) - (top_pkg_TL_DUW + 2)) + 1] = tl_t_p[top_pkg_TL_DW + (top_pkg_TL_DUW + 1)-:((top_pkg_TL_DW + (top_pkg_TL_DUW + 1)) - (top_pkg_TL_DUW + 2)) + 1];
	assign tl_t_i[top_pkg_TL_DUW + 1-:top_pkg_TL_DUW] = tl_t_p[top_pkg_TL_DUW + 1-:top_pkg_TL_DUW];
	assign tl_t_i[1] = tl_t_p[1];
	generate
		for (i = 0; i < (N + 1); i = i + 1) begin : gen_u_o_d_ready
			assign tl_u_o[i][0] = tl_t_o[0];
		end
	endgenerate
	generate
		for (i = 0; i < N; i = i + 1) begin : gen_dfifo
			tlul_fifo_sync #(
				.ReqPass(DReqPass[i]),
				.RspPass(DRspPass[i]),
				.ReqDepth(DReqDepth[i * 4+:4]),
				.RspDepth(DRspDepth[i * 4+:4])
			) fifo_d(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.tl_h_i(tl_u_o[i]),
				.tl_h_o(tl_u_i[i]),
				.tl_d_o(tl_d_o[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + ((0 >= (N - 1) ? i : (N - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))]),
				.tl_d_i(tl_d_i[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + ((0 >= (N - 1) ? i : (N - 1) - i) * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))]),
				.spare_req_i(1'b0),
				.spare_req_o(),
				.spare_rsp_i(1'b0),
				.spare_rsp_o()
			);
		end
	endgenerate
	function automatic [NWD - 1:0] sv2v_cast_3B809_unsigned;
		input reg [NWD - 1:0] inp;
		sv2v_cast_3B809_unsigned = inp;
	endfunction
	assign tl_u_o[N][7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] = (tl_t_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))] & (dev_select_t == sv2v_cast_3B809_unsigned(N))) & ~hold_all_requests;
	assign tl_u_o[N][6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] = tl_t_o[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)];
	assign tl_u_o[N][3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)] = tl_t_o[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)];
	assign tl_u_o[N][top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)] = tl_t_o[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)];
	assign tl_u_o[N][top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))-:((40 + (top_pkg_TL_DBW + 48)) >= (32 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) + 1 : ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + 1)] = tl_t_o[top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))-:((40 + (top_pkg_TL_DBW + 48)) >= (32 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) + 1 : ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + 1)];
	assign tl_u_o[N][top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)] = tl_t_o[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)];
	assign tl_u_o[N][top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)] = tl_t_o[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)];
	assign tl_u_o[N][top_pkg_TL_DW + 16-:top_pkg_TL_DW] = tl_t_o[top_pkg_TL_DW + 16-:top_pkg_TL_DW];
	assign tl_u_o[N][16-:16] = tl_t_o[16-:16];
	tlul_err_resp err_resp(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_u_o[N]),
		.tl_h_o(tl_u_i[N])
	);
endmodule
module tlul_socket_m1 (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o,
	tl_d_o,
	tl_d_i
);
	parameter [31:0] M = 4;
	parameter [M - 1:0] HReqPass = {M {1'b1}};
	parameter [M - 1:0] HRspPass = {M {1'b1}};
	parameter [(M * 4) - 1:0] HReqDepth = {M {4'h2}};
	parameter [(M * 4) - 1:0] HRspDepth = {M {4'h2}};
	parameter [0:0] DReqPass = 1'b1;
	parameter [0:0] DRspPass = 1'b1;
	parameter [3:0] DReqDepth = 4'h2;
	parameter [3:0] DRspDepth = 4'h2;
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(0 >= (M - 1) ? (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((2 - M) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) + (((M - 1) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1) : ((2 - M) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + ((M - 1) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))) - 1)) : (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (M * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (M * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15))):(0 >= (M - 1) ? (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (M - 1) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + ((M - 1) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))) : (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] tl_h_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(0 >= (M - 1) ? (((7 + top_pkg_TL_SZW) + 58) >= 0 ? ((2 - M) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) + (((M - 1) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1) : ((2 - M) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + ((((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + ((M - 1) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))) - 1)) : (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (M * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2)) - 1 : (M * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))) + (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW))):(0 >= (M - 1) ? (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (M - 1) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + ((M - 1) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))) : (((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))] tl_h_o;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_d_o;
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_d_i;
	localparam [31:0] IDW = top_pkg_TL_AIW;
	localparam [31:0] STIDW = $clog2(M);
	wire [(0 >= (M - 1) ? (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((2 - M) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) + (((M - 1) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1) : ((2 - M) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + ((M - 1) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))) - 1)) : (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (M * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17)) - 1 : (M * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 15))):(0 >= (M - 1) ? (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (M - 1) * ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + ((M - 1) * (1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))) : (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))] hreq_fifo_o;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] hrsp_fifo_i [0:M - 1];
	wire [M - 1:0] hrequest;
	wire [M - 1:0] hgrant;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] dreq_fifo_i;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] drsp_fifo_o;
	wire arb_valid;
	wire arb_ready;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] arb_data;
	generate
		genvar i;
		for (i = 0; i < M; i = i + 1) begin : gen_host_fifo
			wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] hreq_fifo_i;
			wire [STIDW - 1:0] reqid_sub;
			wire [IDW - 1:0] shifted_id;
			assign reqid_sub = i;
			assign shifted_id = {tl_h_i[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AIW - 1) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AIW - 1))) : ((((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AIW - 1) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AIW - 1)))) - (IDW - STIDW)) + 1)+:IDW - STIDW], reqid_sub};
			wire [IDW - 1:IDW - STIDW] unused_tl_h_source;
			assign unused_tl_h_source = tl_h_i[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - ((top_pkg_TL_AIW - 1) - (IDW - 1)) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - ((top_pkg_TL_AIW - 1) - (IDW - 1)))) : ((((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - ((top_pkg_TL_AIW - 1) - (IDW - 1)) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - ((top_pkg_TL_AIW - 1) - (IDW - 1))))) + STIDW) - 1)-:STIDW];
			function automatic [0:0] sv2v_cast_1;
				input reg [0:0] inp;
				sv2v_cast_1 = inp;
			endfunction
			function automatic [2:0] sv2v_cast_3;
				input reg [2:0] inp;
				sv2v_cast_3 = inp;
			endfunction
			function automatic [top_pkg_TL_SZW - 1:0] sv2v_cast_F00AF;
				input reg [top_pkg_TL_SZW - 1:0] inp;
				sv2v_cast_F00AF = inp;
			endfunction
			function automatic [top_pkg_TL_AIW - 1:0] sv2v_cast_F1F18;
				input reg [top_pkg_TL_AIW - 1:0] inp;
				sv2v_cast_F1F18 = inp;
			endfunction
			function automatic [top_pkg_TL_AW - 1:0] sv2v_cast_4CD75;
				input reg [top_pkg_TL_AW - 1:0] inp;
				sv2v_cast_4CD75 = inp;
			endfunction
			function automatic [top_pkg_TL_DBW - 1:0] sv2v_cast_37199;
				input reg [top_pkg_TL_DBW - 1:0] inp;
				sv2v_cast_37199 = inp;
			endfunction
			function automatic [top_pkg_TL_DW - 1:0] sv2v_cast_2497D;
				input reg [top_pkg_TL_DW - 1:0] inp;
				sv2v_cast_2497D = inp;
			endfunction
			function automatic [15:0] sv2v_cast_16;
				input reg [15:0] inp;
				sv2v_cast_16 = inp;
			endfunction
			assign hreq_fifo_i = {sv2v_cast_1(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))))]), sv2v_cast_3(tl_h_i[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) : ((((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))))) + ((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)) - 1)-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)]), sv2v_cast_3(tl_h_i[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) : ((((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))))) + ((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)) - 1)-:((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)]), sv2v_cast_F00AF(tl_h_i[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) : ((((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + ((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)) - 1)-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)]), sv2v_cast_F1F18(shifted_id), sv2v_cast_4CD75(tl_h_i[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) : ((((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + ((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)) - 1)-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)]), sv2v_cast_37199(tl_h_i[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? top_pkg_TL_DBW + (top_pkg_TL_DW + 16) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) : ((((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? top_pkg_TL_DBW + (top_pkg_TL_DW + 16) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + ((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)) - 1)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)]), sv2v_cast_2497D(tl_h_i[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? top_pkg_TL_DW + 16 : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (top_pkg_TL_DW + 16)) : ((((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? top_pkg_TL_DW + 16 : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (top_pkg_TL_DW + 16))) + top_pkg_TL_DW) - 1)-:top_pkg_TL_DW]), sv2v_cast_16(tl_h_i[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? ((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 16 : ((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) : (((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 16 : ((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW)) + 15)-:16]), sv2v_cast_1(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)])};
			tlul_fifo_sync #(
				.ReqPass(HReqPass[i]),
				.RspPass(HRspPass[i]),
				.ReqDepth(HReqDepth[i * 4+:4]),
				.RspDepth(HRspDepth[i * 4+:4]),
				.SpareReqW(1)
			) u_hostfifo(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.tl_h_i(hreq_fifo_i),
				.tl_h_o(tl_h_o[(((7 + top_pkg_TL_SZW) + 58) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1) + ((0 >= (M - 1) ? i : (M - 1) - i) * (((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1)))+:(((7 + top_pkg_TL_SZW) + 58) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 2 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1))]),
				.tl_d_o(hreq_fifo_o[(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) + ((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)))+:(((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))]),
				.tl_d_i(hrsp_fifo_i[i]),
				.spare_req_i(1'b0),
				.spare_req_o(),
				.spare_rsp_i(1'b0),
				.spare_rsp_o()
			);
		end
	endgenerate
	tlul_fifo_sync #(
		.ReqPass(DReqPass),
		.RspPass(DRspPass),
		.ReqDepth(DReqDepth),
		.RspDepth(DRspDepth),
		.SpareReqW(1)
	) u_devicefifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(dreq_fifo_i),
		.tl_h_o(drsp_fifo_o),
		.tl_d_o(tl_d_o),
		.tl_d_i(tl_d_i),
		.spare_req_i(1'b0),
		.spare_req_o(),
		.spare_rsp_i(1'b0),
		.spare_rsp_o()
	);
	generate
		for (i = 0; i < M; i = i + 1) begin : gen_arbreqgnt
			assign hrequest[i] = hreq_fifo_o[((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) : ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16) - (7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))))];
		end
	endgenerate
	assign arb_ready = drsp_fifo_o[0];
	localparam tlul_pkg_ArbiterImpl = "PPC";
	generate
		if (tlul_pkg_ArbiterImpl == "PPC") begin : gen_arb_ppc
			prim_arbiter_ppc #(
				.N(M),
				.DW((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17),
				.EnReqStabA(0)
			) u_reqarb(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.req_i(hrequest),
				.data_i(hreq_fifo_o),
				.gnt_o(hgrant),
				.idx_o(),
				.valid_o(arb_valid),
				.data_o(arb_data),
				.ready_i(arb_ready)
			);
		end
		else if (tlul_pkg_ArbiterImpl == "BINTREE") begin : gen_tree_arb
			prim_arbiter_tree #(
				.N(M),
				.DW((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17),
				.EnReqStabA(0)
			) u_reqarb(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.req_i(hrequest),
				.data_i(hreq_fifo_o),
				.gnt_o(hgrant),
				.idx_o(),
				.valid_o(arb_valid),
				.data_o(arb_data),
				.ready_i(arb_ready)
			);
		end
	endgenerate
	wire [M - 1:0] hfifo_rspvalid;
	wire [M - 1:0] dfifo_rspready;
	wire [IDW - 1:0] hfifo_rspid;
	wire dfifo_rspready_merged;
	assign dfifo_rspready_merged = |dfifo_rspready;
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [top_pkg_TL_SZW - 1:0] sv2v_cast_F00AF;
		input reg [top_pkg_TL_SZW - 1:0] inp;
		sv2v_cast_F00AF = inp;
	endfunction
	function automatic [top_pkg_TL_AIW - 1:0] sv2v_cast_F1F18;
		input reg [top_pkg_TL_AIW - 1:0] inp;
		sv2v_cast_F1F18 = inp;
	endfunction
	function automatic [top_pkg_TL_AW - 1:0] sv2v_cast_4CD75;
		input reg [top_pkg_TL_AW - 1:0] inp;
		sv2v_cast_4CD75 = inp;
	endfunction
	function automatic [top_pkg_TL_DBW - 1:0] sv2v_cast_37199;
		input reg [top_pkg_TL_DBW - 1:0] inp;
		sv2v_cast_37199 = inp;
	endfunction
	function automatic [top_pkg_TL_DW - 1:0] sv2v_cast_2497D;
		input reg [top_pkg_TL_DW - 1:0] inp;
		sv2v_cast_2497D = inp;
	endfunction
	function automatic [15:0] sv2v_cast_16;
		input reg [15:0] inp;
		sv2v_cast_16 = inp;
	endfunction
	assign dreq_fifo_i = {sv2v_cast_1(arb_valid), sv2v_cast_3(arb_data[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((6 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49)))) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)]), sv2v_cast_3(arb_data[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))-:((3 + (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48)))) >= (top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 49))) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))))) + 1)]), sv2v_cast_F00AF(arb_data[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))-:((top_pkg_TL_SZW + (40 + (top_pkg_TL_DBW + 48))) >= (40 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))))) + 1)]), sv2v_cast_F1F18(arb_data[top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))-:((40 + (top_pkg_TL_DBW + 48)) >= (32 + (top_pkg_TL_DBW + 49)) ? ((top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17)))) + 1 : ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) - (top_pkg_TL_AIW + (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))))) + 1)]), sv2v_cast_4CD75(arb_data[top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))-:((32 + (top_pkg_TL_DBW + 48)) >= (top_pkg_TL_DBW + 49) ? ((top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 17))) + 1 : ((top_pkg_TL_DBW + (top_pkg_TL_DW + 17)) - (top_pkg_TL_AW + (top_pkg_TL_DBW + (top_pkg_TL_DW + 16)))) + 1)]), sv2v_cast_37199(arb_data[top_pkg_TL_DBW + (top_pkg_TL_DW + 16)-:((top_pkg_TL_DBW + 48) >= 49 ? ((top_pkg_TL_DBW + (top_pkg_TL_DW + 16)) - (top_pkg_TL_DW + 17)) + 1 : ((top_pkg_TL_DW + 17) - (top_pkg_TL_DBW + (top_pkg_TL_DW + 16))) + 1)]), sv2v_cast_2497D(arb_data[top_pkg_TL_DW + 16-:top_pkg_TL_DW]), sv2v_cast_16(arb_data[16-:16]), sv2v_cast_1(dfifo_rspready_merged)};
	assign hfifo_rspid = {{STIDW {1'b0}}, drsp_fifo_o[(top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))) - ((top_pkg_TL_AIW - 1) - (IDW - 1)):(top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))) - ((top_pkg_TL_AIW - 1) - STIDW)]};
	generate
		for (i = 0; i < M; i = i + 1) begin : gen_idrouting
			assign hfifo_rspvalid[i] = drsp_fifo_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))] & (drsp_fifo_o[(top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))) - (top_pkg_TL_AIW - 1)+:STIDW] == i);
			assign dfifo_rspready[i] = (hreq_fifo_o[((0 >= (M - 1) ? i : (M - 1) - i) * (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 17 : 1 - ((((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16))) + (((((7 + top_pkg_TL_SZW) + 40) + top_pkg_TL_DBW) + 48) >= 0 ? 0 : (((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16)] & (drsp_fifo_o[(top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))) - (top_pkg_TL_AIW - 1)+:STIDW] == i)) & drsp_fifo_o[7 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))];
			function automatic [top_pkg_TL_DIW - 1:0] sv2v_cast_B5AB2;
				input reg [top_pkg_TL_DIW - 1:0] inp;
				sv2v_cast_B5AB2 = inp;
			endfunction
			function automatic [top_pkg_TL_DUW - 1:0] sv2v_cast_92577;
				input reg [top_pkg_TL_DUW - 1:0] inp;
				sv2v_cast_92577 = inp;
			endfunction
			assign hrsp_fifo_i[i] = {sv2v_cast_1(hfifo_rspvalid[i]), sv2v_cast_3(drsp_fifo_o[6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((6 + (top_pkg_TL_SZW + 58)) >= (3 + (top_pkg_TL_SZW + 59)) ? ((6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))))) + 1 : ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) - (6 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)]), sv2v_cast_3(drsp_fifo_o[3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))-:((3 + (top_pkg_TL_SZW + 58)) >= (top_pkg_TL_SZW + 59) ? ((3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))))) + 1 : ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) - (3 + (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))))) + 1)]), sv2v_cast_F00AF(drsp_fifo_o[top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))-:((top_pkg_TL_SZW + 58) >= 59 ? ((top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))))) - (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))))) + 1 : ((top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 2)))) - (top_pkg_TL_SZW + (top_pkg_TL_AIW + (top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1)))))) + 1)]), sv2v_cast_F1F18(hfifo_rspid), sv2v_cast_B5AB2(drsp_fifo_o[top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))-:((top_pkg_TL_DIW + (top_pkg_TL_DW + (top_pkg_TL_DUW + 1))) - (top_pkg_TL_DW + (top_pkg_TL_DUW + 2))) + 1]), sv2v_cast_2497D(drsp_fifo_o[top_pkg_TL_DW + (top_pkg_TL_DUW + 1)-:((top_pkg_TL_DW + (top_pkg_TL_DUW + 1)) - (top_pkg_TL_DUW + 2)) + 1]), sv2v_cast_92577(drsp_fifo_o[top_pkg_TL_DUW + 1-:top_pkg_TL_DUW]), sv2v_cast_1(drsp_fifo_o[1]), sv2v_cast_1(hgrant[i])};
		end
	endgenerate
endmodule
module uart (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	cio_rx_i,
	cio_tx_o,
	cio_tx_en_o,
	intr_tx_watermark_o,
	intr_rx_watermark_o,
	intr_tx_empty_o,
	intr_rx_overflow_o,
	intr_rx_frame_err_o,
	intr_rx_break_err_o,
	intr_rx_timeout_o,
	intr_rx_parity_err_o
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_o;
	input cio_rx_i;
	output wire cio_tx_o;
	output wire cio_tx_en_o;
	output wire intr_tx_watermark_o;
	output wire intr_rx_watermark_o;
	output wire intr_tx_empty_o;
	output wire intr_rx_overflow_o;
	output wire intr_rx_frame_err_o;
	output wire intr_rx_break_err_o;
	output wire intr_rx_timeout_o;
	output wire intr_rx_parity_err_o;
	localparam [5:0] UART_INTR_STATE_OFFSET = 6'h00;
	localparam [5:0] UART_INTR_ENABLE_OFFSET = 6'h04;
	localparam [5:0] UART_INTR_TEST_OFFSET = 6'h08;
	localparam [5:0] UART_CTRL_OFFSET = 6'h0c;
	localparam [5:0] UART_STATUS_OFFSET = 6'h10;
	localparam [5:0] UART_RDATA_OFFSET = 6'h14;
	localparam [5:0] UART_WDATA_OFFSET = 6'h18;
	localparam [5:0] UART_FIFO_CTRL_OFFSET = 6'h1c;
	localparam [5:0] UART_FIFO_STATUS_OFFSET = 6'h20;
	localparam [5:0] UART_OVRD_OFFSET = 6'h24;
	localparam [5:0] UART_VAL_OFFSET = 6'h28;
	localparam [5:0] UART_TIMEOUT_CTRL_OFFSET = 6'h2c;
	localparam signed [31:0] UART_INTR_STATE = 0;
	localparam signed [31:0] UART_INTR_ENABLE = 1;
	localparam signed [31:0] UART_INTR_TEST = 2;
	localparam signed [31:0] UART_CTRL = 3;
	localparam signed [31:0] UART_STATUS = 4;
	localparam signed [31:0] UART_RDATA = 5;
	localparam signed [31:0] UART_WDATA = 6;
	localparam signed [31:0] UART_FIFO_CTRL = 7;
	localparam signed [31:0] UART_FIFO_STATUS = 8;
	localparam signed [31:0] UART_OVRD = 9;
	localparam signed [31:0] UART_VAL = 10;
	localparam signed [31:0] UART_TIMEOUT_CTRL = 11;
	localparam [47:0] UART_PERMIT = {4'b0001, 4'b0001, 4'b0001, 4'b1111, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0111, 4'b0001, 4'b0011, 4'b1111};
	wire [124:0] reg2hw;
	wire [64:0] hw2reg;
	uart_reg_top u_reg(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.devmode_i(1'b1)
	);
	uart_core uart_core(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.rx(cio_rx_i),
		.tx(cio_tx_o),
		.intr_tx_watermark_o(intr_tx_watermark_o),
		.intr_rx_watermark_o(intr_rx_watermark_o),
		.intr_tx_empty_o(intr_tx_empty_o),
		.intr_rx_overflow_o(intr_rx_overflow_o),
		.intr_rx_frame_err_o(intr_rx_frame_err_o),
		.intr_rx_break_err_o(intr_rx_break_err_o),
		.intr_rx_timeout_o(intr_rx_timeout_o),
		.intr_rx_parity_err_o(intr_rx_parity_err_o)
	);
	assign cio_tx_en_o = 1'b1;
endmodule
module uart_core (
	clk_i,
	rst_ni,
	reg2hw,
	hw2reg,
	rx,
	tx,
	intr_tx_watermark_o,
	intr_rx_watermark_o,
	intr_tx_empty_o,
	intr_rx_overflow_o,
	intr_rx_frame_err_o,
	intr_rx_break_err_o,
	intr_rx_timeout_o,
	intr_rx_parity_err_o
);
	input clk_i;
	input rst_ni;
	input wire [124:0] reg2hw;
	output wire [64:0] hw2reg;
	input rx;
	output wire tx;
	output wire intr_tx_watermark_o;
	output wire intr_rx_watermark_o;
	output wire intr_tx_empty_o;
	output wire intr_rx_overflow_o;
	output wire intr_rx_frame_err_o;
	output wire intr_rx_break_err_o;
	output wire intr_rx_timeout_o;
	output wire intr_rx_parity_err_o;
	localparam [5:0] UART_INTR_STATE_OFFSET = 6'h00;
	localparam [5:0] UART_INTR_ENABLE_OFFSET = 6'h04;
	localparam [5:0] UART_INTR_TEST_OFFSET = 6'h08;
	localparam [5:0] UART_CTRL_OFFSET = 6'h0c;
	localparam [5:0] UART_STATUS_OFFSET = 6'h10;
	localparam [5:0] UART_RDATA_OFFSET = 6'h14;
	localparam [5:0] UART_WDATA_OFFSET = 6'h18;
	localparam [5:0] UART_FIFO_CTRL_OFFSET = 6'h1c;
	localparam [5:0] UART_FIFO_STATUS_OFFSET = 6'h20;
	localparam [5:0] UART_OVRD_OFFSET = 6'h24;
	localparam [5:0] UART_VAL_OFFSET = 6'h28;
	localparam [5:0] UART_TIMEOUT_CTRL_OFFSET = 6'h2c;
	localparam signed [31:0] UART_INTR_STATE = 0;
	localparam signed [31:0] UART_INTR_ENABLE = 1;
	localparam signed [31:0] UART_INTR_TEST = 2;
	localparam signed [31:0] UART_CTRL = 3;
	localparam signed [31:0] UART_STATUS = 4;
	localparam signed [31:0] UART_RDATA = 5;
	localparam signed [31:0] UART_WDATA = 6;
	localparam signed [31:0] UART_FIFO_CTRL = 7;
	localparam signed [31:0] UART_FIFO_STATUS = 8;
	localparam signed [31:0] UART_OVRD = 9;
	localparam signed [31:0] UART_VAL = 10;
	localparam signed [31:0] UART_TIMEOUT_CTRL = 11;
	localparam [47:0] UART_PERMIT = {4'b0001, 4'b0001, 4'b0001, 4'b1111, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0111, 4'b0001, 4'b0011, 4'b1111};
	localparam signed [31:0] NcoWidth = 16;
	reg [15:0] rx_val_q;
	wire [7:0] uart_rdata;
	wire tick_baud_x16;
	wire rx_tick_baud;
	wire [5:0] tx_fifo_depth;
	wire [5:0] rx_fifo_depth;
	reg [5:0] rx_fifo_depth_prev_q;
	wire [23:0] rx_timeout_count_d;
	reg [23:0] rx_timeout_count_q;
	wire [23:0] uart_rxto_val;
	wire rx_fifo_depth_changed;
	wire uart_rxto_en;
	wire tx_enable;
	wire rx_enable;
	wire sys_loopback;
	wire line_loopback;
	wire rxnf_enable;
	wire uart_fifo_rxrst;
	wire uart_fifo_txrst;
	wire [2:0] uart_fifo_rxilvl;
	wire [1:0] uart_fifo_txilvl;
	wire ovrd_tx_en;
	wire ovrd_tx_val;
	wire [7:0] tx_fifo_data;
	wire tx_fifo_rready;
	wire tx_fifo_rvalid;
	wire tx_fifo_wready;
	wire tx_uart_idle;
	wire tx_out;
	reg tx_out_q;
	wire [7:0] rx_fifo_data;
	wire rx_valid;
	wire rx_fifo_wvalid;
	wire rx_fifo_rvalid;
	wire rx_fifo_wready;
	wire rx_uart_idle;
	wire rx_sync;
	wire rx_in;
	reg break_err;
	wire [4:0] allzero_cnt_d;
	reg [4:0] allzero_cnt_q;
	wire allzero_err;
	wire not_allzero_char;
	wire event_tx_watermark;
	wire event_rx_watermark;
	wire event_tx_empty;
	wire event_rx_overflow;
	wire event_rx_frame_err;
	wire event_rx_break_err;
	wire event_rx_timeout;
	wire event_rx_parity_err;
	reg tx_watermark_d;
	reg tx_watermark_prev_q;
	reg rx_watermark_d;
	reg rx_watermark_prev_q;
	reg tx_uart_idle_q;
	assign tx_enable = reg2hw[92];
	assign rx_enable = reg2hw[91];
	assign rxnf_enable = reg2hw[90];
	assign sys_loopback = reg2hw[89];
	assign line_loopback = reg2hw[88];
	assign uart_fifo_rxrst = reg2hw[37] & reg2hw[36];
	assign uart_fifo_txrst = reg2hw[35] & reg2hw[34];
	assign uart_fifo_rxilvl = reg2hw[33-:3];
	assign uart_fifo_txilvl = reg2hw[29-:2];
	assign ovrd_tx_en = reg2hw[26];
	assign ovrd_tx_val = reg2hw[25];
	reg break_st_q;
	assign not_allzero_char = rx_valid & (~event_rx_frame_err | (rx_fifo_data != 8'h00));
	assign allzero_err = event_rx_frame_err & (rx_fifo_data == 8'h00);
	localparam [0:0] BRK_WAIT = 1;
	assign allzero_cnt_d = ((break_st_q == BRK_WAIT) || not_allzero_char ? 5'h00 : (allzero_err ? allzero_cnt_q + 5'd1 : allzero_cnt_q));
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			allzero_cnt_q <= {5 {1'sb0}};
		else if (rx_enable)
			allzero_cnt_q <= allzero_cnt_d;
	always @(*)
		case (reg2hw[85-:2])
			2'h0: break_err = allzero_cnt_d >= 5'd2;
			2'h1: break_err = allzero_cnt_d >= 5'd4;
			2'h2: break_err = allzero_cnt_d >= 5'd8;
			default: break_err = allzero_cnt_d >= 5'd16;
		endcase
	localparam [0:0] BRK_CHK = 0;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			break_st_q <= BRK_CHK;
		else
			case (break_st_q)
				BRK_CHK:
					if (event_rx_break_err)
						break_st_q <= BRK_WAIT;
				BRK_WAIT:
					if (rx_in)
						break_st_q <= BRK_CHK;
				default: break_st_q <= BRK_CHK;
			endcase
	assign hw2reg[15-:16] = rx_val_q;
	assign hw2reg[42-:8] = uart_rdata;
	assign hw2reg[43] = ~rx_fifo_rvalid;
	assign hw2reg[44] = rx_uart_idle;
	assign hw2reg[45] = tx_uart_idle & ~tx_fifo_rvalid;
	assign hw2reg[46] = ~tx_fifo_rvalid;
	assign hw2reg[47] = ~rx_fifo_wready;
	assign hw2reg[48] = ~tx_fifo_wready;
	assign hw2reg[27-:6] = tx_fifo_depth;
	assign hw2reg[21-:6] = rx_fifo_depth;
	assign hw2reg[31] = 1'b0;
	assign hw2reg[34-:3] = 3'h0;
	assign hw2reg[28] = 1'b0;
	assign hw2reg[30-:2] = 2'h0;
	reg [NcoWidth:0] nco_sum_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			nco_sum_q <= 17'h00000;
		else if (tx_enable || rx_enable)
			nco_sum_q <= {1'b0, nco_sum_q[NcoWidth - 1:0]} + {1'b0, reg2hw[NcoWidth + 67:68]};
	assign tick_baud_x16 = nco_sum_q[16];
	assign tx_fifo_rready = (tx_uart_idle & tx_fifo_rvalid) & tx_enable;
	prim_fifo_sync #(
		.Width(8),
		.Pass(1'b0),
		.Depth(32)
	) u_uart_txfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(uart_fifo_txrst),
		.wvalid_i(reg2hw[38]),
		.wready_o(tx_fifo_wready),
		.wdata_i(reg2hw[46-:8]),
		.depth_o(tx_fifo_depth),
		.rvalid_o(tx_fifo_rvalid),
		.rready_i(tx_fifo_rready),
		.rdata_o(tx_fifo_data)
	);
	uart_tx uart_tx(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tx_enable(tx_enable),
		.tick_baud_x16(tick_baud_x16),
		.parity_enable(reg2hw[87]),
		.wr(tx_fifo_rready),
		.wr_parity(^tx_fifo_data ^ reg2hw[86]),
		.wr_data(tx_fifo_data),
		.idle(tx_uart_idle),
		.tx(tx_out)
	);
	assign tx = (line_loopback ? rx : tx_out_q);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			tx_out_q <= 1'b1;
		else if (ovrd_tx_en)
			tx_out_q <= ovrd_tx_val;
		else if (sys_loopback)
			tx_out_q <= 1'b1;
		else
			tx_out_q <= tx_out;
	prim_generic_flop_2sync #(
		.Width(1),
		.ResetValue(1'b1)
	) sync_rx(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i(rx),
		.q_o(rx_sync)
	);
	reg rx_sync_q1;
	reg rx_sync_q2;
	wire rx_in_mx;
	wire rx_in_maj;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rx_sync_q1 <= 1'b1;
			rx_sync_q2 <= 1'b1;
		end
		else begin
			rx_sync_q1 <= rx_sync;
			rx_sync_q2 <= rx_sync_q1;
		end
	assign rx_in_maj = ((rx_sync & rx_sync_q1) | (rx_sync & rx_sync_q2)) | (rx_sync_q1 & rx_sync_q2);
	assign rx_in_mx = (rxnf_enable ? rx_in_maj : rx_sync);
	assign rx_in = (sys_loopback ? tx_out : (line_loopback ? 1'b1 : rx_in_mx));
	uart_rx uart_rx(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.rx_enable(rx_enable),
		.tick_baud_x16(tick_baud_x16),
		.parity_enable(reg2hw[87]),
		.parity_odd(reg2hw[86]),
		.tick_baud(rx_tick_baud),
		.rx_valid(rx_valid),
		.rx_data(rx_fifo_data),
		.idle(rx_uart_idle),
		.frame_err(event_rx_frame_err),
		.rx(rx_in),
		.rx_parity_err(event_rx_parity_err)
	);
	assign rx_fifo_wvalid = (rx_valid & ~event_rx_frame_err) & ~event_rx_parity_err;
	prim_fifo_sync #(
		.Width(8),
		.Pass(1'b0),
		.Depth(32)
	) u_uart_rxfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(uart_fifo_rxrst),
		.wvalid_i(rx_fifo_wvalid),
		.wready_o(rx_fifo_wready),
		.wdata_i(rx_fifo_data),
		.depth_o(rx_fifo_depth),
		.rvalid_o(rx_fifo_rvalid),
		.rready_i(reg2hw[47]),
		.rdata_o(uart_rdata)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			rx_val_q <= 16'h0000;
		else if (tick_baud_x16)
			rx_val_q <= {rx_val_q[14:0], rx_in};
	always @(*)
		case (uart_fifo_txilvl)
			2'h0: tx_watermark_d = tx_fifo_depth < 6'd2;
			2'h1: tx_watermark_d = tx_fifo_depth < 6'd4;
			2'h2: tx_watermark_d = tx_fifo_depth < 6'd8;
			default: tx_watermark_d = tx_fifo_depth < 6'd16;
		endcase
	assign event_tx_watermark = tx_watermark_d & ~tx_watermark_prev_q;
	assign event_tx_empty = (~tx_fifo_rvalid & ~tx_uart_idle_q) & tx_uart_idle;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			tx_watermark_prev_q <= 1'b1;
			rx_watermark_prev_q <= 1'b0;
			tx_uart_idle_q <= 1'b1;
		end
		else begin
			tx_watermark_prev_q <= tx_watermark_d;
			rx_watermark_prev_q <= rx_watermark_d;
			tx_uart_idle_q <= tx_uart_idle;
		end
	always @(*)
		case (uart_fifo_rxilvl)
			3'h0: rx_watermark_d = rx_fifo_depth >= 6'd1;
			3'h1: rx_watermark_d = rx_fifo_depth >= 6'd4;
			3'h2: rx_watermark_d = rx_fifo_depth >= 6'd8;
			3'h3: rx_watermark_d = rx_fifo_depth >= 6'd16;
			3'h4: rx_watermark_d = rx_fifo_depth >= 6'd30;
			default: rx_watermark_d = 1'b0;
		endcase
	assign event_rx_watermark = rx_watermark_d & ~rx_watermark_prev_q;
	assign uart_rxto_en = reg2hw[-0];
	assign uart_rxto_val = reg2hw[24-:24];
	assign rx_fifo_depth_changed = rx_fifo_depth != rx_fifo_depth_prev_q;
	assign rx_timeout_count_d = (uart_rxto_en == 1'b0 ? 24'd0 : (event_rx_timeout ? 24'd0 : (rx_fifo_depth_changed ? 24'd0 : (rx_fifo_depth == 5'd0 ? 24'd0 : (rx_tick_baud ? rx_timeout_count_q + 24'd1 : rx_timeout_count_q)))));
	assign event_rx_timeout = (rx_timeout_count_q == uart_rxto_val) & uart_rxto_en;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rx_timeout_count_q <= 24'd0;
			rx_fifo_depth_prev_q <= 6'd0;
		end
		else begin
			rx_timeout_count_q <= rx_timeout_count_d;
			rx_fifo_depth_prev_q <= rx_fifo_depth;
		end
	assign event_rx_overflow = rx_fifo_wvalid & ~rx_fifo_wready;
	assign event_rx_break_err = break_err & (break_st_q == BRK_CHK);
	prim_intr_hw #(.Width(1)) intr_hw_tx_watermark(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.event_intr_i(event_tx_watermark),
		.reg2hw_intr_enable_q_i(reg2hw[116]),
		.reg2hw_intr_test_q_i(reg2hw[108]),
		.reg2hw_intr_test_qe_i(reg2hw[107]),
		.reg2hw_intr_state_q_i(reg2hw[124]),
		.hw2reg_intr_state_de_o(hw2reg[63]),
		.hw2reg_intr_state_d_o(hw2reg[64]),
		.intr_o(intr_tx_watermark_o)
	);
	prim_intr_hw #(.Width(1)) intr_hw_rx_watermark(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.event_intr_i(event_rx_watermark),
		.reg2hw_intr_enable_q_i(reg2hw[115]),
		.reg2hw_intr_test_q_i(reg2hw[106]),
		.reg2hw_intr_test_qe_i(reg2hw[105]),
		.reg2hw_intr_state_q_i(reg2hw[123]),
		.hw2reg_intr_state_de_o(hw2reg[61]),
		.hw2reg_intr_state_d_o(hw2reg[62]),
		.intr_o(intr_rx_watermark_o)
	);
	prim_intr_hw #(.Width(1)) intr_hw_tx_empty(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.event_intr_i(event_tx_empty),
		.reg2hw_intr_enable_q_i(reg2hw[114]),
		.reg2hw_intr_test_q_i(reg2hw[104]),
		.reg2hw_intr_test_qe_i(reg2hw[103]),
		.reg2hw_intr_state_q_i(reg2hw[122]),
		.hw2reg_intr_state_de_o(hw2reg[59]),
		.hw2reg_intr_state_d_o(hw2reg[60]),
		.intr_o(intr_tx_empty_o)
	);
	prim_intr_hw #(.Width(1)) intr_hw_rx_overflow(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.event_intr_i(event_rx_overflow),
		.reg2hw_intr_enable_q_i(reg2hw[113]),
		.reg2hw_intr_test_q_i(reg2hw[102]),
		.reg2hw_intr_test_qe_i(reg2hw[101]),
		.reg2hw_intr_state_q_i(reg2hw[121]),
		.hw2reg_intr_state_de_o(hw2reg[57]),
		.hw2reg_intr_state_d_o(hw2reg[58]),
		.intr_o(intr_rx_overflow_o)
	);
	prim_intr_hw #(.Width(1)) intr_hw_rx_frame_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.event_intr_i(event_rx_frame_err),
		.reg2hw_intr_enable_q_i(reg2hw[112]),
		.reg2hw_intr_test_q_i(reg2hw[100]),
		.reg2hw_intr_test_qe_i(reg2hw[99]),
		.reg2hw_intr_state_q_i(reg2hw[120]),
		.hw2reg_intr_state_de_o(hw2reg[55]),
		.hw2reg_intr_state_d_o(hw2reg[56]),
		.intr_o(intr_rx_frame_err_o)
	);
	prim_intr_hw #(.Width(1)) intr_hw_rx_break_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.event_intr_i(event_rx_break_err),
		.reg2hw_intr_enable_q_i(reg2hw[111]),
		.reg2hw_intr_test_q_i(reg2hw[98]),
		.reg2hw_intr_test_qe_i(reg2hw[97]),
		.reg2hw_intr_state_q_i(reg2hw[119]),
		.hw2reg_intr_state_de_o(hw2reg[53]),
		.hw2reg_intr_state_d_o(hw2reg[54]),
		.intr_o(intr_rx_break_err_o)
	);
	prim_intr_hw #(.Width(1)) intr_hw_rx_timeout(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.event_intr_i(event_rx_timeout),
		.reg2hw_intr_enable_q_i(reg2hw[110]),
		.reg2hw_intr_test_q_i(reg2hw[96]),
		.reg2hw_intr_test_qe_i(reg2hw[95]),
		.reg2hw_intr_state_q_i(reg2hw[118]),
		.hw2reg_intr_state_de_o(hw2reg[51]),
		.hw2reg_intr_state_d_o(hw2reg[52]),
		.intr_o(intr_rx_timeout_o)
	);
	prim_intr_hw #(.Width(1)) intr_hw_rx_parity_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.event_intr_i(event_rx_parity_err),
		.reg2hw_intr_enable_q_i(reg2hw[109]),
		.reg2hw_intr_test_q_i(reg2hw[94]),
		.reg2hw_intr_test_qe_i(reg2hw[93]),
		.reg2hw_intr_state_q_i(reg2hw[117]),
		.hw2reg_intr_state_de_o(hw2reg[49]),
		.hw2reg_intr_state_d_o(hw2reg[50]),
		.intr_o(intr_rx_parity_err_o)
	);
endmodule
module uart_reg_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	reg2hw,
	hw2reg,
	devmode_i
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] top_pkg_TL_AIW = 8;
	localparam signed [31:0] top_pkg_TL_AW = 32;
	localparam signed [31:0] top_pkg_TL_DW = 32;
	localparam signed [31:0] top_pkg_TL_DBW = top_pkg_TL_DW >> 3;
	localparam signed [31:0] top_pkg_TL_SZW = $clog2($clog2(top_pkg_TL_DBW) + 1);
	input wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_i;
	localparam signed [31:0] top_pkg_TL_DIW = 1;
	localparam signed [31:0] top_pkg_TL_DUW = 16;
	output wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_o;
	output wire [124:0] reg2hw;
	input wire [64:0] hw2reg;
	input devmode_i;
	localparam [5:0] UART_INTR_STATE_OFFSET = 6'h00;
	localparam [5:0] UART_INTR_ENABLE_OFFSET = 6'h04;
	localparam [5:0] UART_INTR_TEST_OFFSET = 6'h08;
	localparam [5:0] UART_CTRL_OFFSET = 6'h0c;
	localparam [5:0] UART_STATUS_OFFSET = 6'h10;
	localparam [5:0] UART_RDATA_OFFSET = 6'h14;
	localparam [5:0] UART_WDATA_OFFSET = 6'h18;
	localparam [5:0] UART_FIFO_CTRL_OFFSET = 6'h1c;
	localparam [5:0] UART_FIFO_STATUS_OFFSET = 6'h20;
	localparam [5:0] UART_OVRD_OFFSET = 6'h24;
	localparam [5:0] UART_VAL_OFFSET = 6'h28;
	localparam [5:0] UART_TIMEOUT_CTRL_OFFSET = 6'h2c;
	localparam signed [31:0] UART_INTR_STATE = 0;
	localparam signed [31:0] UART_INTR_ENABLE = 1;
	localparam signed [31:0] UART_INTR_TEST = 2;
	localparam signed [31:0] UART_CTRL = 3;
	localparam signed [31:0] UART_STATUS = 4;
	localparam signed [31:0] UART_RDATA = 5;
	localparam signed [31:0] UART_WDATA = 6;
	localparam signed [31:0] UART_FIFO_CTRL = 7;
	localparam signed [31:0] UART_FIFO_STATUS = 8;
	localparam signed [31:0] UART_OVRD = 9;
	localparam signed [31:0] UART_VAL = 10;
	localparam signed [31:0] UART_TIMEOUT_CTRL = 11;
	localparam [47:0] UART_PERMIT = {4'b0001, 4'b0001, 4'b0001, 4'b1111, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0111, 4'b0001, 4'b0011, 4'b1111};
	localparam signed [31:0] AW = 6;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] DBW = DW / 8;
	wire reg_we;
	wire reg_re;
	wire [AW - 1:0] reg_addr;
	wire [DW - 1:0] reg_wdata;
	wire [DBW - 1:0] reg_be;
	wire [DW - 1:0] reg_rdata;
	wire reg_error;
	wire addrmiss;
	reg wr_err;
	reg [DW - 1:0] reg_rdata_next;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_AW) + top_pkg_TL_DBW) + top_pkg_TL_DW) + 16:0] tl_reg_h2d;
	wire [(((((7 + top_pkg_TL_SZW) + top_pkg_TL_AIW) + top_pkg_TL_DIW) + top_pkg_TL_DW) + top_pkg_TL_DUW) + 1:0] tl_reg_d2h;
	assign tl_reg_h2d = tl_i;
	assign tl_o = tl_reg_d2h;
	tlul_adapter_reg #(
		.RegAw(AW),
		.RegDw(DW)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_reg_h2d),
		.tl_o(tl_reg_d2h),
		.we_o(reg_we),
		.re_o(reg_re),
		.addr_o(reg_addr),
		.wdata_o(reg_wdata),
		.be_o(reg_be),
		.rdata_i(reg_rdata),
		.error_i(reg_error)
	);
	assign reg_rdata = reg_rdata_next;
	assign reg_error = (devmode_i & addrmiss) | wr_err;
	wire intr_state_tx_watermark_qs;
	wire intr_state_tx_watermark_wd;
	wire intr_state_tx_watermark_we;
	wire intr_state_rx_watermark_qs;
	wire intr_state_rx_watermark_wd;
	wire intr_state_rx_watermark_we;
	wire intr_state_tx_empty_qs;
	wire intr_state_tx_empty_wd;
	wire intr_state_tx_empty_we;
	wire intr_state_rx_overflow_qs;
	wire intr_state_rx_overflow_wd;
	wire intr_state_rx_overflow_we;
	wire intr_state_rx_frame_err_qs;
	wire intr_state_rx_frame_err_wd;
	wire intr_state_rx_frame_err_we;
	wire intr_state_rx_break_err_qs;
	wire intr_state_rx_break_err_wd;
	wire intr_state_rx_break_err_we;
	wire intr_state_rx_timeout_qs;
	wire intr_state_rx_timeout_wd;
	wire intr_state_rx_timeout_we;
	wire intr_state_rx_parity_err_qs;
	wire intr_state_rx_parity_err_wd;
	wire intr_state_rx_parity_err_we;
	wire intr_enable_tx_watermark_qs;
	wire intr_enable_tx_watermark_wd;
	wire intr_enable_tx_watermark_we;
	wire intr_enable_rx_watermark_qs;
	wire intr_enable_rx_watermark_wd;
	wire intr_enable_rx_watermark_we;
	wire intr_enable_tx_empty_qs;
	wire intr_enable_tx_empty_wd;
	wire intr_enable_tx_empty_we;
	wire intr_enable_rx_overflow_qs;
	wire intr_enable_rx_overflow_wd;
	wire intr_enable_rx_overflow_we;
	wire intr_enable_rx_frame_err_qs;
	wire intr_enable_rx_frame_err_wd;
	wire intr_enable_rx_frame_err_we;
	wire intr_enable_rx_break_err_qs;
	wire intr_enable_rx_break_err_wd;
	wire intr_enable_rx_break_err_we;
	wire intr_enable_rx_timeout_qs;
	wire intr_enable_rx_timeout_wd;
	wire intr_enable_rx_timeout_we;
	wire intr_enable_rx_parity_err_qs;
	wire intr_enable_rx_parity_err_wd;
	wire intr_enable_rx_parity_err_we;
	wire intr_test_tx_watermark_wd;
	wire intr_test_tx_watermark_we;
	wire intr_test_rx_watermark_wd;
	wire intr_test_rx_watermark_we;
	wire intr_test_tx_empty_wd;
	wire intr_test_tx_empty_we;
	wire intr_test_rx_overflow_wd;
	wire intr_test_rx_overflow_we;
	wire intr_test_rx_frame_err_wd;
	wire intr_test_rx_frame_err_we;
	wire intr_test_rx_break_err_wd;
	wire intr_test_rx_break_err_we;
	wire intr_test_rx_timeout_wd;
	wire intr_test_rx_timeout_we;
	wire intr_test_rx_parity_err_wd;
	wire intr_test_rx_parity_err_we;
	wire ctrl_tx_qs;
	wire ctrl_tx_wd;
	wire ctrl_tx_we;
	wire ctrl_rx_qs;
	wire ctrl_rx_wd;
	wire ctrl_rx_we;
	wire ctrl_nf_qs;
	wire ctrl_nf_wd;
	wire ctrl_nf_we;
	wire ctrl_slpbk_qs;
	wire ctrl_slpbk_wd;
	wire ctrl_slpbk_we;
	wire ctrl_llpbk_qs;
	wire ctrl_llpbk_wd;
	wire ctrl_llpbk_we;
	wire ctrl_parity_en_qs;
	wire ctrl_parity_en_wd;
	wire ctrl_parity_en_we;
	wire ctrl_parity_odd_qs;
	wire ctrl_parity_odd_wd;
	wire ctrl_parity_odd_we;
	wire [1:0] ctrl_rxblvl_qs;
	wire [1:0] ctrl_rxblvl_wd;
	wire ctrl_rxblvl_we;
	wire [15:0] ctrl_nco_qs;
	wire [15:0] ctrl_nco_wd;
	wire ctrl_nco_we;
	wire status_txfull_qs;
	wire status_txfull_re;
	wire status_rxfull_qs;
	wire status_rxfull_re;
	wire status_txempty_qs;
	wire status_txempty_re;
	wire status_txidle_qs;
	wire status_txidle_re;
	wire status_rxidle_qs;
	wire status_rxidle_re;
	wire status_rxempty_qs;
	wire status_rxempty_re;
	wire [7:0] rdata_qs;
	wire rdata_re;
	wire [7:0] wdata_wd;
	wire wdata_we;
	wire fifo_ctrl_rxrst_wd;
	wire fifo_ctrl_rxrst_we;
	wire fifo_ctrl_txrst_wd;
	wire fifo_ctrl_txrst_we;
	wire [2:0] fifo_ctrl_rxilvl_qs;
	wire [2:0] fifo_ctrl_rxilvl_wd;
	wire fifo_ctrl_rxilvl_we;
	wire [1:0] fifo_ctrl_txilvl_qs;
	wire [1:0] fifo_ctrl_txilvl_wd;
	wire fifo_ctrl_txilvl_we;
	wire [5:0] fifo_status_txlvl_qs;
	wire fifo_status_txlvl_re;
	wire [5:0] fifo_status_rxlvl_qs;
	wire fifo_status_rxlvl_re;
	wire ovrd_txen_qs;
	wire ovrd_txen_wd;
	wire ovrd_txen_we;
	wire ovrd_txval_qs;
	wire ovrd_txval_wd;
	wire ovrd_txval_we;
	wire [15:0] val_qs;
	wire val_re;
	wire [23:0] timeout_ctrl_val_qs;
	wire [23:0] timeout_ctrl_val_wd;
	wire timeout_ctrl_val_we;
	wire timeout_ctrl_en_qs;
	wire timeout_ctrl_en_wd;
	wire timeout_ctrl_en_we;
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(24),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_tx_watermark(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_tx_watermark_we),
		.wd(intr_state_tx_watermark_wd),
		.de(hw2reg[63]),
		.d(hw2reg[64]),
		.qe(),
		.q(reg2hw[124]),
		.qs(intr_state_tx_watermark_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(24),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_watermark(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_watermark_we),
		.wd(intr_state_rx_watermark_wd),
		.de(hw2reg[61]),
		.d(hw2reg[62]),
		.qe(),
		.q(reg2hw[123]),
		.qs(intr_state_rx_watermark_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(24),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_tx_empty(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_tx_empty_we),
		.wd(intr_state_tx_empty_wd),
		.de(hw2reg[59]),
		.d(hw2reg[60]),
		.qe(),
		.q(reg2hw[122]),
		.qs(intr_state_tx_empty_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(24),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_overflow(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_overflow_we),
		.wd(intr_state_rx_overflow_wd),
		.de(hw2reg[57]),
		.d(hw2reg[58]),
		.qe(),
		.q(reg2hw[121]),
		.qs(intr_state_rx_overflow_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(24),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_frame_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_frame_err_we),
		.wd(intr_state_rx_frame_err_wd),
		.de(hw2reg[55]),
		.d(hw2reg[56]),
		.qe(),
		.q(reg2hw[120]),
		.qs(intr_state_rx_frame_err_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(24),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_break_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_break_err_we),
		.wd(intr_state_rx_break_err_wd),
		.de(hw2reg[53]),
		.d(hw2reg[54]),
		.qe(),
		.q(reg2hw[119]),
		.qs(intr_state_rx_break_err_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(24),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_timeout(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_timeout_we),
		.wd(intr_state_rx_timeout_wd),
		.de(hw2reg[51]),
		.d(hw2reg[52]),
		.qe(),
		.q(reg2hw[118]),
		.qs(intr_state_rx_timeout_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(24),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_parity_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_parity_err_we),
		.wd(intr_state_rx_parity_err_wd),
		.de(hw2reg[49]),
		.d(hw2reg[50]),
		.qe(),
		.q(reg2hw[117]),
		.qs(intr_state_rx_parity_err_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_tx_watermark(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_tx_watermark_we),
		.wd(intr_enable_tx_watermark_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[116]),
		.qs(intr_enable_tx_watermark_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_watermark(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_watermark_we),
		.wd(intr_enable_rx_watermark_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[115]),
		.qs(intr_enable_rx_watermark_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_tx_empty(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_tx_empty_we),
		.wd(intr_enable_tx_empty_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[114]),
		.qs(intr_enable_tx_empty_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_overflow(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_overflow_we),
		.wd(intr_enable_rx_overflow_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[113]),
		.qs(intr_enable_rx_overflow_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_frame_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_frame_err_we),
		.wd(intr_enable_rx_frame_err_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[112]),
		.qs(intr_enable_rx_frame_err_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_break_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_break_err_we),
		.wd(intr_enable_rx_break_err_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[111]),
		.qs(intr_enable_rx_break_err_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_timeout(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_timeout_we),
		.wd(intr_enable_rx_timeout_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[110]),
		.qs(intr_enable_rx_timeout_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_parity_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_parity_err_we),
		.wd(intr_enable_rx_parity_err_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[109]),
		.qs(intr_enable_rx_parity_err_qs)
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_tx_watermark(
		.re(1'b0),
		.we(intr_test_tx_watermark_we),
		.wd(intr_test_tx_watermark_wd),
		.d(1'sb0),
		.qre(),
		.qe(reg2hw[107]),
		.q(reg2hw[108]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_watermark(
		.re(1'b0),
		.we(intr_test_rx_watermark_we),
		.wd(intr_test_rx_watermark_wd),
		.d(1'sb0),
		.qre(),
		.qe(reg2hw[105]),
		.q(reg2hw[106]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_tx_empty(
		.re(1'b0),
		.we(intr_test_tx_empty_we),
		.wd(intr_test_tx_empty_wd),
		.d(1'sb0),
		.qre(),
		.qe(reg2hw[103]),
		.q(reg2hw[104]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_overflow(
		.re(1'b0),
		.we(intr_test_rx_overflow_we),
		.wd(intr_test_rx_overflow_wd),
		.d(1'sb0),
		.qre(),
		.qe(reg2hw[101]),
		.q(reg2hw[102]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_frame_err(
		.re(1'b0),
		.we(intr_test_rx_frame_err_we),
		.wd(intr_test_rx_frame_err_wd),
		.d(1'sb0),
		.qre(),
		.qe(reg2hw[99]),
		.q(reg2hw[100]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_break_err(
		.re(1'b0),
		.we(intr_test_rx_break_err_we),
		.wd(intr_test_rx_break_err_wd),
		.d(1'sb0),
		.qre(),
		.qe(reg2hw[97]),
		.q(reg2hw[98]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_timeout(
		.re(1'b0),
		.we(intr_test_rx_timeout_we),
		.wd(intr_test_rx_timeout_wd),
		.d(1'sb0),
		.qre(),
		.qe(reg2hw[95]),
		.q(reg2hw[96]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_parity_err(
		.re(1'b0),
		.we(intr_test_rx_parity_err_we),
		.wd(intr_test_rx_parity_err_wd),
		.d(1'sb0),
		.qre(),
		.qe(reg2hw[93]),
		.q(reg2hw[94]),
		.qs()
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_tx(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_tx_we),
		.wd(ctrl_tx_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[92]),
		.qs(ctrl_tx_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_rx(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_rx_we),
		.wd(ctrl_rx_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[91]),
		.qs(ctrl_rx_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_nf(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_nf_we),
		.wd(ctrl_nf_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[90]),
		.qs(ctrl_nf_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_slpbk(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_slpbk_we),
		.wd(ctrl_slpbk_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[89]),
		.qs(ctrl_slpbk_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_llpbk(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_llpbk_we),
		.wd(ctrl_llpbk_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[88]),
		.qs(ctrl_llpbk_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_parity_en(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_parity_en_we),
		.wd(ctrl_parity_en_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[87]),
		.qs(ctrl_parity_en_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_parity_odd(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_parity_odd_we),
		.wd(ctrl_parity_odd_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[86]),
		.qs(ctrl_parity_odd_qs)
	);
	prim_subreg #(
		.DW(2),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_ctrl_rxblvl(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_rxblvl_we),
		.wd(ctrl_rxblvl_wd),
		.de(1'b0),
		.d({2 {1'sb0}}),
		.qe(),
		.q(reg2hw[85-:2]),
		.qs(ctrl_rxblvl_qs)
	);
	prim_subreg #(
		.DW(16),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(16'h0000)
	) u_ctrl_nco(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_nco_we),
		.wd(ctrl_nco_wd),
		.de(1'b0),
		.d({16 {1'sb0}}),
		.qe(),
		.q(reg2hw[83-:16]),
		.qs(ctrl_nco_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_txfull(
		.re(status_txfull_re),
		.we(1'b0),
		.wd(1'sb0),
		.d(hw2reg[48]),
		.qre(reg2hw[66]),
		.qe(),
		.q(reg2hw[67]),
		.qs(status_txfull_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_rxfull(
		.re(status_rxfull_re),
		.we(1'b0),
		.wd(1'sb0),
		.d(hw2reg[47]),
		.qre(reg2hw[64]),
		.qe(),
		.q(reg2hw[65]),
		.qs(status_rxfull_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_txempty(
		.re(status_txempty_re),
		.we(1'b0),
		.wd(1'sb0),
		.d(hw2reg[46]),
		.qre(reg2hw[62]),
		.qe(),
		.q(reg2hw[63]),
		.qs(status_txempty_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_txidle(
		.re(status_txidle_re),
		.we(1'b0),
		.wd(1'sb0),
		.d(hw2reg[45]),
		.qre(reg2hw[60]),
		.qe(),
		.q(reg2hw[61]),
		.qs(status_txidle_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_rxidle(
		.re(status_rxidle_re),
		.we(1'b0),
		.wd(1'sb0),
		.d(hw2reg[44]),
		.qre(reg2hw[58]),
		.qe(),
		.q(reg2hw[59]),
		.qs(status_rxidle_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_rxempty(
		.re(status_rxempty_re),
		.we(1'b0),
		.wd(1'sb0),
		.d(hw2reg[43]),
		.qre(reg2hw[56]),
		.qe(),
		.q(reg2hw[57]),
		.qs(status_rxempty_qs)
	);
	prim_subreg_ext #(.DW(8)) u_rdata(
		.re(rdata_re),
		.we(1'b0),
		.wd({8 {1'sb0}}),
		.d(hw2reg[42-:8]),
		.qre(reg2hw[47]),
		.qe(),
		.q(reg2hw[55-:8]),
		.qs(rdata_qs)
	);
	prim_subreg #(
		.DW(8),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("WO"),
		.RESVAL(8'h00)
	) u_wdata(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(wdata_we),
		.wd(wdata_wd),
		.de(1'b0),
		.d({8 {1'sb0}}),
		.qe(reg2hw[38]),
		.q(reg2hw[46-:8]),
		.qs()
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("WO"),
		.RESVAL(1'h0)
	) u_fifo_ctrl_rxrst(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(fifo_ctrl_rxrst_we),
		.wd(fifo_ctrl_rxrst_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(reg2hw[36]),
		.q(reg2hw[37]),
		.qs()
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("WO"),
		.RESVAL(1'h0)
	) u_fifo_ctrl_txrst(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(fifo_ctrl_txrst_we),
		.wd(fifo_ctrl_txrst_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(reg2hw[34]),
		.q(reg2hw[35]),
		.qs()
	);
	prim_subreg #(
		.DW(3),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_fifo_ctrl_rxilvl(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(fifo_ctrl_rxilvl_we),
		.wd(fifo_ctrl_rxilvl_wd),
		.de(hw2reg[31]),
		.d(hw2reg[34-:3]),
		.qe(reg2hw[30]),
		.q(reg2hw[33-:3]),
		.qs(fifo_ctrl_rxilvl_qs)
	);
	prim_subreg #(
		.DW(2),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_fifo_ctrl_txilvl(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(fifo_ctrl_txilvl_we),
		.wd(fifo_ctrl_txilvl_wd),
		.de(hw2reg[28]),
		.d(hw2reg[30-:2]),
		.qe(reg2hw[27]),
		.q(reg2hw[29-:2]),
		.qs(fifo_ctrl_txilvl_qs)
	);
	prim_subreg_ext #(.DW(6)) u_fifo_status_txlvl(
		.re(fifo_status_txlvl_re),
		.we(1'b0),
		.wd({6 {1'sb0}}),
		.d(hw2reg[27-:6]),
		.qre(),
		.qe(),
		.q(),
		.qs(fifo_status_txlvl_qs)
	);
	prim_subreg_ext #(.DW(6)) u_fifo_status_rxlvl(
		.re(fifo_status_rxlvl_re),
		.we(1'b0),
		.wd({6 {1'sb0}}),
		.d(hw2reg[21-:6]),
		.qre(),
		.qe(),
		.q(),
		.qs(fifo_status_rxlvl_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ovrd_txen(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ovrd_txen_we),
		.wd(ovrd_txen_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[26]),
		.qs(ovrd_txen_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ovrd_txval(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ovrd_txval_we),
		.wd(ovrd_txval_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[25]),
		.qs(ovrd_txval_qs)
	);
	prim_subreg_ext #(.DW(16)) u_val(
		.re(val_re),
		.we(1'b0),
		.wd({16 {1'sb0}}),
		.d(hw2reg[15-:16]),
		.qre(),
		.qe(),
		.q(),
		.qs(val_qs)
	);
	prim_subreg #(
		.DW(24),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(24'h000000)
	) u_timeout_ctrl_val(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(timeout_ctrl_val_we),
		.wd(timeout_ctrl_val_wd),
		.de(1'b0),
		.d({24 {1'sb0}}),
		.qe(),
		.q(reg2hw[24-:24]),
		.qs(timeout_ctrl_val_qs)
	);
	prim_subreg #(
		.DW(1),
		._sv2v_width_SWACCESS(16),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_timeout_ctrl_en(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(timeout_ctrl_en_we),
		.wd(timeout_ctrl_en_wd),
		.de(1'b0),
		.d(1'sb0),
		.qe(),
		.q(reg2hw[-0]),
		.qs(timeout_ctrl_en_qs)
	);
	reg [11:0] addr_hit;
	always @(*) begin
		addr_hit = {12 {1'sb0}};
		addr_hit[0] = reg_addr == UART_INTR_STATE_OFFSET;
		addr_hit[1] = reg_addr == UART_INTR_ENABLE_OFFSET;
		addr_hit[2] = reg_addr == UART_INTR_TEST_OFFSET;
		addr_hit[3] = reg_addr == UART_CTRL_OFFSET;
		addr_hit[4] = reg_addr == UART_STATUS_OFFSET;
		addr_hit[5] = reg_addr == UART_RDATA_OFFSET;
		addr_hit[6] = reg_addr == UART_WDATA_OFFSET;
		addr_hit[7] = reg_addr == UART_FIFO_CTRL_OFFSET;
		addr_hit[8] = reg_addr == UART_FIFO_STATUS_OFFSET;
		addr_hit[9] = reg_addr == UART_OVRD_OFFSET;
		addr_hit[10] = reg_addr == UART_VAL_OFFSET;
		addr_hit[11] = reg_addr == UART_TIMEOUT_CTRL_OFFSET;
	end
	assign addrmiss = (reg_re || reg_we ? ~|addr_hit : 1'b0);
	always @(*) begin
		wr_err = 1'b0;
		if ((addr_hit[0] && reg_we) && (UART_PERMIT[44+:4] != (UART_PERMIT[44+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[1] && reg_we) && (UART_PERMIT[40+:4] != (UART_PERMIT[40+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[2] && reg_we) && (UART_PERMIT[36+:4] != (UART_PERMIT[36+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[3] && reg_we) && (UART_PERMIT[32+:4] != (UART_PERMIT[32+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[4] && reg_we) && (UART_PERMIT[28+:4] != (UART_PERMIT[28+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[5] && reg_we) && (UART_PERMIT[24+:4] != (UART_PERMIT[24+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[6] && reg_we) && (UART_PERMIT[20+:4] != (UART_PERMIT[20+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[7] && reg_we) && (UART_PERMIT[16+:4] != (UART_PERMIT[16+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[8] && reg_we) && (UART_PERMIT[12+:4] != (UART_PERMIT[12+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[9] && reg_we) && (UART_PERMIT[8+:4] != (UART_PERMIT[8+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[10] && reg_we) && (UART_PERMIT[4+:4] != (UART_PERMIT[4+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[11] && reg_we) && (UART_PERMIT[0+:4] != (UART_PERMIT[0+:4] & reg_be)))
			wr_err = 1'b1;
	end
	assign intr_state_tx_watermark_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_tx_watermark_wd = reg_wdata[0];
	assign intr_state_rx_watermark_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_watermark_wd = reg_wdata[1];
	assign intr_state_tx_empty_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_tx_empty_wd = reg_wdata[2];
	assign intr_state_rx_overflow_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_overflow_wd = reg_wdata[3];
	assign intr_state_rx_frame_err_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_frame_err_wd = reg_wdata[4];
	assign intr_state_rx_break_err_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_break_err_wd = reg_wdata[5];
	assign intr_state_rx_timeout_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_timeout_wd = reg_wdata[6];
	assign intr_state_rx_parity_err_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_parity_err_wd = reg_wdata[7];
	assign intr_enable_tx_watermark_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_tx_watermark_wd = reg_wdata[0];
	assign intr_enable_rx_watermark_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_watermark_wd = reg_wdata[1];
	assign intr_enable_tx_empty_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_tx_empty_wd = reg_wdata[2];
	assign intr_enable_rx_overflow_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_overflow_wd = reg_wdata[3];
	assign intr_enable_rx_frame_err_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_frame_err_wd = reg_wdata[4];
	assign intr_enable_rx_break_err_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_break_err_wd = reg_wdata[5];
	assign intr_enable_rx_timeout_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_timeout_wd = reg_wdata[6];
	assign intr_enable_rx_parity_err_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_parity_err_wd = reg_wdata[7];
	assign intr_test_tx_watermark_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_tx_watermark_wd = reg_wdata[0];
	assign intr_test_rx_watermark_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_watermark_wd = reg_wdata[1];
	assign intr_test_tx_empty_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_tx_empty_wd = reg_wdata[2];
	assign intr_test_rx_overflow_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_overflow_wd = reg_wdata[3];
	assign intr_test_rx_frame_err_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_frame_err_wd = reg_wdata[4];
	assign intr_test_rx_break_err_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_break_err_wd = reg_wdata[5];
	assign intr_test_rx_timeout_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_timeout_wd = reg_wdata[6];
	assign intr_test_rx_parity_err_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_parity_err_wd = reg_wdata[7];
	assign ctrl_tx_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_tx_wd = reg_wdata[0];
	assign ctrl_rx_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_rx_wd = reg_wdata[1];
	assign ctrl_nf_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_nf_wd = reg_wdata[2];
	assign ctrl_slpbk_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_slpbk_wd = reg_wdata[4];
	assign ctrl_llpbk_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_llpbk_wd = reg_wdata[5];
	assign ctrl_parity_en_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_parity_en_wd = reg_wdata[6];
	assign ctrl_parity_odd_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_parity_odd_wd = reg_wdata[7];
	assign ctrl_rxblvl_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_rxblvl_wd = reg_wdata[9:8];
	assign ctrl_nco_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_nco_wd = reg_wdata[31:16];
	assign status_txfull_re = addr_hit[4] && reg_re;
	assign status_rxfull_re = addr_hit[4] && reg_re;
	assign status_txempty_re = addr_hit[4] && reg_re;
	assign status_txidle_re = addr_hit[4] && reg_re;
	assign status_rxidle_re = addr_hit[4] && reg_re;
	assign status_rxempty_re = addr_hit[4] && reg_re;
	assign rdata_re = addr_hit[5] && reg_re;
	assign wdata_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign wdata_wd = reg_wdata[7:0];
	assign fifo_ctrl_rxrst_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign fifo_ctrl_rxrst_wd = reg_wdata[0];
	assign fifo_ctrl_txrst_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign fifo_ctrl_txrst_wd = reg_wdata[1];
	assign fifo_ctrl_rxilvl_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign fifo_ctrl_rxilvl_wd = reg_wdata[4:2];
	assign fifo_ctrl_txilvl_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign fifo_ctrl_txilvl_wd = reg_wdata[6:5];
	assign fifo_status_txlvl_re = addr_hit[8] && reg_re;
	assign fifo_status_rxlvl_re = addr_hit[8] && reg_re;
	assign ovrd_txen_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign ovrd_txen_wd = reg_wdata[0];
	assign ovrd_txval_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign ovrd_txval_wd = reg_wdata[1];
	assign val_re = addr_hit[10] && reg_re;
	assign timeout_ctrl_val_we = (addr_hit[11] & reg_we) & ~wr_err;
	assign timeout_ctrl_val_wd = reg_wdata[23:0];
	assign timeout_ctrl_en_we = (addr_hit[11] & reg_we) & ~wr_err;
	assign timeout_ctrl_en_wd = reg_wdata[31];
	always @(*) begin
		reg_rdata_next = {DW {1'sb0}};
		case (1'b1)
			addr_hit[0]: begin
				reg_rdata_next[0] = intr_state_tx_watermark_qs;
				reg_rdata_next[1] = intr_state_rx_watermark_qs;
				reg_rdata_next[2] = intr_state_tx_empty_qs;
				reg_rdata_next[3] = intr_state_rx_overflow_qs;
				reg_rdata_next[4] = intr_state_rx_frame_err_qs;
				reg_rdata_next[5] = intr_state_rx_break_err_qs;
				reg_rdata_next[6] = intr_state_rx_timeout_qs;
				reg_rdata_next[7] = intr_state_rx_parity_err_qs;
			end
			addr_hit[1]: begin
				reg_rdata_next[0] = intr_enable_tx_watermark_qs;
				reg_rdata_next[1] = intr_enable_rx_watermark_qs;
				reg_rdata_next[2] = intr_enable_tx_empty_qs;
				reg_rdata_next[3] = intr_enable_rx_overflow_qs;
				reg_rdata_next[4] = intr_enable_rx_frame_err_qs;
				reg_rdata_next[5] = intr_enable_rx_break_err_qs;
				reg_rdata_next[6] = intr_enable_rx_timeout_qs;
				reg_rdata_next[7] = intr_enable_rx_parity_err_qs;
			end
			addr_hit[2]: begin
				reg_rdata_next[0] = 1'sb0;
				reg_rdata_next[1] = 1'sb0;
				reg_rdata_next[2] = 1'sb0;
				reg_rdata_next[3] = 1'sb0;
				reg_rdata_next[4] = 1'sb0;
				reg_rdata_next[5] = 1'sb0;
				reg_rdata_next[6] = 1'sb0;
				reg_rdata_next[7] = 1'sb0;
			end
			addr_hit[3]: begin
				reg_rdata_next[0] = ctrl_tx_qs;
				reg_rdata_next[1] = ctrl_rx_qs;
				reg_rdata_next[2] = ctrl_nf_qs;
				reg_rdata_next[4] = ctrl_slpbk_qs;
				reg_rdata_next[5] = ctrl_llpbk_qs;
				reg_rdata_next[6] = ctrl_parity_en_qs;
				reg_rdata_next[7] = ctrl_parity_odd_qs;
				reg_rdata_next[9:8] = ctrl_rxblvl_qs;
				reg_rdata_next[31:16] = ctrl_nco_qs;
			end
			addr_hit[4]: begin
				reg_rdata_next[0] = status_txfull_qs;
				reg_rdata_next[1] = status_rxfull_qs;
				reg_rdata_next[2] = status_txempty_qs;
				reg_rdata_next[3] = status_txidle_qs;
				reg_rdata_next[4] = status_rxidle_qs;
				reg_rdata_next[5] = status_rxempty_qs;
			end
			addr_hit[5]: reg_rdata_next[7:0] = rdata_qs;
			addr_hit[6]: reg_rdata_next[7:0] = {8 {1'sb0}};
			addr_hit[7]: begin
				reg_rdata_next[0] = 1'sb0;
				reg_rdata_next[1] = 1'sb0;
				reg_rdata_next[4:2] = fifo_ctrl_rxilvl_qs;
				reg_rdata_next[6:5] = fifo_ctrl_txilvl_qs;
			end
			addr_hit[8]: begin
				reg_rdata_next[5:0] = fifo_status_txlvl_qs;
				reg_rdata_next[21:16] = fifo_status_rxlvl_qs;
			end
			addr_hit[9]: begin
				reg_rdata_next[0] = ovrd_txen_qs;
				reg_rdata_next[1] = ovrd_txval_qs;
			end
			addr_hit[10]: reg_rdata_next[15:0] = val_qs;
			addr_hit[11]: begin
				reg_rdata_next[23:0] = timeout_ctrl_val_qs;
				reg_rdata_next[31] = timeout_ctrl_en_qs;
			end
			default: reg_rdata_next = {DW {1'sb1}};
		endcase
	end
endmodule
module uart_rx (
	clk_i,
	rst_ni,
	rx_enable,
	tick_baud_x16,
	parity_enable,
	parity_odd,
	tick_baud,
	rx_valid,
	rx_data,
	idle,
	frame_err,
	rx_parity_err,
	rx
);
	input clk_i;
	input rst_ni;
	input rx_enable;
	input tick_baud_x16;
	input parity_enable;
	input parity_odd;
	output wire tick_baud;
	output wire rx_valid;
	output [7:0] rx_data;
	output wire idle;
	output frame_err;
	output rx_parity_err;
	input rx;
	reg rx_valid_q;
	reg [10:0] sreg_q;
	reg [10:0] sreg_d;
	reg [3:0] bit_cnt_q;
	reg [3:0] bit_cnt_d;
	reg [3:0] baud_div_q;
	reg [3:0] baud_div_d;
	reg tick_baud_d;
	reg tick_baud_q;
	reg idle_d;
	reg idle_q;
	assign tick_baud = tick_baud_q;
	assign idle = idle_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			sreg_q <= 11'h000;
			bit_cnt_q <= 4'h0;
			baud_div_q <= 4'h0;
			tick_baud_q <= 1'b0;
			idle_q <= 1'b1;
		end
		else begin
			sreg_q <= sreg_d;
			bit_cnt_q <= bit_cnt_d;
			baud_div_q <= baud_div_d;
			tick_baud_q <= tick_baud_d;
			idle_q <= idle_d;
		end
	always @(*)
		if (!rx_enable) begin
			sreg_d = 11'h000;
			bit_cnt_d = 4'h0;
			baud_div_d = 4'h0;
			tick_baud_d = 1'b0;
			idle_d = 1'b1;
		end
		else begin
			tick_baud_d = 1'b0;
			sreg_d = sreg_q;
			bit_cnt_d = bit_cnt_q;
			baud_div_d = baud_div_q;
			idle_d = idle_q;
			if (tick_baud_x16)
				{tick_baud_d, baud_div_d} = {1'b0, baud_div_q} + 5'h01;
			if (idle_q && !rx) begin
				baud_div_d = 4'd8;
				tick_baud_d = 1'b0;
				bit_cnt_d = (parity_enable ? 4'd11 : 4'd10);
				sreg_d = 11'h000;
				idle_d = 1'b0;
			end
			else if (!idle_q && tick_baud_q)
				if ((bit_cnt_q == (parity_enable ? 4'd11 : 4'd10)) && rx) begin
					idle_d = 1'b1;
					bit_cnt_d = 4'h0;
				end
				else begin
					sreg_d = {rx, sreg_q[10:1]};
					bit_cnt_d = bit_cnt_q - 4'h1;
					idle_d = bit_cnt_q == 4'h1;
				end
		end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			rx_valid_q <= 1'b0;
		else
			rx_valid_q <= tick_baud_q & (bit_cnt_q == 4'h1);
	assign rx_valid = rx_valid_q;
	assign rx_data = (parity_enable ? sreg_q[8:1] : sreg_q[9:2]);
	assign frame_err = rx_valid_q & ~sreg_q[10];
	assign rx_parity_err = (parity_enable & rx_valid_q) & ^{sreg_q[9:1], parity_odd};
endmodule
module uart_tx (
	clk_i,
	rst_ni,
	tx_enable,
	tick_baud_x16,
	parity_enable,
	wr,
	wr_parity,
	wr_data,
	idle,
	tx
);
	input clk_i;
	input rst_ni;
	input tx_enable;
	input tick_baud_x16;
	input wire parity_enable;
	input wr;
	input wire wr_parity;
	input [7:0] wr_data;
	output idle;
	output wire tx;
	reg [3:0] baud_div_q;
	reg tick_baud_q;
	reg [3:0] bit_cnt_q;
	reg [3:0] bit_cnt_d;
	reg [10:0] sreg_q;
	reg [10:0] sreg_d;
	reg tx_q;
	reg tx_d;
	assign tx = tx_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			baud_div_q <= 4'h0;
			tick_baud_q <= 1'b0;
		end
		else if (tick_baud_x16)
			{tick_baud_q, baud_div_q} <= {1'b0, baud_div_q} + 5'h01;
		else
			tick_baud_q <= 1'b0;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			bit_cnt_q <= 4'h0;
			sreg_q <= 11'h7ff;
			tx_q <= 1'b1;
		end
		else begin
			bit_cnt_q <= bit_cnt_d;
			sreg_q <= sreg_d;
			tx_q <= tx_d;
		end
	always @(*)
		if (!tx_enable) begin
			bit_cnt_d = 4'h0;
			sreg_d = 11'h7ff;
			tx_d = 1'b1;
		end
		else begin
			bit_cnt_d = bit_cnt_q;
			sreg_d = sreg_q;
			tx_d = tx_q;
			if (wr) begin
				sreg_d = {1'b1, (parity_enable ? wr_parity : 1'b1), wr_data, 1'b0};
				bit_cnt_d = (parity_enable ? 4'd11 : 4'd10);
			end
			else if (tick_baud_q && (bit_cnt_q != 4'h0)) begin
				sreg_d = {1'b1, sreg_q[10:1]};
				tx_d = sreg_q[0];
				bit_cnt_d = bit_cnt_q - 4'h1;
			end
		end
	assign idle = (tx_enable ? bit_cnt_q == 4'h0 : 1'b1);
endmodule
