///     This file simply creates a little bin file for testing
///     the rv32i driver.
import std.file;

void main(string[] args)
{
    string binName = args[1];

    if (binName.exists)
    {
        remove(binName);
    }

    uint[] code = [
        0x400093,   // ADDI x1, x0, 0x4
        0x102123,   // SW x0, x1, 0x2
        0x210083,   // LB x1, x2, 0x2
        0x20B7,     // LUI x1, 2^12
        0x02208063, // BEQ x1, x2, 0x20
        0x020000EF, // JAL x1, 0x20
    ];

    write(binName, code);
}