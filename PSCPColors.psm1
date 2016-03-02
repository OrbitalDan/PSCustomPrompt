# PSCPColors.psm1
#
# Create data about the colors in PowerShell, and a few helper functions
# to make working with terminal colors easier
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

# Powershell Color Helper
$global:PSColors = @{}
@(
  #          Name                  System.ConsoleColor       ANSI Code
  #          -------------         -------------------       ---------
  @{ Name = "Black";       Enum = "Black";            Code = 030;       },
  @{ Name = "DarkRed";     Enum = "DarkRed";          Code = 031;       },
  @{ Name = "DarkGreen";   Enum = "DarkGreen";        Code = 032;       },  
  @{ Name = "DarkYellow";  Enum = "DarkYellow";       Code = 033;       },
  @{ Name = "PSFore";      Enum = "DarkYellow";       Code = 033;       }, # Powershell: Silver Foreground
  @{ Name = "DarkBlue";    Enum = "DarkBlue";         Code = 034;       },
  @{ Name = "DarkMagenta"; Enum = "DarkMagenta";      Code = 035;       },
  @{ Name = "PSBack";      Enum = "DarkMagenta";      Code = 035;       }, # Powershell: Dark Blue Background
  @{ Name = "DarkCyan";    Enum = "DarkCyan";         Code = 036;       },
  @{ Name = "Gray";        Enum = "Gray";             Code = 037;       },
  @{ Name = "DarkGray";    Enum = "DarkGray";         Code = 090;       },
  @{ Name = "Red";         Enum = "Red";              Code = 091;       },
  @{ Name = "Green";       Enum = "Green";            Code = 092;       },
  @{ Name = "Yellow";      Enum = "Yellow";           Code = 093;       },
  @{ Name = "Blue";        Enum = "Blue";             Code = 094;       },
  @{ Name = "Magenta";     Enum = "Magenta";          Code = 095;       },
  @{ Name = "Cyan";        Enum = "Cyan";             Code = 096;       },
  @{ Name = "White";       Enum = "White";            Code = 097;       }
) | %{
  $global:PSColors[ $_.Name ] = $_
}

# Helper function to build escape sequences. Codes 30-37, 90-97
# select foreground color (0-15), codes 40-47, 100-107 select
# background color (0-15). I wish I could tell you an easy way
# to figure out which is which, but all I could do was just try
# them and see.
function Set-TerminalGraphics([int[]]$m)     { 
  "$([char]0x1b)[$([String]::Join(';',($m|%{$_.ToString()})))m"; 
}
Export-ModuleMember -Function Set-TerminalGraphics

# Helper function to build color escape sequences
function Set-TerminalColor( [int]$Foreground, [int]$Background = -1 )
{
  if ( $Background -ge 0 )
  {
    # Background codes are always foreground codes + 10
    Set-TerminalGraphics $Foreground, ($Background + 10)
  }
  else
  {
    Set-TerminalGraphics $Foreground
  }
}
Export-ModuleMember -Function Set-TerminalColor