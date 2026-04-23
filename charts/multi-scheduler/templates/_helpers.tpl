{{/*
Resolve the effective SecretProviderClass name for a CronJob.
Accepts: dict with "job" (current cronjob) and "root" ($ root context).
Per-job spc.name takes precedence over the global spc.name.
*/}}
{{- define "multi-scheduler.spcName" -}}
{{- $globalSpc := .root.Values.spc | default dict }}
{{- $cronSpc := .job.spc | default dict }}
{{- coalesce $cronSpc.name $globalSpc.name }}
{{- end }}

{{/*
Resolve the effective SPC volume mount path for a CronJob.
Accepts: dict with "job" and "root".
Defaults to "/mnt/secrets" if neither job nor global config provides a path.
*/}}
{{- define "multi-scheduler.spcPath" -}}
{{- $globalSpc := .root.Values.spc | default dict }}
{{- $cronSpc := .job.spc | default dict }}
{{- coalesce $cronSpc.path $globalSpc.path | default "/mnt/secrets" }}
{{- end }}

{{/*
Resolve the effective SPC secret name (used as volume subPath) for a CronJob.
Accepts: dict with "job" and "root".
Maps to the secret name in the Key Vault / SecretProviderClass object.
*/}}
{{- define "multi-scheduler.spcSecretName" -}}
{{- $globalSpc := .root.Values.spc | default dict }}
{{- $cronSpc := .job.spc | default dict }}
{{- coalesce $cronSpc.secretName $globalSpc.secretName | default "" }}
{{- end }}

{{/*
Render volumeMounts list items for the SPC secret store volume.
Accepts: dict with "job" and "root".
Returns list items (starting with "- name:") so the caller places the
"volumeMounts:" key with the correct nindent level.
Returns empty string when SPC is not configured.
*/}}
{{- define "multi-scheduler.spcVolumeMounts" -}}
{{- if (include "multi-scheduler.spcName" . | trim) }}
- name: secret-volume
  mountPath: {{ include "multi-scheduler.spcPath" . }}
  subPath: {{ include "multi-scheduler.spcSecretName" . }}
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
