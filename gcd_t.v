module stimulus;
	
parameter cyc = 10;
parameter delay = 1;
reg clk, rst_n, start;
reg [7:0] a, b;
wire done, error;
wire [7:0] y;
	
gcd gcd01( .CLK(clk), .RST_N(rst_n), .A(a), .B(b), .START(start), .Y(y), .DONE(done), .ERROR(error));

always #(cyc/2) clk = ~clk;

initial 
begin
	$fsdbDumpfile("gcd.fsdb");
	$fsdbDumpvars;
	$monitor($time, " CLK=%b RST_N=%b START=%b A=%d B=%d | DONE=%b Y=%d ERROR=%b",clk, rst_n, start, a, b, done, y, error);
end

initial 
begin
	clk = 1;
	rst_n = 1;
	#(cyc);
	#(delay) rst_n = 0;
	#(cyc*3) rst_n = 1;
	#(cyc*1);
	
	#(cyc) nop;
	
	#(cyc) load; data_in(8'd21, 8'd6);
	#(cyc) nop;
	@(posedge done);
	
	#(cyc) load; data_in(8'd75, 8'd60);
	#(cyc) nop;
	@(posedge done);
	
	#(cyc) load; data_in(8'd96, 8'd48);
	#(cyc) nop;
	@(posedge done);
	
	#(cyc) load; data_in(8'd34, 8'd21);
	#(cyc) nop;
	@(posedge done);
	
	#(cyc) load; data_in(8'd12, 8'd0);
	#(cyc) nop;
	@(posedge done);
	
	#(cyc) nop;
	#(cyc*4);
	$finish;
end

task nop;
begin
	start = 0;
end
endtask

task load;
begin
	start = 1;
end
endtask

task data_in;
input [7:0] data1, data2;
begin
	a = data1;
	b = data2;
end
endtask

endmodule 

