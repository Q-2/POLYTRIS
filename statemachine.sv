module statemachine (
    input  logic [1:0] rotate,
    input  logic       clearline,
    input  logic [7:0] keyboardinput,
    input  logic       pieceplaced,
    input  logic       placepiece,
    input  logic       ground_notif,
    input  logic [5:0] clearlineval,
	input  logic 	   CLK,
	input logic		   RESET,
    input logic [29:0] clearlineflags,
    input logic [3:0] ground_counter,

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
                       SIG_LOGO, //TODO: ADDED BY CONNIE
					   SIG_LOADPIECE,
    output  logic       piece_clk,
    output logic [4:0] State_out

                       
);
		  parameter KONAMI_KEYCODE = 8'h1a; 
		  parameter LEFT_KEYCODE = 8'h04;
		  parameter RIGHT_KEYCODE = 8'h07;
		  parameter LEFT_ROTATE_KEYCODE = 8'h14;
		  parameter RIGHT_ROTATE_KEYCODE = 8'h08;
          parameter SOFT_DROP_KEYCODE = 8'h18;
          parameter HOLDPIECE_KEYCODE = 8'h0f;
          parameter CLEARALL_KEYCODE = 8'h13;

assign State_out = State;
		
		
//clock for falling pieces
logic drop;
logic LEVEL;
clk_two_electric_boogaloo game_clock(
	.CLK(CLK),
	.RESET(RESET),
	.drop(drop),
	.level(LEVEL),
	.piece_clk(piece_clk)
);
logic moveleftreg, moverightreg, moveupreg, movedownreg, rotateleftreg, rotaterightreg;
logic moveleftkey, moverightkey, moveupkey, movedownkey, rotateleftkey, rotaterightkey;
logic dlayleftkey, dlayrightkey, dlayupkey, dlaydownkey, delayrleftkey, delayrrightkey;
	

	always_ff @ (posedge CLK)begin
	moveleftkey <= (keyboardinput == LEFT_KEYCODE);
	moverightkey <= (keyboardinput == RIGHT_KEYCODE);
	moveupkey <= (keyboardinput == KONAMI_KEYCODE);
	movedownkey <= (piece_clk);
	rotateleftkey <= (keyboardinput == LEFT_ROTATE_KEYCODE);
	rotaterightkey <= (keyboardinput == RIGHT_ROTATE_KEYCODE);
	dlayleftkey <= moveleftkey;
	dlayrightkey <= moverightkey;
	dlaydownkey <= movedownkey;
	dlayupkey <= moveupkey;
	delayrleftkey <= rotateleftkey;
	delayrrightkey <= rotaterightkey;
	if((moveleftkey != dlayleftkey) & (moveleftkey == 1'b1))
		moveleftreg <= 1;
	else if(SIG_MOVELEFT)
		moveleftreg <= 0;
		
		
	if((moverightkey != dlayrightkey) & (moverightkey == 1'b1)) 
		moverightreg <= 1;
	else if(SIG_MOVERIGHT)
		moverightreg <= 0;
		
		
	if((moveupkey != dlayupkey) & (moveupkey == 1'b1)) 
		moveupreg <= 1;
	else if(SIG_KONAMI)
		moveupreg <= 0;
		
	if((movedownkey != dlaydownkey) & (movedownkey == 1'b1))
		movedownreg <= 1;
	else if(SIG_FALL)
		movedownreg <= 0;
		
	if((rotateleftkey != delayrleftkey) & (rotateleftkey == 1'b1))
		rotateleftreg <= 1;
	else if(SIG_MOVELEFT)
		rotateleftreg <= 0;	
		
		
	if((rotaterightkey != delayrrightkey) & (rotaterightkey == 1'b1))
		rotaterightreg <= 1;
	else if(SIG_MOVELEFT)
		rotaterightreg <= 0;	
	end

    logic       piececlkreg;
    logic [3:0] keyreg;
    enum logic [4:0]{
        //BASE STATE
        S_STALL,    //0
        //GAMEBOARD RELEVANT STATES
        S_PIECEPLACED, //1
        S_PIECEPLACED_1, //2
        S_PIECEPLACED_2, //3
        S_PIECEPLACED_3, //4
        S_ROTATELEFT_1, //5
        S_ROTATELEFT_2, //6
        S_ROTATERIGHT_1, //7
        S_ROTATERIGHT_2, //8
        S_FALL, //9
        S_FALL_2, //10
        S_MOVELEFT, //11
        S_MOVERIGHT, //12
        S_KONAMI, //13
        S_NONEINPUT, //14
        S_CLEARLINECHECK, //15
        S_CLEARLINEACT, //16
        S_CLEARLINE, //17
        S_HOLDPIECE, //18
        S_HOLDPIECE_2, //19
        S_HOLDPIECE_3, //20
        S_ENDGAME, //21
        S_CLEARALL, //22
        //
        //OTHER STATES:
        //
        S_PIECE_LOAD, //23
        S_PIECE_INSERT, //24
        S_LOGO, //25
		S_LOADPIECE // don't use plz, not sure why it even exists. 26
    } State, Next_state;
    always_ff @ (posedge CLK)
    begin
        if(keyboardinput == CLEARALL_KEYCODE)
            State <= S_CLEARALL;
        else
            State = Next_state;
    end
    always_comb
    begin
    //soft drop case
    if (keyboardinput == SOFT_DROP_KEYCODE) begin
        drop = 1;
    end
    else begin
        drop = 0;
    end
        //default signals go here
        //this is where i learned about vscode ctrl+alt+up/down
        //sorry it's ugly but it was very satisfying to write.
        //they're all zero.
        //SIG_ indicates a signal for other parts of the design.
                Next_state = State;
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
                SIG_LOADPIECE = 1'b0;

        unique case (State)
            //BASE STATE
            S_STALL : begin
                if (ground_counter == 4'b1111) begin
                Next_state = S_PIECE_INSERT;
                end
                else if(moveupreg)begin
                Next_state = S_KONAMI;
                end
                else if(movedownreg)begin
                Next_state = S_FALL;               
                end
                else if(moveleftreg)begin
                Next_state = S_MOVELEFT;
                end
                else if(moverightreg)begin
                Next_state = S_MOVERIGHT;
                end
                else if(rotateleftreg)begin
                Next_state = S_ROTATELEFT_1;
                end
                else if(rotaterightreg)begin
                Next_state = S_ROTATERIGHT_1;
                end
                else if(keyboardinput == HOLDPIECE_KEYCODE)begin
                Next_state = S_HOLDPIECE;
                end
                else if(keyboardinput == CLEARALL_KEYCODE)begin
                Next_state = S_CLEARALL;
                end
                else Next_state = State;
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
                Next_state = S_STALL;
            S_FALL_2 :
                Next_state = S_STALL; //todo need to add ground counter logic.
            S_MOVELEFT :
                Next_state = S_STALL;
            S_MOVERIGHT :
                Next_state = S_STALL;
            S_KONAMI :
                Next_state = S_STALL;
            S_NONEINPUT :
                Next_state = S_STALL;
            S_CLEARLINECHECK :
                Next_state = S_CLEARLINEACT;
            S_CLEARLINEACT :
                Next_state = S_CLEARLINE;
            S_CLEARLINE :
                if(clearlineflags != 20'b00000000000000000000)
                    Next_state = S_CLEARLINEACT;
                else Next_state = S_PIECE_LOAD;
                //anguish
            S_HOLDPIECE :
                Next_state = S_HOLDPIECE_2;
            S_HOLDPIECE_2 :
                Next_state = S_HOLDPIECE_3;

            S_HOLDPIECE_3 : 
                Next_state = S_STALL;
            S_ENDGAME :
            begin
                if(keyboardinput != 9'b000000000)
                    Next_state = S_LOGO;
				else
				    Next_state = S_ENDGAME;
            end
                    //TODO SIG
            S_CLEARALL :
                Next_state = S_ENDGAME;
                //TODO SIG
            //OTHER STATES :
            S_PIECE_LOAD : 
                Next_state = S_STALL;
            S_PIECE_INSERT :
                Next_state = S_CLEARLINECHECK;
            S_LOGO :begin
                //TODO SIG
                if(keyboardinput != 9'b000000000)
                    Next_state = S_PIECE_LOAD;
                else begin
                    Next_state = State;
                end
            end
            default: Next_state = S_STALL;
        endcase
		  case (State)
            S_PIECEPLACED : //Todo need to write sandbox to gameboard
                SIG_PIECEPLACED = 1'b1;
            S_ROTATELEFT_1 : begin
                SIG_ROTATELEFT = 1'b1;
					 SIG_MOVELEFT = 1'b1;
					 end
            S_ROTATELEFT_2 :
                SIG_MOVERIGHT = 1'b1;
            S_ROTATERIGHT_1 : begin
                SIG_ROTATERIGHT = 1'b1;
					 SIG_MOVELEFT = 1'b1;
					 end
            S_ROTATERIGHT_2 :
                SIG_MOVERIGHT = 1'b1;
            S_FALL :
                SIG_FALL = 1'b1;
            S_FALL_2 :
                SIG_FALL = 1'b1; //todo need to add ground counter logic. AND FIGURE OUT IF YOU NEED ANOTHER VARIABLE
            S_MOVELEFT :
                SIG_MOVELEFT = 1'b1;
            S_MOVERIGHT :
                SIG_MOVERIGHT = 1'b1;
            S_KONAMI :
                SIG_KONAMI = 1'b1;
            S_NONEINPUT :
                SIG_NONEINPUT = 1'b1;
            S_CLEARLINECHECK :
                SIG_CLEARLINECHECK = 1'b1;
            S_CLEARLINEACT :
                SIG_CLEARLINEACT = 1'b1;
            S_CLEARLINE :
                SIG_CLEARLINE = 1'b1; //todo: need to add logic for looping checks of clearlines.
                //anguish
            S_HOLDPIECE :
                SIG_HOLDPIECE = 1'b1;
            S_HOLDPIECE_2 :
                SIG_HOLDPIECE_2 = 1'b1;
            S_HOLDPIECE_3 : 
                SIG_HOLDPIECE_3 = 1'b1;
            S_ENDGAME :
                SIG_ENDGAME = 1'b1;
            S_CLEARALL :
                SIG_CLEARALL = 1'b1;
            //OTHER STATES :
            S_PIECE_LOAD : 
                SIG_LOADPIECE = 1'b1;
            S_PIECE_INSERT :
                SIG_PIECEPLACED = 1'b1;
            S_LOGO :
					;
                //TODO SIG
                //TODO: wuh
            default : begin
            end
		endcase
    end
    
endmodule
