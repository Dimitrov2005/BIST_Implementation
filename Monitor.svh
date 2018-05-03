class Monitor extends uvm_monitor;
   `uvm_component_utils(Monitor)
 
	 typedef enum bit[3:0]{ 
		   TLR=0, // TLR---
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
		   UpdIR=15   //UPDATEIR
	 } state_enum ;
	  
	 virtual iface viface;
	 uvm_analysis_port # (Transaction) aportMon; // declare analysis port 
	 bit WSI[];//STC in 
	 bit WSO[];//STC out 
	 bit oldWSI[]; // STC in prev
	 bit [7:0] aq[$]; // address queue
	 bit [7:0] temp[$];  //temp addr queue used for checker
	 bit [7:0] addr_tdr; // tdr addres
	 bit  DEFTDR[]; // Default TDR value 
	 bit  CAPTDR[]; //captured DR
	 bit 	      RO;//read only
	 
	 state_enum state=TLR;
	 state_enum  next=TLR;
	 bit 	     CaptureDR;
	 bit 	     ShiftDR;
	 bit 	     UpdateDR;
	 bit 		 _ExitDR1;
	 bit 	     CaptureIR;
	 bit 	     ShiftIR;
	 bit 	     UpdateIR;
	 bit 	     CaptureDR_neg;
	 bit 	     ShiftDR_neg;
	 bit 	     CaptureIR_neg;
	 bit 	     ShiftIR_neg;
	 
	 logic _tms;
	 int shiftCnt = 0;
	 int drvShiftCnt;
	 bit _WSO [];   //the corrected WSO data from monitor
	 bit _WSI [];   //the corrected WSI data from monitor
	 bit rstFlag;
	 int currentDefTdr; // size of curent default tdr value 
	 
	   function new(string name, uvm_component parent);
			super.new(name,parent);
			aportMon=new("aportMon",this);
	   endfunction // new

	   function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
	   endfunction // build_phase

	   task run_phase(uvm_phase phase);
	   forever @(posedge viface.TCLK) //repeat on every clock
		begin
			if(!viface.TRESETN)   //think that it shouldnt wait for rst==1. If rst => reset the queues, wsi and wso
			begin
				rstFlag=1;
				aq.delete();
				temp.delete();
				WSI.delete();
				WSO.delete();
				_WSI.delete();
				_WSO.delete();
			end
	//+++++++++ R U N   T H E   F S M  +++++++++ // 
			_tms=viface.TMS;
			$display("Clock fsm monitor at %t ",$time()); 
			update_fsm(_tms,CaptureDR, ShiftDR, UpdateDR,_ExitDR1,CaptureIR,ShiftIR,UpdateIR); 
			
	//capture monitor// 
			if(CaptureDR) 
			begin
				WSI.delete();
				WSO.delete();
				$display("Capture DR at %t",$time);
			end
	//shift monitor//
			if(ShiftDR) 							
			begin									
				//$display("shiftDR posedge at %t \n ",$time());
				shiftCnt=shiftCnt+1;
				WSI={viface.WSI,WSI};
				WSO={viface.WSO,WSO};
				//$display("-------- DATA SHIFT ----- \n WSI:%p \n   WSO:%p",_WSO,_WSI);	
	//+++++++++++++  D A T A    S I Z E    C O R R E C T I O N  +++++++++++++///
				if((WSI.size()==(DEFTDR.size()+1)))
				begin
					$display("WSI CORRECTION MONITOR - needed because of the monitor implementation");								
					$display("WSI BEFORE CORRECTION :%p  |  DEF VAL SIZE: %d  |  SHIFTED CYCLES: %d",WSI ,DEFTDR.size(),drvShiftCnt);	 
					_WSI=new[DEFTDR.size()];	
					_WSI = {>>{WSI with [0:DEFTDR.size()-1]}};
					$display("WSI AFTER CORRECTION %p   | SIZE %d ",_WSI,_WSI.size());
				end
				if((WSO.size()==(DEFTDR.size()+1)))
				begin
					$display("WSO CORRECTION MONITOR - needed because of the monitor implementation ");								
					$display("WSO BEFORE CORRECTION :%p  |  DEF VAL SIZE: %d  |  SHIFTED CYCLES: %d",WSO ,DEFTDR.size(),drvShiftCnt);	 
					_WSO=new[DEFTDR.size()];
					_WSO = {>>{WSO with [0:DEFTDR.size()-1]}};
					$display("WSO AFTER CORRECTION %p   | SIZE %d ",_WSO,_WSO.size());
				end
// +++++++++++++   D A T A    S I Z E    C H E C K E R    +++++++++++++  //
				dataSizeCheck: assert((WSO.size()-1)<=DEFTDR.size())else `uvm_warning("DM",$sformatf("-------- DATA SIZE NOT CORRECT ----- new: %p \n old:%p \n size exp = %d  | actual = %d",WSO,oldWSI,_WSO.size(),DEFTDR.size()));
				currentDefTdr=DEFTDR.size();

			end
		
