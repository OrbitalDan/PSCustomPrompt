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
  Atom          = "⚛";
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

# Helper function to build escape sequences. Codes 30-37, 90-97
# select foreground color (0-15), codes 40-47, 100-107 select
# background color (0-15). I wish I could tell you an easy way
# to figure out which is which, but all I could do was just try
# them and see.
function SetGraphics([int[]]$m)     { 
  "$([char]0x1b)[$([String]::Join(';',($m|%{$_.ToString()})))m"; 
}

# Helper function to build color escape sequences
function SetColor( [int]$Foreground, [int]$Background = -1 )
{
  if ( $Background -ge 0 )
  {
    SetGraphics $Foreground, ($Background + 10)
  }
  else
  {
    SetGraphics $Foreground
  }
}

function global:PoshGitRender( $status )
{
  $retstr = ""
  $s = $global:GitPromptSettings
  if ($status -and $s)
  {
    $branchStatusSymbol          = $null
    $branchStatusBackgroundColor = $s.BranchBackgroundColor
    $branchStatusForegroundColor = $s.BranchForegroundColor

    if (!$status.Upstream)
    {
      $branchStatusSymbol          = $s.BranchUntrackedSymbol
    }
    elseif ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0)
    {
      # We are aligned with remote
      $branchStatusSymbol          = $s.BranchIdenticalStatusToSymbol
      $branchStatusBackgroundColor = $s.BranchIdenticalStatusToBackgroundColor
      $branchStatusForegroundColor = $s.BranchIdenticalStatusToForegroundColor
    }
    elseif ($status.BehindBy -ge 1 -and $status.AheadBy -ge 1)
    {
      # We are both behind and ahead of remote
      $branchStatusSymbol          = $s.BranchBehindAndAheadStatusSymbol
      $branchStatusBackgroundColor = $s.BranchBehindAndAheadStatusBackgroundColor
      $branchStatusForegroundColor = $s.BranchBehindAndAheadStatusForegroundColor
    }
    elseif ($status.BehindBy -ge 1)
    {
      # We are behind remote
      $branchStatusSymbol          = $s.BranchBehindStatusSymbol
      $branchStatusBackgroundColor = $s.BranchBehindStatusBackgroundColor
      $branchStatusForegroundColor = $s.BranchBehindStatusForegroundColor
    }
    elseif ($status.AheadBy -ge 1)
    {
      # We are ahead of remote
      $branchStatusSymbol          = $s.BranchAheadStatusSymbol
      $branchStatusBackgroundColor = $s.BranchAheadStatusBackgroundColor
      $branchStatusForegroundColor = $s.BranchAheadStatusForegroundColor
    }
    else
    {
      # This condition should not be possible but defaulting the variables to be safe
      $branchStatusSymbol          = "?"
    }

    $branchName = $status.Branch;
    if($s.BranchNameLimit -gt 0 -and $branchName.Length -gt $s.BranchNameLimit)
    {
        $branchName = "{0}{1}" -f $branchName.Substring(0,$s.BranchNameLimit), $s.TruncatedBranchSuffix
    }
    $retstr += (SetColor -F $PSColors[$branchStatusForegroundColor.ToString()].Code) + `
      $branchName
      
    if ($branchStatusSymbol)
    {
      $retstr += (SetColor -F $PSColors[$branchStatusForegroundColor.ToString()].Code) + `
        (" {0}" -f $branchStatusSymbol)
    }

    if($s.EnableFileStatus -and $status.HasIndex)
    {
      $retstr += (SetColor -F $PSColors[$s.BeforeIndexForegroundColor.ToString()].Code) + `
        $s.BeforeIndexText

      if($s.ShowStatusWhenZero -or $status.Index.Added)
      {
        $retstr += (SetColor -F $PSColors[$s.IndexForegroundColor.ToString()].Code) + `
          " +$($status.Index.Added.Count)"
      }
      
      if($s.ShowStatusWhenZero -or $status.Index.Modified)
      {
        $retstr += (SetColor -F $PSColors[$s.IndexForegroundColor.ToString()].Code) + `
          " ~$($status.Index.Modified.Count)"
      }
      
      if($s.ShowStatusWhenZero -or $status.Index.Deleted)
      {
        $retstr += (SetColor -F $PSColors[$s.IndexForegroundColor.ToString()].Code) + `
          " -$($status.Index.Deleted.Count)"
      }
      
      if ($status.Index.Unmerged)
      {
        $retstr += (SetColor -F $PSColors[$s.IndexForegroundColor.ToString()].Code) + `
          " !$($status.Index.Unmerged.Count)"
      }
      
      if($status.HasWorking)
      {
        $retstr += (SetColor -F $PSColors[$s.DelimForegroundColor.ToString()].Code) + `
          $s.DelimText
      }
    }

    if($s.EnableFileStatus -and $status.HasWorking)
    {
      if($s.ShowStatusWhenZero -or $status.Working.Added)
      {
        $retstr += (SetColor -F $PSColors[$s.WorkingForegroundColor.ToString()].Code) + `
          " +$($status.Working.Added.Count)"
      }
      
      if($s.ShowStatusWhenZero -or $status.Working.Modified)
      {
        $retstr += (SetColor -F $PSColors[$s.WorkingForegroundColor.ToString()].Code) + `
          " ~$($status.Working.Modified.Count)"
      }
      
      if($s.ShowStatusWhenZero -or $status.Working.Deleted)
      {
        $retstr += (SetColor -F $PSColors[$s.WorkingForegroundColor.ToString()].Code) + `
          " -$($status.Working.Deleted.Count)"
      }
      
      if ($status.Working.Unmerged)
      {
        $retstr += (SetColor -F $PSColors[$s.WorkingForegroundColor.ToString()].Code) + `
          " !$($status.Working.Unmerged.Count)"
      }
    }

    if ($status.HasWorking)
    {
      # We have un-staged files in the working tree
      $localStatusSymbol          = $s.LocalWorkingStatusSymbol
      $localStatusBackgroundColor = $s.LocalWorkingStatusBackgroundColor
      $localStatusForegroundColor = $s.LocalWorkingStatusForegroundColor
    }
    elseif ($status.HasIndex)
    {
      # We have staged but uncommited files
      $localStatusSymbol          = $s.LocalStagedStatusSymbol
      $localStatusBackgroundColor = $s.LocalStagedStatusBackgroundColor
      $localStatusForegroundColor = $s.LocalStagedStatusForegroundColor
    }
    else
    {
      # No uncommited changes
      $localStatusSymbol          = $s.LocalDefaultStatusSymbol
      $localStatusBackgroundColor = $s.LocalDefaultStatusBackgroundColor
      $localStatusForegroundColor = $s.LocalDefaultStatusForegroundColor
    }

    if ($localStatusSymbol)
    {
      $retstr += (SetColor -F $PSColors[$localStatusForegroundColor.ToString()].Code) + `
        (" {0}" -f $localStatusSymbol)
    }
    
    if ($s.EnableStashStatus -and ($status.StashCount -gt 0))
    {
      $retstr += (SetColor -F $PSColors[$s.BeforeStashForegroundColor.ToString()].Code) + `
        $s.BeforeStashText
      $retstr += (SetColor -F $PSColors[$s.StashForegroundColor.ToString()].Code      ) + `
        $status.StashCount
      $retstr += (SetColor -F $PSColors[$s.AfterStashForegroundColor.ToString()].Code ) + `
        $s.AfterStashText
    }

    if ($WindowTitleSupported -and $s.EnableWindowTitle)
    {
      if( -not $Global:PreviousWindowTitle )
      {
        $Global:PreviousWindowTitle = $Host.UI.RawUI.WindowTitle
      }
      $repoName = Split-Path -Leaf (Split-Path $status.GitDir)
      $prefix = if ($s.EnableWindowTitle -is [string]) { $s.EnableWindowTitle } else { '' }
      $Host.UI.RawUI.WindowTitle = "$script:adminHeader$prefix$repoName [$($status.Branch)]"
    }
  }
  elseif ( $Global:PreviousWindowTitle )
  {
    $Host.UI.RawUI.WindowTitle = $Global:PreviousWindowTitle
  }
  
  return $retstr
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

