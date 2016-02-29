# PSCustomPrompt.ps1
# Makes the PowerShell prompt look just a little bit nicer. :)
#
# Copyright (c) 2016 Daniel J. Dunn II
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# TL;DR: Gimme a namedrop if it's useful, don't blame me if it wrecks your computer. Otherwise, have fun!

#--------------------------------------------------------------------
# Terminal Enabling Code From:
# http://www.nivot.org/blog/post/2016/02/04/Windows-10-TH2-%28v1511%29-Console-Host-Enhancements
Add-Type -MemberDefinition @"
[DllImport("kernel32.dll", SetLastError=true)]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, int mode);
[DllImport("kernel32.dll", SetLastError=true)]
public static extern IntPtr GetStdHandle(int handle);
[DllImport("kernel32.dll", SetLastError=true)]
public static extern bool GetConsoleMode(IntPtr handle, out int mode);
"@ -namespace win32 -name nativemethods

$h = [win32.nativemethods]::getstdhandle(-11) #  stdout
$m = 0
$success = [win32.nativemethods]::getconsolemode($h, [ref]$m)
$m = $m -bor 4 # undocumented flag to enable ansi/vt100
$success = [win32.nativemethods]::setconsolemode($h, $m)
#--------------------------------------------------------------------

# Set UTF8 Encoding so that everything plays nice
$global:OutputEncoding = [System.Text.Encoding]::UTF8

# Set up symbol collections
$global:Symbols = @{}

# Cosmetic symbols for fun.  I found these in DejaVu Sans Mono by
# digging around in the upper reaches of the font with the built-in
# Character Map font viewer.
$global:Symbols.Custom = @{
  Envelope      = "✉";
  StatusGood    = "✔";
  StatusBad     = "✘";
  CheckboxTrue  = "☑";
  CheckboxFalse = "☒";
  CheckboxNone  = "☐";
  Nuclear       = "☢";
  Stronghold    = "♜";
  Danger        = "☠";
  Warning       = "⚠";
  Power         = "⚡";
  Moon          = "☾";
  Alchemy       = "⚗";
  Gear          = "⚙";
  Scales        = "⚖";
  Flag          = "⚐";
  Star          = "✪";
  Angstrom      = "Å";
  Exchange      = "↹";
  Nabla         = "∇";
  Interrobang   = "‽";
  Query         = "⁇";
  Phi           = "ϕ";
  Micro         = "µ";
}

# Symbols inserted into the fonts by the powerline project. You
# can find them at https://github.com/powerline/fonts.  Install
# the font and enable it by creating a registry REG_SZ value in
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont
# It must be named as a sequence of '0's (e.g. "00", "000", ...)
# and contain the name of the font as reported by Character Map.
# You must re-login or reboot to apply the changes.
$global:Symbols.Powerline = @{
  FullBlock     = "█";
  RightBlock    = "";
  LeftBlock     = "";
  GitBranch     = "";
  LN            = "";
  Lock          = "";
  RightArrow    = "";
  LeftArrow     = "";
}

# Helper function to build escape sequences. Codes 30-37 select
# foreground color (0-7), codes 40-47 select background color
# (0-7). I wish I could tell you an easy way to figure out which
# is which, but all I could do was just try them and see.
function SetGraphics([int[]]$m)     { 
  "$([char]0x1b)[$([String]::Join(';',($m|%{$_.ToString()})))m"; 
}

# Create a template for the prompt so that we don't waste time
# reconstructing it every command.  Note that I use DarkCyan
# (Index 6) as the background color for the prompt, but I
# edited it in the console to RGB(0,90,135) so that it looks
# nicer.  I also used that color on a black background for
# the initial symbol to make it stand apart.  Near the end,
# I switch to DarkCyan foreground and DarkMagenta (Index 5)
# background. (Default PowerShell recolors DarkMagenta to the
# dark-blue background color, and DarkYellow to the default
# grayish text color.) The 'RightBlock' character from Powerline
# creates the nice transition between the two.
$global:PromptTemplate =              `
    (SetGraphics 36, 40) +            `
    "{0}" +                           `
    (SetGraphics 33, 46) +            `
    " {1} " +                         `
    (SetGraphics 36, 45) +            `
    $Symbols.Powerline.RightBlock +   `
    (SetGraphics 37, 45) +            `
    ""

# Store the symbol for the prompt
$global:PromptSymbol = $Symbols.Custom.Stronghold;

# Function to switch prompt symbol by name - you could obviously do
# far more sophisticated things than this.
function global:psymbol ( [string]$name )
{
  if ( $global:Symbols.Custom.ContainsKey( $name ) )
  {
    $global:PromptSymbol = $global:Symbols.Custom[$name]
  }
  else
  {
    Write-Error "No symbol named '$name' found in `$Symbols.Custom"
  }
}

# Prompt rendering function
function global:prompt
{
  return ( $PromptTemplate -f @( $global:PromptSymbol, $pwd.ProviderPath ) )
}