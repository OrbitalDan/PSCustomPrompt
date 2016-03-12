# Colors.ps1
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



# Guarantee Settings Initialization
if ( $global:PSCPSettings -eq $null )
{
  $global:PSCPSettings = @{}
}
if ( $global:PSCPSettings.Raw -eq $null )
{
  $global:PSCPSettings.Raw = @{}
}



#=== Powershell Color Map Definitions ===============================

$global:PSColors             = @{}

# Indexed Mappings
# -------------------------------------------------------------------
# These will form a cross-reference system that maps
# the various ways of refering to color palette entries
# one to another, making it easy to convert systems.
$global:PSColors.ByName      = @{}
$global:PSColors.ByCode      = @{}
$global:PSColors.ByIndex     = @{}
$global:PSColors.ByAttribute = @{}
$global:PSColors.ByConcfg    = @{}

# Win32 Atribute Flags, as defined in Wincon.h
$b = 1; # FOREGROUND_BLUE
$g = 2; # FOREGROUND_GREEN
$r = 4; # FOREGROUND_RED
$i = 8; # FOREGROUND_INTENSITY

# The color mapping data
@(

  #          Name              ANSI Code       Index              Win32 Attribute Flags           
  #          ----              ---------       -----              ------------------------------  
  @{ Name = "Black";       Code = 030;  Index = 00;   Attribute = ( 0                          ); },
  @{ Name = "DarkRed";     Code = 031;  Index = 04;   Attribute = ( $r                         ); },
  @{ Name = "DarkGreen";   Code = 032;  Index = 02;   Attribute = (         $g                 ); },  
  @{ Name = "DarkYellow";  Code = 033;  Index = 06;   Attribute = ( $r -bor $g                 ); },
  @{ Name = "DarkBlue";    Code = 034;  Index = 01;   Attribute = (                 $b         ); },
  @{ Name = "DarkMagenta"; Code = 035;  Index = 05;   Attribute = ( $r         -bor $b         ); },
  @{ Name = "DarkCyan";    Code = 036;  Index = 03;   Attribute = (         $g -bor $b         ); },
  @{ Name = "Gray";        Code = 037;  Index = 07;   Attribute = ( $r -bor $g -bor $b         ); },
  @{ Name = "DarkGray";    Code = 090;  Index = 08;   Attribute = (                         $i ); },
  @{ Name = "Red";         Code = 091;  Index = 12;   Attribute = ( $r                 -bor $i ); },
  @{ Name = "Green";       Code = 092;  Index = 10;   Attribute = (         $g         -bor $i ); },
  @{ Name = "Yellow";      Code = 093;  Index = 14;   Attribute = ( $r -bor $g         -bor $i ); },
  @{ Name = "Blue";        Code = 094;  Index = 09;   Attribute = (                 $b -bor $i ); },
  @{ Name = "Magenta";     Code = 095;  Index = 13;   Attribute = ( $r         -bor $b -bor $i ); },
  @{ Name = "Cyan";        Code = 096;  Index = 11;   Attribute = (         $g -bor $b -bor $i ); },
  @{ Name = "White";       Code = 097;  Index = 15;   Attribute = ( $r -bor $g -bor $b -bor $i ); }

) | Sort-Object -Property {$_.Index} | %{

  # Cross-index the colors for ease of use
  $global:PSColors.ByName[      $_.Name      ] = $_
  $global:PSColors.ByCode[      $_.Code      ] = $_
  $global:PSColors.ByIndex[     $_.Index     ] = $_
  $global:PSColors.ByAttribute[ $_.Attribute ] = $_
}

$PSColors.PSFore = $PSColors.ByName.DarkYellow  # Powershell: Silver Foreground
$PSColors.PSBack = $PSColors.ByName.DarkMagenta # Powershell: Dark Blue Background

