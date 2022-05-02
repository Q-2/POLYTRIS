
module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,           //x
	
	// Avalon Reset Input
	input logic RESET,           //x
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read                 x
	input  logic AVL_WRITE,					// Avalon-MM Write           x
	input  logic AVL_CS,					// Avalon-MM Chip Select           x
	
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable           u
	input  logic [11:0] AVL_ADDR,			   // Avalon-MM Address           u
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data           x
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data           x
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);
logic [31:0] TEMP_WRITE_DATA;
logic [11:0] FONT_ADDR;
logic [15:0]  FONT_DATA;
logic VGA_CLK;
logic blank;
logic sync;
logic [31:0] LOCAL_REG [30];
logic [9:0] DrawX, DrawY; // Registers
//put other local variables here
logic write;
logic [3:0] FGD_R, FGD_G, FGD_B, BKG_R, BKG_G, BKG_B;
logic [1:0] PIXEL_VAL;
logic [19:0] VGA_DATA;
logic [3:0] LENGTH; 

//Declare submodules..e.g. VGA controller, ROMS, etc

// OCM Zuofu (
// 	.address_a(AVL_ADDR),
// 	.address_b(VGA_ADDR),
// 	.byteena_a(AVL_BYTE_EN),
// 	.byteena_b(),
// 	.clock(CLK),
// 	.data_a(AVL_WRITEDATA),
// 	.data_b(),
// 	.rden_a(AVL_READ),
// 	.rden_b(VGA_CLK),
// 	.wren_a(AVL_WRITE),
// 	.wren_b(),
// 	.q_a(AVL_READDATA),
// 	.q_b(VGA_DATA)
// );

vga_controller text_writing_controller_instantiation(
.Clk(CLK),
.Reset(RESET),
.hs(hs),
.vs(vs),
.pixel_clk(VGA_CLK),
.blank(blank),
.sync(sync),
.DrawX(DrawX),
.DrawY(DrawY)
);


//background colors
logic [11:0] BGD_REG [4];
assign BGD_REG[0] = 12'h777; //gray
assign BGD_REG[1] = 12'h000; //black
assign BGD_REG[2] = 12'hfff; //white
assign BGD_REG[3] = 12'h620; //red
logic [11:0] PIXEL_COLOR;

always_ff @(posedge VGA_CLK) begin
//board
	if ((DrawX > 240) && (DrawX < 400)) begin
		if (blank) begin
			red = PIXEL_COLOR[11:8];
			green = PIXEL_COLOR[7:4];
			blue = PIXEL_COLOR[3:0];
		end
	end
//board borders
	else if (((DrawX > 232) && (DrawX < 240)) || ((DrawX > 400) && (DrawX < 408))) begin
		red = 4'hc;
		blue = 4'hf;
		green = 4'hf; 
	end
 //score box
 	else if (((DrawX > 432) && (DrawX < 544)) && ((DrawY > 32) && (DrawY < 128))) begin
			if(FONT_PIXEL) begin
				red = 4'hf;
				blue = 4'hf;
				green = 4'hf;
			end
			else begin
				red = 4'h0;
				blue = 4'h0;
				green = 4'h0;
			end
 	end
 //level box
 	else if (((DrawX > 432) && (DrawX < 528)) && ((DrawY > 304) && (DrawY < 352))) begin
 		red = 4'h0;
 		blue = 4'h0;
 		green = 4'h0;
 	end
 //stats box
 	else if (((DrawX > 62) && (DrawX < 192)) && ((DrawY > 128) && (DrawY < 432))) begin
 		red = 4'h0;
 		blue = 4'h0;
 		green = 4'h0;
 	end
//the rest of the background
	else begin
		red = 4'ha;
		blue = 4'ha;
		green = 4'ha;
	end
//next piece border
	if (((DrawX > 424) && (DrawX < 504)) && ((DrawY > 184) && (DrawY < 280))) begin
		red = 4'hc;
		blue = 4'hf;
		green = 4'hf;
	end
	else;
//next piece box
	if (((DrawX > 432) && (DrawX < 496)) && ((DrawY > 192) && (DrawY < 272))) begin
		red = 4'h0;
		blue = 4'h0;
		green = 4'h0;
	end
	else;
end

logic [5:0] SPRITE_ADDR;
logic [31:0] SPRITE_DATA;
logic [11:0] COLOR_0, COLOR_1, COLOR_2, COLOR_3;

 //sandbox variables
logic [3:0] SANDBOX [4];
logic [4:0] SANDBOX_X;
logic [5:0] SANDBOX_Y;
logic [4:0] PIECE_LENGTH;
logic [1:0] PIECE_STYLE;
logic [7:0] ScoreX, ScoreY;
logic FONT_PIXEL;
logic [3:0] SCOREPOS_X, SCOREPOS_Y;
logic [7:0] CHAR_DATA;
logic [5:0] CHAR_ADDR;
logic [4:0] VGA_ADDR;
logic [8:0] BoardX, BoardY;
logic [4:0] REGPOS_X, REGPOS_Y;
logic [2:0] LEVEL;

