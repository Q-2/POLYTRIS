module clk_two_electric_boogaloo (
	input CLK,
	input RESET,
	input drop,
	input hard_drop,
	input [2:0] level,
	output piece_clk
);

//level speeds
parameter LEVEL_7 = 13000000;
parameter LEVEL_6 = 18000000;
parameter LEVEL_5 = 23000000;
parameter LEVEL_4 = 28000000;
parameter LEVEL_3 = 33000000;
parameter LEVEL_2 = 38000000;
parameter LEVEL_1 = 43000000;
parameter LEVEL_0 = 48000000;
parameter SOFT_DROP = 700000;
parameter HARD_DROP = 5000;
//assign clock divider based on level input
logic [25:0] divider; 
always_comb begin
case (level)
	0: divider = LEVEL_0;
	1: divider = LEVEL_1;
	2: divider = LEVEL_2;
	3: divider = LEVEL_3;
	4: divider = LEVEL_4;
	5: divider = LEVEL_5;
	6: divider = LEVEL_6;
	7: divider = LEVEL_7;
	default: divider = LEVEL_1;
endcase
end
//counting to divide the time according to the level/soft drop
logic [25:0] counter;
always @ (posedge CLK) begin
	if (RESET) counter <= 0;
	else begin
		if (((drop) && (counter >= SOFT_DROP)) || ((~drop) && (counter >= divider) || ((hard_drop) && (counter >= HARD_DROP))))
			counter <= 0;
		else
			counter <= counter + 1;
	end
end

always_comb begin
//clock the output
if (hard_drop)
	piece_clk = (counter == HARD_DROP);
else if (drop)
	piece_clk = (counter == SOFT_DROP);
else
	piece_clk = (counter == divider);
end
endmodule
