Import Examples
========================

Imports data from C:\temp\my.xml and imports to localhost
-------------------------
``Import-XDSite -xdhost localhost -xmlpath "C:\temp\mypath.xml"``

Imports data from C:\temp\my.xml and imports to localhost with no confirmation
-------------------------
``Import-XDSite -xdhost localhost -xmlpath "C:\temp\mypath.xml" -confirm:$false``

Exports data from localhost and imports on DDC02.DOMAIN.COM
-------------------------
``Export-XDSite -xdhost localhost|Import-XDSite -xdhost DDC02.DOMAIN.COM``

Exports data from DDC01.DOMAIN.COM and imports on DDC02.DOMAIN.COM
-------------------------
``Export-XDSite -xdhost DDC01.DOMAIN.COM|Import-XDSite -xdhost DDC02.DOMAIN.COM``

Exports data from localhost and imports on DDC02.DOMAIN.COM outputs verbose
-------------------------
``Export-XDSite -xdhost localhost -verbose|Import-XDSite -xdhost DDC02.DOMAIN.COM -verbose``