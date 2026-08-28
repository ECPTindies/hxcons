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
    static function main()
    {
        var args = Sys.args();
        var hconstructPath = args.length > 0 ? args[0] : "MyProject.HConstruct";

        var config:BuildConfig = cast ProjectLoader.load(hconstructPath);

        log('=== Project: ${config.app.title} v${config.app.version} ===');

        if (config.sourceDirs == null || config.sourceDirs.length == 0)
            throw "sourceDirs is empty. At least one addSourceDir(...) is required.";

        log('=== Build: .hx -> .exe (hxcpp auto build) ===');
        stageBuild(config);
        renameOutput(config);
        copyAssets(config);

        log('Done. Listing output directory: ${config.outDir}');
        listOutput(config.outDir);
    }
    
    static function stageBuild(config:BuildConfig)
    {
        var hxArgs:Array<String> = [];

        for (dir in config.sourceDirs)
        {
            hxArgs.push("-cp");
            hxArgs.push(dir);
        }

        for (asset in config.assets)
        {
            if (!asset.embed) continue;

            if (FileSystem.isDirectory(asset.path))
            {
                var files = collectFiles(asset.path, asset.include);
                for (src in files) {
                    var resName = resolveAssetName(asset, src);
                    hxArgs.push("-resource");
                    hxArgs.push('$src@$resName');
                }
            } else {
                var resName = resolveAssetName(asset, asset.path);
                hxArgs.push("-resource");
                hxArgs.push('${asset.path}@$resName');
            }
        }

        hxArgs.push("-main"); hxArgs.push(config.mainClass);
        hxArgs.push("-cpp"); hxArgs.push(config.outDir);

        for (d in config.defines) { hxArgs.push("-D"); hxArgs.push(d); }
        if (config.debug) hxArgs.push("-debug");

        runCmd("haxe", hxArgs);
    }

    static function matchesInclude(fileName:String, include:Array<String>):Bool
    {
        for (pattern in include)
        {
            if (pattern == "*") return true;
            if (fileName.endsWith(pattern)) return true;
        }
        return false;
    }

    static function collectFiles(dir:String, include:Array<String>):Array<String>
    {
        var result = [];
        if (!FileSystem.exists(dir)) return result;

        for (entry in FileSystem.readDirectory(dir))
        {
            var full = dir + "/" + entry;
            if (FileSystem.isDirectory(full))
            {
                result = result.concat(collectFiles(full, include));
            } else {
                if (matchesInclude(entry, include))
                {
                    result.push(full);
                }
            }
        }
        return result;
    }

    static function renameOutput(config:BuildConfig)
    {
        // mainClassの最後のドット以降(パッケージを除いたクラス名)を取得
        var parts = config.mainClass.split(".");
        var baseName = parts[parts.length - 1];

        var isWindows = Sys.systemName() == "Windows";
        var ext = isWindows ? ".exe" : "";
        var debugSuffix = config.debug ? "-debug" : "";

        var generatedName = baseName + debugSuffix;
        var generatedPath = config.outDir + "/" + generatedName + ext;
        var targetPath = config.outDir + "/" + config.exeName + ext;

        if (!FileSystem.exists(generatedPath))
        {
            log('Warning: expected generated executable not found at $generatedPath');
            return;
        }

        if (FileSystem.exists(targetPath))
        {
            FileSystem.deleteFile(targetPath);
        }

        FileSystem.rename(generatedPath, targetPath);
        log('Renamed $generatedPath -> $targetPath');
    }

    static function listOutput(outDir:String)
    {
        if (!FileSystem.exists(outDir))
        {
            log("Output directory does not exist.");
            return;
        }
        for (f in FileSystem.readDirectory(outDir))
        {
            log(" - " + f);
        }
    }

    static function resolveCompiler(pref:String):String
    {
        if (pref != "auto") return pref;
        return switch (Sys.systemName())
        {
            case "Windows": "cl";
            case "Mac": "clang++";
            default: "g++";
        }
    }

    static function resolveAssetName(asset:AssetEntry, filePath:String):String
    {
        if (FileSystem.isDirectory(asset.path)) {
            var relPath = filePath.substr(asset.path.length + 1);
            return asset.rename != "" ? asset.rename + "/" + relPath : relPath;
        } else {
            return asset.rename != "" ? asset.rename : haxe.io.Path.withoutDirectory(asset.path);
        }
    }

    static function copyAssets(config:BuildConfig)
    {
        for (asset in config.assets)
        {
            if (asset.embed) continue;

            if (FileSystem.isDirectory(asset.path)) {
                var files = collectFiles(asset.path, asset.include);
                for (src in files) {
                    var relName = resolveAssetName(asset, src);
                    var dest = config.outDir + "/assets/" + relName;
                    ensureDir(haxe.io.Path.directory(dest));
                    sys.io.File.copy(src, dest);
                    log('Copied asset: $src -> $dest');
                }
            } else {
                var relName = resolveAssetName(asset, asset.path);
                var dest = config.outDir + "/assets/" + relName;
                ensureDir(haxe.io.Path.directory(dest));
                sys.io.File.copy(asset.path, dest);
                log('Copied asset: ${asset.path} -> $dest');
            }
        }
    }

    static function ensureDir(dir:String)
    {
        if (dir == "" || FileSystem.exists(dir)) return;
        ensureDir(haxe.io.Path.directory(dir));
        FileSystem.createDirectory(dir);
    }

    static function runCmd(cmd:String, args:Array<String>):String
    {
        log('$cmd ${args.join(" ")}');
        var p = new Process(cmd, args);
        var out = p.stdout.readAll().toString();
        var err = p.stderr.readAll().toString();
        var code = p.exitCode();
        p.close();

        if (out.length > 0) Sys.println(out);
        if (code != 0)
        {
            Sys.println('--- STDERR ---');
            Sys.println(err);
            Sys.println('$cmd failed with exit code $code');
            Sys.exit(code);
        }
        return out;
    }

    static function log(msg:String)
    {
        Sys.println("[Build] " + msg);
    }
}