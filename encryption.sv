//small endian
//permutation mapping	1,6,3,7,8,5,4,2
//order in array		0,5,2,6,7,4,3,1
//order in decode		3,4,6,2,1,5,0,7
//permutation first then xor
module encryption 
#(parameter N = 8)
(
 input logic clock,
 input logic rst,
 input logic en,
 input logic[N-1:0] 	din,
 output logic[N-1:0] dout,
 output logic		v
 );

logic[N-1:0] 	shift_val;
logic[N-1:0]	xor_val;
logic[N-1:0]	din_ff0;
logic[N-1:0]	din_ff1;
logic[N-1:0]	din_ff2;
logic			edge_flag;
parameter K1 = 8'b0011_1110;
parameter K2 = 8'b0100_1001;
parameter K3 = 8'b0111_1110;

//reg din_ff0 8 bit
always_ff @(posedge clock or rst)begin
if(rst==1'b0)begin
din_ff0	<= 'b0;
end
else begin
din_ff0 <= din ;
end
end

//reg din_ff1 8bit
always_ff  @(posedge clock or negedge rst)begin
if(rst==1'b0)begin
din_ff1 <= 'b0;
end
else begin
din_ff1 <= din_ff0;
    end
end


//reg din_ff2 8bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		din_ff2 <= 'b0;
    end
    else begin
		din_ff2 <= din_ff1;
    end
end

//reg edge_flag
always_comb
begin
	if ((din_ff1 & ~din_ff0)||(~din_ff1 & din_ff0))
		edge_flag = 1;
end
//signal dout 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		dout	<= 	8'b0;
    end
    else begin
		dout <= xor_val;
    end
end

//siginal v 1 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		v <= 1'b0;
    end
    else begin
		if(en == 1'b1 && edge_flag == 1)
		begin
			v <= 1'b1;
		end
		else 
			v <= 1'b0;
    end
end

//reg shift_val 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		shift_val <= 'b0;
    end
    else begin
		if(en == 1'b1 && edge_flag == 1)
		begin
			shift_val <= 	{din_ff1[0],din_ff1[5],din_ff1[2],
							din_ff1[6],din_ff1[7],din_ff1[4],
							din_ff1[3],din_ff1[1]}; 
		end
		else
			shift_val <= shift_val;
    end
end

//reg xor_val 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		xor_val <= 'b0;
    end
    else begin
		if(en == 1'b1 && edge_flag == 1)
		begin
			xor_val <= shift_val^K1^K2^K3;
		end
		else
			xor_val <= xor_val;
    end
end
endmodule

