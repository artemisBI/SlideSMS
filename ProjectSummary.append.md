## Git identity & SSH key update (project-local instructions)

The notes below show the environment variables and Git settings to change for this repository so commits and SSH authentication use the new profile/email `jonas.pascua@artemis-bi.com`.

Summary of what to update
- Repository-local Git identity (`user.name`, `user.email`) — recommended for project-specific profile.
- Environment variables that affect commits: `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_NAME`, `GIT_COMMITTER_EMAIL` (session or persistent via `setx`).
- SSH key used for Git authentication — generate a new ed25519 key with the new email and add it to your Git host (GitHub/GitLab/Bitbucket).
- Windows Credential Manager entries if you used HTTPS auth.
- Remote URL only if you are switching accounts or switching HTTPS ↔ SSH.

Quick PowerShell commands (run in your repo root)

1) Inspect current Git config and origins

```powershell
git config --list --show-origin
git config --get user.name
git config --get user.email
git config --global --get user.email
```

2) Set repository-local Git identity (recommended for project-specific profile)

```powershell
# in the repo root
git config user.name "Jonas Pascua"
git config user.email "jonas.pascua@artemis-bi.com"

# verify
git config --get user.name
git config --get user.email
git config --list --show-origin
```

If you prefer to change the identity globally for your user on this machine, add `--global` to the commands above.

3) (Optional) Set environment variables for the current PowerShell session

```powershell
$env:GIT_AUTHOR_NAME      = "Jonas Pascua"
$env:GIT_AUTHOR_EMAIL     = "jonas.pascua@artemis-bi.com"
$env:GIT_COMMITTER_NAME   = "Jonas Pascua"
$env:GIT_COMMITTER_EMAIL  = "jonas.pascua@artemis-bi.com"
```

Make them persistent for future sessions using `setx` (affects future shells):

```powershell
setx GIT_AUTHOR_NAME "Jonas Pascua"
setx GIT_AUTHOR_EMAIL "jonas.pascua@artemis-bi.com"
setx GIT_COMMITTER_NAME "Jonas Pascua"
setx GIT_COMMITTER_EMAIL "jonas.pascua@artemis-bi.com"
```

4) Generate a new ed25519 SSH key (replace your previous command email)

```powershell
ssh-keygen -t ed25519 -C "jonas.pascua@artemis-bi.com" -f $env:USERPROFILE\\.ssh\\id_ed25519
# Press Enter to accept no passphrase or provide one for extra security
```

5) Start ssh-agent and add the new key, then copy the public key to the clipboard

```powershell
# Start agent (Windows built-in OpenSSH)
Start-Service ssh-agent
ssh-add $env:USERPROFILE\\.ssh\\id_ed25519

# Copy public key to clipboard for adding to Git host (GitHub/GitLab/Bitbucket)
Get-Content $env:USERPROFILE\\.ssh\\id_ed25519.pub | Set-Clipboard
```

Then paste into your Git host's SSH keys settings (e.g., GitHub: Settings → SSH and GPG keys → New SSH key).

6) Optional SSH config (if you have multiple keys)

Create or edit `C:\\Users\\<you>\\.ssh\\config` and add:

```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
```

7) Clearing old HTTPS credentials (Windows)

Open Windows Credential Manager (Control Panel → Credential Manager → Windows Credentials) and remove entries related to `git:` or `github.com`. The next pull/push over HTTPS will prompt for credentials (or you can switch to SSH as above).

8) Update remote URL (if switching to SSH)

```powershell
git remote -v
git remote set-url origin git@github.com:jpascua313/savethis.git
```

9) Verify SSH authentication

```powershell
ssh -T git@github.com
```

You should see a welcome message that includes the GitHub username associated with the key you added.

10) (Optional) Change the author/committer of the last commit only

```powershell
git commit --amend --author="Jonas Pascua <jonas.pascua@artemis-bi.com>" --no-edit
# If the commit was already pushed, you'll need to force-push:
git push --force-with-lease
```

11) (Optional & destructive) Rewrite all past commits' author/committer emails

Warning: rewriting history is destructive for any branch already shared with others. Coordinate with collaborators and prefer using `git-filter-repo` (faster/safer) if available. If you must, run these operations in a clone and be prepared to force-push.

Example (high-level guidance):
- Install and run `git-filter-repo` to replace `jpascua@gmail.com` with `jonas.pascua@artemis-bi.com` in author/committer fields, or
- Use `git filter-branch` only if you can't install filter-repo (run from Git Bash or WSL on Windows).

If you want the exact `git-filter-repo` or `filter-branch` commands for this repo, tell me and I will prepare them (I will not rewrite history unless you confirm).

Notes & verification
- Prefer repository-local config so this change only affects this project: `git config user.email "jonas.pascua@artemis-bi.com"` (no `--global`).
- Use `git config --list --show-origin` to confirm where each value is coming from.
- If CI pipelines make commits, update their variables to the new email (CI environment variables or secret keys named like `GIT_AUTHOR_EMAIL`).

Saved: 2025-11-08 — appended instructions to help you switch this repo to `jonas.pascua@artemis-bi.com`.
