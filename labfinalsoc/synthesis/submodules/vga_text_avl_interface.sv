
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
	output logic hs, vs,						// VGA HS/VS
	
	//new exported conduits
	input logic [7:0] keyboard_input,
	input logic [15:0] random_noise,
	input logic [15:0] game_piece,
	output logic [7:0] generator_flag

);
logic [31:0] TEMP_WRITE_DATA;
logic [11:0] FONT_ADDR;
logic [15:0]  FONT_DATA;
logic VGA_CLK;
logic blank;
logic sync; 
logic [31:0] LOCAL_REG [29:0];
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
//SIG_ENDGAME
//state machine variables
logic [9:0] score;
logic [1:0] rotate;
logic       clearline;
logic       pieceplaced;
logic       placepiece;
logic       ground_notif;
logic [5:0] clearlineval;
logic       piece_clk;
logic   SIG_FALL, 
		SIG_MOVELEFT,
		SIG_MOVERIGHT,
		SIG_KONAMI,
		SIG_NONEINPUT,
		SIG_CLEARLINECHECK,
		SIG_CLEARLINEACT,
		SIG_CLEARLINE,
		SIG_PIECEPLACED,
		SIG_ROTATELEFT,
		SIG_ROTATELEFT_2,
		SIG_ROTATERIGHT,
		SIG_ROTATERIGHT_2,
		SIG_HOLDPIECE,
		SIG_HOLDPIECE_2,
		SIG_HOLDPIECE_3,
		SIG_CLEARALL,
		SIG_LOGO,
		SIG_LOADPIECE;
logic [4:0] State_out;

statemachine game_states(.*, .keyboardinput(keyboard_input));

//game board variables
logic [3:0]piece_buffer[3:0];
logic [10:0] RAM_ROW_ADDR;
logic RAM_WE, RAM_RE;
logic RAM_WRITEDATA;
logic [5:0]collision;
logic [3:0]sandbox[3:0];
logic [29:0]clearlineflags;
logic [3:0]ground_counter;
logic [5:0]numberoflines;
gameboard_2 game_board(.*,.piece_buffer(piece_buffer),.sandboxLR(SANDBOX_X), .sandboxUD(SANDBOX_Y),
		.sandbox(sandbox),
		.board_data(LOCAL_REG),
		.ROTATELEFT(SIG_ROTATELEFT),
		.ROTATERIGHT(SIG_ROTATERIGHT),
		.LOADPIECE(SIG_LOADPIECE),
		.FALL(SIG_FALL),
		.MOVELEFT(SIG_MOVELEFT),
		.MOVERIGHT(SIG_MOVERIGHT),
		.PIECEPLACED(SIG_PIECEPLACED),
		.CLEARLINECHECK(SIG_CLEARLINECHECK),
		.CLEARLINEACT(SIG_CLEARLINEACT),
		.CLEARLINE(SIG_CLEARLINE),
		.KONAMI(SIG_KONAMI),
		.NONEINPUT(SIG_NONEINPUT),
		.HOLDPIECE(SIG_HOLDPIECE),
		.HOLDPIECE_2(SIG_HOLDPIECE_2),
		.HOLDPIECE_3(SIG_HOLDPIECE_3),
		.ENDGAME(SIG_ENDGAME),
		.CLEARALL(SIG_CLEARALL),
		.LOGO(SIG_LOGO)
		);



//background colors
// assign BGD_REG[0] = 12'h777; //gray
// assign BGD_REG[1] = 12'h000; //black
// assign BGD_REG[2] = 12'hfff; //white
// assign BGD_REG[3] = 12'h620; //red
logic [11:0] PIXEL_COLOR;
logic [2:0]RANDOMIZER;
logic [3:0]first_addr, second_addr, third_addr, fourth_addr;
int i;
int j; 
scoreToDecimal scoreconverter(.score(score), .first_addr(first_addr), .second_addr(second_addr), .third_addr(third_addr), .fourth_addr(fourth_addr));
always_ff @(posedge VGA_CLK) begin
//score
if(SIG_CLEARALL)
	score = 0;
if(SIG_LOADPIECE)
	score = score + numberoflines * (LEVEL+1) * 8;
if (score >= 128 && score < 256)  LEVEL = 3'b001;
else if ((score >= 256) && (score < 384))  LEVEL = 3'b010;
else if ((score >= 384) && (score < 512))  LEVEL = 3'b011;
else if ((score >= 512) && (score < 640))  LEVEL = 3'b100;
else if ((score >= 640) && (score < 768))  LEVEL = 3'b101;
else if ((score >= 768) && (score < 896))  LEVEL = 3'b110;
else if ((score >= 896) && (score < 1024))  LEVEL = 3'b111;
else LEVEL = 3'b000;
//piece buffer

