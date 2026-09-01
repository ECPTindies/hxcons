# HxCons
![Haxe](https://img.shields.io/badge/Haxe-EA8220?style=for-the-badge&logo=haxe&logoColor=white)
___
A build tool that compiles project using hxcpp.

## [WORNING]
This tool does not include APIs for displaying windows and etc. functions.<br>
You will need to implement those yourself!

## Installing
```
haxelib install hxcons ?<version>
```

## Usage
#### 1. Make your project directory.
For example, we'll name the folder `MyProject`.
```
📁MyProject/
├── 📁assets/
│   ├── 📁images/
│   │   └── icon.png
├── 📁resource/
│   └── my-data.json
└── 📁src/
    └── Main.hx
```

#### 2. Create a `.HxConstruct` file in root directory.
A `.HxConstruct` file is a project configuration file written in Haxe syntax.

```haxe
// You can name the class whatever you like.
class MyProject extends HxConstruct
{
    public function new()
    {
        super();

        setApplyTitle("MyApp");
        setApplyVersion("0.1.0");
        setSrcMainClass("samples.src.Main");
        addSourceDir("src");
        addSourceDir("shared");

        addAsset({ path: "assets", rename: null, include: ["*"], embed: true });
        addAsset({ path: "assets" }); // rename: null, include: ["*"], embed: false

        setDebug(true);
        addDefine("MY_FEATURE");

        addLibrary("format");
        addLibrary("json5hx", "1.0.2");
    }
}
```

#### 3. Install dependencies and compile the project.
With a few exceptions, you should continue to use the `haxelib install ...` command to install dependencies.
Also, please install `hxcpp`.
```
haxelib install format
haxelib install json5hx 1.0.2
haxelib install hxcpp --quiet
```

Now all you have to do is compile it! To compile the project, just type `.HxConstruct` in root directory.
```
haxelib run hxcons .HxConstruct
```

That's it—the project build is now complete!