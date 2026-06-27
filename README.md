# Shadowrocket Rules

适用于 Shadowrocket 的分流规则配置。

## 文件说明

- `shadowrocket-cn-direct-overseas-proxy.conf`
  - 主配置。
  - 国内域名和中国大陆 IP 直连。
  - 国外网站走代理。
  - YouTube、Netflix、OpenAI、GitHub、Telegram、X、TikTok、Discord、Reddit、Streaming、Spotify、Twitch、Gaming、Microsoft、Amazon、Cloudflare 等服务单独分组。
  - 每个分组的节点由你在 Shadowrocket 里手动选择。

- `shadowrocket-cn-direct-overseas-proxy-simple.conf`
  - 简洁配置。
  - 没有单独服务分流策略组。
  - 国内域名和中国大陆 IP 直连。
  - 其他所有流量走 Shadowrocket 当前选中的代理节点。

- `shadowrocket-recovery-direct.conf`
  - 恢复配置。
  - 所有流量直连。
  - 当主配置导入错误、代理不可用、或网络异常时，用它临时恢复联网。

- `youtube-adblock-basic.sgmodule`
  - YouTube 基础去广告模块。
  - 不需要开启 MitM 证书。
  - 主要屏蔽常见广告、统计、追踪域名。
  - 对 YouTube App 的效果不保证，YouTube 规则经常变化。

## 导入链接

主配置：

```text
https://raw.githubusercontent.com/lu41555/shadowrocket-rules/main/shadowrocket-cn-direct-overseas-proxy.conf
```

简洁配置：

```text
https://raw.githubusercontent.com/lu41555/shadowrocket-rules/main/shadowrocket-cn-direct-overseas-proxy-simple.conf
```

恢复配置：

```text
https://raw.githubusercontent.com/lu41555/shadowrocket-rules/main/shadowrocket-recovery-direct.conf
```

YouTube 基础去广告模块：

```text
https://raw.githubusercontent.com/lu41555/shadowrocket-rules/main/youtube-adblock-basic.sgmodule
```

## 手机端导入方法

1. 打开 Shadowrocket。
2. 点击右上角 `+`。
3. 类型选择 `Subscribe` 或 `Config`。
4. URL 填入上面的主配置 Raw 链接。
5. 保存后进入配置页面，选择这个配置。
6. 全局路由选择 `配置` 或 `Config`，不要选择全局代理。

## 节点使用方式

先把你的代理节点正常导入 Shadowrocket。

导入主配置后，在 Shadowrocket 的策略组里分别选择节点：

- `Japan`：选择你的日本节点。
- `Singapore`：选择你的新加坡节点。
- `UnitedStates`：选择你的美国节点。
- `HongKong`：选择你的香港节点。
- `Taiwan`：选择你的台湾节点。
- `Korea`：选择你的韩国节点。
- `UnitedKingdom`：选择你的英国节点。
- `Germany`：选择你的德国节点。
- `France`：选择你的法国节点。
- `Canada`：选择你的加拿大节点。
- `Australia`：选择你的澳大利亚节点。
- `Netherlands`：选择你的荷兰节点。
- `India`：选择你的印度节点。
- `YouTube`：选择适合 YouTube 的节点。
- `Netflix`：选择支持奈飞解锁的节点。
- `OpenAI`：选择适合 ChatGPT/OpenAI 的节点。
- `Telegram`：选择适合 Telegram 的节点。
- `X`：选择适合 X/Twitter 的节点。
- `TikTok`：选择适合 TikTok 的节点。
- `GitHub`：选择适合 GitHub 的节点。
- `Streaming`：选择适合 Disney+、Hulu、Max、Prime Video 等流媒体的节点。
- `Gaming`：选择适合 Steam、Epic、暴雪、Riot 等游戏平台的节点。

建议用法：

- 先进入国家/地区分组，例如 `Japan`、`Singapore`、`UnitedStates`、`HongKong`、`Australia`，分别选择对应地区节点。
- 再进入 `Netflix`、`YouTube`、`OpenAI` 等服务分组，在国家/地区分组和 `PROXY` 之间选择。

例如：

- 主代理选新加坡。
- `Japan` 分组里选日本节点。
- `UnitedStates` 分组里选美国节点。
- `Australia` 分组里选澳大利亚节点。
- `Netflix` 分组里选 `Japan`。
- 这样 Netflix 会走日本节点，而不是主代理的新加坡节点。

其他没有单独分组的国外网站，会走 Shadowrocket 当前默认的 `PROXY` 节点。

如果你不想给不同网站分别选节点，使用简洁配置即可。

如果某个国家/地区分组里没有显示节点，说明节点名称没有匹配到关键词。此时需要把节点显示名称写进配置的对应策略组，例如：

```ini
Japan = select,日本节点名称
Singapore = select,新加坡节点名称
UnitedStates = select,美国节点名称
HongKong = select,香港节点名称
Australia = select,澳大利亚节点名称
Netflix = select,Japan,Singapore,UnitedStates,HongKong,Australia,PROXY
```

节点名称必须和 Shadowrocket 里显示的名字一致。

## 分流逻辑

规则顺序如下：

1. 指定国外服务分组优先匹配。
2. 局域网、本机地址直连。
3. 常见国内域名直连。
4. Apple 中国大陆常用服务直连。
5. 中国大陆 IP 使用 `GEOIP,CN,DIRECT` 直连。
6. 其他所有流量使用 `FINAL,PROXY` 走代理。

## 出问题时怎么恢复

如果导入主配置后无法联网：

1. 在 Shadowrocket 里临时关闭代理。
2. 导入恢复配置：

```text
https://raw.githubusercontent.com/lu41555/shadowrocket-rules/main/shadowrocket-recovery-direct.conf
```

3. 启用恢复配置后，所有流量会直连。
4. 确认节点可用后，再切回主配置。

## YouTube 去广告模块

导入链接：

```text
https://raw.githubusercontent.com/lu41555/shadowrocket-rules/main/youtube-adblock-basic.sgmodule
```

使用方法：

1. 打开 Shadowrocket。
2. 进入模块/Modules。
3. 添加模块订阅，填入上面的 Raw 链接。
4. 启用 `YouTube AdBlock Basic`。
5. 重新打开 YouTube App 或刷新网页。

注意：

- 这是基础版，不强制开启 MitM。
- YouTube App 去广告不一定稳定。
- 如果出现视频无法播放、评论加载异常、登录异常，先关闭此模块测试。
- 不建议一开始就开启多个去广告模块，容易互相冲突。

## 注意事项

- 本配置不包含任何代理节点信息。
- 你需要自己先导入节点。
- 每个策略组都可以在 Shadowrocket 里手动选择节点。
- 如果某个服务打不开，优先检查该服务对应策略组选择的节点是否可用。
- 如果国内网站变慢，检查是否误选了全局代理模式，应使用 `配置/Config` 模式。
