# FilCloud - FIL Monitor iOS App

## 项目概述

FilCloud 是一个使用 Flutter 开发的 Filecoin 监控应用，主要面向 iOS 平台。应用提供了 Filecoin 节点监控、消息通知、资产管理等功能，帮助用户随时掌握 Filecoin 网络状态和自身资产情况。

## 技术栈

- **框架**: Flutter
- **状态管理**: GetX
- **网络请求**: Dio
- **本地存储**: SharedPreferences
- **UI组件**: Flutter SVG, FL Chart
- **推送通知**: Firebase Cloud Messaging (FCM)
- **其他工具**: UUID, Intl, URL Launcher

## 项目结构

```yaml
lib/
├── main.dart              # 应用入口
├── package/              # 数据模型和工具类
├── page/                 # 页面组件
│   ├── asset_page.dart    # 资产页面
│   ├── home_page.dart     # 首页
│   ├── login_page.dart    # 登录页面
│   ├── message_page.dart  # 消息页面
│   ├── node_page.dart     # 节点页面
│   ├── sector_page.dart   # 扇区详情页面
│   └── setting_page.dart  # 设置页面
├── service/              # 服务层
│   ├── api_service.dart   # API 服务
│   └── push_notification_service.dart # 推送通知服务
├── start/                # 应用启动相关
│   └── start.dart        # 主导航结构
└── tool/                 # 工具类和辅助函数
```

## 功能模块

### 1. 认证模块

- 用户登录/注册
- 验证码机制
- 登录状态管理
- 会话过期处理

### 2. 首页模块

- 部门管理
- Filecoin 网络概览
- 货币价格信息
- 实时数据更新

### 3. 节点模块

- 节点列表展示
- 节点详情查看
- 节点状态监控
- 节点 URL 链接功能

### 4. 消息模块

- 系统消息通知
- 推送消息管理
- 消息已读/未读状态

### 5. 资产模块

- 用户资产概览
- 交易记录查询
- 资产变动监控

### 6. 扇区管理

- 扇区状态查看
- 扇区详情展示

## 版本历史

### FilsLink

| 版本号 | 构建号 | 更新内容 |
|-------|-------|--------|
| 1.0.0 | - | 项目初始化 |
| 1.0.1 | - | 增加货币价格信息 |
| 1.0.2 | - | 增加消息推送功能 |
| 1.0.3 | - | 消息推送测试 |
| 1.0.0 | 1 | 首个测试版本发布 |
| 1.0.1 | 2 | 增加扇区详情，优化UI |
| 1.0.1 | 3 | UI优化和bug修复 |
| 1.0.2 | 4 | 增加登录过期处理，登录验证码机制优化 |
| 1.0.3 | 5 | 适配Apple新协议 |

### FilCloud(FilsLink升级版)

| 版本号 | 构建号 | 更新内容 |
|-------|-------|--------|
| 1.0.1 | 1 | 项目初始化 |
| 1.0.1 | 2 | 增加节点 URL 链接功能 |
| 1.2.0 | 3 | 增加管理功能，优化UI |

## 开发环境配置

### 前提条件

- Flutter SDK (最新稳定版)
- Xcode 14.0+
- iOS 14.0+ 设备或模拟器
- macOS 系统

### 安装步骤

1. 克隆项目

   ```bash
   git clone [项目仓库URL]
   cd fils_link
   ```

2. 安装依赖

   ```bash
   flutter pub get
   ```

3. iOS 配置

   ```bash
   cd ios
   pod install
   cd ..
   ```

4. 运行应用

   ```bash
   flutter run
   ```

### 构建发布版本

1. 构建 iOS 应用

   ```bash
   # 清理项目
   flutter clean

   # 安装依赖
   flutter pub get

   # 构建发布版本
   flutter build ios --release
   ```

2. 使用 Xcode 上传到 TestFlight
   - 打开 Xcode 项目 `ios/Runner.xcworkspace`
   - 选择 "Any iOS Device (arm64)" 作为目标设备
   - 选择 Product > Archive
   - 在 Archives 窗口中选择最新的归档
   - 点击 "Distribute App"
   - 选择 "TestFlight Internal Only" 用于内部测试

## 开发规范

### 代码风格

- 遵循 Flutter 官方推荐的代码风格
- 使用 `flutter analyze` 检查代码质量
- 使用有意义的变量名和函数名

### 提交规范

- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 代码风格修改
- refactor: 代码重构
- test: 测试相关
- chore: 构建过程或辅助工具的变动

## 未来计划

- [ ] 增加动画效果，提升用户体验
- [ ] 优化 UI 界面，提高视觉效果
- [ ] 增加更多交互功能
- [ ] 支持深色模式
- [ ] 多语言支持
- [ ] 性能优化

## 常见问题

### 1. iOS 构建问题

如果遇到 "Undefined symbol" 错误，尝试以下步骤：

- 清理项目 `flutter clean`
- 重新安装依赖 `flutter pub get`
- 重新安装 Pods `cd ios && pod deintegrate && pod install`

### 2. 证书问题

在真机测试时如果遇到证书问题：

- 在 Xcode 中确保正确设置开发者账号
- 确保 Bundle Identifier 是唯一的
- 在 Signing & Capabilities 中勾选 "Automatically manage signing"

## 联系方式

如有问题或建议，请联系项目维护者。

- 增加设置功能
- 增加登录验证刷新功能，增加登录验证过期功能
