# lzispcn
IP address data acquisition tool for ISP network operators in China

中国区ISP网络运营商IP地址数据获取工具

**v1.0.0**

工具采用Shell脚本编写，参考并借鉴clangcn（ https://github.com/clangcn/everyday-update-cn-isp-ip.git ）项目代码和思路，对信息检索和数据写入过程做了些优化。在提供IPv4数据获取的同时，增加IPv6数据获取功能，以及基于CIDR网段聚合算法的IPv4/6 CIDR地址数据的生成功能。

脚本在Linux环境下使用，可运行平台包括：Ubuntu，ASUSWRT-Merlin，OpenWrt，......

**功能**
<ul><li>从APNIC下载当前最新的IP信息数据。</li>
<li>从APINC IP信息数据中抽取出当前最新、最完整的中国大陆及港澳台地区所有IPv4/6原始地址数据。</li>
<li>向APNIC逐条查询中国大陆地区的IPv4/6原始地址数据，得到归属信息，生成能够包含中国大陆地区所有IPv4/6地址的ISP运营商分项数据。</li>
<li>通过CIDR聚合算法生成压缩过的IPv4/6 CIDR格式地址数据。</li>
<li>获取的中国IPv4/6地址数据包括4个地区和7个ISP运营商分项：</li>
    <ul><li>大陆地区</li>
        <ul><li>中国电信</li>
        <li>中国联通/网通</li>
        <li>中国移动</li>
        <li>中国铁通</li>
        <li>中国教育网</li>
        <li>长城宽带/鹏博士</li>
        <li>中国大陆其他</li></ul>
    <li>香港地区</li>
    <li>澳门地区</li>
    <li>台湾地区</li></ul></ul>

**安装及运行**

一、安装支撑软件

脚本使用前需在系统中联网安装必要的支撑软件包：whois，wget
<ul><li>Ubuntu</li>

```markdown
    sudo apt update
    sudo apt install whois
```
<li>ASUSWRT-Merlin</li>

```markdown
    先安装Entware软件存储库（插入格式化为ext4格式的USB盘，键入系统自带的amtm命令，在终端菜单窗口中选择安装Entware到USB盘）。
    opkg update
    opkg install whois
```
<li>OpenWrt</li>

```markdown
    opkg update
    opkg install whois
    opkg install wget-ssl
```
</ul>

二、安装项目脚本

1.下载本工具的软件压缩包“lzsipcn-[version ID].tgz”（例如：lzispcn-v1.0.0.tgz）。

2.将压缩包复制到设备的任意有读写权限的目录。

3.在SHELL终端中使用解压缩命令在当前目录中将软件解压缩，生成lzispcn-[version ID]目录（例如：lzispcn-v1.0.0），进入其中可看到一个lzispcn目录，此为脚本的工作目录。<ul>
```markdown
    tar -xzvf lzispcn-[version ID].tgz
```
</ul>

4.将lzispcn目录复制或剪切粘贴到设备中希望放置本脚本的位置，则完成本软件的安装。

5.在lzispcn目录中，lzispcn.sh为项目工具的可执行脚本，若发现相关的读写运行权限不足，手工赋予755以上即可。

三、运行脚本

**实际效果图**

![lzispcn](https://user-images.githubusercontent.com/73221087/229751079-8ab97633-03d2-43e0-bc2c-810a2aec95c6.jpg)


