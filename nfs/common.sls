{% from 'nfs/map.jinja' import nfs with context %}

nfs.common.pkgs:
  pkg.latest:
    - pkgs: {{ nfs.common_packages | yaml }}

nfs.common.default.common:
  file.managed:
    - name: /etc/default/nfs-common
    - source: salt://nfs/default/default.jinja
    - template: jinja
    - context:
      values: {{ nfs.common.default | yaml }}
    - user: root
    - group: root
    - mode: 0644
    - require:
      - pkg: nfs.common.pkgs
