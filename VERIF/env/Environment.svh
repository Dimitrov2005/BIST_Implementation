class Environment extends uvm_env;
   `uvm_component_utils(Environment);

   env_config env_cfg;
   jtag_agent jtag_agnt;
   fuse_agent fuse_agnt;
   Scoreboard scb;

   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      
			//--------check if env_cfg exist in uvm_config_db ------//
		if(!uvm_config_db#(env_config) :: get
			(this,"","env_cfg",env_cfg))
		begin //---- send error -----//
			`uvm_error("ECNF","Environment config not found");
		end
		
      
		if(jenv_cfg.has_jtag_agent)
		begin
			//-------   SET JTAG AGENT CONFIG   --------//
			uvm_config_db#(jtag_agent_config):: set
				(this,"jtag_agnt*","jtag_agent_cfg",env_cfg.jtag_agent_cfg);
			jtag_agnt=jtag_agent::type_id::create("jtag_agnt",this);
		end
		
		if(env_cfg.has_jtag_scoreboard)
		begin 
			$display("building scoreboard ___________ ");
			scb=Scoreboard::type_id::create("scb",this);
		end
		
		if(env_cfg.has_fuse_agent)
		begin
			//-------   SET FUSE AGENT CONFIG   --------//
			uvm_config_db#(fuse_agent_config):: set
				(this,"fuse_agnt*","fuse_agent_cfg",fuse_env_cfg.fuse_agent_cfg);
			fuse_agnt=fuse_agent::type_id::create("fuse_agnt",this);
		end
		
		if(env_cfg.has_fuse_scoreboard)
		begin 
			$display("building scoreboard ___________ ");
			scb=Scoreboard::type_id::create("scb",this);
		end
  
   endfunction // build_phase 
   
   
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      //agent.aportAgnt.connect(scb.fifo.analysis_export);
      
   endfunction // connect_phase

endclass // Environment
