#  -----------------------------------------------------------------------------------
#  Module Name  : -
#  Date Created : 09:00:07 IST, 06 November, 2020 [ Friday ]
# 
#  Author       : pxvi
#  Description  : Generic script to generate a NxM parallel CRC moudle with custom 
#                 polynomial. [ N is the data width and M is the CRC width ]
#  -----------------------------------------------------------------------------------
# 
#  MIT License
# 
#  Copyright (c) 2020 k-sva
# 
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the Software), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
# 
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
# 
#  THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.
# 
#  ----------------------------------------------------------------------------------- */

#!/usr/bin/perl

=begin comment
This is where a multi line comment goes
=cut

print "# ----------------------------------\n";
print "# Paralle CRC Generation Module v0.1\n";
print "# ----------------------------------\n";
print "# \n";
print "# This perl script will generate a N-bit input M-bit CRC module with a specific CRC polynomial.\n";
print "# \n";

print "# Enter the data input width ( N-bit width ) : ";
$nbit_width=<>;
chomp( $nbit_width );
$nbit_width=$nbit_width*1;
print "# Enter the crc width ( M-bit width )        : ";
$mbit_width=<>;
chomp( $mbit_width );
$mbit_width=$mbit_width*1;

#print "# $nbit_width : $mbit_width\n";

print "# \n";
print "# Start entering the CRC polynomial degrees one by one in the descending order. For eg, in the polynomial\n";
print "# x^5 + x^2 + 1, has the degrees 5, 2 and 0. They must be entered in the same order. Please note that, for\n";
print "# this script to work, you must enter the polynimial which matches the width of M ented earlier. Entering the\n";
print "# degree 0 will mean all the other degrees have been entered and the script will move to the next stage.\n";
print "# Note : This script has it's set of bugs and problems. Feel free to report is you find any.\n";

%POLY_DEGREE;
@CRC_SERIAL; # Will hold the calculated serial CRC value
@CRC_PARALLEL; # Will hold the calculated parallel CRC value
@CRC_TEMP; # Will hold any intermideate CRC values
@CRC_CUSTOM;
@H1;
@H2;
$PD="";
@mout_eq;
$poly_hex_val;
$fullfilename;
$filename;

@IN_DATA = ( 0,0,0,0,0,0,0,0 ); # Temp DATA IN array

reload_crc_temp();

print "# \n";
print "# Enter the polynomial degree ( ideally first would be the M value that you have provided ) : ";
$pdegree=<>;
chomp( $pdegree );

if( $pdegree > 0 and $pdegree == $mbit_width ){
    $POLY_DEGREE{$pdegree} = $pdegree; # Added the degree to the hash

    while( $pdegree > 0 ){
        print "# Enter the next polynomial degree in the order ( 0 will finish this step )                 : ";
        $pdegree=<>;
        chomp( $pdegree );
        if( $pdegree >= $mbit_width ){
            print "# \n";
            print "# [E] The polynomial degree enetered ( $pdegree ) is invalid in the current step.\n";
            exit(0);
        }else{
            $POLY_DEGREE{$pdegree} = $pdegree; # Added the degree to the hash   
        }
    }
    
    foreach $j ( reverse sort keys %POLY_DEGREE ){
        #print "# POLY_DEGREE : $j\n";
        if( $j == $mbit_width ){
            $PD = "$j";
        }elsif( $j == 0 ){
            $PD = "$PD";
        }else{
            $PD = "$PD $j";
        }
    }

    print "# \n";

    #test_serial_crc();
    reload_crc_temp();
    generate_h2_matrix();

    reload_crc_temp();
    generate_h1_matrix();
    print "# Polynomial matrices have been generated.\n";

    #print_h1_h2(); # For debug purpose

    mout_eq_generation();
    print "# Design equations have been calculated and now moving to the final step.\n";

    generate_module();

    # Module has been generated
    print "# \n";
    print "# ------------------------------------------------------- \n";
    print "# [S] The parallel CRC verilog module has been generated. \n";
    print "# ------------------------------------------------------- \n";
    print "# Note : Feel free to provide any feedback that might seem neccessary for this script.\n ";

}else{
    print "# \n";
    print "# [E] The first polynomial degree to be entered has to the same as the M-bit width value and must be non-zero.\n";
    exit(0);
}

