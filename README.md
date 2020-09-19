# qwertycd
This is terminal UI based cd command written in Nim.

<img src="https://github.com/minefuto/qwertycd/blob/master/gif/qwertycd.gif">

## Getting Started

### 1. Install the qwertycd binary.
```
nimble install https://github.com/minefuto/qwertycd.git
```

Or, download the binary from Release Page and drop it in your `$PATH`.  
<https://github.com/minefuto/qwertycd/releases>


### 2. Add the following to shell's config file.
**Bash(`.bashrc`)**
```
function qcd() {
  qwertycd
  cd "`cat $HOME/.cache/qwertycd/cache_dir`"
}
```
**Zsh(`.zshrc`)**
```
function qcd() {
  qwertycd
  cd "`cat $HOME/.cache/qwertycd/cache_dir`"
}
```
**Fish(`config.fish`)**
```
function qcd
  qwertycd
  cd (cat $HOME/.cache/qwertycd/cache_dir)
end
```
**PowerShell(`Microsoft.PowerShell_profile.ps1`)**
```
function qcd() {
  qwertycd
  $path = $env:HOMEPATH + "\.cache\qwertycd\cache_dir"
  $file = Get-Content $path
  Set-Location $file
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
macOS, Linux, Windows

## License
MIT
