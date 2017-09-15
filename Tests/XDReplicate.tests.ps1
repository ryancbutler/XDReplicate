$manifest = "$env:APPVEYOR_BUILD_FOLDER\XDReplicate\CTXXD-Replicate.psd1"
$module = "$env:APPVEYOR_BUILD_FOLDER\XDReplicate\CTXXD-Replicate.psm1"

Describe 'Module Metadata Validation' {      
        it 'Script fileinfo should be ok' {
            {Test-ModuleManifest $manifest} | Should Not Throw
        }
        
        it 'Import module should be ok'{
            {Import-Module $module} | Should Not Throw
        }
}