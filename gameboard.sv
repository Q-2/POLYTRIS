module gameboard (
    input logic [3:0]piece_buffer[3:0], //may need more bits
    input logic clk,
    input logic [31:0]board_data[30]
    input logic ROTATELEFT,  ROTATERIGHT, FALL, MOVELEFT, MOVERIGHT, PIECEPLACED, CLEARLINECHECK, CLEARLINEACT, CLEARLINE, KONAMI, NONEINPUT, HOLDPIECE, ENDGAME, CLEARALL,
    output logic [10:0] RAM_ROW_ADDR
    output logic RAM_WE, RAM_RE,
    output logic RAM_WRITEDATA
    output logic [3:0]collision,
    output logic [3:0]sandboxLR,
    output logic [4:0]sandboxUD,
    output logic [3:0]sandbox[3:0],
    output logic [5:0]clearlineval,
 );
/*
This module controls the rotations, translations, and collisions between board pieces and the board itself.

TODO: IMPLEMENT COLLISION LOGIC FOR TRANSLATIONS (Fall,Konami,L/R)  

*/
logic [15:0]interpreted_boarddata;
logic [3:0]preliminarysandbox[3:0];
logic [3:0]holdbox[3:0];
logic [3:0]board_data_slice[3:0]
int bitpair;
for(bitpair = 0; bitpair < 32; bitpair = bitpair + 2)begin
    interpreted_boarddata[bitpair/2] = board_data[bitpair] || board_data[bitpair+1]
end
if( PIECEPLACED ) begin
    sandbox = piece_buffer
end

if( ROTATELEFT ) begin
    //unfortunate but cheap rotation alg
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
            if((((sandboxLR + j) < 4) || ((sandbox+j) > 34) || ((sandboxLR + i) < 4) || ((sandboxLR + i) > 14))) begin
                board_data_slice[i][j] = 0
            end
            else begin
                board_data_slice = board_data[i+sandboxUD][j+sandboxLR]
            end
        end
    end
end
if(ROTATELEFT_2) begin
    int i;
    int j;
    for (i = 0; i < 4; i = i+1)begin
        for(j = 0; j < 4; j = j + 1)begin
            if(preliminarysandbox[i][j] &&( board_data[i+sandboxUD][j+sandboxLR] || board_data[i+sandboxUD][j+sandboxLR + 1]))begin
                collision[2] = 1'b1
            end
            else begin
                sandbox[i][j] = preliminarysandbox[i][j]
            end
        end
    end
end
if( ROTATERIGHT ) begin
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
if(ROTATERIGHT_2) begin
    int i;
    int j;
    for (i = 0; i < 4; i = i+1)begin
        for(j = 0; j < 4; j = j + 1)begin
            if(preliminarysandbox[i][j] &&( board_data[i+sandboxUD][j+sandboxLR] || board_data[i+sandboxUD][j+sandboxLR + 1]))begin
                collision[2] = 1'b1
            end
            else begin
                sandbox[i][j] = preliminarysandbox[i][j]
            end
        end
    end
end
//If collision[x] == 0, then we won't collide when we try to move. Up/Down/Left/Right = 0/1/2/3
if( FALL ) begin
    if(collision[1] == 1'b0)begin
        sandboxUD = sandboxUD + 1
    end 
end

if( MOVELEFT ) begin
    if(collision[2] == 1'b0)begin
        sandboxLR = sandboxLR - 1
    end
end

if( MOVERIGHT ) begin
    if(collision[3] == 1'b0)begin
        sandboxLR = sandboxLR + 1
    end
end

if( KONAMI ) begin
    if(collision[0] == 1'b0)begin
        else sandboxUD = sandboxUD - 1
    end
end 
if( NONEINPUT ) begin
//not really handled here.
//basically, if there's no input then the block should lock in faster.
end

if( CLEARLINECHECK )begin
  //clock fuckery
    int i;
    for(i = 0; i < 30; i = i+1)begin
        if(interpretedboard_data[i] == 16'b1111111111111111)begin
            clearlineval = i
        end
    end
end

if( CLEARLINEACT )begin
    board_data[clearlineval:0] = board_data[clearlineval-1:0] //pulls values down
    clearlineval = 6'b11111
end

if( CLEARLINE )begin
    //doesn't happen here -- if clearlineval = 31 (outside range) then we loop back to check
end

if( HOLDPIECE )begin
    holdbox = sandbox;
    sandboxLR = DEFAULTPOSLR;
    sandboxUD = DEFAULTPOSUD; //currently just moves ur piece back to top
end

if( HOLDPIECE_2)begin
end
 
if( ENDGAME )begin

end

if( CLEARALL )begin
    int i;
    for(i = 0; i<30; i = i+1)begin
        board_data[i] = 0
    end
    int j
    for(i = 0; i<4; i = i + 1)begin
        for(j = 0; j < 4; j = j + 1)begin
        holdbox[i][j] = 0
        sandbox[i][j] = 0
        end 
    end
end