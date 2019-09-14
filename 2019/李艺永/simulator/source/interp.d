///     Module interp.d
///     This module contains routines for an RV32I interpreter.
///     Copyright 2019 Yiyong Li

module interp;
import std.format;
import std.array;
import std.conv;
import core.stdc.string;
import regs;
import inst;

debug import std.stdio;

/// Contains status info for simulation.
class Context
{
    /// Registers.
    Regs regs;

    /// RAM size in bytes.
    static const RAM_SIZE = 4096;

    /// Assume the code starts from offset 0.
    static const CODE_START = 0;

    /// Length of each instruction representation.
    static const INSTR_LEN = uint.sizeof;

    /// 4MB of RAM.
    char[RAM_SIZE] ram;

    /// Constructor.
    this(char[] code, ulong sz)
    {
        assert(INSTR_LEN == 4);
        regs = new Regs;

        memcpy(cast(char*)ram, cast(char*)code, sz);
        regs.pc = CODE_START;
    }
}

/// Executes code within the given [ctx].
void interp(Context ctx)
{
    uint loadIR()
    {
        uint ir;
        auto ramStart = cast(char*)ctx.ram;
        if (ctx.regs.pc + 4 < Context.RAM_SIZE)
        {
            memcpy(&ir, ramStart + ctx.regs.pc, 4);
            return ir;
        }
        return -1;
    }

    uint ir;
    while ((ir = loadIR()) != -1)
    {
        auto inst = decode(ir);
        debug writeln("interp:\t", inst);
        auto offset = interpIR(ctx, inst);
        debug ctx.dumpContext();

        // Done executing all code.
        if (offset == Context.RAM_SIZE)   break;

        // Update PC.
        ctx.regs.pc += offset;
    }
}

/// Dumps context object for debugging.
debug void dumpContext(Context ctx)
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

/// Interprets the given instruction [ir].
/// Returns the number of offset PC should increment.
/// Returns Context.RAM_SIZE means we've done executing.
int interpIR(Context ctx, Inst inst)
{
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
            return ctx.interpBr(inst);

        case Inst.J_TYPE_JAL:
            return ctx.interpJAL(inst);

        case Inst.I_TYPE_JALR:
            return ctx.interpJALR(inst);

        default:
            /// If we've encountered any unknown instruction,
            /// this is the end.
            return Context.RAM_SIZE;
    }

    return Context.INSTR_LEN;
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
            assert(addr >= 0 && addr < Context.RAM_SIZE);
            res = ram[addr];

            if (iinst.kind == IInst.LB)
                res = (res << 24) >> 24;
            break;
        
        case IInst.LH, IInst.LHU: 
            assert(addr >= 0 && addr + 1 < Context.RAM_SIZE);
            res = (ram[addr + 1] << 8) | ram[addr]; 

            if (iinst.kind == IInst.LH)
                res = (res << 16) >> 16;
            break;
        
        case IInst.LW: 
            assert(addr >= 0 && addr + 3 < Context.RAM_SIZE);
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
            assert(addr > 0 && addr < Context.RAM_SIZE);
            ram[addr] = srcval & 0xFF;
            break;

        case 2: 
            assert(addr > 0 && addr + 1 < Context.RAM_SIZE);
            ram[addr] = srcval & 0xFF;
            ram[addr + 1] = (srcval >> 8) & 0xFF;
            break;
        
        case 4:
            assert(addr > 0 && addr + 4 < Context.RAM_SIZE);
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
int interpBr(Context ctx, Inst inst)
{
    auto binst = cast(BInst)inst;

    assert(binst !is null);
    assert(binst.opcode == Inst.B_TYPE);

    const opnd1 = ctx.regs[binst.rs1];
    const opnd2 = ctx.regs[binst.rs2];
    const imm = binst.imm;

    switch (binst.kind)
    {
        case BInst.BEQ: return (opnd1 == opnd2) ? imm : Context.INSTR_LEN;
        case BInst.BNE: return (opnd1 != opnd2) ? imm : Context.INSTR_LEN;
        case BInst.BLT: return (opnd1 < opnd2) ? imm : Context.INSTR_LEN;
        case BInst.BGE: return (opnd1 > opnd2) ? imm : Context.INSTR_LEN;
        case BInst.BLTU: return (cast(uint)opnd1 < cast(uint)opnd2) ? imm : Context.INSTR_LEN;
        case BInst.BGEU: return (cast(uint)opnd1 > cast(uint)opnd2) ? imm : Context.INSTR_LEN;
        default:
            assert(false, "Unknown branch");
    }
}

/// Interprets JAL.
int interpJAL(Context ctx, Inst inst)
{
    auto jinst = cast(JInst)inst;

    assert(jinst !is null);
    assert(jinst.opcode == Inst.J_TYPE_JAL);

    ctx.regs[jinst.rd] = ctx.regs.pc + 4;
    return jinst.offset;
}

/// Interprets JALR.
int interpJALR(Context ctx, Inst inst)
{
    auto iinst = cast(IInst)inst;

    assert(iinst !is null);
    assert(iinst.opcode == Inst.I_TYPE_JALR);

    ctx.regs[iinst.rd] = ctx.regs.pc + 4;
    // Absolute address.
    ctx.regs.pc = ctx.regs[iinst.rs1] + iinst.imm;
    return 0;
}

unittest 
{
    writeln("///    interp.d unittest begins");

    uint[] code = [
        0x400093,   // ADDI x1, x0, 0x4
        0x102123,   // SW x0, x1, 0x2
        0x210083,   // LB x1, x2, 0x2
        0x20B7,     // LUI x1, 2^12
        0x02208063, // BEQ x1, x2, 0x20
        0x020000EF, // JAL x1, 0x20
    ];

    auto ctx = new Context(
        cast(char[])code, 
        code.length * Context.INSTR_LEN
    );
    interp(ctx);

    writeln("///    interp.d unittest ends");
}