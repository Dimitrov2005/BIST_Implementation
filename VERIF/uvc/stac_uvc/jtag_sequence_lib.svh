class jtag_sequence extends uvm_sequence#(jtag_transaction);
   `uvm_object_utils(jtag_sequence)
     // addr1=8'h45,17bit size RW
     // addr2=8'h77;33 bit size R
      
     int num=1;
     bit WSI[];
     bit [7:0] ADDR;
     jtag_transaction tr; 
   
      function new(string name="");
	 super.new(name);
      endfunction // new

      task body ();
	 repeat(num)
	   begin
	      tr=new("tr");
	      start_item(tr);
	      begin
			tr.WSI=WSI;
			tr.ADDR=ADDR;
	      end
	      
	      finish_item(tr);
	      
	   end
      endtask // body
   endclass // Sequence
