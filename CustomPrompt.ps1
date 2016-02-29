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

# Helper function to build escape sequences. Codes 30-37 select
# foreground color (0-7), codes 40-47 select background color
# (0-7).  The codes correspond to the first eight colors in the
# console host properties dialog, and the first eight colors in
# the System.ConsoleColor enumeration.
function SetGraphics([int[]]$m)     { 
  "$([char]0x1b)[$([String]::Join(';',($m|%{$_.ToString()})))m"; 
}

# Create a template for the prompt so that we don't waste time
# reconstructing it every command
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

# Prompt rendering function
function global:prompt
{
  return ( $PromptTemplate -f @( $global:PromptSymbol, $pwd.ProviderPath ) )
}