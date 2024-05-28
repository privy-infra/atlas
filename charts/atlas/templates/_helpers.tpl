{{/*
Expand the name of the chart.
*/}}
{{- define "atlas.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "atlas.fullname" -}}
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
{{- define "atlas.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "atlas.labels" -}}
helm.sh/chart: {{ include "atlas.chart" . }}
{{ include "atlas.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "atlas.selectorLabels" -}}
app.kubernetes.io/name: {{ include "atlas.fullname" . }}
app.kubernetes.io/instance: {{ include "atlas.fullname" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "atlas.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "atlas.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define secret
*/}}
{{- define "atlas.secret" }}
{{- if .Values.secrets.configs.enabled }}
  - secretRef:
      name: "{{ include "atlas.fullname" . }}-configs"
{{- end }}
{{- if .Values.secrets.creds.enabled }}
  - secretRef:
      name: "{{ include "atlas.fullname" . }}-creds"
{{- end }}
{{- end }}

{{/*
Liveness and Readiness
*/}}
{{- define "atlas.liveness" -}}
{{- if eq .Values.liveness.type "httpGet" }}
livenessProbe:
  initialDelaySeconds: {{ .Values.liveness.initialDelay }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  successThreshold: {{ .Values.liveness.successThreshold }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
  httpGet:
    path: {{ .Values.liveness.path }}
    port: {{ .Values.liveness.port }}
readinessProbe:
  initialDelaySeconds: {{ .Values.liveness.initialDelay }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  successThreshold: {{ .Values.liveness.successThreshold }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
  httpGet:
    path: {{ .Values.liveness.path }}
    port: {{ .Values.liveness.port }}
{{- else if eq .Values.liveness.type "exec" }}
livenessProbe:
  initialDelaySeconds: {{ .Values.liveness.initialDelay }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  successThreshold: {{ .Values.liveness.successThreshold }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
  exec:
    command:
      - grpc_health_probe
      - -addr=:{{ .Values.liveness.port }}
readinessProbe:
  initialDelaySeconds: {{ .Values.liveness.initialDelay }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  successThreshold: {{ .Values.liveness.successThreshold }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
  exec:
    command:
      - grpc_health_probe
      - -addr=:{{ .Values.liveness.port }}
{{- else if eq .Values.liveness.type "tcpSocket" }}
livenessProbe:
  initialDelaySeconds: {{ .Values.liveness.initialDelay }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  successThreshold: {{ .Values.liveness.successThreshold }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
  tcpSocket:
    port: {{ .Values.liveness.port }}
readinessProbe:
  initialDelaySeconds: {{ .Values.liveness.initialDelay }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  successThreshold: {{ .Values.liveness.successThreshold }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
  tcpSocket:
    port: {{ .Values.liveness.port }}
{{- end }}
{{- end }}

{{/*
Service protocols
*/}}
{{- define "atlas.serviceProtocol" -}}
{{- if .Values.service.http.enabled }}
- name: http
  port: {{ .Values.service.http.port }}
  targetPort: {{ .Values.service.http.targetPort }}
  protocol: TCP
{{- end }}
{{- if .Values.service.grpc.enabled }}
- name: grpc
  port: {{ .Values.service.grpc.port }}
  targetPort: {{ .Values.service.grpc.targetPort }}
  protocol: TCP
{{- end }}
{{- end }}


{{/*
Custom image
*/}}
{{- define "atlas.customImage" -}}
{{- if .Values.migrations.customImage.enabled }}
image: "{{ .Values.migrations.customImage.image.repository }}:{{ .Values.migrations.customImage.image.tag }}"
{{- else }}
image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
{{- end }}
{{- end }}