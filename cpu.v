//16bit for now
module cpu
(
	input rst,
	input clk,
	output reg [23:0] address,
	output reg read,
	input [31:0] dataIn,
	output reg write,
	output reg [31:0] dataOut,
	output reg [1:0] byteCount,
	input dataInReady,	//expects to data be read in one cycle, it read is not cleared load again
	input dataOutReady
);

//0: read instruction
localparam STATE_LOAD_OPCODE = 3'd0;
localparam STATE_DECODE_OPCODE = 3'd1;
localparam STATE_LOAD_BYTE = 3'd2;
localparam STATE_LOAD_WORD1 = 3'd3;
localparam STATE_LOAD_WORD2 = 3'd4;
localparam STATE_PUSH2 = 3'd5;
localparam STATE_PUSH_DONE = 3'd6;

//localparam OPCODE_PUSH = 8'd0;
localparam OPCODE_POP = 8'd1;
localparam OPCODE_STOR = 8'd2;
localparam OPCODE_LOAD = 8'd3;
localparam OPCODE_PUSHB = 8'd4;
localparam OPCODE_PUSHW = 8'd5;
localparam OPCODE_CLONE = 8'd6;
localparam OPCODE_LOADS = 8'd7;
localparam OPCODE_STORS = 8'd8;
localparam OPCODE_SWAP = 8'd9;

localparam OPCODE_JMP = 8'd16;
localparam OPCODE_JZ = 8'd17;
localparam OPCODE_JNZ = 8'd18;
localparam OPCODE_JG = 8'd19;
localparam OPCODE_JGE = 8'd20;
localparam OPCODE_JE = 8'd21;
localparam OPCODE_JNE = 8'd22;

localparam OPCODE_AND = 8'd32;
localparam OPCODE_OR = 8'd33;
localparam OPCODE_XOR = 8'd34;
localparam OPCODE_NOT = 8'd35;
localparam OPCODE_INC = 8'd36;
localparam OPCODE_DEC = 8'd37;
localparam OPCODE_ADD = 8'd38;
localparam OPCODE_SUB = 8'd39;

localparam OPCODE_SHL = 8'd40;
localparam OPCODE_SHR = 8'd41;
localparam OPCODE_MUL = 8'd42;
//localparam OPCODE_DIV = 8'd43;
//localparam OPCODE_MOD = 8'd44;
localparam OPCODE_NEG = 8'd45;
localparam OPCODE_ABS = 8'd46;

localparam OPCODE_DEBUG = 8'd254;
localparam OPCODE_NOP = 8'd255;


reg [2:0] state = STATE_LOAD_OPCODE;
reg [15:0] IP = 256;
reg [15:0] SP = 0;
reg [7:0] opcode;
reg [15:0] AX;
reg [15:0] BX;
wire [15:0] nSP;
wire [15:0] SPp1;
assign nSP = SP - 16'd2;

always @(posedge clk) begin
	if(rst) begin
		address <= 0;
		read <= 0;
		write <= 0;
		state <= STATE_LOAD_OPCODE;
		IP <= 16'h100;
		SP <= 0;
		dataOut <= 0;
		byteCount <= 0;
	end else begin
		case(state)
			STATE_LOAD_OPCODE:
				begin
					//read first byte of instruction
					write <= 1'b0;
					address <= IP;
					IP <= IP + 1'b1;
					read <= 1'b1;
					state <= STATE_DECODE_OPCODE;
				end
			STATE_DECODE_OPCODE:
				if (dataInReady) begin
					//opcode ready next decode
					opcode <= dataIn;
					if(dataIn == OPCODE_PUSHB) begin
						state <= STATE_LOAD_BYTE;
						address <= IP;
						IP <= IP + 1'b1;
						read <= 1'b1;
					end else if(dataIn == OPCODE_PUSHW) begin
						state <= STATE_LOAD_WORD1;
						address <= IP;
						IP <= IP + 1'b1;
						read <= 1'b1;
					end else  if(dataIn == OPCODE_JMP) begin
						
					end else begin
						//not push opcodes
						//TODO
						state <= STATE_LOAD_OPCODE;
						read <= 0;
					end
				end
			STATE_LOAD_BYTE:
				if (dataInReady) begin
					AX <= {8'b0, dataIn};
					read <= 1'b0;
					//state <= STATE_PUSH;
					address <= nSP;
					SP <= nSP;
					dataOut <= dataIn;
					write <= 1'b1;
					state <= STATE_PUSH2;
				end
			STATE_LOAD_WORD1:
				if (dataInReady) begin
					AX[7:0] <= dataIn;
					state <= STATE_LOAD_WORD2;
					address <= IP;
					IP <= IP + 1'b1;
					read <= 1'b1;
				end
			STATE_LOAD_WORD2:
				if (dataInReady) begin
					AX[15:8] <= dataIn;
					read <= 1'b0;
					//state <= STATE_PUSH;
					dataOut <= AX[7:0];
					write <= 1'b1;
					state <= STATE_PUSH2;
					address <= nSP;
					SP <= nSP;
				end	
			STATE_PUSH2:
				if (dataOutReady) begin
					write <= 1'b1;
					address <= address + 1'b1;
					dataOut <= AX[15:8];
					state <= STATE_PUSH_DONE;
				end
			STATE_PUSH_DONE:
				if (dataOutReady) begin
					state <= STATE_LOAD_OPCODE;
					write <= 1'b0;
				end
		endcase
	end
end

endmodule