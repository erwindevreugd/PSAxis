function HashTableToUrlQuery([HashTable]$hashTable) {
    $i = 0
    $query = ''

    foreach($key in $hashTable.Keys) {
        $value = $hashTable[$key]
        
        if($i -eq 0) {
            $query = $query + "?$($key)=$($value)"
        } else {
            $query = $query + "&$($key)=$($value)"
        }

        $i++
    }

    return $query
}

function MapEnum($enum, $value, $default = $null) {
	try {
		[Enum]::GetValues($enum) | Where-Object { $_ -eq $value } 	
	} catch {
		Write-Error $_
		return $default
	}
}