TITLE: Debugging a Prose Pod
INDEX: 3
UPDATED: 2025-05-31

When something isn’t working correctly in your Prose Pod, your first source of information will be its logs. This guide contains sections for each place where you could see bugs, here is an overview:

- [Dashboard (client side)](#debugging-the-dashboard-client-side)
- [Dashboard (server side)](#debugging-the-dashboard-server-side)
- [Prose apps (client side)](#debugging-prose-apps-client-side)
- [Prose apps (server side)](#debugging-prose-apps-server-side)

! If you can’t find the source of a problem after reading this guide, feel free to [contact our technical support team](#crisp-chat-open) which will gladly help you identify the issue.

## Debugging the Dashboard (client side)

In your web browser, open the developer console and look for errors or warnings.

---

## Debugging the Dashboard (server side)

If your issue happens when using the Dashboard but the developer console shows nothing, checking the Pod API logs should help you. Depending on how you started your Prose Pod, you can see it using `docker compose logs`, `journalctl` or some other utility.

While your problem might be mentioned in a warning or error (enabled by default), more subtle bugs might not be visible by default. In this situation, you will want to make the Pod API logs more verbose.

!!! **Attention:** Increasing log levels will exponentially increase the amount of logs generated, so make sure to revert your changes after you’ve identified your issue. Don’t keep your Pod API running too long with `trace` logs enabled!

To do so, add or update the `[log]` section in `/etc/prose-pod-api/Prose.toml` and set `level` to `"debug"` or `"trace"`:

```toml
# /etc/prose-pod-api/Prose.toml
[log]
level = "debug"
```

If you can’t easily change this configuration file and would prefer using environment variables, know that you can set `PROSE_LOG__LEVEL` instead. It will behave the same.

!! This section accepts more configuration parameters, which you can find documented as [`LogConfig` in the “Pod configuration reference”](/references/pod-config/#logconfig). For example, you might want to set `format = "pretty"` and `with_ansi = true` while you’re debugging.

If you’re seeing timing issues, you might want to check logs in a telemetry console instead of a terminal. To enable telemetry, read [our “Telemetry” guide](/guides/operating/telemetry/).

---

## Debugging Prose apps (client side)

On macOS, find logs at `~/Library/Logs/org.prose.app-web/Prose.log`.

In your web browser, open the developer console.

---

## Debugging Prose apps (server side)

If your issue happens when using the Prose apps but client logs show nothing, only the Pod Server logs can help you. Depending on how you started your Prose Pod, you can see it using `docker compose logs`, `journalctl` or some other utility.

While your problem might be mentioned in a warning or error (enabled by default), more subtle bugs might not be visible by default. In this situation, you will want to make the Pod Server logs more verbose.

!!! **Attention:** Increasing log levels will exponentially increase the amount of logs generated, so make sure to revert your changes after you’ve identified your issue. Don’t keep your Pod Server running too long with `debug` logs enabled!

To do so, add or update the `[server]` section in `/etc/prose-pod-api/Prose.toml` and set `log_level` to `"debug"`:

```toml
# /etc/prose-pod-api/Prose.toml
[server]
log_level = "debug"
```

If you can’t easily change this configuration file and would prefer using environment variables, know that you can set `PROSE_SERVER__LOG_LEVEL` instead. It will behave the same.

!! Find out all possible values in [`ServerConfig` in the “Pod configuration reference”](/references/pod-config/#serverconfig).
