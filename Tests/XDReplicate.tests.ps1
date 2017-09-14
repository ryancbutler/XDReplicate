$sut = "$env:APPVEYOR_BUILD_FOLDER\XDReplicate.ps1"

Describe 'Script Metadata Validation' {      
        it 'Script fileinfo should be ok' {
            {Test-ScriptFileInfo $sut} | Should Not Throw
        }    
}