module score_reg (input [5:0] CHAR_ADDR,
                  output [7:0] CHAR_DATA);
always_comb begin
case (CHAR_ADDR)
6'd01: CHAR_DATA = 8'h0f;
6'd01: CHAR_DATA = 8'h0f;
6'd02: CHAR_DATA = 8'h0f;
6'd03: CHAR_DATA = 8'h0f;
6'd04: CHAR_DATA = 8'h0f;
6'd05: CHAR_DATA = 8'h0f;
6'd06: CHAR_DATA = 8'h0f;

6'd07: CHAR_DATA = 8'h0f;
6'd08: CHAR_DATA = 8'h0e;
6'd09: CHAR_DATA = 8'h0a;
6'd10: CHAR_DATA = 8'h0c;
6'd11: CHAR_DATA = 8'h0d;
6'd12: CHAR_DATA = 8'h0b;
6'd13: CHAR_DATA = 8'h0f;
//fourth row.
6'd14: CHAR_DATA = 8'h0f;
6'd15: CHAR_DATA = 8'h0f;
6'd16: CHAR_DATA = 8'h0f;
6'd17: CHAR_DATA = 8'h0f;
6'd18: CHAR_DATA = 8'h0f;
6'd19: CHAR_DATA = 8'h0f;
6'd20: CHAR_DATA = 8'h0f;

6'd21: CHAR_DATA = 8'h0f;
6'd22: CHAR_DATA = 8'h50;
6'd23: CHAR_DATA = 8'h4f;
6'd24: CHAR_DATA = 8'h47;
6'd25: CHAR_DATA = 8'h47;
6'd26: CHAR_DATA = 8'h59;
6'd27: CHAR_DATA = 8'h0f;

6'd28: CHAR_DATA = 8'h0f;
6'd29: CHAR_DATA = 8'h0f;
6'd30: CHAR_DATA = 8'h0f;
6'd31: CHAR_DATA = 8'h0f;
6'd32: CHAR_DATA = 8'h0f;
6'd33: CHAR_DATA = 8'h0f;
6'd34: CHAR_DATA = 8'h0f;

6'd35: CHAR_DATA = 8'h0f;
6'd36: CHAR_DATA = 8'h0f;
6'd37: CHAR_DATA = 8'h0f;
6'd38: CHAR_DATA = 8'h0f;
6'd39: CHAR_DATA = 8'h0f;
6'd40: CHAR_DATA = 8'h0f;
default: CHAR_DATA = 8'h0f;
endcase
end
endmodule
