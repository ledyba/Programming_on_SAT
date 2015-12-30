# 論理式を扱うHaskellライブラリを使う

　一般の論理式をDIMACS形式まで変換するのは極めて面倒です。まずCNFへ変形し、さらに論理変数全てに数字を付与してDIMACS形式にしなければなりません。SATソルバーから答えが返ってきたら、番号から元の論理変数を復元する必要もあります。極めて面倒です…。

　そこで、わたしはライブラリを書きました。Haskell製です。

 - [Sally](https://github.com/ledyba/Sally) - a SAT instance generatior library for haskell
   - https://github.com/ledyba/Sally

　えっ、いままで初心者向けって感じだったのにいきなりHaskellかよ、って感じですが、一番わかりやすく書けるのがHaskellだという結論に至ったので、あなたがHaskellを書けなくても読んでみてください。

## ライブラリのインストール

　まずはライブラリのインストールをします。まず[Haskell Platformの最新版](https://www.haskell.org/platform/)をインストールしておいてください。
