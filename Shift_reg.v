`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.11.2019 10:29:55
// Design Name: 
// Module Name: Shift_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Shift_reg(
    CLK,    // Clock Signal
    TAP,    // Input value to LFSR
    OUT     // Current state of LFSR
    );
    
    // Make the length of the LFSR variable by making it a parameter.
    parameter REG_WIDTH = 8;
    
    input CLK;
    input TAP;
    // Output value length will be the input parameter.
    output [REG_WIDTH-1:0] OUT; 
    
    // Define register to hold current value of the LFSR.
    reg [REG_WIDTH-1:0] DTypes;
    
    // Define Synchronous logic to shift the LFSR with the input tap value
    always@(posedge CLK) begin
        DTypes <= {DTypes[REG_WIDTH-2:0], TAP};
    end
    
    // Use a continuous assignment to link the output to the current value of the LFSR.
    assign OUT = DTypes;
    
endmodule
