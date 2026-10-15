# Azure Artifacts Credential Provider (azure-artifacts-credprovider)

Installs the Azure Artifacts Credential Provider so dotnet/nuget can authenticate to Azure Artifacts feeds

## Example Usage

```json
"features": {
    "ghcr.io/rafaelkallis/devcontainer-features/azure-artifacts-credprovider:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the Azure Artifacts Credential Provider version to install. Use a release tag (e.g. '2.0.4'). | string | latest |
| installLibsecretAndXdgUtils | Install libsecret-1-0 and xdg-utils (Debian/Ubuntu) for interactive browser-based authentication. Disable to skip if already present. | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/rafaelkallis/devcontainer-features/blob/main/src/azure-artifacts-credprovider/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
