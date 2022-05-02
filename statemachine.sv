module statemachine (
    input  logic [1:0] rotate,
    input  logic       clearline,
    input  logic [7:0] keyboardinput,
    input  logic       pieceplaced,
    input  logic       placepiece,
    input  logic       ground_notif,
    input  logic [5:0] clearlineval,
    input  logic       piece_clk,
	 input  logic 		  CLK,
	 input logic		  RESET,

    output logic       SIG_FALL,
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
                       SIG_CLEARALL, //TODO: ADDED BY CONNIE
                       SIG_ENDGAME, //TODO: ADDED BY CONNIE
                       SIG_LOGO //TODO: ADDED BY CONNIE
                       
                       
);
		  parameter KONAMI_KEYCODE = 8'ha; //TODO: MKLBCHFTDFTYHUNJ
		  parameter LEFT_KEYCODE = 8'ha;
		  parameter RIGHT_KEYCODE = 8'ha;
		  parameter LEFT_ROTATE_KEYCODE = 8'ha;
		  parameter RIGHT_ROTATE_KEYCODE = 8'ha;
		  
    always_ff @ (posedge piece_clk) begin
        piececlkreg = 1'b1;
    end

    logic       piececlkreg;
    logic [3:0] keyreg;
    enum logic [4:0]{
        //BASE STATE
        S_STALL,
        //GAMEBOARD RELEVANT STATES
        S_PIECEPLACED,
        S_PIECEPLACED_1,
        S_PIECEPLACED_2,
        S_PIECEPLACED_3,
        S_ROTATELEFT_1,
        S_ROTATELEFT_2,
        S_ROTATERIGHT_1,
        S_ROTATERIGHT_2,
        S_FALL,
        S_FALL_2,
        S_MOVELEFT,
        S_MOVERIGHT,
        S_KONAMI,
        S_NONEINPUT,
        S_CLEARLINECHECK,
        S_CLEARLINEACT,
        S_CLEARLINE,
        S_HOLDPIECE,
        S_HOLDPIECE_2,
        S_HOLDPIECE_3,
        S_ENDGAME,
        S_CLEARALL,
        //
        //OTHER STATES:
        //
        S_PIECE_LOAD,
        S_PIECE_INSERT,
        S_LOGO
    } State, Next_state;
    always_ff @ (posedge CLK)
    begin
        if(RESET)
            State <= S_CLEARALL;
        else
            State = Next_state;
    end
    always_comb
    begin
        //default signals go here
        //this is where i learned about vscode ctrl+alt+up/down
        //sorry it's ugly but it was very satisfying to write.
        //they're all zero.
        //SIG_ indicates a signal for other parts of the design.
        SIG_FALL = 0;
        SIG_MOVELEFT = 0;
        SIG_MOVERIGHT = 0;
        SIG_KONAMI = 0;
        SIG_NONEINPUT = 0;
        SIG_CLEARLINECHECK = 0;
        SIG_CLEARLINEACT = 0;
        SIG_CLEARLINE = 0;
        SIG_PIECEPLACED = 0;
        SIG_ROTATELEFT = 0;
        SIG_ROTATELEFT_2 = 0;
        SIG_ROTATERIGHT = 0;
        SIG_ROTATERIGHT_2 = 0;
        SIG_HOLDPIECE = 0;
        SIG_HOLDPIECE_2 = 0;
        SIG_HOLDPIECE_3 = 0;
        SIG_CLEARALL = 0;
        SIG_ENDGAME = 0;
        SIG_LOGO = 0;

        unique case (State)
            //BASE STATE
            S_STALL : begin
                if(keyboardinput == KONAMI_KEYCODE)begin
                Next_state = S_KONAMI;
                end
                else if(piececlkreg) begin
                Next_state = S_FALL;
                piececlkreg = 0;
                end
                else if(keyboardinput == LEFT_KEYCODE)begin
                Next_state = S_MOVELEFT;
                end
                else if(keyboardinput == RIGHT_KEYCODE)begin
                Next_state = S_MOVERIGHT;
                end
                else if(keyboardinput == LEFT_ROTATE_KEYCODE)begin
                Next_state = S_ROTATELEFT_1;
                end
                else if(keyboardinput == RIGHT_ROTATE_KEYCODE)begin
                Next_state = S_ROTATERIGHT_1;
                end
                else Next_state = SIG_NONEINPUT;
					end
            S_PIECEPLACED : //Todo need to write sandbox to gameboard
                Next_state = S_CLEARLINECHECK;
            S_ROTATELEFT_1 :
                Next_state = S_ROTATELEFT_2;
            S_ROTATELEFT_2 :
                Next_state = S_STALL;
            S_ROTATERIGHT_1 :
                Next_state = S_ROTATERIGHT_2;
            S_ROTATERIGHT_2 :
                Next_state = S_STALL;
            S_FALL :
                Next_state = S_FALL_2;
            S_FALL_2 :
                Next_state = S_STALL; //todo need to add ground counter logic.
            S_MOVELEFT :
                Next_state = S_STALL;
            S_MOVERIGHT :
                Next_state = S_STALL;
            S_KONAMI :
                Next_state = S_STALL;
            S_NONEINPUT :
                Next_state = S_FALL_2;
            S_CLEARLINECHECK :
                Next_state = S_CLEARLINEACT;
            S_CLEARLINEACT :
                Next_state = S_CLEARLINE;
            S_CLEARLINE :
                Next_state = S_PIECE_LOAD; //todo: need to add logic for looping checks of clearlines.
                //anguish
            S_HOLDPIECE :
                Next_state = S_HOLDPIECE_2;
            S_HOLDPIECE_2 :
                Next_state = S_HOLDPIECE_3;

            S_HOLDPIECE_3 : 
                Next_state = S_STALL;
            S_ENDGAME :
                if(keyboardinput != 9'b000000000)
                    Next_state = S_LOGO;
					 else
						  Next_state = S_ENDGAME;
                    //TODO SIG
            S_CLEARALL :
                Next_state = S_ENDGAME;
                //TODO SIG
            //OTHER STATES :
            S_PIECE_LOAD : 
                Next_state = S_PIECE_INSERT;
            S_PIECE_INSERT :
                Next_state = S_STALL;
            S_LOGO :
                //TODO SIG
                if(keyboardinput)
                    Next_state = S_PIECE_LOAD;
            default: Next_state = S_STALL;
        endcase
		  case (State)
            S_PIECEPLACED : //Todo need to write sandbox to gameboard
                SIG_PIECEPLACED = 1;
            S_ROTATELEFT_1 :
                SIG_ROTATELEFT = 1;
            S_ROTATELEFT_2 :
                SIG_ROTATELEFT_2 = 1;
            S_ROTATERIGHT_1 :
                SIG_ROTATERIGHT = 1;
            S_ROTATERIGHT_2 :
                SIG_ROTATERIGHT_2 = 1;
            S_FALL :
                SIG_FALL = 1;
            S_FALL_2 :
                SIG_FALL = 1; //todo need to add ground counter logic. AND FIGURE OUT IF YOU NEED ANOTHER VARIABLE
            S_MOVELEFT :
                SIG_MOVELEFT = 1;
            S_MOVERIGHT :
                SIG_MOVERIGHT = 1;
            S_KONAMI :
                SIG_KONAMI = 1;
            S_NONEINPUT :
                SIG_NONEINPUT = 1;
            S_CLEARLINECHECK :
                SIG_CLEARLINECHECK = 1;
            S_CLEARLINEACT :
                SIG_CLEARLINEACT = 1;
            S_CLEARLINE :
                SIG_CLEARLINE = 1; //todo: need to add logic for looping checks of clearlines.
                //anguish
            S_HOLDPIECE :
                SIG_HOLDPIECE = 1;
            S_HOLDPIECE_2 :
                SIG_HOLDPIECE_2 = 1;
            S_HOLDPIECE_3 : 
                SIG_HOLDPIECE_3 = 1;
            S_ENDGAME :
                SIG_ENDGAME = 1;
                    //TODO SIG
            S_CLEARALL :
                SIG_CLEARALL = 1;
                //TODO SIG
            //OTHER STATES :
            S_PIECE_LOAD : 
                ; //TODO: wuh
            S_PIECE_INSERT :
                ; //TODO: wuh
            S_LOGO :
					;
                //TODO SIG
                //TODO: wuh

		  
		  endcase
    end
    


endmodule