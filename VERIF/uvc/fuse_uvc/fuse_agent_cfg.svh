class fuse_agent_config extends uvm_object;
   `uvm_object_utils(fuse_agent_config)
     virtual fuse_iface fuse_viface;
   function new(string name="");
      super.new(name);
   endfunction // new

   uvm_active_passive_enum is_active=UVM_ACTIVE;

endclass // agent_config
