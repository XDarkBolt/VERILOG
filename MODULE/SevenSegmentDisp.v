module	SevenSegmentDisp_BCD(sw,reset,LED_out,LED_onluk_out);

input					sw;	//switch girişi.
input					reset;	//reset girişi.
output reg	[6:0] LED_out; //birinci 7 segment için çıkış üretir.
output reg	[6:0] LED_onluk_out; //ikinci onluk tabndaki 7 segment için çıkış üretir.

reg	[3:0] LED_birler_BCD;
reg	[3:0] LED_onlar_BCD;
reg	[7:0] number;	//sayının toplamı.
reg	[7:0] LED_BCD;	//8 bit sayı ancak 99 a kadar gösterir.

always number <= 25; //sayı girişi.

always @(*)
begin
	if ( ~reset )
	begin
		LED_onlar_BCD <= 0;
		LED_birler_BCD <= 0;
		LED_out <= 0;
		LED_onluk_out <= 0;
		LED_BCD <= number;
	end
	else
	begin
		
		@( posedge sw )
		begin
			LED_BCD <= LED_BCD + number;
		end
		
		LED_birler_BCD = LED_BCD % 10;
		LED_onlar_BCD = LED_BCD / 10;	//onluk tabandaki sayı belirleniyor.
		
		case(LED_birler_BCD)
			4'b0000: LED_out = 7'b0000001; // "0"  
			4'b0001: LED_out = 7'b1001111; // "1" 
			4'b0010: LED_out = 7'b0010010; // "2" 
			4'b0011: LED_out = 7'b0000110; // "3" 
			4'b0100: LED_out = 7'b1001100; // "4" 
			4'b0101: LED_out = 7'b0100100; // "5" 
			4'b0110: LED_out = 7'b0100000; // "6" 
			4'b0111: LED_out = 7'b0001111; // "7" 
			4'b1000: LED_out = 7'b0000000; // "8"  
			4'b1001: LED_out = 7'b0000100; // "9" 
			default: LED_out = 7'b0000001; // "0"
		endcase
		
		case(LED_onlar_BCD)
			4'b0000: LED_onluk_out = 7'b0000001; // "00"  
			4'b0001: LED_onluk_out = 7'b1001111; // "10" 
			4'b0010: LED_onluk_out = 7'b0010010; // "20" 
			4'b0011: LED_onluk_out = 7'b0000110; // "30" 
			4'b0100: LED_onluk_out = 7'b1001100; // "40" 
			4'b0101: LED_onluk_out = 7'b0100100; // "50" 
			4'b0110: LED_onluk_out = 7'b0100000; // "60" 
			4'b0111: LED_onluk_out = 7'b0001111; // "70" 
			4'b1000: LED_onluk_out = 7'b0000000; // "80"  
			4'b1001: LED_onluk_out = 7'b0000100; // "90" 
			default: LED_onluk_out = 7'b0000001; // "00"
		endcase
		
	end
end

endmodule 