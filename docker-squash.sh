#!/bin/bash
set -e
set -o pipefail
source_tag="$1"
IFS=$'\n'
source_image_id="$(docker inspect --format "{{ .Id }}" "$source_tag")"
# https://docs.docker.com/engine/reference/commandline/import/
# The --change option will apply Dockerfile instructions to the image that is created. Supported Dockerfile instructions: CMD|ENTRYPOINT|ENV|EXPOSE|ONBUILD|USER|VOLUME|WORKDIR
change_arg=( $(docker inspect --format="{{if .Config.Cmd}}-c
CMD {{json .Config.Cmd}}
{{end}}{{if .Config.Entrypoint}}-c
ENTRYPOINT {{json .Config.Entrypoint}}
{{end}}{{if .Config.Env}}{{range .Config.Env}}-c
ENV {{ . }}
{{end}}{{end}}{{if .Config.ExposedPorts}}-c
EXPOSE{{ range \$k, \$v := .Config.ExposedPorts }} {{ \$k }}{{end}}
{{end}}{{if .Config.OnBuild}}{{range .Config.OnBuild}}-c
ONBUILD {{ . }}
{{end}}{{end}}{{if .Config.User}}-c
USER {{ .Config.User }}
{{end}}{{if .Config.Volumes}}{{range .Config.Volumes}}-c
VOLUME {{ . }}
{{end}}{{end}}{{if .Config.WorkingDir}}-c
WORKDIR {{ .Config.WorkingDir }}
{{end}}" "$source_tag") )
tmp_container="$(docker create "$source_tag")"
trap "docker rm '$tmp_container'" EXIT
echo "Squashing ${source_tag} ($source_image_id) and overwriting the same tag. You will eventually have to prune the old dangling image." >&2
docker export "$tmp_container" | docker import ${change_arg[@]} -m "Squashed from $source_image_id" - "${source_tag}"
echo "$source_image_id"
