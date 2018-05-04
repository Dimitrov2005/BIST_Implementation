module fsm (
	    input
	    TMS,
	    TDI,
	    TRSTN,
	    TCLK,
	    output reg
	    CaptureDR,
	    ShiftDR,
	    UpdateDR,
	    CaptureIR,
	    ShiftIR,
	    UpdateIR,
	    CaptureDR_neg,
	    ShiftDR_neg,
	    CaptureIR_neg,
	    ShiftIR_neg
	    );
   reg [3:0] 	  state,next;
   parameter
     TLR=0, // TLR
       IDLE=1,       // RT/IDLE
       SelectDR=2,      // SELDR
       CapDR=3,      // CAPTUREDR
       ShiDR=4,     // SHIFTDR
       ExitDR1=5,      //  EXIT1DR
       PauseDR=6,     // PAUSEDR
       ExitDR2=7,     //  EXIT2DR
       UpdDR=8,     // UDATE DR
      

       SelectIR=9,    // SELECT-IR 
       CapIR=10,   // CAPIR
       ShiIR=11,   // SHIFTIR
       ExitIR1=12,   //EXITIR1
       PauseIR=13,   //PAUSEIR
       ExitIR2=14,    //EXITIR2
       UpdIR=15;   //UPDATEIR
        

   always @(posedge TCLK or negedge TRSTN)
      if(~TRSTN)
	state<=0;
      else state<=next;

   always @(TMS or state)
     begin
	next=IDLE;
	case (state)
	  
//---------- DATA BRANCH-----------//
	  
	  TLR:if(TMS)
	    next=TLR;
	  else next=IDLE;
	  
	  IDLE: if(TMS)
	    next=SelectDR;
	      else next=IDLE;

	  SelectDR: if(TMS)
	    next=SelectIR;
	  else next=CapDR;

	  CapDR:
	    if(TMS)
	      next=ExitDR1;
	    else next=ShiDR;

	  ShiDR:
	    if(TMS)
	      next=ExitDR1;
	    else next=ShiDR;

	  ExitDR1:
	    if(TMS)
	      next=UpdDR;
	    else next=PauseDR;

	  PauseDR:
	    if(TMS)
	      next=ExitDR2;
	    else next=PauseDR;

	  ExitDR2:
	    if(TMS)
	      next=UpdDR;
	    else next=ShiDR;

	  UpdDR:
	    if(TMS)
	      next=SelectDR;
	    else next=IDLE;

  //---------INSTRUCTION BRANCH----------------// 
	  	  
	  SelectIR: if(TMS)
	    next=TLR;
	  else next=CapIR;

	  CapIR:
	    if(TMS)
	      next=ExitIR1;
	    else next=ShiIR;

	  ShiIR:
	    if(TMS)
	      next=ExitIR1;
	    else next=ShiIR;

	  ExitIR1:
	    if(TMS)
	      next=UpdIR;
	    else next=PauseIR;

	  PauseIR:
	    if(TMS)
	      next=ExitIR2;
	    else next=PauseIR;

	  ExitIR2:
	    if(TMS)
	      next=UpdIR;
	    else next=ShiIR;

	  UpdIR:
	    if(TMS)
	      next=SelectDR;
	    else next=IDLE;

	  default: state=IDLE;
	endcase // case (state)
     end // always @ (TMS or state)
   
   always @(state)
     begin
	CaptureDR=(state === 3) ? 1:0;
	ShiftDR=(state === 4) ? 1:0; 
	UpdateDR=(state === 8) ? 1:0;
	CaptureIR=(state === 10) ? 1:0;
	ShiftIR=(state === 11) ? 1:0;
	UpdateIR=(state === 15) ? 1:0;
     end

   //pushing out enable signals at the negedge of TCLK// 
   always @(negedge TCLK)
     begin
	CaptureDR_neg<=CaptureDR;
	ShiftDR_neg<=ShiftDR;
	CaptureIR_neg<=CaptureIR;
	ShiftIR_neg<=ShiftIR;	
     end
   

   
// for all output signals check, it is guaranteed by the fms that only one state will be 1, others are 0

  // ?? what about the reset signal ?? 
   
endmodule // fsm