# Powershell Color Helper
$global:PSColors = @{}
@(
  @{ Name = "Black";       Enum = "Black";       Code = 030; },
  @{ Name = "DarkRed";     Enum = "DarkRed";     Code = 031; },
  @{ Name = "DarkGreen";   Enum = "DarkGreen";   Code = 032; },  
  @{ Name = "DarkYellow";  Enum = "DarkYellow";  Code = 033; },
  @{ Name = "PSFore";      Enum = "DarkYellow";  Code = 033; }, # Powershell: Silver Foreground
  @{ Name = "DarkBlue";    Enum = "DarkBlue";    Code = 034; },
  @{ Name = "DarkMagenta"; Enum = "DarkMagenta"; Code = 035; },
  @{ Name = "PSBack";      Enum = "DarkMagenta"; Code = 035; }, # Powershell: Dark Blue Background
  @{ Name = "DarkCyan";    Enum = "DarkCyan";    Code = 036; },
  @{ Name = "Gray";        Enum = "Gray";        Code = 037; },
  @{ Name = "DarkGray";    Enum = "DarkGray";    Code = 090; },
  @{ Name = "Red";         Enum = "Red";         Code = 091; },
  @{ Name = "Green";       Enum = "Green";       Code = 092; },
  @{ Name = "Yellow";      Enum = "Yellow";      Code = 093; },
  @{ Name = "Blue";        Enum = "Blue";        Code = 094; },
  @{ Name = "Magenta";     Enum = "Magenta";     Code = 095; },
  @{ Name = "Cyan";        Enum = "Cyan";        Code = 096; },
  @{ Name = "White";       Enum = "White";       Code = 097; }
) | %{
  $global:PSColors[ $_.Name ] = $_
}

