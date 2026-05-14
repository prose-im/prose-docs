TITLE: Backups
INDEX: 40
UPDATED: 2026-04-30

## Introduction

Starting at Prose Pod Server version `0.5.0`, Prose Pods come with a backup
feature. As of 2026-04-30 they are not automated, but you can create backups
and restore them directly from the Prose Pod Dashboard.

This guide explains how to achieve each use case you might have by providing
configuration samples. For a more detailed configuration reference, check the
[Pod configuration reference](/references/pod-config/).

## Overview

The Backup & Restore functionnality is configured via the `backups`
configuration key (e.g. in `/etc/prose/prose.toml`).

Backups cannot be enabled by default, because you need to inform your Prose Pod
where to store them. As of 2026-04-30 you can store them in [S3]-compliant
object storage, or somewhere in the machine’s file system (leveraging mounted
paths).

Backups are created by archiving all files Prose needs into a [tar] archive,
[compressing][compression] it and optionally [encrypting][encryption] it.
Once that done, a [cryptographic digest] ([checksum]) is computed to later
ensure the [integrity] of the backup (hashing step). Backups can also be
cryptographically [signed][signature] to ensure their authenticity.

Each step can be configured independently, allowing one to choose which
algorithms are used and change their parameters. By default (as of 2026-04-30),
compression uses [Zstandard (zstd)][zstd] and hashing (i.e. computing the
digest) uses [BLAKE3]. Signing and encryption are done using the [OpenPGP]
standard. As indicated earlier, archiving is done using the [tar] format, and
it cannot be configured.

## Getting started

To enable backups in your Prose Pod, all you need to say is where backups
should be stored. The expected scenario is to use [S3]; here is what it would
look like:

```toml
[backups.storage]
provider = "s3"
s3.bucket_name = "example-bucket1"
# Optionally, set an object prefix:
# s3.prefix = "prose/"
# Optionally, enable “Force path style”:
# s3.force_path_style = true
s3.region = "example"
s3.endpoint_url = "https://example.your-objectstorage.com"
s3.access_key = "EXAMPLEACCESSKEY1234"
# Pass the secret key via the `PROSE_BACKUPS__STORAGE__S3__SECRET_KEY`
# environment variable.

# WARN: You should really enable backup encryption!
#   Find out how later in this guide.
```

Then expose your S3 secret key to Prose via the `PROSE_BACKUPS__S3__SECRET_KEY`
environment variable and you’ll be good to go!

! Note that `backups.s3` is an alias for `backups.storage.s3`, which you can use to improve your configuration’s readability (especially environment variables).

## Going further

Enabling the backup feature is a good improvement, but some more configuration
is recommended to mitigate some possible attack vectors. As much as we’d like
it to be the default behavior, it is technically impossible as it requires
further configuration. While we _could_ technocally create and manage an
encryption key for you until you provide one, we chose to give you full control
and not create a gray zone where you’re unsure if we _could_ decrypt your data
(we can’t).

### Storing cryptographic checks separately

While it is the default behavior for the sake of simplicity, storing backups
alongside their cryptogrphic checks is not a wise idea. If an attacker were to
get write access to your backup storage, they would be able to publish a new
backup and its integrity check. If you use your backup storage to store anything
other than Prose backups, you likely have credentials exposed somewhere else and
should really consider moving checks away.

To do so, you can split your `backups.storage` configuration key into
`backups.storage.backups` and `backups.storage.checks`. Each of those nested
keys have the same structure as `backups.storage`, whose value is propagated
as default value for `.backups` and `.checks`. This means separating checks
from backups is as simple as:

```diff
  [backups.storage]
  provider = "s3"
  s3.region = "example"
  s3.endpoint_url = "https://example.your-objectstorage.com"
  # NOTE: This can be in `[backups.storage.backups]` for clarity.
  s3.bucket_name = "example-bucket1"
  s3.access_key = "EXAMPLEACCESSKEY1234"
+
+ [backups.storage.checks]
+ s3.bucket_name = "example-bucket2"
+ s3.access_key = "OTHEREXAMPLEACCESSKEY"
```

Another way to address this is to make signing mandatory (not just enabling
it!). Instructions are given further down this guide.

### Enabling backup signing

By default, backups are not signed as it requires a secret signing key to be
configured and accessible. However, it means that an attacker with write access
to your backup storage can create a malicious backup and its associated
integrity check to lure you into restoring malicious data. One way to mitigate
this threat is to enable cryptographic signing.

To do so, you first need to get yourself an OpenPGP signing-capable key. If
you’re not familiar with this, we suggest you follow
[Sequoia PGP’s guide “Creating a key”]. It uses the modern `sq`
[Command-Line Interface (CLI)][CLI] which is easier to use than GnuPG’s `gpg`.
You can still use any software to generate the key, this is just a suggestion.

