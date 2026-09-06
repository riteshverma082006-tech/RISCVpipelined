# RV32I 5-Stage Pipelined RISC-V Processor (Verilog)

A synthesizable, fully working 5-stage pipelined RISC-V (RV32I) CPU, structured
to match the datapath/block names in your diagram (Instruction Parser,
Registers, Immediate Data Extractor, ALU_Control, Forwarding Unit, IF/ID,
ID/EX, EX/MEM, MEM/WB, etc).

Verified in simulation (Icarus Verilog) — **3 test programs, 100% passing**,
covering forwarding, load-use stalling, branch/jump squashing, and byte-level
memory ops. See "How to simulate" below to reproduce.

## Pipeline stages

```
IF  ->  ID  ->  EX  ->  MEM ->  WB
```

- **IF**: PC register + adder (PC+4) + instruction memory.
- **ID**: Instruction Parser, Control Unit, Register File (write-first, so a
  same-cycle WB write is visible to a reading ID the same cycle), Immediate
  Data Extractor, Hazard Detection Unit.
- **EX**: Forwarding Unit, ALU_Control, ALU (with dedicated eq/lt/ltu
  comparator outputs), PC-relative adder for branch/jump targets, Branch Unit.
- **MEM**: Data Memory (byte-addressable, supports byte/half/word).
- **WB**: write-back mux (ALU result / memory data / PC+4 link value).

## Instructions supported (full RV32I base, minus system instructions)

R-type: `add sub sll slt sltu xor srl sra or and`
I-type ALU: `addi slti sltiu xori ori andi slli srli srai`
Loads/Stores: `lb lh lw lbu lhu / sb sh sw`
Branches: `beq bne blt bge bltu bgeu`
Jumps: `jal jalr`
Upper-immediate: `lui auipc`

Not implemented: `fence`, `ecall`/`ebreak`, CSR instructions, M-extension
(mul/div) — these aren't part of base RV32I control flow and are easy to add
onto this structure if you need them later.

## Hazard handling

- **Data hazards**: full EX-stage forwarding from EX/MEM and MEM/WB back into
  the ALU's A/B operands (`forwarding_unit.v`), including forwarding the
  store's data operand.
- **Load-use hazard**: `hazard_detection_unit.v` detects `lw` (or `lb`/`lh`)
  immediately followed by a dependent instruction and stalls the PC + IF/ID
  for one cycle while bubbling ID/EX.
- **Control hazards**: branches/jumps are resolved in EX (comparator flags
  computed directly from the ALU inputs, not the ALU result, so correctness
  doesn't depend on ALU-control decoding). A taken branch/jump flushes **both**
  IF/ID and ID/EX the same cycle (2-cycle branch penalty).

## File map

| File                        | Diagram block(s) |
|-----------------------------|-------------------|
| `pc_unit.v`                 | PC register, PC+4 Adder |
| `instruction_memory.v`      | Instruction Memory |
| `if_id_register.v`          | IF/ID |
| `instruction_parser.v`      | Instruction Parser |
| `control_unit.v`            | Control Unit |
| `register_file.v`           | Registers |
| `immediate_extractor.v`     | Immediate Data Extractor |
| `hazard_detection_unit.v`   | (stall logic straddling ID/EX) |
| `id_ex_register.v`          | ID/EX |
| `forwarding_unit.v`         | Forwarding Unit |
| `alu_control.v`             | ALU_Control |
| `alu.v`                     | ALU |
| `branch_unit.v`             | Branch/PCSrc resolution (feeds the far-left PC mux) |
| `ex_mem_register.v`         | EX/MEM |
| `data_memory.v`             | Data Memory |
| `mem_wb_register.v`         | MEM/WB |
| `riscv_pipeline_top.v`      | Top-level wiring of the whole datapath |
| `defines.vh`                | Shared opcode / control-code constants |

## How to simulate

Requires [Icarus Verilog](http://iverilog.icarus.com/) (`apt install iverilog`).

```bash
iverilog -g2012 -o sim.out defines.vh pc_unit.v instruction_memory.v \
  if_id_register.v instruction_parser.v control_unit.v register_file.v \
  immediate_extractor.v hazard_detection_unit.v id_ex_register.v \
  forwarding_unit.v alu_control.v alu.v branch_unit.v ex_mem_register.v \
  data_memory.v mem_wb_register.v riscv_pipeline_top.v tb_riscv_pipeline.v
vvp sim.out
```

Three testbenches are included:
- `tb_riscv_pipeline.v` (+ `program.hex`) — forwarding, load-use stall, taken
  `beq` with instruction squashing.
- `tb_riscv_pipeline2.v` (+ `program2.hex`) — `lui`, `auipc`, `sub`/`slt` with
  negative numbers, `jal`, `jalr`.
- `tb_riscv_pipeline3.v` (+ `program3.hex`) — signed/unsigned byte loads
  (`lb`/`lbu`), and `bne`/`blt`/`bge` both taken and not-taken.

Swap the last file in the compile line and the `.hex` referenced by
`riscv_pipeline_top`'s `IMEM_INIT_FILE` parameter to run each one, or write
your own `.hex` (one 8-digit hex instruction word per line) and instantiate
`riscv_pipeline_top #(.IMEM_INIT_FILE("your_program.hex")) dut (...)`.

## Notes for real use

- Instruction memory is a simple synchronous ROM (`$readmemh`); data memory is
  byte-addressable with combinational reads / registered writes. Swap these
  for real memory macros / caches for an ASIC or FPGA target.
- No exceptions/interrupts are implemented.
- Branches are resolved in EX (not ID), which is simpler to get correct but
  costs a 2-cycle misprediction penalty instead of 1. If you want a 1-cycle
  penalty, move the comparator + branch-target adder into ID and add the
  extra ID-stage forwarding paths that requires.
