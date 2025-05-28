TITLE: Deploying a Prose Pod
INDEX: 1
UPDATED: 2025-05-29

## Context: The architecture of a Prose Pod

To begin with, let’s introduce you to the architecture of a Prose Pod, which will help you understand how things relate to one another.

A Prose Pod consists of three parts:

1. The [Prose Pod Server], running the [Prosody] XMPP server with additional modules for Prose requirements.
2. The [Prose Pod API], which allows configuring the Server using a HTTP API.
3. The [Prose Pod Dashboard], which exposes a Web UI one can use to configure a Server, invite members, manage authorization, etc.

! In expert guides, Server, Pod API and Dashboard –with capital letters– respectively refer to the [Prose Pod Server](https://github.com/prose-im/prose-pod-server "prose-im/prose-pod-server on GitHub") the [Prose Pod API](https://github.com/prose-im/prose-pod-api "prose-im/prose-pod-api on GitHub") and the [Prose Pod Dashboard](https://github.com/prose-im/prose-pod-dashboard "prose-im/prose-pod-dashboard on GitHub"). While in beginner guides we might use “Prose workspace” or “Prose server” to refer to a Prose Pod for simplification purposes, here we will avoid those generic terms.

### The bootstrapping process

For security reasons, your messaging data (stored in the Server) shouldn’t be readable by other parts of a Prose Pod[^mount]. The Prose Pod API fetches data from the Server using an authenticated network interface. As a consequence, the Pod API and the Server need to share a secret to bootstrap the connection. Since it is effectively a XMPP account password, we refer to it as the “bootstrap Prose Pod API XMPP password” or “bootstrap password” for short.

To make deployments easier, we defined a default bootstrap password, but rest assured that it doesn’t make your Prose Pod less secure. As stated in [Pod configuration reference > BootstrapConfig]: [The first thing the Prose Pod API does](https://github.com/prose-im/prose-pod-api/blob/c02f938161f134289a0c2e07f9ccc67dc97848a2/src/rest-api/src/features/startup_actions/mod.rs#L47) when starting up is changing this password to [a very strong random password](https://github.com/prose-im/prose-pod-api/blob/c02f938161f134289a0c2e07f9ccc67dc97848a2/src/service/src/features/xmpp/server_manager.rs#L116-L126), so you shouldn’t have a reason to change it (see [Provide a default bootstrap password · Issue #246 · prose-im/prose-pod-api](https://github.com/prose-im/prose-pod-api/issues/246)).

To interact with the Server, the Pod API therefore requires it to expose certain interfaces, requiring a certain set of configuration flags to be enabled at all times. Since this is an implementation detail you shouldn’t have to worry about, we package a bootstrapping configuration in the Server image, but we don’t apply it by default (to avoid surprises on your end). Therefore, when running the `proseim/prose-pod-server` image you have to change the entrypoint to `sh -c "cp /usr/share/prose/prosody.bootstrap.cfg.lua /etc/prosody/prosody.cfg.lua && prosody"`. Since you will be mounting `/etc/prosody` from somewhere, by knowing this you won’t be suprised if your `prosody.cfg.lua` suddenly looks different in a filesystem backup.

### Required files and directories

Here are all the directories a Prose Pod uses:

- `/var/lib/prose-pod-api/`: Pod API data (invitations, roles…).
- `/var/lib/prosody/`: Server data (messages, avatars…).
- `/etc/prose/`: Prose Pod configuration (environment).
- `/etc/prose-pod-api/`: Pod API configuration ().
- `/etc/prosody/`: Prosody configuration (see [Configuring Prosody](https://prosody.im/doc/configure)).
  - `/etc/prosody/certs/`: SSL certificates.
- `/usr/share/prose/`: Bootstrapping configuration.
  - The Pod API image already packages this directory. Unless you want to override the bootstrapping configuration, do not mount this path in the Pod API container or your Prose Pod will fail to start.

And here are all the files you need to create and maintain:

- `/etc/prose-pod-api/Prose.toml`: See the [Pod configuration reference](http://localhost:8040/references/pod-config/).
- `/etc/prose/env`: If using our Compose file (see [Example: Compose](#example-compose) later), this is where you can configure environment variables for your Prose Pod.
- `/etc/prosody/certs/*`: SSL certificates for your domain.

## Deployment steps

### Step 1: Create required files and directories

As detailed in [“Required files and directories”](#required-files-and-directories), Prose Pods require a certain amount of files and directories to exist. To create them, you can run:

```bash
umask 027
mkdir -p /var/lib/{prose-pod-api,prosody}
mkdir -p /etc/{prose,prose-pod-api,prosody}
mkdir -p /etc/prosody/certs

touch /var/lib/prose-pod-api/database.sqlite
touch /etc/prose-pod-api/Prose.toml

umask 077
touch /etc/prose/env
```

#### `Prose.toml`

In order for your Prose Pod to run correctly, you need to write a few configuration keys in `/etc/prose-pod-api/Prose.toml`.

You can find an up-to-date template at [github.com/prose-im/prose-pod-system/blob/master/Prose-template.toml](https://github.com/prose-im/prose-pod-system/blob/master/Prose-template.toml), or directly download it using:

```bash
curl -L https://raw.githubusercontent.com/prose-im/prose-pod-system/refs/heads/master/Prose-template.toml -O /etc/prose-pod-api/Prose.toml
```

Once done, edit the file to replace all placeholders with your company information.

!! For more information about all available configuration, see the [Pod configuration reference](http://localhost:8040/references/pod-config/).

#### SSL certificates

!!! TODO: @valerian Please write this section

### Step 2: Run your Prose Pod

To run a Prose Pod on your premises, you have to run all of its parts independently. Each is released as a Docker image, on Docker Hub (see [hub.docker.com/u/proseim](https://hub.docker.com/u/proseim)) and on GitHub’s Container Registry (see [github.com/orgs/prose-im/packages](https://github.com/orgs/prose-im/packages)).

! If you have any technical question while setting up your Prose Pod, feel free to [chat with our technical support team](#crisp-chat-open) which will gladly help you fix any issue you encounter.

#### Example: Run with Docker Compose

To make deployments and updates easier, we maintain a [Compose file](https://docs.docker.com/compose/intro/compose-application-model/#the-compose-file) in [github.com/prose-im/prose-pod-system](https://github.com/prose-im/prose-pod-system).

If you want to use [Docker Compose](https://docs.docker.com/compose/) to deploy a Prose Pod, here are the steps you need to follow:

1. Ensure you have [Docker](https://docs.docker.com/install) and [Docker Compose](https://docs.docker.com/compose/install/) installed and operational.
2. Get the latest Compose file using:

   ```bash
   curl -LO https://raw.githubusercontent.com/prose-im/prose-pod-system/refs/heads/master/compose.yaml
   ```
3. Run your Prose Pod using:

   ```bash
   docker compose up -d
   ```

### Step 3: Check that your Prose Pod is running correctly

If you have a Web browser, you can check that your Prose Pod has started successfully by opening the Dashboard at `http://localhost:3030`.

Otherwise, you can run:

```bash
curl http://localhost:3030/api/pod/version
```

If you get a JSON payload back containing information about the versions of you Prose Pod’s components, it means everything should be working correctly. If you want to make sure everything is well configured or if the call fails, you will have to check the logs.

! If logs don’t guide you to a solution, feel free to [chat with our technical support team](#crisp-chat-open) which will gladly help you fix any issue you encounter.

#### Checking logs using Docker Compose

To check for errors or warnings using Docker Compose, you can run:

```bash
docker compose logs | grep -i -e 'error|warn'
```

If you don’t see the problem or are missing context, you should check *all* the logs using:

```bash
docker compose logs
```

If the logs you see still don’t guide you to a solution, [reach out to our technical support team](#crisp-chat-open) which will gladly help you fix any issue you encounter.

### Step 4: Initializing your Prose Pod

!!! TODO: One needs to configure DNS records manually before they can access the Dashboard from a computer with a GUI.

Now that your Prose Pod is running, you need to create the first admin account, configure your DNS records and invite your first colleague. All of this can be done using the administration Dashboard which is accessible at `http://localhost:3030`.

Your Prose Pod still needs a bit of configuration and [“Initializing your workspace” section of the “Quickstart” guide](/guides/basics/quickstart/#initializing-your-workspace)

All of those steps could also be done using the Prose Pod API directly but it’s pretty advanced and subject to changes so we won’t document it here. However, if you are interested in doing so you can [reach out to our technical support team](#crisp-chat-open) which will guide you into using the Pod API.

[Prose Pod Server]: https://github.com/prose-im/prose-pod-server "prose-im/prose-pod-server on GitHub"
[Prose Pod API]: https://github.com/prose-im/prose-pod-api "prose-im/prose-pod-api on GitHub"
[Prose Pod Dashboard]: https://github.com/prose-im/prose-pod-dashboard "prose-im/prose-pod-dashboard on GitHub"
[Prosody]: https://prosody.im/ "Prosody IM homepage"
[Pod configuration reference > BootstrapConfig]: /references/pod-config/#bootstrapconfig
