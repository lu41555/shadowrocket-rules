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

- `YouTube`：选择适合 YouTube 的节点。
- `Netflix`：选择支持奈飞解锁的节点。
- `OpenAI`：选择适合 ChatGPT/OpenAI 的节点。
- `Telegram`：选择适合 Telegram 的节点。
- `X`：选择适合 X/Twitter 的节点。
- `TikTok`：选择适合 TikTok 的节点。
- `GitHub`：选择适合 GitHub 的节点。
- `Streaming`：选择适合 Disney+、Hulu、Max、Prime Video 等流媒体的节点。
- `Gaming`：选择适合 Steam、Epic、暴雪、Riot 等游戏平台的节点。

其他没有单独分组的国外网站，会走 Shadowrocket 当前默认的 `PROXY` 节点。

如果你不想给不同网站分别选节点，使用简洁配置即可。

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

## 注意事项

- 本配置不包含任何代理节点信息。
- 你需要自己先导入节点。
- 每个策略组都可以在 Shadowrocket 里手动选择节点。
- 如果某个服务打不开，优先检查该服务对应策略组选择的节点是否可用。
- 如果国内网站变慢，检查是否误选了全局代理模式，应使用 `配置/Config` 模式。
