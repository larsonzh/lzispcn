# lzispcn
IP address data acquisition tool for ISP network operators in China

中国区 ISP 网络运营商 IP 地址数据获取工具

**v1.0.2**

工具采用 Shell 脚本编写，参考并借鉴 clangcn（ https://github.com/clangcn/everyday-update-cn-isp-ip.git ）项目代码和思路，对信息检索和数据写入过程做了些优化。在提供 IPv4 数据获取的同时，增加 IPv6 数据获取功能，以及基于 CIDR 网段聚合算法的 IPv4/6 CIDR 地址数据的生成功能。

本产品同时是本人后续的 lzispro 多进程并行处理项目（ https://github.com/larsonzh/lzispro.git ）的单进程基础版本。

脚本在 Linux 环境下使用，运行平台包括：Ubuntu，Deepin，ASUSWRT-Merlin，OpenWrt，......

**功能**
<ul><li>从 APNIC 下载最新 IP 信息数据。</li>
<li>从 APINC IP 信息数据中抽取出最新、最完整的中国大陆及港澳台地区所有 IPv4/6 原始地址数据。</li>
<li>向 APNIC 逐条查询中国大陆地区的 IPv4/6 原始地址数据，得到归属信息，生成能够包含中国大陆地区所有 IPv4/6 地址的 ISP 运营商分项数据。</li>
<li>通过 CIDR 聚合算法生成压缩过的 IPv4/6 CIDR 格式地址数据。</li>
<li>中国区 IPv4/6 地址数据：含 4 个地区分项和 7 个 ISP 运营商分项</li>
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

<ul>脚本使用前最好将所在系统升级到最新版本，同时要在系统中联网安装脚本执行时必须依赖的软件模块：whois，wget</ul>
<ul><li>Ubuntu | Deepin</li>

```markdown
  sudo apt update
  sudo apt install whois
```
<li>ASUSWRT-Merlin</li>

```markdown
  先安装 Entware 软件存储库：
  插入格式化为 ext4 格式的 USB 盘，键入
  系统自带的 amtm 命令，在终端菜单窗口中
  选择安装 Entware 到 USB 盘。
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

<ul>其他 Linux 平台系统依此类推。</ul>

二、安装项目脚本

<ul>1.下载本工具的软件压缩包 lzsipcn-[version ID].tgz（例如：lzispcn-v1.0.2.tgz）。</ul>

<ul>2.将压缩包复制到设备的任意有读写权限的目录。</ul>

<ul>3.在 Shell 终端中使用解压缩命令在当前目录中解压缩，生成 lzispcn-[version ID] 目录（例如：lzispcn-v1.0.2），其中包含一个 lzispcn 目录，是脚本所在目录。</ul>
<ul>

```markdown
  tar -xzvf lzispcn-[version ID].tgz
```
</ul>

<ul>4.将 lzispcn 目录整体复制粘贴到设备中希望放置本工具的位置。</ul>

<ul>5.在 lzispcn 目录中，lzispcn.sh 为本工具的可执行脚本，若读写运行权限不足，手工赋予 755 以上即可。</ul>

三、脚本运行命令

<ul>

```markdown
  假设当前位于 lzispcn 目录
  Ubuntu | Deepin | ...
  启动脚本    bash ./lzispcn.sh
  强制解锁    bash ./lzispcn.sh unlock
  ASUSWRT-Merlin | OpenWrt | ...
  启动脚本         ./lzispcn.sh
  强制解锁         ./lzispcn.sh unlock
```
</ul>
<ul>1.通过 Shell 终端启动脚本后，在操作过程中不要关闭终端窗口，这可能导致程序执行过程意外中断。</ul>
<ul>2.脚本在系统中只能有一个实例进程运行。若上次运行过程中非正常退出，再次运行如果提示有另一个实例正在运行，在确认系统中本脚本确实没有实例正在运行后，可以执行「强制解锁」命令或重启系统，然后再执行「启动脚本」命令。</ul>
<ul>3.进行 ISP 运营商分项数据归类时，脚本需要通过互联网访问 APNIC 做海量信息查询，可能要耗费一、两个小时以上时间。切勿中断此执行过程，并耐心等候。</ul>

四、目录结构

<ul>在项目目录 lzispcn 下，脚本为获取和生成的每类文本形式的数据设立独立的存储目录，在程序执行完成后，从这些目录中可获取所需数据。</ul>
<ul>

```markdown
  [lzispcn]
    [apnic]      -- APNIC 的 IP 信息数据
    [isp]        -- IPv4 原始地址数据
    [cidr]       -- IPv4 CIDR 地址数据
    [ipv6]       -- IPv6 原始地址数据
    [cidr_ipv6]  -- IPv6 CIDR 地址数据
    [tmp]        -- 运行中的临时数据
    lzispcn.sh   -- 主程序
```
</ul>

五、参数配置

<ul>lzispcn.sh 脚本是本工具的主程序，可用文本编辑工具打开查看、修改其中的内容。</ul>
    
<ul>该代码的前部分有供用户修改的参数变量，可根据内部注释修改。</ul>
<ul>

```markdown
  项目目录
  目标数据文件名
  需要获取哪类数据
  信息查询失败后的重试次数
  是否显示进度条
  系统日志文件定义
  ......
```
</ul>

**卸载**

<ul>直接删除 lzispcn 目录。</ul>

**运行效果图**
<ul>华硕 GT-AX6000 梅林固件路由器，四核心 ARM CPU，主频 2.0 MHz。</ul>

![lzispcn](https://user-images.githubusercontent.com/73221087/230068067-f8b25a75-712d-43c2-97fe-f8911873aa06.jpg)
