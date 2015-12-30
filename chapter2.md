# 簡単な論理パズルを解く

この章では、実際にSATソルバーを使って簡単な問題を解いてみましょう。

## あなたとSATソルバー、いますぐダウンロード

　なにはともあれ、SATソルバーを入手しないといけませんね。今回は[MiniSAT](http://minisat.se/)（[http://minisat.se/](http://minisat.se/)）というソフトウェアを使います。このソフトウェアはこの業界ではかなり有名で、[SAT Competition](http://www.satcompetition.org/)というSATソルバーの世界大会ではこれを改造したものがかなり出場しているようです。

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

```DIMACS:src/chapter2/hello.sat
p cnf 1 1
1 -1 0
```



