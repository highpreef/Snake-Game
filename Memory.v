`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 17.10.2019 11:15:54
// Module Name: Memory
// Project Name: Snake_game
// Target Devices: Basys 3 FPGA
// Description: This module serves the purpose of altering the input colour value using
//              synchronous logic to display the intended image at the current state of the
//              MSM following the design specifications.
//  
//////////////////////////////////////////////////////////////////////////////////


module Memory(
    input CLK,                    // 100MHz Basys 3 clock
    input [11:0] COLOUR_IN,       // Input colour value
    input [18:0] ADDR,            // Address of current pixel being displayed
    input [1:0] MSM_State,        // Current state of the MSM
    input [15:0] FrameCount,      // Value used for the 'winning screen' display
    output reg [11:0] COLOUR_OUT  // Output colour signal
    );
    
    /* Synchronous logic to change the colour of the current pixel being displayed depending
       on the current state of the MSM.
     */
    always@(posedge CLK) begin
        // If MSM is in the IDLE state, display the colour blue regardless of anything.
        if (MSM_State == 2'b00)
            COLOUR_OUT <= 12'h00F;
        // If MSM is the the GAME state, pass the value from the SNAKE_CONTROL module directly.
        else if (MSM_State == 2'b01)
            COLOUR_OUT <= COLOUR_IN;
        // If MSM is in the WIN state, use the 'FrameCount' value to produce a pattern on the screen.
        else if (MSM_State == 2'b10) begin
            if (ADDR[8:0] > 240) begin
                if (ADDR[18:9] > 320)
                    COLOUR_OUT <= FrameCount[15:8] + ADDR[7:0] + ADDR[16:9] - 240 - 320;
                else
                    COLOUR_OUT <= FrameCount[15:8] + ADDR[7:0] - ADDR[16:9] - 240 + 320;
            end
            else begin
                if (ADDR[18:9] > 320)
                    COLOUR_OUT <= FrameCount[15:8] - ADDR[7:0] + ADDR[16:9] + 240 - 320;
                else
                    COLOUR_OUT <= FrameCount[15:8] - ADDR[7:0] - ADDR[16:9] + 240 + 320;
            end
        end
        // Else statement to ensure that a value is always passed to COLOUR_OUT.
        else
            COLOUR_OUT <= 12'h000;
    end
    
endmodule
