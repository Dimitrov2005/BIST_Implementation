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
   bit [7:0] temp[$];
	bit [7:0] addr_tdr; // tdr addres
	bit  DEFTDR[]; // Default TDR value 
	bit  CAPTDR[]; //captured DR
   bit 	      RO;//read only
  // bit [1:0]    addr_def[];
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
   


   function new(string name, uvm_component parent);
		super.new(name,parent);
		aportMon=new("aportMon",this);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction // build_phase

   task run_phase(uvm_phase phase);
   forever @(posedge viface.TCLK)
    begin
	//	if(viface.TRESETN)   think that it shouldnt wait for rst==1. If rst => reset the queues, wsi and wso
			begin 
				_tms=viface.TMS;
				$display("Clock fsm monitor at %t ",$time()); 
				update_fsm(_tms,CaptureDR, ShiftDR, UpdateDR,_ExitDR1,CaptureIR,ShiftIR,UpdateIR); 
			end
//capture monitor// 
		if(CaptureDR) 
		begin
			WSI.delete();
			WSO.delete();
			$display("Capture DR at %t",$time);
		end
//shift monitor//
		if(ShiftDR) 							//here we have an extra shift cycle from the fsm implemented in monitor, so need
		begin									// to cut the WSI to default value's size 
			$display("shiftDR at %t ",$time());
			shiftCnt=shiftCnt+1;
			WSI={viface.WSI,WSI};
			WSO={viface.WSO,WSO};
			
			// D A T A    S I Z E    C H E C K   ///
			if(!(WSI.size()==DEFTDR.size()) && (shiftCnt>DEFTDR.size()))
			begin
				$display("WSI CORRECT MONITOR" );							//display def value size, check why there are 18 bits,
				$display("WSI BEFORE CORRECTION %p  %d",WSI ,DEFTDR.size();	// the correction mechanism not working why ? 
				WSI=new[DEFTDR.size()](WSI);								// need to fix the shift of the extra byte 
				$display("WSI AFTER CORRECTION %p",WSI);
			end
			if(!(WSO.size()==DEFTDR.size()) && (shiftCnt>DEFTDR.size()))
			begin
				WSO=new[DEFTDR.size()](WSO);
			end
			//$display("Shift DR , WSI =%b WSO =%b at : %t",viface.WSO,viface.WSO,$time());
			//$display("MONITOR : WSI %p  %d /n WSO %p %d time:%t",WSI,WSI.size(),WSO,WSO.size(),$time()); // newdata is shifted ok
		end
	
//data checker//
		if(_ExitDR1)
		begin
			shiftCnt=0;
			temp=(aq.find_first() with(item==addr_tdr));
			//$display("--------size of find %d---------",temp.size());
			if(temp.size()<1)
				begin
					aq.push_front(addr_tdr); 	//if address is not in address queue, add it in
					oldWSI = DEFTDR; 			// then the first value to check will be the value of the tdr, which we shift in test	     
				end
			if(RO)  							// if the tdr is READ_ONLY, the data to check will be the captured one 
				oldWSI=CAPTDR;
				// dataCheck:assert(WSO==oldWSI)else `uvm_warning("DM",$sformatf("-------- DATA MISMATCH ----- new: %p \n old:%p",WSO,oldWSI));
			oldWSI=WSI;
			$display("-------- DATA COMPARATOR ----- \n new:%p \n old:%p",WSO,oldWSI);	
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
		// $display("Update IR at %t",$time());
	end

	endtask // run_phase
   
   task update_fsm(input logic tms,output bit captureDR, output bit shiftDR, output bit updateDR,output bit _ExitDR1,output bit captureIR, output bit shiftIR, output bit updateIR); // 1149.1 fsm 
		
		$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());
		begin 
			//@(negedge viface.TCLK);
			if(!viface.TRESETN)
			begin 
				next=TLR; 
				$display("RESET MONITOR FSM \n");  
			end         
			else state=next;
			
			case(state)// TMS check        tms =1              tms  =0 
				TLR:    
				if(tms===1 && !($isunknown(tms)))  
				begin 
					next=TLR;
					$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());
				end					
				else if(tms===0 && !($isunknown(tms)))
				begin
					next=IDLE;
					$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());
				end					// if(viface.TMS)   next=TLR;          else next=IDLE;
				IDLE:    
				if(tms===1 && !($isunknown(tms)))     
				begin 
					next=SelectDR; 
					$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());				
				end
				else if(tms===0 && !($isunknown(tms)))
				begin
					next=IDLE;
					$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());
				end
