Send Commands
=========================

This page contains details on **Send** commands.

Send-XDslackmsg
-------------------------


NAME
    Send-XDslackmsg
    
SYNOPSIS
    Sends message to Slack incoming webhook URL
    
    
SYNTAX
    Send-XDslackmsg [-slackurl] <String> [-msg] <String> [[-emoji] <Object>] [<CommonParameters>]
    
    
DESCRIPTION
    Sends message to Slack incoming webhook URL
    

PARAMETERS
    -slackurl <String>
        Slack web incoming hook url
        
    -msg <String>
        Message to send to URL
        
    -emoji <Object>
        Emoji to use as avatar to send message
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>send-xdslackmsg -slackurl "https://myurl.com" -msg "Send this" -emoji ":joy:"
    
    
    
    
    
    
REMARKS
    To see the examples, type: "get-help Send-XDslackmsg -examples".
    For more information, type: "get-help Send-XDslackmsg -detailed".
    For technical information, type: "get-help Send-XDslackmsg -full".




