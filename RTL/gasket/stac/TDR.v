module TDR (input 
	   CaptureDR,
	   ShiftDR,
	   UpdateDR,    
	   Enable,      //enable from decoder
	   TRESETN,
	   TCLK,          
	   SI,          //Serial input
	   output reg
	   SO           //serial output
	   );
   
   parameter SIZE=17;
   parameter ADDR=45;
   
   reg [SIZE-1:0] serialReg,parallelReg;

   always @(posedge TCLK or negedge TRESETN)
     if(~TRESETN)
       serialReg<='b0;
     else if(ShiftDR && Enable)
       serialReg<={SI,serialReg[SIZE-1:1]};
     else if(CaptureDR && Enable)
       serialReg[SIZE-1:0]<=8'hcf;
     else 
       serialReg<=serialReg;
   
   always @(posedge TCLK or negedge TRESETN)
     if(~TRESETN)
       parallelReg<='b0;
     else if (UpdateDR && Enable)
       parallelReg<=serialReg;
     else 
       parallelReg<=parallelReg;
   
   always @* assign SO=serialReg[SIZE-1];
   
endmodule


