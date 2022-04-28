module statemachine (
    input  logic [1:0] rotate,
    input  logic       clearline,
    input  logic [8:0] keyboardinput,
    input  logic       pieceplaced,
    input  logic       placepiece,
    input  logic       pogchamp,
    input  logic       ground_notif,
    input  logic [5:0] clearlineval,

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
    enum logic [4:0]{
        //GAMEBOARD RELEVANT STATES
        STATE_PIECEPLACED,
        STATE_ROTATELEFT_1,
        STATE_ROTATELEFT_2,
        STATE_ROTATERIGHT,
        STATE_ROTATERIGHT_2,
        STATE_FALL,
        STATE_FALL_2,
        STATE_MOVELEFT,
        STATE_MOVERIGHT,
        STATE_KONAMI,
        STATE_NONEINPUT,
        STATE_CLEARLINECHECK,
        STATE_CLEARLINEACT,
        STATE_CLEARLINE,
        STATE_HOLDPIECE,
        STATE_HOLDPIECE_2,
        STATE_HOLDPIECE_3,
        STATE_ENDGAME,
        STATE_CLEARALL,
        //
        //OTHER STATES:
        //
        STATE_PIECE_LOAD,
        STATE_PIECE_INSERT,
        STATE_LOGO,
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
        NONEINPU = 0;
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
                        //GAMEBOARD RELEVANT STATES
            STATE_PIECEPLACED : // todo all
            STATE_ROTATELEFT_1 :
            STATE_ROTATELEFT_2 :
            STATE_ROTATERIGHT :
            STATE_ROTATERIGHT_2 :
            STATE_FALL :
            STATE_FALL_2 :
            STATE_MOVELEFT :
            STATE_MOVERIGHT :
            STATE_KONAMI :
            STATE_NONEINPUT :
            STATE_CLEARLINECHECK :
            STATE_CLEARLINEACT :
            STATE_CLEARLINE :
            STATE_HOLDPIECE :
            STATE_HOLDPIECE_2 :
            STATE_HOLDPIECE_3 :
            STATE_ENDGAME :
            STATE_CLEARALL :
            //OTHER STATES :
            STATE_PIECE_LOAD :
            STATE_PIECE_INSERT :
            STATE_LOGO :
    end
    


endmodule