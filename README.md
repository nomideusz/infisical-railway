# Deploy and Host Infisical on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/infisical-secrets?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=infisical-secrets)

[Infisical](https://infisical.com/) is the open-source secrets manager: environment variables, API keys, database credentials and certificates in one place, with per-environment projects, secret versioning and point-in-time recovery, access controls, audit logs, and a CLI, SDKs and Kubernetes operator that inject secrets into your apps. This template runs Infisical 0.165.16 on the official image with Postgres and Redis, and creates your admin account on first boot, so Infisical's admin sign-up page is never open to whoever finds the URL first.

## About Hosting Infisical

The stack is three services: Infisical, Postgres and Redis.

- **Upstream's own image, pinned.** Infisical runs from the official `infisical/infisical:v0.165.16` image, with a thin wrapper that only adds the first-boot admin setup and an IPv6 listener for Railway's private network.
- **Admin ready, sign-up closed.** Upstream makes the first visitor to `/admin/signup` the instance admin. Here the first boot creates the admin from your email and a generated password, creates your first organization, and turns public sign-up off. There is nothing to claim.
- **Keys generated for you.** The encryption key and session secret are generated at deploy time in the format Infisical expects.
- **Upgrades that migrate themselves.** Every boot runs Infisical's database migrations before serving.
- **Redis that keeps its queue.** Infisical schedules secret syncs, rotations and reminders through Redis queues, so Redis keeps an append-only file on its own volume.

## Common Use Cases

- One place for a team's `.env` files, with dev, staging and production kept apart
- Injecting secrets into apps at runtime with `infisical run`, the SDKs or the Kubernetes operator instead of committing them
- Syncing secrets to GitHub Actions, Vercel, AWS and other platforms from one source of truth
- Rotating database credentials and issuing short-lived dynamic secrets

## Dependencies for Infisical Hosting

- Postgres 17 (included, private network only)
- Redis 8 (included, private network only)

### Deployment Dependencies

- [Infisical documentation](https://infisical.com/docs/documentation/getting-started/introduction)
- [Infisical self-hosting guide](https://infisical.com/docs/self-hosting/overview)
- [Template source on GitHub](https://github.com/two-workspaces/infisical)

### Implementation Details

**Sign in** at the Infisical service's Railway domain with the email you entered at deploy time and the `INFISICAL_ADMIN_PASSWORD` value from the Infisical service's Variables tab. The first boot runs the database migrations, so give it a couple of minutes. Change the password afterwards in Personal Settings; the variable is only read on first boot. Instance settings live under Server Admin in the sidebar.

**Back up `ENCRYPTION_KEY`.** It encrypts every secret Infisical stores. Copy it from the Infisical service's Variables tab into your password manager now. If it is lost or changed, the database cannot be decrypted, and a Postgres backup alone will not bring your secrets back.

**Teammates.** Invite them under Organization → Access Control. Railway only allows outbound SMTP on the Pro plan, so on other plans the invitation email is not sent; Infisical shows an invite link you can copy and send yourself. To send email on Pro, fill in the `SMTP_*` variables.

**Memory.** About 1.5 GB at idle as Railway measures it: 1.1 GB for Infisical's Node.js process, 0.4 GB for Postgres and 10 MB for Redis. That is more than the Trial plan gives, so deploy on Hobby or above.

**Backups.** Everything lives in Postgres: enable Railway's volume backups on the Postgres volume, and keep `ENCRYPTION_KEY` with them.

**Custom domain.** Add it in the Infisical service's Settings → Networking, then set `SITE_URL` to `https://your.domain`. Infisical uses it for links in emails and for OAuth callbacks.

**Telemetry.** Infisical sends anonymous usage statistics to its developers by default. Set `TELEMETRY_ENABLED=false` on the Infisical service to turn it off.

## Why Deploy Infisical on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Infisical on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
