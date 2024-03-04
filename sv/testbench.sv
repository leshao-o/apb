// iverilog -o testbench.vvp testbench.sv 
// vvp testbench.vvp

`include "master.sv"
`include "slave.sv"

module testbench;

reg [0:0] PCLK;
reg [0:0] PRESET;

reg [0:0] PSEL;
reg [0:0] transfer;
reg [0:0] r;
reg [0:0] PWRITE;

reg [31:0] PADDR;
reg [31:0] PDATA;

wire [0:0] PENABLE;
wire [31:0] PRWDATA;
wire [31:0] PRWADDR;

wire [31:0] PRDATA1;
wire [0:0] PREADY;

master m (
    .PCLK(PCLK),
    .PRESET(PRESET),
    .PSEL(PSEL),
    .PREADY(PREADY),
    .transfer(transfer),
    .PWRITE(PWRITE),      
    .PADDR(PADDR),
    .PDATA(PDATA),

    .PENABLE(PENABLE),
    .PRWDATA(PRWDATA),
    .PRWADDR(PRWADDR)
);

slave s (
    .PCLK(PCLK),
    .PRESET(PRESET),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),

    .PRWDATA(PRWDATA),  // master out, slave in data
    .PRWADDR(PRWADDR),  // master out, slava in addr

    .PRDATA1(PRDATA1),        // slave out data
    .PREADY(PREADY)        
);

initial begin
    $dumpfile("testbench.vcd");
    $dumpvars(0,testbench);
    PADDR = 32'b00000000000000000000000000000000;
    PDATA = 32'h00000309;

    PWRITE = 1'b1;
    
    PCLK = 1'b0;
    PRESET = 0;
    PSEL = 0;
    transfer = 1'b1;

    PRESET = 1;
    #10;
    PRESET = 0;
    PSEL = 1;
    #30;
    PSEL = 0;
    #20;

    PADDR = 32'b00000000000000000000000000000100;
    PDATA = 32'h28122023;
    PSEL = 1;
    #30;
    PSEL = 0;
    #20;

    PADDR = 32'b00000000000000000000000000001000;
    PDATA = 32'h416c656b;
    PSEL = 1;
    #30;
    PSEL = 0;
    #20;

    PADDR = 32'b000000000000000000000000001100;
    PDATA = 32'h4c656500;
    PSEL = 1;
    #30;
    PSEL = 0;
    #20;

    $finish;
end

always begin
    #5 PCLK = ~PCLK;
end

endmodule
