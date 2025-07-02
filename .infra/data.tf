data "template_file" "user_data_yaml" {
  template = file("${path.module}/user_data.yaml.tpl")

  vars = {
    PERSISTENT_VOLUME_NAME = "${digitalocean_volume.dovolume.name}"
  }
}
