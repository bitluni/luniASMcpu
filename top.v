module top
(
    input nrst,
    input clk,
    inout [7:0] io,
    input [7:0] in,
    output [7:0] out,
    output [5:0] led
);

wire [23:0] address;
wire [7:0] addressLow = address[7:0];
wire [7:0] addressHigh = address[15:8];
reg [3:0] state = 3'b0;
wire write;
wire read;

wire addressLatch0 = out[0];
wire addressLatch1 = out[1];
wire RAMChipEnable = out[2];
wire RAMRead = out[3];
wire RAMWrite = out[4];
wire ROMChipEnable = out[5];
wire ROMRead = out[6];

//reg dataOutReady = 0;
//reg dataInReady = 0;

wire dataOutReady;
wire dataInReady;

assign out[7] = 0;

wire [31:0] dataOut;
wire [31:0] dataIn;
wire [1:0] byteCount;

reg [31:0] clockCounter = 0;

wire clk2 = clockCounter[22];

mmu memEmu (.rst(nrst), .clk(clk2),
    .address(address),
    .read(read),
    .dataOut(dataIn),
    .write(write),
    .dataIn(dataOut),
    .byteCount(byteCount),
    .dataOutReady(dataInReady),
    .dataInReady(dataOutReady));

cpu cpu0 (.rst(nrst), .clk(clk2),
    .address(address),
    .read(read),
    .dataIn(dataIn),
    .write(write),
    .dataOut(dataOut),
    .byteCount(byteCount),
    .dataInReady(dataInReady),
    .dataOutReady(dataOutReady));

reg [7:0] busByte = 0;
reg [7:0] cachedInByte = 0;
//assign io = ioIsInput ? 8'dZ : busByte;

//assign led = clockCounter[24:20];//~ledcounter;

reg [5:0] ledFlop = 6'd0;
assign led = ledFlop;

always @(posedge clk) begin
    clockCounter <= clockCounter + 1;
    //if(write && address[15:8] == 0) begin
    	ledFlop[4:0] <= ~dataIn[4:0];
    	ledFlop[5:5] <= ~clk2;
    	//ledFlop <= ~address[5:0];//dataIn[5:0];
    //end
end

endmodule