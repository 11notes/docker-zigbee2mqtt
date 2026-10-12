{{/*
Expand the name of the chart.
*/}}
{{- define "zigbee2mqtt.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "zigbee2mqtt.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name and version label.
*/}}
{{- define "zigbee2mqtt.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "zigbee2mqtt.labels" -}}
helm.sh/chart: {{ include "zigbee2mqtt.chart" . }}
{{ include "zigbee2mqtt.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "zigbee2mqtt.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zigbee2mqtt.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Claim name for a given persistence volumes.
*/}}
{{- define "zigbee2mqtt.claimName" -}}
{{- $root := index . 0 }}
{{- $vol := index . 1 }}
{{- $cfg := index $root.Values.persistence $vol }}
{{- if $cfg.existingClaim }}
{{- $cfg.existingClaim }}
{{- else }}
{{- printf "%s-%s" (include "zigbee2mqtt.fullname" $root) $vol }}
{{- end }}
{{- end }}