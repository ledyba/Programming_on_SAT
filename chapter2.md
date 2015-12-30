# 簡単な論理パズルを解く

この章では、実際にSATソルバーを使って簡単な問題を解いてみましょう。

## あなたとSATソルバー、いますぐダウンロード

　なにはともあれ、SATソルバーを入手しないといけませんね。今回は[MiniSAT](http://minisat.se/)（[http://minisat.se/](http://minisat.se/)）というソフトウェアを使います。このソフトウェアはこの業界ではかなり有名で、[SAT Competition](http://www.satcompetition.org/)というSATソルバーの世界大会ではこれを改造したものがたくさん出場して

　さて、ubuntu/OSXなら以下の方法でインストールできます。

```bash
$ sudo apt-get install minisat #Ubuntu
$ brew install minisat #OSX
```

　Windowsは持ってないので知りません…。ググればあるんじゃないでしょうか。

## ハローワールド的な

　何はともあれHello worldです。Hello worldそのものは出来ないので、とりあえず、簡単な問題から解いてみましょう。

```c++
 bool p;
 (p || q || r) && !p //pがｔでもfでもこの式はtrueになる
```

これをSATに入力する形式にすると、次のようになります。

```DIMACS:
c src/chapter2/hello.sat
c cで始まる行はコメントです
p cnf 3 2
1 2 3 0
-1 0
```

　最初のcで始まる2行はコメントなので無視して、3行目から行きましょう。

　最初の"p cnf"は、このファイルがCNF式であることを示しています。なお、SAT Competitonのドキュメント [\[1\]][1](を読む限りでは、CNF式以外の物であることは無いみたいです。

　次の3と2はそれぞれ「変数の数」と「節」の数です。変数の数はいいですね。この場合は、p、q、rの三変数なので「3」です。

　節の数はCNFについてまず説明する必要があるでしょう。Chapter1で話した通り、SATは論理式のうち、CNFと呼ばれる形の物しか受け取れません。
　
##CNF式

　CNFは、論理式のうち次のようなものです。

```cpp
(p || q || r || !s) &&
(t || u || !v || w) &&
(a || b || c || !d) &&
...
```
　つまり、論理変数（またはその否定）をorで繋いだものを、さらにandで繋いだものです。orで繋がれた塊のぞれぞれを節（clause）と呼びます。

　さっきのサンプルである

```cpp
(p || q || r) &&
!p
```

　は上と見比べると、節が2つのCNFになっています。

　ここまでわかれば、

```DIMACS
p cnf 3 2
1 2 3 0
-1 0
```

　が読解できます。それぞれの行は節を表していて、1や-1はpや!p、2はq、3はrを表しています。同じ行に数字を並べるとそれぞれorで繋がった「節」の意味になり、節と節はそれぞれandで繋がっている事を表しています。行の最後の0は行区切りです。

　p,q,rから1,2,3への対応は自分で考えて裏でメモっておく必要があります。さらに行区切りに0を使っているので、論理変数は1から始まる必要があります（マイナス・ゼロとゼロは同じなので論理変数を表すには使えないと覚えてもいいでしょう）。

## 付録：CNFへの変形

　論理式にはCNFでない物があります。たとえば、

```cpp
(p && q) || r
```

　はorの中にandが入っているので、CNFではありません。

　でも、これは追加の論理変数sを使うと、次のCNF式に変形できます。

```cpp
(p && q && s) &&
(r && !s)
=
(p && q && s) &&
(r && !s)
```

　これは何でかというと、次の４通りを考えればわかります。

　このもっと一般的な方法は、次のように書けます。

まず、

```Haskell
toCNF A = A
toCNF A = A
toCNF (A `AND` B) = A `AND` B
```

　なお、この変形は素朴に書くと非常に遅いため、今回は直接は書かずわたしの書いたライブラリを利用します。このライブラリは次のChapter3で触れます。

## 引用
\[1\] SAT Competition 2009: Benchmark Submission Guidelines
http://www.satcompetition.org/2009/format-benchmarks2009.html

[1]: http://www.satcompetition.org/2009/format-benchmarks2009.html "SAT Competition 2009: Benchmark Submission Guidelines"
