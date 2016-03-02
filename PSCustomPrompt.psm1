# PSCustomPrompt.psm1
#
# Makes the PowerShell prompt look just a little bit nicer. :)
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



# Terminal code enabling code courtesy Oisin Grehan
# http://www.nivot.org/blog/post/2016/02/04/Windows-10-TH2-%28v1511%29-Console-Host-Enhancements
function Enable-TerminalCodes
{
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



# Prompt rendering function
function Get-PSCustomPromptRender
{
  $retstr = ""
  for ( $i = 0; $i -lt $PSCPSettings.Order.Count; $i++ )
  {
    # Capture current segment
    $segment = $PSCPSettings.Order[$i]
    
    # Determine blend colors for end of segment
    $nextfg  = $PSColors.PSFore.Code
    $nextbg  = $PSColors.PSBack.Code
    if ( $i -lt ($PSCPSettings.Order.Count-1) )
    {
      $nextfg = $PSCPSettings.Order[$i+1].Foreground
      $nextbg = $PSCPSettings.Order[$i+1].Background
    }

    # Render the string & check if anything resulted
    $fg = $segment.Foreground # Helper for render block
    $bg = $segment.Background # Helper for render block
    $str = & $segment.Render
    
    if ( $str.Length -gt 0 )
    {
    
      # Write the segment in current colors
      $retstr += ( Set-TerminalColor        `
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
        $retstr += (Set-TerminalColor -F $blendfg -B $blendbg) + $str
      }
    }
  }
  if ( $retstr.Length -gt 0 )
  {
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
