package hxcons;

import sys.FileSystem;
import hxcons.Build;

class Run
{
    static function main()
    {
        var args = Sys.args();

        if (args.length == 0)
        {
            printUsage();
            Sys.exit(1);
        }

        var command = args[0];
        var rest = args.slice(1);

        switch (command)
        {
            case "build":
                var hconstructPath = rest.length > 0 ? rest[0] : findDefaultHConstruct();
                if (hconstructPath == null)
                {
                    Sys.println("Error: No .HConstruct file specified and none found in current directory.");
                    Sys.println("Usage: haxelib run hxcons build [path-to-.HConstruct]");
                    Sys.exit(1);
                }
                Build.run(hconstructPath);

            case "version":
                Sys.println("hxcons 0.1.0");

            default:
                Sys.println('Unknown command: $command');
                printUsage();
                Sys.exit(1);
        }
    }

    static function findDefaultHConstruct():Null<String>
    {
        for (entry in FileSystem.readDirectory("."))
        {
            if (StringTools.endsWith(entry, ".HxConstruct"))
                return entry;
        }
        return null;
    }

    static function printUsage()
    {
        Sys.println("hxcons - a Lime-style build tool for .HConstruct projects");
        Sys.println("");
        Sys.println("Usage:");
        Sys.println("  haxelib run hxcons build [path-to-.HConstruct]");
        Sys.println("  haxelib run hxcons version");
    }
}