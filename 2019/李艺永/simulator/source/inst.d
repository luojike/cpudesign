///     Module inst.d
///     This module contains instruction encodings of RV32I.
///     Copyright 2019 Yiyong Li

module inst;

import std.conv : to;
import std.format : format;

/// Base Instruction representation class.
/// Subclasses of Inst are just passive data structures
/// that simplify later interpretation.
class Inst
{
    alias Opcode = uint;
    enum : Opcode
    {
        // Use conversion to deal with numerics starting from 0.

        I_TYPE_JALR     = to!uint("1100111", 10/* convert 10 decimal. */),
        I_TYPE_LOAD     = to!uint("0000011", 10),
        I_TYPE_AL       = to!uint("0010011", 10),

        U_TYPE_AUIPC    = to!uint("0010111", 10),
        U_TYPE_LUI      = to!uint("0110111", 10),

        J_TYPE_JAL      = to!uint("1101111", 10),
        B_TYPE          = to!uint("1100011", 10),
        S_TYPE          = to!uint("0100011", 10),
        R_TYPE          = to!uint("0110011", 10),  // AL_type.
    }

    Opcode opcode;

    /// Base constructor needs an opcode.
    this(Opcode opcode)
    {
        assert(
            opcode == I_TYPE_AL     ||
            opcode == I_TYPE_LOAD   ||
            opcode == I_TYPE_AL     ||
            opcode == U_TYPE_AUIPC  ||
            opcode == U_TYPE_LUI    ||
            opcode == I_TYPE_JALR   ||
            opcode == J_TYPE_JAL    ||
            opcode == B_TYPE        ||
            opcode == S_TYPE        ||
            opcode == R_TYPE,
            "Unknown opcode"
        );
        this.opcode = opcode;
    }

    /// Return true if this instruction encodes an arithmetic 
    /// or logical operation.
    bool isArithOrLogical() const
    {
        return false;
    }

    /// Return true if this instruction encodes a branch(both conditional and not).
    bool isBranch() const
    {
        return (
            opcode == B_TYPE     || 
            opcode == J_TYPE_JAL || 
            opcode == I_TYPE_JALR
        );
    }

    /// Return true if this instruction needs to
    /// write a value to register rd.
    bool writeRD() const
    {
        // TODO:
        // ECALL and EBREAK are ignored for now.
        return (opcode != S_TYPE && opcode != B_TYPE);
    }

    override string toString() const
    {
        return "Base Instruction";
    }
}

/// U-type encoding instruction.
class UInst : Inst
{
    /// Immediate field.
    int imm;

    /// Index of rd register.
    size_t rd;

    /// Constructor for either LUI or AUIPC.
    this(Opcode op, int imm, size_t rd)
    {
        assert(op == U_TYPE_LUI || op == U_TYPE_AUIPC);
        
        super(op);
        this.imm = imm;
        this.rd = rd;
    }

    override string toString() const
    {
        return format!"%s x%s %s"(
            (opcode == U_TYPE_LUI ? "LUI" : "AUIPC"),
            rd,
            imm,
        );
    }
}

/// I-type encoding instruction.
class IInst : Inst
{
    /// Immediate field.
    int imm;
    /// Flag indicates whether imm is signed-extended.
    bool imm_signed;

    /// rd register index.
    size_t rd;

    /// rs1 register index.
    size_t rs1;

    alias Kind = int;
    enum : Kind
    {
        LB,
        LH,
        LW,
        LBU,
        LHU,
        ADDI,
        SLTI,
        SLTIU,
        XORI,
        ORI,
        ANDI,
        SLLI,
        SRLI,
        SRAI,
    }
    Kind kind;

    /// Constructor.
    this(Opcode op, 
        Kind kind, 
        size_t rs1, 
        size_t rd, 
        int imm, 
        bool imm_signed = true
    )
    {
        assert(
            op == I_TYPE_AL     ||
            op == I_TYPE_JALR   ||
            op == I_TYPE_LOAD
        );
        super(op);

        this.kind = kind;
        this.rs1 = rs1;
        this.rd = rd;
        this.imm = imm;
        this.imm_signed = imm_signed;
    }

    override bool isArithOrLogical() const
    {
        return opcode == I_TYPE_AL;
    }

