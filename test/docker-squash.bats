#!/usr/bin/env bats

@test "shrinking preserves attributes" {
  docker build -t docker-squash-test-1 -f Dockerfile.1  .

  prev_size="$(docker image inspect --format '{{.Size}}' docker-squash-test-1)"
  prev_attributes="$(docker image inspect --format '{{.Config.Entrypoint}}
  {{.Config.Env}}
  {{.Config.ExposedPorts}}
  {{.Config.OnBuild}}
  {{.Config.User}}
  {{.Config.Volumes}}
  {{.Config.WorkingDir}}' docker-squash-test-1)"

  old_image="$(bash -x ../docker-squash.sh docker-squash-test-1)"

  new_size="$(docker image inspect --format '{{.Size}}' docker-squash-test-1)"
  new_attributes="$(docker image inspect --format '{{.Config.Entrypoint}}
  {{.Config.Env}}
  {{.Config.ExposedPorts}}
  {{.Config.OnBuild}}
  {{.Config.User}}
  {{.Config.Volumes}}
  {{.Config.WorkingDir}}' docker-squash-test-1)"

  [ $new_size -lt $(($prev_size - 10000000)) ]
  diff <(echo "$prev_attributes") <(echo "$new_attributes")

  # cleanup
  docker rmi "$old_image" docker-squash-test-1
}
