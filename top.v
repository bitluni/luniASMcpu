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
wire [2:0] byteCount;

mmu memEmu (.rst(!nrst), .clk,
	.address(address),
	.read(read),
	.dataOut(dataIn),
	.write(write),
	.dataIn(dataOut),
	.byteCount(byteCount),
	.dataOutReady(dataInReady),
	.dataInReady(dataOutReady));

cpu cpu0 (.rst(!nrst), .clk,
	.address(address),
	.read(read),
	.dataIn(dataIn),
	.write(write),
	.dataOut(dataOut),
	.byteCount(byteCount),
	.dataInReady(dataInReady),
	.dataOutReady(dataOutReady));

/*cpu cpu0 (.clk(clk),
	.address(address),
	.read(read),
	.dataIn(cachedInByte),
	.write(write),
	.dataOut(dataOut),
	.dataInReady(dataInReady),
	.dataOutReady(dataOutReady));*/

localparam STATE_IDLE = 3'd0;
localparam STATE_WRITE_ADDRESS_0 = 3'd1;
localparam STATE_WRITE_ADDRESS_1 = 3'd2;
localparam STATE_WRITE_DATA = 3'd3;
localparam STATE_WRITE_DONE = 3'd4;
localparam STATE_READ_ADDRESS_0 = 3'd5;
localparam STATE_READ_ADDRESS_1 = 3'd6;
localparam STATE_READ_DONE = 3'd7;

wire ioIsInput = state == STATE_READ_DONE;

reg [7:0] busByte = 0;
reg [7:0] cachedInByte = 0;
assign io = ioIsInput ? 8'dZ : busByte;

/*
always @(posedge clk) begin
	case(state)
		STATE_IDLE:
			begin
				if(read) begin
					state <= STATE_READ_ADDRESS_0;
					busByte <= addressLow;
					dataInReady <= 1'b0;
					dataOutReady <= 1'b0;
					addressLatch0 <= 1'b1;
				end else if (write) begin
					state <= STATE_WRITE_ADDRESS_0;
					busByte <= addressLow;
					dataInReady <= 1'b0;
					dataOutReady <= 1'b0;
					addressLatch0 <= 1'b1;
				end
			end
		STATE_READ_ADDRESS_0:
			begin
				if(read) begin
					state <= STATE_READ_ADDRESS_1;
					busByte <= addressHigh;
					addressLatch0 <= 1'b0;
					addressLatch1 <= 1'b1;
				end
			end
		STATE_READ_ADDRESS_1:
			begin
				if(read) begin
					state <= STATE_READ_DONE;
					addressLatch0 <= 1'b0;
					addressLatch1 <= 1'b0;
					RAMChipEnable <= 1'b1;
					RAMRead <= 1'b1;
					RAMWrite <= 1'b0;
				end
			end			
		STATE_READ_DONE:
			begin
				if(read) begin
					state <= STATE_IDLE;
					cachedInByte <= io;
					addressLatch0 <= 1'b0;
					addressLatch1 <= 1'b0;
					RAMChipEnable <= 1'b1;
					RAMRead <= 1'b1;
					RAMWrite <= 1'b0;
					dataInReady <= 1'b1;
				end
			end
		STATE_WRITE_ADDRESS_0:
			begin
				if(read) begin
					state <= STATE_WRITE_ADDRESS_1;
					busByte <= addressHigh;
					addressLatch0 <= 1'b0;
					addressLatch1 <= 1'b1;
				end
			end
		STATE_WRITE_ADDRESS_1:
			begin
				if(read) begin
					state <= STATE_WRITE_DONE;
					busByte <= dataOut;
					addressLatch0 <= 1'b0;
					addressLatch1 <= 1'b0;
					RAMChipEnable <= 1'b1;
					RAMRead <= 1'b0;
					RAMWrite <= 1'b1;
				end
			end			
		STATE_WRITE_DONE:
			begin
				if(read) begin
					state <= STATE_IDLE;
					dataOutReady <= 1'b1;
				end
			end
	endcase
end
*/
localparam WAIT_TIME = 13500000;
reg [31:0] clockCounter = 0;
reg [5:0] ledCounter = 0;

//assign led = clockCounter[24:20];//~ledcounter;

reg [5:0] ledFlop = 6'd0;
assign led = ledFlop;

always @(posedge clk) begin
/*    clockCounter <= clockCounter + 1;
    if (clockCounter == WAIT_TIME) begin
    //    clockCounter <= 0;
        //ledCounter <= ledCounter + 1;
    end*/

	//if(write && address[15:8] == 0) begin
		ledFlop <= ~address[5:0];//dataOut[5:0];
	//end
end

endmodule