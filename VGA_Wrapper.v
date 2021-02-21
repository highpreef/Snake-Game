`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 17.10.2019 11:15:54
// Module Name: VGA_Wrapper
// Project Name: Snake_game
// Target Devices: Basys 3 FPGA
// Description: This module serves the purpose of tying up every module into a single one
//              which handles the I/O values and feeds them into the other modules.
//  
//////////////////////////////////////////////////////////////////////////////////


module VGA_Wrapper(
    input CLK,                  // Basys 3 integrated 100MHz clock
    input [11:0] COLOUR_IN,     // Input colour value
    input [1:0] MSM_State,      // Current state of the MSM
    output [18:0] ADDRESS,      // Address of current pixel being displayed
    output HS,                  // Horizontal sync signal
    output VS,                  // Vertical sync signal
    output [11:0] COLOUR_OUT,   // Output colour value
    output REF                  // Refresh signal that sends a pulse every 0.125s
    );
    
    /* Declare wire to pass the values of the full address of the pixel being currently displayed.
       The 10 MSB correspond to the x-coordinate while the 9 LSB correspond to the y-coordinate.
     */
    wire [18:0] ADDR;
    /* Declare wire to pass the value of COLOUR_IN to the VGA Interface after going through the necessary
       synchronous logic to alter it according to the constraints set by the design.
     */
    wire [11:0] COLOUR;
    
    /* Declare wires to pass the 25MHz clock signal and the end of frame signal. Also declare a register to
       hold the value of the 'FrameCount' signal which will be used for the 'winning screen' display.
     */
    wire Clock;
    wire endOfScreen;
    reg [15:0] FrameCount;
    
    /* Initialize an instance of generic counter to act as the 25MHz pixel clock, creating a logic HIGH every
       4 positive edges of the 100MHz Basys 3 clock, effectively outputting a 25MHz clock signal as its trigger
       output.
     */
    Generic_counter # (
        .COUNTER_WIDTH(2),
        .COUNTER_MAX(3)
        )
        CLOCK (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .DIRECTION(1'b1),
        .TRIG_OUT(Clock)
    );
    
    /* Initialize an instance of generic counter to produce the output refresh pulse. This module will count
       how many times a frame has been drawn in order to produce a pulse every 0.125s. Since this counter uses
       the 100MHz clock it will only need to count up to 30 in order to get a regular pulse every 0.125s.
     */
    Generic_counter # (
        .COUNTER_WIDTH(7),
        .COUNTER_MAX(30)
        )
        REFRESH (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(endOfScreen),
        .DIRECTION(1'b1),
        .TRIG_OUT(REF)
    );
    
    /* Initialize an instance of the Memory design source, which will act as a substitute RAM.
       It will then output a modified COLOUR_IN which denotes the colour of a specific pixel
       to be displayed at that time. It takes the address register as its input as well as the
       current state of the MSM and the 'FrameCount' value in order to modify the COLOUR_IN value
       through synchronous logic so that the intended output display can be observed.
     */
    Memory Logic (
        .CLK(CLK),
        .COLOUR_IN(COLOUR_IN),
        .ADDR(ADDR),
        .MSM_State(MSM_State),
        .FrameCount(FrameCount),
        .COLOUR_OUT(COLOUR)
    );      
    
    /* Initialize an instance of the VGA_Interface design source, which will produce all the
       required outputs to correctly display the intended image through VGA. It includes all
       the timing logic to produce the sync signals and the pixel address indices. It also
       outputs a signal that is asserted every time a frame has finished being drawn.
     */
    VGA_Interface Interface (
        .CLK(Clock),
        .COLOUR_IN(COLOUR),
        .ADDR(ADDR),
        .COLOUR_OUT(COLOUR_OUT),
        .HS(HS),
        .VS(VS),
        .endOfScreen(endOfScreen)
    );
    
    // Apply a continuous assignment for the Address register to the output
    assign ADDRESS = ADDR;
    
    /* Synchronous logic to update the value of 'FrameCount' every clock positive edge, which 
       will be used for the 'winning screen' display.
     */ 
    always@(posedge CLK) begin
        if (ADDR[8:0] == 479) begin
            FrameCount <= FrameCount + 1;
        end
    end
    
endmodule