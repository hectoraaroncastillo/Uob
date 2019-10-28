`uselib lib=calc1_black_box

module example_calc1_tb;
 
   parameter channels = 4;
   wire [0:31]   out_data [0:channels-1];//1, out_data2, out_data3, out_data4;
   wire [0:1]    out_resp [0:channels-1];//1, out_resp2, out_resp3, out_resp4;
   
   reg 	         c_clk;
   reg [0:3] 	 req_cmd_in [0:channels-1];//, req2_cmd_in, req3_cmd_in, req4_cmd_in;
   reg [0:31]    req_data_in [0:channels-1]; //, req2_data_in, req3_data_in, req4_data_in;
   reg [1:7] 	 reset;

   //calc1 DUV(out_data1, out_data2, out_data3, out_data4, out_resp1, out_resp2, out_resp3, out_resp4, c_clk, req1_cmd_in, req1_data_in, req2_cmd_in, req2_data_in, req3_cmd_in, req3_data_in, req4_cmd_in, req4_data_in, reset);
   calc1 DUV(out_data[0], out_data[1], out_data[2], out_data[3], out_resp[0], out_resp[1], out_resp[2], out_resp[3], c_clk, req_cmd_in[0], req_data_in[0], req_cmd_in[1], req_data_in[1], req_cmd_in[2], req_data_in[2], req_cmd_in[3], req_data_in[3], reset);
   initial 
     begin
	c_clk = 0;
	req_cmd_in[0] = 0;
	req_data_in[0] = 0;
	req_cmd_in[1] = 0;
	req_data_in[1] = 0;
	req_cmd_in[2] = 0;
	req_data_in[2] = 0;
	req_cmd_in[3] = 0;
	req_data_in[3] = 0;

     end   
	
   always #100 c_clk = ~c_clk;
   
   initial
     begin


	/***********  Section 1: No operation ***********/
	Test_1_1();
	Test_1_2();
	


	/***********  Section 2: Addition ***********/
	
        // First drive reset. Driving bit 1 is enough to reset the design.

	reset[1] = 1;
	#800 
	reset[1] = 0;

	#2000 $stop;

     end // initial begin

   always
     @ (reset or req_cmd_in[0] or req_data_in[0] or req_cmd_in[1] or req_data_in[1] or req_cmd_in[2] or req_data_in[2] or req_cmd_in[3] or req_data_in[3]) begin
	
	$display ("%t: r:%b \n 1c:%d,1d:%d \n 2c:%d,2d:%d \n 3c:%d,3d:%d \n 4c:%d,4d:%d \n 1r:%d,1d:%d \n 2r:%d,2d:%d \n 3r:%d,3d:%d \n 4r:%d,4d:%d \n\n", $time, reset[1], req1_cmd_in, req1_data_in, req2_cmd_in, req2_data_in, req3_cmd_in, req3_data_in, req4_cmd_in, req4_data_in, out_resp1, out_data1, out_resp2, out_data2, out_resp3, out_data3, out_resp4, out_data4);
	
     end

/*********** Function to notify bugs ***********/
task Notify_Bug;

	input unit, subunit;
	begin
		$display ("%t:  bug-found: %d.%d \n\n", $time, unit, subunit);
	end
endtask // Notify_Bug task


/*********** Test 1.1: Send only clock cycles ***********/
task Test_1_1;		
	integer i;
		// Wait for any possible response with no commands or data
	begin
	#800	
	for (i = 0; i < channels-1; i = i+1) 
	begin
		if (out_data[i] != 0 || out_resp[i] != 0)
		begin
			Notify_Bug(1,1);
		end
	end
	end
endtask // Test_1_1

/*********** Test 1.2 Send data and clock cycles ***********/
task Test_1_2;
	integer i;
	// Wait for any possible response sending just data
	begin
	// Start sending the value 0xFFFF
	for (i = 0; i < channels-1; i = i+1) 
	begin
		req_data_in[i] = 32'h0000_FFFF;
	end	
	// Wait 800 clock cycles
	#800
	// Check if there is response on the output lines
	for (i = 0; i < channels-1; i = i+1) 
	begin
		if (out_data[i] != 0 || out_resp[i] != 0)
		begin
			Notify_Bug(1,2);
		end
	end
	end
endtask // Test_1_2


endmodule // example_calc1_tb


   
