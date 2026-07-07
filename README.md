# Dual-Clock Asynchronous FIFO

This project implements a parameterized dual-clock asynchronous FIFO in SystemVerilog. The FIFO supports data transfer between independent write and read clock domains using Gray-code pointer synchronization and two-flop synchronizers.

The design was verified using a SystemVerilog testbench with different write and read clock frequencies. The testbench checks FIFO full and empty behavior by writing beyond the FIFO depth and reading beyond the available data.

---

## Project Overview

The objective of this project is to design and verify an asynchronous FIFO for safe data transfer across two different clock domains.

The FIFO uses binary pointers for local memory addressing and Gray-coded pointers for clock-domain crossing.

---

## Key Design Features

* Dual-clock asynchronous FIFO design
* Independent write and read clock domains
* Parameterized data width and FIFO depth
* Binary read and write pointers for memory addressing
* Gray-coded read and write pointers for clock-domain synchronization
* Two-flop synchronizers for pointer transfer across clock domains
* Full flag generation in the write clock domain
* Empty flag generation in the read clock domain
* Protection against write operation when FIFO is full
* Protection against read operation when FIFO is empty
* SystemVerilog testbench for functional verification

---

## Design Parameters

The design parameters are defined in `param.sv`.

```systemverilog
`define DATA_WIDTH 8
`define ADDR_WIDTH 3
```

| Parameter     | Value | Description                                              |
| ------------- | ----: | -------------------------------------------------------- |
| `DATA_WIDTH`  |     8 | Width of each FIFO data word                             |
| `ADDR_WIDTH`  |     3 | Address width of FIFO memory                             |
| FIFO Depth    |     8 | Number of FIFO locations, calculated as `2^ADDR_WIDTH`   |
| Pointer Width |     4 | Read/write pointer width, calculated as `ADDR_WIDTH + 1` |

---

## FIFO Architecture

The FIFO is divided into five main blocks:

1. FIFO Memory
2. Write Handler
3. Read Handler
4. Read Pointer Synchronizer
5. Write Pointer Synchronizer

---

## Module Description

| Module              | Description                                                      |
| ------------------- | ---------------------------------------------------------------- |
| `FIFO_Memory`       | Implements the FIFO memory array                                 |
| `Write_Handler`     | Generates write address, Gray-coded write pointer, and full flag |
| `Read_Handler`      | Generates read address, Gray-coded read pointer, and empty flag  |
| `Double_Flop_Sync1` | Synchronizes the read pointer into the write clock domain        |
| `Double_Flop_Sync2` | Synchronizes the write pointer into the read clock domain        |
| `Async_FIFO_top`    | Top-level module connecting all FIFO blocks                      |
| `testbench`         | Verifies FIFO write, read, full, and empty behavior              |

---

## Clock Domains

The FIFO uses two independent clocks:

| Clock  | Domain       | Description                                       |
| ------ | ------------ | ------------------------------------------------- |
| `wclk` | Write domain | Controls write pointer and memory write operation |
| `rclk` | Read domain  | Controls read pointer and empty flag generation   |

The `full` flag is generated in the write clock domain.
The `empty` flag is generated in the read clock domain.

---

## Pointer Synchronization

The FIFO uses Gray-coded pointers for clock-domain crossing.

Binary pointers are used locally for memory addressing:

```systemverilog
assign waddr = wptr_bin[`ADDR_WIDTH-1:0];
assign raddr = rptr_bin[`ADDR_WIDTH-1:0];
```

The binary pointers are converted to Gray code before synchronization:

```systemverilog
assign wptr_next = (wptr_bin_next >> 1) ^ wptr_bin_next;
assign rptr_next = (rptr_bin_next >> 1) ^ rptr_bin_next;
```

Gray code is used because only one bit changes between consecutive pointer values, reducing the risk of invalid pointer sampling across clock domains.

---

## Full and Empty Flag Generation

### Full Condition

The `full` flag is generated in the write clock domain by comparing the next Gray-coded write pointer with the synchronized read pointer.

```systemverilog
full <= (wptr_next == {~rptr_sync_wclk[`ADDR_WIDTH:`ADDR_WIDTH-1],
                        rptr_sync_wclk[`ADDR_WIDTH-2:0]});
```

### Empty Condition

The `empty` flag is generated in the read clock domain by comparing the next Gray-coded read pointer with the synchronized write pointer.

```systemverilog
empty <= (wptr_sync_rclk == rptr_next);
```

---

## Testbench

The testbench uses different write and read clock periods to verify asynchronous operation.

```systemverilog
always #5 wclk = ~wclk;   // Write clock period = 10 ns
always #8 rclk = ~rclk;   // Read clock period  = 16 ns
```

### Test Sequence

1. Reset the FIFO
2. Write data into the FIFO until it becomes full
3. Attempt additional writes after the FIFO is full
4. Read data from the FIFO until it becomes empty
5. Attempt additional reads after the FIFO is empty

### Write Data Sequence

```text
A0 A1 A2 A3 A4 A5 A6 A7 44 55 66
```

Since the FIFO depth is 8, only the first 8 values should be stored.

### Expected Read Data

```text
A0 A1 A2 A3 A4 A5 A6 A7
```

The extra values `44`, `55`, and `66` should not be written once the FIFO becomes full.

---

## Simulation

The design can be simulated using Vivado or any SystemVerilog-supported simulator.


## Reference 

This design is based on the asynchronous FIFO design technique described by Clifford E. Cummings in
