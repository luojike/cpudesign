import std.stdio;
import std.file;
import core.stdc.stdlib;
import interp;

void main(string[] args)
{
    if (args.length != 2)
    {
        stderr.writefln("Usage: %s filename", args[0]);
        exit(-1);
    }

    if (!args[1].exists)
    {
        stderr.writefln("%s doesn't exist!", args[1]);
        exit(-2);
    }

    if (!args[1].isFile)
    {
        stderr.writefln("%s is not a file!", args[1]);
        exit(-2);
    }

    auto code = cast(char[])read(args[1]);
    auto ctx = new Context(code, code.length);
    interp.interp(ctx);
}