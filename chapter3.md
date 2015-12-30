# 論理式を扱うHaskellライブラリを使う

　一般の論理式をDIMACS形式まで変換するのは極めて面倒です。まずCNFへ変形し、さらに論理変数全てに数字を付与してDIMACS形式にしなければなりません。SATソルバーから答えが返ってきたら、番号から元の論理変数を復元する必要もあります。極めて面倒です…（二度目）。

　そこで、わたしはライブラリを書きました。Haskell製です。

 - [Sally](https://github.com/ledyba/Sally) - a SAT instance generatior library for haskell
   - https://github.com/ledyba/Sally

　えっ、いままで初心者向けって感じだったのにいきなりHaskellかよ、って感じですが、一番わかりやすく書けるのがHaskellだという結論に至ったので、あなたがHaskellを書けなくても読んでみてください。

## Haskellをインストール

　まず[Haskell Platformの最新版](https://www.haskell.org/platform/)([https://www.haskell.org/platform/](https://www.haskell.org/platform/))をインストールしておいてください。インストーラーに沿うだけなのでとくに解説しません。

## ライブラリのインストール

　次に、わたしの書いたSAT問題生成用ライブラリである「[Sally](https://github.com/ledyba/Sally)」をインストールをしま。

```bash
$ git clone git@github.com:ledyba/Sally.git
$ cd Sally
$ cabal install
```

## ライブラリの使い方

　cabal replとタイプするとreplモードで使えるので、前章の論理パズルをこのライブラリで解いてみましょう。

```Haskell
% cabal repl
...(中略)...
*Sally.SAT> let fml =
    And [
        Or [
            And [var "b", Not (var "a")],
            And [Not (var "b"), var "a"]],
        Or [
            And [var "c", Not (var "b")],
            And [Not (var "c"), var "b"]]]
*Sally> let cnf = toCNF (removeNot fml)
*Sally> cnf
*Sally> let (vars,dict) = makeAlias cnf
*Sally> toDIMACS vars dict "p.sat"
```

```Haskell
*Sally> result <- fromDIMACS dict "p.ans"
*Sally> result
fromList [("a",True),("b",False),("c",True)]
*Sally>
```
