# `/workspace` on the Grok Bot computer

All Bots on the account share this disk, the browser profile, and CLI credentials.

```text
/workspace/grok-bots/          # this kit (clone)
/workspace/projects/<name>/    # durable project output
/workspace/projects/digest/
/workspace/projects/repro/
/workspace/projects/account-health/
/workspace/projects/product-ops/
/workspace/projects/outbound/
/workspace/projects/talent/
/workspace/projects/paid-media/
/workspace/projects/expenses/
```

- Descriptive names. One project, one folder.
- Final result still belongs in the conversation (or a link to the file), not only on disk.
- Temp dirs and manually installed packages may not survive computer recover/reset. Copy keepers here.
- Do not store secrets, customer dumps, or session cookies in this kit's git tree.
