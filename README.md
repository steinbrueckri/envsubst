[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=steinbrueckri/envsubst)](https://dependabot.com)

# Docker image for 'envsubst'

This image will process a filename which is passed as an argument and substitute $FOO placeholders with ENVIRONMENT VARIABLE values. A new file of the same name is written to the `/processed` directory.

## Examples

### Local

```sh
docker run --rm -v $(pwd)/workdir:/workdir -v $(pwd)/processed:/processed -e "VAR_1=A" -e "VAR_2=b" steinbrueckri/envsubst:latest
```

### K8s

This can be useful when running on Kubernetes and you wish to update placeholders in config files.

This image can run as an init-container after mounting a configmap into `/workdir`.  Because config map files are readonly you'll also need to mount an `emptyDir: {}` volume to the init-container `/processed` folder as well as in the main pod container where you wish your new config to be mounted.

An example:

```yaml
[...]
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: myContainer
        image: alpine
        volumeMounts:
        - name: config
          mountPath: /config
      initContainers:
      - name: init-config
        image: steinbrueckri/envsubst:latest
        env:
        - name: mySecretVar
          valueFrom:
            secretKeyRef:
              name: mySecret
              key: key
        volumeMounts:
        - name: config
          mountPath: /processed
        - name: workdir
          mountPath: /workdir
      volumes:
      - name: workdir
        configMap:
          name: myConfigMap
      - name: config
        emptyDir: {}
```

## Release

- create new branch
- make your changes, if needed
- commit your changes like
  - Patch Release: `fix(script): validate input file to prevent empty files`
  - Minor Release: `feat(dockerimage): add open for multiple input files`
  - Major Release [look her](https://github.com/mathieudutour/github-tag-action/blob/master/README.md)
