# Roadmap: Forgejo Actions CI runner

Add a self-hosted CI capability to the homelab by deploying a Forgejo Actions
runner container alongside the existing Forgejo instance, so that pushes and
pull requests against Forgejo repositories can execute GitHub-Actions-style
workflows on the droplet.

Related:
* [TODO.md](../../TODO.md) (Phase 6 - Sliplane Services, Phase 8 - Hardening)
* [README.md](../../README.md) (Extension, Status/Health cURL Queries)
* [`code/forgejo_container.tf`](../../code/forgejo_container.tf) (existing registration/`null_resource` pattern)
* [`main.tf`](../../main.tf) (module wiring)
* Forgejo Actions admin guide: https://forgejo.org/docs/latest/admin/actions/
* Forgejo Runner installation (Docker): https://forgejo.org/docs/latest/admin/actions/installation/docker
* Forgejo Runner registration: https://forgejo.org/docs/latest/admin/actions/registration
* Securing Forgejo Actions deployments: https://forgejo.org/docs/latest/admin/actions/security

## Intent

Provide a containerized, network-internal CI runner for the existing Forgejo
(`code.${HOST_NAME}`) instance. The runner authenticates bidirectionally with
Forgejo over the `hosting_network`, exposes **no** Traefik route or Authentik
gate (it is outbound-only and not publicly reachable), and spawns each job in an
ephemeral container. This mirrors the deployment conventions already used by the
other service modules and keeps the "modular Forgejo" model: the Actions engine
is built into the Forgejo server, and the runner is a separately deployed,
registered worker.

## Non-goals

This MRDR does **not** cover, and should not be read as deciding:

* **Woodpecker CI** as an alternative (see Phase 6 - noted as a future
  alternative, not implemented here).
* Autoscaling or multi-runner fleets, or remote/offsite runners.
* Migrating or porting any existing GitLab CI pipelines; there is no
  `.gitlab-ci.yml` in scope.
* Formalizing the "Forgejo Actions vs. Woodpecker" architectural decision in a
  MADR (that is a separate artifact if/when the alternative is pursued).
* Hardening decisions already owned by Phase 8 (CrowdSec/Authentik/WAF); this
  only ensures the runner does not undermine them.

---

## Phase 1: Runner container module and registration

**Objective:** Stand up a `runner` Terraform module that deploys a Forgejo
runner container on `hosting_network` and registers it with the Forgejo
instance, with no public routing.

**Definition of done:** `terraform apply` creates a `forgejo_runner_container`
attached to `hosting_network` (no Traefik labels), and the runner appears as a
registered, idle runner under Forgejo **Site Administration -> Actions ->
Runners**.

- [ ] **CI-RUNNER.1.1**: Add a `runner` module block to `main.tf` passing `HOST_NAME`, `HOSTING_NETWORK_NAME`, and `STATE_PATH` (`"${var.MOUNTED_VOLUME}/runner"`), consistent with other modules
- [ ] **CI-RUNNER.1.2**: Create `runner/runner_image.tf` pinning `code.forgejo.org/forgejo/runner:13` (verify current major at implementation time)
- [ ] **CI-RUNNER.1.3**: Create `runner/runner_container.tf` with a `docker_container` on `hosting_network`, mounting `${STATE_PATH}` at `/data` and the templated config; include **no** `traefik.*` labels
- [ ] **CI-RUNNER.1.4**: Add `runner/runner_config.tftpl` for `config.yaml`, targeting the internal instance URL `http://forgejo_container:3000`, setting `container.network = hosting_network`, `runner.capacity = 1` (caveat: single droplet), and cache settings
- [ ] **CI-RUNNER.1.5**: Add a `random_password` for the registration credential plus module `outputs.tf`, mirroring `code/forgejointernaltoken_randompassword.tf`
- [ ] **CI-RUNNER.1.6**: Add a `null_resource` registration step that is idempotent and non-interactive -- prefer offline registration (`forgejo-cli actions register`, `--secret-file`) or `forgejo-runner register --no-interactive --instance http://forgejo_container:3000` -- following the guarding/retry pattern in `code/forgejo_container.tf`
- [ ] **CI-RUNNER.1.7**: `terraform validate` and `terraform plan` pass; apply and confirm the runner shows as online in the admin UI