//board
	if ((DrawX > 240) && (DrawX < 400)) begin
		if (blank) begin
			red = PIXEL_COLOR[11:8];
			green = PIXEL_COLOR[7:4];
			blue = PIXEL_COLOR[3:0];
		end
		else begin
			red = 4'b0000;
			green = 4'b0000;
			blue = 4'b0000;
		end
	end
//board borders
	else if (((DrawX > 232) && (DrawX < 240)) || ((DrawX > 400) && (DrawX < 408))) begin
		if (blank) begin
			red = 4'ha;
			blue = 4'hf;
			green = 4'hf; 
		end
		else begin
			red = 4'b0000;
			green = 4'b0000;
			blue = 4'b0000;
		end
	end
 //score box
 	else if (((DrawX > 432) && (DrawX < 544)) && ((DrawY > 32) && (DrawY < 128))) begin
	 	if (blank) begin
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
		else begin
			red = 4'b0000;
			green = 4'b0000;
			blue = 4'b0000;
		end
 	end
 //level box
 	else if (((DrawX > 432) && (DrawX < 528)) && ((DrawY > 304) && (DrawY < 352))) begin
		if (blank) begin
 			red = 4'h0;
 			blue = 4'h0;
 			green = 4'h0;
		end
		else begin
			red = 4'b0000;
			green = 4'b0000;
			blue = 4'b0000;
		end
 	end
//the rest of the background
	else begin
		if (blank) begin
			red =   BKG_R;
			blue =  BKG_B;
			green = BKG_G;
		end
		else begin
			red = 4'b0000;
			green = 4'b0000;
			blue = 4'b0000;
		end
	end
//next piece border
	if (((DrawX > 424) && (DrawX < 536)) && ((DrawY > 184) && (DrawY < 296))) begin
		if (blank) begin
			red = 4'hc;
			blue = 4'hf;
			green = 4'hf;
		end
		else begin
			red = 4'b0000;
			green = 4'b0000;
			blue = 4'b0000;
		end
	end
	else;
//next piece box
	if (((DrawX > 432) && (DrawX < 528)) && ((DrawY > 192) && (DrawY < 288))) begin
		if (blank) begin
			red = NEXT_COLOR[11:8];
			green = NEXT_COLOR[7:4];
			blue = NEXT_COLOR[3:0];
		end
		else begin
			red = 4'b0000;
			green = 4'b0000;
			blue = 4'b0000;
		end
	end
	else;
end

logic [5:0] SPRITE_ADDR;
logic [31:0] SPRITE_DATA;
logic [11:0] COLOR_0, COLOR_1, COLOR_2, COLOR_3;

 //sandbox variables
logic [4:0] SANDBOX_X;
logic [5:0] SANDBOX_Y;
logic [3:0] PIECE_LENGTH;
logic [1:0] PIECE_STYLE;
logic [7:0] ScoreX, ScoreY;
logic FONT_PIXEL;
logic [3:0] SCOREPOS_X, SCOREPOS_Y;
logic [3:0] CHAR_DATA;
logic [5:0] CHAR_ADDR;
logic [4:0] VGA_ADDR;
logic [8:0] BoardX, BoardY;
logic [4:0] REGPOS_X, REGPOS_Y;
logic [2:0] LEVEL;
logic [1:0] filtered_piece_style;


//obtain board position
assign BoardX = DrawX - 240;
assign BoardY = DrawY;

always_comb begin
if( SIG_ENDGAME || SIG_CLEARLINECHECK) 
	generator_flag = 16'hffff;
else
	generator_flag = 16'h0000;
//bkg clr
for(i = 0; i < 4; i = i+1) begin
	for(j = 0; j < 4; j = j + 1)begin
		piece_buffer[i][j] = game_piece[i*4 + j];
	end
end

