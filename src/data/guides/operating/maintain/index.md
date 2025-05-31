TITLE: Maintaining a Prose Pod
INDEX: 2
UPDATED: 2025-05-31

!!! 🚧 This guide is still a work-in-progress.

## Updating

If you are making a major update (from `X1.Y1.Z1` to `X2.Y2.Z2` if `X1 != X2`), have a look at [the Prose Pod API changelog](https://github.com/prose-im/prose-pod-api/blob/master/CHANGELOG.md) to spot potential changes in configuration keys. We might document major changes here at some point but for now you will have to look at changelogs directly.

### When using Compose

Update your `compose.yaml` file using:

```bash
curl -LO https://raw.githubusercontent.com/prose-im/prose-pod-system/refs/tags/${PROSE_VERSION:?}/compose.yaml
```

Then restart using:

```bash
docker compose up -d --force-recreate
```
