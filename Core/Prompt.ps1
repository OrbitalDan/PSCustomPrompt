# Prompt.ps1
#
# Main Prompt functionality.
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



# Guarantee Settings Initialization
if ( $global:PSCPSettings -eq $null )
{
  $global:PSCPSettings = @{}
}



# Terminal code enabling code courtesy Oisin Grehan
# http://www.nivot.org/blog/post/2016/02/04/Windows-10-TH2-%28v1511%29-Console-Host-Enhancements
function Enable-TerminalCodes
{
  $h = [Win32.Kernel]::GetStdHandle(-11) #  stdout
  $m = 0
  $success = [Win32.Kernel]::GetConsoleMode($h, [ref]$m)
  $m = $m -bor 4 # undocumented flag to enable ansi/vt100
  $success = [Win32.Kernel]::SetConsoleMode($h, $m)
}



$script:PSOriginalSettings = @{}



# Enable the PSCustomPrompt module
function Enable-PSCustomPrompt
{
  # Set UTF8 Encoding so that all the extended charaters from fonts are available
  $script:PSOriginalSettings.OutputEncoding = $global:OutputEncoding
  $global:OutputEncoding = [System.Text.Encoding]::UTF8
  $script:PSOriginalSettings.InputEncoding  = $global:InputEncoding
  $global:InputEncoding  = [System.Text.Encoding]::UTF8
  
  # Turn on terminal code processing in the Console Host
  # TODO: Can we check for this before we do it?
  Enable-TerminalCodes
  
  # Override the prompt function
  $script:PSOriginalSettings.Prompt = (Get-Item function:prompt).Definition  
  Set-Item -Path function:global:prompt -Value { Get-PSCustomPromptRender }
}
Export-ModuleMember -Function Enable-PSCustomPrompt



# Disable the PSCustomPrompt module and restore overwritten settings
function Disable-PSCustomPrompt
{
  # Test for validity before we try to restore anything
  if ( $script:PSOriginalSettings -ne $null -and
       $script:PSOriginalSettings -is [hashtable] )
  {
    # Restore the prompt function
    if ( $script:PSOriginalSettings.Prompt -ne $null )
    {
      Set-Item -Path function:global:prompt -Value ( $script:PSOriginalSettings.Prompt )
    }
  
    # TODO: Is it even possible to disable terminal codes? Is it wise?
    
    # Restore Input Encoding
    if ( $script:PSOriginalSettings.InputEncoding -ne $null )
    {
      $global:InputEncoding  = $script:PSOriginalSettings.InputEncoding
    }
    
    # Restore Output Encoding
    if ( $script:PSOriginalSettings.OutputEncoding -ne $null )
    {
      $global:OutputEncoding = $script:PSOriginalSettings.OutputEncoding
    }
  }  
}
Export-ModuleMember -Function Disable-PSCustomPrompt



# Render a blend character(s) string
function Get-PromptBlendString
{
  param(
    [string]$Direction,
    [int]$BGLeft,
    [int]$BGRight,
    [int]$FGLeft,
    [int]$FGRight
  )
  
  $retstr = ""
  
  # Default the blending colors
  $blend    = ""
  $blendfg  = $PSColors.PSFore.Code
  $blendbg  = $PSColors.PSBack.Code

  # Determine blending character & colors
  if ( $Direction -eq "Right" )
  {
    if ( $BGLeft -eq $BGRight )
    {
      $blend    = $Symbols.Powerline.RightArrow
      $blendfg  = $FGLeft # TODO: Use foreground of segment to left or right?
      $blendbg  = $BGRight
    }
    else
    {
      $blend    = $Symbols.Powerline.RightBlock
      $blendfg  = $BGLeft
      $blendbg  = $BGRight
    }
  }
  elseif ( $Direction -eq "Left" )
  {
    if ( $BGLeft -eq $BGRight )
    {
      $blend    = $Symbols.Powerline.LeftArrow
      $blendfg  = $FGLeft # TODO: Use foreground of segment to left or right?
      $blendbg  = $BGRight
    }
    else
    {
      $blend    = $Symbols.Powerline.LeftBlock
      $blendfg  = $BGLeft
      $blendbg  = $BGRight
    }
  }
  
  # Write the blending character, if any
  if ( $blend -ne "" )
  {
    $retstr += (Set-TerminalColor -F $blendfg -B $blendbg) + $blend
  } 
  
  return $retstr
}



# Prompt rendering function
function Get-PSCustomPromptRender
{
  # Initialize return string
  $retstr = ""
  
  # Default the previous colors
  $prevfg   = $PSColors.PSFore.Code
  $prevbg   = $PSColors.PSBack.Code
  $prevmode = "None"
  
  # Evaulate each segment
  for ( $i = 0; $i -lt $PSCPSettings.Order.Count; $i++ )
  {
    # Capture current segment
    $segment = $PSCPSettings.Order[$i]
    if ( $segment -ne $null )
    {
      # Helpers for render block
      $_  = $segment
      $fg = $segment.Foreground
      $bg = $segment.Background
      
      # Render the string & check if anything resulted
      $str = ""
      if ( $segment.Render -ne $null -and
           $segment.Render -is [scriptblock] )
      {
        $str = & $segment.Render
      }

      # Check if anything was produced - if not, skip the segment
      if ( $str -ne $null    -and `
           $str -is [string] -and `
           $str.Length -gt 0 )
      {
        # Create the segment blend
        $blend = Get-PromptBlendString   `
          -Direction $prevmode           `
          -FGLeft    $prevfg             `
          -BGLeft    $prevbg             `
          -FGRight   $segment.Foreground `
          -BGRight   $segment.Background
        
        # Write the blending character, if any
        if ( $blend -ne "" )
        {
          $retstr += (Set-TerminalColor -F $blendfg -B $blendbg) + $blend
        }    
      
        # Write the segment in current colors
        $retstr += ( Set-TerminalColor `
          -F $segment.Foreground       `
          -B $segment.Background ) +   `
          $str

        # Save the blending information of current segment
        $prevfg   = $segment.Foreground
        $prevbg   = $segment.Background
        $prevmode = $segment.Blend
      }
    }
  }
  
  if ( $retstr.Length -gt 0 )
  {
    # Create the segment blend
    $blend = Get-PromptBlendString     `
      -Direction $prevmode             `
      -FGLeft    $prevfg               `
      -BGLeft    $prevbg               `
      -FGRight   $PSColors.PSFore.Code `
      -BGRight   $PSColors.PSBack.Code
    $retstr += $blend

    # Unless the constructed string is empty, include a color
    # reset directive to clean up after any unruly segments
    $retstr += (Set-TerminalGraphics 0)
  }
  
  return $retstr
}
Export-ModuleMember -Function Get-PSCustomPromptRender



# Default prompt, so that it works out of the box
$global:PSCPSettings.Order = @(
  $PSCPSettings.Segments["Emblem"],
  $PSCPSettings.Segments["GitBranch"],
  $PSCPSettings.Segments["Path"]
)



# Enabled by default
Enable-PSCustomPrompt