BKG_R = {1'b1, (COLOR_0[11]&random_noise[DrawX + random_noise[DrawY + 3]]&COLOR_0[11:8]),(COLOR_0[11]&random_noise[DrawX + random_noise[DrawY + 1]]&COLOR_0[11:8]),1'b1};
BKG_G = {1'b1, (COLOR_0[7]&random_noise[DrawX + random_noise[DrawY + 1]]&COLOR_0[7:4]),(COLOR_0[7]&random_noise[DrawX + random_noise[DrawY + 6]]&COLOR_0[7:4]),1'b1};
BKG_B = {1'b1, (COLOR_0[3]&random_noise[DrawX + random_noise[DrawY + 7]]&COLOR_0[3:0]),(COLOR_0[3]&random_noise[DrawX + random_noise[DrawY + 11]]&COLOR_0[3:0]),1'b1};
//reading data from a 32 bit
    PIXEL_VAL = SPRITE_DATA[(31-{BoardX[3:0],1'b0})-:2];
    SPRITE_ADDR = {VGA_DATA[(REGPOS_X*2+1)-:2], BoardY[3:0]};
    REGPOS_Y = BoardY[8:4];
    REGPOS_X = BoardX[8:4];
    PIECE_STYLE = ((PIECE_LENGTH % 3) + 1);
	 filtered_piece_style = {PIECE_STYLE[0]&(sandbox[REGPOS_Y - SANDBOX_Y+3][REGPOS_X - SANDBOX_X+3]),PIECE_STYLE[1]&(sandbox[REGPOS_Y - SANDBOX_Y+3][REGPOS_X - SANDBOX_X+3])};

if ((REGPOS_X + 3>= SANDBOX_X ) && (REGPOS_X  <= SANDBOX_X ) && (REGPOS_Y + 3 >= SANDBOX_Y) && (REGPOS_Y <= SANDBOX_Y) && sandbox[REGPOS_Y - SANDBOX_Y + 3][REGPOS_X - SANDBOX_X + 3]) begin
	VGA_DATA = {filtered_piece_style, filtered_piece_style, filtered_piece_style, filtered_piece_style, filtered_piece_style, filtered_piece_style, filtered_piece_style, filtered_piece_style, filtered_piece_style, filtered_piece_style};
end
else begin
    VGA_DATA = LOCAL_REG[REGPOS_Y][19:0];
end
case (PIXEL_VAL)
    2'b00: PIXEL_COLOR = COLOR_0; //accent 1
    2'b01: PIXEL_COLOR = COLOR_1; //accent 2
    2'b10: PIXEL_COLOR = COLOR_2; //black
    default: PIXEL_COLOR = COLOR_3; //white
endcase
//TEST todo Sandbox and Gameboard Contents (local reg = gameboard)
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

//next piece printing
logic [1:0] NEXTPOS_X, NEXTPOS_Y;
logic [7:0] Next_X, Next_Y;
logic [1:0] NEXT_VAL;
logic [11:0] NEXT_COLOR;
logic [5:0] NEXT_ADDR;
logic [31:0] NEXT_DATA;
always_comb begin
Next_X = DrawX - 448;
Next_Y = DrawY - 208;
NEXTPOS_X = Next_X[7:4];
NEXTPOS_Y = Next_Y[7:4];
if ((Next_X >= 0) && (Next_X < 64) && (Next_Y >= 0) && (Next_Y < 64)) begin
	if (piece_buffer[NEXTPOS_Y][NEXTPOS_X]) begin
		NEXT_ADDR = {2'b11, Next_Y[3:0]};
	end
	else begin
		NEXT_ADDR = {2'b00, Next_Y[3:0]};
	end
end
else NEXT_ADDR = {6'b000000};
NEXT_VAL = NEXT_DATA[(31-{Next_X[3:0],1'b0})-:2];

case (NEXT_VAL)
    2'b00: NEXT_COLOR = COLOR_0; //accent 1
    2'b01: NEXT_COLOR = COLOR_1; //accent 2
    2'b10: NEXT_COLOR = COLOR_2; //black
    default: NEXT_COLOR = COLOR_3; //white
endcase
end //always_comb end

//	if (((DrawX > 432) && (DrawX < 528)) && ((DrawY > 192) && (DrawY < 288))) begin


drawing(.SPRITE_ADDR(SPRITE_ADDR), .SPRITE_DATA(SPRITE_DATA));

drawing next_piece(.SPRITE_ADDR(NEXT_ADDR), .SPRITE_DATA(NEXT_DATA));

palette level_colors(.LEVEL(LEVEL), .COLOR_0(COLOR_0), .COLOR_1(COLOR_1), .COLOR_2(COLOR_2), .COLOR_3(COLOR_3)); 

score_reg char_code(.*, .CHAR_ADDR(CHAR_ADDR), .CHAR_DATA(CHAR_DATA));

font_rom(.FONT_ADDR(FONT_ADDR), .FONT_DATA(FONT_DATA));
	
endmodule
