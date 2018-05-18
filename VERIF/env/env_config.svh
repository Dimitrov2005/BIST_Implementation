class env_config extends uvm_object;

  `uvm_object_utils(env_config)

   bit    has_jtag_agent=1;
   bit 	 has_jtag_scoreboard=0;
   bit    has_fuse_agent=1;
	bit 	 has_fuse_scoreboard=0;
	
   jtag_agent_config jtag_agent_cfg;
   fuse_agent_config fuse_agent_cfg;
   
   function new(string name="");
      super.new(name);
   endfunction // new

endclass // env_config
