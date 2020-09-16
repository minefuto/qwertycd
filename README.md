# qwertycd
This is terminal UI based cd command written in Nim.

<img src="https://github.com/minefuto/qwertycd/blob/master/gif/qwertycd.gif">

## Getting Started

### 1. install qwertycd
Download the binary from Release Page and drop it in your `$PATH`.  
<https://github.com/minefuto/qwertycd/releases>

Or, please use `nimble install` command.
```
nimble install https://github.com/minefuto/qwertycd.git
```

### 2. Add the following to config file(e.g. `.bashrc`, `.zshrc`, `config.fish`).  
**bash**
```
function qcd() {
  qwertycd
  cd "`cat ~/.cache/qwertycd/cache_dir`"
}
```
**zsh**
```
function qcd() {
  qwertycd
  cd "`cat ~/.cache/qwertycd/cache_dir`"
}
```
**fish**
```
function qcd
  qwertycd
  cd (cat ~/.cache/qwertycd/cache_dir)
end
```
If defined `$XDG_CACHE_HOME` variable environment,  
please replace the above configuration from `~/.cache` to `$XDG_CACHE_HOME`.  
example:  
```
function qcd() {
  qwertycd
  cd "`cat $XDG_CACHE_HOME/qwertycd/cache_dir`"
}
```
## Supported OS
macOS, Linux

## License
MIT
