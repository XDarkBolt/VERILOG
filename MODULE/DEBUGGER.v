/////////////////////////////////////////
//						DEBUGGER					//
/////////////////////////////////////////

module DEBUGGER ( clk , reset , rx_done , tx_done , rx_data_in , db_data , db_ok );

/////////////////////////////////////////

input			clk;
input			reset;
input			rx_done;
input			tx_done;
input	[7:0]	rx_data_in;

output reg [7:0]	db_data;
output reg			db_ok;

/////////////////////////////////////////

parameter 	IDLE 	= 0,
				DEBUG = 1;
				
/////////////////////////////////////////

reg 			STATE;
reg 			NEXT_STATE;
reg			db_done;
reg			tx_start;
reg [7:0]	rx_data;
reg			temp;
reg			temp1;
reg [7:0]	counter;
reg [7:0]	addr;
reg [7:0]	addr_count;
reg [7:0]	text_rom [5:0];

/////////////////////////////////////////

always @( posedge clk or negedge reset )
begin
	if ( ~reset ) STATE <= 0;
	else STATE <= NEXT_STATE;
end

always @( tx_start or db_done )
begin
	 case(STATE)
	
	 IDLE:begin
				if( tx_start ) NEXT_STATE = DEBUG;
				else NEXT_STATE = IDLE;
			end
			
	DEBUG:begin
				if( db_done ) NEXT_STATE = IDLE;
				else NEXT_STATE = DEBUG;
			end
			
			default: NEXT_STATE = IDLE;
			
	 endcase
end

/////////////////////////////////////////

always @( posedge rx_done or posedge db_ok or negedge reset )
begin
	if ( ~reset ) tx_start = 0;
	else
	begin
		if ( rx_done ) tx_start = 1;
		else tx_start = 0;
	end
end

/////////////////////////////////////////

always @( posedge rx_done or negedge reset )
begin
	if ( ~reset ) rx_data	<= 0;
	else rx_data	<=	rx_data_in;
end

always
begin
	db_data			<=	text_rom[addr_count];
	text_rom[0] 	<= 8'h73;
	text_rom[1] 	<= 8'h61;
	text_rom[2] 	<= 8'h62;
	text_rom[3] 	<= 8'h72;
	text_rom[4] 	<= 8'h6f;
	text_rom[5] 	<= 8'h58;
end

/////////////////////////////////////////

always @(*)
begin
@( posedge clk or negedge reset )

	if ( ~reset )
	begin
	
		db_done		<= 0;
		db_ok			<= 0;
		temp			<= 1;
		temp1			<= 0;
		counter		<= 0;
		addr			<= 0;
		addr_count	<= 0;
		
	end
	else
	begin
	
		case (STATE)
	
			IDLE :begin
			
						db_ok 		<= 0;
						db_done		<= 0;
						temp			<= 1;
						temp1			<= 0;
						counter		<= 0;
						addr_count	<= 0;
						
					end
					
			DEBUG:begin
			
						counter	<= counter + 1;
						
						if ( temp )
						begin
							case ( rx_data )
							
								0:begin
										db_done <= 1;
									end
	
								1:begin
										if ( counter == 4 )
										begin
											addr			<= 2;
										end
										if ( counter == 8 )
										begin
											addr_count	<= 0;
											temp1			<= 1;
										end
									end
									
								2:begin
										if ( counter == 4 )
										begin
											addr			<= 5;
										end
										if ( counter == 8 )
										begin
											addr_count	<= 2;
											temp1			<= 1;
										end
									end
									
						default:begin
										if ( counter == 4 )
										begin
											addr			<= 6;
										end
										if ( counter == 8 )
										begin
											addr_count	<= 5;
											temp1			<= 1;
										end
									end
									
							endcase
						end
						
						if ( counter == 16 )
						begin
							db_ok	<= 1;
							temp	<= 0;
						end
						
						if ( counter == 24 )
						begin
							db_ok 		<= 0;
						end
						
						if ( counter == 32 )
						begin
							addr_count	<= addr_count + 1;
							counter	<= 0;
						end
						
						if ( addr_count == addr & temp1 ) db_done <= 1;
						
					end
		endcase
		
	end
	
end

/////////////////////////////////////////

endmodule

/////////////////////////////////////////