{
  product: {
    id: '{{AGAMA_PRODUCT_ID}}',
    registrationCode: '{{SCC_REGCODE}}',
  },
  bootloader: {
    stopOnBootMenu: true,
  },
  user: {
    fullName: 'Bernhard M. Wiedemann',
    password: '$6$vYbbuJ9WMriFxGHY$gQ7shLw9ZBsRcPgo6/8KmfDvQ/lCqxW8/WnMoLCoWGdHO6Touush1nhegYfdBbXRpsQuy/FTZZeg7gQL50IbA/',
    hashedPassword: true,
    userName: 'bernhard',
  },
  root: {
    password: '$6$vYbbuJ9WMriFxGHY$gQ7shLw9ZBsRcPgo6/8KmfDvQ/lCqxW8/WnMoLCoWGdHO6Touush1nhegYfdBbXRpsQuy/FTZZeg7gQL50IbA/',
    hashedPassword: true,
    sshPublicKey: 'fake public key to enable sshd and open firewall',
  },
  scripts: {
    pre: [
      {
        name: 'wipefs',
        content: |||
          #!/usr/bin/env bash
          lsblk
          lsblk -n -l -o NAME -d
          for i in `lsblk -n -l -o NAME -d`
              do wipefs -af /dev/$i
              sleep 2
              sync
          done
          lsblk
          udev adm settle
          lsblk
        |||,
      },
    ],
    post: [
      {
        name: 'enable root login',
        chroot: true,
        content: |||
          #!/usr/bin/env bash
          echo 'PermitRootLogin yes' > /etc/ssh/sshd_config.d/root.conf
        |||,
      },
    ],
  },
  "storage": {
    "drives": [
      {
        "partitions": [
          { "search": "*", "delete": true },
          { "generate": "default" }
        ]
      }
    ]
  }
}
