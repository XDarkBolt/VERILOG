/////////////////////////////////////////
//						UART_RX					//
/////////////////////////////////////////

module UART_RX (  reset , clk , uart_clk , Rx , rx_done , rx_data ) ;

/////////////////////////////////////////

input clk ;
input reset ;
input	uart_clk ;
input Rx ;
output reg 			rx_done ;
output reg [7:0] 	rx_data ;

/////////////////////////////////////////

parameter 	IDLE = 1'b0 ,
				READ = 1'b1 ;

/////////////////////////////////////////

reg 			STATE ;
reg 			NEXT_STATE ;
reg 			start_bit ;
reg [3:0] 	counter ;
reg [3:0] 	bit_counter ;
reg [7:0] 	word_in ;

/////////////////////////////////////////

always @ ( posedge clk or negedge reset )
begin
	if ( ~reset ) STATE <= 0;
	else STATE <= NEXT_STATE;
end

/////////////////////////////////////////

always @ ( STATE or rx_done or Rx )
begin

	case( STATE )

	IDLE: begin
				if( ~Rx ) NEXT_STATE = READ;
				else NEXT_STATE = IDLE;
			end
	READ:begin
				if( rx_done ) NEXT_STATE = IDLE;
				else NEXT_STATE = READ;
			end

			default: NEXT_STATE = IDLE;
	endcase

end
	
/////////////////////////////////////////

always @ (*)
begin
@ ( posedge uart_clk or negedge reset )

	if( ~reset )
	begin
	
		bit_counter <= 0;
		counter 		<= 0;
		rx_done 		<= 0;
		start_bit 	<= 1;
		word_in 		<= 0;
		rx_data 		<= 0;
		
	end
	else begin
	
		case ( STATE )

			IDLE :begin
			
					bit_counter <= 0;
					counter 		<= 0;
					rx_done 		<= 0;
					start_bit 	<= 1;
					rx_data 		<= 0;
					
				end

			READ :begin
			
					counter <= counter + 1;
				
					if( counter == 4'b0111 & start_bit )
					begin
						start_bit 	<= 0;
						counter 		<= 0;
					end
				
					if( counter == 4'b1111 & bit_counter < 4'b1000 )
					begin
						bit_counter <= bit_counter + 1;
						counter 		<= 0;
						word_in 		<= { Rx , word_in[7:1] };
					end
				
					if( counter == 4'b1111 & Rx & bit_counter == 4'b1000 )
					begin
						rx_done 	<= 1;
						rx_data 	<= word_in;
						counter 	<= 0;
					end
				end
		endcase
	end
end

/////////////////////////////////////////

endmodule

/////////////////////////////////////////