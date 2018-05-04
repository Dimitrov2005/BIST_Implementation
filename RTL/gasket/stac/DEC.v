module dec(input 
	   [7:0]x, // 
	   output reg
	   EN1,
	   EN2
	   );

   always @(x)
     if(x==8'h45) // address of TDR1 in binary
       begin
	  EN1=1;
	  EN2=0;
       end
     else if (x==8'h77) // address of TDR2
       begin
	  EN1=0;
	  EN2=1;
       end
     else
       begin
	  EN1=0;
	  EN2=0;
       end
   
endmodule // dec
