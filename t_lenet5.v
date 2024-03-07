`timescale 1ns/100ps

module t_lenet5();

reg clk = 0;
reg reset = 0;
wire [7:0] pixel;
wire[3:0] out;

always #5 clk = ~clk;

// read the next pixel at every posedge clk
image_reader #(.NUMPIXELS(1024), .PIXELWIDTH(8), .FILE("image32x32.list")) R1 (
 .clk(clk), .rst(reset),
 .nextPixel(pixel)
);
// will store the pixel in the row buffer
//  and perform calculations (convolution/pooling)
//  at every posedge clk

rom_params #(.BIT_WIDTH(8), .SIZE((25+1)*6),	// (filters + bias) * (no. feature maps)
		.FILE("kernel_c1.list")) ROM_C1 (
	.clk(clk),
	.read(read),
	.read_out(LeNet5.rom_c1)
);

// C3: 16 feature maps; convolution, stride = 1

// parameters for conv filters
rom_params #(.BIT_WIDTH(16), .SIZE(6*(75+1)),	// (filters + bias) * (no. feature maps)
		.FILE("kernel_c3_x3.list")) ROM_C3_X3 (
	.clk(clk),
	.read(read),
	.read_out(LeNet5.rom_c3_x3)
);
rom_params #(.BIT_WIDTH(16), .SIZE(9*(100+1)),	// (filters + bias) * (no. feature maps)
		.FILE("kernel_c3_x4.list")) ROM_C3_X4 (
	.clk(clk),
	.read(read),
	.read_out(LeNet5.rom_c3_x4)
);
rom_params #(.BIT_WIDTH(16), .SIZE(150+1),	// (filters + bias) * (no. feature maps)
		.FILE("kernel_c3_x6.list")) ROM_C3_X6 (
	.clk(clk),
	.read(read),
	.read_out(LeNet5.rom_c3_x6)
);


// parameters for conv filters
rom_params #(.BIT_WIDTH(32), .SIZE((16*25+1)*60),	// (filters + bias) * (no. feature maps)
		.FILE("kernel_c5_0.list")) ROM_C5_0 (
	.clk(clk),
	.read(read),
	.read_out(LeNet5.rom_c5_0)
);
rom_params #(.BIT_WIDTH(32), .SIZE((16*25+1)*60),	// (filters + bias) * (no. feature maps)
		.FILE("kernel_c5_1.list")) ROM_C5_1 (
	.clk(clk),
	.read(read),
	.read_out(LeNet5.rom_c5_1)
);
	// F6 parameters stored in memory

// parameters for neuron weights
rom_params #(.BIT_WIDTH(32), .SIZE(84*(120+1)),	// (no. neurons) * (no. inputs + bias)
		.FILE("weights_f6.list")) ROM_F6 (
	.clk(clk),
	.read(read),
	.read_out(LeNet5.rom_f6)
);	// layer OUT parameters stored in memory

// parameters for neuron weights
rom_params #(.BIT_WIDTH(32), .SIZE(10*(84+1)),	// (no. neurons) * (no. inputs + bias)
		.FILE("weights_out7.list")) ROM_OUT7 (
	.clk(clk),
	.read(read),
	.read_out(LeNet5.rom_out7)
);
lenet5 #(.IMAGE_COLS(32), .IN_WIDTH(8), .OUT_WIDTH(32)) LeNet5 (
 .clk(clk), .rst(reset),
 .nextPixel(pixel),
 .out(out),
 .read(read)
);

endmodule
