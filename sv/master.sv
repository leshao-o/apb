module master (
    input [0:0] PCLK,
    input [0:0] PRESET,

    input [0:0] PSEL,
    input [0:0] PREADY,
    input [0:0] transfer,

    input [0:0] PWRITE,
    input [31:0] PADDR,
    input [31:0] PDATA, 
    output reg [0:0] PENABLE,
    output reg [31:0] PRWDATA,
    output reg [31:0] PRWADDR
);

reg [31:0] memory [0:127];
reg [1:0] state = 2'b00;

task apb_read;
input [31:0] addr;
    begin

        PRWDATA <= PDATA;

        PRWADDR <= addr;
    end
endtask

task apb_write;
input [31:0] addr;
input [31:0] data;
    begin

        PRWDATA <= data;
        PRWADDR <= addr;
    end
endtask

integer i;
reg [31:0] temp;

always @(posedge PCLK or posedge PRESET or posedge PENABLE) begin

    if (PRESET == 1'b1) begin 
        PRWDATA <= 0;
        PRWADDR <= 0;
        state = 2'b00;
    end

    case (state)
    2'b00:
    begin
        PENABLE = 1'b0;
        if (PSEL == 1'b1 && transfer == 1'b1) begin 
            if (PWRITE == 1'b1) begin
                state <= 2'b01;
            end
            else begin
                state <= 2'b10;
            end
        end
    end

    2'b01:
    begin
        PENABLE = 1'b1;
        if (PSEL == 1'b1 && transfer == 1'b1 && PREADY == 1'b1) begin
            apb_write(PADDR,PDATA);
            state <= 2'b11;
        end
    end

    2'b10:
    begin
        PENABLE <= 1'b1;
        if (PSEL == 1'b1 && transfer == 1'b1 && PREADY == 1'b1) begin
            apb_read(PADDR);
            state <= 2'b11;
        end
    end

    2'b11:begin
        if (PSEL == 1'b1 && transfer == 1'b1 && PREADY == 1'b1) begin
            if (PWRITE == 1'b1) begin
                state <= 2'b01;
            end
            else begin
                state <= 2'b10;
            end
        end

        if (PSEL == 1'b1 && transfer == 1'b0 && PREADY == 1'b1) begin
            state <= 2'b00;
        end
    end

    endcase
end
endmodule