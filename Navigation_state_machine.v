`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 04.11.2019 09:48:49
// Module Name: Navigation_state_machine
// Project Name: Snake_game
// Target Devices: BASYS 3 FPGA
// Description: This module serves as the navigation state machine for the snake game.
//              It controls the diretion in which the snake is currently moving and
//              outputs this to the external modules.
// 
//////////////////////////////////////////////////////////////////////////////////


module Navigation_state_machine(
    input CLK,              // Clock Signal
    input RESET,            // Reset Signal
    input BTNL,             // Left Button
    input BTNT,             // Top Button
    input BTNR,             // Right Button
    input BTND,             // Down Button
    output [1:0] STATE_OUT  // Current state of the NSM
    );
    
    // Define registers to hold the values of the current NSM state and the next state.
    reg [1:0] Curr_state;
    reg [1:0] Next_state;
        
    /* Define the Sequential logic to update the value of the current state to the one
       holding the next state, as well as handling the reset signal in order to go to the 
       default state whenever it is asserted.
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
       logic will be executed whenever the current state changes or the buttons are pressed.
     */ 
    always@(Curr_state or BTNL or BTNT or BTNR or BTND) begin
        case (Curr_state)
            /* State value of 0 represets the direction 'UP'. Can only move to the states
               corresponding to the directions 'RIGHT' or 'LEFT' from this state by pressing the 
               respective buttons, otherwise the NSM remains in this state.
             */
            2'd0 : begin
                if (BTNR)
                    Next_state <= 2'd1;
                else if (BTNL)
                    Next_state <= 2'd3;
                else
                    Next_state <= Curr_state;
            end
            /* State value of 1 represets the direction 'RIGHT'. Can only move to the states
               corresponding to the directions 'UP' or 'DOWN' from this state by pressing the 
               respective buttons, otherwise the NSM remains in this state.
             */
            2'd1 : begin
                if (BTND)
                    Next_state <= 2'd2;
                else if (BTNT)
                    Next_state <= 2'd0;
                else
                    Next_state <= Curr_state;
            end
            /* State value of 2 represets the direction 'DOWN'. Can only move to the states
               corresponding to the directions 'RIGHT' or 'LEFT' from this state by pressing the 
               respective buttons, otherwise the NSM remains in this state.
             */
            2'd2 : begin
                if (BTNL)
                    Next_state <= 2'd3;
                else if (BTNR)
                    Next_state <= 2'd1;
                else
                    Next_state <= Curr_state;
            end
            /* State value of 3 represets the direction 'LEFT'. Can only move to the states
               corresponding to the directions 'DOWN' or 'UP' from this state by pressing the 
               respective buttons, otherwise the NSM remains in this state.
             */
            2'd3 : begin
                if (BTNT)
                    Next_state <= 2'd0;
                else if (BTND)
                    Next_state <= 2'd2;
                else
                    Next_state <= Curr_state;
            end
            // Default state is set to 'UP'.
            default :
                Next_state <= 2'd0;
        endcase
    end
        
endmodule
