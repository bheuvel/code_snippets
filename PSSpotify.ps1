Add-Type -TypeDefinition @"
namespace PSSpotify
{
   public enum ItemTypes
   {
      Album,
      Artist,
      Playlist,
      Track
   }
}
"@


function PSSpotify-Search
{
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'Query as entered in Spotify', Mandatory = $true, ValueFromPipeline = $true)]
	 	[ValidateNotNullorEmpty()]
        [string]$query,
        
        [Parameter(HelpMessage = 'Item types to return', ValueFromPipeline = $true)]
        [PSSpotify.ItemTypes[]]$returnTypes = [PSSpotify.ItemTypes]::Track,

        [Parameter(HelpMessage = 'Maximum number of results', ValueFromPipeline = $true)]
        [ValidateRange(1,50)]
        [int]$limit=20

    )
    $url_spotify="https://api.spotify.com/v1/search?q="
    $queryTypes = '&type=' + ($returnTypes -join ',')
    $queryLimit = "&limit=$limit"

    $queryUri = "$($url_spotify)$([System.Web.HttpUtility]::UrlEncode($query))$($queryTypes)$($queryLimit)"
    Write-Host $queryUri
    Invoke-WebRequest -Uri $queryUri -Headers @{'accept'='application/json'} | ConvertFrom-Json
}

$res = PSSpotify-Search -query 'artist:Muse psycho' -returnTypes Album,Artist,Track
$res.tracks.items | foreach{ "Name: $($_.Name), Album name: $($_.album.name)" }
$res | Select-Object -ExpandProperty Tracks | Select-Object -ExpandProperty items | ft Name,@{Label="AlbumName" ; Expression={$_.Album.Name}}
