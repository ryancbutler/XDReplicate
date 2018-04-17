function Get-FileEncoding
{
#FROM https://gist.github.com/jpoehls/2406504
  [CmdletBinding()] 
  Param (
    [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)] 
    [string]$Path
  )

  [byte[]]$byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path
  #Write-Host Bytes: $byte[0] $byte[1] $byte[2] $byte[3]

  # EF BB BF (UTF8)
  if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )
  { return 'UTF8' }

  # FE FF  (UTF-16 Big-Endian)
  elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
  { return 'Unicode UTF-16 Big-Endian' }

  # FF FE  (UTF-16 Little-Endian)
  elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe)
  { return 'Unicode UTF-16 Little-Endian' }

  # 00 00 FE FF (UTF32 Big-Endian)
  elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
  { return 'UTF32 Big-Endian' }

  # FE FF 00 00 (UTF32 Little-Endian)
  elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff -and $byte[2] -eq 0 -and $byte[3] -eq 0)
  { return 'UTF32 Little-Endian' }

  # 2B 2F 76 (38 | 38 | 2B | 2F)
  elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76 -and ($byte[3] -eq 0x38 -or $byte[3] -eq 0x39 -or $byte[3] -eq 0x2b -or $byte[3] -eq 0x2f) )
  { return 'UTF7'}

  # F7 64 4C (UTF-1)
  elseif ( $byte[0] -eq 0xf7 -and $byte[1] -eq 0x64 -and $byte[2] -eq 0x4c )
  { return 'UTF-1' }

  # DD 73 66 73 (UTF-EBCDIC)
  elseif ($byte[0] -eq 0xdd -and $byte[1] -eq 0x73 -and $byte[2] -eq 0x66 -and $byte[3] -eq 0x73)
  { return 'UTF-EBCDIC' }

  # 0E FE FF (SCSU)
  elseif ( $byte[0] -eq 0x0e -and $byte[1] -eq 0xfe -and $byte[2] -eq 0xff )
  { return 'SCSU' }

  # FB EE 28  (BOCU-1)
  elseif ( $byte[0] -eq 0xfb -and $byte[1] -eq 0xee -and $byte[2] -eq 0x28 )
  { return 'BOCU-1' }

  # 84 31 95 33 (GB-18030)
  elseif ($byte[0] -eq 0x84 -and $byte[1] -eq 0x31 -and $byte[2] -eq 0x95 -and $byte[3] -eq 0x33)
  { return 'GB-18030' }

  else
  { return 'ASCII' }
}


$projectRoot = $env:APPVEYOR_BUILD_FOLDER


Describe "General project validation" {

    $scripts = Get-ChildItem "$projectRoot\CTXXD-Replicate\" -Recurse -Include *.ps1,*.psm1

    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | Foreach-Object{@{file=$_}}         
    It "Script <file> should be valid powershell" -TestCases $testCase {
        param($file)

        $file.fullname | Should Exist

        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }

    $testCase = $scripts | Foreach-Object{@{file=$_}}         
    It "Script <file> should be UTF-8" -TestCases $testCase {
        param($file)
         Get-FileEncoding -Path $file.fullname|should -Be 'UTF8'
    }

    $scriptAnalyzerRules = Get-ScriptAnalyzerRule
    It "<file> should pass ScriptAnalyzer" -TestCases $testCase {
        param($file)
        $analysis = Invoke-ScriptAnalyzer -Path  $file.fullname -Severity @('Warning','Error')   
        
        forEach ($rule in $scriptAnalyzerRules) {        
            if ($analysis.RuleName -contains $rule) {
                $analysis |
                Where-Object RuleName -EQ $rule -outvariable failures |
                Out-Default
                $failures.Count | Should Be 0
            }
            
        }
    }

}

Describe "Function validation" {
    
        $scripts = Get-ChildItem "$projectRoot\CTXXD-Replicate\" -Recurse -Include *.ps1
        $testCase = $scripts | Foreach-Object{@{file=$_}}         
        It "Script <file> should only contain one function" -TestCases $testCase {
            param($file)   
            $file.fullname | Should Exist
            $contents = Get-Content -Path $file.fullname -ErrorAction Stop
            $describes = [Management.Automation.Language.Parser]::ParseInput($contents, [ref]$null, [ref]$null)
            $test = $describes.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true) 
            $test.Count | Should Be 1
        }

        It "<file> should match function name and contain -XD" -TestCases $testCase {
            param($file)   
            $file.fullname | Should Exist
            $contents = Get-Content -Path $file.fullname -ErrorAction Stop
            $describes = [Management.Automation.Language.Parser]::ParseInput($contents, [ref]$null, [ref]$null)
            $test = $describes.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true) 
            $test[0].name | Should Be $file.basename
            $test[0].name | Should BeLike "*-XD*"
        }
}