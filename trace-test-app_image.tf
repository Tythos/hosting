resource "docker_image" "trace_test_app_image" {
  name = "trace-test-app:latest"
  build {
    context = abspath("${path.root}/trace-test-app")
    dockerfile = "Dockerfile"
  }
} 