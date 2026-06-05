# Create GitHub Deployment GitHub Action

This GitHub Action creates a GitHub deployment using the GitHub REST API.  

## Features
- Creates a deployment for the given reference and environment.
- Uses the GitHub REST API (no dependencies on the CLI or local git).
- Fully supports GitHub Organizations and user-owned repositories.
- Outputs the deployment id and url for use in subsequent workflow steps.

## Inputs
| Name          | Description                                           | Required | Default |
|---------------|-------------------------------------------------------|----------|---------|
| `ref`         | The branch, tag or sha of the new deployment          | Yes      | N/A     |
| `environment` | The name of the deployment environment (e.g. development, test, statging, production, etc.) | Yes      | N/A     |
| `description` | A short description of the deployment                 | Yes      | N/A    |
| `org-name`    | The name of the GitHub Organization                   | Yes      | N/A    |
| `repo-name`   | The name of the repository                            | Yes      | N/A    |
| `token`       | GitHub token with access to create a deployment       | Yes      | N/A    |

## Outputs
| Name           | Description                                                   |
|----------------|---------------------------------------------------------------|
| `result`        | Result of the action ("success" or "failure")                |
| `error-message` | Error message if the action fails                            |
| `deployment-id` | The id of the new deployment                                 |
| `deployment-url`| The URL of the new deployment                                |

## Usage
1. **Add the Action to Your Workflow**:
   Create or update a workflow file (e.g., `.github/workflows/create-deployment.yml`) in your repository.
   **Ensure you pass all required inputs and use a valid token with PR write access.**

3. **Reference the Action**:
   Use the action by referencing the repository and version (e.g., `v1`).

4. **Example Workflow**:
   ```yaml
   name: Create New GitHub Deployment
   on:
     workflow_dispatch:
   
   jobs:
     new-deployment:
       runs-on: ubuntu-latest
       steps:
         - name: Run Action
           id: new-deployment
           uses: lee-lott-actions/create-deployment@v1
           with:
             ref: 'v1.2.3'
             environment: 'production'
             description: 'This is a deployment to production.'
             org-name: ${{ github.repository_owner }}
             repo-name: ${{ github.event.repository.name }}
             token: ${{ secrets.GITHUB_TOKEN }}
         - name: Print Result
           run: |
             if [[ "${{ steps.new-deployment.outputs.result }}" == "success" ]]; then
               echo "New deployment successfully created."
             else
               echo "Error: ${{ steps.new-deployment.outputs.error-message }}"
               exit 1
             fi
   ```
