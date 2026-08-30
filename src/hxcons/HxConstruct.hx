package hxcons;

typedef AddAssetsParam = {
    path:String,
    ?rename:String,
    ?include:Array<String>,
    ?embed:Bool
}

typedef LibraryEntry = {
    name:String,
    ?version:String,
}

typedef DefineParam = {
    id:String,
    ?value:Dynamic,
}

typedef DefineEntry = {
    id:String,
    value:Dynamic,
}

class HxConstruct
{
    public var applyVersion:String = "";
    public var applyTitle:String = "";
    public var applyMeta:Map<String, Dynamic> = [];

    public var srcMainClass:String;
    public var sourceDirs:Array<String> = [];
    public var exportDir:String = "out";
    public var debug:Bool = false;
    public var compiler:String = "auto";

    public var libraries:Array<LibraryEntry> = [];

    public var extraIncludes:Array<String> = [];
    public var extraLibPaths:Array<String> = [];
    public var extraLibs:Array<String> = [];

    public var assets:Array<AddAssetsParam> = [];

    public var defines:Array<DefineEntry> = [];

    public var showConsole:Bool = true;

    public function new() {}

    public function toObject():Dynamic
    {
        return
        {
            app: { title: applyTitle, version: applyVersion, meta: applyMeta },
            mainClass: srcMainClass,
            sourceDirs: sourceDirs,
            outDir: exportDir,
            exeName: applyTitle,
            libraries: libraries,
            extraIncludes: extraIncludes,
            extraLibPaths: extraLibPaths,
            extraLibs: extraLibs,
            compiler: compiler,
            debug: debug,
            defines: defines,
            assets: assets,
            showConsole: showConsole,
        };
    }

    // ======================================== Setters ========================================

    public function setApplyVersion(value:String):Void applyVersion = value;
    public function setApplyTitle(value:String):Void applyTitle = value;
    public function setSrcMainClass(value:String):Void srcMainClass = value;
    public function addSourceDir(value:String):Void sourceDirs.push(value);
    public function setExportDir(value:String):Void exportDir = value;
    public function setDebug(value:Bool):Void debug = value;
    public function setCompiler(value:String):Void compiler = value;
    public function addInclude(value:String):Void extraIncludes.push(value);
    public function addLibPath(value:String):Void extraLibPaths.push(value);
    public function addLib(value:String):Void extraLibs.push(value);

    public function addAsset(asset:AddAssetsParam):Void
    {
        assets.push({
            path: asset.path,
            rename: asset.rename != null ? asset.rename : "",
            include: (asset.include != null && asset.include.length > 0) ? asset.include : ["*"],
            embed: asset.embed != null ? asset.embed : false,
        });
    }

    public function addAssetDirs(list:Array<AddAssetsParam>):Void
    {
        for (asset in list) addAsset(asset);
    }

    public function addLibrary(name:String, ?version:String):Void
    {
        libraries.push({ name: name, version: version });
    }

    public function addDefine(id:String):Void
    {
        defines.push({ id: id, value: null });
    }

    public function setDefine(param:DefineParam):Void
    {
        defines.push({ id: param.id, value: param.value != null ? param.value : null });
    }

    public function setConsole(value:Bool):Void
    {
        showConsole = value;
    }
}