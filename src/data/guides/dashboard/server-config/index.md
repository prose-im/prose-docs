TITLE: Configuring your server
INDEX: 2
UPDATED: 2025-05-15

Once initialized, your Prose server can be configured with the following sections:

- [Team Members](#team-members)
- [Server Features](#server-features)
- [Customization](#customization)
- [Security & Encryption](#security-amp-encryption)
- [Network Setup](#network-setup)
- [Backup & Reset](#backup-amp-reset)

---

## Team Members

The Team Members screen is where:

- You can manage existing team members (eg. remove them)
- Add new team members (by sending an invitation email to them)

$[Team members screen](![Team members screen, with invited members](team-members-demo.png))

---

## Server Features

Server Features is the section where you can fine-tune the policy of your server regarding:

- Storage of user messages in the server-backed archive
- The retention time of the message archive
- Whether users can upload and share files
- Whether to encrypt uploaded files or not
- How much time user uploads should be kept on the server (and removed after the expiration time)

$[Server configuration screen](![Server configuration screen](server-config-demo.png))

---

## Customization

The workspace Customization area is described in the [Customizing your workspace guide](/guides/dashboard/workspace-customization/).

$[Customization screen](![Customization screen, with configured details](customize-workspace-demo.png))

---

## Security & Encryption

The Security & Encryption area lets you:

- Specify if TOTP/MFA is mandated on your server (for all team members)
- Configure the minimum required SSL/TLS protocol version (higher is more secure, and less compatible)

$[Security & Encryption screen](![Security & Encryption screen](settings-security-demo.png))

---

## Network Setup

The Network Setup area allows you to:

- Configure the visibility of your server on the network (is it allowed to communicate with other Prose servers?)
- Show DNS records and setup instructions to configure your domain name
- Run diagnostics to check for network configuration mistakes

$[Network Setup screen](![Network Setup screen](settings-network-demo.png))
$[Network Setup screen (on network check)](![Network Setup screen, with active network check](network-checks-demo.png))
$[Network Setup screen (on DNS records)](![Network Setup screen, with DNS records](dns-records-demo.png))

---

## Backup & Reset

You can download a full back up of your Pod from there, which can be used to quickly restore your Pod to a given state (with all its configuration and user data).

If you wish to perform a factory reset of your Pod, it is also possible. Make sure to download a backup of your Pod before you erase it!
