`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 30.10.2019 16:46:12
// Module Name: Master_state_machine
// Project Name: Snake_game
// Target Devices: BASYS 3 FPGA
// Description: This module serves as the master state machine for the snake game.
//              It controls the most abstract states of the game while also controlling
//              the more specified state machines while also being controlled by them.
// 
//////////////////////////////////////////////////////////////////////////////////


module Master_state_machine(
    input CLK,              // Clock Signal
    input RESET,            // Reset Signal
    input BTNL,             // Left Button
    input BTNT,             // Top Button
    input BTNR,             // Right Button
    input BTND,             // Down Button
    input [3:0] SCORE,      // Current score of the snake game
    output [1:0] STATE_OUT  // Current state of the MSM
    );
    
    // Define registers to hold the values of the current MSM state and the next state.
    reg [1:0] Curr_state;
    reg [1:0] Next_state;
    
    /* Define the Sequential logic to update the value of the current state to the one
       holding the next state, as well as handling the reset signal in order to go to the 
       initial state whenever it is asserted.
     */
    always@(posedge CLK) begin
        if (RESET)
            Curr_state <= 2'b00;
        else
            Curr_state <= Next_state;
    end
    
    // Continuous assignment to link the current state to the output.
    assign STATE_OUT = Curr_state;
    
    /* Define Combinatorial logic to produce the value of the next state, so that it can
       then be used to update the value of the current state in the sequential logic. This
       logic will be executed whenever the current state changes, the buttons are pressed
       or the score value changes.
     */ 
    always@(Curr_state or BTNL or BTNT or BTNR or BTND or SCORE) begin
        case (Curr_state)
            // When in IDLE state, any button push takes the MSM to the next state, else stay in the same state.
            2'd0 : begin
                if (BTNL || BTNT || BTNR || BTND)
                    Next_state <= 2'd1;
                else
                    Next_state <= Curr_state;
            end
            /* When in GAME state, only move to next state once a score of 3 has been reached in the snake game, else
               stay in the same state.
             */
            2'd1 : begin
                if (SCORE == 3)
                    Next_state <= 2'd2;
                else
                    Next_state <= Curr_state;
            end
            // When in WIN state, remain in this state forever, until the RESET signal is asserted.
            2'd2 :
                Next_state <= Curr_state;
            // Default state is the IDLE state. 
            default :
                Next_state <= 2'd0;
        endcase
    end
    
endmodule
