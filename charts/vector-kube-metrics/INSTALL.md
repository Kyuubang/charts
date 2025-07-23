# Vector Kubernetes Metrics - Quick Start Guide

## Prerequisites

1. **Kubernetes cluster** with RBAC enabled
2. **ServiceMonitor CRDs** installed (usually by Prometheus Operator)
3. **Existing ServiceMonitors** in your cluster (like from kube-prometheus-stack)

## Installation Steps

### 1. Basic Installation

```bash
# Install with default settings (metrics to console for debugging)
helm install vector-metrics ./charts/vector-kube-metrics

# Check if Vector is running
kubectl get pods -l app.kubernetes.io/name=vector-kube-metrics
```

### 2. Forward Metrics to Prometheus

```bash
# Install with Prometheus remote write
helm install vector-metrics ./charts/vector-kube-metrics \
  --set vector.sinks.prometheus.enabled=true \
  --set vector.sinks.prometheus.endpoint="http://prometheus-server.monitor.svc.cluster.local:9090/api/v1/write"
```

### 3. Forward Metrics to Datadog

```bash
# Install with Datadog integration
helm install vector-metrics ./charts/vector-kube-metrics \
  --set vector.sinks.datadog.enabled=true \
  --set vector.sinks.datadog.apiKey="your-datadog-api-key" \
  --set vector.sinks.datadog.site="datadoghq.com"
```

### 4. Custom Configuration

```bash
# Use custom values file
helm install vector-metrics ./charts/vector-kube-metrics -f values-example.yaml
```

## Verification

### Check Vector Status
```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=vector-kube-metrics

# Check Vector logs
kubectl logs -l app.kubernetes.io/name=vector-kube-metrics

# Check Vector health endpoint
kubectl port-forward svc/vector-metrics-vector-kube-metrics 8080:8080
curl http://localhost:8080/health
```

### Verify Metrics Collection
```bash
# Check Vector's internal metrics
curl http://localhost:8080/metrics

# Check what ServiceMonitors are being discovered
kubectl get servicemonitors -A
```

## What Gets Scraped

Vector automatically discovers and scrapes these ServiceMonitor endpoints:

- ✅ **ingress-nginx-controller** - NGINX Ingress metrics
- ✅ **prometheus-kube-prometheus-alertmanager** - Alertmanager metrics  
- ✅ **prometheus-kube-prometheus-apiserver** - API Server metrics
- ✅ **prometheus-kube-prometheus-coredns** - CoreDNS metrics
- ✅ **prometheus-kube-prometheus-kube-controller-manager** - Controller Manager metrics
- ✅ **prometheus-kube-prometheus-kube-etcd** - etcd metrics
- ✅ **prometheus-kube-prometheus-kube-proxy** - Kube Proxy metrics
- ✅ **prometheus-kube-prometheus-kube-scheduler** - Scheduler metrics
- ✅ **prometheus-kube-prometheus-kubelet** - Kubelet/cAdvisor metrics
- ✅ **prometheus-kube-prometheus-operator** - Prometheus Operator metrics
- ✅ **prometheus-kube-prometheus-prometheus** - Prometheus Server metrics
- ❌ **prometheus-kube-state-metrics** - Excluded (to avoid duplication)
- ❌ **prometheus-prometheus-node-exporter** - Excluded (to avoid duplication)

## Troubleshooting

### Vector Not Starting
```bash
# Check RBAC permissions
kubectl auth can-i get servicemonitors --as=system:serviceaccount:default:vector-metrics-vector-kube-metrics

# Check configuration
kubectl get configmap vector-metrics-vector-kube-metrics -o yaml
```

### No Metrics Being Scraped
```bash
# Check ServiceMonitors exist
kubectl get servicemonitors -A

# Check Vector can reach endpoints
kubectl exec -it deployment/vector-metrics-vector-kube-metrics -- curl -k https://kubernetes.default.svc.cluster.local:443/metrics
```

### Authentication Issues
```bash
# Check service account token
kubectl get serviceaccount vector-metrics-vector-kube-metrics -o yaml

# Check RBAC permissions
kubectl describe clusterrolebinding vector-metrics-vector-kube-metrics
```

## Customization

See `values-example.yaml` for advanced configuration options including:
- Custom namespace filtering
- Additional static targets
- Custom authentication
- Resource limits
- Persistence options
