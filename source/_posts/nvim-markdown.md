---
title: nvim-markdown
date: 2022-08-14 19:53:08
excerpt: 在 Neovim/Vim 中编写 Markdown
tags:
- neovim
- markdown
categories:
- neovim
---

## 在 Neovim/Vim 中编写 Markdown

在以前我们曾经拥有过一个非常完美的插件：[iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)。这是一个非常好的插件，它在很大程度上满足了我们的要求。

但是它任然有一些非常致命的缺点，比如说无法利用第三方转换工具 `pandoc` 以及自定义主题和高亮格式的方法与一般的工具不一样。对于一个颜控来说无法自定义主题其实是非常难受的一件事。

在逛 `Reddit` 论坛时我无意间了解到了一个叫 [markdown-composer](https://github.com/euclio/vim-markdown-composer) 的插件。它是为数不多可以异步渲染、同时还可以利用第三方渲染工具的插件。不过美中不足的就是它无法 __同步滚动__ 这可能是这个插件最致命的缺点了。实际上，[同步滚动的要求](https://github.com/euclio/vim-markdown-composer/issues/34) 18 年就有人提出来了，由于插件原理的原因到现在还没有实现。

### 安装

由于它是用 Rust 编写的，所以你需要使用 `cargo` 来编译。你需要先安装好相关的 Rust 工具包：[Rust 安装指南](https://www.rust-lang.org/zh-CN/tools/install)

然后使用你自己喜欢的插件管理器安装插件吧。

#### vim-plug

``` vim
function! BuildComposer(info)
  if a:info.status != 'unchanged' || a:info.force
    if has('nvim')
      !cargo build --release --locked
    else
      !cargo build --release --locked --no-default-features --features json-rpc
    endif
  endif
endfunction

Plug 'euclio/vim-markdown-composer', { 'do': function('BuildComposer') }
```

#### Vundle

``` vim
Plugin 'euclio/vim-markdown-composer'
```

不过在这之后你需要手动编译一遍：

``` bash
# cd 到你的插件目录，再执行接下来的操作
# 如果你是 Vim 用户
cargo build --release --no-default-features --features json-rpc
# 如果你是 Neovim 用户
cargo build --release
```

#### Dein.vim

``` vim
call dein#add('euclio/vim-markdown-composer', { 'build': 'cargo build --release' })
```

#### Packer.nvim

官方其实并没有给出用 Packer 安装的方法……下面这段代码其实是我琢磨出来的

``` lua
use {
  "euclio/vim-markdown-composer",
  run = "cargo build --release",
}
```

### 开始使用

然后你就可以简单地进行编写了……

![](https://s1.ax1x.com/2022/08/14/vUhWkQ.gif)

非常简单，不是吗？简洁而迅速，是我最喜欢这个插件的地方。

这个插件默认采用的渲染器是 CommonMark，支持最基本的语法和 Katex，如果不需要拓展语法其实完全够用了。如果你需要指定渲染器，比如 Pandoc，那么你只需要指定 `g:markdown_composer_external_renderer`。不过插件要求的渲染器必须从 `stdin` 中读入文件并且从 `stdout` 中输出转换后的结果。

下面给出将渲染器指定为 `pandoc` 示例：

``` vim
let g:markdown_composer_external_renderer='pandoc -f markdown -t html'
```

在 lua 中，可以这么写：

``` lua
vim.g.markdown_composer_external_renderer = 'pandoc -f markdown -t html'
```

插件默认的代码高亮是与 github 的一样，不过可以指定渲染出来后代码的高亮格式。比如：

``` vim
let g:markdown_composer_syntax_theme = 'atom-one-dark'
```

在 lua 中，可以这么写：

``` lua
vim.g.markdown_composer_syntax_theme = 'atom-one-dark'
```

对比图：左 github，右 atom-one-dark

![vUzIIA.png](https://s1.ax1x.com/2022/08/14/vUzIIA.png)

所有高亮格式的预览你都可以在这个网址里看到：[网址](https://highlightjs.org/static/demo/)

`markdown_composer_syntax_theme` 所需要的值都可以在 [这里](https://github.com/isagalaev/highlight.js/tree/master/src/styles) 找到（不要把进去 `.css` 写进去）

插件不仅可以指定代码高亮的格式，还可以指定 markdown 整体的一个主题而不是默认的白色。不过这个会相对麻烦一点点。

如果你需要指定相应的主题，你需要提供 css 文件的 url 地址。不过必须是一个指向本地文件的 `file` url 而不能是 http 或者 http。

比如我在 `/theme` 文件夹中有一个 `dracula.css` 文件是我想要的主题样式，此时我们可以这么写：

``` vim
```
`/theme/dracula.css`
