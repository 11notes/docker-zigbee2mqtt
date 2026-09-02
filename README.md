![banner](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/banner/README.png)

# ZIGBEE2MQTT
![size](https://img.shields.io/badge/image_size-99MB-green?color=%2338ad2d)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![pulls](https://img.shields.io/docker/pulls/11notes/zigbee2mqtt?color=2b75d6)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)[<img src="https://img.shields.io/github/issues/11notes/docker-zigbee2mqtt?color=7842f5">](https://github.com/11notes/docker-zigbee2mqtt/issues)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

run zigbee2mqtt rootless and distroless.

# INTRODUCTION 📢

[Zigbee2MQTT](https://github.com/koenkk/zigbee2mqtt) (created by [koenkk](https://github.com/koenkk)) allows you to use your Zigbee devices without the vendor's bridge or gateway. It bridges events and allows you to control your Zigbee devices via MQTT. In this way you can integrate your Zigbee devices with whatever smart home infrastructure you are using.

# SYNOPSIS 📖
**What can I do with this?** This image will run Zigbee2mqtt [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md) for more security and convenience.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image is very small
>* ... this image has it's own helm [chart](https://github.com/11notes/docker-zigbee2mqtt/tree/master/chart)
>* ... this image has a terraform [script](https://github.com/11notes/docker-zigbee2mqtt/blob/master/terraform/main.tf)

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| 11notes/zigbee2mqtt | 99MB | 1000:1000 | ✅ | amd64, arm64 |
| koenkk/zigbee2mqtt | 147MB | 0:0 | ❌ | 386, amd64, arm64, armv6, armv7, riscv64 |

# VOLUMES 📁
* **/zigbee2mqtt/etc** - Directory of your configuration, database and other files

# COMPOSE ✂️
```yaml
name: "iot"

x-lockdown: &lockdown
  # prevents write access to the image itself
  read_only: true
  # prevents any process within the container to gain more privileges
  security_opt:
    - "no-new-privileges=true"

services:
  zigbee2mqtt:
    image: "11notes/zigbee2mqtt:2.14.0"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
    networks:
      frontend:
    volumes:
      - "zigbee2mqtt.etc:/zigbee2mqtt/etc"
    restart: "always"

volumes:
  zigbee2mqtt.etc:

networks:
  frontend:
```
To find out how you can change the default UID/GID of this container image, consult the [RTFM](https://github.com/11notes/RTFM/blob/main/linux/container/image/11notes/how-to.changeUIDGID.md#change-uidgid-the-correct-way).

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /zigbee2mqtt | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [2.14.0](https://hub.docker.com/r/11notes/zigbee2mqtt/tags?name=2.14.0)
* [2.14.0-unraid](https://hub.docker.com/r/11notes/zigbee2mqtt/tags?name=2.14.0-unraid)
* [2.14.0-nobody](https://hub.docker.com/r/11notes/zigbee2mqtt/tags?name=2.14.0-nobody)

### There is no latest tag, what am I supposed to do about updates?
It is my opinion that the ```:latest``` tag is a bad habbit and should not be used at all. Many developers introduce **breaking changes** in new releases. This would messed up everything for people who use ```:latest```. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:2.14.0``` you can use ```:2``` or ```:2.14```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version. Which in theory should not introduce breaking changes.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/zigbee2mqtt:2.14.0
docker pull ghcr.io/11notes/zigbee2mqtt:2.14.0
docker pull quay.io/11notes/zigbee2mqtt:2.14.0
```

# UNRAID VERSION 🟠
This image supports unraid by default. Simply add **-unraid** to any tag and the image will run as 99:100 instead of 1000:1000.

# NOBODY VERSION 👻
This image supports nobody by default. Simply add **-nobody** to any tag and the image will run as 65534:65534 instead of 1000:1000.

# SOURCE 💾
* [11notes/zigbee2mqtt](https://github.com/11notes/docker-zigbee2mqtt)

# PARENT IMAGE 🏛️
> [!IMPORTANT]
>This image is not based on another image but uses [scratch](https://hub.docker.com/_/scratch) as the starting layer.
>The image consists of the following distroless layers that were added:
>* [11notes/distroless:localhealth](https://github.com/11notes/docker-distroless/blob/master/localhealth.dockerfile) - app to execute HTTP requests only on 127.0.0.1

# BUILT WITH 🧰
* [zigbee2mqtt](https://github.com/laurent22/zigbee2mqtt)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-zigbee2mqtt/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-zigbee2mqtt/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-zigbee2mqtt/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 02.09.2026, 06:05:00 (CET)*