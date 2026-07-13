# 联网检测规则遮蔽修复与实测设计

## 问题

完整版中通用规则 `DOMAIN-SUFFIX,gstatic.com,Google` 位于具体规则 `DOMAIN-SUFFIX,connectivitycheck.gstatic.com,DIRECT` 之前。按从上到下匹配时，Android 联网检测域名会先进入 `Google`，后面的 `DIRECT` 永远无法生效。

简洁版没有 Google 策略组，因此不存在该遮蔽。

## 修复

- 将 `DOMAIN-SUFFIX,connectivitycheck.gstatic.com,DIRECT` 移至 `DOMAIN-SUFFIX,gstatic.com,Google` 之前。
- 保留普通 `*.gstatic.com` 使用 `Google` 的行为。
- 不改变其他联网检测、Tailscale、YouTube或节点选择规则。

## 回归保护

扩展 `scripts/validate-rules.sh`，扫描 `[Rule]` 中的 `DOMAIN-SUFFIX`：如果较早的通用后缀能够匹配较晚的具体后缀，且二者策略不同，则验证失败并报告双方行号、域名和策略。

测试流程：

1. 先加入检查并运行，确认当前配置因 `gstatic.com`/`connectivitycheck.gstatic.com` 冲突而失败。
2. 移动规则后重新运行，确认验证通过。
3. 运行现有 Tailscale、策略引用、模块和工作流检查，确保无回归。

## 实测

在这台 Mac 已安装的 Shadowrocket 中优先使用规则测试或日志功能验证：

- `connectivitycheck.gstatic.com` 命中 `DIRECT`。
- 普通 `gstatic.com` 子域名命中 `Google`。
- `youtubei.googleapis.com` 命中 `YouTube`。

若应用没有独立规则测试入口，则在不改变代理节点的前提下，通过最小网络请求和 Shadowrocket 日志观察匹配结果。任何临时配置切换在测试后恢复。

## 验收

- 自动验证先失败后通过。
- GitHub Actions 成功。
- Shadowrocket 实测三个样例的策略均符合预期，或明确报告因应用/节点环境无法完成的步骤。
