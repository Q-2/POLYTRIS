module drawing(
    input [9:0] DrawX, DrawY,
    output 
);

//obtain board position
logic [8:0] BoardX, BoardY;
if ((DrawX > 240) && (DrawX < 400) && (DrawY > 80) && (DrawY < 400)) begin
    BoardX = DrawX - 240;
    BoardY = DrawY - 80;
end

/*
Block colors:
Each color is 12 bits, round each of the below
    level 0: 3d be ff       00 57 f7
    level 1: 7f d1 00       00 a7 00
    level 2: fa 77 fa       dd 02 cf
    level 3: 5b dc 58       00 58 fa
    level 4: 5b f9 9a       ef 00 5b
    level 5: 54 ef 92       6b 87 ff
    level 6: f9 36 01       7f 7f 7f
    level 7: 6b 45 ff       ab 00 20
*/
//color registers for the pieces, which correspond to each level
logic [11:0] PIECE_REG_0 [3];
logic [11:0] PIECE_REG_1 [3];
logic [11:0] PIECE_REG_2 [3];
logic [11:0] PIECE_REG_3 [3];
logic [11:0] PIECE_REG_4 [3];
logic [11:0] PIECE_REG_5 [3];
logic [11:0] PIECE_REG_6 [3];
logic [11:0] PIECE_REG_7 [3];

PIECE_REG_0[0] = 12h'4cf;
PIECE_REG_0[1] = 12h'06f;
PIECE_REG_0[2] = 12h'fff;

PIECE_REG_1[0] = 12h'8d0;
PIECE_REG_1[1] = 12h'0a0;
PIECE_REG_1[2] = 12h'fff;

PIECE_REG_2[0] = 12h'f7f;
PIECE_REG_2[1] = 12h'e0d;
PIECE_REG_2[2] = 12h'fff;

PIECE_REG_3[0] = 12h'6e6;
PIECE_REG_3[1] = 12h'06f;
PIECE_REG_3[2] = 12h'fff;

PIECE_REG_4[0] = 12h'6fa;
PIECE_REG_4[1] = 12h'f06;
PIECE_REG_4[2] = 12h'fff;

PIECE_REG_5[0] = 12h'5f9;
PIECE_REG_5[1] = 12h'78f;
PIECE_REG_5[2] = 12h'fff;

PIECE_REG_6[0] = 12h'f30;
PIECE_REG_6[1] = 12h'888;
PIECE_REG_6[2] = 12h'fff;

PIECE_REG_7[0] = 12h'74f;
PIECE_REG_7[1] = 12h'b02;
PIECE_REG_7[2] = 12h'fff;

/*
    background: 73 73 73    //gray
                00 00 00    //black
                ff ff ff    //white
                63 1d 00    //red
                99 f8 eb    //ice blue
*/
logic [11:0] BGD_REG [5];
BGD_REG[0] = 12'h777; //gray
BGD_REG[1] = 12'h000; //black
BGD_REG[2] = 12'hfff; //white
BGD_REG[3] = 12'h620; //red
BGD_REG[4] = 12'haff; //ice blue