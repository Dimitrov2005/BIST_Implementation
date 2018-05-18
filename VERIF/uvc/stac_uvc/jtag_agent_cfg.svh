class jtag_agent_config extends uvm_object;
   `uvm_object_utils(jtag_agent_config)
     virtual jtag_iface jtag_viface;
	 
   function new(string name="");
      super.new(name);
   endfunction // new

   uvm_active_passive_enum is_active=UVM_ACTIVE;

endclass // agent_config
