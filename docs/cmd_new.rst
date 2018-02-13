New Commands
=========================

This page contains details on **New** commands.

New-XDAdminFolder
-------------------------


NAME
    New-XDAdminFolder
    
SYNOPSIS
    Checks for and creates administrative folder if not found
    
    
SYNTAX
    New-XDAdminFolder [-folder] <String> [[-xdhost] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
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
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$folders = @("MyFolder1","MyFolder2","MyFolder3")
    
    $folders|New-XDadminfolder
    Tests and creates MyFolder1, MyFolder2 and MyFolder3 admin folders
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-XDadminfolder -folder "TestA\\TestB\\TestC" (USE SINGLE SLASH)
    
    Tests and creates folders as \\TestA\\TestB\\TestC
    
    
    
    
REMARKS
    To see the examples, type: "get-help New-XDAdminFolder -examples".
    For more information, type: "get-help New-XDAdminFolder -detailed".
    For technical information, type: "get-help New-XDAdminFolder -full".


New-XDMCSDesktop
-------------------------

NAME
    New-XDMCSDesktop
    
SYNOPSIS
    Adds machines to XenDesktop Machine Catalog and Delivery Group via MCS
    
    
SYNTAX
    New-XDMCSDesktop [-machinecat] <String> [-dgroup] <String> [-mctype] <String> [[-howmany] <Int32>] [[-user] <String>] [[-xdhost] <String>] 
    [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Adds machines to XenDesktop Machine Catalog and Delivery Group via MCS
    

PARAMETERS
    -machinecat <String>
        Machine Catalog to add to
        
    -dgroup <String>
        Delivery group to add newly created machines to
        
    -mctype <String>
        
    -howmany <Int32>
        Count of machines to add to the site (pooled)
        
    -user <String>
        AD user to add to dedicated desktop (domain\username)
        
    -xdhost <String>
        
    -WhatIf [<SwitchParameter>]
        
    -Confirm [<SwitchParameter>]
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>New-XDMCSDesktop -machinecat "Windows 10 x64 Random" -dgroup "Windows 10 Desktop" -mctype "Dedicated" -user "lab\joeshmith"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-XDMCSDesktop -machinecat "Windows 10 x64 Dedicated" -dgroup "Windows 10 Desktop" -mctype "Pooled" -howmany "10"
    
    
    
    
    
    
REMARKS
    To see the examples, type: "get-help New-XDMCSDesktop -examples".
    For more information, type: "get-help New-XDMCSDesktop -detailed".
    For technical information, type: "get-help New-XDMCSDesktop -full".




