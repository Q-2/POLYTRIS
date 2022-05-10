module gameboard_2(
    input logic [3:0]piece_buffer[3:0], //may need more bits
    input logic CLK,
    input logic ROTATELEFT, ROTATERIGHT, LOADPIECE, FALL, MOVELEFT, MOVERIGHT, PIECEPLACED, CLEARLINECHECK, CLEARLINEACT, CLEARLINE, KONAMI, NONEINPUT, HOLDPIECE, HOLDPIECE_2, HOLDPIECE_3, ENDGAME, CLEARALL, LOGO,
    input logic [3:0] PIECE_LENGTH,
    output logic [10:0] RAM_ROW_ADDR,
    output logic RAM_WE, RAM_RE,
    output logic RAM_WRITEDATA,
    output logic [5:0]collision,
    output logic [4:0]sandboxLR,
    output logic [5:0]sandboxUD,
    output logic [3:0]sandbox[3:0],
    output logic [5:0]clearlineval,
    output logic [29:0]clearlineflags,
    output logic [3:0]ground_counter,
    output logic [31:0]board_data[29:0],
    output logic [5:0]numberoflines

    );

parameter DEFAULTPOSLR = 6;
parameter DEFAULTPOSUD = 4;
logic [18:0] State;
logic [3:0]preliminaryRIGHT[3:0];
logic [3:0]holdbox[3:0];
logic BOARD_WRITE_EN;
int i;
int j;
logic [5:0]board_data_slice[5:0];
logic [9:0]interpreted_boarddata[30];

int row;
int bitpair;
logic JUNK; //just for the state thing
 //                      18      17            16           15          14     13          12          11            10             9            8       7          6          5          4          3             2        1       0     
assign State = {ROTATELEFT,    JUNK      , ROTATERIGHT, LOADPIECE   , FALL, MOVELEFT, MOVERIGHT, PIECEPLACED, CLEARLINECHECK, CLEARLINEACT, CLEARLINE, KONAMI, NONEINPUT, HOLDPIECE, HOLDPIECE_2, HOLDPIECE_3, ENDGAME, CLEARALL, LOGO};
logic [3:0]preliminaryLEFT[3:0];
logic [3:0]delayedprelLEFT[3:0];
logic [3:0]delayedprelRIGHT[3:0];
/////////////////////////////////////////////
/////////////////////////////////////////////
    always_ff @ (posedge CLK) begin
	 delayedprelLEFT <= preliminaryLEFT; 
	 delayedprelRIGHT <= preliminaryRIGHT; 
/////////////////////////////////////////////
    //Move Left
    if(State[13])
    begin
        if(~collision[2])
        sandboxLR <= sandboxLR - 1;
		  else;
    end
/////////////////////////////////////////////
    //Move Right
    else if(State[12])
    begin
        if(~collision[3])
        sandboxLR <= sandboxLR + 1;
    end

/////////////////////////////////////////////

    //Fall
    if(State[14])
    begin
        if(~collision[1])
        sandboxUD <= sandboxUD + 1;
        else begin
            ground_counter <= ground_counter  + 1;
        end
    end

/////////////////////////////////////////////
    //Up
    else if(State[7])
    begin
        if(~collision[0])
        sandboxUD <= sandboxUD - 1;
    end
/////////////////////////////////////////////
/////////////////////////////////////////////
    
    //Preliminary Left Rotate Board
    /*
    1 2 3 4            4 8 . .
    5 6 7 8            3 7 . .
    9 0 . .  ------>   2 6 0 .
    13. . .            1 5 9 13
    */
    for(i = 0; i < 4 ; i = i + 1)begin
        for(j = 0; j < 4; j = j + 1)begin
            preliminaryLEFT[j][3-i] <= sandbox[i][j];
        end
    end
/////////////////////////////////////////////
    
    //Preliminary Right Rotate Board
    /*
    1 2 3 4            13 9 5 1
    5 6 7 8             . . 6 2
    9 . . .  ------>    . . 7 3
    13. . .             . . 8 4
    */
    for(i = 0; i < 4 ; i = i + 1)begin
        for(j = 0; j < 4; j = j + 1)begin
        preliminaryRIGHT[3-j][i] <= sandbox[i][j];
        end
    end



/////////////////////////////////////////////
    //Rotate Left
    if(State[18])
    begin
        if(~collision[4])
            sandbox <= delayedprelLEFT;
    end


    //Rotate Right
    else if(State[16])
    begin
        if(~collision[5])
            sandbox <= delayedprelRIGHT;
    end
