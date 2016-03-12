# Themes.ps1
#
# Functions to manage coherent sets of colors in Powershell
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



#=== Color Themes ===================================================

$global:PSCPSettings.Themes = @{}

# A theme contains two main parts: the color palette and the configuration
$global:PSCPSettings.Themes["Powershell"] = @{

  # The theme must be named
  Name        = "Powershell";

  # The color palette is a hashtable mapping the names of the values in
  # the System.ConsoleColor enum to their actual System.Drawing.Color
  # values, as presented in the console properties dialog.
  Palette     = @{
  # Name                                             R    G    B
  # -----------                                     ---  ---  ---
    Black       = [System.Drawing.Color]::FromARGB( 000, 000, 000);
    DarkBlue    = [System.Drawing.Color]::FromARGB( 000, 000, 128);
    DarkGreen   = [System.Drawing.Color]::FromARGB( 000, 128, 000);
    DarkCyan    = [System.Drawing.Color]::FromARGB( 000, 128, 128);
    DarkRed     = [System.Drawing.Color]::FromARGB( 128, 000, 000);
    DarkMagenta = [System.Drawing.Color]::FromARGB( 001, 036, 086);
    Gray        = [System.Drawing.Color]::FromARGB( 238, 237, 240);
    DarkYellow  = [System.Drawing.Color]::FromARGB( 192, 192, 192);
    DarkGray    = [System.Drawing.Color]::FromARGB( 128, 128, 128);
    Blue        = [System.Drawing.Color]::FromARGB( 000, 000, 255);
    Green       = [System.Drawing.Color]::FromARGB( 000, 255, 000);
    Cyan        = [System.Drawing.Color]::FromARGB( 000, 255, 255);
    Red         = [System.Drawing.Color]::FromARGB( 255, 000, 000);
    Magenta     = [System.Drawing.Color]::FromARGB( 255, 000, 255);
    Yellow      = [System.Drawing.Color]::FromARGB( 255, 255, 000);
    White       = [System.Drawing.Color]::FromARGB( 255, 255, 255);
  }

  # The configuation is a hashtable that maps various display element names
  # to hashtables which each contain names of foreground and background
  # colors selected. The configuration allows more complex mapping of colors
  # to display text output by cmdlets.
  Configuration = @{
  # Name                        Foreground                  Background
  # --------                    -----------                 -----------
    Screen   = @{ Foreground = "DarkYellow";  Background = "DarkMagenta"; };
    Popup    = @{ Foreground = "DarkCyan";    Background = "White";       };
    Error    = @{ Foreground = "Red";         Background = "Black";       };
    Warning  = @{ Foreground = "Yellow";      Background = "Black";       };
    Debug    = @{ Foreground = "Yellow";      Background = "Black";       };
    Verbose  = @{ Foreground = "Yellow";      Background = "Black";       };
    Progress = @{ Foreground = "Yellow";      Background = "DarkCyan";    };
  }
}

$global:PSCPSettings.Themes["Custom"] = @{

  Name        = "Custom";
  
  Palette     = @{
    #                                                R    G    B
    #                                               ---  ---  ---
    Black       = [System.Drawing.Color]::FromARGB( 000, 000, 000);
    DarkBlue    = [System.Drawing.Color]::FromARGB( 000, 000, 128);
    DarkGreen   = [System.Drawing.Color]::FromARGB( 000, 128, 000);
    DarkCyan    = [System.Drawing.Color]::FromARGB( 000, 090, 135);
    DarkRed     = [System.Drawing.Color]::FromARGB( 128, 000, 000);
    DarkMagenta = [System.Drawing.Color]::FromARGB( 001, 036, 086);
    Gray        = [System.Drawing.Color]::FromARGB( 238, 237, 240);
    DarkYellow  = [System.Drawing.Color]::FromARGB( 192, 192, 192);
    DarkGray    = [System.Drawing.Color]::FromARGB( 128, 128, 128);
    Blue        = [System.Drawing.Color]::FromARGB( 000, 000, 255);
    Green       = [System.Drawing.Color]::FromARGB( 000, 255, 000);
    Cyan        = [System.Drawing.Color]::FromARGB( 000, 255, 255);
    Red         = [System.Drawing.Color]::FromARGB( 255, 000, 000);
    Magenta     = [System.Drawing.Color]::FromARGB( 255, 000, 255);
    Yellow      = [System.Drawing.Color]::FromARGB( 255, 255, 000);
    White       = [System.Drawing.Color]::FromARGB( 255, 255, 255);
  }
  
  Configuration = @{
    #                           Foreground                  Background
    #                           -----------                 -----------
    Screen   = @{ Foreground = "DarkYellow";  Background = "DarkMagenta"; };
    Popup    = @{ Foreground = "DarkCyan";    Background = "White";       };
    Error    = @{ Foreground = "Red";         Background = "Black";       };
    Warning  = @{ Foreground = "Yellow";      Background = "Black";       };
    Debug    = @{ Foreground = "Yellow";      Background = "Black";       };
    Verbose  = @{ Foreground = "Yellow";      Background = "Black";       };
    Progress = @{ Foreground = "Yellow";      Background = "DarkCyan";    };
  }
}



