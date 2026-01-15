{{/*
Expand the name of the chart.
*/}}
{{- define "mailpiler.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mailpiler.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "mailpiler.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mailpiler.labels" -}}
helm.sh/chart: {{ include "mailpiler.chart" . }}
{{ include "mailpiler.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mailpiler.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mailpiler.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mailpiler.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mailpiler.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "mailpiler.databaseSecretName" -}}
{{- if .Values.mariadb.enabled -}}
  {{- if .Values.mariadb.auth.existingSecret -}}
{{- .Values.mariadb.auth.existingSecret -}}
  {{- else -}}
{{- include "mailpiler.mariadb.fullname" . -}}
  {{- end -}}
{{- else -}}
  {{- if .Values.database.existingSecret -}}
{{- .Values.database.existingSecret -}}
  {{- else -}}
{{- printf "%s-db" (include "mailpiler.fullname" .) -}}
  {{- end -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.mariadb.fullname" -}}
{{- if .Values.mariadb.fullnameOverride -}}
{{- .Values.mariadb.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "mariadb" .Values.mariadb.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.manticore.serviceName" -}}
{{- printf "%s-manticore" (include "mailpiler.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "mailpiler.smtpServiceName" -}}
{{- printf "%s-smtp" (include "mailpiler.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "mailpiler.smtp.host" -}}
{{- if .Values.smtpService.enabled -}}
{{- include "mailpiler.smtpServiceName" . -}}
{{- else -}}
{{- include "mailpiler.fullname" . -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.smtp.port" -}}
{{- if .Values.smtpService.enabled -}}
{{- .Values.smtpService.port -}}
{{- else -}}
{{- .Values.service.ports.smtp -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.memcached.fullname" -}}
{{- if .Values.memcached.fullnameOverride -}}
{{- .Values.memcached.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "memcached" .Values.memcached.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.databaseHost" -}}
{{- if .Values.mariadb.enabled -}}
{{- include "mailpiler.mariadb.fullname" . -}}
{{- else -}}
{{- required "database.host is required when mariadb.enabled is false" .Values.database.host -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.databaseName" -}}
{{- if .Values.mariadb.enabled -}}
{{- required "mariadb.auth.database is required when mariadb.enabled is true" .Values.mariadb.auth.database -}}
{{- else -}}
{{- required "database.name is required when mariadb.enabled is false" .Values.database.name -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.databaseUser" -}}
{{- if .Values.mariadb.enabled -}}
{{- required "mariadb.auth.username is required when mariadb.enabled is true" .Values.mariadb.auth.username -}}
{{- else -}}
{{- required "database.user is required when mariadb.enabled is false" .Values.database.user -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.databasePasswordKey" -}}
{{- if .Values.mariadb.enabled -}}
{{- .Values.mariadb.auth.secretKeys.userPasswordKey -}}
{{- else -}}
{{- .Values.database.passwordKey -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.manticoreHost" -}}
{{- if .Values.manticoresearch.enabled -}}
{{- include "mailpiler.manticore.serviceName" . -}}
{{- else -}}
{{- required "manticore.host is required when manticoresearch.enabled is false" .Values.manticore.host -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.memcachedHost" -}}
{{- if .Values.memcached.enabled -}}
{{- include "mailpiler.memcached.fullname" . -}}
{{- else -}}
{{- required "memcached.host is required when memcached.enabled is false" .Values.memcached.host -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.configClaimName" -}}
{{- if .Values.persistence.config.existingClaim -}}
{{- .Values.persistence.config.existingClaim -}}
{{- else -}}
{{- printf "%s-config" (include "mailpiler.fullname" .) -}}
{{- end -}}
{{- end }}

{{- define "mailpiler.storeClaimName" -}}
{{- if .Values.persistence.store.existingClaim -}}
{{- .Values.persistence.store.existingClaim -}}
{{- else -}}
{{- printf "%s-store" (include "mailpiler.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
Normalize Mailpiler PATH_PREFIX to avoid broken URLs like /mailpilerlogin.php.

- Empty or "/" => ""
- Ensures a leading "/" and a trailing "/"
*/}}
{{- define "mailpiler.pathPrefix" -}}
{{- $p := .Values.mailpiler.pathPrefix | default "" -}}
{{- if or (not $p) (eq $p "/") -}}
{{- "" -}}
{{- else -}}
{{- if not (hasPrefix "/" $p) -}}
{{- $p = printf "/%s" $p -}}
{{- end -}}
{{- if not (hasSuffix "/" $p) -}}
{{- $p = printf "%s/" $p -}}
{{- end -}}
{{- $p -}}
{{- end -}}
{{- end }}