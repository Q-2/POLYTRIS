module gameboard (
    input logic piece_clk,
    input logic piece_buffer, //may need more bits
    input logic clk,
    input logic reset 
    input logic drop
    input logic [1:0]rotate
    input logic state //may need more bits
    input logic board_height //may need more bits
    input logic board_width //may need more bits
    output logic board_data //may need more bits
    
);
/*
board reg byte biology!N
byte[0] = block old?
byte[1] = block curr?
byte[2-3] = block style
*/
//ram module goes here 
//todo: fix issue where they will do both for loops at once, flag system?
//

// Board Register Instantiation:
logic [3:0] game_board [29:0][9:0];
logic [3:0] copy_board [29:0][9:0];
//
if(state == LOSS || reset) begin
    for (int i = 0; i < 30; i++) begin
        for (int j = 0; j < 9; j++) begin
            game_board[i][j][3:0] = 4'b0000;
            copy_board[i][j][3:0] = 4'b0000;
        end
    end
end
always_ff @ posedge clk begin


if(state == FALL) begin
    for (int i = 0; i < 30; i++) begin
        for (int j = 0; j < 9; j++) begin
            copy_board[i][j][0] = game_board[i][j][0];
            copy_board[i][j][3:2] = game_board[i][j][3:2];
            copy_board[i+1][j][1] = game_board[i][j][1];
            
        end
    end
    for (int i = 0; i < 30; i++) begin
        for (int j = 0; j < 9; j++) begin
            if(~(copy_board[i][j][0] & copy_board[i][j][1])) begin
                game_board[i][j][3:0] = copy_board[i][j][3:0]
            end
        end
    end
end
if(state == MOVEL) begin
    for (int i = 0; i < 30; i++) begin
        for (int j = 0; j < 9; j++) begin
            copy_board[i][j][0] = game_board[i][j][0];
            copy_board[i][j][3:2] = game_board[i][j][3:2];
            copy_board[i][j-1][1] = game_board[i][j][1];
        end
    end
    for (int i = 0; i < 30; i++) begin
        for (int j = 0; j < 9; j++) begin
            if(~(copy_board[i][j][0] & copy_board[i][j][1])) begin
                game_board[i][j][3:0] = copy_board[i][j][3:0]
            end
        end
    end
end
if(state == MOVER) begin
    for (int i = 0; i < 30; i++) begin
        for (int j = 0; j < 9; j++) begin
            copy_board[i][j][0] = game_board[i][j][0];
            copy_board[i][j][3:2] = game_board[i][j][3:2];
            copy_board[i][j+1][1] = game_board[i][j][1];
        end
    end
    for (int i = 0; i < 30; i++) begin
        for (int j = 0; j < 9; j++) begin
            if(~(copy_board[i][j][0] & copy_board[i][j][1])) begin
                game_board[i][j][3:0] = copy_board[i][j][3:0]
            end
        end
    end
end

if(state == PIECE_PLACED) begin
    for (int i = 0; i < 30; i++) begin
        for (int j = 0; j < 9; j++) begin
            copy_board[i][j][0] = game_board[i][j][0] || game_board[i][j][1];
            copy_board[i][j][1] = 1'b0
        end
    end
    for (int i = 0; i < 30; i++) begin
        for (int j = 0; j < 9; j++) begin
            game_board[i][j][3:0] = copy_board[i][j][3:0]
        end
    end
end
if(state == NEW_PIECE) begin
piece_to_place = piece_buffer[0]
piece_buffer[0] = piece_buffer[1]
for (int i = 0; i < 9; i++) begin
        for (int j = 0; j < 9; j++) begin
            copy_board[i][j][0] = game_board[i][j][0] || game_board[i][j][1];
            copy_board[i][j][1] = 1'b0
        end
    end
end
if(rotate[0]) begin //right rotate
//todo

end
if(rotate[1]) begin //left rotate
//todo

end
endmodule