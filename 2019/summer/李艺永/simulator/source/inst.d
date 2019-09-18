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

        I_TYPE_JALR     = 0b1100111,
        I_TYPE_LOAD     = 0b0000011,
        I_TYPE_AL       = 0b0010011,

        U_TYPE_AUIPC    = 0b0010111,
        U_TYPE_LUI      = 0b0110111,

        J_TYPE_JAL      = 0b1101111,
        B_TYPE          = 0b1100011,
        S_TYPE          = 0b0100011,
        R_TYPE          = 0b0110011,
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
        return format!"%s x%s, %s"(
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
        LB = 0,
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
        return format!"%s x%s, x%s, %s"(
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
        return format!"%s x%s, %s"(
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

        return format!"%s x%s, x%s, %s"(
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
        ADD = 0,
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
    size_t src;

    /// Constructor.
    this(
        Opcode opcode, 
        int offset, 
        size_t base, 
        size_t width, 
        size_t src
    )
    {
        assert(opcode == S_TYPE);

        super(opcode);
        this.offset = offset;
        this.base = base;
        this.width = width;
        this.src = src;
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
        return format!"%s x%s, x%s, %s"(
            opstr,
            base,
            src,
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
            int res = (ir >> 8) & 0xF;
            res = res << 1;                     // The last bit is 0.
            res = res | ((ir >> 20) & 0x07E0);  // 10:5
            res = res | ((ir << 4) & 0x0800);   // 11.
            res = res | ((ir >> 19) & 0x1000);  // 12.
            res = (res << 19) >> 19;            // sign-extend.
            return res;
        }

        static if (type == 'J')
        {
            int res = 0;
            res = res | (ir & 0x0FF000);       // 19:12
            res = res | ((ir >> 9) & 0x0800);   // 11
            res = res | ((ir >> 20) & 0x07FE);  // 10:1
            res = res | ((ir >> 11)  & 0x100000); // 20
            res = (res << 11) >> 11;            // sign-extend.
            return res;
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
                    case 0x20: kind = IInst.SRAI; break;
                    default:
                        assert(
                            false,
                            "funct7 field for shift must be either 0 or 0x20"
                        );
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
                            assert(
                                false, 
                                "funct7 for SUB should be 0x20; 
                                funct7 for ADD should be 0"
                            );
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
                default: assert(
                    false,
                    "funct3 should be 0 for SB;
                    1 for SH;
                    2 for SW"
                );
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
                    assert(
                        false,
                        "Inappropriate funct3 field for B-type"
                    );
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
            assert(false, "Unknown opcode!");
    }
}

unittest
{

    /// LUI x1, 2^12
    uint ir = 0x20B7;
    Inst inst = decode(ir);
    auto uinst = cast(UInst)inst;
    assert(uinst !is null);
    assert(uinst.opcode == Inst.U_TYPE_LUI);
    assert(uinst.imm == (2 << 12));
    assert(uinst.rd == 1);
    // Cannot cast to any other type.
    assert(cast(IInst)inst is null);

    /// ADDI x1, x0, 0x4
    ir = 0x400093;
    inst = decode(ir);
    auto iinst = cast(IInst)inst;
    assert(iinst !is null);
    assert(iinst.opcode == Inst.I_TYPE_AL);
    assert(iinst.rd == 1);
    assert(iinst.rs1 == 0);
    assert(iinst.imm == 4);

    /// SLTIU x3, x2, 0x20
    ir = 0x02013193;
    inst = decode(ir);
    iinst = cast(IInst)inst;
    assert(iinst !is null);
    assert(iinst.opcode == Inst.I_TYPE_AL);
    assert(iinst.rd == 3);
    assert(iinst.rs1 == 2);
    assert(iinst.imm == 0x20);
    assert(iinst.imm_signed == false);

    /// ADD x1, x0, x2
    ir = 0x2000B3;
    inst = decode(ir);
    auto rinst = cast(RInst)inst;
    assert(rinst !is null);
    assert(rinst.opcode == Inst.R_TYPE);
    assert(rinst.rd == 1);
    assert(rinst.rs1 == 0);
    assert(rinst.rs2 == 2);

    /// SUB x1, x0, x2
    ir = 0x402000B3;
    inst = decode(ir);
    rinst = cast(RInst)inst;

    /// SH x2, x1, 0x20
    ir = 0x02111023;
    inst = decode(ir);
    auto sinst = cast(SInst)inst;
    assert(sinst !is null);
    assert(sinst.opcode == Inst.S_TYPE);
    assert(sinst.base == 2);
    assert(sinst.width == 2);
    assert(sinst.src == 1);

    /// JAL x1, 0x20
    ir = 0x020000EF;
    inst = decode(ir);
    auto jinst = cast(JInst)inst;
    assert(jinst !is null);
    assert(jinst.opcode == Inst.J_TYPE_JAL);
    assert(jinst.rd == 1);
    assert(jinst.offset == 0x20);

    /// BEQ x1, x2, 0x20
    ir = 0x02208063;
    inst = decode(ir);
    auto binst = cast(BInst)inst;
    assert(binst !is null);
    assert(binst.kind == BInst.BEQ);
    assert(binst.rs1 == 1);
    assert(binst.rs2 == 2);
    assert(binst.imm == 0x20);
}