//------------- DATA ----------------//
	       
				SelectDR: 
				if(tms===1 && !($isunknown(tms)))  
				begin						
					next=SelectIR;
					$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());				
				end
				else if(tms===0 && !($isunknown(tms))) 
				begin 
					next=CapDR;
					$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());
				end	
				CapDR:  
				if(tms===1 && !($isunknown(tms)))   
				begin 
					next=ExitDR1;
					$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());
				end 
				else if(tms===0 && !($isunknown(tms))) 
				begin
					next=ShiDR;
					$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());
				end
				ShiDR:	 
				if(tms===1 && !($isunknown(tms)))   
				next=ExitDR1;    
				else if(tms===0 && !($isunknown(tms))) next=ShiDR;
				ExitDR1: 
				if(tms===1 && !($isunknown(tms)))   
				next=UpdDR; 
				else if(tms===0 && !($isunknown(tms))) next=PauseDR;
				PauseDR: 
				if(tms===1 && !($isunknown(tms)))   
				next=ExitDR2;   
				else if(tms===0 && !($isunknown(tms))) next=PauseDR;
				ExitDR2: 
				if(tms===1 && !($isunknown(tms)))   
				next=UpdDR; 
				else if(tms===0 && !($isunknown(tms))) next=ShiDR;
				UpdDR: 
				if(tms===1 && !($isunknown(tms)))   
				next=SelectDR;  
				else if(tms===0 && !($isunknown(tms))) next=IDLE;
				
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
			//try to get this out of here
			captureDR = (state === CapDR)  ? 1:0;
			shiftDR   = (state === ShiDR)  ? 1:0; 
			updateDR  = (state === UpdDR)  ? 1:0;
			captureIR = (state === CapIR) ? 1:0;
			shiftIR   = (state === ShiIR) ? 1:0;
			updateIR  = (state === UpdIR) ? 1:0;
			_ExitDR1  = (state === ExitDR1)  ? 1:0;
	
		end // forever begin
   endtask

endclass // Monitor8
/*task update_fsm(input logic tms,output bit captureDR, output bit shiftDR, output bit updateDR,output bit _ExitDR1,output bit captureIR, output bit shiftIR, output bit updateIR); // 1149.1 fsm 
		//@(posedge viface.TCLK);
		$display("IN monitor FSM : state = %s | next = %s | TMS = %b     at  %t ",state, next, tms, $time());
		//logic tms;
		//tms=_tms;
		begin 
			//@(negedge viface.TCLK);
			if(!viface.TRESETN)
			begin 
				next=TLR; 
				$display("RESET MONITOR FSM \n");  
			end         
			else state=next;
			
			case(state)// TMS check        tms =1              tms  =0 
				TLR:     if(tms)   next=TLR;          else next=IDLE; // if(viface.TMS)   next=TLR;          else next=IDLE;
				IDLE:    if(tms)   next=SelectDR;     else next=IDLE;
				
//------------- DATA ----------------//
	       
				SelectDR: if(tms)  next=SelectIR;     else next=CapDR;
				CapDR:    if(tms)  next=ExitDR1;      else next=ShiDR;
				ShiDR:	  if(tms)  next=ExitDR1;      else next=ShiDR;
				ExitDR1:  if(tms)  next=UpdDR;        else next=PauseDR;
				PauseDR:  if(tms)  next=ExitDR2;      else next=PauseDR;
				ExitDR2:  if(tms)  next=UpdDR;        else next=ShiDR;
				UpdDR:    if(tms)  next=SelectDR;      else next=IDLE;
				
//---------INSTRUCTION----------------// 
	       
			    SelectIR: if(tms)  next=TLR;          else next=CapIR;
				CapIR:    if(tms)  next=ExitIR1;      else next=ShiIR;
				ShiIR:    if(tms)  next=ExitIR1;      else next=ShiIR;
				ExitIR1:  if(tms)  next=UpdIR;        else next=PauseIR;
				PauseIR:  if(tms)  next=ExitIR2;      else next=PauseIR;
				ExitIR2:  if(tms)  next=UpdIR;        else next=ShiIR;
				UpdIR:    if(tms)  next=SelectDR;     else next=IDLE;
				default: state = IDLE;
			endcase // case (state)
			
			captureDR = (state === CapDR)  ? 1:0;
			shiftDR   = (state === ShiDR)  ? 1:0; 
			updateDR  = (state === UpdDR)  ? 1:0;
			captureIR = (state === CapIR) ? 1:0;
			shiftIR   = (state === ShiIR) ? 1:0;
			updateIR  = (state === UpdIR) ? 1:0;
			_ExitDR1  = (state === ExitDR1)  ? 1:0;
	
		end // forever begin
   endtask*/