# Helper function for adding new maps to PSColors
function Add-PSCPColorExtension ([string]$Name, [hashtable]$Data)
{
  # Make sure all the keys we expect to see are present
  $validkeys = $true
  $PSColors.ByName.Values | %{ 
    $validkeys = $validkeys -and `
      $Data.ContainsKey( $_.Name )
  }

  # Also make sure there are exactly 16 of them  
  if ( $Data.Count -eq 16 -and $validkeys -and $Name -ne "" )
  {
    $global:PSColors["By$Name"] = @{}
    $Data.Keys | %{ 
    
      # Add extension to each color map entry
      $global:PSColors.ByName[$_].$Name = $Data[$_];
      
      # Add colors to index by the new property
      $global:PSColors["By$Name"][$Data[$_]] = $global:PSColors.ByName[$_]
    }
  }
}



#=== Terminal Code Helpers ==========================================

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



#=== Console Window Color Palette Management ========================



#(Get-WmiObject Win32_OperatingSystem).OSArchitecture # "64-bit"
#$global:PSCPSettings.Raw.ConsoleFontsKey = Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont"
#$global:PSCPSettings.Raw.ConsoleUserKey  = Get-Item "HKCU:\Console\Windows Powershell" # TODO: Manage 32/64 bits, other consoles



# Gets a specific RGB value for an indexed color in the palette 
function Get-ConsoleColor ( [int]$Index )
{
  if ( $Index -ge 00 -and
       $Index -le 15 )
  {
    $info     = [Win32.ConsoleScreenBufferInfoEx]::Create()
    $hConsole = [Win32.Kernel]::GetStdHandle( [Win32.StandardHandle]::StandardOutput )
    $success  = [Win32.Kernel]::GetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )
    if ( $success )
    {
      return [System.Drawing.Color]::FromARGB(
        $info.ColorTable[$Index].R,
        $info.ColorTable[$Index].G,
        $info.ColorTable[$Index].B)
    }
    else
    {
      Write-Error "Native method GetConsoleScreenBufferEx failed."
      return $null
    }
    
#    # Disassemble the registry value into RGB values.
#    # For reasons unknown, this is backwards to the way System.Drawing.Color
#    # stores a color in an Int32, so we have to disassemble it ourselves.
#    
#    $raw = $global:PSCPSettings.Raw.ConsoleUserKey.GetValue( "ColorTable{0:D2}" -f $Index )
#    
#    $r = ($raw                 ) %      256
#    $g = ($raw - ($r          )) %    65536
#    $b = ($raw - ($r + $g     )) % 16777216
#    #$a = ($raw - ($r + $g + $b))
#    
#    $r = $r /        1;
#    $g = $g /      256;
#    $b = $b /    65536;
#    #$a = $a / 16777216;
#    
#    return [System.Drawing.Color]::FromARGB( $r, $g, $b )
  }
  else
  {
    Write-Error "Index must be in the range 0-15."
    return $null
  }
}
Export-ModuleMember -Function Get-ConsoleColor



# Sets an indexed color in the palette to a specific RGB value
function Set-ConsoleColor ( `
  [int]$Index, `
  [Drawing.Color]$Color=[Drawing.Color]::Transparent, `
  [object[]]$RGB=$null )
{
  # Check index for correctness
  if ( $Index -ge 00 -and
       $Index -le 15 )
  {
    # Option 1: Color via System.Drawing.Color
    if ( $Color -ne $null -and `
         $Color -is [Drawing.Color] -and `
         $Color -ne [Drawing.Color]::Transparent )
    {
      # Copy values
      $r = $Color.R
      $g = $Color.G
      $b = $Color.B
    }
    # Option 2: Color via RGB values in an array
    elseif ( $RGB -ne $null )
    {
      # Extra verifications
      if ( $RGB.Count -eq 3 )
      {
        if ( $RGB[0] -ge   0 -and 
             $RGB[0] -le 255 -and 
             $RGB[1] -ge   0 -and 
             $RGB[1] -le 255 -and 
             $RGB[2] -ge   0 -and 
             $RGB[2] -le 255      )
        {
          # Copy values
          $r = $RGB[0]
          $g = $RGB[1]
          $b = $RGB[2]
        }
        else
        {
          Write-Error "An invalid RGB value was specified - values must be in the range 0-255."
          return
        }
      }
      else
      {
        Write-Error "An invalid RGB array was specified - it must contain 3 values in the range 0-255."
        return
      }
    }
    else
    {
      Write-Error "A valid new color must be supplied by either the Color or RGB flags."
      return
    }
    
    # Retrieve the live color palette
    $info     = [Win32.ConsoleScreenBufferInfoEx]::Create()
    $hConsole = [Win32.Kernel]::GetStdHandle( [Win32.StandardHandle]::StandardOutput )
    $success  = [Win32.Kernel]::GetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )

    if ( $success )
    {
      # Set the RGB color in the palette
      $temp = $info.ColorTable[$Index] # Something doesn't seem to be smart enough to allow
      $temp.R = $r                     # direct access to set sub-values on array members
      $temp.G = $g                     # just by using the indexer. As a work-around, store
      $temp.B = $b                     # a copy in a temp variable and then write it back
      $info.ColorTable[$Index] = $temp # to the array after modifying it.

      # For reasons that aren't clear, the window information reported by
      # GetConsoleScreenBufferInfoEx is 1 smaller (height & width) than
      # what's actually there.  You have to increase them by 1 before
      # passing it back to SetConsoleScreenBufferInfoEx, or the window
      # will shrink.
      $temp = $info.srWindow
      $temp.Right  += 1 
      $temp.Bottom += 1
      $info.srWindow = $temp
      
      # Save the changes to the live color palette
      $success  = [Win32.Kernel]::SetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )
      
      if (-not $success)
      {
        Write-Error "Native method SetConsoleScreenBufferEx failed. Color was not set."
        return
      }
    }
    else
    {
      Write-Error "Native method GetConsoleScreenBufferEx failed. Color was not retrieved."
      return
    }
    
#    # Re-assemble the RGB values into the format stored in the registry
#    # For reasons unknown, this is backwards to the way System.Drawing.Color
#    # stores a color in an Int32, so we have to assemble it ourselves.
#    $raw = ($b * 65536) + ($g * 256) + ($r * 1)
#    
#    # Open the subkey for writing and then edit it, cleanup behind ourselves
#    $keyname = "ColorTable{0:D2}" -f $Index
#    New-ItemProperty -Path "HKCU:\Console\Windows Powershell" `
#      -Name  $keyname     `
#      -Value $raw         `
#      -PropertyType DWORD `
#      -Force | Out-Null
  }
  else
  {
    Write-Error "Index must be in the range 0-15."
  }
}
Export-ModuleMember -Function Set-ConsoleColor



