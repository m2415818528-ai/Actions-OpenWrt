#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# 1. 强改默认登录 IP 为 192.168.5.1
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 2. 强改默认登录密码为 root (注入 root 对应的 MD5/SHA 影子密文)
sed -i 's/root::0:0:99999:7:::/root:$1$wDL7ZzS8$Yw7r5mUvpxoU\/e0r.vI9P.:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# 3. 魔改无线驱动源码，锁死默认 Wi-Fi 名字与密码（包含2.4G和5G）
sed -i 's/SSID="ImmortalWrt"/SSID="88888888_2.4G"/g' package/mtk/applications/mtradio/files/lib/wifi/mtk.sh
sed -i 's/SSID="ImmortalWrt-5G"/SSID="88888888_5G"/g' package/mtk/applications/mtradio/files/lib/wifi/mtk.sh
sed -i 's/encryption="none"/encryption="psk2"/g' package/mtk/applications/mtradio/files/lib/wifi/mtk.sh
sed -i 's/key=""/key="86680352"/g' package/mtk/applications/mtradio/files/lib/wifi/mtk.sh

# 4. 将物理 LAN2 端口魔改为独立的 WAN2 移动上网端口，并设定电信 WAN 与移动 WAN2 的专属跃点与权重
# a. 从默认的局域网桥接（LAN）中剥离 lan2
sed -i 's/lan1 lan2 lan3/lan1 lan3/g' package/base-files/files/bin/config_generate
# b. 写入开机自动化脚本：锁定电信 WAN 为 Metric 10、权重 20；建立移动 WAN2 为 Metric 20、绑定物理 LAN2 口
cat <<EOF >> package/base-files/files/lib/functions/uci-defaults.sh
uci -q batch <<EEOM
set network.wan.metric='10'
set network.wan.weight='20'
set network.wan2=interface
set network.wan2.proto='dhcp'
set network.wan2.device='lan2'
set network.wan2.metric='20'
commit network
EEOM
EOF
