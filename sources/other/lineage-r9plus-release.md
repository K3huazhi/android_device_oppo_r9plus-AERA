# LineageOS 22.1 R9Plus release metadata

## Release

- Repository: <https://github.com/BlueyfishReleases/R9Plus>
- Tag: `lineage-22.1-20260717-UNOFFICIAL-R9Plus`
- Published: 2026-07-17 (asset timestamps)

## Assets

| 文件 | 大小 | 用途 |
|---|---:|---|
| `boot.img` | 15,803,644 | kernel / ramdisk / header 参考 |
| `recovery.img` | 23,981,312 | 4.9 recovery kernel + FDT + OPPO 证书基线 |
| `lineage-22.1-20260717-UNOFFICIAL-R9Plus.zip` | 1,123,772,044 | 完整 ROM（本项目未下载） |

## SHA-256

```text
boot-lineage22.1.img
a1806ecd6d8b3aff22e35d47a5d276408b937fa192bf44e44d1475491b392f28

recovery-lineage22.1.img
da5312db0f2c328f0d6dcab6e3d20ed39127fdea9de08762a3cda921b7db03d4
```

## 提取产物

```text
recovery kernel blob (Image.gz-dtb)
10,561,222 bytes
7c9ac2f052edf435ee83e5a4be9a27529b7de012cca8da8dea21713f54376a2a

Image (gunzipped)
29,163,544 bytes
a8fc2faf6ef5476f334fbbced65f21f6cd10777e9c5fdc8cdd29c61336fe98e6

FDT
242,901 bytes
113a8b7159a943b3f37915b9a98a76f5a3f8d84d92f8cb2187f2af20b181aeaf

OPPO recovery certificate
1,280 bytes
0bac771b663ebb077b87f2ae1a588a3e5f89192a10dea1bee93c3b252af7eab5
```

## 备注

- 该 release 说明要求使用 TWRP 3.7.1_12-Alpha4 刷入；
- 设备树 fingerprint 为 `OPPO/R9PlusmA/R9PlusA`，与本机一致；
- 该镜像不是从本机分区提取的，因此不能替代本机原厂 boot/recovery 备份。
