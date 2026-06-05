Describe "New-Deployment" {
    BeforeAll {
        $script:Ref           = "v1.2.3"
        $script:Environment   = "production"
        $script:Description   = "This is a description of the deployment"
		$script:OrgName       = "test-org"
		$script:RepoName      = "test-repo"
        $script:Token         = "fake-token"
        $script:MockApiUrl    = "http://127.0.0.1:3000"
        . "$PSScriptRoot/../action.ps1"
    }

	BeforeEach {
        $env:GITHUB_OUTPUT = New-TemporaryFile
        $env:MOCK_API = $script:MockApiUrl
    }
	
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
    }

	Context "Success Cases" {
	    It "unit: New-Deployment succeeds with HTTP 201" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 201; Content = '{"id": "123", "url": "http://127.0.0.1/deployments/123"}' }
	        }
			
	        New-Deployment -Ref $Ref -Environment $Environment -Description $Description -OrgName $OrgName -RepoName $RepoName -Token $Token
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
			$output | Should -Contain "deployment_id=123"
			$output | Should -Contain "deployment_url=http://127.0.0.1/deployments/123"
	    }
	}

	Context "HTTP Failure Cases" {
	    It "unit: New-Deployment fails with HTTP 404" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 404; Content = '{"message":"Repository not found"}' }
	        }
			
	        New-Deployment -Ref $Ref -Environment $Environment -Description $Description -OrgName $OrgName -RepoName $RepoName -Token $Token
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Error: Deployment creation failed. Status code: 404"
	    }
	}

	Context "Parameter Validation Failure Cases" {
	    It "unit: New-Deployment fails with empty Ref" {
	        New-Deployment -Ref "" -Environment $Environment -Description $Description -OrgName $OrgName -RepoName $RepoName -Token $Token
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: Ref, Environment, Description, OrgName, RepoName, and Token must be provided."
	    }

	    It "unit: New-Deployment fails with empty Environment" {
	        New-Deployment -Ref $Ref -Environment "" -Description $Description -OrgName $OrgName -RepoName $RepoName -Token $Token
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: Ref, Environment, Description, OrgName, RepoName, and Token must be provided."
	    }
      
    	It "unit: New-Deployment fails with empty Description" {
	        New-Deployment -Ref $Ref -Environment $Environment -Description "" -OrgName $OrgName -RepoName $RepoName -Token $Token
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: Ref, Environment, Description, OrgName, RepoName, and Token must be provided."
	    }

    	It "unit: New-Deployment fails with empty OrgName" {
	        New-Deployment -Ref $Ref -Environment $Environment -Description $Description -OrgName "" -RepoName $RepoName -Token $Token
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: Ref, Environment, Description, OrgName, RepoName, and Token must be provided."
	    }

    	It "unit: New-Deployment fails with empty RepoName" {
	        New-Deployment -Ref $Ref -Environment $Environment -Description $Description -OrgName $OrgName -RepoName "" -Token $Token
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: Ref, Environment, Description, OrgName, RepoName, and Token must be provided."
	    }		
		      	
	    It "unit: New-Deployment fails with empty Token" {
	        New-Deployment -Ref $Ref -Environment $Environment -Description $Description -OrgName $OrgName -RepoName $RepoName -Token ""
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: Ref, Environment, Description, OrgName, RepoName, and Token must be provided."
	    }
	}

	Context "Exception Failure Cases" {
		It "unit: New-Deployment fails with exception" {
			Mock Invoke-WebRequest { throw "API Error" }
	
			try {
				New-Deployment -Ref $Ref -Environment $Environment -Description $Description -OrgName $OrgName -RepoName $RepoName -Token $Token
			} catch {}
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Where-Object { $_ -match "^error-message=Error: Deployment creation failed. Exception: " } |
				Should -Not -BeNullOrEmpty
		}		
	}
}
