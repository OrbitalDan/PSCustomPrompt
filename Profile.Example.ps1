# Example Profile for PSCustomPrompt

# Have to import the module first!
Import-Module PSCustomPrompt

# This is how we build the default custom prompt, or
# for that matter any prompt composed of ready-made
# segments.
$global:PSCPSettings.Order = @(
  $PSCPSettings.Segments["Emblem"],
  $PSCPSettings.Segments["GitBranch"],
  $PSCPSettings.Segments["Path"]
)

# Although I picked out some nice symbols from the
# upper ranges of unicode to include by default,
# maybe you'd like to use a different one?  You can
# do that!
$Symbols.Custom.Euro = "€";
Set-PSCustomPromptEmblem Euro

# Want to change how a segment works?  No problem!
# I use this to cover up my username when making
# screenshot for security:
$PSCPSettings.Segments.Path.Render = [scriptblock]{
    return ( " {0} " -f ($pwd.ProviderPath.Replace($Env:USERNAME,"OrbitalDan")) )
}

# Don't like the color?  That can be changed too!
$PSCPSettings.Segments.GitBranch.Background = $PSColors.DarkGray.Code

# Note: DarkYellow and DarkMagenta are usually set to PowerShell
# foreground and background, respectively.

# Want a time stamp?  No problemo!
# First, we create a new segment for the date
$global:PSCPSettings.Segments[ "Date" ] = @{
  Name       = "Date";
  Background = $PSColors.Black.Code;
  Foreground = $PSColors.DarkCyan.Code;
  Blend      = "Right";
  Render     = [scriptblock]{
    return ( " {0} " -f [DateTime]::Now )
  }
}

# Then, we insert it into the rendering order
$global:PSCPSettings.Order = @(
  $PSCPSettings.Segments["Emblem"],
  $PSCPSettings.Segments["Date"],   # <-- Let's insert it at the far left
  $PSCPSettings.Segments["GitBranch"],
  $PSCPSettings.Segments["Path"]
)

# And now, let's make the emblem show a divider into that!
$PSCPSettings.Segments.Emblem.Blend = "Right"

# You probably don't realistically want all of this all the time, but these
# will hopefully give you some ideas!
