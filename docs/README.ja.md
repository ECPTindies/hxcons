- **[英語 / English](./README.md)**
___
___
<img src="./docs/img/HxCons.svg" alt="[ICON] HxCons" width="300" height="300"/>

# HxCons
![Haxe](https://img.shields.io/badge/Haxe-EA8220?style=for-the-badge&logo=haxe&logoColor=white)
___
Haxeで作成したプロジェクトをhxcppライブラリを使用してビルドする簡易的なツール。

## [警告]
このツールには、ウィンドウの表示やその他の機能のためのAPIは含まれていません。<br>
それらは、ご自身で実装してもらう必要があります！

## インストール
インストール方法は、現在一つしかありません。
<!-- ```
haxelib install hxcons ?<version>
``` -->
```
haxelib git hxcons https://github.com/ECPTindies/hxcons.git
```

gitからインストールした場合、hxconsのルートフォルダからコンソールを開き、次のコマンドでhxconsをビルドしてください。
```
haxe run.hxml
```

## 基本的な使い方
#### 1. プロジェクトの作成
例として、ここでは`MyProject`と名付けましょう。
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

#### 2. `.HxConstruct`ファイルをルートディレクトリに作成
`.HxConstruct`は、Haxeの構文を使用したプロジェクト構成ファイルです。

```haxe
// You can name the class whatever you like.
class MyProject extends HxConstruct
{
    public function new()
    {
        super();

        setApplyTitle("MyApp");
        setApplyVersion("1.0.0");
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

#### 3. 依存関係のあるライブラリのインストールと、プロジェクトのビルド
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