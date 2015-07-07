Add-Type -AssemblyName System.Web
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

function jps
{
    # "Add-up" two resulting-search objects returned from PSSpotify-Search
    # "Private"function, so LOTS of assumptions and no error-handling
    param(
    [PSObject]$res1,
    [PSObject]$res2
    )
    # If either one is empty, just return the other
    if( $res1 -eq $null -and $res2 -ne $null ) { return $res2 }
    if( $res2 -eq $null -and $res1 -ne $null ) { return $res1 }

    # Loop over the auto-generated members
    $res1.psobject.Members | where{ $_.MemberType -Like "NoteProperty" } | foreach{
        # The PSObject addition function,
        #  so typecast via arrays, which support addition
        #  and assign to the one that will be returned
        $res1."$($_.Name)" = (@($res1."$($_.Name)") + @($res2."$($_.Name)"))
    }
    $res1
}


function PSSpotify-Search
{
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'Query as entered in Spotify', Mandatory = $true, ValueFromPipeline = $true)]
	 	[ValidateNotNullorEmpty()]
        [string]$query,
        
        [Parameter(HelpMessage = 'Item types to return', ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [PSSpotify.ItemTypes[]]$returnTypes = [PSSpotify.ItemTypes]::Track,

        [Parameter(HelpMessage = 'Maximum number of results', ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [ValidateRange(1,100050)]
        [int]$limit=20,

        [Parameter(HelpMessage = 'Offset number of results', ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [ValidateRange(0,100000)]
        [int]$offset=0

    )
    # Search is limited at server at max 50 items (per call)
    $searchLimit = 50
    if( $limit -gt $searchLimit ){
        #Let's break it up
        $res=$null
        do{
            $res = jps $res (PSSpotify-Search -query $query -returnTypes $returnTypes -limit $searchLimit -offset $offset)
            
            $offset += $searchLimit
            $limit  -= $searchLimit
        }while( $limit -gt $searchLimit )

        # Last bit of search range, if any left
        if( $limit -gt 0) {
            $res = jps $res (PSSpotify-Search -query $query -returnTypes $returnTypes -limit $limit -offset $offset)
        }

        return $res        
    } else {
        # The actual/simple call/preparation to Spotify web-api
        $url_spotify="https://api.spotify.com/v1/search?q="
        $queryTypes = '&type=' + ($returnTypes -join ',')
    
        $queryLimit = "&limit=$limit"
        $queryOffset = "&offset=$offset"
        $queryUri = "$($url_spotify)$([System.Web.HttpUtility]::UrlEncode($query))$($queryTypes)$($queryOffset)$($queryLimit)"
        
        Invoke-WebRequest -Uri $queryUri -Headers @{'accept'='application/json'} | ConvertFrom-Json
    }
}


# Example of added value from this
# Sort query based on popularity
# Step 1; large query
$res = PSSpotify-Search -query 'genre:country' -returnTypes Track -limit 150
# Step 2; use simple Powershell-ing to use the Tracks and sort them on popularity (and some fancy output formatting)
$res | Select-Object -ExpandProperty Tracks | Select-Object -ExpandProperty items | sort -Property popularity -Descending | `
ft Name,@{Label="Artist"; Expression={[string]::Join( ", ",( $_.artists | foreach{ $_.Name} ))}},@{Label="AlbumName" ; Expression={$_.Album.Name}},popularity -AutoSize

