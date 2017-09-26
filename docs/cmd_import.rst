Import Commands
=========================

This page contains details on **Import** commands.

import-xdadmin
-------------------------


NAME
    import-xdadmin
    
SYNOPSIS
    Creates admin user from imported object
    
    
SYNTAX
    import-xdadmin [-admin] <Object> [-xdhost] <String> [<CommonParameters>]
    
    
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
    To see the examples, type: "get-help import-xdadmin -examples".
    For more information, type: "get-help import-xdadmin -detailed".
    For technical information, type: "get-help import-xdadmin -full".


import-xdadminrole
-------------------------

NAME
    import-xdadminrole
    
SYNOPSIS
    Creates admin role exported object
    
    
SYNTAX
    import-xdadminrole [-role] <Object> [-xdhost] <String> [<CommonParameters>]
    
    
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
    To see the examples, type: "get-help import-xdadminrole -examples".
    For more information, type: "get-help import-xdadminrole -detailed".
    For technical information, type: "get-help import-xdadminrole -full".


import-xdapp
-------------------------

NAME
    import-xdapp
    
SYNOPSIS
    Creates broker application from imported object
    
    
SYNTAX
    import-xdapp [-app] <Object> [-xdhost] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Creates broker application from imported object
    

PARAMETERS
    -app <Object>
        Broker Application to create
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$XDEXPORT.apps|import-xdapp
    
    Creates applications from imported app object
    
    
    
    
REMARKS
    To see the examples, type: "get-help import-xdapp -examples".
    For more information, type: "get-help import-xdapp -detailed".
    For technical information, type: "get-help import-xdapp -full".


import-XDApplicationGroup
-------------------------

NAME
    import-XDApplicationGroup
    
SYNOPSIS
    Creates application group from imported object
    
    
SYNTAX
    import-XDApplicationGroup [-ag] <Object> [-xdhost] <String> [<CommonParameters>]
    
    
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
    To see the examples, type: "get-help import-XDApplicationGroup -examples".
    For more information, type: "get-help import-XDApplicationGroup -detailed".
    For technical information, type: "get-help import-XDApplicationGroup -full".


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
    Import-XDDesktop [-desktop] <Object> [-xdhost] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Creates desktops from exported object
    

PARAMETERS
    -desktop <Object>
        Desktop to create
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
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


Import-XDsite
-------------------------

NAME
    Import-XDsite
    
SYNOPSIS
    Imports XD site information from object
    
    
SYNTAX
    Import-XDsite [[-xdhost] <String>] [[-xmlpath] <String>] [[-xdexport] <Object>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Imports XD site information from object
    

PARAMETERS
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    -xmlpath <String>
        Path used for XML file location on import and export operations
        
    -xdexport <Object>
        XD site object to import
        
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
    
    
    
    
REMARKS
    To see the examples, type: "get-help Import-XDsite -examples".
    For more information, type: "get-help Import-XDsite -detailed".
    For technical information, type: "get-help Import-XDsite -full".


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




