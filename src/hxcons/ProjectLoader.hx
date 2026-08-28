package hxcons;

using StringTools;

class ProjectLoader {
    public static function load(hxconstructPath:String):Dynamic
    {
        var content = sys.io.File.getContent(hxconstructPath);

        var classNameRe = ~/class\s+(\w+)\s+extends\s+HxConstruct/;
        if (!classNameRe.match(content))
            throw 'HxConstruct class not found in $hxconstructPath';
        var className = classNameRe.matched(1);

        var packageRe = ~/^\s*package\s+([\w.]+)\s*;/m;
        var pkg = packageRe.match(content) ? packageRe.matched(1) : null;

        var stageDir = "out/.stage-project";
        var subDir = pkg != null ? pkg.split(".").join("/") : "";
        var targetDir = subDir == "" ? stageDir : stageDir + "/" + subDir;
        sys.FileSystem.createDirectory(targetDir);

        content = stripPackageDecl(content);

        // .HxConstruct -> .hx (中身はそのまま)
        sys.io.File.saveContent(targetDir + "/" + className + ".hx", content);

        // ベースクラスも同じclasspathに配置(packageを剥がしてルート直下用に変換)
        var hxconstructSrc = sys.io.File.getContent("src/hxcons/HxConstruct.hx");
        sys.io.File.saveContent(stageDir + "/HxConstruct.hx", stripPackageDecl(hxconstructSrc));

        // Runnerをクラス名で置換して生成
        var runnerSrc = sys.io.File.getContent("src/hxcons/Runner.hx.template")
            .replace("{CLASS_NAME}", className);
        runnerSrc = stripPackageDecl(runnerSrc);
        sys.io.File.saveContent(stageDir + "/Runner.hx", runnerSrc);

        // --interpで評価し、標準出力のJSONを受け取る
        var p = new sys.io.Process("haxe", ["-cp", stageDir, "-main", "Runner", "--interp"]);
        var out = p.stdout.readAll().toString();
        var err = p.stderr.readAll().toString();
        var code = p.exitCode();
        p.close();

        if (code != 0) throw 'Failed to evaluate $hxconstructPath:\n$err';

        var data:Dynamic;
        try {
            data = haxe.Json.parse(out);
        } catch (e:Dynamic) {
            throw 'Failed to parse JSON output from $hxconstructPath.\nRaw output was:\n---\n$out\n---\nError: $e';
        }

        resolveRelativePaths(data, hxconstructPath);

        return data;
    }

    static function stripPackageDecl(src:String):String
    {
        var re = ~/^\s*package\s+[\w.]*\s*;/m;
        return re.replace(src, "package;");
    }

    /**
     * sourceDirsとassets[].pathを、.HxConstructファイルの場所を基準にした相対パスに解決する。
     * outDirはリポジトリルート(実行時カレントディレクトリ)基準のまま変更しない。
     */
    static function resolveRelativePaths(data:Dynamic, hxconstructPath:String):Void
    {
        var baseDir = haxe.io.Path.directory(hxconstructPath);

        // .HxConstructがルート直下にある場合、directory()は "" を返す -> 解決不要
        if (baseDir == "") return;

        function resolve(p:String):String
        {
            if (p == null || p == "") return p;
            if (haxe.io.Path.isAbsolute(p)) return p;
            return baseDir + "/" + p;
        }

        function resolveArray(arr:Array<String>):Void
        {
            if (arr == null) return;
            for (i in 0...arr.length) {
                arr[i] = resolve(arr[i]);
            }
        }

        resolveArray(cast data.sourceDirs);
        resolveArray(cast data.extraIncludes);
        resolveArray(cast data.extraLibPaths);
        // extraLibsはライブラリ"名"(例: "SDL2")であってパスではないため対象外

        var assets:Array<Dynamic> = data.assets;
        if (assets != null)
        {
            for (asset in assets)
            {
                asset.path = resolve(asset.path);
            }
        }
    }
}