## Phase 2: Enable and verify Forgejo Actions end-to-end

**Objective:** Confirm a workflow authored in a repo actually executes on the
runner and succeeds.

**Definition of done:** A test repository containing `.forgejo/workflows/hello.yml`
runs green on a push, with the job executing in an ephemeral container on
`hosting_network`, and job logs visible in Forgejo.

- [ ] **CI-RUNNER.2.1**: Add an `[actions]` section to `code/app.ini.tftpl` (`ENABLED = true`; set `DEFAULT_ACTIONS_URL` if actions should be sourced from a self-hosted/mirrored location rather than GitHub)
- [ ] **CI-RUNNER.2.2**: Create a throwaway test repo and add `.forgejo/workflows/hello.yml` (`on: [push]`, a job with a runner label and a trivial `echo`/`run` step)
- [ ] **CI-RUNNER.2.3**: Push and confirm the job is picked up, runs in a fresh job container, and completes successfully; inspect Forgejo run logs
- [ ] **CI-RUNNER.2.4**: Document the runner and a smoke-test command in `README.md` (Extension and/or Status/Health sections)

## Phase 3: Runner security hardening

**Objective:** Constrain the runner so it cannot be leveraged to escape its
intended scope, addressing the "Docker socket = host root" caveat.

**Definition of done:** The choice of job isolation mechanism is documented, and
the runner is limited to an explicit volume/label/capacity allowlist with no
externally reachable surface.

- [ ] **CI-RUNNER.3.1**: Decide and document Docker-socket mode vs. DinD (trade-off note in `README.md`; a MADR if the decision is non-trivial)
- [ ] **CI-RUNNER.3.2**: If using the host Docker socket, restrict the runner via `container.valid_volumes`, avoid `privileged` job options, and set sane `container.options`
- [ ] **CI-RUNNER.3.3**: Scope the runner (global vs. owner/repo) and confirm configured labels match intended workloads
- [ ] **CI-RUNNER.3.4**: Verify the runner is unreachable from outside `hosting_network` (no Traefik route, no published ports) and review its network egress

## Phase 4: Resource governance and observability

**Objective:** Ensure CI bursts do not starve co-tenanted services and that
runner/CI activity is observable through the existing stack.

**Definition of done:** Runner resource limits are set, runner logs flow to Loki
via the existing Docker logging driver, and resource impact is visible in
Grafana.

- [ ] **CI-RUNNER.4.1**: Apply container memory/CPU constraints and keep `runner.capacity` low enough for the droplet
- [ ] **CI-RUNNER.4.2**: Configure the runner container to ship logs through the established Loki logging driver (consistent with `loki`/`promtail` usage)
- [ ] **CI-RUNNER.4.3**: (Optional) Add a Grafana panel for runner/CI activity and alerts for sustained saturation

## Phase 5: Built-in container registry and image publishing

**Objective:** Use Forgejo's native package/container registry from CI, so a
separate registry service is unnecessary.

**Definition of done:** A workflow builds and pushes an image to the Forgejo
registry, and the image can be pulled back authenticated.

- [ ] **CI-RUNNER.5.1**: Enable/verify the built-in Forgejo container registry and its routing under `code.${HOST_NAME}`
- [ ] **CI-RUNNER.5.2**: Add an example workflow that builds and pushes an image using the workflow's provided token
- [ ] **CI-RUNNER.5.3**: Document authentication/pull usage in `README.md`

## Phase 6: (Future / not in scope) Woodpecker CI evaluation

**Objective:** Reserve a slot for evaluating Woodpecker CI as a GitLab-CI-like
alternative without committing to it here.

**Definition of done:** Deferred; recorded only so the option is not lost.

- [ ] **CI-RUNNER.6.1**: (Deferred) If Actions proves awkward for multi-step/stage pipelines, evaluate Woodpecker server+agent with Forgejo OAuth, and capture the comparison as a MADR
