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

### OutCome
- [x] Implement a setup script (setup.sh)
- [x] Implement a build script (build.sh)
- [ ] Application Modification full-stack web application backend + frontend - No Just one service
- [x] Kubernetes manifests
- [x] Implement a deployment script (deploy.sh) to apply the Kubernetes manifests.
- [x] CICD using Github action

- [x] Document the setup process in the README.
- [ ] Create unit tests for the setup script.
- [ ] Set up continuous integration for automated testing.
- [x] Ensure cross-platform compatibility.

### Bonus
- [ ] Implement monitoring and logging solutions.
- [x] Add rollback capabilities to the deployment process.
- [x] Integrate with a package manager for dependency management.
- [ ] Implement multi-stage builds for optimized Docker images



### Verify
#### Build script local

```
bash build.sh
❯ docker image ls
REPOSITORY                                                               TAG                                         IMAGE ID       CREATED         SIZE
ghcr.io/sonthanhcao/es-devops-frontend                                   latest                                      6ebd775cad16   2 minutes ago   1.71GB
ghcr.io/sonthanhcao/es-devops                                            latest                                      6ebd775cad16   2 minutes ago   1.71GB
```
#### K8s
```
root@ip-10-101-240-5:/opt/es-devops# kubectl get pod -A
NAMESPACE            NAME                                         READY   STATUS      RESTARTS   AGE
arc-systems          arc-gha-rs-controller-7f9f7c6875-gcbhn       1/1     Running     0          75m
arc-systems          shared-github-runner-754b578d-listener       1/1     Running     0          75m
development          es-devops-7ddcf8669c-2v8j7                   1/1     Running     0          109s
development          es-devops-7ddcf8669c-sv42f                   1/1     Running     0          2m14s
ingress-nginx        ingress-nginx-admission-create-9jb2v         0/1     Completed   0          75m
ingress-nginx        ingress-nginx-admission-patch-ctkn5          0/1     Completed   0          75m
ingress-nginx        ingress-nginx-controller-6b8cfc8d84-2q5mn    1/1     Running     0          75m
kube-system          coredns-6f6b679f8f-csx5r                     1/1     Running     0          75m
kube-system          coredns-6f6b679f8f-s9clg                     1/1     Running     0          75m
kube-system          etcd-kind-control-plane                      1/1     Running     0          76m
kube-system          kindnet-9w6rz                                1/1     Running     0          75m
kube-system          kube-apiserver-kind-control-plane            1/1     Running     0          76m
kube-system          kube-controller-manager-kind-control-plane   1/1     Running     0          76m
kube-system          kube-proxy-w9rdg                             1/1     Running     0          75m
kube-system          kube-scheduler-kind-control-plane            1/1     Running     0          76m
local-path-storage   local-path-provisioner-57c5987fd4-gm6kr      1/1     Running     0          75m
production           es-devops-7ddcf8669c-4w8ks                   1/1     Running     0          68s
production           es-devops-7ddcf8669c-x6mlz                   1/1     Running     0          69s
```
#### Rollback
- Open Rollback Deploymnet Workflows  
- Click Run Workflows Set Image tag you want to roll back Eg: `da26ea903d56719b629e693e03d3a25098a1ec09` or `v0.0.1`