    override string toString() const
    {
        string opstr;

        switch (kind)
        {
            case LB:    opstr = "LB"; break;
            case LH:    opstr = "LH"; break;
            case LW:    opstr = "LW"; break;
            case LBU:   opstr = "LBU"; break;
            case LHU:   opstr = "LHU"; break;
            case ADDI:  opstr = "ADDI"; break;
            case SLTI:  opstr = "SLTI"; break;
            case SLTIU: opstr = "SLTIU"; break;
            case XORI:  opstr = "XORI"; break;
            case ORI:   opstr = "ORI"; break;
            case ANDI:  opstr = "ANDI"; break;
            case SLLI:  opstr = "SLLI"; break;
            case SRLI:  opstr = "SRLI"; break;
            case SRAI:  opstr = "SRAI"; break;
            default:
                assert(false);
        }
        return format!"%s x%s x%s %s"(
            opstr,
            rd,
            rs1,
            (imm_signed ? imm : cast(uint)imm),
        );
    }
}

/// J-type encoding instruction. JAL only.
class JInst : Inst
{
    /// Signed-extended offset.
    int offset;

    /// rd register index.
    size_t rd;

    /// Constructor.
    this(Opcode op, int offset, size_t rd)
    {
        assert(op == J_TYPE_JAL);

        super(op);
        this.offset = offset;
        this.rd = rd;
    }

    override string toString() const
    {
        return format!"%s x%s %s"(
            "JAL",
            rd,
            offset
        );
    }
}

/// B-type encoding instructions.
class BInst : Inst
{
    /// Immediate as offset.
    int imm;
    /// Signed-extended?
    bool imm_signed;

    /// rs1 register index.
    size_t rs1;

    /// rs2 register index
    size_t rs2;

    alias Kind = int;
    enum : Kind
    {
        BEQ,
        BNE,
        BLT,
        BGE,
        BLTU,
        BGEU,
    }
    Kind kind;

    /// Constructor.
    this(Opcode opcode,
        Kind kind,
        size_t rs1, 
        size_t rs2, 
        int imm, 
        bool imm_signed = true)
    {
        assert(opcode == B_TYPE);
        super(opcode);

        this.kind = kind;
        this.rs1 = rs1;
        this.rs2 = rs2;
        this.imm = imm;
        this.imm_signed = imm_signed;
    }

    override string toString() const
    {
        string opstr;

        switch (kind)
        {
            case BEQ:   opstr = "BEQ"; break;
            case BNE:   opstr = "BNE"; break;
            case BGE:   opstr = "BGE"; break;
            case BLTU:  opstr = "BLTU"; break;
            case BGEU:  opstr = "BGEU"; break;
            default:
                assert(false);
        }

        return format!"%s x%s x%s %s"(
            opstr,
            rs1,
            rs2,
            (imm_signed ? imm : cast(uint)imm),
        );
    }
}

/// R-type encoding instruction.
class RInst : Inst
{
    /// rs1 register index.
    size_t rs1;

    /// rs2 register index.
    size_t rs2;

    /// rd register index.
    size_t rd;

    alias Kind = int;
    enum : Kind
    {
        ADD,
        SUB,
        SLL,    // Shift Left Logical
        SLT,    // Set Less Than
        SLTU,   // Set Less Than Unsigned
        XOR,
        SRL,    // Shift Right Logical
        SRA,    // Shift Right Arithmetic
        OR,
        AND,
    }
    Kind kind;

    /// Constructor.
    this(
        Opcode opcode, 
        Kind kind,
        size_t rs1,
        size_t rs2,
        size_t rd
    )
    {
        assert(opcode == R_TYPE);

        super(opcode);
        this.kind = kind;
        this.rs1 = rs1;
        this.rs2 = rs2;
        this.rd = rd;
    }
}

/// S-type encoding.
class SInst : Inst
{
    /// Offset.
    int offset;

    /// Base address.
    int base;

    /// Width in bytes to write to RAM.
    size_t width;

    /// rs1 index. rs1 stores the value to write to RAM.
    size_t reg_idx;

    /// Constructor.
    this(
        Opcode opcode, 
        int offset, 
        int base, 
        size_t width, 
        size_t reg_idx
    )
    {
        assert(opcode == S_TYPE);

        super(opcode);
        this.offset = offset;
        this.base = base;
        this.width = width;
        this.reg_idx = reg_idx;
    }

    override string toString() const
    {
        string opstr;

        switch (width)
        {
            case 1: opstr = "SB";
            case 2: opstr = "SH";
            case 4: opstr = "SW";
            default:
                assert(false);
        }
        return format!"%s x%s x%s %s"(
            opstr,
            reg_idx,
            base,
            offset
        );
    }
}

unittest
{

}