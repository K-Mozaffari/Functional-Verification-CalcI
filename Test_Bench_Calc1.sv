
`timescale 1ns / 1ns

module TestBench_Calc1;

reg        c_clk;
reg [7:0]  reset=0;
logic [3:0]  req_cmd[0:3] ;
logic [31:0] req_datain[0:3];
logic [1:0]  resp_out[0:3];
logic [31:0] data_out[0:3];

integer error_count_resp=0;
integer error_count_dataout=0; 
integer correct_count_resp=0;
integer correct_count_dataout=0;  
integer counter_clock;
integer correct_reset=0,error_reset=0;


integer  pri[4]='{2,0,1,3};
integer r;
integer e;
integer j;
integer prt[4];
integer Nsc=1;
bit [1:0] pr[11];
bit [1:0] a=2'b00;


calc1_top DUT(
		.c_clk(c_clk),
		.reset(reset),
		.req1_cmd_in(req_cmd[0]),
		.req1_data_in(req_datain[0]),
		.req2_cmd_in(req_cmd[1]),
		.req2_data_in(req_datain[1]),
		.req3_cmd_in(req_cmd[2]),
		.req3_data_in(req_datain[2]),
		.req4_cmd_in(req_cmd[3]),
		.req4_data_in(req_datain[3]),
		
		.out_resp1(resp_out[0]),
		.out_data1(data_out[0]),
		.out_resp2(resp_out[1]),
		.out_data2(data_out[1]),
		.out_resp3(resp_out[2]),
		.out_data3(data_out[2]),
		.out_resp4(resp_out[3]),
		.out_data4(data_out[3]),
		.scan_in(),
		.error_found(),
		.scan_out(),
		 .a_clk(),
		 . b_clk()	
		);

enum logic [3:0] {ADD=1,SUB=2,SH_L=5,SH_R=6,NOP=0} opcode;
typedef struct 
{
logic [3:0] opc1;
logic [3:0] opc2;
logic [31:0] data1 ;
logic [31:0] data2;
logic [31:0] data_o;
logic [1:0] resp_o;
} data_alu;



data_alu T2[4][4]='{
		'{
		 '{ADD,NOP,32'hA,32'h4,32'hE,2'b01},
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10},
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10},
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10}
		},
		'{
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10},
		 '{ADD,NOP,32'hA,32'h4,32'hE,2'b01},
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10},
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10}
		},
		'{
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10},
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10},
		 '{ADD,NOP,32'hA,32'h4,32'hE,2'b01},
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10}
		},
		'{
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10},
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10},
		 '{NOP,NOP,32'h0,32'h0,32'h0,2'b10},
		 '{ADD,NOP,32'hA,32'h4,32'hE,2'b01}
		}

};
		
data_alu T3 [3]='{
		  '{SUB,NOP,32'hA,32'h4,32'h6,2'b01},
		  '{SH_R,NOP,32'hffffffff,32'h4,32'h0fffffff,2'b01},
		  '{SH_L,NOP,32'hffffffff,32'h4,32'hfffffff0,2'b01}
		 	};
		 	
data_alu T4[4] ='{
		  '{ADD,NOP,32'hFFFFFFFF,32'h1,32'h0,2'b10},
		  '{SUB,NOP,32'h11111111,32'h 20000000,32'h0,2'b10},
		  '{ADD,NOP,32'hFFFFFFFE,32'h2,32'h0,2'b10},
		  '{SUB,NOP,32'h11111111,32'h20,32'h0,2'b10}
		 };
		 
		 data_alu T5[2][4]='{
					 
					'{'{ADD,ADD,32'hAE000,32'h4,32'hAE004,2'b01},
					'{SUB,SUB,32'hFA,32'hE3,32'h17,2'b01},	
					'{SH_R,SH_R,32'hA000000B,32'h4,32'hA000000,2'b01 },
					'{SH_L,SH_L,32'hB000000A,32'h4,32'hA0,2'b01}},
					'{				 
					'{SH_R,ADD,32'hA000000B,32'h4,32'hA000000,2'b01 },			 
					'{SH_R,SUB,32'hA000000B,32'h4,32'hA000000,2'b01 },			 			 			 
					'{SH_R,SH_L,32'hA000000B,32'h4,32'hA000000,2'b01 },
					'{NOP,NOP,32'h0,32'h0,32'h00,2'b00 }	
					}	 

			};

data_alu T6='{SH_R,NOP,32'h45AF,32'h8,32'h45B7,2'b01};

data_alu T7[2]='{//Tesiting  shift right and shift left operations which 27 msb are ignored
					'{SH_R,NOP,32'h100000,32'hFFFFFFB0,32'h10,2'b01},
					'{SH_L,NOP,32'h10,32'hFFFFFFB0,32'h100000,2'b01}
					};
					
data_alu T8[4]='{//Testing critical data shift 0 and shift 31
				 '{SH_R,NOP,32'h1,32'h0,32'h1,2'b01},
				 '{SH_L,NOP,32'h10000000,32'h0,32'h10000000,2'b01},
				 '{SH_R,NOP,32'h80000000,32'h1F,32'h1,2'b01},
				 '{SH_L,NOP,32'h1,32'h1F,32'h80000000,2'b01}
				 };
data_alu T9[11]={
			  
				'{'b0011,NOP,32'h5,32'h5,32'hA,2'b00},
				'{'b0100,NOP,32'h05,32'h5,32'hA,2'b00},
				'{'b0111,NOP,32'h05,32'h5,32'hA,2'b00},
				'{'b1000,NOP,32'h05,32'h5,32'hA,2'b00},
				 
				'{'b1001,NOP,32'h05,32'h5,32'hA,2'b00},
				'{'b1010,NOP,32'h05,32'h5,32'hA,2'b00},
				'{'b1011,NOP,32'h05,32'h5,32'hA,2'b00},
				'{'b1100,NOP,32'h05,32'h5,32'hA,2'b00},
			 
				'{'b1101,NOP,32'h05,32'h5,32'hA,2'b00},
				'{'b1110,NOP,32'h05,32'h5,32'hA,2'b00},
				'{'b1111,NOP,32'h05,32'h5,32'hA,2'b00}
				 
				 };
				 
data_alu T10[2]='{
					'{SH_L,NOP,32'h0,32'h0,32'h0,2'b01},
					'{SH_L,NOP,32'hx,32'hx,32'h0,2'b00}
					};
				

initial begin
c_clk = 'b1;
forever #50 c_clk = ~c_clk;

end
always @(posedge c_clk)begin  
counter_clock=counter_clock+1;
end

always @(  posedge resp_out[0] or posedge resp_out[1] or posedge resp_out[2] or posedge resp_out[3])begin 

if (resp_out[0]==01) begin  e=0;a=2'b01; end;
if (resp_out[1]==01) begin  e=1;a=2'b01; end;
if (resp_out[2]==01) begin  e=2;a=2'b01; end;
if (resp_out[3]==01) begin  e=3;a=2'b01; end;
prt[r]=e;
pr[r]=a;
r=r+1;
end

initial begin 
$display("Note: In order to check reset function, after end of test scenarios of 2_1,2_2-3 and 3-1,3-2,3-3 , we acitve reset signal and reset function will be checked");
//Test 1 and 2 
$display("%0t:****************************************************** Start Test Scenario  1:******************************************************\n",$time);
Disp(1);
assert_reset;
for (int k=0;k<4;k=k+1) begin 

	for (int i=0;i<4;i=i+1)begin 
		req_cmd[i]=T2[k][i].opc1;
		req_datain[i]=T2[k][i].data1;
	end
	#100ns;
	for (int i=0;i<4;i=i+1) begin
		req_cmd[i]=T2[k][i].opc2;
		req_datain[i]=T2[k][i].data2;
	end
	#200;
// Checker Test 1
check_result(k,T2[k][k].opc1,T2[k][k].data1,T2[k][k].data2,T2[k][k].data_o,T2[k][k].resp_o);
   assert_reset;
   test_reset;

 end 
// Test 3
Disp(Nsc);
assert_reset;
foreach (T3[i]) begin
	foreach ( req_cmd[j]  )  req_cmd[j]=T3[i].opc1;
	foreach (req_datain[j])  req_datain[j]=T3[i].data1;
 #100ns;
    foreach ( req_cmd[j]  )  req_cmd[j]=T3[i].opc2;
	foreach (req_datain[j])  req_datain[j]=T3[i].data2;

//  Cheker Test 3

for (int k=0;k<4;k=k+1)begin
		#200ns;
		check_result(k,T3[i].opc1,T3[i].data1,T3[i].data2,T3[i].data_o,T3[i].resp_o);
end 

assert_reset;
test_reset;


end 
//Test 4
Disp(Nsc);
assert_reset;

foreach (req_cmd[i]) req_cmd[i]=T4[i].opc1;
foreach (req_datain[i]) req_datain[i]=T4[i].data1;
#100ns;
foreach (req_cmd[i]) req_cmd[i]=T4[i].opc2;
foreach (req_datain[i]) req_datain[i]=T4[i].data2;

for (int i=0;i<4;i=i+1) begin 
#200ns;
check_result(i,T4[i].opc1,T4[i].data1,T4[i].data2,T4[i].data_o,T4[i].resp_o);

 end
assert_reset;
//Test 5

Disp(Nsc);
assert_reset;

for (int z=0;z<2;z=z+1) begin 
	for (int i =0;i<4 ; i=i+1) begin 
		req_cmd[i]=T5[z][i].opc1;
		req_datain[i]=T5[z][i].data1;
	 end
	#100ns;
   for (int i =0;i<4 ; i=i+1) begin 
		req_cmd[i]=T5[z][i].opc2;
		req_datain[i]=T5[z][i].data2;
	end
	
	for (int k=0;k<4;k=k+1)begin
		#200ns;
		check_result(k,T5[z][k].opc1,T5[z][k].data1,T5[z][k].data2,T5[z][k].data_o,T5[z][k].resp_o);
	end 
	assert_reset;
end 

//Test 6
Disp(Nsc);
assert_reset;
e=0;
r=0; 

for (int i=0;i<4;i=i+1) begin 

	req_cmd[pri[i]]=T6 .opc1;
	req_datain[pri[i]]=T6 .data1;
	#100ns;
	req_cmd[pri[i]]=T6.opc2;
	req_datain[pri[i]]=T6 .data2;
end 
#500ns;
for (int i=0;i<4;i=i+1) begin 

	if (pri[i]!==prt[i]) begin 
		error_count_resp = error_count_resp + 1;
		$display("%t : Error: There is a problem priority on port %0d.",$time,i);
	 end 
    	 else correct_count_resp = correct_count_resp + 1;

end 

$display("\n %0t :Test 6   is finished, error_count_resp:%0d \n\n",$time, error_count_resp );

Disp(Nsc);
///
//Testing 7
assert_reset;
foreach (T7[i]) req_cmd[i]=T7[i].opc1; 
foreach (T7[i]) req_datain[i]=T7[i].data1;
#100ns;
foreach (T7[i]) req_cmd[i]=T7[i].opc2; 
foreach (T7[i]) req_datain[i]=T7[i].data2;

///checker 7
for (int i=0;i<2;i=i+1) begin 
#200ns; 
check_result(i,T7[i] .opc1,T7[i] .data1,T7[i] .data2,T7 [i].data_o,T7 [i].resp_o);

end 
//Test 8
Disp(Nsc);
assert_reset;
foreach (T8[i]) req_cmd[i]=T8[i].opc1;
foreach (T8[i]) req_datain[i]=T8[i].data1;
#100ns;
foreach (T8[i]) req_cmd[i]=T8[i].opc2;
foreach (T8[i]) req_datain[i]=T8[i].data2;

///checker 8
for (int i=0;i<4;i=i+1) begin
#200ns; 
check_result(i,T8[i] .opc1,T8[i] .data1,T8[i] .data2,T8[i].data_o,T8[i].resp_o);

end

//Test 9 
Disp(Nsc);

e=0;
r=0; 
a=0;
j=0;
assert_reset;

for  (int k=0;k<11;k=k+1) begin 
	req_cmd[j]=T9[k].opc1;
	req_datain[j]=T9[k].data1;
	#100ns;
	req_cmd[j]=T9[k].opc2;
	req_datain[j]=T9[k].data2;
	#100ns;
	j=j+1;
	if (j>3) j=0;
end

#500ns;
for (int i=0;i<11;i=i+1) begin 

	if (T9[i].resp_o!==pr[i]) begin 
		error_count_resp = error_count_resp + 1;
		$display("%t : Error:Response for invalid opcode:%0000b is 01, but it must be 00",$time,T9[i].opc1);
	 end 
    	 else correct_count_resp = correct_count_resp + 1;

end 

//Test 10 
Disp(Nsc);
assert_reset;
for (int j=0;j<2;j=j+1) begin 
	for (int i=0;i<4;i=i+1)begin 
		req_cmd[i]=T10[j] .opc1;
		req_datain[i]=T10[j] .data1;
	end 
	#100ns;
	for (int i=0;i<4;i=i+1)begin 
		req_cmd[i]=T10[j] .opc2;
		req_datain[i]=T10[j] .data2;
	end 
	for (int i=0;i<4;i=i+1) begin
		#200ns; 
		check_result(i,T10[j] .opc1,T10[j] .data1,T10[j]  .data2 ,T10[j] .data_o,T10[j] .resp_o);
	end
	assert_reset;
	
	
end 


#500ns;
$display("\n %0t :Test 10  is finished, error_count_resp:%0d, error_count_dataout:%0d\n\n",$time, error_count_resp,error_count_dataout);
$display("***********************************************Test Scenario 10 is finished************************************");

$finish;

end
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 task check_result (input int Noport,input logic [3:0] Opcode, input logic  [31:0] A, B, input  logic [31:0] expected_result,input logic  [1:0] expected_resp);
 @(negedge c_clk); 
      if (expected_resp !==resp_out[Noport]) begin
	 error_count_resp = error_count_resp + 1;

	 $display("%t: Error: For Opcode = %b, A= 0x%0h, and B=0x%0h reponse of port %0d  should equal %0b but is %0b ", $time, Opcode, A, B,Noport,expected_resp,resp_out[Noport]);
	end
else 
	correct_count_resp = correct_count_resp + 1;
if  (expected_result !== data_out[Noport]) begin 
		error_count_dataout = error_count_dataout + 1;
		$display("%t: Error: For Opcode = %b, A= 0x%0h, and B=0x%0h reslute of port %0d  should equal %0h but is 0x%0h ", $time, Opcode, A, B, Noport,expected_result,data_out[Noport]);
	end
else 
	correct_count_dataout = correct_count_dataout + 1;

endtask 

task assert_reset;
	 counter_clock=0;
     reset =255;
	 #700ns;
     @(posedge c_clk);
     reset = 0;
     #100ns;

   endtask // assert_reset  
   
 task test_reset;
      @(posedge c_clk);
   for (int i=0;i<4;i=i+1) begin 
      if ((resp_out[i]==0 )| ( data_out[i]==0)) begin
     	correct_reset =correct_reset + 1;
     end 
     else begin error_reset = error_reset + 1;
     $display("%t: Error: reset function did not work properly for port %d", $time,i);
     end
    
   end
   if (error_reset==0)   $display("Reset function works poroperly "); 
   counter_clock=1;
endtask

task reset_counters;
 error_count_resp=0;
 error_count_dataout=0; 
 correct_count_resp=0;
 correct_count_dataout=0; 
 endtask 

  task reset_input;

	foreach (req_cmd[i]) begin 
	req_cmd[i]=0;
	req_datain[i]=0;
	end 
endtask
task Disp(input int temp);
 
if (error_count_resp==0 & error_count_dataout==0)  $display("\n%0t: Test scenario   %0d is successful.",$time,temp); 
else
$display("\n%0t: Test scenario   %0d is faild, error_count_resp:%0d, error_count_dataout:%0d\n\n",$time,temp,error_count_resp,error_count_dataout);

$display("*******************************************************************************************************************************************\n");
Nsc=temp+1;
reset_counters;
reset_input;
#500ns;
$display("%0t:****************************************************** Start Test Scenario  %0d:******************************************************\n",$time,Nsc);

endtask 

endmodule
