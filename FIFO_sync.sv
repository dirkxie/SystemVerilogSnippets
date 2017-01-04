module FIFO_sync (
  input              clk,
  input              rst,
  input              wr_en,   // write enable
  input              rd_en,   // read enable
  input        [7:0] buf_in,  // data into buffer
  output logic [7:0] buf_out, // data out from buffer
  output logic       buf_empty,
  output logic       buf_full,
  output logic [3:0] fifo_counter // number of data in buffer
);

logic [2:0] rd_ptr, wr_ptr; // read, write pointer 
logic [7:0] buf_mem [3:0];  // memory

always_comb begin
  buf_empty = (fifo_counter == 0);
  buf_full  = (fifo_counter == 15);
end

// fifo counter
always_ff @ (posedge clk or posedge rst) begin // async, high reset
  if (rst)
    //reset
    fifo_counter <= 0;
  else if ((!buf_full && wr_en) && (!buf_empty && rd))
    //read and write at the same time, while not empty or full
    fifo_counter <= fifo_counter;
  else if (!buf_full && wr_en)
    //write when not full
    fifo_counter <= fifo_counter + 1;
  else if (!buf_empty && rd_en)
    //read when not empty
    fifo_counter <= fifo_counter - 1;
  else
    fifo_counter <= fifo_counter;
end

// output port
always_ff @ (posedge clk or posedge rst) begin
  if (rst)
    buf_out <= 0;
  else begin
    if (rd_en && !buf_empty)
      buf_out <= buf_mem[rd_ptr];
    else
      buf_out <= buf_out;
  end
end
    
// input port
always_ff @ (posedge clk) begin
  if (wr_en && !buf_full)
    buf_mem[wr_ptr] <= buf_in;
  else
    buf_mem[wr_ptr] <= buf_mem[wr_ptr];
end
    
// rd, wr pointers
always_ff @ (posedge clk or posedge rst) begin
  if (rst) begin
    wr_ptr <= 0;
    rd_ptr <= 0;
  end else begin
    if (!buf_full && wr_en)
      wr_ptr <= wr_ptr + 1;
    else
      wr_ptr <= wr_ptr;
    
    if (!buf_empty && rd_en)
      rd_ptr <= rd_ptr + 1;
    else
      rd_ptr <= rd_ptr;
  end
end

endmodule
