# Segments.ps1
#
# Initialize the library of available prompt segments, and add a few default ones.
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

# The global location where segments available to for prompt construction are stored
$global:PSCPSettings.Segments = @{}

# The global location where the order of segments to be displayed is stored
$global:PSCPSettings.Order = @()

# The default segment displays the current location, creating a similar appearance
# to the default PowerShell prompt.
$global:PSCPSettings.Segments[ "Path" ] = @{
  Name       = "Path";
  Background = $PSColors.ByName.DarkCyan.Code;
  Foreground = $PSColors.PSFore.Code;
  Blend      = "Right";
  Render     = [scriptblock]{
    return ( " {0} " -f $pwd.ProviderPath )
  }
}