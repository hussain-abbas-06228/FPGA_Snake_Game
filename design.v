//Snake Game
module Snake(red,green,blue,h_sync,v_sync,clk,reset,l,r,u,d);

  input clk, reset, l, r, u, d;
  output [4:0] red, blue;
  reg [4:0] red, blue;
  output [5:0] green;
  reg [5:0] green;
  output h_sync, v_sync;

  wire VGA_clk, update_clock, displayArea;
  wire[9:0] xCount;
  wire[9:0] yCount;
  wire[3:0] direction;
  wire[9:0] randX;
  wire[9:0] randomX;
  wire[8:0] randY;
  wire[8:0] randomY;
  reg apple;
  reg border;
  wire R,G,B;
  reg snake;
  reg gameOver;
  reg head;
  reg [9:0] appleX;
  reg [9:0] appleY;
  reg inX,inY;
  reg [9:0] snakeX;
  reg [8:0] snakeY;

  ClockDivider divider(clk, VGA_clk);
  UpdateClock upd(clk, update_clock);
  VGAgenerator vga(VGA_clk, xCount, yCount, displayArea, h_sync, v_sunc);
  Random ran(VGA_clk, randX, randY);
  ButtonInput but(clk,l,r,u,d,direction);

  assign randomX = randX;
  assign randomY = randY;

  initial
    begin
      snakeX = 10'd20;
      snakeY = 9'd20;
    end

  always @(posedge VGA_clk)
    begin
      inX <= (xCount > appleX & xCount < (appleX + 50));
      inY <= (yCount > appleY & yCount < (appleY + 50));
      apple <= inX & inY;
    end

  always @(posedge VGA_clk)
    begin
      border <= ((((xCount >= 0) & (xCount < 15) & ((yCount >= 220) & (yCount < 280))) | (xCount >= 360) & (xCount < 641) & ((~yCount >= 220) & (~yCount<280))) | ((yCount >= 0) & (yCount <15) | (yCount >= 465) & (yCount < 481)));
    end

  always@(posedge VGA_clk)
    begin
      if(reset | gameOver)
        begin
          appleX = 350;
          appleY = 300;
        end
      if(apple & head)
        begin
          appleX <= randX;
          appleY <= randY;
        end
    end


  always@(posedge update_clock)
    begin
      if(direction == 4'b0001) begin snakeX = snakeX - 5; end
      else if (direction == 4'b0010) begin snakeX = snakeX + 5; end
      if(direction == 4'b0100) begin snakeY = snakeY - 5; end
      else if (direction == 4'b1000) begin snakeY = snakeY + 5; end
    end

  always@(posedge VGA_clk)
    begin 
      head <= (xCount > snakeX & xCount < (snakeX+10)) & (yCount > snakeY & yCount < (snakeY+10));
    end

  always @(posedge VGA_clk)
    begin
      if((border &(head)) | reset) gameOver<=1;
      else gameOver<=0;
    end

  assign R = (displayArea & (apple));
  assign G = (displayArea & (head));
  assign B = (displayArea & (border));

  always@(posedge VGA_clk)
    begin
      red = {5{R}};
      green = {6{G}};
      blue = {5{B}};
    end
endmodule
//________________________________________//

module ClockDivider(clk, VGA_clk);
  output VGA_clk;
  reg VGA_clk;
  input clk;

  parameter check = 4;
  parameter a = 0;

  always@(posedge clk)
    begin
      if (a<check)
        begin
          a <= a + 1;
          VGA_clk <= 0;
        end
      else
        begin
          a <= 0;
          VGA_clk <= 1;
        end
    end
endmodule
//___________________________________________________________
module UpdateClock(clk, update_clk);
  output update_clk;
  reg update_clk;
  input clk;

  reg [21:0] check;

  always @ (posedge clk)
    begin
      if(check < 4000000)
        begin
          check <= check + 1;
          update_clk <= 0;
        end
      else
        begin
          check <= 0;
          update_clk <= 1;
        end
    end
endmodule

//_________________________________________________________________

module VGAgenerator(VGA_clk, xCount, yCount, displayArea, VGA_hSync, VGA_vSync);
  input VGA_clk;
  output [9:0] xCount, yCount;
  reg [9:0] xCount, yCount;
  output displayArea;
  reg displayArea;
  output VGA_hSync, VGA_vSync;

  reg p_hSync, p_vSync;

  parameter porchHF = 640;
  parameter syncH = 656;
  parameter porchHB = 752;
  parameter maxH = 800;

  parameter porchVF = 480;
  parameter syncV = 490;
  parameter porchVB = 492;
  parameter maxV = 525;

  always@(posedge VGA_clk)
    begin
      if(xCount == maxH)
        xCount <= 0;
      else
        xCount <= xCount + 1'b1;
    end

  always@(posedge VGA_clk)
    begin
      displayArea <= ((xCount < porchHF) && (yCount < porchVF));
    end


  always@(posedge VGA_clk)
    begin
      p_hSync <= ((xCount >= syncH) && (xCount < porchHB));

      p_vSync <= ((yCount >= syncV) && (yCount < porchVB));
    end

  assign VGA_vSync = ~p_vSync;
  assign VGA_hSync = ~p_hSync;

endmodule
//______________________________________________________________
module Random(VGA_clk, randX, randY);
  input VGA_clk;
  output [9:0]randX;
  reg [9:0]randX;
  output [8:0]randY;
  reg [8:0]randY;

  parameter i=0;
  parameter j = 450;

  always @ (posedge VGA_clk)
    begin
      if (i<610)
        i <= i+1'b1;
      else
        i <= 10'b0;
    end
  always @ (posedge VGA_clk)
    begin
      if (j>0)
        j <= j-1'b1;
      else
        j <= 10'd480;
    end
  always @ (i & j)
    begin
      randX <= i;
      randY <= j;
    end
endmodule
//___________________________________________________
//Button input
module ButtonInput (clk,l,r,u,d,direction);
  input clk,l,r,u,d;
  output [3:0] direction;
  reg [3:0] direction;

  always@(posedge clk)
    begin
      if(l == 1) begin
        direction <= 4'b0001; //left
      end
      else if(r == 1) begin
        direction <= 4'b0010; //right
      end
      else if(u== 1) begin
        direction <= 4'b0100; //up
      end
      else if(d == 1) begin
        direction <= 4'b1000; //down
      end
      else begin
        direction <= direction; //keep last input
      end
    end
endmodule





