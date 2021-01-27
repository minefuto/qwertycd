# qwertycd
![GitHub](https://img.shields.io/github/license/minefuto/qwertycd?style=for-the-badge)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/minefuto/qwertycd?style=for-the-badge)

This is terminal UI based `cd` command written in Nim.

<img src="https://github.com/minefuto/qwertycd/blob/master/gif/qwertycd.gif">

## Features
- Change directory
- Bookmark directory
- History of change directory
- Preview file
- Open file with $EDITOR

## Getting Started

### 1. Install the qwertycd binary.
```
nimble install qwertycd
```

Or, download the binary from Release Page and drop it in your `$PATH`.  
<https://github.com/minefuto/qwertycd/releases>


### 2. Add the following to shell's config file.
**Bash(`.bashrc`)**
```
function qcd() {
  qwertycd
  cd "`cat $HOME/.qwertycd/cache_dir`"
}
```
**Zsh(`.zshrc`)**
```
function qcd() {
  qwertycd
  cd "`cat $HOME/.qwertycd/cache_dir`"
}
```
**Fish(`config.fish`)**
```
function qcd
  qwertycd
  cd (cat $HOME/.qwertycd/cache_dir)
end
```
**PowerShell(`Microsoft.PowerShell_profile.ps1`)**
```
function qcd() {
  qwertycd
  $path = $env:HOMEPATH + "\.qwertycd\cache_dir"
  $file = Get-Content $path
  Set-Location $file
end
```

## Configurations
Download `qwertycd.toml` from the following and edit.   
https://github.com/minefuto/qwertycd/blob/master/example/qwertycd.toml

**macOS/Linux**  
Put to `$HOME/.qwertycd/qwertycd.toml`  

**Windows**  
Put to `env:HOMEPATH\.qwertycd\qwertycd.toml`

## Supported OS
macOS, Linux, Windows
