TYPE: Markdown
TITLE: Pod configuration reference
UPDATED: 2026-02-04

To configure a Prose Pod, you can use the `/etc/prose/prose.toml` configuration
file (in [TOML](https://toml.io/) format).

Each field can also be overwritten using environment variables with the `PROSE_`
prefix and path segments separated by `__`. For example, you might change
maximum log levels by setting `PROSE_LOG__LEVEL=debug`.

Top-level configuration keys:

| Key | Purpose |
| --- | ------- |
| [`branding`](#branding-configuration) | Configure static data like your company name. |
| [`notifiers`](#notifiers-configuration) | Configure how notifications are sent (e.g. when sending invitations). |
| [`log`](#logging-configuration) | Configure logging. |
| [`pod`](#pod-configuration) | Configure the Prose Pod itself. |
| [`server`](#server-configuration) | Configure the Prose Pod Server. |
| [`dashboard`](#dashboard-configuration) | Configure the Prose Pod Dashboard. |

Minimal configuration:

```toml
[server]
domain = "crisp.chat"
```

# Branding configuration

Where you set your company branding.

Example:

```toml
[branding]
company_name = "Crisp"
```

! This configuration key is in a very early stage, expect things like logos and color in the future too.

## Company name

Name of your company. Will be used in places like invitation emails.

- Key: `branding.company_name`
- Type: `string` (optional)
- Length: `[1;48]`
- Compatibility: Pod API `>= v0.19.2`

## API app name

Name used in some places to refer to your Prose Pod API (e.g. “All data will be erased from `{company_name}`’s `{api_app_name}` databases.”). You shouldn’t have a reason to change it, but it’s there.

- Key: `branding.api_app_name`
- Type: `string`
- Length: `[1;48]`
- Default: `"Prose Pod API"`
- Compatibility: Pod API `>= v0.19.2`

# Notifiers configuration

## Email notifier configuration

Email notifications + SMTP configuration.

- Key: `notifiers.email`
- Type: `object`

Example:

```toml
[notifiers.email]
smtp_host = "mail.crisp.chat"
smtp_port = 587
smtp_username = "alice"
smtp_password = "foobar"
smtp_encrypt = true
```

### Prose Pod email address

Pod email address (e.g. `"prose@{smtp_host}"`).

- Key: `notifiers.email.pod_address`
- Type: `string` (email address)
- Default: `"prose@{server.domain}"`
- Compatibility: Pod API `>= v0.19.2`

### SMTP host

Public hostname of your SMTP server.

- Key: `notifiers.email.smtp_host`
- Type: `string` (hostname)
- Length: `[1;1024]`
- Compatibility: Pod API `>= v0.19.2`

### SMTP port

Public port of your SMTP server.

- Key: `notifiers.email.smtp_port`
- Type: `u16` (port number)
- Default: `587`
- Compatibility: Pod API `>= v0.19.2`

### SMTP username

SMTP username.

- Key: `notifiers.email.smtp_username`
- Type: `string` (optional)
- Length: `[1;1024]`
- Compatibility: Pod API `>= v0.19.2`

### SMTP password

SMTP password.

- Key: `notifiers.email.smtp_password`
- Type: `string` (optional)
- Compatibility: Pod API `>= v0.19.2`

### SMTP encryption

Require SMTP encryption. If `false`, will still use encryption but only if available.

- Key: `notifiers.email.smtp_encrypt`
- Type: `bool`
- Default: `true`
- Compatibility: Pod API `>= v0.19.2`

# Server configuration

Configuration of the Prose Pod Server.

- Key: `server`
- Type: `object`

Example:

```toml
[server]
domain = "crisp.chat"
log_level = "warn"
```

## XMPP server domain

Domain name of the messaging server. This is what will appear in user IDs (`user@domain`). Once set, it cannot be changed.

- Key: `server.domain`
- Type: `string` (hostname)
- Compatibility: Pod API `>= v0.19.2`

## Server configuration defaults

Server configuration defaults. Will be used unless you override them using the
Prose Pod Dashboard or Prose Pod API, and will be used again when you reset
server configuration keys.

Useful if you prefer configuring with files instead of clicking in a GUI or
writing a script.

- Key: `server.defaults`
- Type: `object`

Example:

```toml
[server.defaults]
message_archive_retention = "P2Y"
```

### Message archiving default

Activate or deactivate message archiving.

- Key: `server.defaults.message_archive_enabled`
- Type: `bool`
- Default: `true`
- Compatibility: Pod API `>= v0.19.2`

### Message archive retention default

Message archive retention period.

- Key: `server.defaults.message_archive_retention`
- Type: `string` ([Duration](#duration))
- Default: `"infinite"`
- Compatibility: Pod API `>= v0.19.2`

### File upload default

Activate or deactivate file upload and sharing.

- Key: `server.defaults.file_upload_allowed`
- Type: `bool`
- Default: `true`
- Compatibility: Pod API `>= v0.19.2`

### File storage retention default

File storage retention period.

- Key: `server.defaults.file_storage_retention`
- Type: `string` ([Duration](#duration))
- Default: `"infinite"`
- Compatibility: Pod API `>= v0.19.2`

### TLS profile default

TLS profile configuration (see <https://wiki.mozilla.org/Security/Server_Side_TLS>).

- Key: `server.defaults.tls_profile`
- Type: `string`
- Values: `"modern"`, `"intermediate"`, `"old"`
- Default: `"modern"`
- Compatibility: Pod API `>= v0.19.2`

### Federation default

Enabling federation will allow other servers to connect to your. This lets users from other Prose Workspaces connect with users in this Workspace. For more safety, whitelist friendly servers.

- Key: `server.defaults.federation_enabled`
- Type: `bool`
- Default: `false`
- Compatibility: Pod API `>= v0.19.2`

### Federation whitelist default

Whether or not to enable server whitelisting. Caution: If a whitelist is set but disabled, your server will still federate with the entire XMPP network.

- Key: `server.defaults.federation_whitelist_enabled`
- Type: `bool`
- Default: `false`
- Compatibility: Pod API `>= v0.19.2`

### Friendly servers default

If a whitelist is defined, then other servers will not be allowed to connect to this server, except whitelisted ones. It is recommended to whitelist servers you typically work with, i.e. other teams.

- Key: `server.defaults.federation_friendly_servers`
- Type: `array` of `string` (hostname)
- Default: `[]`
- Compatibility: Pod API `>= v0.19.2`

### Push notification body default

Whether or not to send the real message body to the remote pubsub node. Without end-to-end encryption, enabling this may expose your message contents to your client developers and OS vendor.

- Key: `server.defaults.push_notification_with_body`
- Type: `bool`
- Default: `true`
- Compatibility: Pod API `>= v0.19.2`

### Push notification sender default

Whether or not to send the real message sender to the remote pubsub node. Enabling this may expose your contacts to your client developers and OS vendor. Not recommended.

- Key: `server.defaults.push_notification_with_sender`
- Type: `bool`
- Default: `true`
- Compatibility: Pod API `>= v0.19.2`

# Dashboard configuration

## Dashboard URL

Public URL of your Prose Pod Dashboard. Used in places like Workspace
invitation emails.

- Key: `dashboard.url`
- Type: `string` (URI)
- Default: `"https://admin.{pod.address.domain}"`
- Compatibility: Pod API `>= v0.19.2`

# Logging configuration

- Key: `log`
- Type: `object`

Example:

```toml
[log]
level = "debug"
format = "compact"
with_ansi = true
```

## Maximum log level

Maximum (most verbose) log level.

- Key: `log.level`
- Type: `string` (log level)
- Values: `"trace"`, `"debug"`, `"info"`, `"warn"`, `"error"`
- Default: `"info"`
- Compatibility: Pod API `>= v0.19.2`

## XMPP server log level

Maximum log level of the Prose Pod Server.

- Key: `server.log_level`
- Type: `string` (log level)
- Values: `"trace"`, `"debug"`, `"info"`, `"warn"`, `"error"`
- Default: `"info"`
- Compatibility: Pod API `<= v0.19.2` or Pod Server `>= v0.4.0`

! This configuration key might change in the future. We’ll keep it backwards-compatible but it might be deprecated sooner or later.

## Log format

Log format (`full`, `compact`, `json`, `pretty`). See [tracing_subscriber::fmt](https://docs.rs/tracing-subscriber/latest/tracing_subscriber/fmt/index.html#formatters) for more details.

- Key: `log.format`
- Type: `string` (log format)
- Default: `"pretty"` in debug, `"json"` in release
- Compatibility: Pod API `>= v0.19.2`

## Log timer format

Format of timer in logs.

- Key: `log.timer`
- Type: `LogTimer`
- Values: `"none"`, `"time"`, `"uptime"`
- Default: `"uptime"` in debug, `"time"` in release
- Compatibility: Pod API `>= v0.19.2`

## Log with ANSI

Enable ANSI color codes in logs.

- Key: `log.with_ansi`
- Type: `bool`
- Default: `true` in debug, `false` in release
- Compatibility: Pod API `>= v0.19.2`

## Show file path in logs

Include file path in logs.

- Key: `log.with_file`
- Type: `bool`
- Default: `true` in debug, `false` in release
- Compatibility: Pod API `>= v0.19.2`

## Show log level in logs

Include log level.

- Key: `log.with_level`
- Type: `bool`
- Default: `true`
- Compatibility: Pod API `>= v0.19.2`

## Show module in logs

Include Rust target module in logs.

- Key: `log.with_target`
- Type: `bool`
- Default: `true`
- Compatibility: Pod API `>= v0.19.2`

## Show thread IDs in logs

Include thread IDs in logs.

- Key: `log.with_thread_ids`
- Type: `bool`
- Default: `false`
- Compatibility: Pod API `>= v0.19.2`

## Show line numbers in logs

Include line numbers in logs.

- Key: `log.with_line_number`
- Type: `bool`
- Default: `true` in debug, `false` in release
- Compatibility: Pod API `>= v0.19.2`

## Show span events in logs

Include span events in logs.

- Key: `log.with_span_events`
- Type: `bool`
- Default: `false`
- Compatibility: Pod API `>= v0.19.2`

## Show thread names in logs

Include thread names in logs.

- Key: `log.with_thread_names`
- Type: `bool`
- Default: `true` in debug, `false` in release
- Compatibility: Pod API `>= v0.19.2`

# Pod configuration

Configuration of the Prose Pod itself.

- Key: `pod`
- Type: `object`

Example:

```toml
[pod]
address = { domain = "prose.crisp.chat" }
```

## Pod address

Public network address of the server that runs the Prose Pod.

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `pod.address.domain` | `string` (hostname, optional\*) | Public domain name of the Prose Pod. | `"prose.{server.domain}"` |
| `pod.address.ipv4` | `string` (IPv4, optional\*) | Static IPv4 of the Prose Pod. | - |
| `pod.address.ipv6` | `string` (IPv6, optional\*) | Static IPv6 of the Prose Pod. | - |

Compatibility: Pod API `>= v0.19.2`

!! (\*) At least one of `domain`, `ipv4` or `ipv6` must be set.

# Vendor analytics configuration

For all keys here, find detailed explanations in
[“Prose vendor analytics” of `prose-im/prose-pod-server`][vendor-analytics-docs].

[vendor-analytics-docs]: https://github.com/prose-im/prose-pod-server/blob/master/api/docs/vendor-analytics.md

## Enable vendor analytics

- Key: `vendor_analytics.enabled`
- Type: `bool`
- Default: `true`
- Compatibility: Pod Server `>= v0.4.1`

## Vendor analytics presets

- Key: `vendor_analytics.presets`
- Type: Dictionary of vendor analytics configuration (minus `preset` and
  `presets` keys), by preset name.
- Default:

  ```toml
  [vendor_analytics.presets.all]
  enabled = true
  # Product usage analytics
  usage.enabled = true
  usage.meta_user_count.enabled = true
  usage.pod_version.enabled = true
  usage.user_app_version.enabled = true
  usage.user_lang.enabled = true
  usage.user_platform.enabled = true
  # Acquisition analytics
  acquisition.enabled = true
  acquisition.pod_domain.enabled = true

  [vendor_analytics.presets.default]
  inherits = "all"
  # Make identifying data points opt-in
  acquisition.pod_domain.enabled = false

  [vendor_analytics.presets.gdpr]
  inherits = "default"
  # Disable all analytics events if the Prose Workspace has less than 20
  # users. After that, companies are forced to provide KYC information
  # and our per-seat billing system has to know the exact user count.
  min_cohort_size = 20
  # Limit locales to reduce identifiability.
  usage.user_lang.max_locales = 2

  [vendor_analytics.presets.lgpd]
  inherits = "gdpr"
  ```

- Compatibility: Pod Server `>= v0.4.1`

## Vendor analytics preset

- Key: `vendor_analytics.preset`
- Type: `string` (preset name)
- Default: `"default"`
- Compatibility: Pod Server `>= v0.4.1`

## Minimum cohort size for vendor analytics

- Key: `vendor_analytics.min_cohort_size`
- Type: `u8` (optional)
- Default: `20`
- Compatibility: Pod Server `>= v0.4.1`

## Product usage analytics

### Enable all product usage analytics

- Key: `vendor_analytics.usage.enabled`
- Type: `bool`
- Default: `true`
- Compatibility: Pod Server `>= v0.4.1`

### Enable user count analytics

- Key: `vendor_analytics.usage.meta_user_count.enabled`
- Type: `bool`
- Default: `true`
- Compatibility: Pod Server `>= v0.4.1`

### Enable Pod version analytics

- Key: `vendor_analytics.usage.pod_version.enabled`
- Type: `bool`
- Default: `true`
- Compatibility: Pod Server `>= v0.4.1`

### Enable app version analytics

- Key: `vendor_analytics.usage.user_app_version.enabled`
- Type: `bool`
- Default: `true`
- Compatibility: Pod Server `>= v0.4.1`

### Enable user locale analytics

- Key: `vendor_analytics.usage.user_lang.enabled`
- Type: `bool`
- Default: `true`
- Compatibility: Pod Server `>= v0.4.1`

### Max user locales in analytics

- Key: `vendor_analytics.usage.user_lang.max_locales`
- Type: `u8` (optional)
- Compatibility: Pod Server `>= v0.4.1`

### Enable user platform analytics

- Key: `vendor_analytics.usage.user_platform.enabled`
- Type: `bool`
- Default: `true`
- Compatibility: Pod Server `>= v0.4.1`

### User platform analytics allow list

- Key: `vendor_analytics.usage.user_platform.allow_list`
- Type: `array` of `string` (optional)
- Compatibility: Pod Server `>= v0.4.1`

### User platform analytics deny list

- Key: `vendor_analytics.usage.user_platform.deny_list`
- Type: `array` of `string` (optional)
- Compatibility: Pod Server `>= v0.4.1`

## Acquisition analytics

### Enable all acquisition analytics

- Key: `vendor_analytics.acquisition.enabled`
- Type: `bool`
- Default: `true`
- Compatibility: Pod Server `>= v0.4.1`

### Enable Pod domain analytics

- Key: `vendor_analytics.acquisition.pod_domain.enabled`
- Type: `bool`
- Default: `false`
- Compatibility: Pod Server `>= v0.4.1`

# Policies configuration

Use to enforce company policies.

## Enable apps auto-update

Can be used to prevent Prose apps from trying to auto-update.

- Key: `policies.auto_update_enabled`
- Type: `bool`
- Default: `true`
- Compatibility: Pod Server `>= v0.4.1`

---

# Advanced configuration

You shouldn’t have to touch those, but if you really need them they exist.
Know that you might break your Prose Pod by changing those, we don’t guarantee anything.

## Prose Pod API configuration

### Prose Pod API address

IP address to serve the Prose Pod API on.

- Key: `api.address`
- Type: `string` (IPv4 or IPv6)
- Default: `"0.0.0.0"`
- Compatibility: Pod API `>= v0.19.2`

!!! Things will likely break if you change this.

### Prose Pod API port

Port number the Prose Pod API should listen to.

- Key: `api.port`
- Type: `u16` (port number)
- Default: `8080`
- Compatibility: Pod API `>= v0.19.2`

!!! Things will likely break if you change this.

### Prose Pod API default response timeout

Timeout after which all requests are cancelled.

- Key: `api.default_response_timeout`
- Type: `string` ([Duration](#duration))
- Default: `"PT10S"`
- Compatibility: Pod API `>= v0.19.2`

!! **\[Beta\]** This configuration key is still subject to changes.

### Prose Pod API default retry interval

Default interval between retries (e.g. when running network checks).

- Key: `api.default_retry_interval`
- Type: `string` ([Duration](#duration))
- Default: `"PT5S"`
- Compatibility: Pod API `>= v0.19.2`

!! **\[Beta\]** This configuration key is still subject to changes.

### Prose Pod API databases configuration

| Key | Type | Description |
| --- | ---- | ----------- |
| `api.databases.main` | [DatabaseConfig](#databaseconfig) | Main database configuration. |
| `api.databases.main_read` | [DatabaseConfig](#databaseconfig) | Configuration of the main database’s read connection. |
| `api.databases.main_write` | [DatabaseConfig](#databaseconfig) | Configuration of the main database’s write connection. |

For technical reasons, the Prose Pod API opens two connections to its database:
one for read operations only, and one for reads & writes. `main_read` and
`main_write` are used to create the connections, but `main` is used as a
default value. `main_read` and `main_write` can be used for specific overrides.

Default:

```toml
[api.databases.main]
# min_connections = # No minimum.
connect_timeout = 5
# idle_timeout = # No timeout.
sqlx_logging = false

[api.databases.main_read]
url = "sqlite:///var/lib/prose-pod-api/database.sqlite?mode=ro"
max_connections = # Parallelism capacity * 4 (dynamic).

[api.databases.main_write]
url = "sqlite:///var/lib/prose-pod-api/database.sqlite"
max_connections = 1
```

Compatibility: Pod API `>= v0.19.2`

!! **\[Beta\]** This configuration key is still subject to changes.

### Network checks configuration

!! **\[Beta\]** This configuration key is still subject to changes.

#### Network checks timeout

- Key: `api.network_checks.timeout`
- Type: `string` ([Duration](#duration))
- Default: `"PT5M"` (5 minutes)
- Compatibility: Pod API `>= v0.19.2`

#### Network checks retry interval

- Key: `api.network_checks.retry_interval`
- Type: `string` ([Duration](#duration))
- Default: `"PT5S"` (5 seconds)
- Compatibility: Pod API `>= v0.19.2`

#### Network checks retry timeout

- Key: `api.network_checks.retry_timeout`
- Type: `string` ([Duration](#duration))
- Default: `"PT1S"` (1 second)
- Compatibility: Pod API `>= v0.19.2`

#### Network checks DNS cache TTL

When querying DNS records, we query the authoritative name servers directly.
To avoid unnecessary DNS queries, we cache the IP addresses of these servers.
However, these IP addresses can change over time so we need to clear the cache
every now and then. 5 minutes seems long enough to avoid unnecessary queries
while a user is checking their DNS configuration, but short enough to react to
DNS server reconfigurations.

- Key: `api.network_checks.dns_cache_ttl`
- Type: `string` ([Duration](#duration))
- Default: `"PT5M"` (5 minutes)
- Compatibility: Pod API `>= v0.19.2`

## Auth configuration

Authentication and authorization configuration.

### OAuth 2.0 access token TTL

How long sessions are valid for (how often members need to log into the
Pod Dashboard again). Note that this only affects the Pod Dashboard, not
Prose apps.

- Key: `auth.token_ttl`
- Type: `string` ([Duration](#duration))
- Default: `"PT3H"` (3 hours)
- Compatibility: Pod API `>= v0.19.2`

### Password reset token TTL

How long password reset links are valid for.

Note that this configuration only applies to future password reset tokens.

- Key: `auth.password_reset_token_ttl`
- Type: `string` ([Duration](#duration))
- Default: `"PT15M"` (15 minutes)
- Compatibility: Pod API `>= v0.19.2`

### Minimum password length

Minimum length for account passwords. See [NIST Special Publication 800-63B]
and [Authentication - OWASP Cheat Sheet Series] for guidance.

[NIST Special Publication 800-63B]: https://pages.nist.gov/800-63-4/sp800-63b.html#passwordver
[Authentication - OWASP Cheat Sheet Series]: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html#implement-proper-password-strength-controls

Note that this does not apply if passwords are changed outside of Prose
softwares.

- Key: `auth.min_password_length`
- Type: `u8`
- Range: `[8;256]`
- Default: `15`
- Compatibility: Pod API `>= v0.19.2`

### Invitations TTL

How long password reset links are valid for.

Note that this configuration only applies to future password reset tokens.

- Key: `auth.invitation_ttl`
- Type: `string` ([Duration](#duration))
- Default: `"P1W"` (1 week)
- Compatibility: Pod API `>= v0.19.2`

### OAuth 2.0 registration key

!! **\[Beta\]** This configuration key will change, pretend it’s not there.

- Key: `auth.oauth2_registration_key`
- Type: `string`
- Default: Random 256-byte key
- Compatibility: Pod API `>= v0.19.2`

## Prosody configuration

The configuration for Prosody can be tweaked in multiple ways. You can use `prosody.<host>.`

Example:

```toml
[prosody_ext]
additional_modules_enabled = ["custom1"]

[prosody.global.defaults]
limits.c2s = { rate = "100kB/s" }

[prosody."crisp.chat".overrides]
limits.c2s = { rate = "100kB/s" }

[prosody."upload.prose.local".overrides]
http_file_share_daily_quota = "200MiB"
```

### Prosody additional enabled modules

Additional Prosody modules to enable.

Those modules will be enabled globally after every other configuration has been applied (apart from dynamic overrides, which are always applied last).

- Key: `prosody_ext.additional_modules_enabled`
- Type: `Vec<String>`
- Default: `[]`
- Compatibility: Pod API `>= v0.19.2`

Example:

```toml
[prosody_ext]
additional_modules_enabled = ["bosh"]
```

### Prosody config file path

Path to the Prosody configuration file.

- Key: `prosody_ext.config_file_path`
- Type: `string` (file path)
- Default: `"/etc/prosody/prosody.cfg.lua"`
- Compatibility: Pod API `>= v0.19.2`

!!! Things will likely break if you change this.

### Prosody defaults and overrides

Prose Pods manage a Prosody configuration file
(see [Configuring Prosody – Prosody IM](https://prosody.im/doc/configure))
for you, that’s generated based on what you configure via the
Prose Pod Dashboard or Prose Pod API.

You can configure `prosody.<host>.defaults` and `prosody.<host>.overrides` to
respectively set defaults or overrides for fields in the generated Prosody
configuration file. When generating such configuration file, defaults are
applied first, then changes are made depending on what’s been configured via
the Prose Pod Dashboard or Prose Pod API and finally overrides are applied.

`<host>` should be replaced by the hostname of the `VirtualHost` or `Component`
you want to configure. The special host `global` applies to the global
Prosody configuration (top level).
Make sure to quote the hostname if it contains a period (`.`) otherwise TOML
will interpret it as nested keys. For example, you should write
`prosody."crisp.chat".overrides` to override configuration for `crisp.chat`.

Compatibility: Pod API `>= v0.19.2`

!!! Not all keys are supported, see [prose-pod-api/src/prosody-config/src/prosody_config/mod.rs](https://github.com/prose-im/prose-pod-api/blob/master/src/prosody-config/src/prosody_config/mod.rs). If you miss support for a key, tell us and we’ll add it in a future release!

## Service accounts configuration

To behave properly, Prose needs to create a few additional XMPP accounts.
They’re not _user_ accounts, and have special permissions.

You should not need to change any of this, but as always configuration is there
_just in case_.

### Prose Workspace XMPP account

XMPP account of your Prose Workspace itself. It is used to store your Workspace
name, accent color and other information in a way that makes it available via
the XMPP protocol.

- Key: `service_accounts.prose_workspace.xmpp_node`
- Type: `string` ([JID node](#jidnode))
- Default: `"prose-workspace"`
- Compatibility: Pod API `>= v0.19.2`

!!! Things will likely break if you change this.

!! **\[Beta\]** The default value will likely change in the future; please do not make it explicit or things might break later.

## Local hostnames

Hostnames in the private network for Prose Pod components.

### Local Prose Pod Server hostname

Local hostname.

- Key: `server.local_hostname`
- Type: `string` (hostname)
- Default: `"prose-pod-server"`
- Compatibility: Pod API `>= v0.19.2`

!!! Things will likely break if you change this.

!! **\[Beta\]** This configuration key is still subject to changes.

## XMPP server HTTP port

HTTP port of the XMPP server.

- Key: `server.http_port`
- Type: `u16` (port number)
- Default: `5280`
- Compatibility: Pod API `>= v0.19.2`

---

# Debug configuration

As the name suggest, you should only use those settings temporarily.
They might expose user data or things like that. You have been warned.

- Key: `debug_use_at_your_own_risk`
- Type: `object`
- Default: `{}`

## Log configuration at startup

Log the parsed configuration at startup.

- Key: `debug_use_at_your_own_risk.log_config_at_startup`
- Type: `bool`
- Default: `true` in debug, `false` in release
- Compatibility: Pod API `>= v0.19.2`

## Detailed error responses

Enable detailed error responses (adds detailed messages and debug information).

- Key: `debug_use_at_your_own_risk.detailed_error_responses`
- Type: `bool`
- Default: `true` in debug, `false` in release
- Compatibility: Pod API `>= v0.19.2`

## Unencrypted client-to-server connections

Allow unencrypted client-to-server connections.

- Key: `debug_use_at_your_own_risk.c2s_unencrypted`
- Type: `bool`
- Default: `false`
- Compatibility: Pod API `>= v0.19.2`

## Unencrypted client-to-server connections

Startup actions to skip (by module name). See [`prose-im/prose-pod-api/src/rest-api/src/features/startup_actions/mod.rs`](https://github.com/prose-im/prose-pod-api/blob/0b786c0f5349969cc2a166b0ccc4b5cdbdc33063/src/rest-api/src/features/startup_actions/mod.rs).

- Key: `debug_use_at_your_own_risk.skip_startup_actions`
- Type: `array` of `string`
- Default: `[]`
- Compatibility: Pod API `>= v0.19.2`

!! **\[Beta\]** Values for this configuration key are still subject to changes. Some might be removed.

---

# Custom types

## Duration

A duration in [ISO 8601 format](https://en.wikipedia.org/wiki/ISO_8601#Durations) (e.g. `"PT10S"`, `"PT5M"`, `"P2Y"`…).

## DatabaseConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `url` | `string` (URI) | Database URL. | - |
| `min_connections` | `u32` (optional) | Minimum number of connections. | `None` |
| `max_connections` | `u32` | Maximum number of connections. | Parallelism capacity \* 4 |
| `connect_timeout` | `u64` (seconds) | Connection acquiring timeout. | `5` |
| `idle_timeout` | `u64` (optional) | Idle connection timeout. | `None` |
| `sqlx_logging` | `bool` | Enable [sqlx](https://docs.rs/sqlx/latest/sqlx/) logging. | `false` |

## JidNode

Local part of a JID, as defined in [RFC 6120 - Extensible Messaging and Presence Protocol (XMPP): Core, section 1.4](https://datatracker.ietf.org/doc/html/rfc6120#section-1.4).
The domain part will be your Server’s domain (i.e. `"{xmpp_node}@{server_domain}"`.
