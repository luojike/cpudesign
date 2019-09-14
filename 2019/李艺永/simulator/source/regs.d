///     Module regs.d
///     This module contains register file of RV32I core.
///     Copyright 2019 Yiyong Li.

module regs;

import consts;

/// Class represents register file of a RV32I core,
/// including 31 general-purpose registers and a PC register.
class Regs
{
    /// 31 general-purpose registers.
    int[32] vecs;

    /// width of each register.
    size_t XLEN = 32;

    /// PC register.
    uint pc;

    /// Constructor.
    this() {
        // All value types all initial values in D. Don't worry 'bout it.
    }

    /// Reset all registers to 0.
    void resetRegs()
    {
        vecs[] = 0;
    }

    /// Reset PC register to 0.
    void resetPC()
    {
        pc = 0;
    }

    /// E.g. auto regval = regs[0];
    int opIndex(size_t idx)
    {
        assert(
            idx >= 0 && idx < 31,
            "Invalid reg index!"
        );

        return vecs[idx];
    }

    /// E.g. regs[1] = 0x10;
    int opIndexAssign(int val, size_t idx)
    {
        assert(
            idx > 0 && idx <= 31,
            "Invalid reg assignment!"
        );

        return (vecs[idx] = val);
    }

    /// Increment PC register.
    void incrPC()
    {
        pc += INSTR_LEN;
    }
}

unittest
{
    auto regs = new Regs;

    assert(regs.pc == 0);
    assert(regs[0] == 0);
    
    regs[1] = 0x20;
    assert(regs[1] = 0x20);
}