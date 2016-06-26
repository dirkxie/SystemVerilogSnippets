//10 entries of 4 bytes (packed into 32 bits)
bit [3:0][7:0] test [1:10];
test[9] = test[8] + 1; //4 byte add
test[7][3:2] = test[6][1:0]; //2 byte copy

