# Multi-Scheduler Examples

This directory contains example configurations for common use cases of the multi-scheduler Helm chart.

## Available Examples

### 1. Backup Jobs (`backup-jobs.yaml`)
Demonstrates how to set up various backup operations:
- Database backups (daily)
- Filesystem backups (daily)
- Configuration backups (weekly)
- Cleanup of old backups (daily)

**Usage:**
```bash
helm install backup-scheduler ../multi-scheduler -f backup-jobs.yaml
```

### 2. Data Processing Pipeline (`data-pipeline.yaml`)
Shows a complete data processing workflow:
- Data ingestion (every 4 hours)
- Data processing (every 6 hours, offset)
- Data validation (every 6 hours, offset)
- Report generation (daily)
- Weekly summaries (Monday mornings)
- Data cleanup (daily)

**Usage:**
```bash
helm install data-processor ../multi-scheduler -f data-pipeline.yaml
```

### 3. Monitoring and Health Checks (`monitoring-jobs.yaml`)
Comprehensive monitoring setup:
- Health checks (every 5 minutes)
- SSL certificate monitoring (daily)
- Disk space monitoring (hourly)
- Database connection checks (every 15 minutes)
- Log analysis (hourly)

**Usage:**
```bash
helm install monitoring ../multi-scheduler -f monitoring-jobs.yaml
```

## Customizing Examples

Each example file can be customized for your specific needs:

1. **Copy the example file:**
   ```bash
   cp backup-jobs.yaml my-backup-config.yaml
   ```

2. **Edit the configuration:**
   - Update the `image` to point to your container
   - Modify environment variables
   - Adjust schedules and timezones
   - Update commands for your specific use case

3. **Install with your custom configuration:**
   ```bash
   helm install my-jobs ../multi-scheduler -f my-backup-config.yaml
   ```

## Common Patterns

### Environment-Specific Configuration
```yaml
env:
  - name: "ENVIRONMENT"
    value: "production"  # or "staging", "development"
  - name: "API_ENDPOINT"
    value: "https://api.prod.example.com"
```

### Resource Scaling
```yaml
resources:
  limits:
    cpu: "2000m"     # 2 CPU cores for heavy processing
    memory: "4Gi"    # 4 GB for memory-intensive tasks
  requests:
    cpu: "500m"
    memory: "1Gi"
```

### Multi-Timezone Scheduling
```yaml
cronjobs:
  - name: "us-report"
    schedule: "0 9 * * 1-5"      # 9 AM weekdays
    timezone: "America/New_York"
  
  - name: "eu-report"
    schedule: "0 9 * * 1-5"      # 9 AM weekdays
    timezone: "Europe/London"
  
  - name: "asia-report"
    schedule: "0 9 * * 1-5"      # 9 AM weekdays
    timezone: "Asia/Tokyo"
```

## Testing Your Configuration

Before deploying to production, test your configuration:

1. **Dry run installation:**
   ```bash
   helm install test-run ../multi-scheduler -f your-config.yaml --dry-run --debug
   ```

2. **Deploy to a test namespace:**
   ```bash
   kubectl create namespace test-scheduler
   helm install test-scheduler ../multi-scheduler -f your-config.yaml -n test-scheduler
   ```

3. **Monitor the first few executions:**
   ```bash
   kubectl get cronjobs -n test-scheduler
   kubectl get jobs -n test-scheduler
   ```

4. **Clean up test environment:**
   ```bash
   helm uninstall test-scheduler -n test-scheduler
   kubectl delete namespace test-scheduler
   ```

## Best Practices

- Start with shorter intervals for testing, then adjust to production schedules
- Use appropriate resource limits to prevent resource starvation
- Include health checks and monitoring for critical jobs
- Set up alerting for job failures
- Use secrets for sensitive configuration (API keys, passwords)
- Test timezone configurations thoroughly
- Monitor job execution times and adjust schedules to avoid overlaps

## Need Help?

- Check the main [README.md](../README.md) for detailed documentation
- Review the [INSTALL.md](../INSTALL.md) for installation instructions
- Look at the [CHANGELOG.md](../CHANGELOG.md) for version history
