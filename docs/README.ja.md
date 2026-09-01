- **[英語 / English](./README.md)**
___
___
![HxCons](/docs/img/HxCons.svg)
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

## サンプル
- [SDLを使用したウィンドウの作成](/samples/window/)
- [GitHub Workflowの例](/.github/workflows/tester.yml)

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
一部を除き、依存関係をインストールする際は引き続き`haxelib install ...`コマンドを使用してください。
同時に、`hxcpp`もインストールが必要です。
```
haxelib install hxcpp --quiet
haxelib install format
haxelib install json5hx 1.0.2
```

あとはコンパイルするだけ！プロジェクトをビルドするには、ルートディレクトリでコンソールを開き、以下を入力してください。
```
haxelib run hxcons .HxConstruct
```

これで、ビルドが通ったはずです！
