# Tenant Onboarding

## Overview

This runbook describes how to add a new music collective to the platform.

## Steps

1. Create a row in the `tenants` table.
2. Configure the tenant's `config` JSONB:
   - name
   - primary_color
   - secondary_color
   - accent_color
   - modules
   - domain or subdomain
3. Add default tags for the tenant (optional).
4. Configure the domain in Vercel or DNS.
5. Map the domain to the tenant in the database.
6. Create the first admin user for the tenant.

## Modules

Enable modules per tenant in the `config.modules` field:

```json
{
  "wallet": true,
  "events": true,
  "shop": true,
  "music": true,
  "content": true,
  "versus": false
}
```

## TODO

- [ ] Build admin panel for self-onboarding.
- [ ] Automate DNS/custom domain setup.
