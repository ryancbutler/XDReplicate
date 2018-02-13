Export Commands
=========================

This page contains details on **Export** commands.

Export-XDApp
-------------------------


NAME
    Export-XDApp
    
SYNOPSIS
    Adds required import values to existing exported app object
    
    
SYNTAX
    Export-XDApp [-app] <Object> [[-xdhost] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Adds required import values to existing exported app object
    

PARAMETERS
    -app <Object>
        Application Object
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$apps = Get-BrokerApplication -AdminAddress $xdhost|export-xdapp
    
    Grabs all applications and adds required values to object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Export-XDApp -examples".
    For more information, type: "get-help Export-XDApp -detailed".
    For technical information, type: "get-help Export-XDApp -full".


Export-XDAppGroup
-------------------------

NAME
    Export-XDAppGroup
    
SYNOPSIS
    Adds delivery group names to Application Group Object required for import process
    
    
SYNTAX
    Export-XDAppGroup [-appgroupobject] <Object> [[-xdhost] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Adds delivery group names to Application Group Object required for import process
    

PARAMETERS
    -appgroupobject <Object>
        Application Group object
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$appgroups = Get-BrokerApplicationGroup|export-xdappgroup -xdhost $xdhost
    
    Grabs all application groups and adds required values to object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Export-XDAppGroup -examples".
    For more information, type: "get-help Export-XDAppGroup -detailed".
    For technical information, type: "get-help Export-XDAppGroup -full".


Export-XDDesktop
-------------------------

NAME
    Export-XDDesktop
    
SYNOPSIS
    Adds Delivery group names to Desktop Object
    
    
SYNTAX
    Export-XDDesktop [-desktop] <Object> [-dg] <Object> [[-xdhost] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Adds Delivery group names to Desktop Object
    

PARAMETERS
    -desktop <Object>
        Exported desktop object
        
    -dg <Object>
        Delivery group where desktop resides
        
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$dg = get-brokerdesktopgroup -name "My Delivery Group"
    
    $desktops = Get-BrokerEntitlementPolicyRule|Export-XDdesktop -xdhost $xdhost -dg $dg
    Grabs all desktops and adds required values to object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Export-XDDesktop -examples".
    For more information, type: "get-help Export-XDDesktop -detailed".
    For technical information, type: "get-help Export-XDDesktop -full".


Export-XDSite
-------------------------

NAME
    Export-XDSite
    
SYNOPSIS
    Exports XD site information to variable or XML file
    
    
SYNTAX
    Export-XDSite [[-xdhost] <String>] [[-xmlpath] <String>] [[-dgtag] <String>] [[-ignoredgtag] <String>] [[-apptag] <String>] [[-ignoreapptag] 
    <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Exports XD site information to variable or XML file
    

PARAMETERS
    -xdhost <String>
        XenDesktop DDC hostname to connect to
        
    -xmlpath <String>
        Path used for XML file location on import and export operations
        
    -dgtag <String>
        Only export delivery groups with specified tag
        
    -ignoredgtag <String>
        Skips export of delivery groups with specified tag
        
    -apptag <String>
        Export delivery group applications with specific tag
        
    -ignoreapptag <String>
        Exports all delivery group applications except ones with specific tag
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Export-XDSite -xdhost DDC02.DOMAIN.COM
    
    Exports data from DDC02.DOMAIN.COM and returns as object
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Export-XDSite -xdhost DDC02.DOMAIN.COM -dgtag "replicate"
    
    Exports data from DDC02.DOMAIN.COM with delivery groups tagged with "replicate" and returns as object.
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Export-XDSite -xdhost DDC02.DOMAIN.COM -ignoredgtag "skip"
    
    Exports data from DDC02.DOMAIN.COM while skipping delivery groups tagged with "skip" and returns as object.
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Export-XDSite -xdhost DDC02.DOMAIN.COM -apptag "replicate"
    
    Exports data from DDC02.DOMAIN.COM delivery groups while only including apps tagged with "replicate" and returns as object.
    
    
    
    
    -------------------------- EXAMPLE 5 --------------------------
    
    PS C:\>Export-XDSite -xdhost DDC02.DOMAIN.COM -ignoreapptag "skip"
    
    Exports data from DDC02.DOMAIN.COM delivery groups while ignoring apps tagged with "skip" and returns as object.
    
    
    
    
    -------------------------- EXAMPLE 6 --------------------------
    
    PS C:\>.\XDReplicate.ps1 -xdhost DDC02.DOMAIN.COM -XMLPATH "C:\temp\my.xml"
    
    Exports data from DDC02.DOMAIN.COM and exports to C:\temp\my.xml
    
    
    
    
REMARKS
    To see the examples, type: "get-help Export-XDSite -examples".
    For more information, type: "get-help Export-XDSite -detailed".
    For technical information, type: "get-help Export-XDSite -full".




