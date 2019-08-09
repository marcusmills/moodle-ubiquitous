# Ports:
# * 2000 RPC mountd
# * 2001 statd listen
# * 2002 statd outgoing
# * 2003 quotad
# * 2004 NLM TCP/UDP
# * 2005 NFS callback
# * 7790 drbd block replication

drbd:
  drbd.d:
    global_common.conf: |
      global {
        usage-count no;
      }

      common {
        handlers {
          fence-peer "/usr/lib/drbd/crm-fence-peer.sh";
          after-resync-target "/usr/lib/drbd/crm-unfence-peer.sh";
          split-brain "/usr/lib/drbd/notify-split-brain.sh root";
          pri-lost-after-sb "/usr/lib/drbd/notify-pri-lost-after-sb.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
        }
        startup {
          wfc-timeout 0;
        }
        disk {
          md-flushes yes;
          disk-flushes yes;
          c-plan-ahead 1;
          c-min-rate 100M;
          c-fill-target 20M;
          c-max-rate 4G;
        }
        net {
          after-sb-0pri discard-younger-primary;
          after-sb-1pri discard-secondary;
          after-sb-2pri call-pri-lost-after-sb;
          protocol C;
          tcp-cork yes;
          max-buffers 20000;
          max-epoch-size 20000;
          sndbuf-size 0;
          rcvbuf-size 0;
        }
      }
    export-data.res: |
      resource export-data {
        protocol C;
        disk {
          on-io-error detach;
        }
        on storage0 {
          address 192.168.120.70:7790;
          device /dev/drbd0;
          disk /dev/storage0-exports/data;
          meta-disk internal;
        }
        on storage1 {
          address 192.168.120.71:7790;
          device /dev/drbd0;
          disk /dev/storage1-exports/data;
          meta-disk internal;
        }
      }

pacemaker:
  user:
    # "P4$$word"; hashed with openssl passwd -1
    password: '$1$URnGoZlt$sIaFZZgRqBzNUZjWhQOCu1'
  cluster_setup:
    - pcsclustername: ubiquitous
    - nodes:
      - storage0.ubiquitous
      - storage1.ubiquitous
  properties:
    stonith-enabled: 'false'
    no-quorum-policy: 'ignore'
  resources: {}

# Only allow local services to bind
tcpwrappers:
  hosts.deny:
    nfs:
      - 'rpcbind mountd nfsd statd lockd rquotad : ALL'
  hosts.allow:
    nfs:
      - 'rpcbind mountd nfsd statd lockd rquotad : 127.0.0.1 192.168.120.0/24'

nfs:
  common:
    default:
      NEED_IDMAPD: 'yes'
      STATDOPTS: --port 2001 --outgoing-port 2002
  kernel_server:
    default:
      RPCMOUNTDOPTS: --manage-gids --port 2000
  modprobe:
    lockd:
      - nlm_udpport=2004 nlm_tcpport=2004
    nfs:
      - callback_tcpport=2005
  sysctl:
    parameters:
      fs.nfs.nlm_tcpport: 2004
      fs.nfs.nlm_udpport: 2004
