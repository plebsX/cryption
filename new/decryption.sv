//small endian
//permutation mapping	1,6,3,7,8,5,4,2
//order in array		0,5,2,6,7,4,3,1
//order in decode		3,4,6,2,1,5,0,7
//xor first then permutation
module decryption 
#(parameter N = 8)
(
    input logic clock    ,
    input logic rst,
	input logic en,
	input logic [N-1:0] din,
    output logic [N-1:0] dout,
	output logic v
);

logic[N-1:0]	shift_de_val;
logic[N-1:0]	xor_de_val;
logic[1:0]		xor_cnt;

parameter K1 = 8'b0011_1110;
parameter K2 = 8'b0100_1001;
parameter K3 = 8'b0111_1110;

parameter CNT_MAX = 3;

//signal dout 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		dout	<=	8'b0;
    end
    else begin
		dout	<= shift_de_val;
    end
end

//signal v 1 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		v <= 1'b0;
    end
    else begin
		if(en == 1'b1)
		begin
			v <= 1'b1;
		end
		else 
			v <= 1'b0;
    end
end

//reg xor_cnt 2bit 0 1 2
always_ff  @(posedge clock or negedge rst)begin
    if(rst == 1'b0)begin
		xor_cnt <= 'b0;
    end
    else begin
		if(en == 1'b1)
		begin
			if(xor_cnt == CNT_MAX - 1)
				xor_cnt <= 0;
			else
				xor_cnt <= xor_cnt + 1;
		end
		else
			xor_cnt <= xor_cnt;
    end
end


//reg xor_de_val 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		xor_de_val <= 'b0;	
    end
    else begin
		if(en == 1'b1)
		begin
			unique case(xor_cnt)
				0:begin
					xor_de_val <= K1^din;
				end
				1:begin
					xor_de_val <= K2^din;
				end
				2:begin
					xor_de_val <= K3^din;
				end
		end
		else 
			xor_de_val <= din;
    end
end

//reg shift_de_val 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
    	shift_de_val <= 'b0;
	end
    else begin
		if(en == 1'b1)
		begin
			shift_de_val <= {xor_de_val[3],xor_de_val[4],xor_de_val[6],
							xor_de_val[2],xor_de_val[1],xor_de_val[5],
							xor_de_val[0],xor_de_val[7]};
		end
		else 
			shift_de_val <= xor_de_val;
    end
end

endmodule
