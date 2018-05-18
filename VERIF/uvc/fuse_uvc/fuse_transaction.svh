class fuse_transaction extends uvm_sequence_item;
   `uvm_object_utils(fuse_transaction);

   bit WSI[];
   bit [7:0] ADDR;
   bit WSO[];

   function new(string name ="fuse_transaction");
      super.new(name);
   endfunction // new

endclass // Transaction