// +++++++++++++   D A T A       C H E C K E R S   +++++++++++++  //
			if(_ExitDR1)
			begin
				
				temp=(aq.find_first() with(item==addr_tdr));		// check if the address of the tdr is in the address queue
				//$display("--------size of find %d---------",temp.size());
				if(temp.size()<1)
				begin
						aq.push_front(addr_tdr); 					// if address is not in address queue, add it in
						oldWSI = DEFTDR;							// then the first value to check will be the value of the tdr, which we shift in test
				end
				if(RO) 												// if the tdr is READ_ONLY, the data to check will be the captured one 
					oldWSI=CAPTDR;
				if(rstFlag)											// if there was a reset, only the WSO is reseted, the tdr's value is the def one
					oldWSI=new[DEFTDR.size()];
				dataCheck:assert(_WSO==oldWSI)else `uvm_warning("DM",$sformatf("-------- DATA MISMATCH ----- new: %p \n old:%p",_WSO,oldWSI));
				//$display("-------- DATA COMPARATOR ----- \n new:%p \n old:%p",_WSO,oldWSI);	
				oldWSI=_WSI;
				rstFlag=0;								    // null the rst flag; 
				shiftCnt=0;									// null the internal shift counter; 		
			end
		
			if(UpdateDR)
				$display("Update DR at %t",$time());
			if(CaptureIR) 
				$display("Capture IR at %t",$time());
			if(ShiftIR)
			begin
				//shifting address of tdr and saving it in address queue
				addr_tdr={viface.WSI,addr_tdr[7:1]};
			end	
			if(UpdateIR)
				$display("Update IR at %t",$time());
		end

		endtask // run_phase
	   
	   task update_fsm(input logic tms,output bit captureDR, output bit shiftDR, output bit updateDR,output bit _ExitDR1,output bit captureIR, output bit shiftIR, output bit updateIR); // 1149.1 fsm 
		//	$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());
			begin 
				//@(negedge viface.TCLK);
				if(!viface.TRESETN)
				begin 
					next=TLR; 
					$display("RESET MONITOR FSM \n");  
				end         
				else state=next;
				
				case(state)// TMS check        tms =1              tms  =0 
					TLR:     if(tms===1 && !($isunknown(tms)))     next=TLR;          else if(tms===0 && !($isunknown(tms))) next=IDLE; 
					IDLE:    if(tms===1 && !($isunknown(tms)))     next=SelectDR;     else if(tms===0 && !($isunknown(tms))) next=IDLE;
					
	//------------- DATA ----------------//
			   
					SelectDR: if(tms===1 && !($isunknown(tms)))    next=SelectIR;     else if(tms===0 && !($isunknown(tms))) next=CapDR;
					CapDR:    if(tms===1 && !($isunknown(tms)))    next=ExitDR1;      else if(tms===0 && !($isunknown(tms))) next=ShiDR;
					ShiDR:	  if(tms===1 && !($isunknown(tms)))    next=ExitDR1;      else if(tms===0 && !($isunknown(tms))) next=ShiDR;
					ExitDR1:  if(tms===1 && !($isunknown(tms)))    next=UpdDR;        else if(tms===0 && !($isunknown(tms))) next=PauseDR;
					PauseDR:  if(tms===1 && !($isunknown(tms)))    next=ExitDR2;      else if(tms===0 && !($isunknown(tms))) next=PauseDR;
					ExitDR2:  if(tms===1 && !($isunknown(tms)))    next=UpdDR;        else if(tms===0 && !($isunknown(tms))) next=ShiDR;
					UpdDR:    if(tms===1 && !($isunknown(tms)))    next=SelectDR;     else if(tms===0 && !($isunknown(tms))) next=IDLE;
					
	//---------INSTRUCTION----------------// 
			   
					SelectIR: if(tms===1 && !($isunknown(tms)))    next=TLR;          else if(tms===0 && !($isunknown(tms))) next=CapIR;
					CapIR:    if(tms===1 && !($isunknown(tms)))    next=ExitIR1;      else if(tms===0 && !($isunknown(tms))) next=ShiIR;
					ShiIR:    if(tms===1 && !($isunknown(tms)))    next=ExitIR1;      else if(tms===0 && !($isunknown(tms))) next=ShiIR;
					ExitIR1:  if(tms===1 && !($isunknown(tms)))    next=UpdIR;        else if(tms===0 && !($isunknown(tms))) next=PauseIR;
					PauseIR:  if(tms===1 && !($isunknown(tms)))    next=ExitIR2;      else if(tms===0 && !($isunknown(tms))) next=PauseIR;
					ExitIR2:  if(tms===1 && !($isunknown(tms)))    next=UpdIR;        else if(tms===0 && !($isunknown(tms))) next=ShiIR;
					UpdIR:    if(tms===1 && !($isunknown(tms)))    next=SelectDR;     else if(tms===0 && !($isunknown(tms))) next=IDLE;
					default: state = IDLE;
				endcase // case (state)
				
				captureDR = (state === CapDR)  ? 1:0;
				shiftDR   = (state === ShiDR)  ? 1:0; 
				updateDR  = (state === UpdDR)  ? 1:0;
				captureIR = (state === CapIR)  ? 1:0;
				shiftIR   = (state === ShiIR)  ? 1:0;
				updateIR  = (state === UpdIR)  ? 1:0;
				_ExitDR1  = (state === ExitDR1)  ? 1:0;
		
			end // forever begin
	   endtask

endclass // Monitor8