!! For increased security, we suggest you protect the private key material with a passphrase; Prose supports it. If you were not prompted for one when creating the key/subkey, you really should generate a new one.

Once you have that key, you need to export it with its private key material
(i.e. as a “Transferable Secret Key” (TSK)) and store it somewhere on the
machine running Prose. It is recommended to use the binary format, although
Prose also supports ASCII-armored. To prevent leaks[^tsk-leak], you should
store it outside of Prose’s operational directories (which are listed in
[our “Deploying a Prose Pod” guide](/guides/operating/deploy/)).
You should also ensure permissions are minimal (e.g. `600`, owned by the user
running your Prose Pod).

[^tsk-leak]: If you haven’t enabled backup encryption, your signing keys would be readable if they are included in backups. Make sure to keep them out. Even then, don’t think encryption is a silver bullet as you might unknowingly expose keys if you ever disable encryption and generate a new backup (e.g. an automatically recurring backup) without cleaning up the keys first. Avoid this footgun and store keys outside of Prose’s operational directories.

Once that done, add the following lines to your configuration:

```toml
[backups.signing]
pgp.enabled = true
# NOTE: This file MUST contain private key material,
#   as it’s used for signature verification.
pgp.tsk = "/path/to/example.pgp"
```

If your signing key is passphrase-protected —which it should be—, you can
expose the passphrase to your Prose Pod using the
`PROSE_BACKUPS__PGP__PASSPHRASES__<FINGERPRINT>` environment variable, where
`<FINGERPRINT>` is the long fingerprint of the certificate or subkey.

! Note that `backups.pgp` is an alias for `backups.signing.pgp`, which you can use to improve your configuration’s readability (especially environment variables).

