module top;
  `timescale 1ns/1ps;
  import uvm_pkg::*;
  import env_pkg::*;  
`include "uvm_macros.svh"
 
   bit TCLK,TRESETN;  
   iface iface1(TCLK,TRESETN);
   virtual iface viface=iface1;

bistprj_gasket gasket(
	.MAS_CLK(iface1.TCLK),
	.MAS_RST(iface1.TRESETN),
	.IN_JTAG_TMS(iface1.TMS),
	.IN_JTAG_WSI(iface1.WSI),
	//to do : add phy signals for bist
	
	.OUT_JTAG_WSO(iface1.WSO)
	); 	   
/*JTAG stc(.TMS(iface1.TMS),
	    .TCLK(iface1.TCLK),
	    .TRESETN(iface1.TRESETN),
	    .WSI(iface1.WSI),
	    .WSO(iface1.WSO));
*/	    
   initial
     begin
	TCLK=0;
	TRESETN=1;
	#1 TRESETN=0;
	#5 TRESETN=1;
	
     end
  
 always #5 TCLK=~TCLK;

   initial 
     begin
	uvm_config_db #(virtual iface)::set  (null,"","viface",viface);
	run_test("test");	
	#10000 $finish();
     end
endmodule:top