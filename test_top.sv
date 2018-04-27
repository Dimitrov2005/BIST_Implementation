module top;
  `timescale 1ns/1ps;
  import uvm_pkg::*;
  import pack_all::*;  
`include "uvm_macros.svh"
 
   bit TCLK,TRESETN;  
   iface iface1(TCLK,TRESETN);
   virtual iface viface=iface1;

STAC stc(.TMS(iface1.TMS),
	    .TCLK(iface1.TCLK),
	    .TRESETN(iface1.TRESETN),
	    .WSI(iface1.WSI),
	    .WSO(iface1.WSO));
	    
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
	#1000 $finish();
     end
endmodule:top