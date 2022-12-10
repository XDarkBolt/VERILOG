/////////////////////////////////////////
//						UART_TX					//
/////////////////////////////////////////

module UART_TX ( reset , clk , uart_clk , Tx , tx_data_in , tx_ok , tx_done );

/////////////////////////////////////////

input										reset;
input 									clk;
input										tx_ok;
input										uart_clk;
input wire [(DATA_IN_WIDTH-1):0]	tx_data_in;

output reg								Tx;
output reg								tx_done;

/////////////////////////////////////////

reg 			test_bit;
reg 			tx_start;
reg 			STATE;
reg 			NEXT_STATE;
reg			stop_bit;
reg [3:0] 	bit_counter;
reg [3:0] 	counter;
reg [9:0]	tx_data;

reg [7:0]	tx_ram [(BYTE-1):0];
reg [BYTE:0]	addr;
reg [(DATA_WIDTH-DATA_IN_WIDTH):0]	zeros;

/////////////////////////////////////////

parameter 	IDLE 	= 0,
				WRITE = 1;
				
parameter	DATA_WIDTH 		= 2**BYTE,
				UART_WIDTH 		= 8;
				
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SETTINGS

parameter	BYTE 				= 2,
				DATA_IN_WIDTH	= 12;
				
always @( posedge tx_ok )
begin
	
	tx_ram[0] 	<= tx_data_in[(UART_WIDTH-1):0];								
	tx_ram[1] 	<= {zeros,tx_data_in[(DATA_IN_WIDTH-1):UART_WIDTH]};	
	
//tx_ram[0] 	<= tx_data_in[(UART_WIDTH-1):0];
//tx_ram[1] 	<= tx_data_in[((2*UART_WIDTH)-1):UART_WIDTH];
	
//	tx_ram[0] 	<= {1'b1,7'b0000011};
//	tx_ram[1] 	<= {1'b0,tx_data_in[6:0]};
//	tx_ram[2] 	<= {3'b000,tx_data_in[11:7]};
	
end

//tx_ram[2] 	<= {zeros,tx_data_in[(DATA_IN_WIDTH-1):(2*UART_WIDTH)]};

//SETTINGS				
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always
begin
	tx_data		<=	{{1'b1},tx_ram[addr],{1'b0}};
end			

/////////////////////////////////////////

always @( posedge clk or negedge reset )
begin
	if ( ~reset ) STATE <= 0;
	else STATE <= NEXT_STATE;
end

/////////////////////////////////////////

always @( STATE or tx_done or tx_start )
begin
	 case(STATE)
	
	 IDLE:begin
				if( tx_start & ~tx_done ) NEXT_STATE = WRITE;
				else NEXT_STATE = IDLE;
			end
			
	WRITE:begin
				if( tx_done & ~tx_start ) NEXT_STATE = IDLE;
				else NEXT_STATE = WRITE;
			end
			
			default: NEXT_STATE = IDLE;
			
	 endcase
end

/////////////////////////////////////////

always @( posedge tx_ok or posedge tx_done or negedge reset )
begin
	if ( ~reset ) tx_start = 0;
	else
	begin
		if ( tx_done ) tx_start = 0;
		else tx_start = 1;
	end
end

/////////////////////////////////////////

always @(*)
begin
@ ( posedge uart_clk or negedge reset )

	if( ~reset )
	begin
	
		tx_done 			<= 0;
		counter 			<= 0;
		bit_counter		<= 0;
		Tx					<= 1;
		stop_bit			<= 1;
		addr				<= 0;
		zeros				<= 0;
		
	end
	else begin
	
		case (STATE)
	
			IDLE :begin
						
						addr				<= 0;
						Tx 				<= 1;
						tx_done 			<= 0;
						counter 			<= 0;
						bit_counter 	<= 0;
						stop_bit 		<= 1;
						
					end
					
			WRITE:begin
	
						counter 			<= counter + 1;
						
						if( counter == 15 )
						begin
						
							counter <= 0 ;
							
							if ( bit_counter < 10 )
							begin
								bit_counter <= bit_counter + 1;
								Tx 			<= tx_data[bit_counter];
							end
							
							if ( bit_counter == 10 & stop_bit )
							begin
								Tx 			<= 1;
								addr			<= addr + 1;
							end
							
							if ( bit_counter == 10 & addr < (BYTE - 1) )
							begin
								bit_counter	<= 0;
								counter		<= 15;
							end
							
						end
						
						if ( bit_counter == 10 & addr > (BYTE - 1) )
						begin
							stop_bit 	<= 0;
							Tx 			<= 1;
						end
							
						if ( ~stop_bit )
						begin
							tx_done 	<= 1;
						end
						
					end
		endcase
		
	end
	
end

/////////////////////////////////////////

endmodule

/////////////////////////////////////////