Export Examples
========================

Exports data from localhost and exports to C:\temp\my.xml
-------------------------
``Export-XDSite -xdhost localhost -XMLPATH "C:\temp\my.xml"``

Exports data from localhost with delivery groups tagged with "replicate" and imports on DDC02.DOMAIN.COM
-------------------------
``Export-XDSite -xdhost localhost -dgtag "replicate"|Import-XDSite -xdhost DDC02.DOMAIN.COM``
   
Exports data from localhost while skipping delivery groups tagged with "skip" and imports on DDC02.DOMAIN.COM
-------------------------
``Export-XDSite -xdhost localhost -ignoredgtag "skip"|Import-XDSite -xdhost DDC02.DOMAIN.COM``

Exports data from localhost delivery groups while only including apps tagged with "replicate" and imports on DDC02.DOMAIN.COM
-------------------------
``Export-XDSite -xdhost localhost -apptag "replicate"|Import-XDSite -xdhost DDC02.DOMAIN.COM``

Exports data from localhost delivery groups while ignoring apps tagged with "skip" and imports on DDC02.DOMAIN.COM
-------------------------
``Export-XDSite -xdhost localhost -ignoreapptag "skip"|Import-XDSite -xdhost DDC02.DOMAIN.COM``