# ----------------------------------
# Module generate part of the script
# ----------------------------------

sub generate_module{
    print "#\n";

    print "# Enter an appropriate suffix for the module ( eg. uhs3, usb2, ccti, don_no_1 etc ) : ";
    $suff=<>;
    chomp( $suff );

    if( !$suff ){
        print "# Not custom suffix will be added.\n";
        $filename="crc";
        $filename.="$mbit_width";
        #$filename.="_";
        #$filename.="$poly_hex_val";
        $filename.="_";
        $filename.="$nbit_width";
        $filename.="bit_";
        $filename.="parallel_mod";
    }else{
        $filename="crc";
        $filename.="$mbit_width";
        #$filename.="_";
        #$filename.="$poly_hex_val";
        $filename.="_";
        $filename.="$nbit_width";
        $filename.="bit_";
        $filename.="parallel";
        $filename.="_";
        $filename.="$suff";
        $filename.="_";
        $filename.="mod";
    }

    createFile();
}

# ------------------------
# Mout equation generation
# ------------------------

sub mout_eq_generation_debug{
    my $i=0;
    my $j=0;

    while( $i < $mbit_width ){
        my $first=1;
        print "# Mout[$i] = ";
        # H1
        while( $j < $nbit_width ){
            if( $H1[$i][$j] == 1 ){
                if( $first == 1 ){
                    $first = 0;
                    print "Nin[$j] ";
                }else{
                    print "^ Nin[$j] ";
                }
            }
            $j=$j+1;
        }
        $j=0;
        # H2
        while( $j < $mbit_width ){
            if( $H2[$i][$j] == 1 ){
                if( $first == 1 ){
                    $first = 0;
                    print "Min[$j] ";
                }else{
                    print "^ Min[$j] ";
                }
            }
            $j=$j+1;
        }
        print "\n"; # End of the line
        $j=0;
        $i=$i+1;
    }
    $i=0;
}

# ------------------------------------------------------------------
# Generate the Mout in terms of Din and CRCin for the verilog module
# ------------------------------------------------------------------

sub mout_eq_generation{
    my $i=0;
    my $j=0;

    while( $i < $mbit_width ){
        my $first=1;
        $mout_eq[$i] = "";
        $mout_eq[$i] .= "Mout_n[$i] = ";
        # H1
        while( $j < $nbit_width ){
            if( $H1[$i][$j] == 1 ){
                if( $first == 1 ){
                    $first = 0;
                    $mout_eq[$i] .= "data_in[$j] ";
                }else{
                    $mout_eq[$i] .= "^ data_in[$j] ";
                }
            }
            $j=$j+1;
        }
        $j=0;
        # H2
        while( $j < $mbit_width ){
            if( $H2[$i][$j] == 1 ){
                if( $first == 1 ){
                    $first = 0;
                    $mout_eq[$i] .= "Mout_p[$j] ";
                }else{
                    $mout_eq[$i] .= "^ Mout_p[$j] ";
                }
            }
            $j=$j+1;
        }
        $mout_eq[$i] .= ";"; # End of the line
        $j=0;
        $i=$i+1;
    }
    $i=0;
}

# --------------------
# Print H1 & H2 matrix
# --------------------

