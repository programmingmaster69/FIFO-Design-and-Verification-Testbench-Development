`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.11.2024 14:31:29
// Design Name: 
// Module Name: fifo
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


module fifo(clk,rst,wdata,rdata,wr_en,rd_en,full,empty);
input clk,rst,wr_en,rd_en;
output full,empty;
input [7:0] wdata;
output reg [7:0] rdata;

reg [5:0] wr_ptr;
reg [5:0] rd_ptr;
reg [7:0] mem[31:0];
integer i;

//Writing Data into FIFO
always@(posedge clk,posedge rst)
begin
    if (rst)
    begin
        for (i = 0;i<32; i = i+1)
            mem[i] <= 8'b0;
    end
    else if (wr_en & ~full)
        mem[wr_ptr] <= wdata;
end


//Reading from FIFO
always@(posedge clk,posedge rst)
begin
    if(rst)
        rdata <= 8'b0;
    else if(rd_en & ~empty)
        rdata <= mem[rd_ptr];
end


//Generating write pointer
always@(posedge clk,posedge rst)
begin
    if(rst)
        wr_ptr <= 6'b0;
    else if (wr_en & ~full)
        wr_ptr <= wr_ptr + 1;
end


//Generating read pointer
always@(posedge clk,posedge rst)
begin
    if(rst)
        rd_ptr <= 6'b0;
    else if (rd_en & ~empty)
        rd_ptr <= rd_ptr + 1;
end


//Assigning value to Full and Empty
assign empty = (rd_ptr == wr_ptr);
assign full = ((wr_ptr[4:0] == rd_ptr[4:0]) && (wr_ptr[5]) != rd_ptr[5]);

endmodule
