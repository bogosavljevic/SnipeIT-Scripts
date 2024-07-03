# Snipe-IT API token and URL
#by Dimitrije Bogosavljevic
$ApiToken = "API token generated from SnipeIT"
$SnipeItUrl = "Your SnipeIT end-point"
$logFilePath = "logfile.log"  # Specify the path to your log file

# Country to company ID mapping
$countryCompanyMap = @{
    "DE" = 1
    "CH" = 4
    "UK" = 5
    "GB" = 5
    # Add more countries and their corresponding company IDs here
}
function Update-UserCompany {
    param (
        [string]$userId,
        [string]$firstName,
        [string]$userName,
        [int]$newCompanyId,
        [string]$email
    )

    $headers = @{
        "Authorization" = "Bearer $ApiToken"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    # Prepare update payload to change company ID
    $updatePayload = @{
        "first_name" = $firstName
        "username"   = $userName
        "company_id" = $newCompanyId
    }

    # API request to update user company
    $userUpdateUri = "$SnipeItUrl/api/v1/users/$userId"
    try {
        $updateResponse = Invoke-RestMethod -Uri $userUpdateUri -Method Put -Headers $headers -Body ($updatePayload | ConvertTo-Json)
        Write-Host "Company ID for $email updated successfully to $newCompanyId."
    } catch {
        $errorMessage = "Failed to update company ID for $email. Error: $_"
        Write-Host $errorMessage
        Add-Content -Path $logFilePath -Value "$(Get-Date) - $errorMessage"
    }
}

function Get-CompanyIdByCountry {
    param (
        [string]$country
    )

    if ($countryCompanyMap.ContainsKey($country)) {
        return $countryCompanyMap[$country]
    } else {
        return $null
    }
}
function Update-UserCompany {
    param (
        [string]$userId,
        [string]$firstName,
        [string]$userName,
        [int]$newCompanyId,
        [string]$email
    )

    $headers = @{
        "Authorization" = "Bearer $ApiToken"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    # Prepare update payload to change company ID
    $updatePayload = @{
        "first_name" = $firstName
        "username"   = $userName
        "company_id" = $newCompanyId
    }

    # API request to update user company
    $userUpdateUri = "$SnipeItUrl/api/v1/users/$userId"
    try {
        $updateResponse = Invoke-RestMethod -Uri $userUpdateUri -Method Put -Headers $headers -Body ($updatePayload | ConvertTo-Json)
        Write-Host "Company ID for $email updated successfully to $newCompanyId."
    } catch {
        $errorMessage = "Failed to update company ID for $email. Error: $_"
        Write-Host $errorMessage
        Add-Content -Path $logFilePath -Value "$(Get-Date) - $errorMessage"
    }
}

function Get-CompanyIdByCountry {
    param (
        [string]$country
    )

    if ($countryCompanyMap.ContainsKey($country)) {
        return $countryCompanyMap[$country]
    } else {
        return $null
    }
}

function Process-Users {
    param (
        [int]$offset = 0
    )

    $headers = @{
        "Authorization" = "Bearer $ApiToken"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    $userListUri = "$SnipeItUrl/api/v1/users?limit=500&offset=$offset"
    $userResponse = Invoke-RestMethod -Uri $userListUri -Method Get -Headers $headers

    foreach ($user in $userResponse.rows) {
        $userId = $user.id
        $firstName = $user.first_name
        $userName = $user.username
        $userCountry = $user.country  # Assuming 'country' is the correct field name
        $email = $user.email

        if ($null -eq $userCountry) {
            $errorMessage = "Country not found for user: $email"
            Write-Host $errorMessage
            Add-Content -Path $logFilePath -Value "$(Get-Date) - $errorMessage"
            continue
        }

        $newCompanyId = Get-CompanyIdByCountry -country $userCountry

        if ($null -eq $newCompanyId) {
            $errorMessage = "No company ID mapped for country: $userCountry for user: $email"
            Write-Host $errorMessage
            Add-Content -Path $logFilePath -Value "$(Get-Date) - $errorMessage"
            continue
        }

        Update-UserCompany -userId $userId -firstName $firstName -userName $userName -newCompanyId $newCompanyId -email $email
    }

    if ($userResponse.total -gt ($offset + 500)) {
        Process-Users -offset ($offset + 500)
    }
}

# Main script starts here
Process-Users -offset 0
