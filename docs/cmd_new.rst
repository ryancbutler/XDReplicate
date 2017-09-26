New Commands
=========================

This page contains details on **New** commands.

New-XDadminfolder
-------------------------


NAME
    New-XDadminfolder
    
SYNOPSIS
    Checks for and creates administrative folder if not found
    
    
SYNTAX
    New-XDadminfolder [-folder] <String> [[-xdhost] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Checks for and creates administrative folder if not found
    

PARAMETERS
    -folder <String>
        Folder to validate and create
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    -WhatIf [<SwitchParameter>]
        
    -Confirm [<SwitchParameter>]
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$folders = @("MyFolder1","MyFolder2","MyFolder3")
    
    $folders|New-XDadminfolder
    Tests and creates MyFolder1, MyFolder2 and MyFolder3 admin folders
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-XDadminfolder -folder "TestA\TestB\TestC"
    
    Tests and creates folders as \TestA\TestB\TestC
    
    
    
    
REMARKS
    To see the examples, type: "get-help New-XDadminfolder -examples".
    For more information, type: "get-help New-XDadminfolder -detailed".
    For technical information, type: "get-help New-XDadminfolder -full".




