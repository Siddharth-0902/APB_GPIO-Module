`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 16:31:00
// Design Name: 
// Module Name: apb_gpio
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module apb_gpio(
    input        pclk,
    input        presetn,

    input        psel,
    input        penable,
    input [1:0]  paddr,
    input        pwrite,
    input [7:0]  pwdata,

    output reg [7:0] prdata,
    output           pready,

    input  [7:0] gpio_in,
    output reg [7:0] gpio_out,
    output reg [7:0] gpio_oe
);

// Registers
reg [7:0] dir_reg;
reg [7:0] mode_reg;
reg [7:0] write_reg;
reg [7:0] read_reg;

localparam push_pull  = 1'b1;
localparam open_drain = 1'b0;

integer i;

//////////////////// WRITE LOGIC ////////////////////

always @(posedge pclk or negedge presetn)
begin
    if(!presetn)
    begin
        dir_reg   <= 8'h00;
        mode_reg  <= 8'h00;
        write_reg <= 8'h00;
    end
    else if(psel && !penable && pwrite) // APB write setup phase
    begin
        case(paddr)
            2'b00: dir_reg   <= pwdata;
            2'b01: mode_reg  <= pwdata;
            2'b10: write_reg <= pwdata;
            default: ;
        endcase
    end
end


//////////////////// READ LOGIC ////////////////////

always @(posedge pclk or negedge presetn)
begin
    if(!presetn)
        prdata <= 8'h00;
    else if(psel && penable && !pwrite)
    begin
        case(paddr)
            2'b00: prdata <= dir_reg;
            2'b01: prdata <= mode_reg;
            2'b10: prdata <= write_reg;
            2'b11: prdata <= read_reg;
            default: prdata <= 8'h00;
        endcase
    end
end


//////////////////// INPUT SAMPLING ////////////////////

always @(posedge pclk or negedge presetn)
begin
    if(!presetn)
        read_reg <= 8'h00;
    else
        read_reg <= gpio_in;
end


//////////////////// GPIO CONTROL ////////////////////

always @(posedge pclk or negedge presetn)
begin
    if(!presetn)
    begin
        gpio_out <= 8'h00;
        gpio_oe  <= 8'h00;
    end
    else
    begin
        for(i=0;i<8;i=i+1)
        begin
            if(mode_reg[i] == push_pull)
            begin
                gpio_out[i] <= write_reg[i];
                gpio_oe[i]  <= dir_reg[i];
            end
            else
            begin
                gpio_out[i] <= 1'b0;
                gpio_oe[i]  <= dir_reg[i] & ~write_reg[i];
            end
        end
    end
end


//////////////////// APB READY ////////////////////

assign pready = 1'b1;

endmodule
