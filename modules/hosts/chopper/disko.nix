{
  flake.diskoConfigurations.chopper = {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-WD_Red_SN700_1000GB_25514L802026";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "2G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "fmask=0077"
                    "dmask=0077"
                  ];
                };
              };
              swap = {
                size = "16G";
                content = {
                  type = "swap";
                  discardPolicy = "both";
                };
              };
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
          };
        };
        hdd1 = {
          type = "disk";
          device = "ata-WDC_WD10EZEX-22MFCA0_WD-WCC6Y0ZKV7S1";
          content = {
            type = "gpt";
            partitions = {
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "hddpool";
                };
              };
            };
          };
        };
      };
      zpool = {
        rpool = {
          type = "zpool";
          options = {
            ashift = "12";
          };
          # Root filesystem / pool-wide default properties
          rootFsOptions = {
            compression = "lz4";
            acltype = "posixacl";
            xattr = "sa";
            normalization = "formD";
            mountpoint = "none";
            atime = "off"; # Disables atime globally for speed and SSD longevity
            encryption = "aes-256-ccm";
            keyformat = "raw";
            keylocation = "file:///run/keys/zfs.key";
          };
          datasets = {
            # 100GB dummy safety space reservation
            reserved = {
              type = "zfs_fs";
              options = {
                reservation = "100G";
                mountpoint = "none";
              };
            };
            # System datasets
            root = {
              type = "zfs_fs";
              mountpoint = "/";
              options.mountpoint = "legacy";
            };
            nix = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options.mountpoint = "legacy";
            };
            # Optimized PostgreSQL dataset
            postgres = {
              type = "zfs_fs";
              mountpoint = "/var/lib/postgresql";
              options = {
                mountpoint = "legacy";
                recordsize = "8k";
                logbias = "throughput";
              };
            };
            # Immich App Directory (thumbs, profiles, database backups)
            immich-app = {
              type = "zfs_fs";
              mountpoint = "/var/lib/immich";
              options.mountpoint = "legacy";
            };
            # Data
            data = {
              type = "zfs_fs";
              options.mountpoint = "none";
            };
            "data/nextcloud" = {
              type = "zfs_fs";
              mountpoint = "/var/lib/nextcloud";
              options.mountpoint = "legacy";
            };
            "data/zola" = {
              type = "zfs_fs";
              mountpoint = "/home/bene/blog";
              options.mountpoint = "legacy";
            };
          };
        };
        hddpool = {
          type = "zpool";
          options.ashift = "12";
          # Root filesystem / pool-wide default properties
          rootFsOptions = {
            compression = "lz4";
            acltype = "posixacl";
            xattr = "sa";
            normalization = "formD";
            mountpoint = "none";
            atime = "off"; # Disables atime globally for speed and longevity
          };
          datasets = {
            # 100GB dummy safety space reservation
            reserved = {
              type = "zfs_fs";
              options = {
                reservation = "100G";
                mountpoint = "none";
              };
            };
            data = {
              type = "zfs_fs";
              options = {
                mountpoint = "none";
                encryption = "aes-256-ccm";
                keyformat = "raw";
                keylocation = "file:///run/keys/zfs.key";
              };
            };
            "data/smb" = {
              type = "zfs_fs";
              mountpoint = "/public";
              options.mountpoint = "legacy";
            };
            "data/smb/archive" = {
              type = "zfs_fs";
              mountpoint = "/public/archive";
              options.compression = "zstd";
              options.mountpoint = "legacy";
            };
            # Immich Bulk Storage (Original Photos & Videos)
            "data/immich-media" = {
              type = "zfs_fs";
              mountpoint = "/var/lib/immich-media";
              options = {
                mountpoint = "legacy";
                recordsize = "1M"; # Tuned for large media retrieval
              };
            };
          };
        };
      };
    };
  };
}
