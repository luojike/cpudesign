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
        JALR,
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

    /// Base address. rs1.
    size_t base;

    /// Width in bytes to write to RAM.
    size_t width;

    /// rs2 index. rs2 stores the value to write to RAM.
    size_t reg_idx;

    /// Constructor.
    this(
        Opcode opcode, 
        int offset, 
        size_t base, 
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
            case 1: opstr = "SB"; break;
            case 2: opstr = "SH"; break;
            case 4: opstr = "SW"; break;
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

/// Decode from bit pattern.
Inst decode(uint ir)
{
    /// Mask for opcode.
    const opMask = 0x7F;
    const opcode = ir & opMask;

    /// funct code extractor.
    uint funct(uint nbits)(uint ir)
    {
        static if (nbits == 3)
        {
            return (ir >> 12) & 0x07;
        }

        static if (nbits == 7)
        {
            return (ir >> 25) & 0x7F;
        }
    }

    /// Register extractor.
    size_t reg(string regname)(uint ir)
    {
        const regMask = 0x1F;
        static if (regname == "rs1")
        {
            return (ir >> 15) & regMask;
        }

        static if (regname == "rs2")
        {
            return (ir >> 20) & regMask;
        }

        static if (regname == "rd")
        {
            return (ir >> 7) & regMask;
        }

        else
            assert(false);
    }

    int imm(char type)(uint ir)
    {
        static if (type == 'I')
        {
            return (ir >> 20) & 0x0FFF;
        }

        static if (type == 'S')
        {
            int low = (ir >> 7) & 0x1F;
            int high = ((ir >> 25) & 0x7F) << 5;
            return high | low;
        }

        static if (type == 'U')
        {
            return ir & 0xFFFFF000;
        }

        static if (type == 'B')
        {
            // TODO:
            return 0;
            // int res = (ir >> 7) & 0x1E;
            // ir << 
        }
        else
            assert(false);
    }

    switch (opcode)
    {
        case Inst.I_TYPE_AL:
        {
            IInst.Kind kind;
            bool imm_signed = true;
            int imm_val = imm!'I'(ir);

            switch (funct!3(ir))
            {
                case 0:
                kind = IInst.ADDI;
                break;

                case 1:
                kind = IInst.SLLI;
                imm_val = 0x1F & imm_val;
                break;

                case 2:
                kind = IInst.SLTI;
                break;

                case 3:
                kind = IInst.SLTIU;
                imm_signed = false;
                break;

                case 4:
                kind = IInst.XORI;
                break;

                case 5:
                switch (funct!7(ir))
                {
                    case 0: kind = IInst.SRLI; break;
                    case 2: kind = IInst.SRAI; break;
                    default:
                        assert(false);
                }
                imm_val = 0x1F & imm_val;
                break;

                case 6:
                kind = IInst.ORI;
                break;

                case 7:
                kind = IInst.ANDI;
                break;

                default:
                    assert(false);
            }
            return new IInst(
                opcode,
                kind,
                reg!"rs1"(ir),
                reg!"rd"(ir),
                imm_val,
                imm_signed
            );
        }

        case Inst.I_TYPE_JALR:
            return new IInst(
                opcode,
                IInst.JALR,
                reg!"rs1"(ir),
                reg!"rd"(ir),
                imm!'I'(ir),
                true,
            );

        case Inst.I_TYPE_LOAD:
        {
            IInst.Kind kind;

            switch (funct!3(ir))
            {
                case 0: kind = IInst.LB; break;
                case 1: kind = IInst.LH; break;
                case 2: kind = IInst.LW; break;
                case 4: kind = IInst.LBU; break;
                case 5: kind = IInst.LHU; break;
                default:
                    assert(false);
            }
            return new IInst(
                opcode,
                kind,
                reg!"rs1"(ir),
                reg!"rd"(ir),
                imm!'I'(ir),
                (kind != IInst.LBU && kind != IInst.LHU),
            );
        }

        case Inst.R_TYPE:
        {
            RInst.Kind kind;

            switch (funct!3(ir))
            {
                case 0:
                {
                    switch (funct!7(ir))
                    {
                        case 0: kind = RInst.ADD; break;
                        case 0x20: kind = RInst.SUB; break;
                        default:
                            assert(false);
                    }
                }
                break;

                case 1:
                kind = RInst.SLL;
                break;

                case 2:
                kind = RInst.SLT;
                break;

                case 3:
                kind = RInst.SLTU;
                break;

                case 4:
                kind = RInst.XOR;
                break;

                case 5:
                {
                    switch (funct!7(ir))
                    {
                        case 0: kind = RInst.SRL; break;
                        case 0x20: kind = RInst.SRA; break;
                        default: assert(false);
                    }
                }
                break;

                case 6:
                kind = RInst.OR;
                break;

                case 7:
                kind = RInst.AND;
                break;

                default:
                    assert(false);
            }
            return new RInst(
                opcode,
                kind,
                reg!"rs1"(ir),
                reg!"rs2"(ir),
                reg!"rd"(ir),
            );
        }

        case Inst.S_TYPE:
        {
            size_t width;
            switch (funct!3(ir))
            {
                case 0: width = 1; break;   // SB
                case 1: width = 2; break;   // SH
                case 2: width = 4; break;   // SW
                default: assert(false);
            }
            return new SInst(
                opcode,
                imm!'S'(ir),
                reg!"rs1"(ir),
                width,
                reg!"rs2"(ir),
            );
        }

        case Inst.U_TYPE_LUI, Inst.U_TYPE_AUIPC:
            return new UInst(
                opcode,
                imm!'U'(ir),
                reg!"rd"(ir),
            );
    
        case Inst.B_TYPE:
        {
            BInst.Kind kind;
            switch (funct!3(ir))
            {
                case 0: kind = BInst.BEQ; break;
                case 1: kind = BInst.BNE; break;
                case 4: kind = BInst.BLT; break;
                case 5: kind = BInst.BGE; break;
                case 6: kind = BInst.BLTU; break;
                case 7: kind = BInst.BGEU; break;
                default:
                    assert(false);
            }
            return new BInst(
                opcode,
                kind,
                reg!"rs1"(ir),
                reg!"rs2"(ir),
                imm!'B'(ir),
                (kind != BInst.BLTU && kind != BInst.BGEU),
            );
        }

        case Inst.J_TYPE_JAL:
            return new JInst(
                opcode,
                imm!'J'(ir),
                reg!"rd"(ir),
            );

        default:
            assert(false);
    }
}

unittest
{

}