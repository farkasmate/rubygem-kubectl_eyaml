# kubectl-eyaml plugin

Keep sensitive Kubernetes config in version control using encrypted YAML manifests.

## Usage

Prefix `kubectl` commands with *eyaml*:

```
kubectl eyaml apply -f secret.yaml
```
```
kubectl eyaml diff -k .
```

## Install

```
gem install kubectl_eyaml
```

## Config

https://github.com/voxpupuli/hiera-eyaml#basic-usage
