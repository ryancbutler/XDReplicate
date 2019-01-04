Get Commands
=========================

This page contains details on **get** commands.

get-xddesktop
-------------------------


NAME
    get-xddesktop
    
SYNOPSIS
    Gets Desktop machine of user given Machine catalog
    
    
SYNTAX
    get-xddesktop [[-dgroup] <Object>] [[-user] <Object>] [[-xdhost] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Gets Desktop machine of user given Machine catalog
    

PARAMETERS
    -dgroup <Object>
        Delivery group to query from
        
    -user <Object>
        What user
        
    -xdhost <String>
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>get-xddesktop -dggroup "Windows 10 Desktop" -user "lab\jsmith
    
    
    
    
    
    
REMARKS
    To see the examples, type: "get-help get-xddesktop -examples".
    For more information, type: "get-help get-xddesktop -detailed".
    For technical information, type: "get-help get-xddesktop -full".




