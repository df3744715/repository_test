module gcd(
	CLK,
	RST_N,
	A,
	B,
	START,
	Y,
	DONE,
	ERROR
);

input CLK,RST_N,START;
input [7:0]A,B;
output reg [7:0]Y;
output reg DONE,ERROR;

reg [7:0] reg_a, reg_b, data_a, data_b;
reg [7:0] diff;
reg error_next;
reg [1:0] state, state_next;

wire found, err, swap;

parameter [1:0] IDLE = 2'b00;
parameter [1:0] CALC = 2'b01;
parameter [1:0] FINISH = 2'b10;

assign found = (reg_a==reg_b || A==B) ? 1:0;
assign swap = (reg_b > reg_a) ? 1:0;

always @* 
begin
	if (swap) 
	begin
		data_a = reg_b;
		data_b = reg_a;
	end 
	else 
	begin
		data_a = reg_a;
		data_b = reg_b;
	end
end

always @* 
begin
	diff = data_a-data_b;
end

always @(posedge CLK or negedge RST_N)
begin
	if (!RST_N) 
	begin
		Y = 0;
	end 
	else if (found) 
	begin
		Y = data_a;
	end
	else
	begin
		Y = 0;
	end
end

always @(posedge CLK or negedge RST_N)
begin
	if (!RST_N) 
	begin
		reg_a = 0;
		reg_b = 0;
	end 
	else if (START) 
	begin
		reg_a = A;
		reg_b = B;
	end 
	else 
	begin
		reg_a = diff;
		reg_b = data_b;
	end
end

always @(posedge CLK or negedge RST_N) 
begin
	if (RST_N == 0) 
	begin
		state <= IDLE;
		ERROR <= 0;
	end 
	else 
	begin
		state <= state_next;
		ERROR <= error_next;
	end
end

always @* 
begin
	case (state)
		IDLE: 
		begin
			DONE = 0;
			if (START) 
			begin
				state_next = CALC;
				error_next = (A==0 || B==0) ? 1'b1:0;
			end 
			else 
			begin
				state_next = IDLE;
				error_next = 0;
			end
		end
		CALC: 
		begin
			DONE = 0;
			if(found || ERROR)
			begin
				state_next = FINISH;
				error_next = ERROR;
			end
			else if(!found && !ERROR)
			begin
				state_next = CALC;
				error_next = ERROR;
			end
		end
		FINISH: 
		begin
			DONE = 1;
			state_next = IDLE;
			error_next = 0;
		end
		default: 
		begin
			DONE = 0;
			state_next = IDLE;
			error_next = 0;
		end
	endcase
end

endmodule 

