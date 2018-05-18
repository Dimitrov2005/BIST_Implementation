class fuse_agent extends uvm_agent;
   `uvm_component_utils(fuse_agent);

   fuse_agent_config fuse_agent_cfg;
   fuse_driver fuse_drv;
   fuse_monitor fuse_mon;
   fuse_sequencer fuse_seq;
   uvm_analysis_port#(fuse_transaction)aportAgnt;
 

   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      aportAgnt=new("aportAgnt",this);

      if(!uvm_config_db#(fuse_agent_config)::get
	 (this,"","fuse_agent_cfg",fuse_agent_cfg))
		begin
			`uvm_error("fuse_agent","agent_config not found");
		end
		
     fuse_drv=fuse_driver::type_id::create("fuse_drv",this);//build others with factory
     fuse_seq=fuse_sequencer::type_id::create("fuse_seq",this);
     fuse_mon=fuse_monitor::type_id::create("fuse_mon",this);
	 fuse_mon.drvShiftCnt=fuse_drv.drvShiftCnt;
   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      fuse_mon.fuse_viface=fuse_agent_cfg.fuse_viface;
      fuse_mon.aportMon.connect(aportAgnt);
      fuse_drv.seq_item_port.connect(fuse_seq.seq_item_export);
      fuse_drv.fuse_viface=fuse_agent_cfg.fuse_viface;
   endfunction; // connect_phase

   endclass // Agent
