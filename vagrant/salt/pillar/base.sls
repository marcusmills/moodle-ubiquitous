admin:
  name: ubuntu
  password: gibberish
  groups: # Primary group is always named after user name
    - sudo
  home: /home/ubuntu

iptables:
  apply: True

systemd:
  apply: True