# Multi-Scheduler Helm Chart

A Helm chart for managing multiple Kubernetes CronJobs with shared configuration and individual scheduling capabilities.

## Description

The multi-scheduler chart allows you to deploy and manage multiple CronJobs in a Kubernetes cluster using a single Helm chart. It provides a flexible way to define common configuration (like container images, environment variables, and resource limits) while allowing each CronJob to have its own unique schedule, timezone, and other specific settings.

## Features

- **Multiple CronJobs**: Deploy multiple CronJobs from a single chart
- **Shared Configuration**: Common settings like image, environment variables, and resources are shared across all jobs
- **Individual Scheduling**: Each CronJob can have its own schedule and timezone
- **Flexible Commands**: Define custom commands for each CronJob
- **Resource Management**: Set CPU and memory limits/requests
- **Image Pull Secrets**: Support for private container registries
- **Timezone Support**: Configure different timezones for each CronJob

## Installation

### Add the Helm Repository (if applicable)

```bash
helm repo add your-repo https://your-helm-repo.com
helm repo update
```

### Install the Chart

```bash
helm install my-multi-scheduler ./multi-scheduler
```

### Install with Custom Values

```bash
helm install my-multi-scheduler ./multi-scheduler -f my-values.yaml
```

## Configuration

### Global Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image` | Container image for all CronJobs | `nginx:latest` |
| `env` | Global environment variables applied to all CronJobs | See values.yaml |
| `resources.limits.cpu` | CPU limit for all containers | `100m` |
| `resources.limits.memory` | Memory limit for all containers | `128Mi` |
| `resources.requests.cpu` | CPU request for all containers | `50m` |
| `resources.requests.memory` | Memory request for all containers | `64Mi` |
| `imagePullSecrets` | Image pull secrets for private registries | `[]` |

### CronJob Configuration Parameters

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `cronjobs[].name` | Name of the CronJob | - | Yes |
| `cronjobs[].schedule` | Cron schedule expression | - | Yes |
| `cronjobs[].suspend` | Whether to suspend the CronJob | `false` | No |
| `cronjobs[].timezone` | Timezone for the CronJob | `UTC` | No |
| `cronjobs[].command` | Command to execute in the container | - | No |

## Usage Examples

### Basic Example

```yaml
image: "alpine:latest"

env:
  - name: "LOG_LEVEL"
    value: "INFO"

cronjobs:
  - name: "daily-backup"
    schedule: "0 2 * * *"  # Daily at 2 AM
    command:
      - "/bin/sh"
      - "-c"
      - "echo 'Running backup...'"
```

### Multiple CronJobs with Different Configurations

```yaml
image: "alpine:latest"

env:
  - name: "ENVIRONMENT"
    value: "production"

resources:
  limits:
    cpu: "200m"
    memory: "256Mi"
  requests:
    cpu: "100m"
    memory: "128Mi"

cronjobs:
  - name: "daily-backup"
    schedule: "0 2 * * *"
    timezone: "UTC"
    suspend: false
    command:
      - "/scripts/backup.sh"

  - name: "weekly-cleanup"
    schedule: "0 3 * * 0"  # Weekly on Sunday
    timezone: "America/New_York"
    suspend: false
    command:
      - "/scripts/cleanup.sh"

  - name: "hourly-health-check"
    schedule: "0 * * * *"  # Every hour
    timezone: "Europe/London"
    suspend: false
    command:
      - "/scripts/health-check.sh"
```

### Using Private Container Registry

```yaml
image: "myregistry.com/myapp:latest"

imagePullSecrets:
  - name: "my-registry-secret"

cronjobs:
  - name: "private-job"
    schedule: "0 */6 * * *"  # Every 6 hours
    command:
      - "/app/run.sh"
```

## Cron Schedule Format

The schedule field uses the standard cron format:

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of the month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday)
│ │ │ │ │
│ │ │ │ │
* * * * *
```

### Common Schedule Examples

| Schedule | Description |
|----------|-------------|
| `0 2 * * *` | Daily at 2:00 AM |
| `0 */6 * * *` | Every 6 hours |
| `*/15 * * * *` | Every 15 minutes |
| `0 3 * * 0` | Weekly on Sunday at 3:00 AM |
| `0 1 1 * *` | Monthly on the 1st at 1:00 AM |
| `0 0 1 1 *` | Yearly on January 1st at midnight |

## CronJob Behavior

- **Concurrency Policy**: Set to `Forbid` - prevents overlapping job executions
- **Failed Jobs History**: Keeps 1 failed job for debugging
- **Successful Jobs History**: Keeps 3 successful jobs
- **Backoff Limit**: Set to 0 - no retry attempts on failure
- **Restart Policy**: `Never` - failed pods are not restarted

## Timezone Support

You can specify different timezones for each CronJob:

```yaml
cronjobs:
  - name: "us-east-job"
    schedule: "0 9 * * *"  # 9 AM Eastern
    timezone: "America/New_York"
  
  - name: "europe-job"
    schedule: "0 14 * * *"  # 2 PM Central European
    timezone: "Europe/Paris"
  
  - name: "asia-job"
    schedule: "0 8 * * *"   # 8 AM Tokyo
    timezone: "Asia/Tokyo"
```

## Upgrading

To upgrade an existing installation:

```bash
helm upgrade my-multi-scheduler ./multi-scheduler -f my-values.yaml
```

## Uninstalling

To uninstall the chart:

```bash
helm uninstall my-multi-scheduler
```

Note: This will remove all CronJobs and their history. Make sure to backup any important data before uninstalling.

## Troubleshooting

### Check CronJob Status

```bash
kubectl get cronjobs
kubectl describe cronjob <cronjob-name>
```

### View Job History

```bash
kubectl get jobs
kubectl logs job/<job-name>
```

### Check Pod Logs

```bash
kubectl get pods
kubectl logs <pod-name>
```

### Common Issues

1. **CronJob not executing**: Check the schedule format and timezone settings
2. **Image pull errors**: Verify image name and registry secrets
3. **Resource constraints**: Check if the cluster has sufficient resources
4. **Command failures**: Check the command syntax and container entrypoint

## Chart Information

- **Chart Version**: 0.1.1
- **Kubernetes Version**: Compatible with Kubernetes 1.19+
- **Helm Version**: Requires Helm 3.0+

## Contributing

Please read the contributing guidelines before submitting pull requests or issues.

## License

This chart is licensed under the same license as the parent repository.
