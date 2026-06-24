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
{{- $secretNames := include "multi-scheduler.spcSecretNames" . | fromYamlArray | default (list) }}
{{- if gt (len $secretNames) 0 -}}
{{- index $secretNames 0 -}}
{{- end -}}
{{- end }}

{{/*
Resolve effective SPC secret names for a CronJob.
Accepts: dict with "job" and "root".
Priority: cronjob spc.secretNames -> cronjob spc.secretName ->
global spc.secretNames -> global spc.secretName.
Returns a YAML array.
*/}}
{{- define "multi-scheduler.spcSecretNames" -}}
{{- $globalSpc := .root.Values.spc | default dict }}
{{- $cronSpc := .job.spc | default dict }}
{{- $names := list }}
{{- if $cronSpc.secretNames }}
  {{- $names = $cronSpc.secretNames }}
{{- else if $cronSpc.secretName }}
  {{- $names = list $cronSpc.secretName }}
{{- else if $globalSpc.secretNames }}
  {{- $names = $globalSpc.secretNames }}
{{- else if $globalSpc.secretName }}
  {{- $names = list $globalSpc.secretName }}
{{- end }}
{{- toYaml $names -}}
{{- end }}

{{/*
Collect all unique SPC secret names from global and cronjob scope.
Used to auto-generate a global SecretProviderClass objects list.
Returns a YAML array.
*/}}
{{- define "multi-scheduler.allSpcSecretNames" -}}
{{- $globalSpc := .Values.spc | default dict }}
{{- $seen := dict }}
{{- $names := list }}

{{- if $globalSpc.secretName }}
  {{- if not (hasKey $seen $globalSpc.secretName) }}
    {{- $_ := set $seen $globalSpc.secretName true }}
    {{- $names = append $names $globalSpc.secretName }}
  {{- end }}
{{- end }}

{{- range ($globalSpc.secretNames | default (list)) }}
  {{- if and . (not (hasKey $seen .)) }}
    {{- $_ := set $seen . true }}
    {{- $names = append $names . }}
  {{- end }}
{{- end }}

{{- range (.Values.cronjobs | default (list)) }}
  {{- $cronSpc := .spc | default dict }}
  {{- if $cronSpc.secretName }}
    {{- if not (hasKey $seen $cronSpc.secretName) }}
      {{- $_ := set $seen $cronSpc.secretName true }}
      {{- $names = append $names $cronSpc.secretName }}
    {{- end }}
  {{- end }}

  {{- range ($cronSpc.secretNames | default (list)) }}
    {{- if and . (not (hasKey $seen .)) }}
      {{- $_ := set $seen . true }}
      {{- $names = append $names . }}
    {{- end }}
  {{- end }}
{{- end }}

{{- toYaml $names -}}
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
  {{- $secretNames := include "multi-scheduler.spcSecretNames" . | fromYamlArray | default (list) }}
  {{- if eq (len $secretNames) 1 }}
  subPath: {{ index $secretNames 0 }}
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
