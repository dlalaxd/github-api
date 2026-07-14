#!/usr/bin/env bash

# =============================================================================
# GitHub Repository Collaborators with Read Access
# Lists users who have read (pull) access to a GitHub repository.
# =============================================================================

set -euo pipefail

# Configuration
API_URL="https://api.github.com"

# Check for required environment variables
if [[ -z "${GITHUB_USERNAME:-}" || -z "${GITHUB_TOKEN:-}" ]]; then
    echo "Error: GITHUB_USERNAME and GITHUB_TOKEN environment variables must be set." >&2
    echo "Usage: GITHUB_USERNAME=youruser GITHUB_TOKEN=ghp_... $0 <owner> <repo>" >&2
    exit 1
fi

# Input validation
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <repository-owner> <repository-name>" >&2
    echo "Example: $0 octocat Hello-World" >&2
    exit 1
fi

REPO_OWNER="$1"
REPO_NAME="$2"

# Function to make authenticated GET request to GitHub API
github_api_get() {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    curl -s -L \
         -u "${GITHUB_USERNAME}:${GITHUB_TOKEN}" \
         -H "Accept: application/vnd.github.v3+json" \
         "$url"
}

# Function to list users with read (pull) access
list_users_with_read_access() {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    local collaborators

    collaborators=$(github_api_get "$endpoint" | jq -r '
        .[] | 
        select(.permissions.pull == true) | 
        .login
    ' 2>/dev/null || true)

    if [[ -z "${collaborators:-}" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}." 
        return 0
    fi

    echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
    echo "$collaborators"
}

# Main execution
echo "Fetching collaborators for ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
