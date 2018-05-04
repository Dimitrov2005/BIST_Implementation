module bistprj_gasket(
input 
	MAS_CLK,
	MAS_RST,
	IN_JTAG_TMS,
	IN_JTAG_WSI,
	//to do : add phy signals for bist
output
	OUT_JTAG_WSO 	
);

// wires for the internal connections to phy !!!! 
wire gasket2jtag_tms;
wire gasket2jtag_clk;
wire gasket2jtag_rst;
wire gasket2jtag_wsi;
wire jtag2gasket_wso;
//instance of the stack which holds the tdr's

//to do : add tdr's output data and connect to phy inputs
JTAG stc(
	.TMS(IN_JTAG_TMS),
    .TCLK(MAS_CLK),
    .TRESETN(MAS_RST),
    .WSI(IN_JTAG_WSI),
    .WSO(OUT_JTAG_WSO)
	);
endmodule
	    