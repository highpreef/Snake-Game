`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 04.11.2019 11:00:58
// Module Name: Snake_counter
// Project Name: Snake_game
// Target Devices: BASYS 3 FPGA
// Description: This module has the function of keeping the score of the snake game.
//              It recieves a signal indicating the target has been reached after which
//              it updates the score value and passes the value through the 7-segment
//              decoder to get the output signals for displaying the score on the 7-segment
//              display.
// 
//////////////////////////////////////////////////////////////////////////////////


module Snake_counter(
    input CLK,                  // Clock Signal
    input RESET,                // Reset Signal
    input REACHED_TARGET,       // Input signal which is asserted for 2 clock cycles whenever the target is reached
    output [3:0] SEG_SELECT,    // Output signal for selecting which 7-segment display to display on
    output [7:0] HEX_OUT,       // Output signal for selecting which pins to activate on the 7-segment display
    output reg [3:0] SCORE     // Output signal representing the current score of the snake game
    );
    
    /* Declare wire to hold an enable signal that represents that the target has been reached
       and the score can be incremented.
     */
    wire ENABLE;
    
    /* Define Synchronous logic which increments the score value by 1 every time the target is reached.
       The score value is also reset to 0 whenever the RESET signal is asserted.
     */
    always@(posedge CLK) begin
        if (RESET)
            SCORE <= 0;
        else if (ENABLE)
            SCORE <= SCORE + 1;
    end
    
    // Define wires for the 17, 4 and 1 bit counter trigger output values.
    wire Bit17TriggOut, Bit4Out1, StrobeCount;
    
    // Define wires for the current count value of the 4 bit counters.
    wire [3:0] DecCount0;
    wire [3:0] DecCount1;
    
    /* Initialize an instance of generic counter to produce an output clock
       with a frequency of 10KHz to feed into the strobe counter.
     */
    Generic_counter # (
        .COUNTER_WIDTH(17),
        .COUNTER_MAX(99999)
        )
        Bit17Counter (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .DIRECTION(1'b1),
        .TRIG_OUT(Bit17TriggOut)
    );
    
    /* Initialize an instance of generic counter to produce a strobe signal
       that is fed into the multiplexer so that the value displayed on the 
       7-segment displays can be multiplexed. Only 2 7-segment displays will
       be used, so the strobe signal only needs to be 1 bit wide.
     */
    Generic_counter # (
        .COUNTER_WIDTH(1),
        .COUNTER_MAX(1)
        )
        Bit2Counter (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(Bit17TriggOut),
        .DIRECTION(1'b1),
        .COUNT(StrobeCount)
    );
    
    /* Initialize an instance of generic counter to produce an enable signal that is
       1 clock cycle wide so that it can be used to increment the score value. This counter
       is necessary as the REACHED_TARGET signal is asserted for 2 clock cycles.
     */
    Generic_counter # (
        .COUNTER_WIDTH(1),
        .COUNTER_MAX(1)
        )
        TARGET (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(REACHED_TARGET),
        .DIRECTION(1'b1),
        .TRIG_OUT(ENABLE)
    );
    
    /* Initialize an instance of generic counter to count the unit number of times the score
       value is incremented. The count value of this counter is stored for display on the 
       7-segment display. The trigger output of this counter will be used to enable the second
       4-bit counter.
     */
    Generic_counter # (
        .COUNTER_WIDTH(4),
        .COUNTER_MAX(9)
        )
        Bit4Counter1 (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(ENABLE),
        .DIRECTION(1'b1),
        .TRIG_OUT(Bit4Out1),
        .COUNT(DecCount1)
    );
    
    /* Initialize an instance of generic counter to count how many multiples of 10 the
       score value has been incremented by. This 4-bit counter is enabled by the previous one
       and its count value is stored to be displayed in the 7-segment display.
     */
    Generic_counter # (
        .COUNTER_WIDTH(4),
        .COUNTER_MAX(9)
        )
        Bit4Counter2 (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(Bit4Out1),
        .DIRECTION(1'b1),
        .COUNT(DecCount0)
    );
    
    //Define wires to connect the 4-bit count values plus the DOT bit.
    wire [4:0] DecCountAndDOT0;
    wire [4:0] DecCountAndDOT1;
    
    // Define a wire to connect the multiplexer output value.
    wire [4:0] MuxOut;
    
    /* Continuous assignments that concatenate the count value of the 4-bit counter with a DOT bit.
       The DOT bits are both set to 1 so the DOT pin is not asserted.
     */
    assign DecCountAndDOT0 = {1'b1, DecCount1};
    assign DecCountAndDOT1 = {1'b1, DecCount0};
    
    /* Initialize an instance of Multiplexer to create a 2 to 1 multiplexer that takes the strobe signal
       as the control signal and depending on it outputs one of the 2 count values to be displayed on the
       7-segment display.
     */
    Multiplexer Mux (
        .CONTROL(StrobeCount),
        .IN0(DecCountAndDOT0),
        .IN1(DecCountAndDOT1),
        .OUT(MuxOut)
    );
    
    /* Initialize an instance of the 7-segment decoder to produce the output signals necessary to display the 
       count values on the 7-segnment display. It takes the strobe signal and the multiplexer output as inputs.
     */
    Seg7Display Seg7 (
        .SEG_SELECT_IN({1'b0, StrobeCount}),
        .BIN_IN(MuxOut[3:0]),
        .DOT_IN(MuxOut[4]),
        .SEG_SELECT_OUT(SEG_SELECT),
        .HEX_OUT(HEX_OUT)
    );
    
endmodule
