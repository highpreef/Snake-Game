`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 17.10.2019 11:15:54
// Module Name: Generic_counter
// Project Name: Snake_game
// Target Devices: Basys 3 FPGA
// Description: This module implements a counter that counts from 0 to n and outputs
//              its current count values every clock cycle as well as a trigger output
//              that is a logic HIGH every time the counter reaches n.
//  
//////////////////////////////////////////////////////////////////////////////////


module Generic_counter(
        CLK,        // Clock signal
        RESET,      // Reset signal
        ENABLE,     // Enable signal
        DIRECTION,  // Direction of counting signal
        TRIG_OUT,   // Trigger output signal
        COUNT       // Current count value signal
    );
    
    // Declare the parameters for the count value width and max.
    parameter COUNTER_WIDTH = 4;
    parameter COUNTER_MAX = 9;
    
    input CLK;
    input RESET;
    input ENABLE;
    input DIRECTION;
    output TRIG_OUT;
    output [COUNTER_WIDTH-1:0] COUNT;
    
    // Declare and initialize registers to hold the values of the count and trigger during each clock cycle
    reg [COUNTER_WIDTH-1:0] count_value = 0;
    reg Trigger_out;
    
    /* Increment or decrement count value every clock cycle depending on the direction signal, reseting to either
       the max count value or 0 after it has counted n times. The reset signal takes the count value to 0.
     */
    always@(posedge CLK) begin
        if (RESET)
            count_value <= 0;
        else begin
            if (ENABLE) begin
                if (DIRECTION) begin
                    if (count_value == COUNTER_MAX)
                        count_value <= 0;
                    else
                        count_value <= count_value + 1;
                end
                else if (!DIRECTION) begin
                    if (count_value == 0)
                        count_value <= COUNTER_MAX;
                    else
                        count_value <= count_value - 1;
                end
            end
        end
    end
    
    /* Output a trigger signal each time the count value reaches the max value when the direction signal is HIGH,
       or 0 when the direction signal is LOW. The reset signal forces the trigger output to be a logic LOW.
     */
    always@(posedge CLK) begin
        if (RESET)
            Trigger_out <= 0;
        else begin
            if (DIRECTION) begin
                if (ENABLE && (count_value == COUNTER_MAX))
                    Trigger_out <= 1;
                else
                    Trigger_out <= 0;
            end
            else if (!DIRECTION) begin
                if (ENABLE && (count_value == 0))
                    Trigger_out <= 1;
                else
                    Trigger_out <= 0;
            end
        end
    end
    
    // Utilize a continuous assign statement to ling the registers to the output of the module.
    assign COUNT = count_value;
    assign TRIG_OUT = Trigger_out;
    
endmodule