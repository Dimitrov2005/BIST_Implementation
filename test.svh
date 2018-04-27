class test extends uvm_test; 
   `uvm_component_utils(test)
     

     
      env_config env_cfg;
      Sequence seq;
      agent_config agent_cfg;
      Environment env;
	 
	 bit [SIZE_TDR1-1:0] WSI1='b0;
	 bit [7:0]  ADDR1=ADDR_TDR1;
	 bit [SIZE_TDR2-1:0] WSI2='b0;
	 bit [7:0]  ADDR2=ADDR_TDR2;
	 bit [SIZE_TDR1-1:0]	    DEFTDR1=DEF_VAL_TDR1;
	 bit [32:0]	    CAPTDR2=8'hca;
	 bit 	    ROTDR2=RO_TDR2;
	 bit 	    ROTDR1=RO_TDR1;

	 
      function new(string name, uvm_component parent);
	 super.new(name,parent);
      endfunction // new

      function void build_phase(uvm_phase phase);
	 super.build_phase(phase);

	 env_cfg=env_config::type_id::create("env_cfg",this);
	 agent_cfg=agent_config::type_id::create("agent_cfg",this); 
	 if(!uvm_config_db#(virtual iface)::get
            (this,"","viface",agent_cfg.viface))
	   begin
	      `uvm_error("TINF","base_test iface1 not found");
	   end
	 env_cfg.agent_cfg=agent_cfg;  
	 uvm_config_db#(env_config)::set
	   (this,"*","env_cfg",env_cfg);
	 env=Environment::type_id::create("env",this);
	 
      endfunction // build_phase


      task run_phase(uvm_phase phase);
	 
			seq=Sequence::type_id::create("seq",this);
			seq.num=1;
	 //override the number of transactions
			phase.raise_objection(this);
	    begin
	       {>>17{seq.WSI}}=17'b0;
	       seq.ADDR=ADDR1;
	       {>>{env.agent.mon.DEFTDR}}=DEFTDR1;
	       env.agent.mon.RO=ROTDR1;
	       seq.start(env.agent.seq);
	    end
	    begin
	       {>>17{seq.WSI}}={17{1'b1}};
	       seq.ADDR=ADDR1;
	       seq.start(env.agent.seq);
	    end
	    begin
	       {>>17{seq.WSI}}=17'b0;
	       seq.ADDR=ADDR1;
	       seq.start(env.agent.seq);
	    end
	    begin
	       {>>33{seq.WSI}}=33'b0;
	       seq.ADDR=ADDR2; 
	       env.agent.mon.RO=ROTDR2;
	       {<<{env.agent.mon.CAPTDR}}=CAPTDR2;
	       seq.start(env.agent.seq);
	    end 
	    begin
	       {>>33{seq.WSI}}={33{1'b1}};
	       seq.ADDR=ADDR2;
	       seq.start(env.agent.seq);
	    end
	    begin
	       {>>33{seq.WSI}}=33'b0;
	       seq.ADDR=ADDR2;
	       seq.start(env.agent.seq);
	    end 
	    phase.drop_objection(this);
      endtask


   endclass
