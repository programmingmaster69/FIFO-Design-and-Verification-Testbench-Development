`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.11.2024 15:23:32
// Design Name: 
// Module Name: fifo_tb
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
//TRANSACTOR


class transactor;
    
    rand bit rd_en;
    rand bit wd_en;
    rand bit [7:0] wdata;
    bit [7:0] rdata;
    bit full;
    bit empty;
    constraint rd_wr_en{ rd_en != wd_en;}

endclass


//GENERATOR
class generator;
    rand transactor trans;
    mailbox gen2driv;
    int repeat_count;
    int count;
    
    function new (mailbox gen2driv);
        this.gen2driv = gen2driv;
    endfunction
    
    task main();
        repeat(repeat_count)
        begin
            trans = new();
            trans.randomize();
            gen2driv.put(trans);
        end
    endtask
endclass


//DRIVER
class driver;

    virtual fifo_if vif;
    mailbox gen2driv;
    
    function new(virtual fifo_if vif,mailbox gen2drive);
        this.vif = vif;
        this.gen2driv = gen2driv;
    endfunction
    
    task reset();
        vif.DRIVER.driver_cb.rst<=1;
    repeat(40)
    @(posedge vif.DRIVER.clk)
        vif.DRIVER.driver_cb.rst<= 0;
    endtask :reset
    
    task main();
    fork : main
        forever
        begin
            transactor trans;
                trans = new();
            gen2driv.get(trans);
            @(posedge vif.DRIVER.clk)
            if(trans.wr_en || trans.rd_en)
                begin
                    if(trans.wr_en)
                        begin
                            vif.DRIVER.driver_cb.wr_en<=trans.wr_en;
                            vif.DRIVER.driver_cb.rd_en<=trans.rd_en;
                            vif.DRIVER.driver_cb.wdata<=trans.wdata;
                            @(posedge vif.DRIVER.clk);
                        end
                    else
                        begin
                            vif.DRIVER.driver_cb.wr_en<=trans.wr_en;
                            vif.DRIVER.driver_cb.rd_en<=trans.rd_en;
                            trans.rdata = vif.MONITOR.monitor.rdata;
                            @(posedge vif.DRIVER.clk);
                        end   
                end   
        end
    join_none :main
    endtask

endclass


//INTERFACE
interface fifo_if(input logic clk);
    logic rd_en;
    logic rst;
    logic wr_en;
    logic [7:0]wdata;
    logic [7:0]rdata;
    logic full,empty;
    
    clocking driver_cb@(posedge clk);
        default input #1 output #1;
        output rst;
        output wdata;
        output rd_en;
        output wr_en;
        input full;
        input empty;
        input rdata;
    endclocking
    
    clocking monitor@(posedge clk);
        input rst;
        input rd_en;
        input wr_en;
        input wdata;
        input full,empty;
        input rdata;
    endclocking
    
    modport DRIVER (clocking driver_cb, input clk);
    modport MONITOR (clocking monitor, input clk);    
endinterface


//MONITOR
class monitor;

virtual fifo_if vif;
mailbox rcvr2sb;

    function new(virtual fifo_if vif,mailbox rcvr2sb);
    this.vif = vif;
    if(rcvr2sb == null)
        $finish;
    else
        this.rcvr2sb = rcvr2sb;
    endfunction : new

    task start();
    
    fork
    forever begin
        transactor trans;
        trans = new();
        $display("-----------------Mode of operation---------------------");
        @(posedge vif.MONITOR.clk);
        wait(vif.MONITOR.monitor.rd_en||vif.MONITOR.monitor.wr_en)
        @(posedge vif.MONITOR.clk);
        
        if(vif.MONITOR.monitor.wr_en)
        begin
            trans.wr_en = vif.MONITOR.monitor.wr_en;
            trans.rd_en = vif.MONITOR.monitor.rd_en;
            trans.wdata = vif.MONITOR.monitor.wdata;
            trans.full = vif.MONITOR.monitor.full;
            trans.empty = vif.MONITOR.monitor.empty;
            if(trans.full)
                $display("\wr_en=%h    Memory is full", vif.MONITOR.monitor.wr_en);
            else
                $display("\wr_en=%h \wdata=%h",vif.MONITOR.monitor.wr_en,vif.MONITOR.monitor.wdata);
        end
        
        else
        begin
            trans.wr_en = vif.MONITOR.monitor.wr_en;
            trans.rd_en = vif.MONITOR.monitor.rd_en;
            trans.rdata = vif.MONITOR.monitor.rdata;
            trans.full = vif.MONITOR.monitor.full;
            trans.empty = vif.MONITOR.monitor.empty;
            if(trans.empty)
                $display("\rd_en=%h    Memory is Empty", vif.MONITOR.monitor.rd_en);
            else
                $display("\rd_en=%h \rdata=%h",vif.MONITOR.monitor.rd_en,vif.MONITOR.monitor.rdata);
        end
        rcvr2sb.put(trans);
        end
        join_none
    endtask : start
    
endclass


//Scoreboard
class scoreboard;

mailbox gen2driv;
mailbox rcvr2sb;
integer compare;

function new(mailbox gen2driv, mailbox rcvr2sb);
    this.gen2driv = gen2driv;
    this.rcvr2sb = rcvr2sb;
endfunction : new

task start();
    transactor trans_rcv,trans;
    
    trans_rcv = new();
    trans = new();
    
    fork
    forever
        begin
        rcvr2sb.get(trans_rcv);
        gen2driv.get(trans);
        $display("-----------------SCOREBOARD---------------------");
        
            begin
            compare = 1'b0;
            if(trans.wr_en == tran_rcv.wr_en && trans.rd_en == trans.rcv.rd_en)
                compare = 1;
            end
            if(trans_rcv.full||trans_rcv.empty)
            begin
                if(trans_rcv.full)
                    $display("\wr_en = %0h Memory is full",trans_rcv.we_en);
                else
                    $display("\wr_en = %0h \wdata = %0h",trans_rcv.we_en,trans_rcv.wdata);
            end
            if(trans_rcv.empty)
                    $display("\rd_en = %0h Memory is empty",trans_rcv.rd_en);
                else
                    $display("\rd_en = %0h \rdata = %0h",trans_rcv.rd_en,trans_rcv.rdata);
            if(compare == 1)
                $display("Yes");
            else
                $display("No");
        end
        join_none
    
endtask : start
endclass


//Test-program
program test(fifo_if inf);
    environment env;
    initial begin
        env = new(inf);
        env.build();
        env.gen.repeat_count = 40;
        env.test();
        env.run;
    end   
endprogram    



//environment
class environment;
    generator gen;
    driver driv;
    monitor rcv;
    scoreboard sb;
    mailbox gen2driv;
    mailbox rcv2sb;
    virtual fifo_if vif_ff;
    
    function new(virtual fifo_if vif_ff);
        this.vif_ff = vif_ff;
    endfunction
    
    task build();
        gen2driv = new();
        rcv2sb = new();
        
        gen = new(gen2driv);
        driv = new(vif_ff,gen2driv);
        rcv = new(vif_ff,rcv2sb);
        sb = new(gen2driv,rcv2sb);
    endtask
    
    
    task pre_test();
        driv.reset();
    endtask
    
    task test();
    fork
    gen.main();
    driv.main();
    rcv.start();
    sb.start();
    join
    endtask
    
    task run();
        pre_test();
        test();
        $finish();
    endtask
endclass


//Testbench
module tb_top();
bit clk;

fifo_if inf(clk);
test_ti(inf);

fifo dut(.wdata(inf.wdata),
         .rd_en(inf.rd_en),
         .wr_en(inf.wr_en),
         .full(inf.full),
         .empty(inf.empty),
         .rdata(inf.rdata),
         .clk(clk),
         .rst(inf.rst));
         
initial begin
    clk = 1;
    end
    
 always #5 clk = ~clk;
 
endmodule
    
