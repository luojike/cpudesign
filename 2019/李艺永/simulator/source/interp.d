///     Module interp.d
///     Copyright Yiyong Li

module interp;
import regs;

/// Contains status info for simulation.
class Context
{
    /// Registers.
    Regs regs;

    /// 4GB of RAM.
    uint[4096] ram;
}

