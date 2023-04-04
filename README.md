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
<li>中国区IPv4/6地址数据：含4个地区分项和7个ISP运营商分项</li>
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

<ul>脚本使用前最好将所在系统更新到最新版本，同时需要在系统中联网安装脚本运行必须使用的支撑软件包：whois，wget</ul>
<ul><li>Ubuntu</li>

```markdown
    sudo apt update
    sudo apt install whois
```
<li>ASUSWRT-Merlin</li>

```markdown
    先安装Entware软件存储库：
    插入格式化为ext4格式的USB盘，键入系统
    自带的amtm命令，在终端菜单窗口中选择安
    装Entware到USB盘。
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

<ul>1.下载本工具的软件压缩包“lzsipcn-[version ID].tgz”（例如：lzispcn-v1.0.0.tgz）。</ul>

<ul>2.将压缩包复制到设备的任意有读写权限的目录。</ul>

<ul>3.在Shell终端中使用解压缩命令在当前目录中将软件解压缩，生成lzispcn-[version ID]目录（例如：lzispcn-v1.0.0），进入其中可看到一个lzispcn目录，此为脚本的工作目录。</ul>
<ul>

```markdown
    tar -xzvf lzispcn-[version ID].tgz
```
</ul>

<ul>4.将lzispcn目录复制或剪切粘贴到设备中希望放置本脚本的位置，则完成本软件的安装。</ul>

<ul>5.在lzispcn目录中，lzispcn.sh为项目工具的可执行脚本，若发现相关的读写运行权限不足，手工赋予755以上即可。</ul>

三、脚本运行命令

<ul>

```markdown
    假设当前正位于lzispcn目录
    Ubuntu | ...
    启动脚本  bash ./lzispcn.sh
    强制解锁  bash ./lzispcn.sh unlock
    ASUSWRT-Merlin | OpenWrt | ...
    启动脚本       ./lzispcn.sh
    强制解锁       ./lzispcn.sh unlock
```
</ul>
<ul>1.通过Shell终端启动脚本后，在操作过程中不要关闭终端窗口，因为这可能会导致程序执行过程意外中断。</ul>
<ul>2.脚本在系统中只能有一个实例进程运行，若上次运行过程中非正常退出，再次运行时需先执行「强制解锁」命令或重启系统，然后再执行「启动脚本」命令。</ul>
<ul>3.创建ISP运营商数据时，程序需要通过互联网访问APNIC进行海量信息查询，这可能要耗费一、两个小时以上时间。此过程中，请不要中断脚本程序的执行过程，并保持耐心。</ul>

四、数据存储位置

<ul>在项目目录lzispcn下，脚本为获取和生成的每类数据设立独立的存储目录。</ul>
<ul>

```markdown
    lzispcn
        apnic
        isp
        cidr
        ipv6
        cidr_ipv6
        tmp
```
</ul>

**卸载**

<ul>直接删除lzispcn目录，脚本软件即可全部清除。</ul>

**运行效果图**

![lzispcn](https://user-images.githubusercontent.com/73221087/229790889-b6f02ff0-9f09-441a-8b83-aa029d3a6458.jpg)
