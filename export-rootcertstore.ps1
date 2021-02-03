#######################################
# Author: Goffar, Paul (@n3tl0kr)
# Title: export-rootcertstore.ps1
#######################################

Function export-rootcertstore 
{
    param(
        [parameter(Mandatory)]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist" 
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
            return $true
        })]
        [System.IO.FileInfo]$Path
    )
   

Write-host -ForegroundColor Yellow "export-certificate trust store for analysis..."

$certs = (Get-ChildItem -Path Cert:\LocalMachine\AuthRoot -Recurse)

$certs | ForEach-Object {$i=0}{
        Try
        {
        #setup export object
        $subject=($_.SubjectName.Name).Split(',')
        $subject=(([String]$subject[0]).Split('='))[1]
        $thumb = ($_.Thumbprint).Substring(0,9)
        $file = $subject + "_" + $thumb + ".pem"
        
        #setup cert object
        $InsertLineBreaks = 1
        $PEM = new-object System.Text.StringBuilder
        $Pem.AppendLine("-----BEGIN CERTIFICATE-----")
        $Pem.AppendLine([System.Convert]::ToBase64String($_.RawData,$InsertLineBreaks))
        $Pem.AppendLine("-----END CERTIFICATE-----")
        $Pem.ToString() | out-file $Path\$file
        
        #Export-Certificate -Type CERT -Cert $_ -NoClobber -FilePath "$Path\$file"
        $i++
        }

        catch
        {
        "$($file) cannot be exported"
        }
    }

    write-host -ForegroundColor Yellow "Successfully exported $i root certificates"
}


