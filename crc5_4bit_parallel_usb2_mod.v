/* -----------------------------------------------------------------------------------
 * Module Name  : crc5_4bit_parallel_usb2_mod
 * Date Created : 15:00:50 IST, 06 November, 2020 [ Friday ]
 *
 * Author       : pxvi
 * Description  : Parallel CRC( 5-bit ) module with 4-bit data input.
 *                Polynomial Degrees [ 5, 2 ]
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

module crc5_4bit_parallel_usb2_mod  #(  parameter   RESET_SEED = 'h00 )(
                                                                            input CLK,
                                                                            input RSTn,

                                                                            input [3:0] data_in,
                                                                            input enable,
                                                                            input clear,

                                                                            output [4:0] CRC
                                                                        );


    reg [4:0] Mout_p, Mout_n;

    always@( posedge CLK or negedge RSTn )
    begin
        Mout_p <= Mout_n;

        if( !RSTn )
        begin
            Mout_p <= RESET_SEED;
        end
    end

    always@( * )
    begin
        Mout_n = Mout_p;

        if( clear )
        begin
            Mout_n = RESET_SEED;
        end
        else if( enable )
        begin
            Mout_n[0] = data_in[0] ^ data_in[3] ^ Mout_p[1]^ Mout_p[4];
            Mout_n[1] = data_in[1] ^ Mout_p[2];
            Mout_n[2] = data_in[0] ^ data_in[2] ^ data_in[3] ^ Mout_p[1] ^ Mout_p[3] ^ Mout_p[4];
            Mout_n[3] = data_in[1] ^ data_in[3] ^ Mout_p[2] ^ Mout_p[4];
            Mout_n[4] = data_in[2] ^ Mout_p[0] ^ Mout_p[3];
        end
    end

    assign CRC = Mout_p;

endmodule
