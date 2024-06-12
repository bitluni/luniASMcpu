//memory managemant unit
module mmu
(
    input rst,
    input clk,
    input [23:0] address,
    input read,
    output reg [31:0] dataOut, 	//upto 32 bits
    input write,
    input [31:0] dataIn,		//upto 32 bits
    input [1:0] byteCount,		//count of bytes - 1 to read/write
    output reg dataOutReady,	//expects to data be read in one cycle, if read is not cleared load again
    output reg dataInReady
);

reg [7:0] sram[255:0];
reg [7:0] rom[255:0];

initial begin
    //$readmemh("rom.mem", rom, 0);
    rom[0] = 8'd255; //8'h05;
    rom[1] = 8'd254; //8'hBA;
    rom[2] = 8'd255; //8'hAD;
    rom[3] = 8'd254; //8'h05;
    rom[4] = 8'd255; //8'hF0;
    rom[5] = 8'd254; //8'h0D;
    rom[6] = 8'd16;
    rom[7] = 8'd16;
    rom[8] = 8'd16;
    rom[9] = 8'h00;
    rom[10] = 8'h00;
    rom[11] = 8'h00;
    rom[12] = 8'h00;
    rom[13] = 8'h00;
    rom[14] = 8'h00;
    rom[15] = 8'h00;
end

reg [1:0] byteNumber;
reg readActive;
reg writeActive;

always @(posedge read) begin
//    byteNumber <= 0;
//    readActive <= 1;
//    dataOut <= 0;
end

always @(posedge write) begin
//    byteNumber <= 0;
//    writeActive <= 1;
end

always @(posedge clk) begin
    if(rst) begin
    	dataOut <= 0;
    	dataInReady <= 0;
    	dataOutReady <= 0;
    	readActive <= 0;
    end else begin
    	if(dataOutReady || dataInReady) begin
    		dataInReady <= 1'b0;
    		dataOutReady <= 1'b0;
    	end else begin
    		if(read) begin
    		 	if(readActive) begin
    				if(!address[8]) begin
    					dataOut <= (dataOut << (byteNumber * 8)) | (sram[address[7:0] + byteNumber]);
    				end else begin
    					dataOut <= (dataOut << (byteNumber * 8)) | (rom[address[7:0] + byteNumber]);
    				end
    				if(byteNumber != byteCount) begin
    					byteNumber <= byteNumber + 1;
    				end else begin
    					byteNumber <= 0;
    					dataOutReady <= 1'b1;
    					readActive <= 1'b0;
    				end
    			end else begin
                    readActive <= 1'b1;
                    dataOut <= 0;
    			end
    		end else if (write) begin
    		 	if(writeActive) begin
    				if(!address[8]) begin	
    					sram[address[7:0] + byteNumber]	<= (dataIn >> (byteNumber * 8));
    				end else begin
    					//rom read only
    				end
    				if(byteNumber != byteCount) begin
    					byteNumber <= byteNumber + 1;
    				end else begin
    					byteNumber <= 0;
    					dataInReady <= 1'b1;
    					writeActive <= 1'b0;
    				end
    			end else begin
                    writeActive <= 1'b1;
    			end
    		end 
    	end
    end
end

endmodule