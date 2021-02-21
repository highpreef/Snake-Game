`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 07.10.2019 10:42:18
// Module Name: Multiplexer
// Project Name: Snake_game
// Target Devices: BASYS 3 FPGA
// Description: This module defines a 2 to 1 multiplexer to be used in the Snake_counter
//              module. It will output one of its 2 5 bit inputs depending on the control
//              signal.
// 
//////////////////////////////////////////////////////////////////////////////////


module Multiplexer(
    input CONTROL,          // Control Signal
    input [4:0] IN0,        // First Input Signal
    input [4:0] IN1,        // Second Input Signal
    output reg [4:0] OUT    // Output Signal
    );
    
    /* Define Combinational logig that outputs one of its 2 input depending on the control signal.
       A case statement is used to select the output based ont he control signal.
     */
    always@(CONTROL or IN0 or IN1) begin
        case (CONTROL)
            // If control signal is LOW, output first signal.
            1'b0 : OUT <= IN0;
            // If control signal is HIGH, output second signal.
            1'b1 : OUT <= IN1;
            // Define default output.
            default : OUT <= 5'b00000;
        endcase
    end
endmodule
