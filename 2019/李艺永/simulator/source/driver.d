import std.stdio;
import inst;

void main()
{
    /// LUI x1, 2^12
    uint ir = 0x20B7;
    Inst inst = decode(ir);
    auto uinst = cast(UInst)inst;
    assert(uinst !is null);
    assert(uinst.opcode == Inst.U_TYPE_LUI);
    assert(uinst.imm == (2 << 12));
    assert(uinst.rd == 1);
    assert(cast(IInst)inst is null);

    writeln("OK");
}