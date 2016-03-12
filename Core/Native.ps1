# Native.ps1
#
# Imports required native functions from Windows API
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

# This is the lazy way to do it: Dump all required types into one
# monolithic C# fragment so that nothing has to be cross-referenced
# after the fact.

Add-Type -Language CSharp -TypeDefinition @"

using System;
using System.Runtime.InteropServices;

namespace Win32
{
  // StartupInfo
  // ------------------------------------------------------------
  // Contains information about the context in which the process
  // was started.
  //
  // https://msdn.microsoft.com/en-us/library/ms686331.aspx
  // http://www.pinvoke.net/default.aspx/Structures/STARTUPINFO.html
  //
  [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
  public struct StartupInfo
  {
    public uint   cb;
    public string lpReserved;
    public string lpDesktop;
    public string lpTitle;
    public uint   dwX;
    public uint   dwY;
    public uint   dwXSize;
    public uint   dwYSize;
    public uint   dwXCountChars;
    public uint   dwYCountChars;
    public uint   dwFillAttribute;
    public uint   dwFlags;
    public ushort wShowWindow;
    public ushort cbReserved2;
    public IntPtr lpReserved2;
    public IntPtr hStdInput;
    public IntPtr hStdOutput;
    public IntPtr hStdError;
  }
  
  [Flags]
  public enum StartFlags
  {
    TitleIsLinkName = 0x00000800
    // Unused values omitted for brevity
  }
  
  public enum StandardHandle
  {
    StandardOutput = -11
    // Unused values omitted for brevity
  }
  
  [StructLayout(LayoutKind.Explicit, Size = 4)]
  public struct ColorRef {
  
    public ColorRef(byte r, byte g, byte b) {
      this.Value = 0;
      this.R = r;
      this.G = g;
      this.B = b;
    }

    public ColorRef(uint value) {
      this.R = 0;
      this.G = 0;
      this.B = 0;
      this.Value = value & 0x00FFFFFF;
    }

    [FieldOffset(0)]
    public byte R;
    
    [FieldOffset(1)]
    public byte G;
    
    [FieldOffset(2)]
    public byte B;

    [FieldOffset(0)]
    public uint Value;
  }
  
  [StructLayout(LayoutKind.Sequential)]
  public struct Coord
  {
    public short X;
    public short Y;
  }
  
  [StructLayout(LayoutKind.Sequential)]
  public struct SmallRect
  {
    public short Left;
    public short Top;
    public short Right;
    public short Bottom;
  }

  [StructLayout(LayoutKind.Sequential)]
  public struct ConsoleScreenBufferInfoEx
  {
    public uint      cbSize;
    public Coord     dwSize;
    public Coord     dwCursorPosition;
    public short     wAttributes;
    public SmallRect srWindow;
    public Coord     dwMaximumWindowSize;

    public ushort    wPopupAttributes;
    public bool      bFullscreenSupported;

    [MarshalAs(
      UnmanagedType.ByValArray,
      ArraySubType = UnmanagedType.Struct,
      SizeConst = 16)]
    public ColorRef[] ColorTable;
    
    public static ConsoleScreenBufferInfoEx Create()
    {
      return new ConsoleScreenBufferInfoEx { cbSize = 96 };
    }
        
    //public ColorRef black;
    //public ColorRef darkBlue;
    //public ColorRef darkGreen;
    //public ColorRef darkCyan;
    //public ColorRef darkRed;
    //public ColorRef darkMagenta;
    //public ColorRef darkYellow;
    //public ColorRef gray;
    //public ColorRef darkGray;
    //public ColorRef blue;
    //public ColorRef green;
    //public ColorRef cyan;
    //public ColorRef red;
    //public ColorRef magenta;
    //public ColorRef yellow;
    //public ColorRef white;
  }

  public class Kernel
  {
  
    // GetStartupInfo
    // ----------------------------------------------------------
    // Retrieves information about the context in which the
    // calling process was started.
    //
    // https://msdn.microsoft.com/en-us/library/ms683230.aspx
    // http://www.pinvoke.net/default.aspx/kernel32/GetStartupInfo.html
    //
    [DllImport("Kernel32.dll",
      SetLastError = true,
      CharSet = CharSet.Ansi,
      EntryPoint = "GetStartupInfoA")]
    public static extern void GetStartupInfo(
      out StartupInfo lpStartupInfo);
    
    
    [DllImport("Kernel32.dll", 
      SetLastError=true)]
    public static extern IntPtr GetStdHandle(
      int handle);
    
    [DllImport("Kernel32.dll", 
      SetLastError=true)]
    public static extern bool GetConsoleMode(
      IntPtr handle,
      out int mode);
    
    [DllImport("Kernel32.dll",
      SetLastError=true)]
    public static extern bool SetConsoleMode(
      IntPtr hConsoleHandle,
      int mode);

    [DllImport("Kernel32.dll",
      SetLastError = true)]
    public static extern bool SetConsoleWindowInfo(
      IntPtr hConsoleOutput,
      bool bAbsolute,
      [In] ref SmallRect lpConsoleWindow );
      
    [DllImport("Kernel32.dll",
      SetLastError = true)]
    public static extern bool GetConsoleScreenBufferInfoEx(
      IntPtr hConsoleOutput,
      ref ConsoleScreenBufferInfoEx ConsoleScreenBufferInfoEx );
      
    [DllImport("Kernel32.dll",
      SetLastError = true)]
    public static extern bool SetConsoleScreenBufferInfoEx(
      IntPtr hConsoleOutput,
      ref ConsoleScreenBufferInfoEx ConsoleScreenBufferInfoEx );   
  }
  
  [Flags]
  public enum WindowsMessage
  {
    SettingsUpdated = 0x001A
    // Unused values omitted for brevity
  }
  
  public enum MessageTarget
  {
    Broadcast = 0xFFFF
    // Unused values omitted for brevity
  }
  
  public class User
  {  
    [DllImport("User32.dll",
      SetLastError = true,
      CharSet = CharSet.Auto)]
    public static extern bool SendNotifyMessage(
      IntPtr  hWnd,
      uint    Msg, 
      UIntPtr wParam,
      string  lParam);
  }
}

"@



function Send-SettingsUpdate ([string]$UpdatedItem)
{
  # Broadcast a settings-updated message.  This can be
  # an environment message ("Environment"), or a registry
  # key (Name of key), or perhaps others as well
  return ([Win32.User]::SendNotifyMessage(
    [IntPtr]([Win32.MessageTarget]::Broadcast),
    [Win32.WindowsMessage]::SettingsUpdated,
    [UIntPtr]::Zero,
    $UpdatedItem))
}


# for ($i=0;$i-lt10;$i++){ Test-Problem }
function Test-Problem
{
  $info     = [Win32.ConsoleScreenBufferInfoEx]::Create()
  $hConsole = [Win32.Kernel]::GetStdHandle( [Win32.StandardHandle]::StandardOutput )
  $success  = [Win32.Kernel]::GetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )
    Write-Output ( "Size {0},{1}; CPos {2},{3}; Win {4},{5},{6},{7}; Max {8},{9}" -f `
      $info.dwSize.X,              $info.dwSize.Y,             `
      $info.dwCursorPosition.X,    $info.dwCursorPosition.Y,   `
      $info.srWindow.Left,         $info.srWindow.Top,         `
      $info.srWindow.Right,        $info.srWindow.Bottom,      `
      $info.dwMaximumWindowSize.X, $info.dwMaximumWindowSize.Y )
    Write-Output "Here's some more..."
  
  # For reasons that aren't clear, the window information reported by
  # GetConsoleScreenBufferInfoEx is 1 smaller (height & width) than
  # what's actually there.  You have to increase them by 1 before
  # passing it back to SetConsoleScreenBufferInfoEx, or the window
  # will shrink.
  $temp = $info.srWindow
  $temp.Right  += 1 
  $temp.Bottom += 1
  $info.srWindow = $temp
  
  $success  = [Win32.Kernel]::SetConsoleScreenBufferInfoEx( $hConsole, [ref]$info )
}
Export-ModuleMember -Function Test-Problem