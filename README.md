# Parallel CRC Generator (M-bit Polynomial & N-bit Data)

A Perl-based generator script that automatically creates synthesizable Verilog modules for parallel CRC (Cyclic Redundancy Check) computation. Unlike traditional serial CRC implementations that require multiple clock cycles, this tool generates hardware that computes the complete CRC value in a single clock cycle, regardless of the input data width.

## Overview

This project provides a generic solution for generating parallel CRC modules with customizable polynomial configurations. The generated Verilog modules are optimized for high-throughput applications, making them ideal for systems processing streaming data where CRC calculation must keep pace with data reception rates.

The implementation is based on well-established research papers that describe parallel CRC generation methods using matrix transformations (H1 and H2 matrices) to convert serial CRC algorithms into parallel implementations.

### Key Features

- **Single-cycle computation**: Complete CRC calculation in one clock cycle
- **Fully customizable**: Supports any M-bit CRC polynomial with N-bit data input
- **Synthesis-ready**: Generated code is linted and ready for FPGA/ASIC synthesis
- **Interactive script**: User-friendly Perl script with guided input prompts
- **MIT Licensed**: Free to use, modify, and distribute

## Architecture

The generated modules implement a parallel CRC architecture that uses combinational logic to compute CRC values. The internal block diagram below illustrates the fundamental implementation:

![Parallel CRC Block Diagram](https://github.com/PXVI/adv_module/blob/master/CRC/Parallel/crc_parallel_block_diagram.png)

**Figure**: Reference from paper (1) - A Practical Parallel CRC Generation Method by Evgeni Stavinov

## Requirements

- Perl interpreter (standard on most Unix-like systems)
- Verilog synthesis tool (for using the generated modules)

## Usage

The script is interactive and will guide you through the generation process. Simply run the script and follow the prompts:

```bash
perl script_crc_NxMbit_module_gen.pl
```

### Step-by-Step Guide

1. **Data Input Width (N-bit)**: Enter the width of your input data bus
   - Example: `8` for 8-bit data, `32` for 32-bit data

2. **CRC Width (M-bit)**: Enter the width of the CRC polynomial
   - Example: `5` for CRC-5, `16` for CRC-16, `32` for CRC-32

3. **Polynomial Degrees**: Enter the polynomial degrees in descending order
   - The first degree must equal the M-bit width you specified
   - Continue entering degrees in descending order
   - Enter `0` to finish entering degrees
   - Example for polynomial x^5 + x^2 + 1: Enter `5`, then `2`, then `0`

4. **Module Suffix (Optional)**: Enter a custom suffix for the module name
   - Leave blank for default naming: `crc{M}_{N}bit_parallel_mod`
   - With suffix: `crc{M}_{N}bit_parallel_{suffix}_mod`
   - Example suffixes: `usb2`, `ethernet`, `custom`

### Example Session

```
# ----------------------------------
# Paralle CRC Generation Module v0.1
# ----------------------------------
# 
# This perl script will generate a N-bit input M-bit CRC module with a specific CRC polynomial.
# 
# Enter the data input width ( N-bit width ) : 8
# Enter the crc width ( M-bit width )        : 5
# 
# Start entering the CRC polynomial degrees one by one in the descending order...
# Enter the polynomial degree ( ideally first would be the M value that you have provided ) : 5
# Enter the next polynomial degree in the order ( 0 will finish this step )                 : 2
# Enter the next polynomial degree in the order ( 0 will finish this step )                 : 0
# 
# Polynomial matrices have been generated.
# Design equations have been calculated and now moving to the final step.
# 
# Enter an appropriate suffix for the module ( eg. uhs3, usb2, ccti, don_no_1 etc ) : usb2
# 
# ------------------------------------------------------- 
# [S] The parallel CRC verilog module has been generated. 
# ------------------------------------------------------- 
```

This example generates a module file named `crc5_8bit_parallel_usb2_mod.v` for an 8-bit input with a 5-bit CRC using polynomial x^5 + x^2 + 1.

### Generated Module Interface

The generated Verilog module includes the following signals:

- **CLK**: Clock input
- **RSTn**: Active-low reset
- **data_in[N-1:0]**: N-bit data input
- **enable**: Enable signal for CRC calculation
- **clear**: Synchronous clear to reset CRC to seed value
- **CRC[M-1:0]**: M-bit CRC output
- **RESET_SEED**: Parameter for initial CRC seed value (default: 'h00)

## Implementation Details

This tool implements the parallel CRC generation method described in the research papers listed below. The algorithm works by:

1. **Matrix Generation**: Computing H1 and H2 transformation matrices based on the polynomial
   - H1 matrix: Maps input data bits to CRC output
   - H2 matrix: Maps previous CRC state to new CRC output

2. **Equation Generation**: Deriving combinational logic equations from the matrices

3. **Module Generation**: Creating a synthesizable Verilog module with:
   - Clocked state machine for CRC accumulation
   - Combinational logic for parallel CRC computation
   - Control signals for enable and clear functionality

The generated code uses XOR operations to implement the polynomial-based CRC calculation in parallel, eliminating the need for shift registers and multiple clock cycles.

## License

This project is licensed under the **MIT License**. 

Copyright (c) 2020 k-sva

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the condition that the above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

## Research Papers & References

This implementation is based on parallel CRC generation methods described in the following research papers:

1. **A Practical Parallel CRC Generation Method** by Evgeni Stavinov
   - Primary reference for the matrix-based parallel CRC implementation

2. G. Albertango and R. Sisto, **"Parallel CRC Generation,"** IEEE Micro, Vol. 10, No. 5, 1990.

3. G. Campobello, G. Patane, M. Russo, **"Parallel CRC Realization,"** http://ai.unime.it/~gp/publications/full/tccrc.pdf

4. A. Perez, **"Byte-wise CRC Calculations,"** IEEE Micro, Vol. 3, No. 3, 1983

5. R. J. Glaise, **"A Two-Step Computation of Cyclic Redundancy Code CRC-32 for ATM Networks,"** IBM Journal of Research and Development, Vol. 41, Issue 6, 1997

The method transforms serial CRC algorithms into parallel implementations using matrix mathematics, allowing the computation to be performed in a single clock cycle regardless of data width.

## Contributing

If you find any bugs or have suggestions for improvements, please feel free to report them. The script includes error checking, but edge cases may exist.

## Author

pxvi (k-sva)
