### Setup Repo Secret and Create GITHUB PAT Token
```
Create Classic Personal Access token as below
repo (Full control) # For setup runner
write:packages # For Using Github docker repo
```
- Create GH_TOKEN secret in your fork repository with value above


### Using `setup.sh` for Automated Setup

1. Ensure you have execution permissions for the script:
  ```sh
  chmod +x setup.sh
  ```
2. Run the script to set up the environment:
  ```sh
  bash setup.sh
  ```

### What `setup.sh` Does

- Installs necessary dependencies.
- Sets up environment variables.
- Setup K8s Cluster using kind
- Deploy Self host github action Runner to your repo

### Troubleshooting `setup.sh`

- **Permission Denied**: Ensure the script has execution permissions.
- **Environment Variable Issues**: Double-check that all necessary environment variables are correctly set.

Configuration options and their effects




### OutCome
- [ ] Implement a build script (build.sh)
- [ ] Kubernetes manifests
- [ ] Implement a deployment script (deploy.sh) to apply the Kubernetes manifests.
- [ ] CICD using Github action

- [ ] Document the setup process in the README.
- [ ] Create unit tests for the setup script.
- [ ] Set up continuous integration for automated testing.
- [ ] Ensure cross-platform compatibility.

### Bonus
- [ ] Implement monitoring and logging solutions.
- [ ] Add rollback capabilities to the deployment process.
- [ ] Integrate with a package manager for dependency management.
- [ ] Implement multi-stage builds for optimized Docker images
