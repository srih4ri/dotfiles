function git-init-push --description "Initialize git repo and push to srih4ri/<folder-name>"
    set -l repo_owner "srih4ri"
    set -l repo_name (basename (pwd))
    set -l remote_url "git@github.com:$repo_owner/$repo_name.git"

    # Initialize git if not already a repo
    if not test -d .git
        echo "Initializing git repository..."
        git init
        if test $status -ne 0
            echo "Failed to initialize git repository"
            return 1
        end
    end

    # Check if there are any commits, if not create initial commit
    if not git rev-parse HEAD >/dev/null 2>&1
        # Check if there are any files to commit
        if test (git status --porcelain | wc -l) -eq 0
            echo "No files found. Creating README.md..."
            echo "# $repo_name" > README.md
        end
        echo "Creating initial commit..."
        git add -A
        git commit -m "Initial commit"
        if test $status -ne 0
            echo "Failed to create initial commit"
            return 1
        end
    end

    # Set up remote origin
    if git remote get-url origin >/dev/null 2>&1
        echo "Remote 'origin' already exists, updating URL..."
        git remote set-url origin $remote_url
    else
        echo "Adding remote 'origin'..."
        git remote add origin $remote_url
    end

    # Try to push
    echo "Attempting to push to $repo_owner/$repo_name..."
    if git push -u origin (git branch --show-current) 2>/dev/null
        echo "Successfully pushed to $repo_owner/$repo_name"
        return 0
    end

    # Push failed, check if repo exists
    echo "Push failed. Checking if repository exists..."
    if gh repo view "$repo_owner/$repo_name" >/dev/null 2>&1
        echo "Repository exists but push failed. Check your permissions."
        return 1
    end

    # Repo doesn't exist, prompt for creation
    echo "Repository '$repo_owner/$repo_name' does not exist."
    read -P "Create private repository '$repo_owner/$repo_name'? [y/N] " confirm

    if test "$confirm" != "y" -a "$confirm" != "Y"
        echo "Aborted."
        return 1
    end

    # Create the repository
    echo "Creating private repository '$repo_owner/$repo_name'..."
    if not gh repo create "$repo_owner/$repo_name" --private
        echo "Failed to create repository"
        return 1
    end

    # Push again
    echo "Pushing to newly created repository..."
    if git push -u origin (git branch --show-current)
        echo "Successfully pushed to $repo_owner/$repo_name"
        return 0
    else
        echo "Push failed after creating repository"
        return 1
    end
end
