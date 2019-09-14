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

    /// RAM size.
    size_t ramSize()
    {
        return 4096;
    }
}

/// Dumps context object for debugging.
void dumpContext(Context ctx)
{
    auto regs = ctx.regs;
    // auto ram = ctx.ram;

    writeln("==== regs begin ====");
    writef("pc:   %s\n", regs.pc);
    for (auto i = 0; i < regs.XLEN; i++)
    {
        writef("x%s:    %s\n", i, regs[i]);
    }
    writeln("==== regs end ====\n");
}

/// Interprets the given [inst].
void interp(Context ctx, uint ir)
{
    Inst inst = decode(ir);
    debug writeln("interp:\t", inst);

    switch (inst.opcode)
    {
        case Inst.I_TYPE_AL, Inst.R_TYPE:
            ctx.interpAL(inst);
            break;

        case Inst.I_TYPE_LOAD:
            ctx.interpLoad(inst);
            break;

        case Inst.S_TYPE:
            ctx.interpStore(inst);
            break;

        case Inst.U_TYPE_LUI, Inst.U_TYPE_AUIPC:
            ctx.interpUty(inst);
            break;

        case Inst.B_TYPE:
            ctx.interpBr(inst);
            break;

        case Inst.J_TYPE_JAL:
            ctx.interpJAL(inst);
            break;

        case Inst.I_TYPE_JALR:
            ctx.interpJALR(inst);
            break;

        default:
            assert(false, "Not implemented");
    }
    ctx.regs.pc += 4;
    assert(ctx.regs.pc <= ctx.ramSize, "PC exceled max RAM address.");

    debug ctx.dumpContext();
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
    
    // Store reg and sign-extend it.
    // Note that 'char' type in D is unsigned:
    // https://dlang.org/spec/type.html
    switch (iinst.kind)
    {
        // TODO: Remove these asserts.
        case IInst.LB, IInst.LBU:
            assert(addr >= 0 && addr < ctx.ramSize);
            res = ram[addr];

            if (iinst.kind == IInst.LB)
                res = (res << 24) >> 24;
            break;
        
        case IInst.LH, IInst.LHU: 
            assert(addr >= 0 && addr + 1 < ctx.ramSize);
            res = (ram[addr + 1] << 8) | ram[addr]; 

            if (iinst.kind == IInst.LH)
                res = (res << 16) >> 16;
            break;
        
        case IInst.LW: 
            assert(addr >= 0 && addr + 3 < ctx.ramSize);
            res = (ram[addr + 3] << 24) | (ram[addr + 2] << 16) | (ram[addr + 1] << 8) | ram[addr]; 
            break;
  
        default:
            assert(false, "Not supported load");
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
    
    switch (sinst.width)
    {
        case 1:
            assert(addr > 0 && addr < ctx.ramSize);
            ram[addr] = srcval & 0xFF;
            break;

        case 2: 
            assert(addr > 0 && addr + 1 < ctx.ramSize);
            ram[addr] = srcval & 0xFF;
            ram[addr + 1] = (srcval >> 8) & 0xFF;
            break;
        
        case 4:
            assert(addr > 0 && addr + 4 < ctx.ramSize);
            ram[addr] = srcval & 0xFF;
            ram[addr + 1] = (srcval >> 8) & 0xFF;
            ram[addr + 2] = (srcval >> 16) & 0xFF;
            ram[addr + 3] = (srcval >> 24) & 0xFF;
            break;

        default:
            assert(false, "Invalid width of store instruction");
    }
}

/// Interprets LUI and AUIPC.
void interpUty(Context ctx, Inst inst)
{
    assert(
        inst.opcode == Inst.U_TYPE_AUIPC || 
        inst.opcode == Inst.U_TYPE_LUI
    );

    auto uinst = cast(UInst)inst;
    assert(uinst !is null);
    
    const imm = uinst.imm;
    size_t rd = uinst.rd;

    if (uinst.opcode == Inst.U_TYPE_LUI)
    {
        ctx.regs[rd] = imm;
    }

    else
    {
        // We're in the middle of executing this instruction,
        // the pc points to this one for now.
        ctx.regs[rd] = imm + ctx.regs.pc;
    }
}

/// Interprets the given conditional branch.
void interpBr(Context ctx, Inst inst)
{
    auto binst = cast(BInst)inst;

    assert(binst !is null);
    assert(binst.opcode == Inst.B_TYPE);

    int opnd1 = ctx.regs[binst.rs1];
    int opnd2 = ctx.regs[binst.rs2];
    int imm = binst.imm;

    switch (binst.kind)
    {
        case BInst.BEQ:
        if (opnd1 == opnd2)
            ctx.regs.pc += imm;
        return;

        case BInst.BNE:
        if (opnd1 != opnd2)
            ctx.regs.pc += imm;
        return;

        case BInst.BLT:
        if (opnd1 < opnd2)
            ctx.regs.pc += imm;
        return;

        case BInst.BGE:
        if (opnd1 > opnd2)
            ctx.regs.pc += imm;
        return;

        case BInst.BLTU:
        if (cast(uint)opnd1 < cast(uint)opnd2)
            ctx.regs.pc += imm;
        return;

        case BInst.BGEU:
        if (cast(uint)opnd1 > cast(uint)opnd2)
            ctx.regs.pc += imm;
        return;

        default:
            assert(false, "Unknown branch");
    }
}

/// Interprets JAL.
void interpJAL(Context ctx, Inst inst)
{
    auto jinst = cast(JInst)inst;

    assert(jinst !is null);
    assert(jinst.opcode == Inst.J_TYPE_JAL);

    ctx.regs[jinst.rd] = ctx.regs.pc + 4;
    ctx.regs.pc += jinst.offset;
}

/// Interprets JALR.
void interpJALR(Context ctx, Inst inst)
{
    auto iinst = cast(IInst)inst;

    assert(iinst !is null);
    assert(iinst.opcode == Inst.I_TYPE_JALR);

    ctx.regs[iinst.rd] = ctx.regs.pc + 4;
    // Absolute address.
    ctx.regs.pc = ctx.regs[iinst.rs1] + iinst.imm;
}

unittest 
{
    auto ctx = new Context;

    // ADDI x1, x0, 0x4
    auto ir = 0x400093;
    interp(ctx, ir);

    // SW x0, x1, 0x2
    // (Store x1 to ram[x0 + 0x2])
    ir = 0x102123;
    interp(ctx, ir);

    // LB x1, x2, 0x2
    // (Load ram[x2 + 0x2] to x1)
    ir = 0x210083;
    interp(ctx, ir);

    // LUI x1, 2^12
    ir = 0x20B7;
    interp(ctx, ir);

    /// BEQ x1, x2, 0x20
    ir = 0x02208063;
    interp(ctx, ir);

    /// JAL x1, 0x20
    ir = 0x020000EF;
    interp(ctx, ir);
}