// Code your testbench here
// or browse Examples
module test_snake();
  reg clk,reset,l,r,u,d;
  wire VGA_clk,update_clock;
  wire [4:0] red;
  wire [5:0] green;
  wire [4:0] blue;
  wire h_sync, v_sync;
  
  Snake s1(.red(red), .green(green), .blue(blue), .h_sync(h_sync), .v_sync(v_sync), .clk(clk), .reset(reset), .l(l), .r(r), .u(u), .d(d));

  always
    #1 clk = ~clk;
  
  assign VGA_clk = VGA_clk;
  assign update_clock = update_clock; 
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(1,test_snake);
  	  clk = 0; reset = 0;
  	  l=1;r=0;u=0;d=0; #30;
      l=0;r=1;u=0;d=0; #30;
      l=0;r=0;u=1;d=0; #30;
      l=0;r=0;u=0;d=1; #30;
      $finish;
    end
endmodule
  
  
