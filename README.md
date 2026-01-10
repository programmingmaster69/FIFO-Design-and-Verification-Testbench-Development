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

Sample Output and Successful verification check: 











<img width="449" height="381" alt="390867291-ef36ed94-7d86-4d32-b72c-1ec750e8b72d" src="https://github.com/user-attachments/assets/e3b200c3-3fc9-4c0f-ac53-44caa44f9b22" />