!!! **Attention:** Enabling signing won’t mitigate the aforementioned attack vector if you don’t verify the authenticity of a backup before restoring it (e.g. by checking the validity of the backup’s signature in the Prose Pod Dashboard). For proper mitigation, read [the “Making backup signing mandatory” section](#making-backup-signing-mandatory) of this guide.

<!-- NOTE: Signing is automatically made mandatory when enabled.
### Making backup signing mandatory

By default, when you enable signing it only makes it so new backups are signed
but does not enforce checking the authenticity of backups when restoring them.
Integrity is still ensured by cryptographic checksums, but a backup with no
signature won’t get rejected. This is to ensure that backups created before you
enabled signing remain restorable, unless you intentionally choose otherwise.

One downside of this is that an administrator can unknowingly restore a
malicious backup created by an attacker with write access to your backup
storage. To make Prose reject any backup without a valid signature, you can
make signing mandatory:

```toml
[backups.signing]
mandatory = true
```
-->

### Enabling backup encryption

Your data is secure when it’s on your server, but backups are not encrypted by
default and are stored externally. If an attacker gains read access to your
backup storage, all of your data leaks. Just like signing, we can’t enable
backup encryption by default, but you really should enable it.

To do so, follow the instructions in [the “Enabling backup signing” section],
but this time create a key/subkey for storage encryption. You can reuse the
same certificate you use for signing. Configuration keys are analogous:

```toml
[backups.encryption]
mode = "pgp"
# NOTE: This file MUST contain private key material,
#   as it’s used for decryption.
pgp.tsk = "/path/to/prose-backup.asc"
```

Passphrases are passed the same way as they are for backup signing.

## Advanced configuration

### Changing the compression level

Prose uses [Zstandard][zstd] by default, at the default compression level of 3.
If you wish to change this value, you can set it this way:

```toml
[backups.compression]
algorithm = "zstd"
# This value is transparently passed to the `zstd` Rust library for forward
# compatibility, meaning any negative or positive value can be used although
# `zstd` only supports `<= 22` at the moment.
# The special value `0` means `zstd`’s default (currently `3`).
# Default is `3`.
zstd.compression_level = 4
```

### Changing the hashing algorithm

Prose uses [BLAKE3] as the default hashing algorithm. If you want/need to use
another one (e.g. SHA-256 for compliance reasons), here is how to configure it:

```toml
[backups.hashing]
# The algorithm to use when computing backup checksums.
# Possible values: `"BLAKE3"` (default), `"SHA-256"`.
algorithm = "BLAKE3"
```

### Adding encryption recipients

Use if you need to decrypt backups using private keys not present on the server
(e.g. in a separate environment for forensic analysis), you can add encryption
recipients. The same way as you expose the “main” encryption key, you can list
paths to additional OpenPGP certificates to use when encrypting:

```toml
[backups.encryption]
# NOTE: Those files SHOULD NOT contain any private key material.
pgp.additional_recipients = ["/path/to/other-system.pub.asc"]
```

### Changing the maximum backup download URL lifetime

When downloading a backup in the Prose Pod Dashboard, a short-lived URL is
generated. As the URL lifetime is parameterized, an attacker could try to
generate an “infinite” one. That’s why we put a soft limit of 5 minutes.
If you need to generate longer-lasting download URLs, you can use the
`backups.download.url_max_ttl` configuration key:

```toml
[backups.download]
# NOTE: Uses the [ISO 8601 Duration format](https://en.wikipedia.org/wiki/ISO_8601#Durations).
url_max_ttl = "PT5M"
```

### Enabling S3 Object Lock

Prose backups support [S3 Object Lock]. You can configure it using the following
keys in `backups.s3`, `backups.storage.s3`, `backups.storage.backups.s3` or
`backups.storage.checks.s3` (wherever fits best):

- `object_lock_mode`: `"compliance"` or `"governance"`
- `object_lock_duration`: [ISO 8601 Duration]
- `object_lock_legal_hold_status`: `"on"` or `"off"`

!! If using Object Lock, you should also enable some bucket-level configuration to automatically cleanup objects and delete markers once the retention period ends. Because of mandatory versioning, Prose can only mark objects as deleted but the underlying data will still exist (and be billed by your provider!).

## Maintenance

### Rotating keys

Using short-lived subkeys and rotating them regularly is a great practice.
Prose supports that out of the box, you shouldn’t have anything to change in
your configuration.

However, if you happen to change the “primary” keys used for signing/encryption
you might render old backups unrecoverable. To prevent that, you can keep the
old keys around and inform Prose to trust/use them if needed:

```toml
[backups.signing]
# Optional. Use if you changed the primary key instead of rotating subkeys.
# NOTE: Those SHOULD NOT contain any private key material.
pgp.additional_trusted_issuers = ["/path/to/example-old.pub.pgp"]

[backups.encryption]
# Optional. Use if you changed the primary key instead of rotating subkeys.
# NOTE: Those MUST contain private key material.
pgp.additional_decryption_keys = ["/path/to/example-old.pgp"]
```

## Gotchas

### Compiling `prose-pod-server` yourself

If you compile `prose-pod-server` yourself instead of using the pre-compiled
version, make sure to enable the appropriate feature flags to keep old backups
restorable. For example, if you had BLAKE3 checksums but migrated to SHA-256
and stopped compiling with `hashing-blake3`, your old backups will be rendered
invalid.

## Debugging

If you ever encounter issues and need to do some debugging, please
[contact our technical support team][contact] which will gladly guide you.

## Need a missing feature?

If you have a use case we haven’t thought about, or would like us to improve
something (e.g. introduce automated periodic backups), please
[contact our technical support team][contact].

[BLAKE3]: https://en.wikipedia.org/wiki/BLAKE_(hash_function)#BLAKE3 "“BLAKE (hash function)” on Wikipedia"
[checksum]: https://en.wikipedia.org/wiki/Checksum "“Checksum” on Wikipedia"
[CLI]: https://en.wikipedia.org/wiki/Command-line_interface "“Command-line interface” on Wikipedia"
[compression]: https://en.wikipedia.org/wiki/Data_compression "“Data compression” on Wikipedia"
[contact]: https://prose.org/contact/ "Prose contact form"
[cryptographic digest]: https://en.wikipedia.org/wiki/Cryptographic_hash_function#Verifying_the_integrity_of_messages_and_files "“Cryptographic hash function” on Wikipedia"
[encryption]: https://en.wikipedia.org/wiki/Encryption "“Encryption” on Wikipedia"
[integrity]: https://en.wikipedia.org/wiki/Data_integrity "“Data integrity” on Wikipedia"
[ISO 8601 Duration]: https://en.wikipedia.org/wiki/ISO_8601#Durations "“ISO 8601” on Wikipedia"
[OpenPGP]: https://en.wikipedia.org/wiki/Pretty_Good_Privacy#OpenPGP "“Pretty Good Privacy” on Wikipedia"
[S3 Object Lock]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html "“Locking objects with Object Lock” in AWS S3 docs"
[S3]: https://en.wikipedia.org/wiki/Amazon_S3 "“Amazon S3” on Wikipedia"
[Sequoia PGP’s guide “Creating a key”]: https://book.sequoia-pgp.org/sq_key_generation.html "“Creating a key” in the Sequoia PGP book"
[signature]: https://en.wikipedia.org/wiki/Digital_signature "“Digital signature” on Wikipedia"
[tar]: https://en.wikipedia.org/wiki/Tar_(computing) "“tar (computing)” on Wikipedia"
[the “Enabling backup signing” section]: #enabling-backup-signing
[zstd]: https://en.wikipedia.org/wiki/Zstd "“zstd” on Wikipedia"