sub print_h1_h2{
    my $j=0;
    my $k=0;

    # H1

    print "# \n";
    print "# ---------\n";
    print "# H1 Matrix \n";
    print "# ---------\n";

    print "# Mout[x] - 0 1 ..\n";
    print "# ---------";
    while( $j < $mbit_width ){
        print "--";
        $j=$j+1;
    }
    print "\n";
    $j=0;
    while( $k < $nbit_width ){
        print "# Nbit[$k] : ";
        while( $j < $mbit_width ){
            print "$H1[$j][$k] ";
            $j=$j+1;
        }
        print "\n";
        $j=0;
        $k=$k+1;
    }

    $j=0;
    $k=0;

    print "# \n";
    print "# ---------\n";
    print "# H2 Matrix \n";
    print "# ---------\n";
    
    print "# Mout[x] - 0 1 ..\n";
    print "# ---------";
    while( $j < $mbit_width ){
        print "--";
        $j=$j+1;
    }
    print "\n";
    $j=0;
    while( $k < $mbit_width ){
        print "# Mbit[$k] : ";
        while( $j < $mbit_width ){
            print "$H2[$j][$k] ";
            $j=$j+1;
        }
        print "\n";
        $j=0;
        $k=$k+1;
    }
    print "# \n";
}

# ------------------------------------------------
# Generate the H1 Matric ( CRC as a funtion of N )
# ------------------------------------------------

sub generate_h1_matrix{
    
    @IN_DATA = ();

    my $k=0;
    my $j=0;
    my $x=$k;
    while( $k < $nbit_width ){
        while( $j < $nbit_width ){
            if( $x == ( ( $nbit_width - 1 ) - $j ) ){
                $IN_DATA[$j] = 1;
            }else{
                $IN_DATA[$j] = 0;
            }
            $j = $j + 1;
        }
        $j=0;
        parallel_crc_run( 0 );
        while( $j < $mbit_width ){
            $H1[$j][$k] = $CRC_SERIAL[$j];
            $j = $j + 1;
        }
        $j=0;
        #print "# ---------------------\n";
        #print "# H1 Matrix Run Done...\n";
        #print "# ---------------------\n";
        $k = $k + 1;
        $x = $k;
    }

}

# ------------------------------------------------
# Generate the H2 Matric ( CRC as a funtion of M )
# ------------------------------------------------

sub generate_h2_matrix{

    my $k=0;
    my $j=0;
    my $x=$k;
    while( $k < $mbit_width ){
        while( $j < $mbit_width ){
            if( $x == $j ){
                $CRC_CUSTOM[$j] = 1;
            }else{
                $CRC_CUSTOM[$j] = 0;
            }
            $j = $j + 1;
        }
        $j=0;
        parallel_crc_run( 1 );
        while( $j < $mbit_width ){
            $H2[$j][$k] = $CRC_SERIAL[$j];
            $j = $j + 1;
        }
        $j=0;
        reload_crc_temp();
        #print "# ---------------------\n";
        #print "# H2 Matrix Run Done...\n";
        #print "# ---------------------\n";
        $k = $k + 1;
        $x = $k;
    }
}

# --------------------------------
# Run serial as function of M or N
# --------------------------------

