`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Univarsity of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 04.11.2019 21:01:01
// Module Name: Snake_control
// Project Name: Snake_game
// Target Devices: BASYS 3 FPGA
// Description: This module will control the main aspects of the snake game. It will
//              Update the position of the snake with a refresh signal and control 
//              the display of the snake game by dictating the colour of the current
//              pixels being displayed.
// 
//////////////////////////////////////////////////////////////////////////////////


module Snake_control(
    input CLK,                      // Clock Signal
    input RESET,                    // Reset Signal
    input [1:0] MSM_State,          // Current state of the MSM
    input [1:0] NSM_State,          // Current state of the NSM
    input [14:0] TARGET_ADDR,       // Address of the current target
    input [18:0] ADDRESS,           // Address of the pixel currently being displayed
    input REF,                      // Refresh signal which pulses every 0.125s
    output reg [11:0] COLOUR_OUT,   // Colour value of current pixel being displayed
    output reg REACHED_TARGET       // Signal representing whether the target has been reached or not
    );
    
    // Define parameters for the snake length and the range for the reduced resolution display range.
    parameter SnakeLength = 1;
    parameter MaxX = 159;
    parameter MaxY = 119;
    
    // Define 2D registers to hold the current address of the snake.
    reg [7:0] SnakeState_X [0:SnakeLength-1];
    reg [6:0] SnakeState_Y [0:SnakeLength-1];
    
    /* Define for loop which updates the value of the snake for the case when its length is larger than 1.
       It also resets the starting value of the snake whenever the RESET signal is asserted.
     */
    genvar PixNo;
    generate
        // For loop which shifts the address of the snake along its length.
        for (PixNo = 0; PixNo < SnakeLength-1; PixNo = PixNo+1)
        begin: PixShift
            always@(posedge CLK) begin
                if (RESET) begin
                    SnakeState_X[PixNo+1] <= 80;
                    SnakeState_Y[PixNo+1] <= 100;
                end
                else if (REF) begin
                    SnakeState_X[PixNo+1] <= SnakeState_X[PixNo];
                    SnakeState_Y[PixNo+1] <= SnakeState_Y[PixNo];
                end
            end
        end
    endgenerate
    
    /* Define Synchronous logic to update the head of the snake every time the refresh signal is asserted
       depending on the current state of the NSM.
     */
    always@(posedge CLK) begin
        // If the RESET signal is asserted, set the head of the snake to the intial value.
        if (RESET) begin
            SnakeState_X[0] <= 80;
            SnakeState_Y[0] <= 100;
        end
        // Else if the refresh signal is asserted and the MSM is in GAME mode update the address of the snake head.
        else if (REF && (MSM_State == 2'b01)) begin
            case (NSM_State)
                /* If the NSM state is 00 and the snake is not at the minimum vertical value decrease
                   the y-coordinate of the snake head (move UP). Otherwise set value of the snake head to
                   the maximum vertical value.
                 */
                2'b00 : begin
                    if (SnakeState_Y[0] == 0)
                        SnakeState_Y[0] <= MaxY;
                    else
                        SnakeState_Y[0] <= SnakeState_Y[0] - 1;
                end
                
                /* If the NSM state is 01 and the snake is not at the maximum horizontal value increase
                   the x-coordinate of the snake head (move RIGHT). Otherwise set value of the snake head to
                   the minimum horizontal value.
                 */
                2'b01 : begin
                    if (SnakeState_X[0] == MaxX)
                        SnakeState_X[0] <= 0;
                    else
                        SnakeState_X[0] <= SnakeState_X[0] + 1;
                end
                
                /* If the NSM state is 10 and the snake is not at the maximum vertical value increase
                   the y-coordinate of the snake head (move DOWN). Otherwise set value of the snake head to
                   the minimum vertical value.
                 */
                2'b10 : begin
                    if (SnakeState_Y[0] == MaxY)
                        SnakeState_Y[0] <= 0;
                    else
                        SnakeState_Y[0] <= SnakeState_Y[0] + 1;
                end
                
                /* If the NSM state is 11 and the snake is not at the minimum horizontal value decrease
                   the x-coordinate of the snake head (move LEFT). Otherwise set value of the snake head to
                   the maximum horizontal value.
                 */
                2'b11 : begin
                    if (SnakeState_X[0] == 0)
                        SnakeState_X[0] <= MaxX;
                    else
                        SnakeState_X[0] <= SnakeState_X[0] - 1;
                end
                
                // Define default case
                default : begin
                    SnakeState_X[0] <= SnakeState_X[0];
                    SnakeState_Y[0] <= SnakeState_Y[0];
                end
            endcase
        end
    end
    
    /* Define Synchronous logic to check whether the target has the same address as the snake head (target has been reached).
       If so assert the REACHED_TARGET signal, otherwise keep the signal LOW.
     */
    always@(posedge CLK) begin
        if ((SnakeState_X[0] == TARGET_ADDR[14:7]) && (SnakeState_Y[0] == TARGET_ADDR[6:0]) && (MSM_State == 2'b01))
            REACHED_TARGET <= 1;
        else
            REACHED_TARGET <= 0;
    end
        
    /* Define Synchronous logic to display the snake head, the target and the game area. Each entity has
       its own pixel colour which is output to the VGA Interface.
     */
    always@(posedge CLK) begin
        // If the current pixel being displayed belongs to the snake head, output a colour value representing yellow.
        if ((ADDRESS[18:11] == SnakeState_X[0]) && (ADDRESS[8:2] == SnakeState_Y[0]) && (MSM_State == 2'b01))
            COLOUR_OUT <= 12'hFF0;
        // If the current pixel being diplayed belongs to the target, output a colour value representing red.
        else if ((ADDRESS[18:11] == TARGET_ADDR[14:7]) && (ADDRESS[8:2] == TARGET_ADDR[6:0]) && (MSM_State == 2'b01))
            COLOUR_OUT <= 12'hF00;
        // Otherwise the current pixel being displayed should be coloured blue.
        else
            COLOUR_OUT <= 12'h00F;
    end

    
endmodule
