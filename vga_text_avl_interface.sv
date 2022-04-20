/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

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
logic [10:0] FONT_ADDR;
logic [7:0]  FONT_DATA;
logic VGA_CLK;
logic blank;
logic sync;
//logic [31:0] LOCAL_REG       [`NUM_REGS];
logic [9:0] DrawX, DrawY; // Registers
//put other local variables here
logic write;
logic [3:0] FGD_R, FGD_G, FGD_B, BKG_R, BKG_G, BKG_B;
logic PIXEL_VAL;
logic [15:0] CHAR_VAL;
logic [6:0] REGPOS_Y;
logic [5:0] REGPOS_X;

//lab 7.2 new variables
logic [11:0] CHARLES;	//word address
logic [31:0] AGENT_Q;	//q_b output
logic [11:0] LSD_VISION; //colors
logic [3:0] FGD_ID, BKG_ID;
logic [3:0] FGD_REG, BKG_REG;
logic [11:0] FGD_LSD_COLOR, BKG_LSD_COLOR;

//Declare submodules..e.g. VGA controller, ROMS, etc

OCM Zuofu (
	.address_a(AVL_ADDR),
	.address_b(CHARLES),
	.byteena_a(AVL_BYTE_EN),
	.byteena_b(),
	.clock(CLK),
	.data_a(AVL_WRITEDATA),
	.data_b(),
	.rden_a(AVL_READ),
	.rden_b(VGA_CLK),
	.wren_a(AVL_WRITE),
	.wren_b(),
	.q_a(AVL_READDATA),
	.q_b(AGENT_Q)
);

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
                   
font_rom(
.addr(FONT_ADDR), 
.data(FONT_DATA)
);

//get colors from memory
logic [31:0] PALLET_REG [8];
always_ff @(posedge CLK) begin
    if ((AVL_ADDR[11]) && (AVL_WRITE))
		PALLET_REG[AVL_ADDR[2:0]]  <= AVL_WRITEDATA;
end


/* 
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
always_ff @(posedge CLK) begin
	if (AVL_WRITE) begin
		if(AVL_BYTE_EN[0])   LOCAL_REG[AVL_ADDR][7:0] <= AVL_WRITEDATA[7:0];
		if(AVL_BYTE_EN[1])   LOCAL_REG[AVL_ADDR][15:8] <= AVL_WRITEDATA[15:8];
		if(AVL_BYTE_EN[2])   LOCAL_REG[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
		if(AVL_BYTE_EN[3])	LOCAL_REG[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
	end
	if (AVL_READ) begin
		AVL_READDATA[31:0] = LOCAL_REG[AVL_ADDR][31:0];
	end
end
*/

always_comb begin
PIXEL_VAL = FONT_DATA[7-DrawX[2:0]]^CHAR_VAL[15];
FONT_ADDR = {CHAR_VAL[14:8], DrawY[3:0]};
REGPOS_Y = DrawY[9:4];
REGPOS_X = DrawX[9:4];
CHARLES = REGPOS_Y*40+REGPOS_X;
case(DrawX[3])
	1'b0: CHAR_VAL = AGENT_Q[15:0];
	1'b1: CHAR_VAL = AGENT_Q[31:16];
endcase

//sprite retrieval  |||  row major order, position row, col -> position by (row*Ncol + col)

//Color retrieval
LSD_VISION = CHAR_VAL[7:0];

//fgd color
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
else 
	BKG_LSD_COLOR = PALLET_REG[BKG_REG][24:13];
BKG_R = BKG_LSD_COLOR[3:0];
BKG_G = BKG_LSD_COLOR[7:4];
BKG_B = BKG_LSD_COLOR[11:8];
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

	
endmodule
