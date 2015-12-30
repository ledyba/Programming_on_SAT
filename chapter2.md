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
 p || !p //pがｔでもfでもこの式はtrueになる
```

これをSATに入力する形式にすると、次のようになります。

```DIMACS:
c src/chapter2/hello.sat
c cで始まる行はコメントです
p cnf 1 1
1 -1 0
```

最初のcで始まる2行はコメントなので無視して、3行目から行きましょう。

最初の「p cnf」は、このファイルがCNF式であることを示しています。なお、SAT Competitonのドキュメント[\[1\]][1](を読む限りでは、CNF式以外の物であることは無いみたいです。

## 引用
\[1\] SAT Competition 2009: Benchmark Submission Guidelines
http://www.satcompetition.org/2009/format-benchmarks2009.html

[1]: http://www.satcompetition.org/2009/format-benchmarks2009.html "SAT Competition 2009: Benchmark Submission Guidelines"
