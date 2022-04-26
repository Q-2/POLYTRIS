module gameboard (
    input logic [3:0]piece_buffer[3:0], //may need more bits
    input logic clk,
    input logic [31:0]board_data
    input logic ROTATELEFT,  ROTATERIGHT, FALL, MOVELEFT, MOVERIGHT, PIECEPLACED, CLEARLINECHECK, CLEARLINEACT, CLEARLINE, KONAMI, NONEINPUT, HOLDPIECE, ENDGAME, CLEARALL,
    output logic [10:0] RAM_ROW_ADDR
    output logic RAM_WE, RAM_RE,
    input logic [31:0]RAM_READDATA
    output logic RAM_WRITEDATA
    output logic [3:0]collision
    output logic [3:0]sandboxLR
    output logic [4:0]sandboxUD
    output logic [3:0]sandbox[3:0]
 );
/*
This module controls the rotations, translations, and collisions between board pieces and the board itself.



*/
logic [15:0]interpreted_readdata
logic [3:0]sandboxLR = 4'd5
logic [4:0]sandboxUD = 5'd0
logic [3:0]sandbox[3:0]
logic [3:0]preliminarysandbox[3:0]
int bitpair
for(bitpair = 0; bitpair < 32; bitpair = bitpair + 2)begin
    interpreted_readdata[bitpair/2] = RAM_READDATA[bitpair] || RAM_READDATA[bitpair+1]
end
if(  PIECEPLACED ) begin
 sandbox = piece_buffer
end

if(  ROTATELEFT ) begin
/*
1 2 3 4            4 8 . .
5 6 7 8            3 7 . .
9 0 . .  ------>   2 6 0 .
13. . .            1 5 9 13
*/
    int i;
    int j;
    for(i = 0; i < 4 ; i = i + 1)begin
        for(j = 0; j < 4; j = j + 1)begin
        preliminarysandbox[i][j] = sandbox[i][3-j]
        end
    end
end

if(  ROTATERIGHT ) begin
/*
1 2 3 4            13 9 5 1
5 6 7 8             . . 6 2
9 . . .  ------>    . . 7 3
13. . .             . . 8 4
*/
    int i;
    int j;
    for(i = 0; i < 4 ; i = i + 1)begin
        for(j = 0; j < 4; j = j + 1)begin
        preliminarysandbox[i][j] = sandbox[3-i][j]
        end
    end

end
//If collision[x] == 1, then we won't collide when we try to move.
if(  FALL ) begin
    if(collision[0] == 1'b1)begin
        sandboxUD = sandboxUD + 1
    end 
end

if(  MOVELEFT ) begin
    if(collision[1] == 1'b1)begin
        sandboxLR = sandboxLR - 1
    end
end

if(  MOVERIGHT ) begin
    if(collision[2] == 1'b1)begin
        sandboxLR = sandboxLR + 1
    end
end

if(  KONAMI ) begin
    if(collision[3] == 1'b1)begin
        if(sandboxUD == 5'b00000) sandbox = 0
        else sandboxUD = sandboxUD - 1
    end
end
if(  NONEINPUT ) begin
//not really handled here.
//basically, if there's no input then the block should lock in faster.
end

if(  CLEARLINECHECK )begin

end

if(  CLEARLINEACT )begin
end

if(  CLEARLINE )begin
end

if(  HOLDPIECE )begin
end

if(  ENDGAME )begin
end

if(  CLEARALL )begin
end