module statemachine (
    input [1:0] rotate,
    input       clearline,
    input [8:0] keyboardinput,
    input       pieceplaced,
    input       placepiece,
    input       pogchamp
    output [5:0] state
);
    enum logic [5:0]{
        logo,
        insertpiece,
        //FALL
            rotatel
            rotater
            movel,
            mover,
            fall,
            none,
        pieceplaced,
        clearlinecheck,
        clearlineact,
        clearline,
        holdpiece,
        endscreen,
        clearall,

    }




endmodule