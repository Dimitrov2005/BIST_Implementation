class Environment extends uvm_env;
   `uvm_component_utils(Environment);

   env_config env_cfg;
   Agent agent;
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
      
      if(env_cfg.has_agent)
	begin
	   //-------set agent 1 config--------//
	   uvm_config_db#(agent_config):: set
	     (this,"agent*","agent_cfg",env_cfg.agent_cfg);
	   agent=Agent::type_id::create("agent",this);
	end
      if(env_cfg.has_scoreboard)begin 
	 $display("building scoreboard ___________ ");
	 scb=Scoreboard::type_id::create("scb",this);
      end
   endfunction // build_phase 
   
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      //agent.aportAgnt.connect(scb.fifo.analysis_export);
      
   endfunction // connect_phase

endclass // Environment
