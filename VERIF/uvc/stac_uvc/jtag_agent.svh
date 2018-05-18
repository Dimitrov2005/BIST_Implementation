class jtag_agent extends uvm_agent;
   `uvm_component_utils(jtag_agent);

   jtag_agent_config jtag_agent_cfg;
   jtag_driver jtag_drv;
   jtag_monitor jtag_mon;
   jtag_sequencer jtag_seq;
   uvm_analysis_port#(jtag_transaction)aportAgnt;
 

   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      aportAgnt=new("aportAgnt",this);

      if(!uvm_config_db#(jtag_agent_config)::get
		(this,"","agent_cfg",jtag_agent_cfg))
		begin
			`uvm_error("fifo_agent","agent_config not found");
		end

     jtag_drv=jtag_driver::type_id::create("jtag_drv",this);//build others with factory
     jtag_seq=jtag_sequencer::type_id::create("jtag_seq",this);
     jtag_mon=jtag_monitor::type_id::create("jtag_mon",this);
	 mon.drvShiftCnt=drv.drvShiftCnt;
   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      jtag_mon.jtag_viface=jtag_agent_cfg.jtag_viface;
      jtag_mon.aportMon.connect(aportAgnt);
      jtag_drv.seq_item_port.connect(seq.seq_item_export);
      jtag_drv.jtag_viface=jtag_agent_cfg.jtag_viface;
   endfunction; // connect_phase
endclass // Agent
