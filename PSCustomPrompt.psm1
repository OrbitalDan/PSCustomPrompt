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

# Save the value of the module root, as $PSScriptRoot will vary with each script invocation
$ModuleRoot = $PSScriptRoot

# Load all core files except the prompt
. $ModuleRoot\Core\Native.ps1
. $ModuleRoot\Core\Colors.ps1
. $ModuleRoot\Core\Themes.ps1
. $ModuleRoot\Core\Segments.ps1
. $ModuleRoot\Core\Symbols.ps1

# Load all external integrations
. $ModuleRoot\Integration\PoshGit.ps1
. $ModuleRoot\Integration\Concfg.ps1

# Load the main prompt
. $ModuleRoot\Core\Prompt.ps1