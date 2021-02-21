`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 07.10.2019 09:22:55
// Module Name: Seg7Display
// Project Name: Snake_game
// Target Devices: BASYS 3 FPGA
// Description: This module decodes an input binary number and select signal into
//              outputs that can be fed into the 7-segment display in order to display
//              the input binary number in decimal on the selected 7-segment display.
// 
//////////////////////////////////////////////////////////////////////////////////


module Seg7Display(
    input [1:0] SEG_SELECT_IN,          // Value for selecting which 7-segment display to activate
    input [3:0] BIN_IN,                 // Value of binary number intended to decode into a decimal number on the 7-segment display
    input DOT_IN,                       // Value of the DOT pin for the 7-segment display 
    output reg [3:0] SEG_SELECT_OUT,    // Output signal for selection on 7-segment displays
    output reg [7:0] HEX_OUT            // Output signal for pin assertions on the chosen 7-segment display
    );
    
    /* Define combinatorial logic to create the SEG_SELECT_OUT signal based on the value of SEG_SELECT_IN.
       This output will select which 7-segment display to activate.
     */
    always@(SEG_SELECT_IN) begin
        case (SEG_SELECT_IN)
            // If value is 00 activate the last 7-segment display.
            2'b00 : SEG_SELECT_OUT <= 4'b1110;
            // If value is 01 activate the second to last 7-segment display.
            2'b01 : SEG_SELECT_OUT <= 4'b1101;
            // If value is 10 activate the second 7-segment display.
            2'b10 : SEG_SELECT_OUT <= 4'b1011;
            // If value is 11 activate the first 7-segment display.
            2'b11 : SEG_SELECT_OUT <= 4'b0111;
            // Define default output value
            default : SEG_SELECT_OUT <= 4'b1111;
        endcase
    end
    
    /* Define combinatorial logic to decode the input binary value plus the DOT signal into the
       accepted format for the 7-segment display. This value will be displayed on the selected
       7-segment display.
     */
    always@(BIN_IN or DOT_IN) begin
        case (BIN_IN)
            /* For each value of the binary input output the respective 7-bit binary number which 
               selects which pins to activate in order to display the input number.
             */
            4'h0 : HEX_OUT[6:0] <= 7'b1000000;
            4'h1 : HEX_OUT[6:0] <= 7'b1111001;
            4'h2 : HEX_OUT[6:0] <= 7'b0100100;
            4'h3 : HEX_OUT[6:0] <= 7'b0110000;
            
            4'h4 : HEX_OUT[6:0] <= 7'b0011001;
            4'h5 : HEX_OUT[6:0] <= 7'b0010010;
            4'h6 : HEX_OUT[6:0] <= 7'b0000010;
            4'h7 : HEX_OUT[6:0] <= 7'b1111000;
            
            4'h8 : HEX_OUT[6:0] <= 7'b0000000;
            4'h9 : HEX_OUT[6:0] <= 7'b0011000;
            4'hA : HEX_OUT[6:0] <= 7'b0001000;
            4'hB : HEX_OUT[6:0] <= 7'b0000011;
            
            4'hC : HEX_OUT[6:0] <= 7'b1000110;
            4'hD : HEX_OUT[6:0] <= 7'b0100001;
            4'hE : HEX_OUT[6:0] <= 7'b0000110;
            4'hF : HEX_OUT[6:0] <= 7'b0001110;
            
            // define default value
            default : HEX_OUT[6:0] <= 7'b1111111;
        endcase
        
        // Pass the value of the DOT directly into the MSB of the output signal.
        HEX_OUT[7] <= DOT_IN;
    end
endmodule
