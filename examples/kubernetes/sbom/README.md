# Create SBOMs with syft
In this exercise we will learn how to create an SBOM in one of the industry formats and then we'll do stuff with this.

## Ensure syft and grype are installed
```bash
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
```

> [!WARNING]
> By default the installation scripts installs the tools under `bin/syft`! We are forcing the installer to installe them under `/usr/local/bin`

## Ensure `jq` is installed
```bash
curl -L -o /usr/local/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64
chmod +x /usr/local/bin/jq
```

## Create a CYCLONEDX-JSON SBOM for `nginx:1.10`
```bash
syft nginx:1.10 -o cyclonedx-json=./nginx.cyclonedx.sbom.json
```

## Analyze the vulnerabilities with `grype`
```bash
grype sbom:./nginx.cyclonedx.sbom.json -o json=./nginx-report.json
```

## Count the number of Medium vulnerabilites with `jq`
```bash
jq -r '[.matches[] | select(.vulnerability.severity == "Medium")] | length' ./nginx-report.json
```
It should be 294!