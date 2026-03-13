`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 16:38:10
// Design Name: 
// Module Name: tb_apb_gpio
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

module tb_apb_gpio;
    // Define testbench ports
    reg pclk = 0;
    reg presetn;
    reg psel;
    reg penable;
    reg [3:0] paddr;
    reg pwrite;
    reg [7:0] pwdata;
    wire [7:0] prdata;
    wire pready;
    reg [7:0] gpio_in;
    wire [7:0] gpio_out;
    wire [7:0] gpio_oe;
 
    // Instantiate the apb_gpio module
    apb_gpio dut (
        .pclk(pclk),
        .presetn(presetn),
        .psel(psel),
        .penable(penable),
        .paddr(paddr),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out),
        .gpio_oe(gpio_oe)
         );
        
 always #10 pclk = ~pclk;
 //dir - 0, mode - 1, write - 2, read - 3
 initial begin
 presetn = 1'b0;
 repeat(10)@(posedge pclk);
 presetn = 1'b1;
 gpio_in = 8'h34;
 ////////////// update write_reg
 @(posedge pclk);
 psel = 1;
 paddr = 2;
 pwrite = 1;
 pwdata = 8'haa;
 @(posedge pclk);
 penable = 1'b1;
 @(posedge pclk);
 ///// set all the pins as output : dir_reg
 @(posedge pclk);
 psel = 1;
 paddr = 0;
 pwrite = 1;
 pwdata = 8'hff;
 @(posedge pclk);
 penable = 1'b1;
 @(posedge pclk);
 
 ///// mode_reg : push pull
 psel = 1;
 paddr = 1;
 pwrite = 1;
 pwdata = 8'hff;
 @(posedge pclk);
 penable = 1'b1;
 @(posedge pclk);
 
 ////////////// mode reg : open drain
 
 psel = 1;
 paddr = 1;
 pwrite = 1;
 pwdata = 8'h00;
 @(posedge pclk);
 penable = 1'b1;
 @(posedge pclk);
 
 ///////////////////read data
 psel = 1;
 paddr = 3;
 pwrite = 0;
 pwdata = 8'h00;
 @(posedge pclk);
 penable = 1'b1;
 @(posedge pclk);
 
 end
        
endmodule
