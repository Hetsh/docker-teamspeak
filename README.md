# MCServer
Super small and simple teamspeak server.

## Running the server
```bash
docker run --detach --name teamspeak --publish 9987:9987/udp --publish 10011:10011/tcp --publish 30033:30033/tcp hetsh/teamspeak
```

## Stopping the container
```bash
docker stop teamspeak
```

## Configuration
Teamspeak is configured via a config file `/etc/teamspeak-server/app.ini`.
The default configuration should be sufficient for simple setups.
To apply your custom config use this additional mount flag:
```bash
docker run --mount type=bind,source=/path/to/app.ini,target=/etc/teamspeak-server/app.ini ...
```
Just make sure your configuration contains the following options:
```ini
dbsqlpath=/opt/teamspeak-server/sql/
logpath=/var/log/teamspeak-server
serverquerydocs_path=/opt/teamspeak-server/serverquerydocs
```
You can also add `license_accepted=1` if you agree to their terms and conditions.

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
```bash
systemctl enable teamspeak --now
```
The systemd unit can be found in my [GitHub](https://github.com/Hetsh/docker-teamspeak) repository.
By default, the systemd service assumes `/etc/teamspeak-server/app.ini` for configuration and `/etc/teamspeak-server/data` for data.
You need to adjust these to suit your setup.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-teamspeak)). Please feel free to ask questions, file an issue or contribute to it.
