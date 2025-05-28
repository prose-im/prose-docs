TITLE: Quickstart
INDEX: 1
UPDATED: 2025-05-28

## Creating a Prose workspace

To create a Prose workspace, the easiest solution is to use our Cloud-hosted service. It is fully managed (uptime & updates) and allows for unlimited members. If you want to deploy Prose on your own premises, you can use the Community version, but beware that it has a 100 members limit. For more information, head over to [our Pricing page](https://prose.org/pricing/ "Pricing | Prose IM").

!!! TODO: @valerian Is there a way to change “Read” in the navigation links and make it open in an external tab?

+ Navigation
  | Prose Cloud: The easiest way to use Prose in your company. -> https://prose.org/cloud/signup/
  | Self-hosted (Community): Want to host a Prose Pod youself? Read this guide. -> /guides/operating/

## Initializing your workspace

!!! TODO: @valerian Where does the user get the URL to their Dashboard in the Cloud version?

Once we’ve created your workspace, we’ll give you a link to your admin dashboard. The first time you open it, you will will be guided through a quick initialization process. This section walks you through it.

### Server domain

!!! TODO: @valerian Will they see this screen in the Cloud version or could we start directly at the workspace name?

The first screen will ask you to choose a domain for your instant messaging server. If your team members emails are **name@company.com**, we recommend you enter **company.com** in the field.

! Prose can co-exist with your email and website **on the same domain**, you don’t need a subdomain for it to work properly.

<details>
  <summary>Click to show an example screenshot</summary>

$[Workspace domain initialization screen](![Workspace initialization screen, workspace domain](/static/user/images/screenshots/dashboard/init-domain-fresh.png))

</details>

### Workspace name

After that, you will be prompted for a workspace name. It will be used on **Prose apps** to identify your workspace. We recommend using your **organization name**.

<details>
  <summary>Click to show an example screenshot</summary>

$[Workspace name initialization screen](![Workspace initialization screen, workspace name](/static/user/images/screenshots/dashboard/init-name-fresh.png))

</details>

### First admin account

Finally, you will be asked for information about the first account you need to create: the initial workspace administrator. Using this account, you will be able to log into the Dashboard to invite users and configure your workspace.

<details>
  <summary>Click to show an example screenshot</summary>

$[Admin account creation screen](![Workspace initialization screen, admin account](/static/user/images/screenshots/dashboard/init-admin-fresh.png))

</details>

## Configuring DNS records

Before you can start using your Prose workspace, you will have to configure DNS records to link it to your domain.

We provide you all the DNS records you need to configure. To find them, navigate to “Advanced Settings” > “Network Setup” then under “Network Setup Tools” click “Show DNS instructions…”.

<details>
  <summary>Click to show an example screenshot</summary>

$[DNS setup instructions screen](![DNS setup instructions screen](/static/user/images/screenshots/dashboard/dns-records-demo.png))

</details>

<!-- FIX: Without this line break, the folowwing paragraph is too close to the details tag. -->
<br/>

Now log into your DNS provider’s administration dashboard (e.g. Cloudflare, AWS Route 53, Google Cloud DNS, Quad9…) and create the records we give you.

The interface is different for each provider and they’re subject to changes so we can’t give you detailed steps but it should be pretty straightforward.

! **Tip:** If your DNS provider allows it, you can edit your DNS zone file and directly paste the DNS records copied to your clipboard when you click “Copy” at the end of each table row.

!!! TODO: @valerian What would you think about adding screenshots showing how DNS setup might look like in a DNS provider’s UI? Like an example where we add records in Cloudflare or some other DNS provider.

### Ensuring your network configuration is correct

Once you have created all DNS records, close the “DNS setup instructions” pane and tap “Start network checks…”. If you had already closed the “DNS setup instructions” pane, you can find this button under “Advanced Settings” > “Network Setup” > “Network Setup Tools”.

You should then see a screen that runs different network configuration checks and shows what is still misconfigured.

<details>
  <summary>Click to show an example screenshot</summary>

$[Network configuration checker screen](![Network configuration checker screen](/static/user/images/screenshots/dashboard/network-checks-demo.png))

</details>

!! <p>If failed, network checks retry after 5 seconds (or whetever your [`default_retry_interval` configuration](/references/pod-config/#general-settings) is). This means you can leave the pane open, change some configuration and come back to see if it is now fixed.</p><p>However, note that network configuration usually takes some time to propagate due to multiple layers of caching in networks. The Prose Pod API tries to run DNS checks directly, but you might still have to wait for clients to connect properly.</p><p>Also beware that network checks will stop retying after 5 minutes, to avoid useless retries if you kept the pane open in another we browser tab. In this situation, you can hit the restart button at the top of the pane or close and reopen the pane to reset this timer.</p>

Once all network checks have passed, your Prose workspace is ready to be used 🥳

## Inviting the first member

After you’ve [configured your DNS records](#configuring-dns-records) and [checked that they are correctly configured](#ensuring-your-network-configuration-is-correct), it’s now time to invite your first colleague!

To do so, open “Team Members” > “Members & Invites” then click “Add a Team Member” and fill the form.

!!! **Attention:** The username you choose when creating the invitation is definitive. You will not be able to change it after the account is created.

<details>
  <summary>Click to show an example screenshot</summary>

$[TODO](![TODO](/static/user/images/screenshots/dashboard/invite-member-fresh.png))

</details>

## Next steps

+ Navigation
  | Download Prose: Download the Prose app to start chatting. -> ./download/
  | Discover the Dashboard: Other features of the Dashboard. -> /guides/dashboard/
