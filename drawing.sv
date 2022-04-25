module drawing(
    input [2:0] level,
	output [11:0] palette [3]
    );

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
logic [11:0] PIECE_REG_0 [4];
logic [11:0] PIECE_REG_1 [4];
logic [11:0] PIECE_REG_2 [4];
logic [11:0] PIECE_REG_3 [4];
logic [11:0] PIECE_REG_4 [4];
logic [11:0] PIECE_REG_5 [4];
logic [11:0] PIECE_REG_6 [4];
logic [11:0] PIECE_REG_7 [4];
always_comb begin
PIECE_REG_0[0] = 12'h4cf;
PIECE_REG_0[1] = 12'h06f;
PIECE_REG_0[2] = 12'hfff;
PIECE_REG_0[3] = 12'h000;

PIECE_REG_1[0] = 12'h8d0;
PIECE_REG_1[1] = 12'h0a0;
PIECE_REG_1[2] = 12'hfff;
PIECE_REG_1[3] = 12'h000;

PIECE_REG_2[0] = 12'hf7f;
PIECE_REG_2[1] = 12'he0d;
PIECE_REG_2[2] = 12'hfff;
PIECE_REG_2[3] = 12'h000;

PIECE_REG_3[0] = 12'h6e6;
PIECE_REG_3[1] = 12'h06f;
PIECE_REG_3[2] = 12'hfff;
PIECE_REG_3[3] = 12'h000;

PIECE_REG_4[0] = 12'h6fa;
PIECE_REG_4[1] = 12'hf06;
PIECE_REG_4[2] = 12'hfff;
PIECE_REG_4[3] = 12'h000;

PIECE_REG_5[0] = 12'h5f9;
PIECE_REG_5[1] = 12'h78f;
PIECE_REG_5[2] = 12'hfff;
PIECE_REG_5[3] = 12'h000;

PIECE_REG_6[0] = 12'hf30;
PIECE_REG_6[1] = 12'h888;
PIECE_REG_6[2] = 12'hfff;
PIECE_REG_6[3] = 12'h000;

PIECE_REG_7[0] = 12'h74f;
PIECE_REG_7[1] = 12'hb02;
PIECE_REG_7[2] = 12'hfff;
PIECE_REG_7[3] = 12'h000;
end
endmodule
