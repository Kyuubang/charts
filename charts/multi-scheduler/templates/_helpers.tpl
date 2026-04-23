{{/*
Resolve the effective SecretProviderClass name for a CronJob.
Accepts: dict with "job" (current cronjob) and "root" ($ root context).
Per-job spc.name takes precedence over the global spc.name.
Returns empty string when neither level has spc.name set.
*/}}
{{- define "multi-scheduler.spcName" -}}
{{- $globalSpc := .root.Values.spc | default dict }}
{{- $cronSpc := .job.spc | default dict }}
{{- if $cronSpc.name -}}
{{- $cronSpc.name -}}
{{- else if $globalSpc.name -}}
{{- $globalSpc.name -}}
{{- end -}}
{{- end }}

{{/*
Resolve the effective SPC volume mount path for a CronJob.
Accepts: dict with "job" and "root".
Defaults to "/mnt/secrets" if neither job nor global config provides a path.
*/}}
{{- define "multi-scheduler.spcPath" -}}
{{- $globalSpc := .root.Values.spc | default dict }}
{{- $cronSpc := .job.spc | default dict }}
{{- if $cronSpc.path -}}
{{- $cronSpc.path -}}
{{- else if $globalSpc.path -}}
{{- $globalSpc.path -}}
{{- else -}}
/mnt/secrets
{{- end -}}
{{- end }}

{{/*
Resolve the effective SPC secret name (used as volume subPath) for a CronJob.
Accepts: dict with "job" and "root".
Maps to the secret name in the Key Vault / SecretProviderClass object.
Returns empty string when not set.
*/}}
{{- define "multi-scheduler.spcSecretName" -}}
{{- $globalSpc := .root.Values.spc | default dict }}
{{- $cronSpc := .job.spc | default dict }}
{{- if $cronSpc.secretName -}}
{{- $cronSpc.secretName -}}
{{- else if $globalSpc.secretName -}}
{{- $globalSpc.secretName -}}
{{- end -}}
{{- end }}

{{/*
Render volumeMounts list items for the SPC secret store volume.
Accepts: dict with "job" and "root".
Returns list items (starting with "- name:") so the caller places the
"volumeMounts:" key with the correct nindent level.
Returns empty string when SPC is not configured.
*/}}
{{- define "multi-scheduler.spcVolumeMounts" -}}
{{- $spcName := include "multi-scheduler.spcName" . | trim }}
{{- if $spcName }}
- name: secret-volume
  mountPath: {{ include "multi-scheduler.spcPath" . }}
  {{- $secretName := include "multi-scheduler.spcSecretName" . | trim }}
  {{- if $secretName }}
  subPath: {{ $secretName }}
  {{- end }}
{{- end -}}
{{- end }}

{{/*
Render volumes list items for the SPC secret store CSI driver.
Accepts: dict with "job" and "root".
Returns list items (starting with "- name:") so the caller places the
"volumes:" key with the correct nindent level.
Returns empty string when SPC is not configured.
*/}}
{{- define "multi-scheduler.spcVolumes" -}}
{{- if (include "multi-scheduler.spcName" . | trim) }}
- name: secret-volume
  csi:
    driver: secrets-store.csi.k8s.io
    readOnly: true
    volumeAttributes:
      secretProviderClass: {{ include "multi-scheduler.spcName" . | trim }}
{{- end -}}
{{- end }}