function Get-ColorPalette
{
  # Initialize return value
  $palette = @{}
  
  # Retrieve the live color palette
  $info     = [Win32.ConsoleScreenBufferInfoEx]::Create()
  $hConsole = [Win32.Kernel]::GetStdHandle( [Win32.StandardHandle]::StandardOutput )
  $success  = [Win32.Kernel]::GetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )

  if ( $success )
  {
    # Store the colors as System.Drawing.Color objects in the palette
    $global:PSColors.ByName.Values | %{
      $palette[ $_.Name ] = [System.Drawing.Color]::FromARGB(
        $info.ColorTable[$_.Index].R,
        $info.ColorTable[$_.Index].G,
        $info.ColorTable[$_.Index].B)
    }
    
    # Return the finished palette
    return $palette
  }
  else
  {
    Write-Error "Native method GetConsoleScreenBufferEx failed. Color was not retrieved."
    return $null
  }    
}
Export-ModuleMember -Function Get-ColorPalette



function Set-ColorPalette ( [hashtable]$Palette )
{
  # Retrieve the live color palette
  $info     = [Win32.ConsoleScreenBufferInfoEx]::Create()
  $hConsole = [Win32.Kernel]::GetStdHandle( [Win32.StandardHandle]::StandardOutput )
  $success  = [Win32.Kernel]::GetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )

  if ( $success )
  {
    # Store the colors as System.Drawing.Color objects in the palette
    $global:PSColors.ByName.Values | %{
    
      if ( $Palette.ContainsKey( $_.Name ) )
      {
        # Set the RGB color in the palette
        $temp = $info.ColorTable[$_.Index] # Something doesn't seem to be smart enough to allow
        $temp.R = $Palette[$_.Name].R      # direct access to set sub-values on array members
        $temp.G = $Palette[$_.Name].G      # just by using the indexer. As a work-around, store
        $temp.B = $Palette[$_.Name].B      # a copy in a temp variable and then write it back
        $info.ColorTable[$_.Index] = $temp # to the array after modifying it.
      }  
    }

    # For reasons that aren't clear, the window information reported by
    # GetConsoleScreenBufferInfoEx is 1 smaller (height & width) than
    # what's actually there.  You have to increase them by 1 before
    # passing it back to SetConsoleScreenBufferInfoEx, or the window
    # will shrink.
    $temp = $info.srWindow
    $temp.Right  += 1 
    $temp.Bottom += 1
    $info.srWindow = $temp
    
    # Save the changes to the live color palette
    $success  = [Win32.Kernel]::SetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )
    
    if (-not $success)
    {
      Write-Error "Native method SetConsoleScreenBufferEx failed. Color was not set."
      return
    }
  }
  else
  {
    Write-Error "Native method GetConsoleScreenBufferEx failed. Color was not retrieved."
    return
  }  
}
Export-ModuleMember -Function Set-ColorPalette



