# Parallel CRC ( Mbit Polynomial & Nbit Data )
------------------------
This here is the collection of CRC modules which are parallel in naturein the sense that the user can generate a full CRC in just one clock cycle, despite the lenght of the input. This is espicially useful in a system which has a stream of data is being recieved over which the CRC is supposed to be calculated. The **CRC Generator Script** which has been provided is a generic script which can generate a M-bit CRC calculator for an N-bit input with customizable polynomial. The design generated is already linted and is good to be synthesized. <br/>

The generator script is **Perl** based and the instructions on how to use it are pretty straight forward. Just try running the script and everything is self explanatory. <br/>

The internal block diagram for the design is given below. This is the fundamental implementaion diagram. Additional signals and their use are all added for ease of use.

![Parallel CRC Block Diagram](https://github.com/PXVI/adv_module/blob/master/CRC/Parallel/crc_parallel_block_diagram.png)
**Figure** : Reference from paper ( 1 )

------------------------

### Bibliography / References

The designs and the script both have an implementation which makes use of a Parallel CRC Implementation method which was picked up from the following papers. The method is pretty straight forward and you are free to read them.

  - ( 1 ) A Practical Parallel CRC Generation Method by Evgeni Stavinov
  - G. Albertango and R. Sisto, “Parallel CRC Generation,” IEEE Micro, Vol. 10, No. 5, 1990.
  - G. Campobello, G. Patane, M. Russo, “Parallel CRC Realization,” http://ai.unime.it/~gp/publications/full/tccrc.pdf
  - A. Perez, “Byte-wise CRC Calculations,” IEEE Micro, Vol. 3, No. 3, 1983
  - R. J. Glaise, “A Two-Step Computation of Cyclic Redundancy Code CRC-32 for ATM Networks,” IBM Journal of Research and Development, Vol. 41, Issue 6, 1997
