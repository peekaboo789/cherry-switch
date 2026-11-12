# CherryPlayer (Nintendo Switch)

一个面向 Emby 媒体服务器的 Switch 客户端：海报墙浏览、剧集追更、播放进度回写。

本项目基于 [SwitchWave](https://github.com/averne/SwitchWave)（averne，GPL-3.0）修改，
沿用其 libmpv / deko3d 播放与渲染底座，新增 Emby 媒体库界面与观看进度同步。

## 当前进度

- [x] 继承 SwitchWave 的本地/USB/SMB/NFS/WebDAV 播放能力
- [ ] Emby 服务器登录与配置持久化
- [ ] 继续观看 / 电影 / 剧集 海报墙
- [ ] 详情页、季集选择、下一集连播
- [ ] 播放进度、已看状态回写 Emby

## 构建

CI 使用 `devkitpro/devkita64` Docker 工具链。依赖源码按固定提交号拉取，不随上游漂移：

```sh
bash tools/fetch-deps.sh
docker build -t cherry-switch-builder .
docker run --rm -v "$PWD":/mnt cherry-switch-builder bash -c '
  cd /mnt
  make configure-ffmpeg && make build-ffmpeg -j$(nproc)
  make configure-uam    && make build-uam
  make configure-mpv    && make build-mpv
  make dist -j$(nproc)
'
```

产物为 `build/CherryPlayer-<version>-<commit>.zip`。

## 安装

把 zip 解压到 SD 卡根目录，形成：

```
sdmc:/switch/CherryPlayer/CherryPlayer.nro
sdmc:/switch/CherryPlayer/mpv.conf
```

通过 Atmosphère 标题菜单或 hbmenu 启动。首次启动会在同目录生成
`CherryPlayer.conf`（应用设置）以及 mpv 的 `watch_later` 等运行数据。

## 许可

GPL-3.0，与原项目一致。源代码随二进制一同提供。
