# 华宝五金 iOS App

由原微信小程序（云开发）迁移而来：SwiftUI + SwiftData，iOS 17+，完全离线，数据只存本地。

## 环境要求

- Xcode 16+（已用 Xcode 26 验证编译通过）
- 无需 XcodeGen 等第三方工具，`HuaBaoApp.xcodeproj` 直接用 Xcode 打开即可

## 运行

```bash
open ios-app/HuaBaoApp.xcodeproj
```

选择 iPhone 模拟器或真机运行。命令行编译：

```bash
xcodebuild -project ios-app/HuaBaoApp.xcodeproj -scheme HuaBao \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## 数据初始化（导入云端导出文件）

1. 把微信云开发数据库导出的两个 JSON 文件传到 iPhone（AirDrop / iCloud Drive / 文件 App 均可）：
   - 商品集合（productionList）
   - 操作记录集合（operationList）
2. App 首页（全部）点右上角「导入数据」按钮
3. 「选择导出文件导入」，两个文件可以一起选，App 会自动识别类型
4. 按 `_id` 去重，重复导入只会跳过已有数据，不会产生重复

## 数据导出（备份）

同一页面点「导出全部数据」，会把本地商品和操作记录按与云开发导出完全一致的格式（JSONL、`{"$date": ...}` 日期）生成 `productionList.json` / `operationList.json` 两个文件，通过系统分享面板保存或 AirDrop。导出的文件可以直接再导入（已验证 2869 条商品 + 4613 条记录导入→导出→再导入后全字段一致）。

`SampleData/` 目录下保留了迁移时使用的导出文件副本（2869 条商品 + 4613 条操作记录），可直接用于模拟器测试导入。

## 功能（与小程序一致）

- **全部**：按首字母 A-Z 分组索引的商品列表，底部显示总条数
- **搜索**：按名称 / 名称代码 / 规格模糊匹配
- **增加**：新增商品（全字段必填，按 名称+规格 查重），自动写入「新增」操作记录
- **详情**：修改数量（步进器）/ 价格，删除商品（二次确认），自动写入「修改」（带新旧数据）/「删除」操作记录
- **记录**：操作记录列表，支持按类型（新增/修改/删除）、时间（全部/今天/自定义区间）、正倒序筛选；修改记录可查看新旧数据对比

## 目录结构

```
ios-app/
├─ HuaBaoApp.xcodeproj/   # 手写工程文件（PBXFileSystemSynchronizedRootGroup，源文件改动无需改工程）
├─ SampleData/            # 云端导出数据副本，供导入测试
└─ HuaBao/
   ├─ App/HuaBaoApp.swift                  # @main + TabView
   ├─ Core/
   │  ├─ Models/Product.swift              # 商品（对应 productionList）
   │  ├─ Models/OperationRecord.swift      # 操作记录（对应 operationList）
   │  └─ Import/CloudDataImporter.swift    # JSONL 解析 / $date 日期 / 去重
   ├─ Features/
   │  ├─ ProductList/    # 全部
   │  ├─ Search/         # 搜索
   │  ├─ AddProduct/     # 增加
   │  ├─ ProductDetail/  # 详情
   │  ├─ Records/        # 记录
   │  └─ Import/         # 数据导入
   └─ Shared/            # 商品行组件、格式化工具
```

## 数据模型说明

- `Product.id` 沿用云端 `_id`，本地新增商品使用 UUID
- `price` 保持字符串（云端即为字符串）
- 操作记录的 `operateType`：`add` / `delete` / `updata`；`updata` 的新旧数据以 JSON 字符串存在 `oldDataJSON` / `newDataJSON`