//TODO: test case
assign LEVEL = 3'b000;

//obtain board position
assign BoardX = DrawX - 240;
assign BoardY = DrawY;

always_comb begin
//reading data from a 32 bit
PIXEL_VAL = SPRITE_DATA[(31-{BoardX[3:0],1'b0})-:2];
SPRITE_ADDR = {VGA_DATA[(REGPOS_X*2+1)-:2], BoardY[3:0]};
REGPOS_Y = BoardY[8:4];
REGPOS_X = BoardX[8:4];
PIECE_STYLE = (PIECE_LENGTH % 3) + 1;

if ((REGPOS_X + 4 >= SANDBOX_X - 3 + 4) && (REGPOS_X  + 4 <= SANDBOX_X + 4) && (REGPOS_Y + 4 >= SANDBOX_Y - 3 + 4) && (REGPOS_Y + 4 <= SANDBOX_Y + 4)) begin
	VGA_DATA = {PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE};
end
VGA_DATA = LOCAL_REG[REGPOS_Y][19:0];

case (PIXEL_VAL)
	2'b00: PIXEL_COLOR = COLOR_0; //accent 1
	2'b01: PIXEL_COLOR = COLOR_1; //accent 2
	2'b10: PIXEL_COLOR = COLOR_2; //black
	default: PIXEL_COLOR = COLOR_3; //white
endcase
LOCAL_REG[0] = 32'b11111111111111111111010011011011;
LOCAL_REG[4] = 32'b11111111111111111111010011011011;

end
always_comb begin
//obtain score box position
ScoreX = DrawX - 432;
ScoreY = DrawY - 32;
SCOREPOS_X = ScoreX[7:4];
SCOREPOS_Y = ScoreY[7:4];
// 	else if (((DrawX > 432) && (DrawX < 544)) && ((DrawY > 32) && (DrawY < 128))) begin

//printing the 'score' on screen
CHAR_ADDR = SCOREPOS_Y*7+SCOREPOS_X;
FONT_ADDR = {CHAR_DATA, ScoreY[3:0]};
FONT_PIXEL = FONT_DATA[15-ScoreX[3:0]];
end


// PIXEL_VAL = SPRITE_DATA[(31-{BoardX[3:0],1'b0})-:2];
// SPRITE_ADDR = {VGA_DATA[(REGPOS_X*2+1)-:2], BoardY[3:0]};
// REGPOS_Y = BoardY[8:4];
// REGPOS_X = BoardX[8:4];
// PIECE_STYLE = (PIECE_LENGTH % 3) + 1;


drawing piece_tile(.SPRITE_ADDR(SPRITE_ADDR), .SPRITE_DATA(SPRITE_DATA));

palette level_colors(.LEVEL(LEVEL), .COLOR_0(COLOR_0), .COLOR_1(COLOR_1), .COLOR_2(COLOR_2), .COLOR_3(COLOR_3)); //TODO: fill in the level

score_reg print_score(.CHAR_ADDR(CHAR_ADDR), .CHAR_DATA(CHAR_DATA));

font_rom(
.FONT_ADDR(12'h124), 
.FONT_DATA(FONT_DATA)
);

/*
//check if it's a piece
FGD_ID = LSD_VISION[7:4];
FGD_REG = FGD_ID[3:1]; //divide by two, take floor to get palette register
if (FGD_ID[0]==0)
	FGD_LSD_COLOR = PALLET_REG[FGD_REG][12:1];
else 
	FGD_LSD_COLOR = PALLET_REG[FGD_REG][24:13];
FGD_R = FGD_LSD_COLOR[3:0];
FGD_G = FGD_LSD_COLOR[7:4];
FGD_B = FGD_LSD_COLOR[11:8];

//bkg color
BKG_ID = LSD_VISION[3:0];
BKG_REG = BKG_ID[3:1]; //divide by two, take floor to get palette register
if (BKG_ID[0]==0)
	BKG_LSD_COLOR = PALLET_REG[BKG_REG][12:1];
else begin
	BKG_LSD_COLOR = PALLET_REG[BKG_REG][24:13];
	BKG_R = BKG_LSD_COLOR[3:0];
	BKG_G = BKG_LSD_COLOR[7:4];
	BKG_B = BKG_LSD_COLOR[11:8];
	end
end

always_ff @(posedge VGA_CLK) begin
//handle drawing (may either be combinational or sequential - or both).
	//reading FGD_R, FGD_G, FGD_B, BKG_R, BKG_G, BKG_B values
		if(blank) begin 
			if(PIXEL_VAL) begin
				red = FGD_R;
				blue = FGD_B;
				green = FGD_G;
			end
			else begin
				red = BKG_R;
				blue = BKG_B;
				green = BKG_G;
			end
		end
		else begin
			red = 4'b0000;
			green = 4'b0000;
			blue = 4'b0000;
		end
end
*/
	
endmodule
