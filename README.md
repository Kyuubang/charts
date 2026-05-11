# charts

Helm chart repository by [Kyuubang](https://github.com/Kyuubang).

```bash
helm repo add kyuubang https://kyuubang.github.io/charts
helm repo update
```

---

## Charts

| Chart | Version | Description |
|---|---|---|
| [`basic-microservices`](#basic-microservices) | 0.1.0 | Deploy multiple microservices with shared Ingress, SPC, and HPA |
| [`multi-scheduler`](#multi-scheduler) | 0.2.2 | Manage multiple CronJobs with shared configuration |
| [`vector-kube-metrics`](#vector-kube-metrics) | 0.1.0 | Collect and forward Kubernetes metrics via Vector + ServiceMonitor |

---

## basic-microservices

Deploy and manage multiple microservices from a single values file. Creates a Deployment, Service, and shared Ingress per service, with optional HPA and Azure Key Vault secret mounting via CSI Secret Provider.

**Install**
```bash
helm install my-release kyuubang/basic-microservices -f values.yaml
```

**Key values**

```yaml
prefix: my-app          # prepended to all resource names
namespace: my-namespace
ingress:
  enabled: true
  host: api.example.com
spc:                    # Azure Key Vault (optional)
  enabled: false
resources:
  limits:
    cpu: 128m
    memory: 128Mi
microservices:
  - name: user-service
    image: "registry/user-service:v1.0.0"
    port: 9900
    path: /api/users/v1
    replicas: 1
    hpa:                # optional autoscaling
      enabled: true
      minReplicas: 1
      maxReplicas: 5
      targetCPUUtilizationPercentage: 80
    spc:                # optional secret mount
      mountPath: /app/.env
      objectName: my-secret
```

**Resource name patterns**

| Resource | Pattern |
|---|---|
| Deployment | `<prefix>-<name>` |
| Service | `svc-<prefix>-<name>` |
| Ingress | `ingress-pls-<prefix>` |
| HPA | `hpa-<prefix>-<name>` |
| SecretProviderClass | `spc-<prefix>-<name>` |

→ [Full chart](charts/basic-microservices)

---

## multi-scheduler

Manage multiple Kubernetes CronJobs from a single values file with shared image, env, and resource configuration. Each job can define its own schedule, timezone, and command.

**Install**
```bash
helm install my-schedulers kyuubang/multi-scheduler -f values.yaml
```

**Key values**

```yaml
image: "alpine:latest"
cronjobs:
  - name: daily-report
    schedule: "0 2 * * *"
    command: ["sh", "-c", "echo hello"]
    timezone: "Asia/Jakarta"
```

→ [Full chart](charts/multi-scheduler) · [Examples](charts/multi-scheduler/examples)

---

## Contributing

Charts live under `charts/<chart-name>/`. Each chart follows standard Helm structure with a `values.yaml` and `templates/`.

To test a chart locally:
```bash
helm template my-release charts/<chart-name> -f charts/<chart-name>/values.yaml
```
