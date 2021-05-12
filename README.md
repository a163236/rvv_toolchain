# 概要
RISC-VのV拡張v0.10対応のgnu-toolchainとspikeとpkのビルド済みイメージです．(RISC-V Vecotr extension)

- [riscv-gnu-toolchainのrvv-intrinsicブランチ](https://github.com/riscv/riscv-gnu-toolchain/tree/rvv-intrinsic)
- [riscv-isa-sim](https://github.com/riscv/riscv-isa-sim)
- [riscv-pk](https://github.com/riscv/riscv-pk)

riscv-gnu-toolchainのrvv-intrinsicブランチと，riscv-isa-sim(spike)，riscv-pkをダウンロード＆ビルド． /opt/riscv/のフォルダにそれら全てがインストールされているので，Dockerのマルチステージビルドを使用して，/opt/riscv/ファイルだけをデプロイしました．
イメージサイズは900MBくらいです．

## Dockerfile
Dockerfileはこちらにあります．
https://github.com/a163236/docker_folder/blob/master/riscv_vector_toolchain_dockerimage/Dockerfile

# インストール方法

まず，dockerが使える環境にしておくことが必要です．

イメージの取得
```bash
docker pull a163236/rvv_toolchain
```

コンテナの作成
```bash
docker run --name rvv_toolchain -it a163236/rvv_toolchain
```

コンテナの起動とアタッチ
```bash
docker start -a rvv_toolchain
```

# 使用方法

使用方法についてはC言語やアセンブリコードをコンパイルし，spikeシミュレータで実行することを想定しています．

## コンパイル

```bash
riscv64-unknown-elf-gcc -mcmodel=medany -march=rv64gcv -O3 [Cソース] -o [実行ファイル名]
```
-mcmodel=medanyを付けると中規模のコードになるらし．

## アセンブソースのコンパイル
```bash
riscv64-unknown-elf-gcc -march=rv64gcv -nostdlib [アセンブリソース] -o [実行ファイル名]
```

## 逆アセンブル

```bash
riscv64-unknown-elf-objdump -D [実行ファイル名] > [実行ファイル名].txt
```

# シミュレーション
spikeによるシミュレーション．
--varchオプションでベクタの長さ，--isaで実装のオプションが選択できる．オプションは ```spike --help```コマンドで見れる．

```bash
spike --varch=vlen:128,elen:32,slen:128 --isa=rv64gcv pk [実行ファイル名]
```

デバッグモードでのシミュレーション
```bash
spike -d --varch=vlen:128,elen:32,slen:128 --isa=rv64gcv pk [実行ファイル名]
```

# 使用例
helloworld.Sファイルとして以下のコードを保存します．

```asm:helloworld.S
  .globl _start

_start:

  vsetivli t0, 10, e8 //AVL=10, vtype=8bit // 8bitが10個
  la a1, string
  vle8.v v30, (a1)

  li a0, -32
  vadd.vx v30, v30, a0
  vse8.v v30, (a1)

  # print
  li a0, 1
  la a1, string
  li a2, 12 // string length
  li a7, 64 // write system call
  ecall

  li a0, 0
  li a7, 93 #exit system call
  ecall

  .data 
  .align 8
string:
  .ascii "helloworld!\n"
```

下記のコマンドでコンパイルと逆アセンブルを行う．

```bash
riscv64-unknown-elf-gcc -march=rv64gcv -nostdlib helloworld.S -o helloworld && riscv64-unknown-elf-objdump -D helloworld > helloworld.txt
```

下記コマンドでにより実行を行う．

```bash
spike --varch=vlen:128,elen:32,slen:128 --isa=rv64gcv pk helloworld
```

そうすると以下のようにHELLOWORLD!の文字が出力されるはずです．

```
bbl loader
HELLOWORLD!
```
