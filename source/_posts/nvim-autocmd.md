---
title: Neovim/Vim 与它的 autocmd
date: 2022-08-13
excerpt: 对neovim与autocmd的简单讨论
tags:
- neovim
- vim
categories:
- neovim
---

## Neovim/Vim 和它的 autocmd

### 从 vim 开始谈起

autocmd 是 vim 中一个非常实用的东西。autocmd即自动命令，指当满足一定条件下会自动触发的事件。在 vim 中我们可以实用 `autocmd` 这个简单的命令来进行定义。

如果您对 autocmd 足够了解，只是想知道在 Neovim 里的 API，可以直接跳过这一部分。

如果你想要创建一个新的自动命令，只需要使用如下命令：

``` vim
autocmd [group] {event} {aupat} [++once] [++nested] {cmd}
```

其中，`{...}` 对应的参数是必须参数，`[...]` 对应的参数是可选参数。

#### 快速入门

首先我们可以看一个例子：

在命令模式下输入这段命令

``` vim
:autocmd BufWrite * sleep 500m
```

然后任意保存一个文件……

你会发现你的 vim 卡了一下，大概半秒。这就是自动命令在搞鬼了。当你保存文件的时候，就相当于触发了一个事件 `BufWrite`。vim 发现你刚好定义了一个自动命令，这个自动命令要求当触发 `BufWrite` 事件时、文件名刚好又匹配 `*`，于是便执行命令 `:sleep 500m` （即暂停 `0.5` 秒）

在这一个自动命令里面，`BufWrite` 对应的就是 `{event}`，即触发所需要的时间。`*` 对应的参数就是 `{aupat}`，`{aupat}` 即 `autocmd-pattern`（自动命令匹配模式），当触发对应事件并且文件名匹配 `{aupat}` 时，就会执行 `{cmd}`。

其中，`{cmd}` 对应的是一个命令，不过经过我的实践，貌似 `{cmd}` 并不可以是一个函数，也就是说如果你想通过 `autocmd` 执行一个 vim 函数必须通过类似 `call fn()` 的方式调用。

#### group

group ，即自动命令组。可以用来管理多个 autocmd 命令。

我们有一个用来创建/切换自动命令组的命令 `augroup`，先看一个示例：

``` vim
augroup test
  autocmd BufWrite * echom "a"
augroup END
```

> 这里提一嘴关于 vim 命令运行的技巧  
> 你可以将上述命令保存到一个文件里面，例如保存到 `test.vim`  
> 然后运行 `source %`，`%` 意味着当前文件，此时就相当于运行了一遍 vimscript

当你执行上述命令之后，再随意保存一个文件。然后通过 `message` 来查看相关信息。

``` vim
:source test.vim
:message clear
:w
:message
a
"test.vim" 3L, 57B written
```

如果 message 出来的信息过多影响观感可以用 `message clear` 清空
此时，若你尝试使用 `autocmd!` 清空掉这条自动命令……

``` vim
:message clear
:autocmd!
:message clear
:w
a
"test.vim" 3L, 57B written
```

发现了吗？这条自动命令并没有被清掉。此时我们已经可以大概猜出 `group` 的作用：用来将自动命令分组。而 `augroup` 所做的就是 __创建__ 并切换自动命令组。其中一个最特别的 `augroup end|END` 可以回到默认分组。

对于分组，除了使自动命令的分类更加清晰，还有一个最大的作用：防止同一个自动命令被执行多次。

在自动命令中，由于 vim 压根不知道你是否要保留哪怕是一模一样的自动命令，所以最简单粗暴的做法就是让每一个自动命令都是独立的。对于以下命令：

``` vim
augroup test
  autocmd BufWrite * echom "a"
  autocmd BufWrite * echom "a"
  autocmd BufWrite * echom "a"
  autocmd BufWrite * echom "a"
augroup END
```

``` vim
:source %
:source %
:message clear
:w
:message
a
a
a
a
a
a
a
a
"test.vim" 6L, 153B written
```

由于我们执行了两遍 `source`，导致原本 `test` 组里的自动命令也翻了一倍。为了解决这种奇怪的问题，我们可以这么做：

``` vim
augroup test
  autocmd!
  autocmd BufWrite * echom "a"
  autocmd BufWrite * echom "a"
  autocmd BufWrite * echom "a"
  autocmd BufWrite * echom "a"
augroup END
```

``` vim
:source %
:source %
:message clear
:w
:message
a
a
a
a
"test.vim" 7L, 164B written
```

#### event

event 即事件，每当你执行某些特定动作时会触发一些事件。比如 `BufWrite` 就是一个最简单的事件：当缓冲区内的文本写入一个文件是。你可以简单理解为当你保存文件的时候。也就是说你可以通过很多个事件，来实现一些非常有趣的功能：比如当你打开一个新文件的时候替你读取一个模板等等。

注：每一个例子中的细节可能不同情况下不一样

+ `BufAdd`  
  当你创建一个新的缓冲区后将其添加到缓冲区列表时，亦或者是缓冲区列表中的一个缓冲区被重命名。这在编写插件的时候会非常有用。
  > 例子:
  > ``` vim
  > :autocmd BufAdd * echo "you add/rename a buffer"
  > :vs test
  > you add/rename a buffer
  > ```

+ `BufDelete`  
  当一个缓冲区被删除、或者被重命名之前。  
  > 例子:
  > ``` vim
  > :autocmd BufDelete * echo "you delete/rename a buffer"
  > :ls
  >   1 %a   "[No Name]"                    line 1
  > :bdelete 1
  > you delete/rename a buffer
  > ```

+ `BufEnter`  
  当你进入一个缓冲区时。不过会在 `BufAdd` 和 `BufReadPost` 之后。
  > 例子:
  > ``` vim
  > :autocmd BufEnter * echo "BufEnter"
  > :vs test
  > BufEnter
  > ```
  > 然后输入 `<C-W>l` 来切换窗口，也会输出 `BufEnter`

+ `BufFilePost`
  当你用 `:file` 或者 `saveas` 更改光标选择的缓冲区的名字时。
  > 例子:
  > ``` vim
  > :autocmd BufFilePost * echo "change"
  > :fild test
  > change
  > :saveas test2
  > change
  > ```
