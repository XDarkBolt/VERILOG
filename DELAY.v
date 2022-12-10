/////////////////////////////////////////
//						DELAY						//
/////////////////////////////////////////

module DELAY ( reset , clk , sig_in , sig_out );

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SETTINGS

parameter	COUNT_WIDTH	= 5,
				DELAY_TIME	= 10,
				SIG_TIME		= 1;

//SETTINGS				
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

input reset;
input clk;

input sig_in;
output reg sig_out;

/////////////////////////////////////////

reg [COUNT_WIDTH:0] counter;
reg		  temp0;
reg		  temp00;

/////////////////////////////////////////

always @(*)
begin
	if ( ~reset ) temp00	<= 0;
	else begin
		if ( sig_in ) temp00	<= 1;
		if ( ~sig_in & counter > DELAY_TIME ) temp00	<= 0;
	end
end

always @(*)
begin
@( posedge clk or negedge reset )

	if ( ~reset )
	begin
	
	temp0		<= 0;
	sig_out	<= 0;
	counter	<= 0;
	
	end
	else begin
		
		if ( temp00 || temp0 )
		begin
		
			counter <= counter + 1;
			
			if ( counter < DELAY_TIME ) temp0 <= 1;
			
			if ( counter == DELAY_TIME )
			begin
				sig_out	<= 1;
			end
			
			if ( counter == ( DELAY_TIME + SIG_TIME ) )
			begin
				sig_out	<= 0;
				temp0		<= 0;
				counter	<= 0;
			end
			
		end
		
	end
	
end

/////////////////////////////////////////

endmodule

/////////////////////////////////////////