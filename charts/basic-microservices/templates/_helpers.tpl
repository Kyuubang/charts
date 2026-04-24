{{/*
Expand the name of the chart.
*/}}
{{- define "basic-microservices.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the chart label value: <name>-<version>
*/}}
{{- define "basic-microservices.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels. Requires a "context" key pointing to the root context ($).
Usage: include "basic-microservices.labels" (dict "context" $)
*/}}
{{- define "basic-microservices.labels" -}}
helm.sh/chart: {{ include "basic-microservices.chart" .context }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
app.kubernetes.io/part-of: {{ .context.Chart.Name }}
{{- end }}

{{/*
Deployment name: <prefix>-<name>
Usage: include "basic-microservices.msFullName" (dict "prefix" .Values.prefix "name" $ms.name)
*/}}
{{- define "basic-microservices.msFullName" -}}
{{- printf "%s-%s" .prefix .name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Service name: svc-<prefix>-<name>
Usage: include "basic-microservices.svcName" (dict "prefix" .Values.prefix "name" $ms.name)
*/}}
{{- define "basic-microservices.svcName" -}}
{{- printf "svc-%s-%s" .prefix .name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Ingress name: ingress-pls-<prefix>
Usage: include "basic-microservices.ingressName" (dict "prefix" .Values.prefix)
*/}}
{{- define "basic-microservices.ingressName" -}}
{{- printf "ingress-pls-%s" .prefix | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
HPA name: hpa-<prefix>-<name>
Usage: include "basic-microservices.hpaName" (dict "prefix" .Values.prefix "name" $ms.name)
*/}}
{{- define "basic-microservices.hpaName" -}}
{{- printf "hpa-%s-%s" .prefix .name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
SecretProviderClass name: spc-<prefix>-<name>
Usage: include "basic-microservices.spcName" (dict "prefix" .Values.prefix "name" $ms.name)
*/}}
{{- define "basic-microservices.spcName" -}}
{{- printf "spc-%s-%s" .prefix .name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels for a microservice.
Usage: include "basic-microservices.selectorLabels" (dict "prefix" .Values.prefix "name" $ms.name)
*/}}
{{- define "basic-microservices.selectorLabels" -}}
app: {{ printf "%s-%s" .prefix .name }}
{{- end }}

{{/*
Resolve resources: ms-level overrides global if set.
Usage: include "basic-microservices.resources" (dict "global" $.Values "ms" $ms)
*/}}
{{- define "basic-microservices.resources" -}}
{{- if .ms.resources }}
{{- toYaml .ms.resources }}
{{- else }}
{{- toYaml .global.resources }}
{{- end }}
{{- end }}

{{/*
Resolve env: ms-level fully overrides global if set (not merged).
Usage: include "basic-microservices.env" (dict "global" $.Values "ms" $ms)
*/}}
{{- define "basic-microservices.env" -}}
{{- $env := .ms.env | default .global.env }}
{{- if $env }}
{{- toYaml $env }}
{{- end }}
{{- end }}

{{/*
Resolve SPC configuration: ms-level fields take precedence over global defaults.
Empty string values in ms.spc fall back to global.spc (coalesce treats "" as empty).
Returns a YAML map — use with fromYaml to access fields.
Usage: include "basic-microservices.spcResolve" (dict "global" $.Values "ms" $ms) | fromYaml
*/}}
{{- define "basic-microservices.spcResolve" -}}
{{- $g := .global.spc | default dict }}
{{- $m := .ms.spc | default dict }}
mountPath: {{ coalesce (get $m "mountPath") (get $g "mountPath") | default "" | quote }}
objectName: {{ coalesce (get $m "objectName") (get $g "objectName") | default "" | quote }}
tenantId: {{ coalesce (get $m "tenantId") (get $g "tenantId") | default "" | quote }}
keyvaultName: {{ coalesce (get $m "keyvaultName") (get $g "keyvaultName") | default "" | quote }}
userAssignedIdentityID: {{ coalesce (get $m "userAssignedIdentityID") (get $g "userAssignedIdentityID") | default "" | quote }}
{{- end }}
