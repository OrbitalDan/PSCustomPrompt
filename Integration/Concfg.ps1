# Integration\Concfg.ps1
#
# Integration with the concfg project to allow importing of concfg-compatible themes.
# concfg on github: https://github.com/lukesampson/concfg
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



#=== Concfg Color Definitions =======================================

# Extend the Color Map to include information about what concfg
# calls the various colors
#
Add-PSCPColorExtension -Name "Concfg" -Data `
@{
# Name          Concfg Name
# -----------   ---------------
  Black       = "black";
  DarkRed     = "dark_red";
  DarkGreen   = "dark_green";
  DarkYellow  = "dark_yellow";
  DarkBlue    = "dark_blue";
  DarkMagenta = "dark_magenta";
  DarkCyan    = "dark_cyan";
  Gray        = "gray";
  DarkGray    = "dark_gray";
  Red         = "red";
  Green       = "green";
  Yellow      = "yellow";
  Blue        = "blue";
  Magenta     = "magenta";
  Cyan        = "cyan";
  White       = "white";
}



#=== Concfg Theme Import & Export Functions =========================

function Import-ConcfgTheme
{
  Param(
    [string]$Path = "",
    [string]$Uri  = "",
    [string]$Name = ""
  )
  
  $newname = $Name
  
  if ( $Path -ne "" )
  {
    if ( Test-Path $Path )
    {
      $json = Get-Content $Path
      
      if ( $Name -eq "" )
      {
        $newname = (Get-Item $Path).BaseName
      }
    }
    else
    {
      Write-Error "The specified path `'$Path`' is not valid."
    }
  }
  elseif( $Uri -eq "" )
  {
    # TODO
    Write-Error "Load from URI is not yet implemented.  Coming soon!"
    return
  }
  else
  {
    Write-Error "A valid path or uri must be specified."
    return
  }  
  
  # Clone the default theme as a base, Concfg themes don't
  # contain all color configuration information, so we'll
  # fill those in with the defaults.
  $newtheme = New-Theme
  
  # Name comes from either the parameter or the file name
  $newtheme.Name = $newname
  
  # Read the JSON into an object
  $obj = Get-Content $Path | ConvertFrom-Json
  
  # Copy palette colors from the JSON object
  $PSColors.ByConcfg.Values | %{
    $newtheme.Palette[$_.Name] = [System.Drawing.ColorTranslator]::FromHtml( $obj.($_.Concfg) )
  }
  
  # Set the screen & popup color configurations
  $sc = $obj.screen_colors.Split(',')
  $newtheme.Configuration.Screen.Foreground = $PSColors.ByConcfg[ $sc[0] ].Name
  $newtheme.Configuration.Screen.Background = $PSColors.ByConcfg[ $sc[1] ].Name
  
  $pc = $obj.popup_colors.Split(',')
  $newtheme.Configuration.Popup.Foreground = $PSColors.ByConcfg[ $pc[0] ].Name
  $newtheme.Configuration.Popup.Background = $PSColors.ByConcfg[ $pc[1] ].Name
    
  # Add the imported theme to the list of available themes
  $global:PSCPSettings.Themes[ $newtheme.Name ] = $newtheme 
}
Export-ModuleMember -Function Import-ConcfgTheme



# TODO
function Export-ConcfgTheme
{
}