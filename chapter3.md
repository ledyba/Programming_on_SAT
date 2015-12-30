# 論理式を扱うHaskellライブラリを使う

　一般の論理式をDIMACS形式まで変換するのは極めて面倒です。まずCNFへ変形し、さらに論理変数全てに数字を付与してDIMACS形式にしなければなりません。SATソルバーから答えが返ってきたら、番号から元の論理変数を復元する必要もあります。極めて面倒です…。

　そこで、わたしはライブラリを書きました。Haskell製です。

 - [Sally](https://github.com/ledyba/Sally) - a SAT instance generatior library for haskell
   - https://github.com/ledyba/Sally

　
　
