{% from 'nfs/map.jinja' import nfs with context %}

include:
  - nfs.common

nfs.client.pkgs:
  pkg.latest:
    - pkgs: {{ nfs.client_packages | yaml }}

{% for basename, mount in salt['pillar.get']('nfs:imports', {}).items() %}
nfs.client.dir.{{ basename }}:
  file.directory:
    - name: {{ mount.mountpoint }}
<<<<<<< HEAD
    - user: {{ mount.mountpoint_user }}
    - group: {{ mount.mountpoint_group }}
=======
>>>>>>> 8bde0ea9ef50e962d580bd9e03b594e7b91fa2bc
    - makedirs: True

nfs.client.mount.{{ basename }}:
  mount.mounted:
    - name: {{ mount.mountpoint }}
    - device: {{ mount.device }}
    - fstype: nfs
  {% if 'opts' in mount %}
    - opts: {{ mount.get('opts') }}
  {% endif %}
    - require:
      - file: nfs.client.dir.{{ basename }}
{% endfor %}
