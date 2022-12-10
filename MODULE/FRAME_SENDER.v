/////////////////////////////////////////
//					FRAME_SENDER				//
/////////////////////////////////////////

module FRAME_SENDER ( reset , adc_clk_out , adc_data_in , tx_ok_out , frame );

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SETTINGS

parameter	ROM_LENGTH 		= 2048,
				ADDR_DEPTH		= 12,
				DATA_IN_WIDTH	= 12,
				SEND_SPEED		= 14,
				START_TIME		= 24;
				
//SETTINGS				
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

input									reset;
input									adc_clk_out;
input [DATA_IN_WIDTH:0]			adc_data_in;

output 								tx_ok_out;
output reg [DATA_IN_WIDTH:0]	frame;

/////////////////////////////////////////

reg [DATA_IN_WIDTH:0] 		frame_rom [ROM_LENGTH - 1:0];
reg [( ADDR_DEPTH + 1 ):0]	addr_rx;
reg [( ADDR_DEPTH + 1 ):0] addr_tx;
reg [START_TIME:0] 			tx_ok_counter;
reg [SEND_SPEED:0] 			ntx_ok_counter;
reg								tx_ok_addr;
reg								tx_ok;
reg		  						temp;
reg 								temp1;
reg								temp2;

/////////////////////////////////////////

always @(*)
@( negedge adc_clk_out or negedge reset )
begin
	if ( ~reset )
	begin
		temp 		<= 0;
		addr_rx 	<= 0;
	end
	else begin
		if ( ~temp & temp2 ) addr_rx <= addr_rx + 1;
		if ( addr_rx > 2047 ) temp <= 1;
	end
end

always @(*)
@( negedge tx_ok_addr or negedge reset )
begin
	if ( ~reset )
	begin
		temp1 <= 0;
		addr_tx <= 0;
	end
	else begin
		if ( temp ) addr_tx <= addr_tx + 1;
		if ( addr_tx > 2047 ) temp1 <= 1;
	end
end

always @(*)
@( posedge adc_clk_out or negedge reset )
begin
	if ( ~reset )
	begin
		temp2 			<= 0;
		tx_ok_counter 	<= 0;
	end
	else begin
		tx_ok_counter <= tx_ok_counter + 1;
		if ( tx_ok_counter[START_TIME] ) temp2 <= 1;
	end
end

always @( negedge adc_clk_out or negedge reset )
begin
	if ( ~reset ) ntx_ok_counter <= 0;
	else ntx_ok_counter <= ntx_ok_counter + 1;
end

always
begin
	tx_ok <= tx_ok_counter[SEND_SPEED];
	if ( temp && ~temp1 ) tx_ok_addr <= ntx_ok_counter[SEND_SPEED];
end

assign tx_ok_out = ( ( temp && ~temp1 ) ? tx_ok : 1'b0 );

always @(*)
begin
@( posedge adc_clk_out )
	if ( ~temp )
	begin
		frame_rom[addr_rx] <=	adc_data_in;
	end
end

always
begin
	frame <=	frame_rom[addr_tx];
end

/////////////////////////////////////////

endmodule

/////////////////////////////////////////