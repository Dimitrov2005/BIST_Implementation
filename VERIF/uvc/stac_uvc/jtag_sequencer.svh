class jtag_sequencer extends uvm_sequencer #(jtag_transaction);
  
 `uvm_component_utils(jtag_sequencer)
     
     function new(string name, uvm_component parent);
	super.new(name,parent);
     endfunction // new

endclass // Seqencer
