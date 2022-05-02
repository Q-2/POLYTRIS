module statemachine (
    input  logic [1:0] rotate,
    input  logic       clearline,
    input  logic [7:0] keyboardinput,
    input  logic       pieceplaced,
    input  logic       placepiece,
    input  logic       ground_notif,
    input  logic [5:0] clearlineval,
    input  logic       piece_clk,

    output logic       FALL,
                       MOVELEFT,
                       MOVERIGHT,
                       KONAMI,
                       NONEINPUT
                       CLEARLINECHECK,
                       CLEARLINEACT,
                       CLEARLINE,
                       PIECEPLACED,
                       ROTATELEFT,
                       ROTATELEFT_2,
                       ROTATERIGHT,
                       ROTATERIGHT_2,
                       HOLDPIECE,
                       HOLDPIECE_2,
                       HOLDPIECE_3,
                       
                       
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
        S_ROTATERIGHT,
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
        FALL = 0;
        MOVELEFT = 0;
        MOVERIGHT = 0;
        KONAMI = 0;
        NONEINPUT = 0;
        CLEARLINECHECK = 0;
        CLEARLINEACT = 0;
        CLEARLINE = 0;
        PIECEPLACED = 0;
        ROTATELEFT = 0;
        ROTATELEFT_2 = 0;
        ROTATERIGHT = 0;
        ROTATERIGHT_2 = 0;
        HOLDPIECE = 0;
        HOLDPIECE_2 = 0;
        HOLDPIECE_3 = 0;
        unique case (State)
            //BASE STATE
            S_STALL :
                if(keycode == KONAMI_KEYCODE)begin
                Next_state = KONAMI
                end
                else if(piececlkreg) begin
                Next_state = FALL
                piececlkreg = 0
                end
                else if(keycode == LEFT_KEYCODE)begin
                Next_state = MOVELEFT
                end
                else if(keycode == RIGHT_KEYCODE)begin
                Next_state = MOVERIGHT
                end
                else if(keycode == LEFT_ROTATE_KEYCODE)begin
                Next_state = ROTATELEFT
                end
                else if(keycode == RIGHT_ROTATE_KEYCODE)begin
                Next_state = ROTATERIGHT
                end
                else Next_state = NONEINPUT

            S_PIECEPLACED : //Todo need to write sandbox to gameboard
                Next_state = CLEARLINECHECK;
            S_ROTATELEFT_1 :
                Next_state = ROTATELEFT_2;
            S_ROTATELEFT_2 :
                Next_state = S_STALL;
            S_ROTATERIGHT :
                Next_state = ROTATERIGHT_2;
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
                Next_state = CLEARLINEACT;
            S_CLEARLINEACT :
                Next_state = CLEARLINE;
            S_CLEARLINE :
                Next_state = S_PIECE_LOAD; //todo: need to add logic for looping checks of clearlines.
            S_HOLDPIECE :
                Next_state = S_HOLDPIECE_2;
            S_HOLDPIECE_2 :
                Next_state = S_HOLDPIECE_3;
            S_HOLDPIECE_3 : 
                Next_state = S_STALL;
            S_ENDGAME :
                if(keyboardinput != 9'b000000000)
                    Next_state = S_LOGO;
            S_CLEARALL :
                Next_state = S_ENDGAME;
            //OTHER STATES :
            S_PIECE_LOAD : 
                Next_state = S_PIECE_INSERT;
            S_PIECE_INSERT :
                Next_state = S_STALL;
            S_LOGO :
                if(keyboardinput)
                    Next_state = S_PIECE_LOAD;
            default: Next_state = S_STALL;
        endcase
    end
    


endmodule