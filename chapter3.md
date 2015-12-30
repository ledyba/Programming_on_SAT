# 論理式を扱うHaskellライブラリを使う

　DIMACS形式への変換は極めて面倒です。一般の論理式をCNFまで変形しなければなりませんし、SATソルバーに入力するために論理変数全てに数字を付与して、SATソルバーから答えが返ってきたら番号から元の論理変数を復元しなければなりません。

　そこで、わたしはライブラリを書きました。Haskell製です。

 - Sally - a SAT instance generatior library for haskell
   - https://github.com/ledyba/Sally

　
　
