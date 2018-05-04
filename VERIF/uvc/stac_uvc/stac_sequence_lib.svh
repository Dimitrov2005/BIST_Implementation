class Sequence extends uvm_sequence#(Transaction);
   `uvm_object_utils(Sequence)
     // addr1=8'h45,17bit size RW
     // addr2=8'h77;33 bit size R
      
     int num=1;
     bit WSI[];
     bit [7:0] ADDR;
     Transaction tr; 
   
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
