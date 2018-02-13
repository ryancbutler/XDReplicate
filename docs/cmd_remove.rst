Remove Commands
=========================

This page contains details on **Remove** commands.

Remove-XDMCSDesktop
-------------------------


NAME
    Remove-XDMCSDesktop
    
SYNOPSIS
    Removes desktop(s) from given delivery group
    
    
SYNTAX
    Remove-XDMCSDesktop [[-dgroup] <String>] [-mctype] <String> [[-howmany] <String>] [[-machine] <String>] [[-xdhost] <String>] [-WhatIf] 
    [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Removes desktop(s) from given delivery group
    

PARAMETERS
    -dgroup <String>
        
    -mctype <String>
        Machine catalog type (dedicated or pooled)
        
    -howmany <String>
        How many pooled machines to remove
        
    -machine <String>
        
    -xdhost <String>
        
    -WhatIf [<SwitchParameter>]
        
    -Confirm [<SwitchParameter>]
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Remove-XDMCSdesktop -desktop "MYDOMAIN\MYVDI01" -mctype "Dedicated"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Remove-XDMCSdesktop -howmany 5 -dgroup "Windows 7 Pooled Test" -mctype "Pooled"
    
    
    
    
    
    
REMARKS
    To see the examples, type: "get-help Remove-XDMCSDesktop -examples".
    For more information, type: "get-help Remove-XDMCSDesktop -detailed".
    For technical information, type: "get-help Remove-XDMCSDesktop -full".




