# 簡単な論理パズルを解く

この章では、実際にSATソルバーを使って簡単な問題を解いてみましょう。

## あなたとSATソルバー、いますぐダウンロード

　なにはともあれ、SATソルバーを入手しないといけませんね。今回は[MiniSAT](http://minisat.se/)（[http://minisat.se/](http://minisat.se/)）というソフトウェアを使います。このソフトウェアはこの業界ではかなり有名で、[SAT Competition](http://www.satcompetition.org/)というSATソルバーの世界大会ではこれを改造したものがたくさん出場しています。

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

これをSATに入力する形式にするためのファイルフォーマットである、***DIMACS形式***にすると、次のようになります。

```DIMACS
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
(t || u || !v) &&
(a || b || c || !d) &&
(!a) &&
...
```
　つまり、***リテラル***と呼ばれる"論理変数、または、その否定"をorで繋いだもののグループを、さらにandで繋いだものです。orで繋がれた塊のぞれぞれを節（clause）と呼びます。

　さっきのサンプルである

```cpp
(p || q || r) && !p
```

　は上と見比べると、節が2つのCNFになっています。

　ここまで理解したら、DIMACS形式を完全に理解できます：

```DIMACS
p cnf 3 2
1 2 3 0
-1 0
```

　それぞれの行は節を表していて、1や-1はpや!p、2はq、3はrを表しています。同じ行に数字を並べるとそれぞれorで繋がった「節」の意味になり、節と節はそれぞれandで繋がっている事を表しています。行の最後の0は行区切りです。

　さて、これをSATソルバーに解かせてみましょう。

```bash
$ minisat hello.sat hello.ans
============================[ Problem Statistics ]=============================
|                                                                             |
|  Number of variables:             3                                         |
|  Number of clauses:               1                                         |
|  Parse time:                   0.00 s                                       |
|  Eliminated clauses:           0.00 Mb                                      |
|  Simplification time:          0.00 s                                       |
|                                                                             |
============================[ Search Statistics ]==============================
| Conflicts |          ORIGINAL         |          LEARNT          | Progress |
|           |    Vars  Clauses Literals |    Limit  Clauses Lit/Cl |          |
===============================================================================
===============================================================================
restarts              : 1
conflicts             : 0              (0 /sec)
decisions             : 1              (0.00 % random) (962 /sec)
propagations          : 1              (962 /sec)
conflict literals     : 0              ( nan % deleted)
Memory used           : 0.24 MB
CPU time              : 0.00104 s

SATISFIABLE
```

　というわけで「充足可能」と出ました（最後の行）。その時の論理変数の割当は、hello.ansファイルに吐き出されます。

```bash
$ cat hello.ans
SAT
-1 -2 3 0
```

　この読み方ですが、正になっている番号の論理変数はtrue、負になっているものはfalseにすると全体で真になると読んでください。

　つまり、p(=1)はfalse、q(=2)もfalse、r(=3)はtrueだということです。たしかに`(p || q || r) && !p`に代入してみると、trueになっています（一つ目の節はrがtrueなのでtrue、ふたつ目は!pがtrue）。

　p,q,rから1,2,3への対応は自分で考えて裏でメモっておく必要があります。さらに行区切りに0を使っているので、論理変数は1から始まる必要があります（マイナス・ゼロとゼロは同じなので論理変数を表すには使えない、と覚えてもよいでしょう）。

## CNFへの変形

　論理式にはCNFでない物があります。たとえば、

```cpp
(p && q) || r
```

　は***or***の中に***and***が入っているので、CNFではありません。CNFは***and***の中に***or***が入ってるんでしたね。

　でも、これは追加の論理変数sを使うと、次のCNF式に変形できます。

```cpp
(p || s) && (q || s) &&
(r && !s)
```

　この場合の「変形できる」とは、次の意味で言っています：

 - 元の論理式が充足可能なら、変換した後のCNFも充足可能
   - 追加した分を除いた論理変数のtrue/false割当は元の論理式も充足する
 - 元の論理式が充足不可能なら、変換した後のCNFも充足不可能

　言い換えれば、SATの問題をとく時はまず論理式をCNFに変形してからSATソルバーに投げ、返ってきた割当てのうち追加した論理変数を無視すれば、元の論理式を充足する論理変数の割当てが得られるということです。若干回りくどいのですが、それぞれのソフトウェアの役割分担のためにこうなってます。

　さて、この変形がなぜできるかというと、大雑把にいえば

 - `(p && q) || r`がtrueとなるのは、orの左右のどちらかがtrue（もしくは両方）
 - sは追加の変数なのでtrueでもfalseでも良い（どうせ無視するから）

　だからです。この事を使うと、まず次の「変形」が出来ることがわかります。

　`((p && q) || s) && (r || !s)`

　場合分けをしてゆっくり考えればわかります：

 - 元式の`(p && q)`がtrueになる場合、s = falseであれば全体もtrue
 - 元式の`(r)`がtrueになる場合、s = trueであれば全体もtrue
 - 両方ともfalseとなる場合、sにtrue/falseのどちらを入れてもfalse
 - 両方ともtrueとなる場合、sにtrue/falseのどちらを入れてもtrue

　というわけで、元の論理式がtrueになる時（`(p && q)`と`(r)`のどちらかもしくは両方がtrue）になる時と、変形された後の式がtrueになる時が一致しているので、上記の意味で「変形可能」です。

　さらに、`&&`を掛け算、`||`を足し算と見るといわゆる「分配法則」が使えることを利用すると、次のように同値変形できます。

```
// 左の項で「分配法則」を使う：
((p && q) || s) && (r || !s) =    
　((p || s) && (q || s)) && (r || !s)
```

　一般の論理式を変形する方法はホップクロフト [\[2\]][2]に
書いてありますが、ここでは省略します。少しだけいうと、ドモルガンの法則を使ってnotをand/orの内側の論理変数に押し込んだ後に、説明した変形でCNFに変換します。

　なお、この変形は素朴に書くと非常に遅いため、今回は直接は書かずわたしの書いたライブラリを利用します。このライブラリは次のChapter3で触れます。

##論理パズルを解いてみよう

　ここまででSATソルバーの使い方を完全に伝授できたので、この章のゴールとして、ためしに一つ簡単な論理パズルを解いてみましょう [\[3\]][3]。

> 嘘つきと正直者（１）

> 嘘つきが２人、正直者が１人います。  
> Ａは「私は正直者だ」と主張し、Ｂは「Ａは嘘つきだ。俺こそが正直者だ」といい、Ｃは「Ｂは嘘をいっている。本当の正直者は僕だ」といっています。  
> 正直者は誰でしょうか？


### 論理変数を設計する

まず、この3人が正直かどうかの論理変数を作ります：

 - a,b,c: a,b,cがそれぞれ正直ならtrue、嘘つきならfalse

すると、それぞれの言い分は次のように書けます：

> Ａは「私は正直者だ」

 Aが正直ならこの文章は正しいですし、Aが嘘つきでもやはり正しい（嘘つきが正直者だと嘘をついている）ので実は何も言っていません。

> Ｂは「Ａは嘘つきだ。俺こそが正直者だ」

 「俺こそが正直者だ」はAの主張と同じで何も言ってません。「Aは嘘つき」だというところにだけ注目すればOKです。

　Bが「Aは嘘つき」と言ったということはBが正直ならAは嘘つき、Bが嘘つきならAは正直、という意味なので

```
(b && !a) || (!b && a)
```
と論理式に翻訳できます。

> Ｃは「Ｂは嘘をいっている。本当の正直者は僕だ」

これもBと同様に、

```
(c && !b) || (!c && b)
```

となります。


### CNFへ変形する

全体の論理式は、BとCの論理式を&&で繋げればよくて、

```
((b && !a) || (!b && a)) &&
((c && !b) || (!c && b))
```

となります。これをさらに先ほどのテクニックでCNFに変形します。

```
((b && !a) || !t1) && ((!b && a) || t1) &&
((c && !b) || !t2) && ((!c && b) || t2)
=>
((b || !t1) && (!a || !t1) && ((!b || t1) && (a || t1) &&
((b || !t2) && (!a || !t2) && ((!b || t2) && (a || t2)
```

最後に、これをDIMACS形式にします：

```
c src/chapter2/puzzle.sat
p cnf 5 8
2 -4 0
-1 -4 0
-2 4 0
1 4 0
3 -5 0
-2 -5 0
-3 5 0
2 5 0
```

論理変数には、a,b,c,t1,t2にそれぞれ1〜5を割当てました。

これを解かせると、

```bash
$ minisat puzzle.sat puzzle.ans
(...中略....)
CPU time              : 0.001207 s

SATISFIABLE
```

と「充足可能（＝論理パズルは解ける）」という回答が返ってきました。

論理変数の割当てを見ると：

```bash
$ cat puzzle.ans
SAT
1 -2 3 -4 5 0
```

　となり、a,cはtrue、bはfalseとなりました（残りのt1,t2はCNFに変形するために用意したテンポラリ変数ですから、無視してよいのでした）。

　よって、答えは「嘘を付いているのはB」です。確かに、この答えを検算してみると合ってますね。

## 次は？

　手動でCNFの変形をしてると頭が痛くなりそうじゃないですか？単純労働ですし、こういったものは積極的に自動化しましょう。

　というわけで、次はわたしが作ったSATのためのライブラリを紹介します。

## 参考文献

\[1\] SAT Competition 2009: Benchmark Submission Guidelines    
http://www.satcompetition.org/2009/format-benchmarks2009.html

[1]: http://www.satcompetition.org/2009/format-benchmarks2009.html "SAT Competition 2009: Benchmark Submission Guidelines"

\[2\] オートマトン言語理論 計算論2 <第2版>,    
ジョン・E・ホッブクロフト (著), R・モトワニ (著), J・D・ウルマン (著), 野崎 昭弘 (翻訳)    
http://www.amazon.co.jp/dp/4781910270/ref=cm_sw_r_tw_dp_6O2Gwb1YRB125

[2]: http://www.amazon.co.jp/dp/4781910270/ref=cm_sw_r_tw_dp_6O2Gwb1YRB125 "オートマトン言語理論 計算論2 <第2版>"


\[3\] ソードワールドRPG蜃気楼の塔  
http://www.geocities.co.jp/Playtown/8112/hobby/ho0002.html

[3]: http://www.geocities.co.jp/Playtown/8112/hobby/ho0002.html
