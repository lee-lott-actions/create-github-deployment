function New-Deployment {
    param (
	    [string]$Ref,
	    [string]$Environment,
	    [string]$Description,
	    [string]$OrgName,
	    [string]$RepoName,
	    [string]$Token
    )

	# Validate required inputs
	if ([string]::IsNullOrEmpty($Ref) -or
		[string]::IsNullOrEmpty($Environment) -or
		[string]::IsNullOrEmpty($Description) -or
		[string]::IsNullOrEmpty($OrgName) -or
		[string]::IsNullOrEmpty($RepoName) -or
		[string]::IsNullOrEmpty($Token))
	{
		Write-Output "Error: Missing required parameters"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: Ref, Environment, Description, OrgName, RepoName, and Token must be provided."
		Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
		return
	}   

    # Use MOCK_API if set, otherwise default to GitHub API
    $githubApiUrl = $env:MOCK_API
	if (-not $githubApiUrl) { $githubApiUrl = "https://api.github.com" }
	$uri = "$githubApiUrl/repos/$OrgName/$RepoName/deployments"
	
    $headers = @{
		Authorization = "Bearer $Token"
		"Accept" = "application/vnd.github+json"
		"X-GitHub-Api-Version" = "2026-03-10"
		"Content-Type" = "application/json"		
	}

	$body = @{
		ref         = $Ref
		environment = $Environment
		description = $Description
	} | ConvertTo-Json

	try {
		Write-Host "Creating deployment for reference $Ref"
		$response = Invoke-WebRequest -Uri $uri -Headers $headers -Method POST -Body $body -SkipHttpErrorCheck

        if ($response.StatusCode -eq 201) {
			$deployment = $response.Content | ConvertFrom-Json
			Add-Content -Path $env:GITHUB_OUTPUT -Value "deployment_id=$($deployment.id)"
			Add-Content -Path $env:GITHUB_OUTPUT -Value "deployment_url=$($deployment.url)"
			Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
			Write-Host "Deployment created. ID: $($deployment.id)"
        } else {
			$errorMsg = "Error: Deployment creation failed. Status code: $($response.StatusCode)"
			Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
			Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
			Write-Host $errorMsg
        }
	} catch {
		$errorMsg = "Error: Deployment creation failed. Exception: $($_.Exception.Message)"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
		Write-Host $errorMsg
	}
}
