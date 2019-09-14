///     Module interp.d
///     This module contains routines for an RV32I interpreter.
///     Copyright 2019 Yiyong Li

module interp;
import std.format;
import std.array;
import std.conv;
import regs;
import inst;

debug import std.stdio;

/// Contains status info for simulation.
class Context
{
    /// Registers.
    Regs regs;

    /// 4GB of RAM.
    char[4096] ram;

    /// Constructor.
    this()
    {
        regs = new Regs;
    }
}

/// Interprets the given [inst].
void interp(Context ctx, uint ir)
{
    Inst inst = decode(ir);

    switch (inst.opcode)
    {
        case Inst.I_TYPE_AL, Inst.R_TYPE:
            debug writeln("interp:\t", inst);
            return ctx.interpAL(inst);

        case Inst.I_TYPE_LOAD:
            debug writeln("interp:\t", inst);
            return ctx.interpLoad(inst);

        default:
            assert(false, "Not implemented");
    }
}

/// Interprets the given arithmetic or logical instruction.
void interpAL(Context ctx, Inst inst)
{
    auto regs = ctx.regs;
    assert(
        inst.opcode == Inst.I_TYPE_AL ||
        inst.opcode == Inst.R_TYPE
    );

    string genOpstr(string op, string dest, string opnd1, string opnd2)
    {
        if (op == "SLT")
            return format!"%s = (%s < %s) ? 1 : 0;"(
                dest,
                opnd1,
                opnd2,
            );
        
        else if (op == "SLTU")
            return format!"%s = (cast(uint)%s < cast(uint)%s) ? 1 : 0;"(
                dest,
                opnd1,
                opnd2,
            );

        return format!"%s = %s %s %s;"(
            dest,
            opnd1,
            op,
            opnd2
        );
    }

    string genOpstrs()
    {
        /// The order must match as exactly as those
        /// declare in class IInst.
        auto IOpstrs = [
            "+", "SLT", "SLTU", "^", "|", "&", "<<", ">>>", ">>"
        ];

        /// The order must match as exactly as those
        /// declare in class RInst.
        auto ROpstrs = [
            "+", "-", "<<", "SLT", "SLTU", "^", ">>>", ">>", "|", "&"
        ];

        /// Results.
        auto str = appender!string();

        /// Generate all cases.
        void genCasesStr(
            int off,
            string[] ops,
            string dest, 
            string opnd1, 
            string opnd2
        )
        {
            foreach (i, op; ops)
            {
                str.put("\tcase ");
                str.put(to!string(i + off));
                str.put(": ");
                str.put(genOpstr(op, dest, opnd1, opnd2));
                str.put("return;\n");
            }
        }

        /// Generate switch prolog.
        void genProlog(string instName)
        {
            str.put(format!"if (%s !is null) {\n"(instName));
            str.put(format!"switch (%s.kind) {\n"(instName));
        }

        /// Generate switch epilog.
        void genEpilog()
        {
            str.put("default: assert(false, \"Unknown operator\");");
            str.put("}\n");
            str.put("}\n");
        }

        auto IOff = 5;
        auto ROff = 0;

        genProlog("iinst");
        genCasesStr(IOff, IOpstrs, "regs[iinst.rd]", "regs[iinst.rs1]", "iinst.imm");
        genEpilog();

        genProlog("rinst");
        genCasesStr(ROff, ROpstrs, "regs[rinst.rd]", "regs[rinst.rs1]", "regs[rinst.rs2]");
        genEpilog();

        return str.data;
    }

    auto iinst = cast(IInst)inst;
    auto rinst = cast(RInst)inst;
    mixin(genOpstrs());

    assert(false, "Inst must be either IInst or RInst");
}

/// Interprets the given load instruction.
void interpLoad(Context ctx, Inst inst)
{
    auto regs = ctx.regs;
    auto ram = ctx.ram;
    auto iinst = cast(IInst)inst;
    int res;

    assert(iinst !is null);
    assert(iinst.opcode == Inst.I_TYPE_LOAD);

    size_t addr = cast(size_t)iinst.imm;
    switch (iinst.kind)
    {
        // TODO: Add memory contraints.
        case IInst.LB: 
            assert(addr >= 0 && addr < 4096);
            res = ram[addr]; break;
        
        case IInst.LH: 
            assert(addr >= 0 && addr + 1 < 4096);
            res = (ram[addr + 1] << 8) | ram[addr]; break;
        
        case IInst.LW: 
            assert(addr >= 0 && addr + 3 < 4096);
            res = (ram[addr + 3] << 24) | (ram[addr + 2] << 16) | (ram[addr + 1] << 8) | ram[addr]; break;
        
        default:
            assert(false, "Not supported load");
    }

    if (iinst.kind != iinst.LBU && iinst.kind != IInst.LHU)
    {
        // Sign-extend.
        // Note that 'char' type in D is unsigned:
        // https://dlang.org/spec/type.html
        switch (iinst.kind)
        {
            case IInst.LB: res = (res << 24) >> 24; break;
            case IInst.LH: res = (res << 16) >> 16; break;
            case IInst.LW: break;
            default:
                assert(false, "Not supported load");
        }
    }

    regs[iinst.rd] = res;
}

/// Interprets the given store instruction.
void interpStore(Context ctx, Inst inst)
{
    auto regs = ctx.regs;
    auto ram = ctx.ram;
    auto sinst = cast(SInst)inst;

    assert(sinst !is null);
    assert(sinst.opcode == Inst.S_TYPE);

    auto srcval = regs[sinst.src];
    auto addr = regs[sinst.base] + sinst.offset;
    
    // switch (sinst.width)
    // {
    //     case 1: ram[addr] = 
    // }
}

unittest 
{
    auto ctx = new Context;
    // ADDI x1, x0, 0x4
    auto ir = 0x400093;
    interp(ctx, ir);

    // LB x1, x2, 0x2
    ir = 0x210083;
    interp(ctx, ir);
}