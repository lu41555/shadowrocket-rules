# 规则安全与可维护性优化设计

## 目标

- 保持所有 `100.*` 地址走代理的既有行为，仅让 Tailscale 设备本地服务 `100.100.100.100/32` 直连。
- 修复 YouTube API 被通用 Google 规则提前匹配的问题。
- 降低 YouTube 基础去广告模块对其他应用的误伤风险。
- 固定 MITM v2 使用的第三方脚本版本，避免上游分支更新造成未经审核的行为变化。
- 增加自动检查，防止关键规则回归。

## 配置规则

完整版和简洁版均在 `100.0.0.0/8,PROXY` 之前加入：

```ini
IP-CIDR,100.100.100.100/32,DIRECT,no-resolve
```

这是整个 `100.0.0.0/8` 的唯一直连例外，用于 Tailscale Quad100/MagicDNS 本地服务。其他 `100.*` 地址继续走 `PROXY`。

完整版将 `DOMAIN-SUFFIX,youtubei.googleapis.com,YouTube` 移至 `DOMAIN-SUFFIX,googleapis.com,Google` 之前，确保具体规则优先于通用后缀规则。

## YouTube 模块

基础模块删除以下可能影响其他应用或无效的规则：

- `DOMAIN-SUFFIX,google-analytics.com,REJECT`
- `DOMAIN-SUFFIX,play.google.com/log,REJECT`
- `DOMAIN-SUFFIX,app-measurement.com,REJECT`
- `DOMAIN-SUFFIX,firebaseinstallations.googleapis.com,REJECT`
- `DOMAIN-SUFFIX,firebaselogging.googleapis.com,REJECT`

MITM v2 继续使用当前社区脚本，但 URL 固定到实施时验证过的 Git 提交 SHA，不再跟随可变的 `master` 分支。

旧 MITM 模块与本地脚本本轮保留，避免已有订阅 URL 失效。

## 文档

README 明确说明：

- `100.100.100.100/32` 是 `100.0.0.0/8` 中唯一的直连例外。
- MITM 会解密匹配的 YouTube HTTPS 流量并执行固定版本的第三方脚本。
- 基础模块只保留更明确的 YouTube/广告服务规则，减少对其他应用的影响。

## 自动检查

新增仓库内验证脚本和 GitHub Actions 工作流，检查：

- 两个配置均恰好包含一条 Quad100 直连规则和一条 `100.0.0.0/8` 代理规则，且顺序正确。
- Tailscale 三个域名后缀规则完整。
- 完整版不存在 `url-test` 或 `fallback` 自动策略组。
- `youtubei.googleapis.com` 位于通用 `googleapis.com` 之前。
- 所有规则引用的策略组存在。
- 基础模块不再包含已删除的广域或无效规则。
- MITM v2 的脚本 URL 包含完整提交 SHA，且不引用 `master`。

验证脚本使用 macOS/Linux 都可用的 POSIX shell、`awk` 和 `grep`，不增加第三方运行时依赖。

## 验收标准

- 本地验证脚本退出码为 0。
- GitHub Actions 在推送与拉取请求时运行同一验证脚本。
- README 与实际规则一致。
- 只修改本设计涉及的配置、模块、文档和验证文件。
