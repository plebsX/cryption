//small endian
//permutation mapping	1,6,3,7,8,5,4,2
//order in array		0,5,2,6,7,4,3,1
//order in decode		3,4,6,2,1,5,0,7
//permutation first then xor

//add shift cipher
//direction 10 shift right 
//direction 01 shift left
//direction 00 don't shift 
//shift_num

module encryption 
#(parameter N = 8)
(
    input logic clock,
    input logic rst,
	input logic en,
	input logic[1:0] 	direction,
	input logic[4:0]	shift,
	input logic[N-1:0] 	din,
    output logic[N-1:0] dout,
	output logic		v
);

logic[N-1:0] 	shift_val;
logic[N-1:0]	cipher_val;
logic[N-1:0]	xor_val;
logic[1:0]		xor_cnt;
logic[4:0]		shift_num;
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
	shift_num = shift % 26;
end
 
//signal dout 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		dout	<= 	8'b0;
    end
    else begin
		if(en == 1'b1)
			dout <= xor_val;
		else
			dout <= dout;
    end
end

//siginal v 1 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		v <= 1'b0;
    end
    else begin
		if(en == 1'b1 )
		begin
			v <= 1'b1;
		end
		else 
			v <= 1'b0;
    end
end
//reg cipher_val 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
    	cipher_val <= 'b0;
	end
    else begin
		if(en == 1'b1)
		begin
			if(direction == 2'b00)
				cipher_val <= din;
			else if(direction == 2'b01)//left shift
			begin
				if(din >= UP_A && din <= UP_Z)
				begin
					cipher_val <= ((din-shift_num) >= UP_A)? din-shift_num : UP_Z - (UP_A-(din-shift_num)-1);
				end
				if(din >= LOW_A && din <= LOW_Z)
				begin 
					cipher_val <= ((din-shift_num) >= LOW_A)? din-shift_num : LOW_Z - (UP_A-(din-shift_num)-1);
				end
			end
			else if(direction == 2'b10)//right shift
			begin
				if(din >= UP_A && din <= UP_Z)
				begin
					cipher_val <= ((din+shift_num) <= UP_Z)? din+shift_num : UP_A + (din+shift_num-UP_Z -1);
				end
				if(din >= LOW_A && din <= LOW_Z)
				begin 
					cipher_val <= ((din+shift_num) <= LOW_Z)? din+shift_num : LOW_A + (din+shift_num-LOW_Z -1);
				end
			end
			else
				cipher_val <= din;
		end
		else
			cipher_val <= cipher_val;
    end
end

//reg shift_val 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		shift_val <= 'b0;
    end
    else begin
		if(en == 1'b1 )
		begin
			shift_val <= 	{
								cipher_val[0],cipher_val[5],cipher_val[2],
								cipher_val[6],cipher_val[7],cipher_val[4],
								cipher_val[3],cipher_val[1]
							}; 
		end
		else
			shift_val <= shift_val;
    end
end

//reg xor_cnt 2bit 0 1 2
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		xor_cnt <= 'b0;
    end
    else begin
		if(en == 1'b1)
		begin
			if(xor_cnt == CNT_MAX -1)
				xor_cnt <= 0;
			else
				xor_cnt <= xor_cnt + 1;	
		end
		else
			xor_cnt <= xor_cnt;
    end
end


//reg xor_val 8 bit
always_ff  @(posedge clock or negedge rst)begin
    if(rst==1'b0)begin
		xor_val <= 'b0;
    end
    else begin
		if(en == 1'b1 )
		begin
			unique case (xor_cnt)
				0:begin
					xor_val <= shift_val^ K1;	
				end

				1:begin
					xor_val <= shift_val^ K2;
				end
				
				2:begin
					xor_val <= shift_val^ K3;
				end
			endcase
		end
		else
			xor_val <= xor_val;
    end
end
endmodule

