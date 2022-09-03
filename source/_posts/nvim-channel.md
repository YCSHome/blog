---
title: Neovim的Channel
date: 2022-08-25 22:56:01
excerpt: 在Neovim上对Channel的研究
categories:
- Neovim
tags:
- Neovim
- Channel
---

# Neovim的Channel

## 前言

最近开始打算自己琢磨写 nvim 插件了，了解到了一个非常重要的概念 channel，但是搜了一下几乎没有找到相应的教程。这有一点点悲哀了属于是。打算自己写一篇博客来记录一下自己折腾的历史。

## 关于 channel

channel 的直译为通道……我感觉通道这个翻译……尚可吧。这个本质上是 nvim 与外部进行通信的方式。打开通道的方式比较独特，官方文档里给出了以下五种方式：

1. 当 nvim 以 `--headless` 启动时，使用 `stdioopen()` 来作为一个启动脚本打开通道。这个通道依赖标准输入输出。

2. 通过 `jobstart()` 产生的进程的 `stdin`、`stdout` 与 `stdcerr`。

3. 通过用 `jobstart(..., {'pty': v:true})` 或者 `termopen()`的方式打开一个 PTY 通道。

4. 通过 `sockconnect()` 连接到一个 TCP 或者 IP scoket 或者命名的管道。

5. 由另一个进程连接到 nvim 监听的 socket，只支持 RPC 通道。

好玩的是，内种终端也是在 PTY 通道上实现的。

每一个通道都有一个唯一的整数 ID，像 `stdioopen()` 这样的函数会返回通道的 ID，但是 `chansend()` 这样的函数会消耗掉通道 ID。

## 最简单暴力的操作
