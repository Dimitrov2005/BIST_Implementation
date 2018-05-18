class jtag_driver extends uvm_driver #(jtag_transaction);
   
   `uvm_component_utils(jtag_driver)
     virtual jtag_iface jtag_viface;
   int 	     i;
   int 		 drvShiftCnt; //driver shift counter, used in monitor for checkers
   bit 	     WSI[];
	
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction; // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase) ;
     
   endfunction // build_phase

   task run_phase(uvm_phase phase);
       jtag_transaction tr;	
      @(negedge jtag_viface.TCLK) jtag_viface.TMS<=1;//TLR->IDLE
      @(negedge jtag_viface.TCLK)	jtag_viface.TMS<=0;
      forever
	begin
	   wait (jtag_viface.TRESETN)
	     seq_item_port.get_next_item(tr);
	   //+++++++++++++ SHIFT INTO IR THE ADDRESS OF 1-ST TDR++++++++++++++++++++ //

  
		@(negedge jtag_viface.TCLK)	jtag_viface.TMS<=1;
		@(negedge jtag_viface.TCLK)	jtag_viface.TMS<=1;
		@(negedge jtag_viface.TCLK)	jtag_viface.TMS<=0;
		@(negedge jtag_viface.TCLK)
		  for(i=0;i<=7;i++) 
		    begin
		       jtag_viface.TMS<=0;
		       @(negedge jtag_viface.TCLK)
			 jtag_viface.WSI<=tr.ADDR[i];
		    end
		jtag_viface.TMS<=1;
		@(negedge jtag_viface.TCLK) jtag_viface.TMS<=1;
		@(negedge jtag_viface.TCLK) jtag_viface.TMS<=1;
		//--------------- SHIFT INTO IR THE ADDRESS OF 1-ST TDR  --------------------//
		
		//++++++++++++++ SHIFT DATA INTO 1-ST TDR ++++++++++++++++++++++++//
		 
		@(negedge jtag_viface.TCLK)	jtag_viface.TMS<=0;
		@(negedge jtag_viface.TCLK) 
		
		
		  for(i=0;i<(tr.WSI.size());i++)
		    begin	
			//$display("WSI =%p shift number %d  time = %t\n",tr.WSI,i,$time());
		       jtag_viface.TMS<=0;
		       @(negedge jtag_viface.TCLK)
			   
			 jtag_viface.WSI<=tr.WSI[i];
		    end
			drvShiftCnt=tr.WSI.size();
			//$display("++++++++++drvShiftCnt++++++++++++ = %d ",drvShiftCnt);
		jtag_viface.TMS<=1;
		@(negedge jtag_viface.TCLK) jtag_viface.TMS<=1;
		@(negedge jtag_viface.TCLK) jtag_viface.TMS<=0;
		// -------------------- SHIFT DATA INTO 1-ST TDR -------------------- //


	   
	  
	   seq_item_port.item_done();
	end //
   endtask // run_phase
endclass // Driver