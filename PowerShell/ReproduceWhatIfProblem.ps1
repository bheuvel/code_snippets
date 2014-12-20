$base="$($env:TEMP)\Base"
$res=md $base -force

Remove-Item $base -Recurse -Force
for( $i=1; $i -lt 2; $i++){
    $res=New-Item -ItemType directory  ("$base/{0:D8}-fld" -f $i)  -force
    for($j=1; $j -lt 1300; $j++){
        $res=New-Item -ItemType file   ("$base/{0:D8}-fld/{1:D8}-file" -f $i,$j) -force
    }
}

Remove-Item "$base.zip" -Force -ErrorAction SilentlyContinue
Add-Type -Assembly "System.IO.Compression.FileSystem"
[System.IO.Compression.ZipFile]::CreateFromDirectory("$base", "$base.zip")
Remove-Item $base -Recurse

$res=md "$base\dsc" -force

@"
instance of MSFT_ArchiveResource as `$MSFT_ArchiveResource1ref
{
ResourceID = "[Archive]chef_dsc";
 Path = "$($base  -replace "\\","\\").zip";
 Ensure = "Present";
 Destination = "$($base  -replace "\\","\\")";
 SourceInfo = "::4::5::archive";
 ModuleName = "PSDesiredStateConfiguration";
 ModuleVersion = "1.0";

};

instance of OMI_ConfigurationDocument
{
 Version="1.0.0";
 Author="vagrant";
 GenerationDate="12/17/2014 13:30:33";
 GenerationHost="VAGRANT-2008R2";
};

"@ | Out-File -FilePath "$base\dsc\localhost.mof" -Force

Start-DscConfiguration -Wait -Verbose -WhatIf "$base\dsc"

Remove-Item "$base" -Recurse -Force  -ErrorAction SilentlyContinue

