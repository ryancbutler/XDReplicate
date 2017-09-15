$sut = "$env:APPVEYOR_BUILD_FOLDER\XDReplicate\CTXXD-Replicate.psd1"

Describe 'Script Metadata Validation' {      
        it 'Script fileinfo should be ok' {
            {Test-ModuleManifest $sut} | Should Not Throw
        }    
}