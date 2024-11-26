# PaperMC Docker
This project aims to create a _mostly_ generic set of Docker images for running the papermc.io projects: paper, velocity, and waterfall, with mimimal setup.

*NOTE: These images do not provide papermc.io or Minecraft binaries directly, the necessary binaries are downloaded automatically at runtime.*

## Requirements
- Docker, or equivilent container management system (you're on your own here)

## Basic Usage
This will start the most basic of setups:
- port `25565` is forwarded from the host
- the Minecraft EULA is accepted (if applicable)
- a randomly named volume will be created automatically by Docker, to persist configuration, worlds, and other application files
- the container will automatically download the latest stable version of the respective application on startup

#### Paper
```bash
docker run -p 25565:25565 -e EULA="true" brandonbisel/papermc-paper
```

#### Velocity
```bash
docker run -p 25565:25565 brandonbisel/papermc-velocity
```

#### Waterfall
```bash
docker run -p 25565:25565 brandonbisel/papermc-waterfall
```

## Port
By default, the paper.io apps run on the same port that Minecraft defaults to: `25565`. The `docker run -p` option allows you to specify which port on the host machine is forwarded to the application.
##### Using the default Minecraft port
```bash
docker run -p 25565:25565 -e EULA="true" brandonbisel/papermc-paper
```
##### Using a custom port on the Host machine
```bash
docker run -p 51234:25565 -e EULA="true" brandonbisel/papermc-paper
```

## Environment Variables
Several options are exposed via environment variables. 
#### Usage
```bash
docker run -p 25565:25565 -e VARIABLE_NAME="variable_value" -e VARIABLE_2_NAME="variable_2_value" brandonbisel/papermc-paper
```

#### Common
- `PAPERMC_PROJECT_VERSION`
  - Locks the version of the respective application. For Paper, this generally directly coresponds to the version of Minecraft that it supports.
  - Defaults to `latest` - will automatically determine the latest release
  - Examples: 
    - Paper: `1.21.3`
    - Velocity: `3.4.0-SNAPSHOT`
- `PAPERMC_PROJECT_BUILD`
  - Locks the build of the respective application, in conjunction with the `PAPERMC_PROJECT_VERSION`.
  - Defaults to `latest` - will automatically determine the latest build
  - Example: `63`
- `PAPERMC_PROJECT_CHANNEL`
  - The build channel to pull jars from.
  - Defaults to `default` - will only pull "stable" builds
  - If set to `experimental`, will fall back to the latest "stable" build when the latest build is not "experimental".
- `PAPERMC_PROJECT_RAM`
  - The amount of memory to be allocated to the respective application
  - Defaults:
      - Paper: _unspecified_ - uses the Java defaults
      - Velocity: `1G`
      - Waterfall: `512M`
  - Coresponds to the `-Xms` and `-Xmx` options provdided to Java when executing the application
- `JAVA_OPTS`
  - Additional options that will be passed to Java when executing the application

#### Paper
- `EULA`
  - Sets the Minecraft EULA
  - Must be set to `true` before Minecraft Server will accept connections
  - Required by Minecraft Terms of Service

## Persistent Storage
The image defines a volume to store persistent application data, such as worlds and configuration files. By default, this is automaticall created with a randomly generated name as assigned by Docker. To specify a named volume, or persist data to the filesystem directly, explicitly mount the volume:
#### Named Volume
##### Paper
```bash
docker volume create my-volume
docker run -p 25565:25565 -v "my-volume:/opt/papermc/paper" -e EULA="true" brandonbisel/papermc-paper
```
##### Velocity
```bash
docker volume create my-volume
docker run -p 25565:25565 -v "my-volume:/opt/papermc/velocity" brandonbisel/papermc-velocity
```
##### Waterfall
```bash
docker volume create my-volume
docker run -p 25565:25565 -v "my-volume:/opt/papermc/waterfall" brandonbisel/papermc-waterfall
```

#### Filesystem
##### Paper
```bash
mkdir /path/to/myfiles
docker run -p 25565:25565 -v "/path/to/myfiles:/opt/papermc/paper" brandonbisel/papermc-paper
```
##### Velocity
```bash
mkdir /path/to/myfiles
docker run -p 25565:25565 -v "/path/to/myfiles:/opt/papermc/velocity" brandonbisel/papermc-velocity
```
##### Waterfall
```bash
mkdir /path/to/myfiles
docker run -p 25565:25565 -v "/path/to/myfiles:/opt/papermc/waterfall" brandonbisel/papermc-waterfall
```
## Docker Compose
Example Docker Compose files:

#### Paper
```yaml
services:
  papermc_1:
    container_name: papermc_1
    image: "brandonbisel/papermc-paper:latest"
    volumes:
    - /opt/docker/papermc_1/paper:/opt/papermc/paper
    restart: unless-stopped
    ports:
    - "25565:25565"
    environment:
      EULA: "true"
      PAPERMC_PROJECT_RAM: "4G"
      PAPERMC_PROJECT_VERSION: "1.21.3"
```

#### Velocity
```yaml
services:
  velocity_1:
    container_name: velocity_1
    image: "brandonbisel/papermc-velocity:latest"
    volumes:
    - "/opt/docker/velocity_1/velocity:/opt/papermc/velocity"
    restart: unless-stopped
    ports:
    - "25565:25565"
    environment:
      PAPERMC_PROJECT_RAM: "1G"
```

#### Velocity + Paper Stack
```yaml
networks:
  minecraft_net:
    driver: bridge
    ipam:
      config:
      - subnet: 192.168.33.0/24
        gateway: 192.168.33.1

services:
  papermc_1:
    container_name: papermc_1
    image: "brandonbisel/papermc-paper:latest"
    volumes:
    - "/opt/docker/papermc_1/paper:/opt/papermc/paper"
    restart: unless-stopped
    networks:
      minecraft_net:
        ipv4_address: 192.168.33.100 # Velocity requires a specific IP address for proxied servers
    environment:
      EULA: "true"
      PAPERMC_PROJECT_RAM: "4G"
      PAPERMC_PROJECT_VERSION: "1.21.3"

  velocity_1:
    container_name: velocity_1
    image: "brandonbisel/papermc-velocity:latest"
    volumes:
    - "/opt/docker/velocity_1/velocity:/opt/papermc/velocity"
    restart: unless-stopped
    ports:
    - "25565:25565"
    networks:
    - minecraft_net
    environment:
      PAPERMC_PROJECT_RAM: "1G"
```

## Build
This project is set up to build Paper, Velocity, and Waterfall, all from the same `Dockerfile`. The `papermc_launcher.sh` script is copied to `/opt/papermc/`, and the contents of the respective project directory (`$PAPERMC_PROJECT`) are copied to `/opt/papermc/papermc_setup/`, to be copied into the `/opt/papermc/$PAPERMC_PROJECT/` volume during the first startup.

#### Paper
```bash
docker build --build-arg PAPERMC_PROJECT="paper" --pull --tag "$IMAGE_NAME"
```

#### Velocity
```bash
docker build --build-arg PAPERMC_PROJECT="velocity" --pull --tag "$IMAGE_NAME"
```

#### Waterfall
```bash
docker build --build-arg PAPERMC_PROJECT="waterfall" --pull --tag "$IMAGE_NAME"
```