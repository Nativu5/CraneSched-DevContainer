# Dev Container for CraneSched

Portable development environment for [CraneSched](https://github.com/PKUHPC/CraneSched).

## Quick Start

1. Open VS Code and install Dev Container extension.  
2. Copy .devcontainer folder to your project.
3. Reopen the project in the container.

To learn more about Dev Container, see [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers).

For advanced configuration, see [Dev Container metadata reference](https://containers.dev/implementors/json_reference/). 

## Without VS Code

If not using VS Code, refer to below commands for manual build and run: 

- Build and push
    ```sh
    docker build -t ghcr.io/nativu5/cranedev:full .
    docker push ghcr.io/nativu5/cranedev:full
    ```

- Pull and run
    ```sh
    docker pull ghcr.io/nativu5/cranedev:full
    docker run -it --rm --name cranedev ghcr.io/nativu5/cranedev:full
    ```
- Connect with SSH
    
    SSH server is running on port 22. 
    
    The default user is `root` with password `xFeN1L1Hkbtw`.

## Image Variants

- `latest`: Full development environment.
- `full`: Full development environment with MongoDB.
- `ci`: only toolchains for building, no development tools.
