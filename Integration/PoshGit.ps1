function Get-PoshGitRender( $status )
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
    $retstr += (Set-TerminalColor -F $PSColors.ByName[$branchStatusForegroundColor.ToString()].Code) + `
      $branchName
      
    if ($branchStatusSymbol)
    {
      $retstr += (Set-TerminalColor -F $PSColors.ByName[$branchStatusForegroundColor.ToString()].Code) + `
        (" {0}" -f $branchStatusSymbol)
    }

    if($s.EnableFileStatus -and $status.HasIndex)
    {
      $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.BeforeIndexForegroundColor.ToString()].Code) + `
        $s.BeforeIndexText

      if($s.ShowStatusWhenZero -or $status.Index.Added)
      {
        $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.IndexForegroundColor.ToString()].Code) + `
          " +$($status.Index.Added.Count)"
      }
      
      if($s.ShowStatusWhenZero -or $status.Index.Modified)
      {
        $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.IndexForegroundColor.ToString()].Code) + `
          " ~$($status.Index.Modified.Count)"
      }
      
      if($s.ShowStatusWhenZero -or $status.Index.Deleted)
      {
        $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.IndexForegroundColor.ToString()].Code) + `
          " -$($status.Index.Deleted.Count)"
      }
      
      if ($status.Index.Unmerged)
      {
        $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.IndexForegroundColor.ToString()].Code) + `
          " !$($status.Index.Unmerged.Count)"
      }
      
      if($status.HasWorking)
      {
        $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.DelimForegroundColor.ToString()].Code) + `
          $s.DelimText
      }
    }

    if($s.EnableFileStatus -and $status.HasWorking)
    {
      if($s.ShowStatusWhenZero -or $status.Working.Added)
      {
        $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.WorkingForegroundColor.ToString()].Code) + `
          " +$($status.Working.Added.Count)"
      }
      
      if($s.ShowStatusWhenZero -or $status.Working.Modified)
      {
        $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.WorkingForegroundColor.ToString()].Code) + `
          " ~$($status.Working.Modified.Count)"
      }
      
      if($s.ShowStatusWhenZero -or $status.Working.Deleted)
      {
        $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.WorkingForegroundColor.ToString()].Code) + `
          " -$($status.Working.Deleted.Count)"
      }
      
      if ($status.Working.Unmerged)
      {
        $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.WorkingForegroundColor.ToString()].Code) + `
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
      $retstr += (Set-TerminalColor -F $PSColors.ByName[$localStatusForegroundColor.ToString()].Code) + `
        (" {0}" -f $localStatusSymbol)
    }
    
    if ($s.EnableStashStatus -and ($status.StashCount -gt 0))
    {
      $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.BeforeStashForegroundColor.ToString()].Code) + `
        $s.BeforeStashText
      $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.StashForegroundColor.ToString()].Code      ) + `
        $status.StashCount
      $retstr += (Set-TerminalColor -F $PSColors.ByName[$s.AfterStashForegroundColor.ToString()].Code ) + `
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
Export-ModuleMember -Function Get-PoshGitRender

# Create a prompt segment to display the Git status information
$global:PSCPSettings.Segments[ "GitBranch" ] = @{
  Name       = "GitBranch";
  Background = $PSColors.ByName.White.Code;
  Foreground = $PSColors.ByName.DarkCyan.Code;
  Blend      = "Right";
  Render     = [scriptblock]{
    $status = Get-GitStatus
    if ( $status -eq $null )
    {
      return ""
    }
    else
    {
      return (" {0} {1} " -f $Symbols.Powerline.GitBranch, (Get-PoshGitRender $status) )
    }
  }
}