# install-yq-action
Cross-platform [yq](https://github.com/mikefarah/yq) installer composite action

[![Tests - Setup YQ Action](https://github.com/dcarbone/install-yq-action/actions/workflows/tests.yaml/badge.svg)](https://github.com/dcarbone/install-yq-action/actions/workflows/tests.yaml)

# Index

1. [Examples](#examples)
2. [Action Source](action.yaml)
3. [Action Inputs](#action-inputs)
4. [Action Outputs](#action-outputs)

## Examples

* [linux](./.github/workflows/example-linux.yaml)
* [macos](./.github/workflows/example-macos.yaml)
* [windows](./.github/workflows/example-windows.yaml)

## Action Inputs

#### version
```yaml
  version:
    required: false
    description: "Version of YQ to install"
    default: "v4.35.1"
```

This must be a version with a [corresponding release](https://github.com/mikefarah/yq/releases).

#### download-compressed
```yaml
  download-compressed:
    required: false
    description: "If 'true', downloads .tar.gz of binary rather than raw binary.  Save the tubes."
    default: 'true'
```

#### force
```yaml
  force:
    required: false
    description: "If 'true', does not check for existing yq installation before continuing."
    default: 'false'
```

GitHub's own hosted runners come with a version of
[yq pre-installed](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#preinstalled-software).

Setting this to `true` will install the version you specify into the tool cache, superseding the preinstalled version.
Setting this to true can also help ensure the same version is used across both self-hosted and remote runners. 

## Action Outputs

#### found
```yaml
  found:
    description: "If 'true', yq was already found on this runner"
```

#### installed
```yaml
  installed:
    description: "If 'true', yq was installed by this action"
```
