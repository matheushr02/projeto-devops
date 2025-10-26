{{/*
Funções auxiliares comuns do Helm.
*/}}

{{/*
Gera o nome completo do chart.
*/}}
{{- define "projeto-devops.fullname" -}}
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
Cria os labels do seletor do chart.
*/}}
{{- define "projeto-devops.selectorLabels" -}}
app.kubernetes.io/name: {{ include "projeto-devops.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Cria o nome do chart.
*/}}
{{- define "projeto-devops.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Cria labels comuns.
*/}}
{{- define "projeto-devops.labels" -}}
helm.sh/chart: {{ include "projeto-devops.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "projeto-devops.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
