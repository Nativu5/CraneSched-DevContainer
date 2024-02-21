# DevContainer for CraneSched

## Quick Start

1. Open VSCode and configure DevContainer. 
2. Add .devcontainer to your project.
3. Reopen the project in the container.

See [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers) for more information.

## Image

- Build and push
```bash
docker build -t registry.cn-shanghai.aliyuncs.com/nativus/cranedev:latest .
docker push registry.cn-shanghai.aliyuncs.com/nativus/cranedev:latest
```

- Pull and run
```bash
docker pull registry.cn-shanghai.aliyuncs.com/nativus/cranedev:latest
docker run -it --rm --name cranedev registry.cn-shanghai.aliyuncs.com/nativus/cranedev:latest
```