function Get-ColorConfiguration
{
  $config = @{}
  
  # Primary and Secondary Foreground/Background are Console Attributes
  $config.Screen = @{}
  $config.Popup  = @{}
  
  # Retrieve the live color palette
  $info     = [Win32.ConsoleScreenBufferInfoEx]::Create()
  $hConsole = [Win32.Kernel]::GetStdHandle( [Win32.StandardHandle]::StandardOutput )
  $success  = [Win32.Kernel]::GetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )

  if ( $success )
  {
    # Split the primary (screen) attributes into foreground and background
    $fg =   $info.wAttributes        %  16
    $bg = (($info.wAttributes - $fg) % 256) / 16 # Same flags, just shifted over a half-byte
    $config.Screen.Foreground = $PSColors.ByAttribute[ $fg ].Name
    $config.Screen.Background = $PSColors.ByAttribute[ $bg ].Name

    # Split the secondary (popup) attributes into foreground and background
    $fg =   $info.wPopupAttributes        %  16
    $bg = (($info.wPopupAttributes - $fg) % 256) / 16 # Same flags, just shifted over a half-byte
    $config.Popup.Foreground = $PSColors.ByAttribute[ $fg ].Name
    $config.Popup.Background = $PSColors.ByAttribute[ $bg ].Name
  }
  else
  {
    Write-Error "Native method GetConsoleScreenBufferEx failed. Color configuration was not retrieved."
    return $null
  }
  
  # Collect other screen colors' information about what color from the palette to use
  @("Error","Warning","Debug","Verbose","Progress") | %{
    $Type = $_
    $config[$Type] = @{
      Foreground = $global:PSCPSettings.Themes.Powershell.Configuration[$Type].Foreground;
      Background = $global:PSCPSettings.Themes.Powershell.Configuration[$Type].Background;
    }
    if ( $Host -ne $null -and
         $Host.PrivateData -ne $null -and
         $Host.PrivateData -is [PSObject] )
    {
      # Output type foreground
      if ($Host.PrivateData.$TypeForegroundColor -ne $null -and
          $Host.PrivateData.$TypeForegroundColor -is [System.Drawing.ConsoleColor])
      {
        $config[$Type].Foreground = ($Host.PrivateData.$TypeForegroundColor).ToString()
      }
      
      # Output type background
      if ($Host.PrivateData.$TypeBackgroundColor -ne $null -and
          $Host.PrivateData.$TypeBackgroundColor -is [System.Drawing.ConsoleColor])
      {
        $config[$Type].Background = ($Host.PrivateData.$TypeBackgroundColor).ToString()
      }
    }
  }
  
  # Return the finished configuration
  return $config
}
Export-ModuleMember -Function Get-ColorConfiguration



function Set-ColorConfiguration ([hashtable]$Configuration)
{ 
  # Retrieve the live color palette
  $info     = [Win32.ConsoleScreenBufferInfoEx]::Create()
  $hConsole = [Win32.Kernel]::GetStdHandle( [Win32.StandardHandle]::StandardOutput )
  $success  = [Win32.Kernel]::GetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )

  if ( $success )
  {
    # Combine the primary (screen) attributes
    $info.wAttributes = `
       $PSColors.ByName[ $Configuration.Screen.Foreground ].Attribute + `
      ($PSColors.ByName[ $Configuration.Screen.Background ].Attribute * 16)
      
    # Combine the secondary (popup) attributes
    $info.wPopupAttributes = `
       $PSColors.ByName[ $Configuration.Popup.Foreground ].Attribute + `
      ($PSColors.ByName[ $Configuration.Popup.Background ].Attribute * 16)
    
    # For reasons that aren't clear, the window information reported by
    # GetConsoleScreenBufferInfoEx is 1 smaller (height & width) than
    # what's actually there.  You have to increase them by 1 before
    # passing it back to SetConsoleScreenBufferInfoEx, or the window
    # will shrink.
    $temp = $info.srWindow
    $temp.Right  += 1 
    $temp.Bottom += 1
    $info.srWindow = $temp
    
    # Save the changes to the live color palette
    $success  = [Win32.Kernel]::SetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )
      
    if ( -not $success )
    {
      Write-Error "Native method SetConsoleScreenBufferEx failed. Color configuration was not applied."
      return
    }
  }
  else
  {
    Write-Error "Native method GetConsoleScreenBufferEx failed. Color configuration was not applied."
    return
  }
  
  # Set other screen colors' information about what color from the palette to use
  @("Error","Warning","Debug","Verbose","Progress") | %{
    $Type = $_
    $Configuration[$Type] = @{
      Foreground = $global:PSCPSettings.Themes.Powershell.Configuration[$Type].Foreground;
      Background = $global:PSCPSettings.Themes.Powershell.Configuration[$Type].Background;
    }
    if ( $Host -ne $null -and
         $Host.PrivateData -ne $null -and
         $Host.PrivateData -is [PSObject] )
    {
      # Apply type foreground
      if ($Host.PrivateData.$TypeForegroundColor -ne $null -and
          $Host.PrivateData.$TypeForegroundColor -is [System.Drawing.ConsoleColor])
      {
        $Host.PrivateData.$TypeForegroundColor = [System.ConsoleColor]::($Configuration[$Type].Foreground)
      }
      
      # Apply type background
      if ($Host.PrivateData.$TypeBackgroundColor -ne $null -and
          $Host.PrivateData.$TypeBackgroundColor -is [System.Drawing.ConsoleColor])
      {
        $Host.PrivateData.$TypeBackgroundColor = [System.ConsoleColor]::($Configuration[$Type].Background)
      }
    }
  }
}
Export-ModuleMember -Function Set-ColorConfiguration
