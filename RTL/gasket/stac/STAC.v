module JTAG (
input 
	 TMS,
	 TCLK,
	 TRESETN,
	 WSI,
output 
	 WSO
	 
);

   wire 	    CaptureDR;
   wire 	    ShiftDR;
   wire 	    UpdateDR;
   wire 	    CaptureIR;
   wire 	    ShiftIR;
   wire 	    UpdateIR;
   wire 	    CaptureDR_neg;
   wire 	    ShiftDR_neg;
   wire 	    CaptureIR_neg;
   wire 	    ShiftIR_neg;
   wire 	    en1;
   wire 	    en2;
   wire 	    si1_mux;
   wire 	    si2_mux;
   wire [7:0] 	    ir_po;
   
	
   fsm fsm(.TMS(TMS),
	   .TDI(WSI),
	   .TRSTN(TRESETN),
	   .TCLK(TCLK),
	   .CaptureDR(CaptureDR),
	   .ShiftDR(ShiftDR),
	   .UpdateDR(UpdateDR),
	   .CaptureIR(CaptureIR),
	   .ShiftIR(ShiftIR),
	   .UpdateIR(UpdateIR),
	   .CaptureDR_neg(CaptureDR_neg),
	   .ShiftDR_neg(ShiftDR_neg),
	   .CaptureIR_neg(CaptureIR_neg),
	   .ShiftIR_neg(ShiftIR_neg)
	   );

   dec dec1(.x(ir_po),
	   .EN1(en1),
	   .EN2(en2)
	    );
	  

   mux mux1( .SO1(si1_mux),
	     .SO2(si2_mux),
	     .e(ir_po),
	     .WSO(WSO)
	     );
  
   IR ir1( .CaptureIR(CaptureIR_neg),
	   .ShiftIR(ShiftIR_neg),
	   .UpdateIR(UpdateIR), 
	   .TRESETN(TRESETN),
	   .TCLK(TCLK),          
	   .SI(WSI), 
	   .PO(ir_po)
	   );
   
   TDRRW tdr1(.CaptureDR(CaptureDR_neg),
	.ShiftDR(ShiftDR_neg),
	.UpdateDR(UpdateDR),
	.Enable(en1),
	.TRESETN(TRESETN),
	.TCLK(TCLK), 
	.SI(WSI),
	.SO(si1_mux)
	);
   
   TDRR  tdr2(.CaptureDR(CaptureDR_neg), 
	.ShiftDR(ShiftDR_neg),
	.UpdateDR(UpdateDR),
	.Enable(en2),
	.TRESETN(TRESETN),
	.TCLK(TCLK), 
	.SI(WSI),
	.PI(33'hca),// connect to constant 
	.SO(si2_mux)
	);

endmodule // STAC
