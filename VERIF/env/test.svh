class test extends uvm_test; 
   `uvm_component_utils(test)
     

     
      env_config env_cfg;
      jtag_sequence jtag_seq;
	  fuse_sequence fuse_seq;
      jtag_agent_config jtag_agent_cfg;
	  fuse_agent_config fuse_agent_cfg;
      Environment env;
	 
	 bit [SIZE_TDR1-1:0] WSI1='b0;
	 bit [7:0]  ADDR1=ADDR_TDR1;
	 bit [SIZE_TDR2-1:0] WSI2='b0;
	 bit [7:0]  ADDR2=ADDR_TDR2;
	 bit [SIZE_TDR1-1:0]	    DEFTDR1=DEF_VAL_TDR1;
	 bit [SIZE_TDR2-1:0]	    DEFTDR2=DEF_VAL_TDR2;
	 bit [32:0]	    CAPTDR2=8'hca;
	 bit 	    ROTDR2=RO_TDR2;
	 bit 	    ROTDR1=RO_TDR1;

	 
      function new(string name, uvm_component parent);
	 super.new(name,parent);
      endfunction // new

     function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		env_cfg=env_config::type_id::create("env_cfg",this);
		jtag_agent_cfg=jtag_agent_config::type_id::create("jtag_agent_cfg",this);
		fuse_agent_cfg=fuse_agent_config::type_id::create("fuse_agent_cfg",this);
	 
		if(!uvm_config_db#(virtual jtag_iface)::get
            (this,"","jtag_viface",jtag_agent_cfg.jtag_viface))
		begin
			`uvm_error("TINF","base_test : jtag_iface not found");
		end
		
		if(!uvm_config_db#(virtual fuse_iface)::get
            (this,"","jtag_viface",fuse_agent_cfg.fuse_viface))
		begin
			`uvm_error("TINF","base_test : fuse_iface not found");
		end
		
		env_cfg.jtag_agent_cfg=jtag_agent_cfg;  
		env_cfg.fuse_agent_cfg=fuse_agent_cfg;
		
		uvm_config_db#(env_config)::set
		(this,"*","env_cfg",env_cfg);
		
		env=Environment::type_id::create("env",this);
	 
      endfunction // build_phase


      task run_phase(uvm_phase phase);
	 
			jtag_seq=jtag_sequence::type_id::create("jtag_seq",this);
			jtag_seq.num=1;
	 //override the number of transactions
			phase.raise_objection(this);
	    begin
	       {>>17{jtag_seq.WSI}}=17'b0;
	       jtag_seq.ADDR=ADDR1;
	       {>>{env.jtag_agnt.jtag_mon.DEFTDR}}=DEFTDR1;
	       env.jtag_agnt.jtag_mon.RO=ROTDR1;
	       jtag_seq.start(env.jtag_agnt.jtag_seq);
	    end
	    begin
	       {>>17{jtag_seq.WSI}}={17{1'b1}};
	       jtag_seq.ADDR=ADDR1;
	       jtag_seq.start(env.jtag_agnt.jtag_seq);
	    end
	    begin
	       {>>17{jtag_seq.WSI}}=17'b0;
	       jtag_seq.ADDR=ADDR1;
	       jtag_seq.start(env.jtag_agnt.jtag_seq);
	    end
	    begin
	       {>>33{jtag_seq.WSI}}=33'b0;
	       jtag_seq.ADDR=ADDR2; 
	       env.jtag_agnt.jtag_mon.RO=ROTDR2;
		   {>>{env.jtag_agnt.jtag_mon.DEFTDR}}=DEFTDR2;
	       {>>{env.jtag_agnt.jtag_mon.CAPTDR}}=CAPTDR2;
	       jtag_seq.start(env.jtag_agnt.jtag_seq);
	    end 
	    begin
	       {>>33{jtag_seq.WSI}}={33{1'b1}};
	       jtag_seq.ADDR=ADDR2;
	       jtag_seq.start(env.jtag_agnt.jtag_seq);
	    end
	    begin
	       {>>33{jtag_seq.WSI}}=33'b0;
	       jtag_seq.ADDR=ADDR2;
	       jtag_seq.start(env.jtag_agnt.jtag_seq);
	    end 
	    phase.drop_objection(this);
      endtask


   endclass