/////////////////////////////////////////////
/////////////////////////////////////////////
    //Clearline check (Sends a signal to the state machine and game board to clear specifed lines.)
    if(State[10])
    begin
        numberoflines <= 0;
        for(i = 0; i < 30; i = i + 1) begin
            if(interpreted_boarddata[i] == 10'b1111111111) //todo defined in always_comb block below
                clearlineflags[i] <= 1'b1;
            else
                clearlineflags[i] <= 1'b0;
        end
    end
    
/////////////////////////////////////////////
    //INSERT PIECE writes piece to board
    if(State[11])
    begin
       ground_counter <= 0;
       for(i = 0; i < 4; i = i + 1)begin
           for(j = 0; j < 4; j = j + 1)begin
               if((i + sandboxUD >= 3) && (j + sandboxLR >= 3) && (i + sandboxUD <= 32) && (i + sandboxLR  <= 12))begin
                   if(sandbox[i][j])
                       board_data[i + sandboxUD - 3][(j+sandboxLR-3)*2 + 1-:2] <=  ((PIECE_LENGTH % 3) + 1);
               end
           end
       end
    end
/////////////////////////////////////////////
    //clearline act
    else if(State[9])
    begin
        if (clearlineflags[0]) begin
            board_data[0] <= 32'h00000000;
            clearlineflags[0]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else;
        if (clearlineflags[1]) begin 
            board_data[1] <= board_data[0];
            clearlineflags[1]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[2]) begin
            board_data[2:1] <= board_data[1:0];
            clearlineflags[2]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[3]) begin
            board_data[3:1] <= board_data[2:0];
            clearlineflags[3]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[4]) begin
            board_data[4:1] <= board_data[3:0];
            clearlineflags[4]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[5]) begin
            board_data[5:1] <= board_data[4:0];
            clearlineflags[5]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[6]) begin
            board_data[6:1] <= board_data[5:0];
            clearlineflags[6]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[7]) begin
            board_data[7:1] <= board_data[6:0];
            clearlineflags[7]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[8]) begin
            board_data[8:1] <= board_data[7:0];
            clearlineflags[8]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[9]) begin
            board_data[9:1] <= board_data[8:0];
            clearlineflags[9]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[10]) begin
            board_data[10:1] <= board_data[9:0];
            clearlineflags[10]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[11]) begin
            board_data[11:1] <= board_data[10:0];
            clearlineflags[11]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[12]) begin
            board_data[12:1] <= board_data[11:0];
            clearlineflags[12]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[13]) begin
            board_data[13:1] <= board_data[12:0];
            clearlineflags[13]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[14]) begin
            board_data[14:1] <= board_data[13:0];
            clearlineflags[14]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[15]) begin
            board_data[15:1] <= board_data[14:0];
            clearlineflags[15]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[16]) begin
            board_data[16:1] <= board_data[15:0];
            clearlineflags[16]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[17]) begin
            board_data[17:1] <= board_data[16:0];
            clearlineflags[17]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[18]) begin
            board_data[18:1] <= board_data[17:0];
            clearlineflags[18]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[19]) begin
            board_data[19:1] <= board_data[18:0];
            clearlineflags[19]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[20]) begin
            board_data[20:1] <= board_data[19:0];
            clearlineflags[20]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[21]) begin
            board_data[21:1] <= board_data[20:0];
            clearlineflags[21]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[22]) begin
            board_data[22:1] <= board_data[21:0];
            clearlineflags[22]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[23]) begin
            board_data[23:1] <= board_data[22:0];
            clearlineflags[23]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[24]) begin
            board_data[24:1] <= board_data[23:0];
            clearlineflags[24]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[25]) begin
            board_data[25:1] <= board_data[24:0];
            clearlineflags[25]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[26]) begin
            board_data[26:1] <= board_data[25:0];
            clearlineflags[26]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[27]) begin
            board_data[27:1] <= board_data[26:0];
            clearlineflags[27]<= 0;
            numberoflines <= numberoflines + 1;
        end
        else if (clearlineflags[28]) begin
            board_data[28:1] <= board_data[27:0];
            clearlineflags[28]<= 0;
            numberoflines <= numberoflines + 1;
        end
		  else if (clearlineflags[29]) begin
            board_data[29:1] <= board_data[28:0];
            clearlineflags[29]<= 0;
            numberoflines <= numberoflines + 1;
			end
    end
/////////////////////////////////////////////
/////////////////////////////////////////////
    //Hold 
    if(State[4])
    //TODO: uhhh
    begin


    end
/////////////////////////////////////////////
/////////////////////////////////////////////
    //Loads piece from buffer
    if(State[15])
    begin
        sandbox <= piece_buffer;
        sandboxLR <= DEFAULTPOSLR;
        sandboxUD <= DEFAULTPOSUD;
    end
