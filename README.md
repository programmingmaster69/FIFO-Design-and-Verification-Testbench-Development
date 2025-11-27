# FIFO Design and Verification Testbench (SystemVerilog)

A simple synchronous FIFO (First-In First-Out) buffer implemented in SystemVerilog, along with a self-checking verification testbench.

---

## Features

- Synchronous FIFO design in SystemVerilog  
- Parameterizable data width and depth (can be easily extended)  
- Standard FIFO status flags:
  - `full`
  - `empty`
- Self-checking testbench
- Stimulus including:
  - Reset behavior
  - Simple write/read sequences
  - Boundary conditions (full / empty behavior)
  - Corner cases like:
    - Writes when FIFO is full
    - Reads when FIFO is empty

---

