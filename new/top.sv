module top_level
(#parameter N = 8)
(
    input logic clock    ,
    input logic rst,
	input logic en,
	input logic[1:0] 	direction,
	input logic[4:0]	shift_num,
	input logic[N-1]	din, 	
	output logic v,
    output logic[N-1:0] dout
);

logic	en_v;
logic[N-1]	out_in;

encryption u_en(
	.clock		(clock),
	.rst		(rst),
	.en			(en),
	.direction	(direction),
	.shift_num	(shift_num),
	.din		(din),
	.en_v		(v),
	.out_in		(dout)
);

decryption u_de(
	.clock		(clock),
	.rst		(rst),
	.en_v		(en),
	.direction	(direction),
	.shift_num	(shift_num),
	.out_in		(din),
	.dout		(dout),
	.v			(v)
);

endmodule

