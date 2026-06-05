# Create GitHub Deployment GitHub Action

This GitHub Action creates a new GitHub Deployment using the GitHub REST API and PowerShell.  
It is designed to be simple, composable, and independent of the local git state.

## Features

- Creates a new GitHub Deployment in your repository using the REST API.
- Lets you specify the target ref, deployment environment, and description.
- Fully supports GitHub Organizations and user-owned repositories.
- Outputs the deployment creation result, deployment ID, deployment URL, and error message for use in subsequent workflow steps.
- Designed for secure automation with the minimal required token permissions.

## Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `ref` | The branch, tag or sha of the new deployment | Yes | |
| `environment` | The name of the deployment environment (e.g. development, test, statging, production, etc.) | Yes | |
| `description` | A short description of the deployment | Yes | |
| `org-name` | The name of the GitHub Organization | Yes | |
| `repo-name` | The name of the repository | Yes | |
| `token` | GitHub token with access to create a deployment | Yes | |

## Outputs

| Name | Description |
|------|-------------|
| `result` | Result of the action (`success` or `failure`) |
| `error-message` | Error message if the action fails |
| `deployment-id` | The id of the new deployment |
| `deployment-url` | The URL of the new deployment |

## Usage

Create a workflow file in your repository (for example, `.github/workflows/create-deployment.yml`).  
**Ensure you pass all required inputs and use a valid token with deployment write access.**

### Example Workflow

```yaml
name: Create GitHub Deployment
on:
  workflow_dispatch:

jobs:
  create-deployment:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v5

      - name: Create GitHub Deployment via API
        id: create-deployment
        uses: lee-lott-actions/create-github-deployment@v1
        with:
          ref: 'main'
          environment: 'production'
          description: 'Deploy main to production'
          repo-name: ${{ github.event.repository.name }}
          org-name: ${{ github.repository_owner }}
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Output Deployment Result
        run: |
          echo "Deployment Result: ${{ steps.create-deployment.outputs.result }}"
          echo "Deployment ID: ${{ steps.create-deployment.outputs.deployment-id }}"
          echo "Deployment URL: ${{ steps.create-deployment.outputs.deployment-url }}"
          echo "Error Message: ${{ steps.create-deployment.outputs.error-message }}"
```
