## Flux

Contents:
- Flux UI using Wave GitOps
- Scripts to automate the installation and initialization of Flux and K8s
- Secret managment with sops.

### Generate a private key per cluster

Each cluster folder in `./clusters/` should have a git ignored `sops.agekey` file, whose public key
is listed in `./.sops.yaml` with a path_regex that involves files that only belong to that cluster.

You can generate a key like this:

```sh
# One key per file
age-keygen > clusters/dev/sops.agekey
```

You should have a file there with a format like this:

```sh
$ cat sops.agekey
# created: 2023-07-17T14:07:50+02:00
# public key: age1v6q8sylunaq9m08rwxq702enmmh9lama7sp47vkcw3z8wm74z39q846s3y
AGE-SECRET-KEY-THIS_IS_A_SECRET_THAT_SHOULD_NEVER_BE_PUSHED
```

Normally, you would need to put an `AGE-SECRET-*` value that is shared within your team. The
`sops.agekey` file will never be pushed to the repo as it is git ignored.

The public key of this file should be added to the relevant `.sops.yaml` entries.

### Create resources

Make sure to add your credentials in the `.envrc` file.

To initialize a cluster and test the setup, we can execute the following command, which will create a cluster using kind and delete it afterwards.

```
make e2e
```

If you want to create other clusters, i.e. for prod:

```
make create-prod
```

### Flux UI
To access the Flux UI on a cluster, first start port forwarding with:

```
kubectl -n flux-system port-forward svc/weave-gitops 9001:9001
```
Navigate to http://localhost:9001 and login using the username `admin` and the password `flux`.
