# Auto Utils Template

> This template repository provides a cross-platform setup for automation scripts using Docker, Batch, PowerShell, and Shell scripts.<br>
> It helps you bootstrap repeatable environments quickly and consistently across Windows, macOS, and Linux.

## Docker

### Setup Command

```bash
docker create -it --name auto-utils-template \
  ghcr.io/iam-green/auto-utils-template
```

### Environments

| Environment Name  |      Description      | Default Value |
| :---------------: | :-------------------: | :-----------: |
|        TZ         |     Set Timezone      | `Asia/Seoul`  |
|        UID        |      Set User ID      |    `1000`     |
|        GID        |     Set Group ID      |    `1000`     |
|  DATA_DIRECTORY   |  Set Data Directory   |  `/app/data`  |
| LIBRARY_DIRECTORY | Set Library Directory |  `/app/lib`   |

## Windows

### Setup Command

```batch
.\start.bat
```

### Options

```
  -h, -help                             Display help and exit.
  -d, -dd, -data-directory <directory>  Choose the data directory.
  -ld, -library-directory <directory>   Choose the library directory.
  -u, -update                           Update code to the latest version.
```

## macOS & Linux

### Setup Command

```bash
chmod +x ./start.sh && ./start.sh
```

### Options

```
  -h, --help                             Display help and exit.
  -d, -dd, --data-directory <directory>  Choose the data directory.
  -ld, --library-directory <directory>   Choose the library directory.
  -u, --update                           Update code to the latest version.
```