function Get-CurrentTheme ( [string]$Name )
{
  # TODO: This needs some more safety checks
  @{
    Name          = $Name;
    Palette       = Get-ColorPalette;
    Configuration = Get-ColorConfiguration;
  }
}
Export-ModuleMember -Function Get-CurrentTheme



function Set-CurrentTheme ( [hashtable]$Theme )
{
  # TODO: This needs some more safety checks
  Set-ColorPalette       $Theme.Palette
  Set-ColorConfiguration $Theme.Configuration
  Write-Output "Theme applied.  You may need to clear the host to see the changes."
}
Export-ModuleMember -Function Set-CurrentTheme



function Set-NamedTheme ( [string]$Name )
{
  if ( $global:PSCPSettings.Themes.ContainsKey( $Name ) )
  {
    Set-CurrentTheme -Theme $global:PSCPSettings.Themes[$Name]
  }
  else
  {
    Write-Error "Could not find theme named `'$Name `' in `$PSCPSettings.Themes"
  }
}
Export-ModuleMember -Function Set-NamedTheme



function Copy-Theme ( [hashtable]$Theme )
{
  return @{
    Name = $Theme.Name
    Palette = @{
      Black       = $Theme.Palette.Black      ;
      DarkBlue    = $Theme.Palette.DarkBlue   ;
      DarkGreen   = $Theme.Palette.DarkGreen  ;
      DarkCyan    = $Theme.Palette.DarkCyan   ;
      DarkRed     = $Theme.Palette.DarkRed    ;
      DarkMagenta = $Theme.Palette.DarkMagenta;
      Gray        = $Theme.Palette.Gray       ;
      DarkYellow  = $Theme.Palette.DarkYellow ;
      DarkGray    = $Theme.Palette.DarkGray   ;
      Blue        = $Theme.Palette.Blue       ;
      Green       = $Theme.Palette.Green      ;
      Cyan        = $Theme.Palette.Cyan       ;
      Red         = $Theme.Palette.Red        ;
      Magenta     = $Theme.Palette.Magenta    ;
      Yellow      = $Theme.Palette.Yellow     ;
      White       = $Theme.Palette.White      ;
    }
    Configuration = @{
      Screen = @{
        Foreground = $Theme.Screen.Foreground;
        Background = $Theme.Screen.Background;
      }
      Popup = @{
        Foreground = $Theme.Popup.Foreground;
        Background = $Theme.Popup.Background;
      }
      Error = @{
        Foreground = $Theme.Error.Foreground;
        Background = $Theme.Error.Background;
      }
      Warning = @{
        Foreground = $Theme.Warning.Foreground;
        Background = $Theme.Warning.Background;
      }
      Debug = @{
        Foreground = $Theme.Debug.Foreground;
        Background = $Theme.Debug.Background;
      }
      Verbose = @{
        Foreground = $Theme.Verbose.Foreground;
        Background = $Theme.Verbose.Background;
      }
      Progress = @{
        Foreground = $Theme.Progress.Foreground;
        Background = $Theme.Progress.Background;
      }
    }
  }
}
Export-ModuleMember -Function Copy-Theme



function New-Theme
{
  return ( Copy-Theme -Theme $global:PSCPSettings.Themes.Powershell )
}
Export-ModuleMember -Function New-Theme



function Import-Theme ( [string]$Path, [string]$Type )
{
  # TODO
}
Export-ModuleMember -Function Import-Theme



function Export-Theme ( [string]$Path, [string]$Type )
{
  # TODO
}
Export-ModuleMember -Function Export-Theme



