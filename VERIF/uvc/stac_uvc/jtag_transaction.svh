class jtag_transaction extends uvm_sequence_item;
   `uvm_object_utils(jtag_transaction);

   bit WSI[];
   bit [7:0] ADDR;
   bit WSO[];

   function new(string name ="");
      super.new(name);
   endfunction // new

endclass // Transaction
