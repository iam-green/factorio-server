# Factorio Server

## Docker

### Setup Command

```bash
docker create -it --name factorio-server \
  -p 34197:34197/udp \
  -v /path/to/data:/app/data \
  -v /path/to/lib:/app/lib \
  -v /path/to/factorio:/app/factorio \
  ghcr.io/iam-green/factorio-server:latest
```

### Environments

|   Environment Name    |        Description        |  Default Value  |
| :-------------------: | :-----------------------: | :-------------: |
|          TZ           |       Set Timezone        |  `Asia/Seoul`   |
|          UID          |        Set User ID        |     `1000`      |
|          GID          |       Set Group ID        |     `1000`      |
|    DATA_DIRECTORY     |    Set Data Directory     |   `/app/data`   |
|   LIBRARY_DIRECTORY   |   Set Library Directory   |   `/app/lib`    |
|  FACTORIO_DIRECTORY   |  Set Factorio Directory   | `/app/factorio` |
|        VERSION        |   Set Factorio Version    |    `stable`     |
|       MAP_NAME        |       Set Map Name        |   `factorio`    |
|         PORT          |         Set Port          |     `34197`     |
|   WHITELIST_ENABLE    |     Enable Whitelist      |     `false`     |
|    QUALITY_ENABLE     |    Enable Quality DLC     |     `false`     |
| ELEVATED_RAILS_ENABLE | Enable Elevated Rails DLC |     `false`     |
|   SPACE_AGE_ENABLE    |   Enable Space Age DLC    |     `false`     |

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
  -h, --help                                   Display help and exit.
  -v, --version <stable|experimental|version>  Specify the version of Factorio to install.
  -m, --map-name <name>                        Specify the map name.
  -p, --port <port>                            Specify the port number.
  -w, --whitelist                              Enable whitelist.
  -sa, --space-age                             Enable Space Age DLC.
  -er, --elevated-rails                        Enable Elevated Rails DLC.
  -q, --quality                                Enable Quality DLC.
  -u, --username <username>                    Specify the Factorio account username.
  -pw, --password <password>                   Specify the Factorio account password.
  -t, --token <token>                          Specify the Factorio account token.
  -d, -dd, --data-directory <directory>        Choose the data directory.
  -ld, --library-directory <directory>         Choose the library directory.
  -fd, --factorio-directory <directory>        Choose the Factorio directory.
  -u, --update                                 Update code to the latest version.
```
