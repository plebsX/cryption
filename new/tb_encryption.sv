`timescale 10ps/1ps
module tb_encryption;
encryption d0 (.*);
parameter N = 8;
logic clock  ;
logic rst;

logic en;
logic [N-1:0] din;
logic [N-1:0] dout;


logic [4:0]		shift;
logic [1:0]		direction;	
logic v;

parameter CYCLE    = 20;


parameter RST_TIME = 3 ;


initial begin
    clock = 0;
    forever #(CYCLE/2)    clock=~clock;
end


initial begin
    rst = 1;
    #2;
    rst= 0;
    #(CYCLE*RST_TIME);
   	rst= 1;
end


initial begin
    #1;
    din= 0;
    #(10*CYCLE);
   	din = 8; 
end

initial begin
	#1;
	en = 0;
	#(10*CYCLE);
	en = 1;
end


initial begin
	#1;
	direction = 2'b00;
	#(60*CYCLE)
	direction = 2'b10;
	#(60*CYCLE)
	direction = 2'b01;
end

initial begin
	#1;
	shift = 'b01;
	#(10*CYCLE);
	shift = 5;
	#(10*CYCLE);
	shift = 10;
	#(10*CYCLE);
	shift = 15;
	#(10*CYCLE);
	shift = 20;
	#(10*CYCLE);
	shift = 25;
	#(10*CYCLE);
	shift = 26;
	
	#(10*CYCLE);
	shift = 5;
	#(10*CYCLE);
	shift = 10;
	#(10*CYCLE);
	shift = 15;
	#(10*CYCLE);
	shift = 20;
	#(10*CYCLE);
	shift = 25;
	#(10*CYCLE);
	shift = 26;
end
endmodule

