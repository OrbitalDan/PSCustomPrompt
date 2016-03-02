# PSCPSymbols.psm1
#
# Initialize the library of symbols, and symbol helper-functions.
#
# Copyright (c) 2016 Daniel J. Dunn II
#
# --- Standard MIT License: -----------------------------------------
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# -------------------------------------------------------------------
#
# TL;DR: Gimme a namedrop if it's useful, don't blame me if it wrecks your computer. Otherwise, have fun!
#

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
  Atom          = "⚛";
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

# Store the symbol for the prompt
$global:PSCPSettings.Emblem = $Symbols.Custom.Gear;

# Function to switch prompt symbol by name - you could obviously do
# far more sophisticated things than this.
function Set-PSCustomPromptEmblem ( [string]$Name )
{
  if ( $global:Symbols.Custom.ContainsKey( $name ) )
  {
    $global:PSCPSettings.Emblem = $global:Symbols.Custom[$name]
  }
  else
  {
    Write-Error "No symbol named '$Name' found in `$Symbols.Custom"
  }
}
Export-ModuleMember -Function Set-PSCustomPromptEmblem

# A simple segment that displays a single symbol, stored in $PSCPSettings.Emblem
# This is just for aesthetics, it has no real effect on anything.
$global:PSCPSettings.Segments[ "Emblem" ] = @{
  Name       = "Emblem";
  Background = $PSColors.Black.Code;
  Foreground = $PSColors.DarkCyan.Code;
  Blend      = "None";
  Render     = [scriptblock]{
    return $global:PSCPSettings.Emblem
  }
}