#cloud-config
package_update: true
package_upgrade: true

packages:
  - screen

write_files:
  - path: /root/mount_persistent_volume.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      mkdir -p /mnt/${PERSISTENT_VOLUME_NAME}
      mount /dev/disk/by-id/scsi-0DO_Volume_${PERSISTENT_VOLUME_NAME} /mnt/${PERSISTENT_VOLUME_NAME}
      echo "/dev/disk/by-id/scsi-0DO_Volume_${PERSISTENT_VOLUME_NAME} /mnt/${PERSISTENT_VOLUME_NAME} ext4 defaults,nofail 0 2" >> /etc/fstab

runcmd:
  - ls -ahl /root
  - /root/mount_persistent_volume.sh

final_message: "Server setup complete!"
