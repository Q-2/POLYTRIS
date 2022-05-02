module statemachine (
    input  logic [1:0] rotate,
    input  logic       clearline,
    input  logic [7:0] keyboardinput,
    input  logic       pieceplaced,
    input  logic       placepiece,
    input  logic       ground_notif,
    input  logic [5:0] clearlineval,
    input  logic       piece_clk,

    output logic       SIG_FALL,
                       SIG_MOVELEFT,
                       SIG_MOVERIGHT,
                       SIG_KONAMI,
                       SIG_NONEINPUT
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
                       
                       
);
    always_ff @ (posedge piece_clk) begin
        piececlkreg = 1'b1
    end

    logic       piececlkreg
    logic [3:0] keyreg;
    enum logic [4:0]{
        //BASE STATE
        S_STALL
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
        S_LOGO,
    } State, Next_state
    always_ff @ (posedge Clk)
    begin
        if(RESET)
            State <= CLEARALL
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
        unique case (State)
            //BASE STATE
            S_STALL :
                if(keycode == KONAMI_KEYCODE)begin
                Next_state = S_KONAMI
                end
                else if(piececlkreg) begin
                Next_state = S_FALL
                piececlkreg = 0
                end
                else if(keycode == LEFT_KEYCODE)begin
                Next_state = S_MOVELEFT
                end
                else if(keycode == RIGHT_KEYCODE)begin
                Next_state = S_MOVERIGHT
                end
                else if(keycode == LEFT_ROTATE_KEYCODE)begin
                Next_state = S_ROTATELEFT_1
                end
                else if(keycode == RIGHT_ROTATE_KEYCODE)begin
                Next_state = S_ROTATERIGHT
                end
                else Next_state = SIG_NONEINPUT

            S_PIECEPLACED : //Todo need to write sandbox to gameboard
                Next_state = S_CLEARLINECHECK;
                SIG_PIECEPLACED = 1'b1;
            S_ROTATELEFT_1 :
                Next_state = S_ROTATELEFT_2;
                SIG_ROTATELEFT = 1'b1;
            S_ROTATELEFT_2 :
                Next_state = S_STALL;
                SIG_ROTATELEFT_2 = 1'b1;
            S_ROTATERIGHT :
                Next_state = S_ROTATERIGHT_2;
                SIG_ROTATERIGHT = 1'b1;
            S_ROTATERIGHT_2 :
                Next_state = S_STALL;
                SIG_ROTATERIGHT_2 = 1'b1;
            S_FALL :
                Next_state = S_FALL_2;
                SIG_FALL = 1'b1;
            S_FALL_2 :
                Next_state = S_STALL; //todo need to add ground counter logic.
                SIG_FALL = 1'b1;
            S_MOVELEFT :
                Next_state = S_STALL;
                SIG_MOVELEFT = 1'b1;
            S_MOVERIGHT :
                Next_state = S_STALL;
                SIG_MOVERIGHT = 1'b1;
            S_KONAMI :
                Next_state = S_STALL;
                SIG_KONAMI = 1'b1;
            S_NONEINPUT :
                Next_state = S_FALL_2;
                SIG_NONEINPUT = 1'b1;
            S_CLEARLINECHECK :
                Next_state = S_CLEARLINEACT;
                SIG_CLEARLINECHECK = 1'b1;
            S_CLEARLINEACT :
                Next_state = S_CLEARLINE;
                SIG_CLEARLINEACT = 1'b1;
            S_CLEARLINE :
                Next_state = S_PIECE_LOAD; //todo: need to add logic for looping checks of clearlines.
                //anguish
                SIG_CLEARLINE = 1'b1;
            S_HOLDPIECE :
                Next_state = S_HOLDPIECE_2;
                SIG_HOLDPIECE = 1'b1;
            S_HOLDPIECE_2 :
                Next_state = S_HOLDPIECE_3;
                SIG_HOLDPIECE_1 = 1'b1;

            S_HOLDPIECE_3 : 
                Next_state = S_STALL;
                SIG_HOLDPIECE_2 = 1'b1;
            S_ENDGAME :
                if(keyboardinput != 9'b000000000)
                    Next_state = S_LOGO;
                    //TODO SIG
            S_CLEARALL :
                Next_state = S_ENDGAME;
                //TODO SIG
            //OTHER STATES :
            S_PIECE_LOAD : 
                Next_state = S_PIECE_INSERT;
                S_PIECE_LOAD = 1'b1;
            S_PIECE_INSERT :
                Next_state = S_STALL;
                S_PIECE_INSERT = 1'b1;
            S_LOGO :
                //TODO SIG
                if(keyboardinput)
                    Next_state = S_PIECE_LOAD;
            default: Next_state = S_STALL;
        endcase
    end
    


endmodule