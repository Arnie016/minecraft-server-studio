# Published · 0.1.0 alpha

Public, no-login catalogue:
https://ashfall-workshop.stashofdoodlido.chatgpt.site

Versioned GitHub release:
https://github.com/Arnie016/minecraft-server-studio/releases/tag/workshop-v0.1.0

Source and agent handoff pull request:
https://github.com/Arnie016/minecraft-server-studio/pull/1
Branch: feat/pack-foundry-v0.1.0
Original release source commit: e1992b084a3b1ccd5258f18459b453835dc848b7

The initial GitHub Actions check and release jobs succeeded. Eight release
subjects received signed Sigstore build provenance. Every local pack, bundle,
checksum manifest and catalogue hash matched its published GitHub release asset.

Initial attestation:
https://github.com/Arnie016/minecraft-server-studio/attestations/51616046
Initial workflow:
https://github.com/Arnie016/minecraft-server-studio/actions/runs/36777572482

The site serves byte-identical game archives. Its SHA-256 checks validate
integrity relative to the catalogue. To verify repository identity separately:

```sh
gh attestation verify YOUR-DOWNLOADED-PACK.zip -R Arnie016/minecraft-server-studio
```

Later CI also performs this signature-verification command before publishing
new alpha assets. Existing versioned release assets are never overwritten.

## Hosting continuation

GitHub remains the canonical development handoff. The public Site is a generated
static mirror, deployed from an owner-controlled hosting checkout. The current
hosting manifest uses static.directory = "dist". Future site work must reuse
this exact existing Site identity, not register another Site:

- project_id: appgprj_6abd7aeb333c8191aa05d53cb2f7c5af
- saved version: appgprj_6abd7aeb333c8191aa05d53cb2f7c5af~appgver_0dc5325edd2c81918fe134f2fea17897
- deployment: appgdep_6abd7bda4b6881919fc308cb1f20901d
- hosting source commit: 708147ad0277e81a6fbe48f6261d922887415712
- audience: public

No hosting credentials are stored here. Rebuild pack-foundry/site from GitHub,
then publish those generated files through the existing Site's supported workflow.
A GitHub commit alone does not automatically redeploy this hosted mirror.

The MCP server is a separate **local stdio** component. The public site does not
host an MCP endpoint. No CurseForge projects have been submitted, and no sales,
reward account or background daily mod-generation schedule is configured.
Human Minecraft graphical playtests and marketplace screenshots remain pending.
