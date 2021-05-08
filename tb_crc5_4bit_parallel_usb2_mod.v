/* -----------------------------------------------------------------------------------
 * Module Name  : -
 * Date Created : 15:27:47 IST, 06 November, 2020 [ Friday ]
 *
 * Author       : pxvi
 * Description  : Basic testbench for the CRC5 4bit data module testing
 * -----------------------------------------------------------------------------------

   MIT License

   Copyright (c) 2020 k-sva

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the Software), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.

 * ----------------------------------------------------------------------------------- */

`include "crc5_4bit_parallel_usb2_mod.v"

module tb_crc5_4bit_parallel_usb2_mod;

    reg [3:0] data_in;
    reg clk, rstn, clear, enable;
    wire [4:0] crc;

    // Dut Instantiation
    // -----------------
    crc5_4bit_parallel_usb2_mod         #(   .RESET_SEED( 'h00 )
                                        )
                                        dut
                                        (
                                            .CLK( clk ),
                                            .RSTn( rstn ),
                                            .data_in( data_in ),
                                            .enable( enable ),
                                            .clear( clear ),
                                            .CRC( crc )
                                        );

    initial
    begin
        fork
            begin
                clk = 0;
                forever
                begin
                    #5 clk = ~clk;
                end
            end
            begin
                rstn = 0;
                #200;
                rstn = 1;
            end
            begin
                #1;
                wait( rstn == 1 );

                repeat( 4 )
                begin
                    @( negedge clk );
                    enable = 1;
                    clear = 0;
                    data_in = $urandom;

                    #1;
                    $display( "%6d - Debug : Enable ( %0d ), Clear ( %0d ), Reset ( %0d ), Data In ( %b [ %h ] [ %d ] ), CRC ( %b [ %h ] [ %d ] )", $time, enable, clear, rstn, data_in, data_in, data_in, crc, crc, crc );
                    @( posedge clk );
                    //$display( "%6d - Debug : Enable ( %0d ), Clear ( %0d ), Reset ( %0d ), Data In ( %b [ %h ] [ %d ] )", $time, enable, clear, rstn, data_in, data_in, data_in );
                end
                @( negedge clk );
                $display( "%6d - Debug : Enable ( %0d ), Clear ( %0d ), Reset ( %0d ), Data In ( %b [ %h ] [ %d ] ), CRC ( %b [ %h ] [ %d ] )", $time, enable, clear, rstn, data_in, data_in, data_in, crc, crc, crc );
                enable = 0;
                clear = 0;
                data_in = $urandom;
                @( posedge clk );
                $display( "%6d - Debug : Enable ( %0d ), Clear ( %0d ), Reset ( %0d ), Data In ( %b [ %h ] [ %d ] ), CRC ( %b [ %h ] [ %d ] )", $time, enable, clear, rstn, data_in, data_in, data_in, crc, crc, crc );
                @( posedge clk );
                $display( "%6d - Debug : Enable ( %0d ), Clear ( %0d ), Reset ( %0d ), Data In ( %b [ %h ] [ %d ] ), CRC ( %b [ %h ] [ %d ] )", $time, enable, clear, rstn, data_in, data_in, data_in, crc, crc, crc );
                @( posedge clk );
                $display( "%6d - Debug : Enable ( %0d ), Clear ( %0d ), Reset ( %0d ), Data In ( %b [ %h ] [ %d ] ), CRC ( %b [ %h ] [ %d ] )", $time, enable, clear, rstn, data_in, data_in, data_in, crc, crc, crc );
                @( negedge clk );
                enable = 0;
                clear = 1;
                data_in = $urandom;
                @( posedge clk );
                @( negedge clk );
                enable = 0;
                clear = 1;
                data_in = $urandom;
                #1;
                $display( "%6d - Debug : Enable ( %0d ), Clear ( %0d ), Reset ( %0d ), Data In ( %b [ %h ] [ %d ] ), CRC ( %b [ %h ] [ %d ] )", $time, enable, clear, rstn, data_in, data_in, data_in, crc, crc, crc );
            end
        join
    end

    initial
    begin   
        #2000;
        $finish;
    end

endmodule
