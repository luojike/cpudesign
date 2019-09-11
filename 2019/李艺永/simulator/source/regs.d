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
    uint[32] vecs;

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

    /// Write [val] to register x[n].
    void write(size_t n, uint val)
    {
        assert(n > 0 && n < 31);

        vecs[n] = val;
    }

    /// Read register x[n].
    uint read(size_t n)
    {
        assert(n >= 0 && n < 31);
        return vecs[n];
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
    assert(regs.read(0) == 0);
}