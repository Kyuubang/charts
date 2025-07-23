# Vector Kubernetes Metrics

A Helm chart for deploying Vector to collect and forward Kubernetes metrics using ServiceMonitor scraping, similar to kube-prometheus-stack but excluding kube-state-metrics and node-exporter.

## Features

- **ServiceMonitor Discovery**: Automatically discovers and scrapes ServiceMonitors
- **Kubernetes API Metrics**: Collects metrics from Kubernetes API resources
- **Kubelet Metrics**: Scrapes container metrics, probes, and cadvisor metrics
- **API Server Metrics**: Collects metrics from Kubernetes API server
- **Flexible Sinks**: Support for Prometheus, Datadog, and custom outputs
- **Excludes Redundant Metrics**: Filters out kube-state-metrics and node-exporter
- **Security**: Non-root container with read-only filesystem
- **RBAC**: Minimal required permissions for metrics collection

## Installation

```bash
# Add the chart repository (if using a repository)
helm repo add your-repo https://your-charts-repo.com

# Install the chart
helm install vector-metrics ./vector-kube-metrics

# Or with custom values
helm install vector-metrics ./vector-kube-metrics -f my-values.yaml
```

## ServiceMonitor Implementation

This chart implements ServiceMonitor discovery and scraping by:

### 1. **Automatic ServiceMonitor Discovery**
Vector automatically discovers ServiceMonitors in specified namespaces and scrapes their endpoints:

```yaml
vector:
  metrics:
    prometheus:
      enabled: true
      serviceMonitor:
        namespaces:
          - "monitor"           # Prometheus operator namespace
          - "kube-system"       # System components
          - "ingress-system"    # Ingress controllers
        selector:
          matchLabels:
            release: "prometheus"  # Only scrape ServiceMonitors with this label
```

### 2. **Supported ServiceMonitor Endpoints**
Based on your cluster's ServiceMonitors, Vector will scrape:

- **Ingress NGINX**: Controller metrics from ingress-system namespace
- **Alertmanager**: Prometheus alertmanager metrics
- **API Server**: Kubernetes API server metrics
- **CoreDNS**: DNS resolution metrics
- **Controller Manager**: Kubernetes controller manager metrics
- **etcd**: Key-value store metrics
- **Kube Proxy**: Network proxy metrics
- **Scheduler**: Kubernetes scheduler metrics
- **Prometheus Operator**: Operator metrics
- **Prometheus Server**: Prometheus itself

### 3. **Automatic Filtering**
The chart automatically excludes:
- `kube-state-metrics` (to avoid duplication)
- `node-exporter` (to avoid duplication)
- Any ServiceMonitor with these labels in the name

### 4. **Authentication Handling**
Vector handles different authentication methods:
- **Bearer tokens** for API server endpoints
- **TLS certificates** for secure endpoints
- **Service account tokens** for cluster-internal scraping

## Configuration Examples

### Basic Configuration

```yaml
# Forward metrics to Prometheus
vector:
  sinks:
    prometheus:
      enabled: true
      endpoint: "http://prometheus-server:9090/api/v1/write"
```

### Datadog Configuration

```yaml
vector:
  sinks:
    datadog:
      enabled: true
      apiKey: "your-datadog-api-key"
      site: "datadoghq.com"
      tags:
        environment: "production"
        cluster: "my-cluster"
```

### Custom Metrics Sources

```yaml
vector:
  metrics:
    prometheus:
      enabled: true
      staticConfigs:
        - targets:
          - "my-app:8080"
          - "another-service:9090"
          labels:
            job: "custom-apps"
```

## Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Vector image repository | `timberio/vector` |
| `image.tag` | Vector image tag | `0.34.0-debian` |
| `vector.metrics.prometheus.enabled` | Enable ServiceMonitor scraping | `true` |
| `vector.metrics.kubernetesApi.enabled` | Enable Kubernetes API metrics | `true` |
| `vector.metrics.kubelet.enabled` | Enable kubelet metrics | `true` |
| `vector.metrics.apiserver.enabled` | Enable API server metrics | `true` |
| `vector.sinks.prometheus.enabled` | Enable Prometheus remote write | `false` |
| `vector.sinks.datadog.enabled` | Enable Datadog sink | `false` |
| `rbac.create` | Create RBAC resources | `true` |
| `serviceAccount.create` | Create service account | `true` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |

## Monitoring

Enable monitoring of Vector itself:

```yaml
monitoring:
  serviceMonitor:
    enabled: true
    labels:
      release: prometheus
```

## Persistence

Enable persistence for Vector's data directory:

```yaml
persistence:
  enabled: true
  size: 10Gi
  storageClass: "fast-ssd"
```

## Security

The chart follows security best practices:

- Non-root user (UID 1001)
- Read-only root filesystem
- Dropped all capabilities
- Minimal RBAC permissions
- Security contexts enforced

## Troubleshooting

1. **Check Vector status**:
   ```bash
   kubectl get pods -l app.kubernetes.io/name=vector-kube-metrics
   ```

2. **View Vector logs**:
   ```bash
   kubectl logs -l app.kubernetes.io/name=vector-kube-metrics
   ```

3. **Check Vector configuration**:
   ```bash
   kubectl get configmap <release-name>-vector-kube-metrics -o yaml
   ```

4. **Test Vector API**:
   ```bash
   kubectl port-forward svc/<release-name>-vector-kube-metrics 8080:8080
   curl http://localhost:8080/health
   ```

## Differences from kube-prometheus-stack

This chart differs from kube-prometheus-stack by:

- Using Vector instead of Prometheus for metrics collection
- Excluding kube-state-metrics and node-exporter components
- Focusing on metrics forwarding rather than storage
- Providing more flexible output options (Datadog, custom endpoints)
- Lightweight deployment with single component

## License

This chart is licensed under the Apache 2.0 License.
