Import Commands
=========================

This page contains details on **Import** commands.

Import-XDAdmin
-------------------------


NAME
    Import-XDAdmin
    
SYNOPSIS
    Creates admin user from imported object
    
    
SYNTAX
    Import-XDAdmin [-admin] <Object> [-xdhost] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Creates admin user from imported object
    

PARAMETERS
    -admin <Object>
        Admin user to create
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$XDEXPORT.admins|import-xdadmin
    
    Creates admin users from imported admin user object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Import-XDAdmin -examples".
    For more information, type: "get-help Import-XDAdmin -detailed".
    For technical information, type: "get-help Import-XDAdmin -full".


Import-XDAdminRole
-------------------------

NAME
    Import-XDAdminRole
    
SYNOPSIS
    Creates admin role exported object
    
    
SYNTAX
    Import-XDAdminRole [-role] <Object> [-xdhost] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Creates admin role exported object
    

PARAMETERS
    -role <Object>
        Role to create
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$XDEXPORT.adminroles|import-xdadminrole
    
    Creates admin roles from imported admin role object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Import-XDAdminRole -examples".
    For more information, type: "get-help Import-XDAdminRole -detailed".
    For technical information, type: "get-help Import-XDAdminRole -full".


Import-XDApp
-------------------------

NAME
    Import-XDApp
    
SYNOPSIS
    Creates broker application from imported object
    
    
SYNTAX
    Import-XDApp [-app] <Object> [-xdhost] <String> [-ignoreenable] [<CommonParameters>]
    
    
DESCRIPTION
    Creates broker application from imported object
    

PARAMETERS
    -app <Object>
        Broker Application to create
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    -ignoreenable [<SwitchParameter>]
        Ignores setting the Enable flag
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$XDEXPORT.apps|import-xdapp
    
    Creates applications from imported app object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Import-XDApp -examples".
    For more information, type: "get-help Import-XDApp -detailed".
    For technical information, type: "get-help Import-XDApp -full".


Import-XDApplicationGroup
-------------------------

NAME
    Import-XDApplicationGroup
    
SYNOPSIS
    Creates application group from imported object
    
    
SYNTAX
    Import-XDApplicationGroup [-ag] <Object> [-xdhost] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Creates application group from imported object
    

PARAMETERS
    -ag <Object>
        Application Group to create
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$XDEXPORT.appgroups|import-xdapplicationgroup
    
    Creates application groups from imported application group object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Import-XDApplicationGroup -examples".
    For more information, type: "get-help Import-XDApplicationGroup -detailed".
    For technical information, type: "get-help Import-XDApplicationGroup -full".


Import-XDDeliveryGroup
-------------------------

NAME
    Import-XDDeliveryGroup
    
SYNOPSIS
    Creates delivery groups from exported object
    
    
SYNTAX
    Import-XDDeliveryGroup [-dg] <Object> [-xdhost] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Creates delivery groups from exported object
    

PARAMETERS
    -dg <Object>
        Delivery Group to create
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$XDEXPORT.dgs|import-xddeliverygroup
    
    Creates delivery groups from imported delivery group object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Import-XDDeliveryGroup -examples".
    For more information, type: "get-help Import-XDDeliveryGroup -detailed".
    For technical information, type: "get-help Import-XDDeliveryGroup -full".


Import-XDDesktop
-------------------------

NAME
    Import-XDDesktop
    
SYNOPSIS
    Creates desktops from exported object
    
    
SYNTAX
    Import-XDDesktop [-desktop] <Object> [-xdhost] <String> [-ignoreenable] [<CommonParameters>]
    
    
DESCRIPTION
    Creates desktops from exported object
    

PARAMETERS
    -desktop <Object>
        Desktop to create
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    -ignoreenable [<SwitchParameter>]
        Ignores setting the Enable flag
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$XDEXPORT.desktops|import-xddesktop
    
    Creates desktops from imported desktop object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Import-XDDesktop -examples".
    For more information, type: "get-help Import-XDDesktop -detailed".
    For technical information, type: "get-help Import-XDDesktop -full".


Import-XDSite
-------------------------

NAME
    Import-XDSite
    
SYNOPSIS
    Imports XD site information from object
    
    
SYNTAX
    Import-XDSite [[-xdhost] <String>] [[-xmlpath] <String>] [[-xdexport] <Object>] [-ignoreenable] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Imports XD site information from object
    

PARAMETERS
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    -xmlpath <String>
        Path used for XML file location on import and export operations
        
    -xdexport <Object>
        XD site object to import
        
    -ignoreenable [<SwitchParameter>]
        Ignores setting the Enable flag on apps and desktops
        
    -WhatIf [<SwitchParameter>]
        
    -Confirm [<SwitchParameter>]
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$exportedobject|Import-XDSite -xdhost DDC02.DOMAIN.COM
    
    Imports data to DDC02.DOMAIN.COM and returns as object
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Import-XDSite -xdhost DDC02.DOMAIN.COM -xmlpath "C:\temp\mypath.xml"
    
    Imports data to DDC02.DOMAIN.COM from XML file C:\temp\mypath.xml
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Import-XDSite -xdhost DDC02.DOMAIN.COM -xdexport $myexport
    
    Imports data to DDC02.DOMAIN.COM from variable $myexport
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Import-XDSite -xdhost DDC02.DOMAIN.COM -xdexport $myexport -ignoreenable
    
    Imports data to DDC02.DOMAIN.COM from variable $myexport and does not change any existing disable\enable settings for applications and desktops
    
    
    
    
REMARKS
    To see the examples, type: "get-help Import-XDSite -examples".
    For more information, type: "get-help Import-XDSite -detailed".
    For technical information, type: "get-help Import-XDSite -full".


Import-XDTag
-------------------------

NAME
    Import-XDTag
    
SYNOPSIS
    Creates desktops from imported object
    
    
SYNTAX
    Import-XDTag [-tag] <Object> [-xdhost] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Creates desktops from imported object
    

PARAMETERS
    -tag <Object>
        TAG to create
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$XDEXPORT.tags|import-xdtag
    
    Creates tags from imported tag object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Import-XDTag -examples".
    For more information, type: "get-help Import-XDTag -detailed".
    For technical information, type: "get-help Import-XDTag -full".




