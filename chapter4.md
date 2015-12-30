# 足し算と引き算をする

　とりあえず、足し算を引き算を実装してみましょう。Brainfuckに必要なのは+1と-1だけなので、この２つだけを実装しましょう（現在コミケ当日の深夜で余裕がなくなってきた）。

## 論理変数を設計する

　足し算と引き算をする前に、まずtrueとfalseだけでどうやって数字を表すか考えましょう。

　といっても、これは簡単です。情報科学の基本概念、２進数です！数字を２進数の列で表して、0とfalse、1とtrueを対応させます。

　早速、そのデータ構造を作りましょう。入力／出力の各ビットに対応する各論理変数を作ります：

```hs
data Nat = InNat Int | OutNat Int deriving (Show,Read,Ord,Eq)
```

　論理変数`InNat 0`で入力する数値1ビット目を表し、論理変数`InNat 1`で入力する数値2ビット目を表し、…といった感じで表現します。出力も同じです。

　この方法では入力も出力も原理的に事実上無限bit考えることが出来ますが、一旦入力も出力も8bitで固定で考えます。

## 定数で固定する

　まず、入力を与える必要があります。ここでは一旦定数を与えましょう。

　そのためにはどうすればよいか。SATソルバーで問題をとく時の常套手段、というか唯一の方法ですが、「狙った答えになる時だけ論理式が充足されるように」論理式を作ります。定数の場合は簡単で、なって欲しい定数の時だけ真となる論理式を作ります。

　例えば、0=0b00000000(0が8コ)の時は、InNat 0からInNat 7まですべてfalseとなるように論理式を組み立てます。つまり、それぞれの論理変数すべての否定をAndでつなげた論理式を作ります。

```haskell
*Sally> And (fmap (\n -> Not(var (InNat n))) [0..7])
And [
    Not (FVar (Var (InNat 0))),
    Not (FVar (Var (InNat 1))),
    Not (FVar (Var (InNat 2))),
    Not (FVar (Var (InNat 3))),
    Not (FVar (Var (InNat 4))),
    Not (FVar (Var (InNat 5))),
    Not (FVar (Var (InNat 6))),
    Not (FVar (Var (InNat 7)))]
```

　この組み立て方のキモは、「Andで繋がれた条件はすべてTrueになる時かつその時に限り論理式が充足されること」です。つまり、この場合InNat *がすべてFalse（0）の時、かつその時に限り、この論理式がTrueになります。

　一般の数値に対して論理式を組み立てるためには、定数を２進数に変換してから同じことをすればOKです。

```hs
-- 数値を2進数のTrue/Falseのリストへ変換する
toBitList :: Int -> Int -> [Bool]

-- 最初の引数にはInNatかOutNatを渡せるようについでに一般化もした
makeConst :: (Int -> Nat) -> Int -> Int -> Fml Nat
makeConst type_ bitLength value =
      And $
        fmap (\(bi,b) ->
            if b
                then (FVar (Var (type_ bi)))
                else Not (FVar (Var (type_ bi))))
        (zip [0..] (toBitList bitLength value))

 -- 8ビットで定数「10」を表す論理式を作る
main = print (makeConst InNat 8 10)
```

## 1ビット加算器を作る

　さて、定数は表せたので、足し算を考えていきましょう。最初に書いたとおり、+1だけ考えます。足し算といえば、論理回路です。というわけで、まずは２進数１桁ぶんの足し算をする回路を作ります：

 - 入力（それぞれ1ビットの論理変数）
   - I<sub>1</sub> 
   - I<sub>2</sub> 
 - 出力
   - O=I<sub>1</sub> + I<sub>2</sub>の下1bit
   - C=I<sub>1</sub> + I<sub>2</sub>の上1bit

　言い換えると、Cは繰り上がりです。

### 上1bit（繰り上がり）
　上1bitであるCは簡単で、I<sub>1</sub> もI<sub>2</sub>も1（True）の時だけ繰り上がりが起こるのでC=I<sub>1</sub> && I<sub>2</sub>です。

　論理式がCとI<sub>1</sub> && I<sub>2</sub>等しいこと（＝）は言い換えればどちらも真であるかどちらも偽であるかのどちらかなので、次のようにエンコーディングできます。

　(C && (I<sub>1</sub> && I<sub>2</sub>)) || (!C && !(I<sub>1</sub> && I<sub>2</sub>))

以下、これを(C=I<sub>1</sub> && I<sub>2</sub>)と略記します。

### 下1bit

　下1bitは結構面倒です。I<sub>1</sub>と I<sub>2</sub>の組み合わせを調べると、I<sub>1</sub>とI<sub>2</sub>のどちらか片方だけが真の時だけOは真になります。これはいわゆるxor演算ですが、これをそのまま実装すると少し長くなるので、今回は次のように実装しました。

　((I<sub>1</sub> = I<sub>2</sub>) && !O) || (!(I<sub>1</sub> = I<sub>2</sub>) && O)

 I<sub>1</sub>と I<sub>2</sub>をそれぞれ代入すると、この論理式がTrueになるのは

 - I<sub>1</sub>とI<sub>2</sub>が等しく、OがFalse
 - I<sub>1</sub>とI<sub>2</sub>が異なり、OがTrue

のとき、かつその時に限るので、O=I<sub>1</sub> xor I<sub>2</sub>という等式が作れたことになります。

## 1ビット減算器を作る

　

