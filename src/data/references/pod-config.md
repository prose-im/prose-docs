TYPE: Markdown
TITLE: Pod configuration reference
UPDATED: 2025-05-15

To configure a Prose Pod, you can use the `/etc/prose/prose.toml` configuration file (in [TOML](https://toml.io/) format).

Each field can also be overwritten using environment variables with the `PROSE_` prefix and path segments separated by `__`. For example, you might change the Prose Pod API’s maximum log level by setting `PROSE_LOG__LEVEL=debug`.

# General settings

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `branding` | [`BrandingConfig`](#brandingconfig) | Where you configure static data like your company name. | See [below](#brandingconfig) |
| `notify` | [`NotifyConfig`](#notifyconfig) | Where you set how notifications are sent (e.g. when sending invitations). | See [below](#notifyconfig) |
| `log` | [`LogConfig`](#logconfig) | Log configuration for the Prose Pod API. | See [below](#logconfig) |
| `default_response_timeout` | [Duration](#duration) | Timeout after which all requests are cancelled. | `PT10S` |
| `default_retry_interval` | [Duration](#duration) | Default interval between retries (e.g. when running network checks). | `PT5S` |

## BrandingConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `company_name` | `String` | Name of your company. Will be used in places like invitation emails. | - |
| `page_title` | `String` | Name used in some places to refer to your Prose Pod API (e.g. “All data will be erased from {company}’s {page_title} databases.”). You shouldn’t have a reason to change it, but it’s there. | `"Prose Pod API"` |

## NotifyConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `email` | `NotifyEmailConfig` | Email notifications + SMTP configuration. | - |

### NotifyEmailConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `pod_address` | `String` (email address) | Pod email address (e.g. `"prose@{smtp_server_domain}"`). | - |
| `smtp_host` | `String` | SMTP host. | `"localhost"` |
| `smtp_port` | `u16` | SMTP port. | `587` |
| `smtp_username` | `Option<String>` | SMTP username. | - |
| `smtp_password` | `Option<String>` | SMTP password. | - |
| `smtp_encrypt` | `bool` | Enable SMTP encryption. | `true` |

## LogConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `level` | `LogLevel` | Maximum log level (`trace`, `debug`, `info`, `warn`, `error`). | `info` |
| `format` | `LogFormat` | Log format (`full`, `compact`, `json`, `pretty`). See [tracing_subscriber::fmt](https://docs.rs/tracing-subscriber/latest/tracing_subscriber/fmt/index.html#formatters) for more details. | `pretty` in debug, `json` in release |
| `timer` | `LogTimer` | Timer format (`none`, `time`, `uptime`). | `uptime` in debug, `time` in release |
| `with_ansi` | `bool` | Enable ANSI color codes. | `true` in debug, `false` in release |
| `with_file` | `bool` | Include file path in logs. | `true` in debug, `false` in release |
| `with_level` | `bool` | Include log level. | `true` |
| `with_target` | `bool` | Include Rust target module. | `true` |
| `with_thread_ids` | `bool` | Include thread IDs. | `false` |
| `with_line_number` | `bool` | Include line numbers. | `true` in debug, `false` in release |
| `with_span_events` | `bool` | Include span events. | `false` |
| `with_thread_names` | `bool` | Include thread names. | `true` in debug, `false` in release |

---

# Advanced settings

You shouldn’t have to touch those, but if you really need them they exist.
Know that you might break your Prose Pod by changing those, we don’t guarantee anything.

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `databases` | [`DatabasesConfig`](#databasesconfig) | Where you can configure internal Prose Pod API databases. | See [below](#databasesconfig) |
| `bootstrap` | [`BootstrapConfig`](#bootstrapconfig) | Bootstrap configuration. | See [below](#bootstrapconfig) |
| `auth` | [`AuthConfig`](#authconfig) | Authentication & authorization configuration. | See [below](#authconfig) |
| `server` | [`ServerConfig`](#serverconfig) | Server configuration. | See [below](#serverconfig) |
| `prosody` | [`ProsodySettings`](#prosodysettings) | Base Prosody configuration. | - |
| `prosody_ext` | [`ProsodyExtConfig`](#prosodyextconfig) | Prosody extension configuration. | See [below](#prosodyextconfig) |
| `service_accounts` | [`ServiceAccountsConfig`](#serviceaccountsconfig) | Service account configuration. | See [below](#serviceaccountsconfig) |
| `address` | IPv4 / IPv6 | IP address to serve API on\*. | `"0.0.0.0"` |
| `port` | `u16` | Port to serve the API on\*. | `8080` |

!!! (\*) Things will likely break if you change this.

## DatabasesConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `main` | [`DatabaseConfig`](#databaseconfig) | Main database configuration. | See [below](#databaseconfig) |

### DatabaseConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `url` | URI | Database URL. | `"sqlite:///var/lib/prose-pod-api/database.sqlite"` |
| `min_connections` | `Option<u32>` | Minimum number of connections. | `None` |
| `max_connections` | `usize` | Maximum number of connections. | Parallelism capacity \* 4 |
| `connect_timeout` | `u64` (seconds) | Connection acquiring timeout. | `5` |
| `idle_timeout` | `Option<u64>` | Idle connection timeout. | `None` |
| `sqlx_logging` | `bool` | Enable [sqlx](https://docs.rs/sqlx/latest/sqlx/) logging. | `false` |

## BootstrapConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `prose_pod_api_xmpp_password` | `String` | Bootstrap XMPP password for the Prose Pod API service account.\*\* | `"bootstrap"` |

!! (\*\*) [The first thing the Prose Pod API does](https://github.com/prose-im/prose-pod-api/blob/c02f938161f134289a0c2e07f9ccc67dc97848a2/src/rest-api/src/features/startup_actions/mod.rs#L47) when starting up is changing this password to [a very strong random password](https://github.com/prose-im/prose-pod-api/blob/c02f938161f134289a0c2e07f9ccc67dc97848a2/src/service/src/features/xmpp/server_manager.rs#L116-L126), so you shouldn’t have a reason to change it (see [Provide a default bootstrap password · Issue #246 · prose-im/prose-pod-api](https://github.com/prose-im/prose-pod-api/issues/246)).

## AuthConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `token_ttl` | [Duration](#duration) | How long sessions are valid for (how often members need to log into the Dashboard again). Note that this only affects the Dashboard, not Prose apps. | `"PT3H"` (3 hours) |
| `password_reset_token_ttl` | [Duration](#duration) | How long password reset links are valid for. | `"PT15M"` (15 minutes) |
| `oauth2_registration_key` | `String` | OAuth 2.0 registration key. | Random 256-byte key |

## ServerConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `log_level` | `String` | Maximum log level of the Prose Pod Server (`"debug"`, `"info"`, `"warn"`, `"error"`). | `"info"` |
| `defaults` | [`ServerDefaultsConfig`](#serverdefaultsconfig) | Server configuration defaults. Will be used unless you override them using the Dashboard or Prose Pod API. | See [below](#serverdefaultsconfig) |
| `oauth2_registration_key` | `String` | OAuth 2.0 registration key. | Random 256-byte key |
| `oauth2_access_token_ttl` | `u32` (seconds) | OAuth 2.0 access token TTL. | `10800` (3 hours) |
| `http_port` | `u16` | HTTP port.\* | `5280` |
| `local_hostname` | `String` | Local hostname.\* | `"prose-pod-server"` |
| `local_hostname_admin` | `String` | Admin local hostname.\* | `"prose-pod-server-admin"` |

!!! (\*) Things will likely break if you change this.

### ServerDefaultsConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `message_archive_enabled` | `bool` | Activate or deactivate message archiving. | `true` |
| `message_archive_retention` | [Duration](#duration) | Message archive retention period. | `infinite` |
| `file_upload_allowed` | `bool` | Activate or deactivate file upload and sharing. | `true` |
| `file_storage_retention` | [Duration](#duration) | File storage retention period. | `infinite` |
| `tls_profile` | `String` | TLS profile configuration (`"modern"`, `"intermediate"`, `"old"`). See <https://wiki.mozilla.org/Security/Server_Side_TLS>. | `"modern"` |
| `federation_enabled` | `bool` | Enabling federation will allow other servers to connect to your. This lets users from other Prose Workspaces connect with users in this Workspace. For more safety, whitelist friendly servers. | `false` |
| `federation_whitelist_enabled` | `bool` | Whether or not to enable server whitelisting. Caution: If a whitelist is set but disabled, your server will still federate with the entire XMPP network. | `false` |
| `federation_friendly_servers` | `Vec<String>` | If a whitelist is defined, then other servers will not be allowed to connect to this server, except whitelisted ones. It is recommended to whitelist servers you typically work with, i.e. other teams. | `[]` |
| `push_notification_with_body` | `bool` | Whether or not to send the real message body to the remote pubsub node. Without end-to-end encryption, enabling this may expose your message contents to your client developers and OS vendor. Not recommended. | `false` |
| `push_notification_with_sender` | `bool` | Whether or not to send the real message sender to the remote pubsub node. Enabling this may expose your contacts to your client developers and OS vendor. Not recommended. | `false` |

## ProsodyExtConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `additional_modules_enabled` | `Vec<String>` | Additional Prosody modules to enable.\*\* | `[]` |
| `config_file_path` | `String` | Path to the Prosody configuration file.\* | `"/etc/prosody/prosody.cfg.lua"` |

!!! (\*) Things will likely break if you change this.

! (\*\*) Those modules will be enabled globally after everything other configuration has been applied (apart from dynamic overrides, which are always applied last).

## ServiceAccountsConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `prose_workspace` | [`ServiceAccountConfig`](#serviceaccountconfig) | XMPP account of your Prose Workspace itself. It is used to store your Workspace name, accent color and other information in a way that makes it available via the XMPP protocol. | `{ xmpp_node: "prose-workspace" }` |
| `prose_pod_api` | [`ServiceAccountConfig`](#serviceaccountconfig) | XMPP account used by the Prose Pod API itself.\* | `{ xmpp_node: "prose-pod-api" }` |

!!! (\*) Things will likely break if you change this.

### ServiceAccountConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `xmpp_node` | `String` | Local part of the JID used by this service account (see [RFC 6120 - Extensible Messaging and Presence Protocol (XMPP): Core, section 1.4](https://datatracker.ietf.org/doc/html/rfc6120#section-1.4)). The domain part will be your Server’s domain (i.e. `"{xmpp_node}@{server_domain}"`. | - |

---

# Debug settings

As the name suggest, you should only use those settings temporarily.
They might expose user data or things like that. You have been warned.

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `debug_use_at_your_own_risk` | [`DebugConfig`](#debugconfig) | Debug configuration. | See [below](#debugconfig) |

## DebugConfig

| Key | Kind | Description | Default |
| --- | ---- | ----------- | ------- |
| `log_config_at_startup` | `bool` | Log the parsed Prose Pod API configuration at startup. | `true` in debug, `false` in release |
| `detailed_error_responses` | `bool` | Enable detailed error responses (adds detailed messages and debug information). | `true` in debug, `false` in release |
| `c2s_unencrypted` | `bool` | Allow unencrypted client-to-server connections. | `false` |

---

# Custom types

## Duration

A duration in [ISO 8601 format](https://en.wikipedia.org/wiki/ISO_8601#Durations) (e.g. `"PT10S"`, `"PT5M"`, `"P2Y"`…).

## ProsodySettings

Prosody settings. See [Configuring Prosody – Prosody IM](https://prosody.im/doc/configure).

Not all keys are supported, see [prose-pod-api/src/prosody-config/src/prosody_config/mod.rs](https://github.com/prose-im/prose-pod-api/blob/master/src/prosody-config/src/prosody_config/mod.rs). If you miss support for a key, tell us and we’ll add it in a future release!
