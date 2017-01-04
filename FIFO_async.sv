// modified from asic-world
// http://www.asic-world.com/examples/verilog/asyn_fifo.html
module FIFO_async
# (
  parameter DATA_WIDTH    = 8,
  parameter ADDRESS_WIDTH = 4,
  parameter FIFO_DEPTH    = (1 << ADDRESS_WIDTH)
) (
  // read port
  output logic [DATA_WIDTH-1:0] buf_out,
  output logic                  buf_empty,
  input                         rd_en,
  input                         rd_clk,
  
  // write port
  input        [DATA_WIDTH-1:0] buf_in,
  output logic                  buf_full,
  input                         wr_en,
  input                         wr_clk,
  
  // clear
  input                         Clear_in     
);

logic [DATA_WIDTH-1:0]    buf_mem[FIFO_DEPTH-1:0];
logic [ADDRESS_WIDTH-1:0] wr_ptr, rd_ptr;
logic EqualAddresses;
logic NextWriteAddressEn, NextReadAddressEn;
logic Set_Status, Rst_Status;
logic Status;
logic PresetFull, PresetEmpty;

// Data ports logic
// dual-port RAM
// buf_out logic
always_ff @ (posedge rd_clk) begin
  if (rd_en && !buf_empty)
    buf_out <= buf_mem[rd_ptr];
end

// buf_in logic
always_ff @ (posedge wr_clk) begin
  if (wr_en && !buf_full)
    buf_mem[wr_ptr] <= buf_in;
end

// fifo address support logic
// 'next address' enable logic
assign NextWriteAddressEn = wr_en & ~buf_full;
assign NextReadAddressEn  = rd_en & ~buf_empty;

// address (gray counter) logic
GrayCounter GrayCounter_wr_ptr (
  .GrayCount_out (wr_ptr),
  .Enable_in     (NextWriteAddressEn),
  .Clear_in      (Clear_in),
  .Clk           (wr_clk)
);

GrayCounter GrayCounter_rd_ptr (
  .GrayCount_out (rd_ptr),
  .Enable_in     (NextReadAddressEn),
  .Clear_in      (Clear_in),
  .Clk           (rd_clk)
);

// equal address logic
assign EqualAddresses = (wr_ptr == rd_ptr);
// 'quarant selector' logic
assign Set_Status = (wr_ptr[ADDRESS_WIDTH-2] ~^ rd_ptr[ADDRESS_WIDTH-1]) &
                    (wr_ptr[ADDRESS_WIDTH-1] ^ rd_ptr[ADDRESS_WIDTH-2]);

assign Rst_Status = (wr_ptr[ADDRESS_WIDTH-2] ^ rd_ptr[ADDRESS_WIDTH-1]) &
                    (wr_ptr[ADDRESS_WIDTH-1] ~^ rd_ptr[ADDRESS_WIDTH-2]);

// 'Status' latch logic
always_latch begin // D latch with async clear & preset
  if (Rst_Status | Clear_in)
    Status = 0; // going 'empty'
  else if (Set_Status)
    Status = 1; // going 'full'
end

// 'Full_out' logic for writing port
assign PresetFull = Status & EqualAddresses;

always_ff @ (posedge wr_clk or posedge PresetFull) begin
  if (PresetFull)
    Full_out <= 1;
  else
    Full_out <= 0;
end

assign PresetEmpty = ~Status & EqualAddresses;

always_ff @ (posedge rd_clk or posedge PresetEmpty) begin
  if (PresetEmpty)
    Empty_out <= 1;
  else
    Empty_out <= 0;
end

endmodule
