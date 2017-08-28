# Line break for readability in AppVeyor console
Write-Host -Object ''

# Make sure we're using the Master branch and that it's not a pull request
# Environmental Variables Guide: https://www.appveyor.com/docs/environment-variables/
if ($env:APPVEYOR_REPO_BRANCH -ne 'master') 
{
    Write-Warning -Message "Skipping version increment and publish for branch $env:APPVEYOR_REPO_BRANCH"
}
else
{
    
    Try 
    {
        
        #scripts to check
        $scripts = @($env:PSScripts -split ",")
        
        foreach ($script in $scripts)
        {
            $scriptinfo  = Test-ScriptFileInfo -path $script
            [System.Version]$scriptver = $scriptinfo.version
            $psinfo = find-script $scriptinfo.name
            [System.Version]$psver = $psinfo.version
            write-host "Found Github script version $scriptinfo and PS gallery version $psver"
            if($psver -lt $scriptver)
            {
                write-host "Updating PS Gallery"
            }
            else {
                write-host "Version matches.."
            }

        }
        
    }
    catch
    {
        throw $_
    }




}