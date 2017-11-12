module top_level
#(parameter N = 8)
(
    input logic clock    ,
    input logic rst,
	input logic en,
	input logic[1:0] 	direction,
	input logic[4:0]	shift,
	input logic[N-1:0]	din, 	
	output logic v,
    output logic[N-1:0] dout
);

logic	en_v;
logic[N-1:0]	out_in;

encryption u_en(
	.clock		(clock),
	.rst		(rst),
	.en			(en),
	.direction	(direction),
	.shift		(shift),
	.din		(din),
	.v			(en_v),
	.dout		(out_in)
);

decryption u_de(
	.clock		(clock),
	.rst		(rst),
	.en			(en_v),
	.direction	(direction),
	.shift		(shift),
	.din		(out_in),
	.dout		(dout),
	.v			(v)
);

endmodule

