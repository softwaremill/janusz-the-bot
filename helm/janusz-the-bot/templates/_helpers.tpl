{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "janusz-the-bot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "janusz-the-bot.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "janusz-the-bot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "janusz-the-bot.labels" -}}
helm.sh/chart: {{ include "janusz-the-bot.chart" . }}
{{ include "janusz-the-bot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "janusz-the-bot.selectorLabels" -}}
app: {{ include "janusz-the-bot.fullname" . }}
app.kubernetes.io/name: {{ include "janusz-the-bot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "janusz-the-bot.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "janusz-the-bot.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "dbHostConfigSource" -}}
{{- printf "%s%s" .Values.db.hostConfig.kind "KeyRef" -}}
{{- end -}}

{{- define "dbNameConfigSource" -}}
{{- printf "%s%s" .Values.db.dbNameConfig.kind "KeyRef" -}}
{{- end -}}

{{- define "dbUsernameConfigSource" -}}
{{- printf "%s%s" .Values.db.usernameConfig.kind "KeyRef" -}}
{{- end -}}

{{- define "dbPasswordConfigSource" -}}
{{- printf "%s%s" .Values.db.passwordConfig.kind "KeyRef" -}}
{{- end -}}
