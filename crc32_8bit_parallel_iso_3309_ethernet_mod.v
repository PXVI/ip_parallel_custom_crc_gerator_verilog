/* -----------------------------------------------------------------------------------
 * Module Name  : crc32_8bit_parallel_iso_3309_ethernet_mod
 * Date Created : 16:56:22 IST, 6 November, 2020 [ Friday ]
 * 
 * Author       : pxvi
 * Description  : Parallel CRC( 32-bit ) module with 8-bit data input. 
 *                Polynomial Degrees [ 32 26 23 22 2 16 12 11 10 1 ]
 * -----------------------------------------------------------------------------------
 * 
 * MIT License
 * 
 * Copyright (c) 2020 k-sva
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
 * ----------------------------------------------------------------------------------- */
module crc32_8bit_parallel_iso_3309_ethernet_mod  #(  parameter   RESET_SEED = 'h00 )(
                                                                            input CLK,
                                                                            input RSTn,

                                                                            input [8-1:0] data_in,
                                                                            input enable,
                                                                            input clear,

                                                                            output [32-1:0] CRC
                                                                        );


    reg [32-1:0] Mout_p, Mout_n;

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
            Mout_n[0] = data_in[0] ^ data_in[6] ^ Mout_p[24] ^ Mout_p[30] ;
            Mout_n[1] = data_in[0] ^ data_in[1] ^ data_in[6] ^ data_in[7] ^ Mout_p[24] ^ Mout_p[25] ^ Mout_p[30] ^ Mout_p[31] ;
            Mout_n[2] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[6] ^ data_in[7] ^ Mout_p[24] ^ Mout_p[25] ^ Mout_p[26] ^ Mout_p[30] ^ Mout_p[31] ;
            Mout_n[3] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7] ^ Mout_p[25] ^ Mout_p[26] ^ Mout_p[27] ^ Mout_p[31] ;
            Mout_n[4] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ Mout_p[24] ^ Mout_p[26] ^ Mout_p[27] ^ Mout_p[28] ^ Mout_p[30] ;
            Mout_n[5] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ Mout_p[24] ^ Mout_p[25] ^ Mout_p[27] ^ Mout_p[28] ^ Mout_p[29] ^ Mout_p[30] ^ Mout_p[31] ;
            Mout_n[6] = data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ Mout_p[25] ^ Mout_p[26] ^ Mout_p[28] ^ Mout_p[29] ^ Mout_p[30] ^ Mout_p[31] ;
            Mout_n[7] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[7] ^ Mout_p[24] ^ Mout_p[26] ^ Mout_p[27] ^ Mout_p[29] ^ Mout_p[31] ;
            Mout_n[8] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ Mout_p[0] ^ Mout_p[24] ^ Mout_p[25] ^ Mout_p[27] ^ Mout_p[28] ;
            Mout_n[9] = data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ Mout_p[1] ^ Mout_p[25] ^ Mout_p[26] ^ Mout_p[28] ^ Mout_p[29] ;
            Mout_n[10] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ Mout_p[2] ^ Mout_p[24] ^ Mout_p[26] ^ Mout_p[27] ^ Mout_p[29] ;
            Mout_n[11] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ Mout_p[3] ^ Mout_p[24] ^ Mout_p[25] ^ Mout_p[27] ^ Mout_p[28] ;
            Mout_n[12] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ Mout_p[4] ^ Mout_p[24] ^ Mout_p[25] ^ Mout_p[26] ^ Mout_p[28] ^ Mout_p[29] ^ Mout_p[30] ;
            Mout_n[13] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ Mout_p[5] ^ Mout_p[25] ^ Mout_p[26] ^ Mout_p[27] ^ Mout_p[29] ^ Mout_p[30] ^ Mout_p[31] ;
            Mout_n[14] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ Mout_p[6] ^ Mout_p[26] ^ Mout_p[27] ^ Mout_p[28] ^ Mout_p[30] ^ Mout_p[31] ;
            Mout_n[15] = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ Mout_p[7] ^ Mout_p[27] ^ Mout_p[28] ^ Mout_p[29] ^ Mout_p[31] ;
            Mout_n[16] = data_in[0] ^ data_in[4] ^ data_in[5] ^ Mout_p[8] ^ Mout_p[24] ^ Mout_p[28] ^ Mout_p[29] ;
            Mout_n[17] = data_in[1] ^ data_in[5] ^ data_in[6] ^ Mout_p[9] ^ Mout_p[25] ^ Mout_p[29] ^ Mout_p[30] ;
            Mout_n[18] = data_in[2] ^ data_in[6] ^ data_in[7] ^ Mout_p[10] ^ Mout_p[26] ^ Mout_p[30] ^ Mout_p[31] ;
            Mout_n[19] = data_in[3] ^ data_in[7] ^ Mout_p[11] ^ Mout_p[27] ^ Mout_p[31] ;
            Mout_n[20] = data_in[4] ^ Mout_p[12] ^ Mout_p[28] ;
            Mout_n[21] = data_in[5] ^ Mout_p[13] ^ Mout_p[29] ;
            Mout_n[22] = data_in[0] ^ Mout_p[14] ^ Mout_p[24] ;
            Mout_n[23] = data_in[0] ^ data_in[1] ^ data_in[6] ^ Mout_p[15] ^ Mout_p[24] ^ Mout_p[25] ^ Mout_p[30] ;
            Mout_n[24] = data_in[1] ^ data_in[2] ^ data_in[7] ^ Mout_p[16] ^ Mout_p[25] ^ Mout_p[26] ^ Mout_p[31] ;
            Mout_n[25] = data_in[2] ^ data_in[3] ^ Mout_p[17] ^ Mout_p[26] ^ Mout_p[27] ;
            Mout_n[26] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ Mout_p[18] ^ Mout_p[24] ^ Mout_p[27] ^ Mout_p[28] ^ Mout_p[30] ;
            Mout_n[27] = data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ Mout_p[19] ^ Mout_p[25] ^ Mout_p[28] ^ Mout_p[29] ^ Mout_p[31] ;
            Mout_n[28] = data_in[2] ^ data_in[5] ^ data_in[6] ^ Mout_p[20] ^ Mout_p[26] ^ Mout_p[29] ^ Mout_p[30] ;
            Mout_n[29] = data_in[3] ^ data_in[6] ^ data_in[7] ^ Mout_p[21] ^ Mout_p[27] ^ Mout_p[30] ^ Mout_p[31] ;
            Mout_n[30] = data_in[4] ^ data_in[7] ^ Mout_p[22] ^ Mout_p[28] ^ Mout_p[31] ;
            Mout_n[31] = data_in[5] ^ Mout_p[23] ^ Mout_p[29] ;
        end
    end

    assign CRC = Mout_p;

endmodule