sub parallel_crc_run{
    # Pass extra argument which tell is the Serial CRC sub is to be run N times or M times
    # 0 is N times, 1 is M times
    
    if( ( $#_ + 1 ) == 1 ){
        if( $_[0] == 1 ){
            load_custom_crc_temp();
            my $i = 0;

            while( $i < $nbit_width ){
                crc_serial_run( $IN_DATA[$i] );
                load_serial_to_temp();
                #print "# Run... $i\n";

                $i = $i + 1;
            }
        }else{
            reload_crc_temp();
            my $i = 0;

            while( $i < $nbit_width ){
                crc_serial_run( $IN_DATA[$i] );
                load_serial_to_temp();
                #print "# Run... $i\n";

                $i = $i + 1;
            }
        }
    }elsif( ( $#_ + 1 ) == 0 ){
        
        test_serial_crc(); # Default. No use in particular

    }else{
        print "# \n";
        print "# [E] Unexpected number of arguments have been provided.\n";
    }
}

# -----------------------
# Test serial crc run sub
# -----------------------

sub test_serial_crc{
    # 'd31
    my @IN_DATA = (    0,
                    0,
                    1,
                    1,
                    0,
                    0,
                    0,
                    1
                );

    reload_crc_temp();
    my $i = 0;

    while( $i < $nbit_width ){
        crc_serial_run( $IN_DATA[$i] );
        load_serial_to_temp();
        print "# Run... $i\n";

        $i = $i + 1;
    }
}

# ------------------------------
# Load a specific CRC TEMP value
# ------------------------------

sub load_custom_crc_temp{
    @CRC_TEMP = @CRC_CUSTOM;
}

# -------------------------------
# Reload the CRC_TEMP values to 0
# -------------------------------

sub reload_crc_temp{
    my $i = 0;

    while( $i < $mbit_width ){
        $CRC_TEMP[$i] = 0;
        $i = $i + 1;
    }
}

# ---------------------------
# Copy CRC_SERIAL to CRC_TEMP
# ---------------------------

sub load_serial_to_temp{
    @CRC_TEMP = @CRC_SERIAL;
}

# -------------------------
# CRC Serial Run Subroutine
# -------------------------

sub crc_serial_run{
    $argsNum = $#_ + 1; # Will give the number of arguments. Must pass data_in & crc ( crc will be taken from a global array of CRC_TEMP ).

    if( $argsNum == 1 ){
        my $i = 0;

        while( $i < $mbit_width ){
            if( $i == 0 ){
                $CRC_SERIAL[$i] = $CRC_TEMP[$mbit_width-1] ^ $_[0];
                #print "# 0 Normal [ $CRC_SERIAL[$i], $CRC_TEMP[$mbit_width-1], $_[0] ]\n";
            }else{
                if( exists( $POLY_DEGREE{$i} ) ){ # Check if the degree exists in the hash
                    $CRC_SERIAL[$i] = $CRC_TEMP[$i-1] ^ $CRC_TEMP[$mbit_width-1] ^ $_[0];
                    #print "# Exists [ $CRC_SERIAL[$i], $CRC_TEMP[$i-1], $CRC_TEMP[$mbit_width-1], $_[0] ]\n";
                }else{
                    $CRC_SERIAL[$i] = $CRC_TEMP[$i-1];
                    #print "# Does not exist [ $CRC_SERIAL[$i], $CRC_TEMP[$i-1] ]\n";
                }
            }
            #@CRC_TEMP = @CRC_SERIAL;

            $i = $i + 1;
        }

        $OUT = "";

        foreach $k ( reverse @CRC_SERIAL ){
            $OUT = "$OUT $k";
        }
        #print "# [D] Serial CRC : $OUT, Data In ( $_[0] )\n";
    }else{
        print "# \n";
        print "# [E] The crc_serial_run sub did not receive the required number of arguments.\n";
        exit(0);
    }
}

# ----------------------
# Create the moudle file
# ----------------------

sub createFile{ # This used to create a new file for the first time
    $fullfilename = "$fileName\.$temp";

    open my $FH, '>', "$filename.v";
    close $FH;

    insertLic();
    generate_code();
}

# ---------------------
# Insert liscense discl
# ---------------------

sub insertLic(){
    open( NH, ">>", "$filename.v" ) or die( "[E] Failed to open the file for appending" ); # Open the file in append mode

    $fcomment = "/*";
    $comment = " *";
    $ecomment = "*/";

    %monArr = ( 0 => "January", 1 => "Febuary", 2 => "March", 3 => "April", 4 => "May", 5 => "June", 6 => "July", 7 => "August", 8 => "September", 9 => "October", 10 => "November", 11 => "December" );
    %wdayArr = ( 0 => "Sunday", 1 => "Monday", 2 => "Tuesday", 3 => "Wednesday", 4 => "Thursday", 5 => "Friday", 6 => "Saturday" );

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    #print "$mon : $wday\n";
    $mon = $monArr{$mon};
    $wday = $wdayArr{$wday};
    if( $min < 10 ){
        $min = "0$min";
    }
    if( $sec < 10 ){
        $sec = "0$sec";
    }
    if( $hour < 10 ){
        $hour = "0$hour";
    }

    print NH "$fcomment -----------------------------------------------------------------------------------\n";
    print NH "$comment Module Name  : $filename\n";
    print NH "$comment Date Created : $hour:$min:$sec IST, $mday $mon, $year [ $wday ]\n";
    print NH "$comment \n";
    print NH "$comment Author       : pxvi\n";
    print NH "$comment Description  : Parallel CRC( $mbit_width-bit ) module with $nbit_width-bit data input. \n";
    print NH "$comment                Polynomial Degrees [ $PD ]\n";
    print NH "$comment -----------------------------------------------------------------------------------\n";
    print NH "$comment \n";
    print NH "$comment MIT License\n";
    print NH "$comment \n";
    print NH "$comment Copyright (c) $year k-sva\n";
    print NH "$comment \n";
    print NH "$comment Permission is hereby granted, free of charge, to any person obtaining a copy\n";
    print NH "$comment of this software and associated documentation files (the Software), to deal\n";
    print NH "$comment in the Software without restriction, including without limitation the rights\n";
    print NH "$comment to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n";
    print NH "$comment copies of the Software, and to permit persons to whom the Software is\n";
    print NH "$comment furnished to do so, subject to the following conditions:\n";
    print NH "$comment \n";
    print NH "$comment The above copyright notice and this permission notice shall be included in all\n";
    print NH "$comment copies or substantial portions of the Software.\n";
    print NH "$comment \n";
    print NH "$comment THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n";
    print NH "$comment IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n";
    print NH "$comment FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n";
    print NH "$comment AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n";
    print NH "$comment LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n";
    print NH "$comment OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n";
    print NH "$comment SOFTWARE.\n";
    print NH "$comment \n";
    print NH "$comment ----------------------------------------------------------------------------------- $ecomment\n";

}

# Insert the module template code

sub generate_code{

    open( NH, ">>", "$filename.v" ) or die( "[E] Failed to open the file for appending" ); # Open the file in append mode

    print NH "module $filename  #(  parameter   RESET_SEED = 'h00 )(\n";
    print NH "                                                                            input CLK,\n";
    print NH "                                                                            input RSTn,\n";
    print NH "\n";
    print NH "                                                                            input [$nbit_width-1:0] data_in,\n";
    print NH "                                                                            input enable,\n";
    print NH "                                                                            input clear,\n";
    print NH "\n";
    print NH "                                                                            output [$mbit_width-1:0] CRC\n";
    print NH "                                                                        );\n";
    print NH "\n";
    print NH "\n";
    print NH "    reg [$mbit_width-1:0] Mout_p, Mout_n;\n";
    print NH "\n";
    print NH "    always@( posedge CLK or negedge RSTn )\n";
    print NH "    begin\n";
    print NH "        Mout_p <= Mout_n;\n";
    print NH "\n";
    print NH "        if( !RSTn )\n";
    print NH "        begin\n";
    print NH "            Mout_p <= RESET_SEED;\n";
    print NH "        end\n";
    print NH "    end\n";
    print NH "\n";
    print NH "    always@( * )\n";
    print NH "    begin\n";
    print NH "        Mout_n = Mout_p;\n";
    print NH "\n";
    print NH "        if( clear )\n";
    print NH "        begin\n";
    print NH "            Mout_n = RESET_SEED;\n";
    print NH "        end\n";
    print NH "        else if( enable )\n";
    print NH "        begin\n";
    
    my $i = 0;

    while( $i < $mbit_width ){
        print NH "            $mout_eq[$i]\n";
        $i = $i + 1;
    }
    $i = 0;

    #print NH "            Mout_n[0] = data_in[0] ^ data_in[3] ^ Mout_p[1]^ Mout_p[4];";
    #print NH "            Mout_n[1] = data_in[1] ^ Mout_p[2];";
    #print NH "            Mout_n[2] = data_in[0] ^ data_in[2] ^ data_in[3] ^ Mout_p[1] ^ Mout_p[3] ^ Mout_p[4];";
    #print NH "            Mout_n[3] = data_in[1] ^ data_in[3] ^ Mout_p[2] ^ Mout_p[4];";
    #print NH "            Mout_n[4] = data_in[2] ^ Mout_p[0] ^ Mout_p[3];";
    print NH "        end\n";
    print NH "    end\n";
    print NH "\n";
    print NH "    assign CRC = Mout_p;\n";
    print NH "\n";
    print NH "endmodule\n";

}
