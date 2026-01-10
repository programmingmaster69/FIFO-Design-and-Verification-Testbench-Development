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

Sample Output and Successful verification check: <img width="449" height="381" alt="image" src="https://github.com/user-attachments/assets/4991dc46-063a-4189-a312-9f5f17cb48d7" />

