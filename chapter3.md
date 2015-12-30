# 論理式を扱うHaskellライブラリを使う

　一般の論理式をDIMACS形式まで変換するのは極めて面倒です。まずCNFへ変形し、さらに論理変数全てに数字を付与してDIMACS形式にしなければなりません。SATソルバーから答えが返ってきたら、番号から元の論理変数を復元する必要もあります。極めて面倒です…（二度目）。

　そこで、わたしはライブラリを書きました。Haskell製です。

 - [Sally](https://github.com/ledyba/Sally) - a SAT instance generatior library for haskell
   - https://github.com/ledyba/Sally

　えっ、いままで初心者向けって感じだったのにいきなりHaskellかよ、って感じですが、一番わかりやすく書けるのがHaskellだという結論に至ったので、あなたがHaskellを書けなくても読んでみてください。

## Haskellをインストール

　まず[Haskell Platformの最新版](https://www.haskell.org/platform/)([https://www.haskell.org/platform/](https://www.haskell.org/platform/))をインストールしておいてください。インストーラーに沿うだけなのでとくに解説しません。

## ライブラリのインストール

　次に、わたしの書いたSAT問題生成用ライブラリである「[Sally](https://github.com/ledyba/Sally)」をインストールをします。

```bash
$ git clone git@github.com:ledyba/Sally.git
$ cd Sally
$ cabal install
```

## ライブラリの使い方

　cabal replとタイプするとreplモードで使えるので、前章の論理パズルをこのライブラリで解いてみましょう。まず、論理式を（Haskellで）入力して、CNFへ変換します。

```Haskell
% cabal repl
...(中略)...
         -- 論理式を入力：
         -- ((b && !a) || (!b && a)) &&
         -- ((c && !b) || (!c && b))
*Sally> let fml =
    And [
        Or [
            And [var "b", Not (var "a")],
            And [Not (var "b"), var "a"]],
        Or [
            And [var "c", Not (var "b")],
            And [Not (var "c"), var "b"]]]
        -- CNFへ変換します：
*Sally> let cnf = toCNF (removeNot fml)
        -- CNFへの変換結果：
*Sally> cnf
[
    [CAff (TmpVar [1,0,1]),CAff (Var "b")],
    [CAff (TmpVar [1,0,1]),CNot (Var "a")],
    [CNot (TmpVar [1,0,1]),CNot (Var "b")],
    [CNot (TmpVar [1,0,1]),CAff (Var "a")],
    [CAff (TmpVar [1,1,1]),CAff (Var "c")],
    [CAff (TmpVar [1,1,1]),CNot (Var "b")],
    [CNot (TmpVar [1,1,1]),CNot (Var "c")],
    [CNot (TmpVar [1,1,1]),CAff (Var "b")]
]
```

　TmpVarというのがCNFへ変換したときの追加の論理変数で、よく見比べると前章と同じ結果になっています（CAffとなっている方は論理変数そのままを表していて、CNotと付いているほうは論理変数の否定を表しています）。

　ここから更に、論理変数に1,2,3...と番号を振った上でファイルへ保存します：

```Haskell
        -- 番号を振る
*Sally> let (vars,dict) = makeAlias cnf
        -- DIMACS形式でファイルに保存
*Sally> toDIMACS vars dict "p.sat"
```

　保存したら、コンソールをもう一つ開いてminisatに問題を解かせます：

```bash
$ minisat p.sat p.ans
...
SATISFIABLE
```

　問題が解けたので、もう一度Sallyのコンソールへ戻り、この結果を確認します：

```Haskell
*Sally> result <- fromDIMACS dict "p.ans"
*Sally> result
fromList [("a",True),("b",False),("c",True)]
*Sally>
```

　というわけで、嘘つきはBとなり、前章で手動でやった結果と同じものが得られます。

　なお、論理式を作る時にvar "a"などとしていますが、この"a"の部分は他の任意のデータ構造に置き換えることができます。

```hs
        -- StringじゃなくてもIntでもいい
*Sally> var 1
FVar (Var 1)
        -- [Int]でもいい
*Sally> var [1,2,3]
FVar (Var [1,2,3])
        -- Maybe Intでもいい
*Sally> var (Just 1)
FVar (Var (Just 1))
```

　この機能は結構強力で、後でBrainfuckコンパイラを作るときに役立ちます。

## 次は？

　足し算と引き算を実装しましょう。