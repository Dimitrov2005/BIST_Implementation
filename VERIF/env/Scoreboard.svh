class Scoreboard extends uvm_scoreboard;

   `uvm_component_utils(Scoreboard)

 //    uvm_tlm_analysis_fifo#(Transaction) fifo;
  // byte cnt=0;
  // Transaction tr;
   //int 	mism=0;
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    //  fifo=new("fifo",this);
   endfunction // build_phase

   
   task run();
   //   forever 
	//begin
	//   tr=new("tr");
	//   fifo.get(tr);
	  // `uvm_info("TRREC",$sformatf("+++++++ Transaction recieved   WSI: %h WSO %h ++++++",tr.WSI,tr.WSO), UVM_MEDIUM);
	//end
   endtask // run
endclass // Scoreboard
