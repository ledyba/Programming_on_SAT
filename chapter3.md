# 論理式を扱うHaskellライブラリを使う

　一般の論理式をDIMACS形式まで変換するのは極めて面倒です。まずCNFへ変形しなければなりませんし、さらに論理変数全てに数字を付与してDIMACS形式にし、さらにSATソルバーから答えが返ってきたら番号から元の論理変数を復元しなければなりません。

　そこで、わたしはライブラリを書きました。Haskell製です。

 - Sally - a SAT instance generatior library for haskell
   - https://github.com/ledyba/Sally

　
　
