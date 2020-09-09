# qwertycd
This is terminal UI based cd command written in Nim.

<img src="https://github.com/minefuto/qwertycd/blob/master/gif/qwertycd.gif" width="600">

# Getting Started

1. Download qwertycd command
Download the binary from Release Page and drop it in your `$PATH`.
<https://github.com/minefuto/qwertycd/releases>

Or, please use `nimble install` command.
```
nimble install https://github.com/minefuto/qwertycd.git
```

2. Add the following to config file(e.g. `.bashrc`, `.zshrc`, `config.fish`).
*bash*
```
function qcd() {
  qwertycd
  cd `cat ~/.cache/qwertycd/cache_dir`
}
```
*zsh*
```
function qcd() {
  qwertycd
  cd `cat ~/.cache/qwertycd/cache_dir`
}
```
*fish*
```
function qcd
    qwertycd
    cd (cat ~/.cache/qwertycd/cache_dir)
end
```

# Supported OS
macOS, Linux

# License
MIT
