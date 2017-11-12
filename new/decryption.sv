//small endian
//permutation mapping	1,6,3,7,8,5,4,2
//order in array		0,5,2,6,7,4,3,1
//order in decode		3,4,6,2,1,5,0,7
//xor first then permutation

//add shift cipher
//direction 10 shift right 
//direction 01 shift left
//direction 00 don't shift 
//shift_num

module decryption 
#(parameter N = 8)
(
    input logic clock    ,
    input logic rst,
	input logic en,
	input logic[1:0]	direction,
	input logic[4:0]	shift,
	input logic [N-1:0] din,
    output logic [N-1:0] dout,
	output logic v
);

logic[N-1:0]	shift_de_val;
logic[N-1:0]	cipher_de_val;
logic[N-1:0]	xor_de_val;
logic[1:0]		xor_cnt;
logic[4:0]		shift_num;

logic[N-1:0]	din_ff0;
logic[N-1:0]	din_ff1;
parameter K1 = 8'b0011_1110;
parameter K2 = 8'b0100_1001;
parameter K3 = 8'b0111_1110;
parameter UP_A = 8'b0100_0001;
parameter UP_Z = 8'b0101_1010;
parameter LOW_A	= 8'b0110_0001;
parameter LOW_Z = 8'b0111_1010; 

parameter CNT_MAX = 3;

always_comb
begin
	shift_num = shift %26;
end
//reg din_ff0
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		din_ff0 <= 'b0;
    end
    else begin
		din_ff0 <= din;
    end
end
//reg din_ff1
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		din_ff1 <= 'b0;
    end
    else begin
		din_ff1 <= din_ff0;
    end
end

//signal dout 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		dout	<=	8'b0;
    end
    else begin
		if(en == 1'b1)	
			dout	<= 	cipher_de_val;
		else
			dout	<=	dout;
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
					xor_de_val <= K1^din_ff1;
				end
				1:begin
					xor_de_val <= K2^din_ff1;
				end
				2:begin
					xor_de_val <= K3^din_ff1;
				end
			endcase
		end
		else 
			xor_de_val <= din_ff1;
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
//reg cipher_de_val 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
    	cipher_de_val <= 'b0;
	end
    else begin
		if(en == 1'b1)
		begin

			if(direction == 2'b00)
				cipher_de_val <= shift_de_val ;
			else if(direction == 2'b10)//de left shift
			begin
				if(shift_de_val >= UP_A && shift_de_val <= UP_Z)
				begin
					cipher_de_val <= ((shift_de_val -shift_num) >= UP_A)? shift_de_val -shift_num : UP_Z - (UP_A-(shift_de_val -shift_num)-1);
				end
				if(shift_de_val >= LOW_A && shift_de_val <= LOW_Z)
				begin 
					cipher_de_val <= ((shift_de_val -shift_num) >= LOW_A)? shift_de_val -shift_num : LOW_Z - (UP_A-(shift_de_val -shift_num)-1);
				end
			end
			else if(direction == 2'b01)//de right shift
			begin
				if(shift_de_val >= UP_A && shift_de_val <= UP_Z)
				begin
					cipher_de_val <= ((shift_de_val +shift_num) <= UP_Z)? shift_de_val +shift_num : UP_A + (shift_de_val +shift_num-UP_Z -1);
				end
				if(shift_de_val >= LOW_A && shift_de_val <= LOW_Z)
				begin 
					cipher_de_val <= ((shift_de_val +shift_num) <= LOW_Z)? shift_de_val +shift_num : LOW_A + (shift_de_val +shift_num-LOW_Z -1);
				end
			end
			else
				cipher_de_val <= shift_de_val ;
		end
		else
			cipher_de_val <= cipher_de_val;
    end
end

endmodule
