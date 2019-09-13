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

auto decode(uint ir)
{

    /// Extract funct fields.
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

    /// Immediate extractor.
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
}
