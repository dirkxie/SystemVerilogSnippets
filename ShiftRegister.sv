/*
* bit shift reg
* byte shift reg
* for loop
* group of regs
*/

module ShiftReg (
  input CLK,
  input RST,
  input DATA_IN,
  output BIT_OUT,
  output [7:0] BYTE_OUT
);

  reg [7:0] bitShiftReg;
  reg [7:0] byteShiftReg[11:0];
  
  integer i;

  always @ (posedge clk) begin
    //bit shift reg
    bitShiftReg <= {bitShiftReg[6:0], DATA_IN};

    //byte shift reg using for loop
    byteShiftReg [0] <= bitShiftReg;
    
    for (i = 1; i < 12; i = i + 1)
      byteShiftReg[i] <= byteShiftReg[i-1];
  end

  assign BIT_OUT = bitShiftReg[7];
  assign BYTE_OUT = byteShiftReg[11];

endmodule
