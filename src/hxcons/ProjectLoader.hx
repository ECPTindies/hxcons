package hxcons;

using StringTools;

class ProjectLoader {
    public static function load(hconstructPath:String): Dynamic
    {
        var content = sys.io.File.getContent(hconstructPath);

        var classNameRe = ~/class\s+(\w+)\s+extends\s+HConstruct/;
        if (!classNameRe.match(content))
            throw 'HConstruct class not found in $hconstructPath';
        var className = classNameRe.matched(1);

        var packageRe = ~/^\s*package\s+([\w.]+)\s*;/m;
        var pkg = packageRe.match(content) ? packageRe.matched(1) : null;

        var stageDir = "out/.stage-project";
        var subDir = pkg != null ? pkg.split(".").join("/") : "";
        var targetDir = subDir == "" ? stageDir : stageDir + "/" + subDir;
        sys.FileSystem.createDirectory(targetDir);

        // .HConstruct -> .hx (中身はそのまま)
        sys.io.File.saveContent(targetDir + "/" + className + ".hx", content);

        var hconstructSrc = sys.io.File.getContent("src/hxcons/HConstruct.hx");
        // ベースクラスも同じclasspathに配置
        sys.io.File.saveContent(stageDir + "/HConstruct.hx", stripPackageDecl(hconstructSrc));

        // Runnerをクラス名で置換して生成
        var runnerSrc = sys.io.File.getContent("src/hxcons/Runner.hx.template").replace("{CLASS_NAME}", className);
        runnerSrc = stripPackageDecl(runnerSrc);
        sys.io.File.saveContent(stageDir + "/Runner.hx", runnerSrc);

        // --interpで評価し、標準出力のJSONを受け取る
        var p = new sys.io.Process("haxe", ["-cp", stageDir, "-main", "Runner", "--interp"]);
        var out = p.stdout.readAll().toString();
        var err = p.stderr.readAll().toString();
        var code = p.exitCode();
        p.close();

        if (code != 0) throw 'Failed to evaluate $hconstructPath:\n$err';

        return haxe.Json.parse(out);
    }

    static function stripPackageDecl(src:String):String
    {
        var re = ~/^\s*package\s+[\w.]*\s*;/m;
        return re.replace(src, "package;");
    }
}