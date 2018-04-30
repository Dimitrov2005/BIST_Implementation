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
 

   


   function new(string name, uvm_component parent);
		super.new(name,parent);
		aportMon=new("aportMon",this);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction // build_phase

   task run_phase(uvm_phase phase);
   forever @(negedge viface.TCLK)
    begin
		if(viface.TRESETN)
			begin 
				update_fsm(CaptureDR, ShiftDR, UpdateDR,_ExitDR1); 
			end
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
			$display("shiftDR at %t ",$time());
			WSI={WSI,viface.WSI};
			WSO={WSO,viface.WSO};
			//$display("Shift DR , WSI =%b WSO =%b at : %t",viface.WSO,viface.WSO,$time());
			//$display("MONITOR : WSI %p  %d /n WSO %p %d time:%t",WSI,WSI.size(),WSO,WSO.size(),$time()); // newdata is shifted ok
		end
	
//data checker//
		if(_ExitDR1)
		begin
			temp=(aq.find_first() with(item==addr_tdr));
			//$display("--------size of find %d---------",temp.size());
			if(temp.size()<1)
				begin
					aq.push_front(addr_tdr);
					oldWSI=DEFTDR; // if address not in aq,then add it +  default for tdr 	     
				end
			if(RO)
				oldWSI=CAPTDR;
				// dataCheck:assert(WSO==oldWSI)else `uvm_warning("DM",$sformatf("-------- DATA MISMATCH ----- new: %p \n old:%p",WSO,oldWSI));
				$display("-------- DATA COMPARATOR ----- \n new:%p \n old:%p",WSO,oldWSI);	
			oldWSI=WSI;
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
	end
	endtask // run_phase
   
   task update_fsm(output bit captureDR, output bit shiftDR, output bit updateDR,output bit _ExitDR1); // 1149.1 fsm 
		wait (viface.TRESETN);
		@(posedge viface.TCLK);
		begin 
			@(posedge viface.TCLK);
			state=next;
			case(state)// TMS check        tms =1              tms  =0 
				TLR:     if(viface.TMS)   next=TLR;          else next=IDLE;
				IDLE:    if(viface.TMS)   next=SelectDR;     else next=IDLE;
				
//------------- DATA ----------------//
	       
				SelectDR: if(viface.TMS)  next=SelectIR;     else next=CapDR;
				CapDR:    if(viface.TMS)  next=ExitDR1;      else next=ShiDR;
				ShiDR:	  if(viface.TMS)  next=ExitDR1;      else next=ShiDR;
				ExitDR1:  if(viface.TMS)  next=UpdDR;        else next=PauseDR;
				PauseDR:  if(viface.TMS)  next=ExitDR2;      else next=PauseDR;
				ExitDR2:  if(viface.TMS)  next=UpdDR;        else next=ShiDR;
				UpdDR:    if(viface.TMS)  next=SelectDR;      else next=IDLE;
				
//---------INSTRUCTION----------------// 
	       
			    SelectIR: if(viface.TMS)  next=TLR;          else next=CapIR;
				CapIR:    if(viface.TMS)  next=ExitIR1;      else next=ShiIR;
				ShiIR:    if(viface.TMS)  next=ExitIR1;      else next=ShiIR;
				ExitIR1:  if(viface.TMS)  next=UpdIR;        else next=PauseIR;
				PauseIR:  if(viface.TMS)  next=ExitIR2;      else next=PauseIR;
				ExitIR2:  if(viface.TMS)  next=UpdIR;        else next=ShiIR;
				UpdIR:    if(viface.TMS)  next=SelectDR;     else next=IDLE;
				default: state = IDLE;
			endcase // case (state)
			
			captureDR = (state === 3)  ? 1:0;
			shiftDR   = (state === 4)  ? 1:0; 
			updateDR  = (state === 8)  ? 1:0;
			CaptureIR = (state === 10) ? 1:0;
			ShiftIR   = (state === 11) ? 1:0;
			UpdateIR  = (state === 15) ? 1:0;
			_ExitDR1   = (state === 5)  ? 1:0;
	
		end // forever begin
   endtask

endclass // Monitor