# === Segments of the Prompt ==================================================

$global:PromptSegments = @{}

$global:PromptSegments[ "Emblem" ] = @{
  Name       = "Emblem";
  Background = $PSColors.Black.Code;
  Foreground = $PSColors.DarkCyan.Code;
  Blend      = "None";
  Render     = [scriptblock]{
    return $global:PromptSymbol
  }
}

$global:PromptSegments[ "GitBranch" ] = @{
  Name       = "GitBranch";
  Background = $PSColors.White.Code;
  Foreground = $PSColors.DarkCyan.Code;
  Blend      = "Right";
  Render     = [scriptblock]{
    $status = Get-GitStatus
    if ( $status -eq $null )
    {
      return ""
    }
    else
    {
      return (" {0} {1} " -f $Symbols.Powerline.GitBranch, (global:PoshGitRender $status) )
    }
  }
}

$global:PromptSegments[ "Path" ] = @{
  Name       = "Path";
  Background = $PSColors.DarkCyan.Code;
  Foreground = $PSColors.PSFore.Code;
  Blend      = "Right";
  Render     = [scriptblock]{
    return ( " {0} " -f $pwd.ProviderPath )
  }
}
  
# === Order the Segments ======================================================

$global:PromptSegments.Order = @(
  $PromptSegments["Emblem"],
  $PromptSegments["GitBranch"],
  $PromptSegments["Path"]
)

# =============================================================================

# Prompt rendering function
function global:PromptRender
{
  $retstr = ""
  for ( $i = 0; $i -lt $PromptSegments.Order.Count; $i++ )
  {
    # Capture current segment
    $segment = $PromptSegments.Order[$i]
    
    # Determine blend colors for end of segment
    $nextfg  = $PSColors.PSFore.Code
    $nextbg  = $PSColors.PSBack.Code
    if ( $i -lt ($PromptSegments.Order.Count-1) )
    {
      $nextfg = $PromptSegments.Order[$i+1].Foreground
      $nextbg = $PromptSegments.Order[$i+1].Background
    }

    # Render the string & check if anything resulted
    $fg = $segment.Foreground # Helper for render block
    $bg = $segment.Background # Helper for render block
    $str = & $segment.Render
    
    if ( $str.Length -gt 0 )
    {
    
      # Write the segment in current colors
      $retstr += ( SetColor        `
        -F $segment.Foreground     `
        -B $segment.Background ) + `
        $str

      # Determine blending character & colors
      $str = ""
      $blendfg  = $PSColors.PSFore.Code
      $blendbg  = $PSColors.PSBack.Code
      if ( $segment.Blend -eq "Right" )
      {
        if ( $segment.Background -eq $nextbg )
        {
          $str = $Symbols.Powerline.RightArrow
          $blendfg  = $segment.Foreground
          $blendbg  = $segment.Background
        }
        else
        {
          $str = $Symbols.Powerline.RightBlock
          $blendfg  = $segment.Background
          $blendbg  = $nextbg
        }
      }
      elseif ( $segment.Blend -eq "Left" )
      {
        if ( $segment.Background -eq $nextbg )
        {
          $str = $Symbols.Powerline.LeftArrow
          $blendfg  = $segment.Foreground
          $blendbg  = $segment.Background
        }
        else
        {
          $str = $Symbols.Powerline.LeftBlock
          $blendfg  = $segment.Background
          $blendbg  = $nextbg
        }
      }
      
      # Write the blending character, if any
      if ( $str -ne "" )
      {
        $retstr += (SetColor -F $blendfg -B $blendbg) + $str
      }
    }
  }
  if ( $retstr.Length -gt 0 )
  {
    # Unless the constructed string is empty, include a color
    # reset directive to clean up after any unruly segments
    $retstr += (SetGraphics 0)
  }
  
  return $retstr
}

function global:prompt
{
  return (global:PromptRender)
}
