# Teamspeak
Super small and simple teamspeak server.

## Running the server
```bash
docker run --detach --name teamspeak --publish 9987:9987/udp --publish 30033:30033/tcp hetsh/teamspeak
```

## Stopping the container
```bash
docker stop teamspeak
```

## Creating persistent storage
```bash
DATA="/path/to/data"
mkdir -p "$DATA"
chown -R 1361:1361 "$DATA"
```
`1361` is the numerical id of the user running the server (see Dockerfile).
The user must have RW access to the directory.
Start the server with the additional mount flags:
```bash
docker run --mount type=bind,source=/path/to/data,target=/teamspeak-server-data ...
```

## Automate startup and shutdown via systemd
The systemd unit can be found in my GitHub [repository](https://github.com/Hetsh/docker-teamspeak).
```bash
systemctl enable teamspeak --now
```
By default, the systemd service assumes `/apps/teamspeak/app.ini` for configuration and `/apps/teamspeak/data` for data and `/etc/localtime` for timezone.
Since this is a personal systemd unit file, you might need to adjust some parameters to suit your setup.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-teamspeak)).
Please feel free to ask questions, file an issue or contribute to it.