/////////////////////////////////////////////
/////////////////////////////////////////////
    //Clear All (Sets everything to zero; resets sandbox)
    if(State[1])
    begin
        for(i = 0; i < 4 ; i = i + 1)begin
            for(j = 0; j < 4; j = j + 1)begin
                preliminaryRIGHT[i][j] <= 0;
                preliminaryLEFT[i][j] <= 0;
                holdbox[i][j] <= 0;
            end
        end
        
        for(i = 0; i < 30 ; i = i + 1)begin
                board_data[i][31:0] <= 0;
		end
    end // end of always_ff

    end
    always_comb begin
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Collision bits (6 Bits long, each determines if attempting a move would collide)
    //[0] = Up
    //[1] = Fall
    //[2] = Move Left
    //[3] = Move Right
    //[4] = Rotate Left
    //[5] = Rotate Right
    //
    //Endgame: Freezes the Board, sets all collision = 1 to stop movement.
    for (row=0; row < 30; row = row +1) begin
	    for(bitpair = 0; bitpair < 20; bitpair = bitpair + 2) begin
		    interpreted_boarddata[row][bitpair/2] = (board_data[row][bitpair] || board_data[row][bitpair+1]);
	    end
    end
    ///how we do checking between sandbox and gameboard in vgatext
    // PIECE_STYLE = ((PIECE_LENGTH % 3) + 1)&SANDBOX[REGPOS_X - SANDBOX_X+3][REGPOS_Y - SANDBOX_Y+3];

    //     if ((REGPOS_X + 4>= SANDBOX_X ) && (REGPOS_X  <= SANDBOX_X - 1) && (REGPOS_Y + 4 >= SANDBOX_Y) && (REGPOS_Y <= SANDBOX_Y - 1)) begin
    //         VGA_DATA = {PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE, PIECE_STYLE};;
    //     end

    for(i = 0; i < 6 ; i = i + 1)begin
        for(j = 0; j < 6; j = j + 1)begin
            if((i + sandboxUD >= 4) && (i + sandboxUD <= 33) && (j + sandboxLR >= 4) && (j + sandboxLR <= 13)) begin
                board_data_slice[i][j] = interpreted_boarddata[i+sandboxUD-4][j+sandboxLR-4];
             end
            else begin
                board_data_slice[i][j] = 1'b1;
             end
        end	
    end
    //board data slice check same y but with all x + 1 to account for shifted center of game board data slice
    //Collision Up [0]         
		//collision[5:0] = 6'b000000;                                                                              //
        collision[0] =  (sandbox[0][0] && board_data_slice[0][1]) || (sandbox[0][1] && board_data_slice[0][2]) || (sandbox[0][2] && board_data_slice[0][3]) || (sandbox[0][3] && board_data_slice[0][4])
                     || (sandbox[1][0] && board_data_slice[1][1]) || (sandbox[1][1] && board_data_slice[1][2]) || (sandbox[1][2] && board_data_slice[1][3]) || (sandbox[1][3] && board_data_slice[1][4])
                     || (sandbox[2][0] && board_data_slice[2][1]) || (sandbox[2][1] && board_data_slice[2][2]) || (sandbox[2][2] && board_data_slice[2][3]) || (sandbox[2][3] && board_data_slice[2][4])
                     || (sandbox[3][0] && board_data_slice[3][1]) || (sandbox[3][1] && board_data_slice[3][2]) || (sandbox[3][2] && board_data_slice[3][3]) || (sandbox[3][3] && board_data_slice[3][4])  || ENDGAME || (sandboxUD == 0);
    //Collision Down[1] x + 1 and y + 2
        collision[1] =  (sandbox[0][0] && board_data_slice[2][1]) || (sandbox[0][1] && board_data_slice[2][2]) || (sandbox[0][2] && board_data_slice[2][3]) || (sandbox[0][3] && board_data_slice[2][4])
                     || (sandbox[1][0] && board_data_slice[3][1]) || (sandbox[1][1] && board_data_slice[3][2]) || (sandbox[1][2] && board_data_slice[3][3]) || (sandbox[1][3] && board_data_slice[3][4])
                     || (sandbox[2][0] && board_data_slice[4][1]) || (sandbox[2][1] && board_data_slice[4][2]) || (sandbox[2][2] && board_data_slice[4][3]) || (sandbox[2][3] && board_data_slice[4][4])
                     || (sandbox[3][0] && board_data_slice[5][1]) || (sandbox[3][1] && board_data_slice[5][2]) || (sandbox[3][2] && board_data_slice[5][3]) || (sandbox[3][3] && board_data_slice[5][4])  || ENDGAME || (sandboxUD == 32);

    //Collision Left[2] x + 0 and y + 1
        collision[2] =  (sandbox[0][0] && board_data_slice[1][0]) || (sandbox[0][1] && board_data_slice[1][1]) || (sandbox[0][2] && board_data_slice[1][2]) || (sandbox[0][3] && board_data_slice[1][3])
                     || (sandbox[1][0] && board_data_slice[2][0]) || (sandbox[1][1] && board_data_slice[2][1]) || (sandbox[1][2] && board_data_slice[2][2]) || (sandbox[1][3] && board_data_slice[2][3])
                     || (sandbox[2][0] && board_data_slice[3][0]) || (sandbox[2][1] && board_data_slice[3][1]) || (sandbox[2][2] && board_data_slice[3][2]) || (sandbox[2][3] && board_data_slice[3][3])
                     || (sandbox[3][0] && board_data_slice[4][0]) || (sandbox[3][1] && board_data_slice[4][1]) || (sandbox[3][2] && board_data_slice[4][2]) || (sandbox[3][3] && board_data_slice[4][3])  || ENDGAME || (sandboxLR == 0);

    //Collision Right[3] x + 2 and y + 1
        collision[3] =  (sandbox[0][0] && board_data_slice[1][2]) || (sandbox[0][1] && board_data_slice[1][3]) || (sandbox[0][2] && board_data_slice[1][4]) || (sandbox[0][3] && board_data_slice[1][5])
                     || (sandbox[1][0] && board_data_slice[2][2]) || (sandbox[1][1] && board_data_slice[2][3]) || (sandbox[1][2] && board_data_slice[2][4]) || (sandbox[1][3] && board_data_slice[2][5])
                     || (sandbox[2][0] && board_data_slice[3][2]) || (sandbox[2][1] && board_data_slice[3][3]) || (sandbox[2][2] && board_data_slice[3][4]) || (sandbox[2][3] && board_data_slice[3][5])
                     || (sandbox[3][0] && board_data_slice[4][2]) || (sandbox[3][1] && board_data_slice[4][3]) || (sandbox[3][2] && board_data_slice[4][4]) || (sandbox[3][3] && board_data_slice[4][5])  || ENDGAME || (sandboxLR == 12);

    //Collision Rotate Left [4] x+1 y+1
        collision[4] =  (preliminaryLEFT[0][0] && board_data_slice[1][1]) || (preliminaryLEFT[0][1] && board_data_slice[1][2]) || (preliminaryLEFT[0][2] && board_data_slice[1][3]) || (preliminaryLEFT[0][3] && board_data_slice[1][4])
                     || (preliminaryLEFT[1][0] && board_data_slice[2][1]) || (preliminaryLEFT[1][1] && board_data_slice[2][2]) || (preliminaryLEFT[1][2] && board_data_slice[2][3]) || (preliminaryLEFT[1][3] && board_data_slice[2][4])
                     || (preliminaryLEFT[2][0] && board_data_slice[3][1]) || (preliminaryLEFT[2][1] && board_data_slice[3][2]) || (preliminaryLEFT[2][2] && board_data_slice[3][3]) || (preliminaryLEFT[2][3] && board_data_slice[3][4])
                     || (preliminaryLEFT[3][0] && board_data_slice[4][1]) || (preliminaryLEFT[3][1] && board_data_slice[4][2]) || (preliminaryLEFT[3][2] && board_data_slice[4][3]) || (preliminaryLEFT[3][3] && board_data_slice[4][4]) || ENDGAME;
    //Collision Rotate Right[5]
        collision[5] =  (preliminaryRIGHT[0][0] && board_data_slice[1][1]) || (preliminaryRIGHT[0][1] && board_data_slice[1][2]) || (preliminaryRIGHT[0][2] && board_data_slice[1][3]) || (preliminaryRIGHT[0][3] && board_data_slice[1][4])
                     || (preliminaryRIGHT[1][0] && board_data_slice[2][1]) || (preliminaryRIGHT[1][1] && board_data_slice[2][2]) || (preliminaryRIGHT[1][2] && board_data_slice[2][3]) || (preliminaryRIGHT[1][3] && board_data_slice[2][4])
                     || (preliminaryRIGHT[2][0] && board_data_slice[3][1]) || (preliminaryRIGHT[2][1] && board_data_slice[3][2]) || (preliminaryRIGHT[2][2] && board_data_slice[3][3]) || (preliminaryRIGHT[2][3] && board_data_slice[3][4])
                     || (preliminaryRIGHT[3][0] && board_data_slice[4][1]) || (preliminaryRIGHT[3][1] && board_data_slice[4][2]) || (preliminaryRIGHT[3][2] && board_data_slice[4][3]) || (preliminaryRIGHT[3][3] && board_data_slice[4][4])  || ENDGAME;
    end

    endmodule