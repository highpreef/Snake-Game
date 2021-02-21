`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 04.11.2019 10:44:30
// Module Name: Target_generator
// Project Name: Snake_game
// Target Devices: BASYS 3 FPGA
// Description: This module has the function of generating random addresses on the 
//              reduced resolution display range. This random address will represent 
//              the target for the snake game.
// 
//////////////////////////////////////////////////////////////////////////////////


module Target_generator(
    input CLK,                      // Clock Signal
    input RESET,                    // Reset Signal
    input REACHED_TARGET,           // Input signal representing whether the target has been reached or not
    input [1:0] MSM_State,          // Current state of the MSM
    output reg [14:0] TARGET_ADDR   // Output random address representing the current target
    );
    
    // Define wires for the random 8 and 7 bit binary values from the LFSRs.
    wire [7:0] SHIFTX;
    wire [6:0] SHIFTY;
    
    //Define wires for the random x and y coordinates. These values will be within the reduced resolution range of 160 by 120.
    reg [7:0] RANDX;
    reg [6:0] RANDY;
    // Define wires for the current inputs to the LFSRs.
    reg TAPX, TAPY;
    
    /* Define synchronous logic to calculate the input values to the LFSRs. The inputs will be 
       a linear function of the current state of the LFSRs. This function is well defined and will
       act to produce a pseudo number generator.
     */
    always@(posedge CLK) begin
        // Get input values as a function of the current state of the LFSRs as specified in the well defined documentation.
        TAPX <= SHIFTX[7] ~^ SHIFTX[5] ~^ SHIFTX[4] ~^ SHIFTX[3];
        TAPY <= SHIFTY[6] ~^ SHIFTY[5];
    end
    
    /* Initialize an instance of the Shift_reg module. This will act as the LFSR for the x-coordinate
       of the target, as such a random 8 bit value is needed thus the input parameter is set to 8. It
       takes an input tap value and outputs its current state.
     */
    Shift_reg # (
        .REG_WIDTH(8)
    ) shiftX (
        .CLK(CLK),
        .TAP(TAPX),
        .OUT(SHIFTX)
    );
    
    /* Initialize an instance of the Shift_reg module. This will act as the LFSR for the y-coordinate
       of the target, as such a random 7 bit value is needed thus the input parameter is set to 7. It
       takes an input tap value and outputs its current state.
     */
    Shift_reg # (
        .REG_WIDTH(7)
    ) shiftY (
        .CLK(CLK),
        .TAP(TAPY),
        .OUT(SHIFTY)
    );
    
    // Define synchronous logic to limit the LFSR output values to the reduced resolution range of 160 by 120.
    always@(posedge CLK) begin
        // The modulus operator is used to create values withing the required range.
        RANDX <= SHIFTX % 160;
        RANDY <= SHIFTY % 120;
    end
    
    // Define synchronous logic to update the current value of the output target address.
    always@(posedge CLK) begin
        // If the MSM is in the IDLE state or current target has been reached, update the current target to a new random address.
        if (REACHED_TARGET || (MSM_State == 2'b00))
            TARGET_ADDR <= {RANDX, RANDY};
        // Otherwise keep the current target address.
        else
            TARGET_ADDR <= TARGET_ADDR;
    end
    
endmodule
