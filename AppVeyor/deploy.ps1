[CmdletBinding()]
param(
    
)
# Line break for readability in AppVeyor console
Write-Host -Object ''
Import-Module posh-git -Force

if ($env:APPVEYOR_REPO_BRANCH -ne 'master') 
{
    Write-Warning -Message "Skipping version increment and publish for branch $env:APPVEYOR_REPO_BRANCH"
}
elseif ($env:APPVEYOR_PULL_REQUEST_NUMBER -gt 0)
{
    Write-Warning -Message "Skipping version increment and publish for pull request #$env:APPVEYOR_PULL_REQUEST_NUMBER"
}
else
{
    Try {
        $updates = Get-ChildItem $env:APPVEYOR_BUILD_FOLDER -Filter "*.ps1"
        
        $pubme = $false
        if($updates.count -gt 0)
        {
        Write-Verbose $updates
            foreach ($update in $updates)
            {
                $localver = Test-ScriptFileInfo $update.name
                $psgallerver = Find-Script $localver.name -Repository PSgallery
                if ($psgallerver.version -le $localver.version)
                {
                    Write-Verbose "Updating version and publishing to PSgallery"
                    $fileVersion = $localver.Version
                    $newVersion = "{0}.{1}.{2}" -f $fileVersion.Major, $fileVersion.Minor, ($fileVersion.Build + 1)
                    Update-ScriptFileInfo -Path $update -Version $newVersion
                    Publish-Script -Path $update -NuGetApiKey $env:PSGKey
                    $pubme = $true
                }
                else
                {
                Write-Warning "$($localver.name) not found on PSgallery or PSgallery version higher"
                }
            }
        }
        else {
            Write-Warning "Nothing to update"
        }
    }
    catch {
        Write-Warning "Version update failed"
        throw $_
    }

    Try 
    {
        if($pubme)
        {
        git checkout master
        git add --all
        git commit -m "PSGallery Version Update to $newVersion"
        git push origin master
        Write-Verbose "Repo has been pushed to github"
        }
        else {
            Write-Verbose "Nothing to push"
        }
    }
    Catch 
    {
        Write-Warning "Github push failed"
        throw $_
    }

}