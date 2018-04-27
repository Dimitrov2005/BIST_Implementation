class agent_config extends uvm_object;
   `uvm_object_utils(agent_config)
     virtual iface viface;
   function new(string name="");
      super.new(name);
   endfunction // new

   uvm_active_passive_enum is_active=UVM_ACTIVE;

endclass // agent_config
