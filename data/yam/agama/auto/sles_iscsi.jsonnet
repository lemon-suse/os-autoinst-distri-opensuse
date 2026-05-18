{
   bootloader: {
      stopOnBootMenu: true
   },
   iscsi: {
      initiator: 'iqn.1996-04.de.suse:01:972154f2547d',
      targets: [
         {
            address: '{{WORKER_IP}}',
            interface: 'default',
            name: '{{ISCSI_NAME}}',
            port: 3260,
            startup: 'automatic'
         }
      ]
   },
   product: {
      id: 'SLES',
      registrationCode: '{{SCC_REGCODE}}'
   },
   questions: {
      answers: [
         {
            answer: 'decrypt',
            class: 'storage.luks_activation',
            password: '{{PASSWORD}}'
         }
      ],
      "policy": "auto"
   },
   root: {
      hashedPassword: true,
      password: '$6$vYbbuJ9WMriFxGHY$gQ7shLw9ZBsRcPgo6/8KmfDvQ/lCqxW8/WnMoLCoWGdHO6Touush1nhegYfdBbXRpsQuy/FTZZeg7gQL50IbA/',
      sshPublicKey: 'fake public key to enable sshd and open firewall'
   },
   storage: {
      boot: {
         configure: true
      },
      drives: [
         {
            partitions: [
               {
                  delete: true,
                  search: '*'
               },
               {
                  filesystem: {
                     path: '/home',
                     type: 'xfs'
                  }
               }
            ],
            search: '/dev/sda'
         },
         {
            partitions: [
               {
                  delete: true,
                  search: '*'
               },
               {
                  filesystem: {
                     path: '/',
                     type: 'btrfs'
                  },
                  size: '20 GiB'
               },
               {
                  filesystem: {
                     path: 'swap'
                  },
                  size: '1 GiB'
               }
            ],
            search: '/dev/vda'
         }
      ]
   },
   "user": {
      fullName: 'Bernhard M. Wiedemann',
      hashedPassword: true,
      password: '$6$vYbbuJ9WMriFxGHY$gQ7shLw9ZBsRcPgo6/8KmfDvQ/lCqxW8/WnMoLCoWGdHO6Touush1nhegYfdBbXRpsQuy/FTZZeg7gQL50IbA/',
      userName: 'bernhard'
   }
}
