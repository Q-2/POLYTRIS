module gameboard (
    input logic [3:0]piece_buffer[3:0], //may need more bits
    input logic CLK,
    input logic [31:0]board_data[30],
    input logic ROTATELEFT, ROTATELEFT_2, ROTATERIGHT, ROTATERIGHT_2, FALL, MOVELEFT, MOVERIGHT, PIECEPLACED, CLEARLINECHECK, CLEARLINEACT, CLEARLINE, KONAMI, NONEINPUT, HOLDPIECE, HOLDPIECE_2, HOLDPIECE_3, ENDGAME, CLEARALL, LOGO,
    output logic [10:0] RAM_ROW_ADDR,
    output logic RAM_WE, RAM_RE,
    output logic RAM_WRITEDATA,
    output logic [3:0]collision,
    output logic [3:0]sandboxLR,
    output logic [4:0]sandboxUD,
    output logic [3:0]sandbox[3:0],
    output logic [5:0]clearlineval
	 );
/*
This module controls the rotations, translations, and collisions between board pieces and the board itself.

TODO: IMPLEMENT COLLISION LOGIC FOR TRANSLATIONS (Fall,Konami,L/R)  

*/

parameter DEFAULTPOSLR = 8;
parameter DEFAULTPOSUD = 0; //18      17            16           15          14     13          12          11            10             9            8       7          6          5          4          3             2        1       0     
logic [18:0] State = {ROTATELEFT, ROTATELEFT_2, ROTATERIGHT, ROTATERIGHT_2, FALL, MOVELEFT, MOVERIGHT, PIECEPLACED, CLEARLINECHECK, CLEARLINEACT, CLEARLINE, KONAMI, NONEINPUT, HOLDPIECE, HOLDPIECE_2, HOLDPIECE_3, ENDGAME, CLEARALL, LOGO}

logic [3:0]preliminarysandbox[3:0];
logic [3:0]holdbox[3:0];
logic [3:0]board_data_slice[3:0];
logic [4:0] row;
int bitpair;
always_ff @ (posedge CLK) begin
for (row=0; row < 30; row = row +1) begin
	for(bitpair = 0; bitpair < 20; bitpair = bitpair + 2) begin
		 interpreted_boarddata[row][bitpair/2] = board_data[row][bitpair] || board_data[row][bitpair+1];
	end
end
unique case (State)
PIECEPLACED : begin
    sandbox = piece_buffer;
end

ROTATELEFT : begin
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
            preliminarysandbox[i][j] = sandbox[i][3-j];
            if((((sandboxLR + j) < 4) || ((sandboxUD+j) > 34) || ((sandboxLR + i) < 4) || ((sandboxUD + i) > 14))) begin
                board_data_slice[i][j] = 0;
            end
            else begin
                board_data_slice[i][j] = board_data[i+sandboxUD][j+sandboxLR];
            end
        end
    end
end

int i;
int j;
ROTATELEFT_2 : begin
    for (i = 0; i < 4; i = i+1)begin
        for(j = 0; j < 4; j = j + 1)begin
            if(preliminarysandbox[i][j] &&( board_data[i+sandboxUD][j+sandboxLR] || board_data[i+sandboxUD][j+sandboxLR + 1]))begin
                collision[2] = 1'b1;
            end
            else begin
                sandbox[i][j] = preliminarysandbox[i][j];
            end
        end
    end
end
ROTATERIGHT : begin
/*
1 2 3 4            13 9 5 1
5 6 7 8             . . 6 2
9 . . .  ------>    . . 7 3
13. . .             . . 8 4
*/

    for(i = 0; i < 4 ; i = i + 1)begin
        for(j = 0; j < 4; j = j + 1)begin
        preliminarysandbox[i][j] = sandbox[3-i][j];
        end
    end
end
ROTATERIGHT_2 : begin

    for (i = 0; i < 4; i = i+1)begin
        for(j = 0; j < 4; j = j + 1)begin
            if(preliminarysandbox[i][j] &&( board_data[i+sandboxUD][j+sandboxLR] || board_data[i+sandboxUD][j+sandboxLR + 1]))begin
                collision[2] = 1'b1;
            end
            else begin
                sandbox[i][j] = preliminarysandbox[i][j];
            end
        end
    end
end
//If collision[x] == 0, then we won't collide when we try to move. Up/Down/Left/Right = 0/1/2/3
FALL : begin
    if(collision[1] == 1'b0)begin
        sandboxUD = sandboxUD + 1;
    end 
end

MOVELEFT : begin
    if(collision[2] == 1'b0)begin
        sandboxLR = sandboxLR - 1;
    end
end

MOVERIGHT : begin
    if(collision[3] == 1'b0)begin
        sandboxLR = sandboxLR + 1;
    end
end

KONAMI : begin
    if(collision[0] == 1'b0)begin
        sandboxUD = sandboxUD - 1;
    end
end
NONEINPUT : begin
//not really handled here.
//basically, if there's no input then the block should lock in faster.
end

CLEARLINECHECK : begin
  //clock fuckery

    for(i = 0; i < 30; i = i+1)begin
        if(interpreted_boarddata[i] == 16'b1111111111111111)begin
            clearlineval = i;
        end
    end
end
// //remove this
// if( CLEARLINEACT )begin
//     board_data[clearlineval:0] = board_data[clearlineval-1:0]; //pulls values down
//     clearlineval = 6'b11111;
// end

// if( CLEARLINE )begin
//     //doesn't happen here -- if clearlineval = 31 (outside range) then we loop back to check
// end

HOLDPIECE : begin
    holdbox = sandbox;
    sandboxLR = DEFAULTPOSLR;
    sandboxUD = DEFAULTPOSUD; //currently just moves ur piece back to top
end

HOLDPIECE_2 : begin
end
 
ENDGAME : begin

end

CLEARALL : begin
    // for(i = 0; i<30; i = i+1)begin
    //     board_data[i] = 0;
    // end
    for(i = 0; i<4; i = i + 1)begin
        for(j = 0; j < 4; j = j + 1)begin
        holdbox[i][j] = 0;
        sandbox[i][j] = 0;
        end 
    end
end
end
endcase
endmodule
