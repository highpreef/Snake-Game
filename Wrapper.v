`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 07.11.2019 21:48:58
// Module Name: Wrapper
// Project Name: Snake_game
// Target Devices: BASYS 3 FPGA
// Description: This module ties up all the individual modules essential to the 
//              snake game as well as their outputs and inputs to eachother. It
//              also outputs the required signal to the 7-segment display and the
//              VGA display.
// 
//////////////////////////////////////////////////////////////////////////////////


module Wrapper(
    input CLK,                  // Clock Signal
    input RESET,                // Reset Signal
    input BTNL,                 // Left Button
    input BTNT,                 // Top Button
    input BTNR,                 // Right Button
    input BTND,                 // Down Button
    output [11:0] COLOUR_OUT,   // Colour signal to the VGA output
    output HS,                  // Horizontal sync signal to the VGA output
    output VS,                  // Vertical sync signal to the VGA output
    output [3:0] SEG_SELECT,    // Output signal to the 7-segment displays to select which 7-segment display to use
    output [7:0] HEX_OUT        // Output signal to the selected 7-segment display to select which pins to activate 
    );
    
    // Declare wires to pass the states of the MSM and NSM.
    wire [1:0] MSM_State;
    wire [1:0] NSM_State;
    // Declare wire to pass the current score of the snake game.
    wire [3:0] SCORE;
    
    // Declare wires to pass the colour value of the current pixel being displayed and its address.
    wire [11:0] COLOUR_IN;
    wire [18:0] ADDRESS;
    // Declare wire to pass the 0.125s refresh signal.
    wire REF;
    
    // Declare wires to pass the REACHED_TARGET signal and the current target address.
    wire REACHED_TARGET;
    wire [14:0] TARGET_ADDR;
    
    /* Initialize an instance of the Master_state_machine  module which will control the most abstract state
       of the snake game. In each of the states it will control the other more specialized state machines
       while receiving their states in order to move states as well.
     */
    Master_state_machine MSM (
        .CLK(CLK),
        .RESET(RESET),
        .BTNL(BTNL),
        .BTNT(BTNT),
        .BTNR(BTNR),
        .BTND(BTND),
        .SCORE(SCORE),
        .STATE_OUT(MSM_State)
    );
    
    /* Initialize an instance of the Navigation_state_machine module which will control the current state
       of the direction of the state. Its output will be used to decide how to update the snake's
       position.
     */
    Navigation_state_machine NSM (
        .CLK(CLK),
        .RESET(RESET),
        .BTNL(BTNL),
        .BTNT(BTNT),
        .BTNR(BTNR),
        .BTND(BTND),
        .STATE_OUT(NSM_State)
    );
    
    /* Initialize an instance of the VGA_Wrapper module which will contain all the logic to produce the 
       outputs required to pass onto the VGA display. Its outputs will be dependant on the input
       colour value as well as the state of the MSM.
     */
    VGA_Wrapper VGA (
        .CLK(CLK),
        .COLOUR_IN(COLOUR_IN),
        .MSM_State(MSM_State),
        .ADDRESS(ADDRESS),
        .HS(HS),
        .VS(VS),
        .COLOUR_OUT(COLOUR_OUT),
        .REF(REF)
    );
    
    /* Initialize an instance of the Snake_counter module which will control the current score of the 
       snake game and output this to the 7-segment display. It will be dependant on the 
       REACHED_TARGET signal from the Snake_control module.
     */
    Snake_counter SNAKE_COUNTER (
        .CLK(CLK),
        .RESET(RESET),
        .REACHED_TARGET(REACHED_TARGET),
        .SEG_SELECT(SEG_SELECT),
        .HEX_OUT(HEX_OUT),
        .SCORE(SCORE)
    );
    
    /* Initialize an instance of the Target_generator module which will be responsible for generating
       the address of the current target and either keeping its value or return a new one depending on
       whether the target has been reached or not. It will be dependant on the REACHED_TARGET signal from
       the Snake_control module and state of the MSM.
     */
    Target_generator TARGET_GENERATOR (
        .CLK(CLK),
        .RESET(RESET),
        .REACHED_TARGET(REACHED_TARGET),
        .MSM_State(MSM_State),
        .TARGET_ADDR(TARGET_ADDR)
    );
    
    /* Initialize an instance of the Snake_control module which will control the current address of the
       snake and update it depending on the current state of the NSM. It will also be responsible for
       checking whether the target has been reached as well as displaying all the entities present in the
       snake game. It will be dependant on the state of the NSM, the state of the MSM, the address of the current
       pixel being displayed, the address of the target and the refresh signal.
     */
    Snake_control SNAKE_CONTROL (
        .CLK(CLK),
        .RESET(RESET),
        .MSM_State(MSM_State),
        .NSM_State(NSM_State),
        .TARGET_ADDR(TARGET_ADDR),
        .ADDRESS(ADDRESS),
        .REF(REF),
        .COLOUR_OUT(COLOUR_IN),
        .REACHED_TARGET(REACHED_TARGET)
    );
    
endmodule
