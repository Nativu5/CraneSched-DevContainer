# Dev Container for CraneSched

## Quick Start

1. Open VS Code and configure Dev Container. 
2. Copy .devcontainer folder to your project.
3. Reopen the project in the container.

To learn more about Dev Container in VS Code, see [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers) 

For advanced configuration, see [Dev Container metadata reference](https://containers.dev/implementors/json_reference/). 

## Without VS Code

If not using VS Code, refer to below commands for manual build and run: 

- Build and push
    ```sh
    docker build -t registry.cn-shanghai.aliyuncs.com/nativus/cranedev:latest .
    docker push registry.cn-shanghai.aliyuncs.com/nativus/cranedev:latest
    ```

- Pull and run
    ```sh
    docker pull registry.cn-shanghai.aliyuncs.com/nativus/cranedev:latest
    docker run -it --rm --name cranedev registry.cn-shanghai.aliyuncs.com/nativus/cranedev:latest
    ```
