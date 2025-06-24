TITLE: Deploying a Prose Pod
INDEX: 1
UPDATED: 2025-06-24

## Context: The architecture of a Prose Pod

To begin with, let’s introduce you to the architecture of a Prose Pod, which will help you understand how things relate to one another.

A Prose Pod consists of four parts:

1. The [Prose Pod Server], running the [Prosody] XMPP server with additional modules for Prose requirements.
2. The [Prose Web application], which is a XMPP client accessible using a web browser.
3. The [Prose Pod API], which allows configuring the Server using a HTTP API.
4. The [Prose Pod Dashboard], which exposes a Web UI one can use to configure a Server, invite members, manage authorization, etc.

! In expert guides, Server, Pod API and Dashboard –with capital letters– respectively refer to the [Prose Pod Server](https://github.com/prose-im/prose-pod-server "prose-im/prose-pod-server on GitHub") the [Prose Pod API](https://github.com/prose-im/prose-pod-api "prose-im/prose-pod-api on GitHub") and the [Prose Pod Dashboard](https://github.com/prose-im/prose-pod-dashboard "prose-im/prose-pod-dashboard on GitHub"). While in beginner guides we might use “Prose workspace” or “Prose server” to refer to a Prose Pod for simplification purposes, here we will avoid those generic terms.

### The bootstrapping process

For security reasons, your messaging data (stored in the Server) shouldn’t be readable by other parts of a Prose Pod. The Prose Pod API fetches data from the Server using an authenticated network interface. As a consequence, the Pod API and the Server need to share a secret to bootstrap the connection. Since it is effectively a XMPP account password, we refer to it as the “bootstrap Prose Pod API XMPP password” or “bootstrap password” for short.

To make deployments easier, we defined a default bootstrap password, but rest assured that it doesn’t make your Prose Pod less secure. As stated in [Pod configuration reference > BootstrapConfig]: [The first thing the Prose Pod API does](https://github.com/prose-im/prose-pod-api/blob/c02f938161f134289a0c2e07f9ccc67dc97848a2/src/rest-api/src/features/startup_actions/mod.rs#L47) when starting up is changing this password to [a very strong random password](https://github.com/prose-im/prose-pod-api/blob/c02f938161f134289a0c2e07f9ccc67dc97848a2/src/service/src/features/xmpp/server_manager.rs#L116-L126), so you shouldn’t have a reason to change it (see [Provide a default bootstrap password · Issue #246 · prose-im/prose-pod-api](https://github.com/prose-im/prose-pod-api/issues/246)).

To interact with the Server, the Pod API therefore requires it to expose certain interfaces, requiring a certain set of configuration flags to be enabled at all times. Since this is an implementation detail you shouldn’t have to worry about, we package a bootstrapping configuration in the Server image, but we don’t apply it by default (to avoid surprises on your end). Therefore, when running the `proseim/prose-pod-server` image you have to change the entrypoint to `sh -c "cp /usr/share/prose/prosody.bootstrap.cfg.lua /etc/prosody/prosody.cfg.lua && prosody"`. Since you will be mounting `/etc/prosody` from somewhere, by knowing this you won’t be suprised if your `prosody.cfg.lua` suddenly looks different in a filesystem backup.

### Required files and directories

Here are all the directories a Prose Pod uses:

- `/var/lib/prose-pod-api/`: Pod API data (invitations, roles…).
- `/var/lib/prosody/`: Server data (messages, avatars…).
- `/etc/prose/`: Prose Pod configuration.
- `/etc/prosody/`: Prosody configuration (see [Configuring Prosody](https://prosody.im/doc/configure)).
  - `/etc/prosody/certs/`: SSL certificates.
- `/usr/share/prose/`: Bootstrapping configuration.
  - The Pod API image already packages this directory. Unless you want to override the bootstrapping configuration, do not mount this path in the Pod API container or your Prose Pod will fail to start.

And here are all the files you need to create and maintain:

- `/etc/prose/prose.toml`: See the [Pod configuration reference](http://localhost:8040/references/pod-config/).
- `/etc/prose/prose.env`: If using our Compose file (see [Example: Compose](#example-compose) later), this is where you can configure environment variables for your Prose Pod.
- `/etc/prosody/certs/*`: SSL certificates for your domain.

---

## Deployment steps

### Step 1: Some helper variables

To copy-paste working commands from this guide, please start by creating the following variables:

```bash
PROSE_FILES=https://raw.githubusercontent.com/prose-im/prose-pod-system/refs/heads/master
YOUR_DOMAIN= # Insert your domain
```

### Step 2: Create the `prose` user

For better isolation, you shouldn’t run Prose as root on your server. This guide uses a `prose` user that you should create using:

```bash
# Create group
addgroup --gid 1001 prose

# Create user
adduser --uid 1001 --gid 1001 --disabled-password --no-create-home --gecos 'Prose' prose
```

### Step 3: Create required files and directories

As detailed in [“Required files and directories”](#required-files-and-directories), Prose Pods require a certain amount of files and directories to exist. To create them, you can run:

```bash
# Directories
install -o prose -g prose -m 750 -d \
  /var/lib/{prose-pod-api,prosody} \
  /etc/{prose,prosody} \
  /etc/prosody/certs

# Database
install -o prose -g prose -m 640 -T /dev/null \
  /var/lib/prose-pod-api/database.sqlite

# Environment
install -o prose -g prose -m 600 -T /dev/null \
  /etc/prose/prose.env
```

#### Create the `prose.toml` file

In order for your Prose Pod to run correctly, you need to write a few configuration keys in `/etc/prose/prose.toml`.

You can find an up-to-date template at [prose-im/prose-pod-system/blob/master/templates/prose.toml](https://github.com/prose-im/prose-pod-system/blob/master/templates/prose.toml), or directly download it using:

```bash
# Download configuration template
curl -L "${PROSE_FILES:?}"/templates/prose.toml \
  | sed s/'{your_domain}'/${YOUR_DOMAIN:?}/g \
  > /etc/prose/prose.toml

# Change configuration user/group
chown prose:prose /etc/prose/prose.toml

# Then edit </etc/prose/prose.toml>!
```

Once done, **edit the file to replace all placeholders** with your company information.

!! For more information about all available configuration, see the [Pod configuration reference](http://localhost:8040/references/pod-config/).

#### SSL certificates

1. Install [certbot](https://certbot.eff.org/):

   ```bash
   upt update
   apt install -y certbot
   ```

2. Ensure you have `A`/`AAAA` DNS records pointing to your server (so certbot can pass its SSL challenge).

3. Request a SSL certificate for your Prose Pod:

   ```bash
   certbot certonly --standalone -d ${YOUR_DOMAIN:?} -d groups.${YOUR_DOMAIN:?}
   ```

   Note that certbot should have automatically created `/etc/cron.d/certbot` to handle certificates renewal.

   <details>
       <summary>Click to show an example <code>/etc/cron.d/certbot</code></summary>

   ```bash
   # /etc/cron.d/certbot: crontab entries for the certbot package
   #
   # Upstream recommends attempting renewal twice a day
   #
   # Eventually, this will be an opportunity to validate certificates
   # haven't been revoked, etc.  Renewal will only occur if expiration
   # is within 30 days.
   #
   # Important Note!  This cronjob will NOT be executed if you are
   # running systemd as your init system.  If you are running systemd,
   # the cronjob.timer function takes precedence over this cronjob.  For
   # more details, see the systemd.timer manpage, or use systemctl show
   # certbot.timer.
   SHELL=/bin/sh
   PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

   0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(43200))' && certbot -q    renew --no-random-sleep-on-renew
   ```

   </details>

4. certbot certificates are stored in `/etc/letsencrypt/live`, but Prosody will search in `/etc/prosody/certs`. Normally we’d use `prosodyctl --root cert import /etc/letsencrypt/live` (as explained in [Let’s Encrypt – Prosody IM](https://prosody.im/doc/letsencrypt)), but Prose runs Prosody in a dedicated container therefore your server doesn’t have access to `prosodyctl` (and we can’t use symbolic links). Here is one way to copy the certificates manually:

   ```bash
   rsync -aL --chown=prose:prose /etc/{letsencrypt/live,prosody/certs}/
   ```

   ! **Tip:** If you manage multiple certificates and want Prosody to only see the one you use for Prose, you can use `rsync -aL --chown=prose:prose /etc/{letsencrypt/live,prosody/certs}/${YOUR_DOMAIN:?}/` instead.

5. certbot should have automatically created `/etc/cron.d/certbot` to handle certificates renewal, but you still have to add a certbot renewal hook to update Prosody certificates when certificates are renewed. For this, assign the command you executed previously in as `post_hook` under `[renewalparams]` in `/etc/letsencrypt/renewal/prose.${YOUR_DOMAIN:?}.conf`. For example, if you used `rsync -aL --chown=prose:prose /etc/{letsencrypt/live,prosody/certs}/` you should set:

   ```toml
   post_hook = "/bin/bash -c 'rsync -aL --chown=prose:prose /etc/{letsencrypt/live,prosody/certs}/'"
   ```

### Step 3: Run your Prose Pod

To run a Prose Pod on your premises, you have to run all of its parts independently. Each is released as a Docker image, on Docker Hub (see [hub.docker.com/u/proseim](https://hub.docker.com/u/proseim)) and on GitHub’s Container Registry (see [github.com/orgs/prose-im/packages](https://github.com/orgs/prose-im/packages)).

! If you have any technical question while setting up your Prose Pod, feel free to [contact our technical support team](https://prose.org/contact/) which will gladly help you fix any issue you encounter.

#### Example: Run with Docker Compose

To make deployments and updates easier, we maintain a [Compose file](https://docs.docker.com/compose/intro/compose-application-model/#the-compose-file) in [prose-im/prose-pod-system](https://github.com/prose-im/prose-pod-system).

If you want to use [Docker Compose](https://docs.docker.com/compose/) to deploy a Prose Pod, here are the steps you need to follow:

1. Ensure you have [Docker](https://docs.docker.com/install) and [Docker Compose](https://docs.docker.com/compose/install/) installed and operational.

   ! **Tip:** If you don’t have it already, the easiest way to install Docker is to run `curl -L https://get.docker.com | sh`.

2. Add the `prose` user to the `docker` group:

   ```bash
   usermod -aG docker prose
   ```

3. Get the [latest Compose file](https://github.com/prose-im/prose-pod-system/blob/master/compose.yaml) using:

   ```bash
   # Download Docker Compose file
   curl -L "${PROSE_FILES:?}"/compose.yaml -o /etc/prose/compose.yaml

   # Change Compose file user/group
   chown prose:prose /etc/prose/compose.yaml
   ```

4. Configure [systemd](https://systemd.io/) to run Prose at startup and run it:

   ```bash
   # Install systemd service file
   curl -L "${PROSE_FILES:?}"/templates/prose.service -o /etc/systemd/system/prose.service

   # Enable the prose systemd service
   systemctl daemon-reload
   systemctl enable prose
   systemctl start prose
   ```

While `systemctl start prose` should have failed if something was wrong, you can still run the following command to make sure every part of your Prose Pod is running (you should see an empty table, with headers only):

```bash
docker compose -f /etc/prose/compose.yaml ps --status=exited
```

If you see one that has exited, check its logs using:

```bash
docker compose -f /etc/prose/compose.yaml logs --no-log-prefix -- {service_name}
```

! If the error logs aren’t clear enough, don’t hesitate [reaching out to our technical support team](https://prose.org/contact/).

### Step 4: Configure the reverse proxy

The traffic to your Prose Pod will need to be routed by a [reverse proxy](https://en.wikipedia.org/wiki/Reverse_proxy).

! This section supposes you’re using [NGINX](https://nginx.org/en/). If you use another reverse proxy, please update insctructions accordingly.

```bash
apt install -y nginx python3-certbot-nginx
```

```bash
certbot --nginx \
  -d prose.${YOUR_DOMAIN:?} \
  -d admin.prose.${YOUR_DOMAIN:?} \
```

To make deployments easier, we maintain a NGINX configuration file at [templates/nginx.conf in github.com/prose-im/prose-pod-system](https://github.com/prose-im/prose-pod-system/blob/master/templates/nginx.conf). You can download and enable it using:

```bash
# Install NGINX files
curl -L "${PROSE_FILES:?}"/templates/nginx.conf \
  | sed s/'{your_domain}'/${YOUR_DOMAIN:?}/g \
  > /etc/nginx/sites-available/prose.${YOUR_DOMAIN:?}

# Enable NGINX sites
ln -s /etc/nginx/sites-{available,enabled}/prose.${YOUR_DOMAIN:?}
```

```bash
# Apply the new NGINX configuration
systemctl reload nginx
```

### Step 5: `.well-known/host-meta`

```bash
WWW_ROOT=/var/www/default
```

```bash
mkdir -p "${WWW_ROOT:?}"/.well-known/

# .well-known/host-meta (XML)
curl -L "${PROSE_FILES:?}"/templates/host-meta \
  | sed s/'{your_domain}'/${YOUR_DOMAIN:?}/g \
  > "${WWW_ROOT:?}"/.well-known/host-meta

# .well-known/host-meta.json
curl -L "${PROSE_FILES:?}"/templates/host-meta.json \
  | sed s/'{your_domain}'/${YOUR_DOMAIN:?}/g \
  > "${WWW_ROOT:?}"/.well-known/host-meta.json
```

<!-- If your server is the one serving your domain and you don’t have a certificate just yet, run:

```bash
certbot --nginx -d ${YOUR_DOMAIN:?}
``` -->

```bash
# Install NGINX files
curl -L "${PROSE_FILES:?}"/templates/nginx-well-known.conf \
  | sed s/'{your_domain}'/${YOUR_DOMAIN:?}/g \
  > /etc/nginx/sites-available/${YOUR_DOMAIN:?}

# Enable NGINX sites
ln -s /etc/nginx/sites-{available,enabled}/${YOUR_DOMAIN:?}
```

```bash
# Apply the new NGINX configuration
systemctl reload nginx
```

### Step 6: Check that your Prose Pod is running correctly

If you have a Web browser, you can check that your Prose Pod has started successfully by opening the Dashboard at `http://localhost:8081`.

Otherwise, you can run:

```bash
curl http://localhost:8081/api/pod/version
```

If you get a JSON payload back containing information about the versions of you Prose Pod’s components, it means everything should be working correctly. If you want to make sure everything is well configured or if the call fails, you will have to check the logs.

! If logs don’t guide you to a solution, feel free to [contact our technical support team](https://prose.org/contact/) which will gladly help you fix any issue you encounter.

#### Checking logs using Docker Compose

To check for errors or warnings using Docker Compose, you can run:

```bash
docker compose -f /etc/prose/compose.yaml logs | grep -i -e 'error|warn'
```

If you don’t see the problem or are missing context, you should check *all* the logs using:

```bash
docker compose -f /etc/prose/compose.yaml logs
```

If the logs you see still don’t guide you to a solution, [reach out to our technical support team](https://prose.org/contact/) which will gladly help you fix any issue you encounter.

### Step 7: Initializing your Prose Pod

Now that your Prose Pod is running, you need to create the first admin account, configure your DNS records and invite your first colleague. All of this can be done using the administration Dashboard which is accessible at `http://localhost:8081`.

!! Those steps could also be done using the Prose Pod API directly but it’s pretty advanced and subject to changes so we won’t document it here. However, if you are interested in doing so you can [reach out to our technical support team](https://prose.org/contact/) which will guide you into using the Pod API.

However, you very likely don’t have access to a web browser on the machine where you are running the Prose Pod so you will have to create a first DNS record in order for you to access the Dashboard from your own web browser.

If your server has a public IP address, add the following records to your DNS zone (replacing `{ipv4}` and `{ipv6}` by your server’s IPv4 and IPv6 addresses):

```txt
admin.prose 10800 IN A    {ipv4}
admin.prose 10800 IN AAAA {ipv6}
```

! If your server only has an IPv4 or IPv6, add only the appropriate record.

If your server is already accessible via a hostname, add this `CNAME` record to your DNS zone instead (replacing `{hostname}` by your server’s public hostname):

```txt
prose 10800 IN CNAME {hostname}
```

! You can change `prose` to something else, it’s not hard-coded anywhere on our side, but beware that our guides will assume you used this value so you’ll have to change it everywhere we mention `prose.{your_domain}`.

Now, or after a few minutes (for your DNS provider to propagate the new records), you should be able to open `https://prose.{your_domain}:8081` in your web browser and see your Prose Pod Dashboard. If you get a SSL error, go back to [the “SSL certificates” section](#ssl-certificates) and make sure everything is correct.

! If you can’t access your Dashboard at this point, feel free to [contact our technical support team](https://prose.org/contact/) which will gladly help you fix your configuration.

Now that you have access to your Dashboard, you can follow [the “Initializing your workspace” section of the “Quickstart” guide](/guides/basics/quickstart/#initializing-your-workspace) to finish configuring your Prose Pod.

+ Navigation
  | Initializing your workspace: Finish configuring your Prose Pod using the Dashboard. -> /guides/basics/quickstart/#initializing-your-workspace

[Prose Pod Server]: https://github.com/prose-im/prose-pod-server "prose-im/prose-pod-server on GitHub"
[Prose Web application]: https://github.com/prose-im/prose-app-web "prose-im/prose-app-web on GitHub"
[Prose Pod API]: https://github.com/prose-im/prose-pod-api "prose-im/prose-pod-api on GitHub"
[Prose Pod Dashboard]: https://github.com/prose-im/prose-pod-dashboard "prose-im/prose-pod-dashboard on GitHub"
[Prosody]: https://prosody.im/ "Prosody IM homepage"
[Pod configuration reference > BootstrapConfig]: /references/pod-config/#bootstrapconfig
