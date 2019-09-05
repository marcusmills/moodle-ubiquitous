gocd-agent:
  server: https://192.168.120.20:8154/go

gocd-server:
  users:
    lcarrier: sumK1vbrhQjdahTPpwS61/Bfb7E=

<<<<<<< HEAD
sudoers:
  gocd:
    - '%go ALL=(ALL) NOPASSWD: /usr/bin/salt-call ubiquitous_platform.*'
    - '%go ALL=(ALL) NOPASSWD: /usr/bin/salt-call ubiquitous_platform_maintenance.*'
=======
admin:
  sudoers:
    gocd:
      - '%go ALL=(ALL) NOPASSWD: /usr/bin/salt-call ubiquitous_platform.*'
>>>>>>> 8bde0ea9ef50e962d580bd9e03b594e7b91fa2bc
