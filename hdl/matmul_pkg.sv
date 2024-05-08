package matmul_pkg;
	// DUT Params
	parameter int unsigned BUS_WIDTH = 32;
	parameter int unsigned DATA_WIDTH = 8;
	parameter int unsigned ADDR_WIDTH = 16;
	parameter int unsigned SP_NTARGETS = 4;
	parameter int unsigned NUMBER_OF_CHECK = 100;
	localparam int unsigned MAX_DIM = BUS_WIDTH/DATA_WIDTH;
	typedef logic[BUS_WIDTH-1:0] data_bus_t;
	typedef logic[ADDR_WIDTH-1:0] adrr_bus_t;
	typedef logic[MAX_DIM-1:0] elements_data_bus_t;
	// TB Params
	localparam time CLK_NS = 10;
	localparam int unsigned RST_CYC = 3;

endpackage
