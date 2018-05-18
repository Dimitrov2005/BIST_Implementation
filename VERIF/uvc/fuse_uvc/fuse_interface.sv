interface fuse_iface(input logic TCLK,TRESETN);
   logic TMS, 
	 WSI,
	 WSO;
	 
	 
//   D E B U G     P U R P O S E   //
/*
	 always @(TMS)
	 $display("INTERFACE TMS CHANGED TO %b  time %t",TMS,$time());	 
*/

endinterface