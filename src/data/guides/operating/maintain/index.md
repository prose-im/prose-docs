TITLE: Maintaining a Prose Pod
INDEX: 2
UPDATED: 2025-06-24

## Updating

If you are making a major update (from `X1.Y1.Z1` to `X2.Y2.Z2` if `X1 != X2`), have a look at [the Prose Pod API changelog](https://github.com/prose-im/prose-pod-api/blob/master/CHANGELOG.md) to spot potential changes in configuration keys. We might document major changes here at some point but for now you will have to look at changelogs directly.

### When using Compose

Update your `compose.yaml` file using:

```bash
curl -L https://raw.githubusercontent.com/prose-im/prose-pod-system/refs/tags/${PROSE_VERSION:?}/compose.yaml -o /etc/prose/compose.yaml
```

Then restart using:

```bash
systemctl restart prose
```

## After a factory reset

```bash
rsync -aL --chown=prose:prose /etc/{letsencrypt/live,prosody/certs}/
```

```bash
curl -L https://raw.githubusercontent.com/prose-im/prose-pod-system/refs/heads/master/templates/prose.toml \
  | sed s/'{your_domain}'/${YOUR_DOMAIN:?}/g \
  > /etc/prose/prose.toml
chown prose:prose /etc/prose/prose.toml
# Then edit </etc/prose/prose.toml>!
```
