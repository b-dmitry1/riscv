`ifndef CPU_VH
`define CPU_VH

`define ALU_ADD     5'h00
`define ALU_SUB     5'h01
`define ALU_AND     5'h02
`define ALU_OR      5'h03
`define ALU_XOR     5'h04
`define ALU_SLL     5'h05
`define ALU_SRL     5'h06
`define ALU_SRA     5'h07
`define ALU_LUI     5'h08
`define ALU_AUIPC   5'h09
`define ALU_JAL     5'h0A
`define ALU_SEQ     5'h0B
`define ALU_SNE     5'h0C
`define ALU_SLT     5'h0D
`define ALU_SLTU    5'h0E
`define ALU_SGE     5'h0F
`define ALU_SGEU    5'h10
`define ALU_SADDR   5'h11
`define ALU_MUL     5'h18
`define ALU_MULH    5'h19
`define ALU_MULHSU  5'h1A
`define ALU_MULHU   5'h1B
`define ALU_DIV     5'h1C
`define ALU_DIVU    5'h1D
`define ALU_REM     5'h1E
`define ALU_REMU    5'h1F

`endif
