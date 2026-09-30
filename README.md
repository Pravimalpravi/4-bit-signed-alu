
# 4-bit Signed ALU

A 4-bit signed Arithmetic Logic Unit designed and verified using SystemVerilog.

## Overview

This project implements a modular 4-bit signed ALU supporting arithmetic, logical, and comparison operations.

The design uses hierarchical RTL, with the arithmetic datapath built from Half Adder, Full Adder, and Ripple-Carry Adder modules.

## Supported Operations

| Opcode | Operation  |
|--------|------------|
| 000    | ADD        |
| 001    | SUB        |
| 010    | AND        |
| 011    | OR         |
| 100    | XOR        |
| 101    | Signed SLT |

## Architecture

The arithmetic datapath is organized hierarchically:

    Half Adder
        |
        v
    Full Adder
        |
        v
    4-bit Ripple-Carry Adder
        |
        v
    ADD/SUB Unit
        |
        v
    4-bit Signed ALU

The ADD/SUB unit reuses the same Ripple-Carry Adder for both addition and subtraction.

Subtraction is performed using two's-complement arithmetic:

    A - B = A + (~B) + 1

The `sub` control signal determines whether `B` is inverted and whether the initial carry-in is set to `1`.

## Signed Arithmetic

The ALU uses 4-bit two's-complement representation.

    Minimum value = -8
    Maximum value = +7

The physical arithmetic circuit operates on the bit patterns, while the signed interpretation determines the numerical meaning of those patterns.

### Signed Overflow

For addition, overflow occurs when:

- Both operands have the same sign.
- The result has the opposite sign.

For subtraction, overflow occurs when:

- The operands have opposite signs.
- The result has a sign different from the first operand.

The ALU provides the overflow condition separately from the 4-bit result.

## Result Interpretation

The ALU provides three outputs:

- Standard 4-bit `result`
- `overflow` flag
- Auxiliary 5-bit `full_result`

The auxiliary `full_result` reconstructs the correct mathematical result for signed arithmetic cases where the 4-bit result overflows.

For example:

    7 + 1

      0111
    + 0001
    ------
      1000

The 4-bit result is:

    1000

which represents `-8` when interpreted as a 4-bit signed two's-complement number.

However, the actual mathematical result is:

    +8

The overflow flag identifies that the 4-bit signed result is outside the representable range, and the auxiliary 5-bit output provides the correct mathematical result:

    01000 = +8

This auxiliary output is an additional design feature for result interpretation; the standard ALU result remains the 4-bit result together with the overflow flag.

## Verification

The ALU was exhaustively verified using a SystemVerilog testbench.

The testbench covers:

- All 16 possible signed values of `A`
- All 16 possible signed values of `B`
- All 6 supported operations

Total number of test cases:

    16 x 16 x 6 = 1536

Verification result:

    TOTAL TESTS  : 1536
    PASSED       : 1536
    FAILED       : 0

All 1536 test cases passed successfully.

## Files

    design.sv
    testbench.sv
    README.md

### design.sv

Contains:

- Half Adder
- Full Adder
- 4-bit Ripple-Carry Adder
- ADD/SUB unit
- AND unit
- OR unit
- XOR unit
- Signed SLT unit
- Top-level 4-bit ALU

### testbench.sv

Contains the automated exhaustive verification environment covering all supported operations and signed input combinations.

## Tools

- SystemVerilog
- Icarus Verilog
- EDA Playground
- EPWave

## Learning Focus

This project was developed to strengthen understanding of:

- Hierarchical RTL design
- Structural module composition
- Two's-complement arithmetic
- Signed overflow detection
- Combinational datapath design
- SystemVerilog testbench development
- Exhaustive functional verification
- Waveform-based debugging
