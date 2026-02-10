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

## Using Local Submodules

To temporarily point submodules to local directories (without affecting the remote config on GitHub):

```sh
# Allow local file transport (required for Git 2.38.1+)
git config protocol.file.allow always

# Point submodules to local paths
git config submodule.CraneSched.url /path/to/your/local/CraneSched
git config submodule.CraneSched-FrontEnd.url /path/to/your/local/CraneSched-FrontEnd

# Initialize and update submodules to latest master
git submodule update --init --remote
```

This only modifies `.git/config` (local, not committed), leaving `.gitmodules` untouched.

To restore remote URLs:

```sh
git submodule sync
```

To prevent submodule commit changes from being accidentally committed (useful during local development):

```sh
git update-index --assume-unchanged CraneSched
git update-index --assume-unchanged CraneSched-FrontEnd
```

To restore tracking:

```sh
git update-index --no-assume-unchanged CraneSched
git update-index --no-assume-unchanged CraneSched-FrontEnd
```

If you need to re-clone submodules (e.g., after pointing to a wrong URL), clean up and re-initialize:

```sh
rm -rf CraneSched .git/modules/CraneSched
rm -rf CraneSched-FrontEnd .git/modules/CraneSched-FrontEnd
git submodule update --init --remote
```

## Image Variants

- `latest`: Full development environment.
- `full`: Full development environment with MongoDB.
- `ci`: only toolchains for building, no development tools.
