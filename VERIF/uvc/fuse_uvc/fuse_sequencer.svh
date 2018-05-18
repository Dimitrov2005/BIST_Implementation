class fuse_sequencer extends uvm_sequencer #(fuse_transaction);
  
 `uvm_component_utils(fuse_sequencer)
     
     function new(string name, uvm_component parent);
		super.new(name,parent);
     endfunction // new

endclass // Seqencer
