package hxcons;

import sys.io.Process;
import sys.FileSystem;

using StringTools;

typedef AppData = {
    title:String,
    version:String,
    meta:Dynamic,
}

typedef AssetEntry = {
    path:String,
    rename:String,
    include:Array<String>,
    embed:Bool,
}

typedef BuildConfig = {
    var app:AppData;
    var mainClass:String;
    var sourceDirs:Array<String>;
    var outDir:String;
    var exeName:String;
    var extraIncludes:Array<String>;
    var extraLibPaths:Array<String>;
    var extraLibs:Array<String>;
    var compiler:String;
    var debug:Bool;
    var defines:Array<String>;
    var assets:Array<AssetEntry>;
}

class Build {
    static function main() {
        var args = Sys.args();
        var hconstructPath = args.length > 0 ? args[0] : ".HConstruct";

        var config:BuildConfig = cast ProjectLoader.load(hconstructPath);

        log('=== Project: ${config.app.title} v${config.app.version} ===');

        if (config.sourceDirs == null || config.sourceDirs.length == 0)
            throw "sourceDirs is empty. At least one addSourceDir(...) is required.";

        log('=== Stage 1: .hx -> .cpp ===');
        stageHxToCpp(config);

        log('=== Stage 2: .cpp -> .exe ===');
        stageCppToExe(config);

        log('Done. Output: ${config.outDir}/${config.exeName}');
    }

    static function stageHxToCpp(config:BuildConfig) {
        var cppDir = config.outDir + "/cpp";
        var hxArgs:Array<String> = [];

        for (dir in config.sourceDirs) {
            hxArgs.push("-cp");
            hxArgs.push(dir);
        }

        hxArgs.push("-main"); hxArgs.push(config.mainClass);
        hxArgs.push("-cpp"); hxArgs.push(cppDir);
        hxArgs.push("-D"); hxArgs.push("no-compilation");

        for (d in config.defines) { hxArgs.push("-D"); hxArgs.push(d); }
        if (config.debug) hxArgs.push("-debug");

        runCmd("haxe", hxArgs);
    }

    static function stageCppToExe(config:BuildConfig)
    {
        var cppDir = config.outDir + "/cpp";
        var srcDir = cppDir + "/src";

        var hxcppPath = StringTools.trim(runCmd("haxelib", ["path", "hxcpp"]).split("\n")[0]);

        var sources = [for (f in FileSystem.readDirectory(srcDir))
            if (StringTools.endsWith(f, ".cpp")) srcDir + "/" + f];

        var compiler = resolveCompiler(config.compiler);
        var isMsvc = compiler == "cl";

        var exePath = config.outDir + "/" + config.exeName +
            (Sys.systemName() == "Windows" ? ".exe" : "");

        var args:Array<String> = [];

        if (isMsvc) {
            args = args.concat(["/DHXCPP_API_LEVEL=430"]);
            args = args.concat(["/EHsc", "/I" + cppDir + "/include", "/I" + hxcppPath + "/include"]);
            args = args.concat(config.extraIncludes.map(i -> "/I" + i));
            args = args.concat(sources);
            args = args.concat(["/Fe:" + exePath, "/link"]);
            args = args.concat(["/LIBPATH:" + hxcppPath + "/lib"]);
            args = args.concat(config.extraLibPaths.map(p -> "/LIBPATH:" + p));
            args.push("hxcpp.lib");
            args = args.concat(config.extraLibs.map(l -> l.endsWith(".lib") ? l : l + ".lib"));
        } else {
            args = args.concat(["-DHXCPP_API_LEVEL=430"]);
            args = args.concat(["-std=c++11", "-I" + cppDir + "/include", "-I" + hxcppPath + "/include"]);
            args = args.concat(config.extraIncludes.map(i -> "-I" + i));
            args = args.concat(sources);
            args = args.concat(["-L" + hxcppPath + "/lib"]);
            args = args.concat(config.extraLibPaths.map(p -> "-L" + p));
            args.push("-lhxcpp");
            args = args.concat(config.extraLibs.map(l -> "-l" + l));
            args = args.concat(["-o", exePath]);
        }

        Sys.putEnv("HXCPP_COMPILE_THREADS", "1");

        runCmd(compiler, args);
    }

    static function resolveCompiler(pref:String):String {
        if (pref != "auto") return pref;
        return switch (Sys.systemName()) {
            case "Windows": "cl";
            case "Mac": "clang++";
            default: "g++";
        }
    }

    static function runCmd(cmd:String, args:Array<String>):String {
        log('$cmd ${args.join(" ")}');
        var p = new Process(cmd, args);
        var out = p.stdout.readAll().toString();
        var err = p.stderr.readAll().toString();
        var code = p.exitCode();
        p.close();

        if (out.length > 0) Sys.println(out);
        if (code != 0) {
            Sys.println('--- STDERR ---');
            Sys.println(err);
            Sys.println('$cmd failed with exit code $code');
            Sys.exit(code);
        }
        return out;
    }

    static function log(msg:String) {
        Sys.println("[Build] " + msg);
    }
}