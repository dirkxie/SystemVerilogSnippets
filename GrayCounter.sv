module GrayCounter
#(
  parameter COUNTER_WIDTH = 4
) (
  output logic [COUNTER_WIDTH-1:0] GrayCount_out,
  input                            Enable_in,
  input                            Clear_in,
  input                            clk);
 
  logic [COUNTER_WIDTH-1:0] BinaryCount;
  
  always_ff @ (posedge clk) begin
    if (Clear_in) begin
      BinaryCount   <= {COUNTER_WIDTH{1'b0}} + 1; // gray code starts with 1
      GrayCount_out <= {COUNTER_WIDTH{1'b0}};
    end else if (Enable_in) begin
      BinaryCount <= BinaryCount + 1;
     // {MSB, xor((MSB-1,0), (MSB,1))}
      GrayCount_out <= {BinaryCount[COUNTER_WIDTH-1],
                       BinaryCount[COUNTER_WIDTH-2:0] ^ BinaryCount[COUNTER_WIDTH-1:1]}; 
    end
endmodule
