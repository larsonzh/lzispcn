# lzispcn
IP address data acquisition tool for ISP network operators in China

中国地区ISP网络运营商IP地址数据获取工具

**v1.0.0**

**用途**

<ul><li>从APNIC下载当前最新的IP信息数据。</li>

<li>从APINC IP信息数据中抽取出当前最新的中国大陆及港澳台地区IPv4/6原始地址数据。</li>

<li>向APNIC逐条查询中国大陆地区的IPv4/6原始地址数据，得到归属信息，生成中国电信、中国联通/网通、中国移动、中国铁通、中国教育网、长城宽带/鹏博士、中国其他ISP的能够包含中国大陆所有IPv4/6地址的ISP运营商地址数据。</li>

<li>通过CIDR聚合算法生成压缩过的IPv4/6 CIDR格式地址数据。</li></ul>

![lzispcn](https://user-images.githubusercontent.com/73221087/229587948-7758d3a1-68bd-4cf0-b582-a78a5e8a07e5.jpg)
