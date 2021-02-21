`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 17.10.2019 11:15:54
// Module Name: VGA_Interface
// Project Name: Snake_game
// Target Devices: Basys 3 FPGA
// Description: This module serves the purpose of handling all the timing logic for
//              the sync signals, the colour value output and the address value.
//  
//////////////////////////////////////////////////////////////////////////////////


module VGA_Interface(
    input CLK,                      // 25MHz pixel clock
    input [11:0] COLOUR_IN,         // Input colour value
    output reg [18:0] ADDR,        // Vertical address index
    output reg [11:0] COLOUR_OUT,  // Output colour value
    output reg HS,                 // Horizontal sync signal
    output reg VS,                 // Vertical sync signal
    output endOfScreen             // Signal denoting frame has finished being drawn
    );
    // Timing parameters for vertical sync signal.
    parameter VerTimeToPulseWidthEnd = 10'd2;
    parameter VerTimeToBackPorchEnd = 10'd31;
    parameter VerTimeToDisplayTimeEnd = 10'd511;
    parameter VerTimeToFrontPorchEnd = 10'd521;
    
    // Timing parameters for horizontal sync signal.
    parameter HorzTimeToPulseWidthEnd = 10'd96;
    parameter HorzTimeToBackPorchEnd = 10'd144;
    parameter HorzTimeToDisplayTimeEnd = 10'd784;
    parameter HorzTimeToFrontPorchEnd = 10'd800;
    
    /* Declare wires for the current count value for both 
       counters and the trigger output from the first counter.
    */ 
    wire [9:0] HS_Count;
    wire [9:0] VS_Count;
    wire HS_Trig_Out;
    
    /* Initialize an instance of generic counter to act as the horizontal counter.
       Outputs a trigger value to enable the vertical counter, and the count value itself.
       The counter counts 800 times before reseting as per the docment specifications.
     */
    Generic_counter # (
        .COUNTER_WIDTH(10),
        .COUNTER_MAX(799)
        )
        HS_Counter (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .DIRECTION(1'b1),
        .TRIG_OUT(HS_Trig_Out),
        .COUNT(HS_Count)
    );
    
    /* Initialize an instance of generic counter to act as the vertical counter.
       Outputs a trigger value to signal the end of a frame, and the count value itself.
       The counter counts 521 times before reseting as per the document specifications.
     */
    Generic_counter # (
        .COUNTER_WIDTH(10),
        .COUNTER_MAX(520)
        )
        VS_Counter (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(HS_Trig_Out),
        .DIRECTION(1'b1),
        .TRIG_OUT(endOfScreen),
        .COUNT(VS_Count)
    );
    
    /* HS OUTPUT LOGIC
       Sets the horizontal sync signal to be high when the horizontal counter is less than the
       width of the horizontal sync signal pulse, otherwise it is set to 1.    
     */
    always@(posedge CLK) begin
        if (HS_Count < HorzTimeToPulseWidthEnd)
            HS <= 0;
        else
            HS <= 1;
    end 
    
    /* VS OUTPUT LOGIC
       Sets the vertical sync signal to be high when the vertical counter is less than the
       width of the vertical sync signal pulse, otherwise it is set to 1.    
     */
    always@(posedge CLK) begin
        if (VS_Count < VerTimeToPulseWidthEnd)
            VS <= 0;
        else
            VS <= 1;
    end 
    
    /* COLOUR_OUT OUTPUT LOGIC
       Sets the COLOUR_OUT signal to the same value of the COLOUR_IN signal whenever both
       counters are in the display range (from the end of the 'back porch' to the start 
       of the 'front porch') otherwise it is set to 0.   
     */
    always@(posedge CLK) begin
        if ((HS_Count > HorzTimeToBackPorchEnd) && (HS_Count < HorzTimeToDisplayTimeEnd) && (VS_Count > VerTimeToBackPorchEnd) && (VS_Count < VerTimeToDisplayTimeEnd))
            COLOUR_OUT <= COLOUR_IN;
        else
            COLOUR_OUT <= 0;
    end
    
    /* ADDRH OUTPUT LOGIC
       Sets the horizontal address index to increase at the same rate as the horizontal
       counter while the horizontal sync pulse is in the display range, otherwise it is
       set to 0. The horizontal count value is used to create the horizontal address index,
       subtracting the width of the horizontal sync signal 'back porch' from it. 
       The result is updated to the 10 MSB of the Address register every positive edge
       of the clock cycle.
     */
    always@(posedge CLK) begin
        if ((HS_Count > HorzTimeToBackPorchEnd) && (HS_Count < HorzTimeToDisplayTimeEnd))
            ADDR[18:9] <= HS_Count - 144;
        else
            ADDR[18:9] <= 0;
    end
    
    /* ADDRY OUTPUT LOGIC
       Sets the vertical address index to increase at the same rate as the vertical
       counter while the vertical sync pulse is in the display range, otherwise it is
       set to 0. The vertical count value is used to create the vertical address index,
       subtracting the width of the vertical sync signal 'back porch' from it. The result
       is updated to the 9 LSB of the Address register every positive edge of the clock
       cycle.
     */
    always@(posedge CLK) begin
        if ((VS_Count > VerTimeToBackPorchEnd) && (VS_Count < VerTimeToDisplayTimeEnd))
            ADDR[8:0] <= VS_Count - 31;
        else
            ADDR[8:0] <= 0;
    end
    
endmodule





