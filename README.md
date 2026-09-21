# 天然气气田数据实时监测与修复系统

<p align="center">
  <b>基于 RBAC 权限模型 + LightGBM 智能修复引擎的气田生产数据监测平台</b>
</p>

---

## 一、项目简介

本项目面向天然气气田生产场景，提供 **实时数据监测**、**异常检测**、**时序数据智能修复** 与 **多角色权限管控** 能力。

系统采用前后端分离架构：

- 后端基于 **Spring Boot 2.7 + MyBatis**，提供 RESTful 接口；
- 前端基于 **React 18 + Vite + Recharts**，以单页应用形式呈现可视化大屏与业务管理界面；
- 权限模型采用经典 **RBAC 五表设计**（用户 / 角色 / 菜单模块 / 用户角色关联 / 角色菜单关联），登录后按角色动态下发菜单。

核心场景：现场传感器（压力、流量、温度、累计量）在采集过程中经常出现 **缺失值** 与 **异常值**。系统通过 LightGBM 等模型对异常数据进行检测与修复，修复结果需满足 WMAPE、S-score 等评估指标，并支持甲方（客户）对修复方案进行审批。

---

## 二、功能模块

| 模块 | 路由 | 说明 |
| --- | --- | --- |
| 气田总览（Dashboard） | `/dashboard/overview` | 关键指标卡片（总产量、在线井数、告警数、修复率）、气田分布地图、24 小时流量/压力趋势、井状态分布饼图、月度产量统计 |
| 生产监测（Monitor） | `/dashboard/monitor` | 多相流生产监测，实时流量曲线（最近 20 分钟）、节点监测列表、单节点详情（压力/温度/状态） |
| 数据修复（Repair） | `/dashboard/repair` | 修复算法引擎配置（LightGBM）、模型评估指标（WMAPE / S-score / MAE / RMSE）、修复前后对比、修复历史记录、一键重新训练模型 |
| 系统管理（System） | `/dashboard/sys` | 用户列表、角色分配、用户新增/编辑/删除 |
| 点位管理（Points） | `/dashboard/points` | 点位（测点）增删改查、按井站/特征量类型/分组筛选、启用停用 |

> 菜单为动态下发：用户只能看到其角色被授权的模块，未授权模块不会出现在左侧菜单中。

---

## 三、技术栈

### 后端
- Java 1.8
- Spring Boot 2.7.18（spring-boot-starter-web）
- MyBatis Spring Boot Starter 2.3.1（注解式 Mapper）
- MySQL 8.0（mysql-connector-java 8.0.33）
- Maven 构建

### 前端
- React 18.2
- React Router DOM 6.20
- Vite 5.0（开发服务器 + `/api` 代理）
- Axios 1.6（请求/响应拦截器统一处理 token）
- Recharts 3.8（折线图 / 柱状图 / 饼图）
- 纯内联样式，无 UI 组件库依赖

### 数据库
- MySQL 8.x，字符集 `utf8mb4`，库名 `gas_field_rbac`

---

## 四、目录结构

```
天然气气田数据实时监测与修复系统/
├── backend/                                  # Spring Boot 后端
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/gasfield/
│       │   ├── GasFieldApplication.java      # 启动类
│       │   ├── AuthController.java           # 登录接口
│       │   ├── RbacService.java              # RBAC 认证与菜单授权
│       │   ├── config/CorsConfig.java        # 跨域配置
│       │   ├── controller/
│       │   │   ├── PointController.java      # 点位管理接口
│       │   │   └── MonitorController.java    # 监测数据接口
│       │   ├── entity/                       # SysUser / SysRole / SysModule / PointInfo / RealTimeData
│       │   └── mapper/                       # SysUserMapper / SysModuleMapper / PointInfoMapper / RealTimeDataMapper
│       └── resources/application.yml         # 端口与数据源配置
├── frontend/                                 # React 前端
│   ├── package.json
│   ├── vite.config.js                        # 端口 3000，代理 /api -> 8080
│   ├── index.html
│   └── src/
│       ├── App.jsx                           # 路由与登录态
│       ├── main.jsx
│       ├── pages/
│       │   ├── Login.jsx                     # 登录页（含角色快速切换）
│       │   └── Dashboard.jsx                 # 主框架（左侧动态菜单 + 顶部 Header）
│       ├── components/
│       │   ├── DashboardOverview.jsx         # 气田总览
│       │   ├── ProductionMonitor.jsx         # 生产监测
│       │   ├── DataRepair.jsx                # 数据修复
│       │   ├── UserManagement.jsx            # 用户管理
│       │   └── PointManagement.jsx           # 点位管理
│       ├── api/
│       │   ├── request.js                    # Axios 实例 + 拦截器
│       │   └── auth.js                       # 登录接口封装
│       └── utils/auth.js                     # token / 用户信息本地存储
├── sql/
│   ├── init.sql                              # RBAC 五表 + 初始账号/角色/菜单
│   ├── business-tables.sql                   # 12 张业务表结构
│   └── sample-data.sql                       # 示例数据
├── init-database.bat                         # 一键初始化数据库
├── start-backend.bat                         # 一键启动后端
├── start-frontend.bat                        # 一键启动前端
└── 说明文档（含安装部署说明）.docx            # 课程说明文档
```

---

## 五、数据库设计

### 1. RBAC 权限表（`init.sql`）

| 表名 | 说明 |
| --- | --- |
| `sys_user` | 系统用户（账号、密码、姓名、状态） |
| `sys_role` | 角色（名称、权限标识 `role_key`） |
| `sys_module` | 菜单/模块（含父级 `parent_id`、路由 `path`） |
| `sys_user_role` | 用户 ↔ 角色 关联 |
| `sys_role_module` | 角色 ↔ 菜单 关联 |

### 2. 业务表（`business-tables.sql`）

| 表名 | 说明 |
| --- | --- |
| `point_info` | 点位信息（编码、名称、特征量类型、井站、单位、历史上下限、分组、优先级） |
| `real_time_data` | 实时数据（数据时间、数值、质量码、是否异常、是否已修复） |
| `anomaly_detection` | 异常检测记录（检测方法 EWMA/RATE/QUALITY/CUSTOM、异常类型、严重程度、状态） |
| `repair_strategy` | 修复策略配置（窗口大小、异常倍数、修复模型、模型参数、P 值阈值） |
| `repair_record` | 修复记录（原值、修复值、P 值、是否达标、决策依据、审批人） |
| `model_config` | 模型配置（模型类型 LIGHTGBM/ARIMA/LSTM、超参数、特征列、状态） |
| `model_version` | 模型版本（版本号、文件路径、训练样本数、验证分数、指标、是否激活） |
| `alarm_rule` | 告警规则（规则类型、阈值、时间窗口、通知渠道与用户） |
| `alarm_record` | 告警记录（级别、消息、状态、确认人、处理人） |
| `operation_log` | 操作日志（用户、模块、请求 URL、耗时、结果） |
| `report_template` | 报表模板（报表类型、图表配置、导出格式） |
| `system_config` | 系统配置（键值、类型、分组、描述） |

---

## 六、快速开始

### 6.1 环境要求

| 依赖 | 版本建议 |
| --- | --- |
| JDK | 1.8+ |
| Maven | 3.6+ |
| Node.js | 16+（建议 18+） |
| MySQL | 8.0+ |

### 6.2 初始化数据库

**方式一：一键脚本（推荐，Windows）**

1. 在项目根目录创建 `database.local.ini`（脚本会读取其中的账号密码）：

   ```ini
   mysql_user=root
   mysql_password=你的MySQL密码
   ```

2. 双击运行 `init-database.bat`。脚本会自动查找 `mysql.exe`，依次导入：
   - `sql/init.sql`（创建库 `gas_field_rbac` 与 RBAC 表）
   - `sql/business-tables.sql`（创建业务表）
   - `sql/sample-data.sql`（写入示例数据）

**方式二：手动导入**

```bash
mysql -u root -p --default-character-set=utf8mb4 < sql/init.sql
mysql -u root -p --default-character-set=utf8mb4 gas_field_rbac < sql/business-tables.sql
mysql -u root -p --default-character-set=utf8mb4 gas_field_rbac < sql/sample-data.sql
```

### 6.3 修改后端数据源

编辑 `backend/src/main/resources/application.yml`，将 `password` 改为你的 MySQL 密码：

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/gas_field_rbac?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai
    username: root
    password: 3306          # ← 改成你自己的密码
    driver-class-name: com.mysql.cj.jdbc.Driver

mybatis:
  configuration:
    map-underscore-to-camel-case: true
```

### 6.4 启动后端

```bash
cd backend
mvn spring-boot:run
```

或双击 `start-backend.bat`。启动成功后控制台输出 `====== 气田管理系统后端启动成功 ======`，服务地址：<http://localhost:8080>

### 6.5 启动前端

```bash
cd frontend
npm install
npm run dev
```

或双击 `start-frontend.bat`。浏览器访问：<http://localhost:3000>

> Vite 已配置代理：前端所有 `/api/**` 请求转发到 `http://localhost:8080`，因此无需修改前端接口地址。

---

## 七、默认账号与权限

所有账号初始密码均为 `123456`（登录页支持一键切换角色演示）。

| 账号 | 角色 | 角色标识 | 可访问模块 |
| --- | --- | --- | --- |
| `admin` | 系统管理员 | `ADMIN` | 气田总览、生产监测、数据修复、系统管理、点位管理 |
| `client_01` | 甲方代表 | `CLIENT` | 气田总览、生产监测 |
| `algo_dev` | 算法工程师 | `ALGO_DEV` | 气田总览、生产监测、数据修复、点位管理 |
| `field_eng` | 现场工程师 | `FIELD_ENGINEER` | 气田总览、生产监测、点位管理 |

权限控制逻辑：登录成功后返回用户的 `roleId`，后端根据 `sys_role_module` 查询该角色的授权菜单并下发前端，前端据此渲染左侧菜单。

---

## 八、接口清单

### 认证 `/api/auth`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/api/auth/login` | 登录，Body: `{ "username": "...", "password": "..." }`，返回 `token`、`user`、`menus` |

### 点位 `/api/points`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/api/points` | 查询全部点位 |
| GET | `/api/points/stats` | 点位统计（总数/启用/停用/井站数/分组数） |
| GET | `/api/points/{id}` | 按 ID 查询点位 |
| GET | `/api/points/feature-type/{type}` | 按特征量类型查询 |
| GET | `/api/points/well-station/{station}` | 按井站查询 |
| GET | `/api/points/group/{groupName}` | 按分组查询 |
| GET | `/api/points/filters` | 获取筛选项（井站、分组、特征量类型） |
| POST | `/api/points` | 新增点位 |
| PUT | `/api/points/{id}` | 更新点位 |
| PATCH | `/api/points/{id}/status` | 启停点位，Body: `{ "status": 1 }` |
| DELETE | `/api/points/{id}` | 删除点位 |

### 监测 `/api/monitor`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/api/monitor/realtime/{pointId}?hours=24` | 按时间范围查询实时数据 |
| GET | `/api/monitor/latest/{pointId}?limit=100` | 查询最新 N 条数据 |
| GET | `/api/monitor/all?startTime=&endTime=` | 查询时间区间内全部数据（含点位信息） |
| GET | `/api/monitor/quality/{pointId}?hours=24` | 数据质量统计（质量率、缺失率、异常率、修复率） |
| GET | `/api/monitor/dashboard` | 大屏汇总统计（点位数、记录数、异常数、缺失数、质量率） |
| POST | `/api/monitor/data` | 上报实时数据 |

> 时间参数格式为 `yyyy-MM-dd HH:mm:ss`。

---

## 九、配置说明

| 配置项 | 位置 | 默认值 |
| --- | --- | --- |
| 后端端口 | `backend/src/main/resources/application.yml` → `server.port` | 8080 |
| 数据库连接 | 同上 → `spring.datasource` | `localhost:3306/gas_field_rbac` |
| 驼峰映射 | 同上 → `mybatis.configuration.map-underscore-to-camel-case` | true |
| 前端端口 | `frontend/vite.config.js` → `server.port` | 3000 |
| 接口代理 | 同上 → `server.proxy['/api'].target` | `http://localhost:8080` |
| 允许跨域来源 | `backend/.../config/CorsConfig.java` | `localhost:3000 / 5173 / 8081` |

---

## 十、常见问题

**1. 登录提示「用户名或密码错误」**
确认密码为 `123456`，且用户名在 `admin` / `client_01` / `algo_dev` / `field_eng` 之内。当前认证逻辑为演示实现（见 `RbacService.authenticate`），返回的 token 为 mock 字符串。

**2. 数据库初始化脚本报错找不到密码**
`init-database.bat` 依赖项目根目录的 `database.local.ini`，需手动创建并填写 `mysql_user` 与 `mysql_password`。

**3. 前端请求 404 / 跨域失败**
确认后端已在 8080 端口启动；若前端端口不是 3000，需在 `CorsConfig.java` 中补充对应的 `allowedOrigins`，或修改 `vite.config.js` 的代理端口。

**4. 点位管理页数据为空**
示例数据由 `sql/sample-data.sql` 写入，请确认该脚本已成功导入，可通过 `SELECT COUNT(*) FROM point_info;` 校验（默认 10 条）。

**5. 中文乱码**
建库时需使用 `utf8mb4` 字符集，导入时添加 `--default-character-set=utf8mb4` 参数（一键脚本已包含）。

---

## 十一、后续规划

- 用真实 JWT 替换 mock token，并对密码进行 BCrypt 加密存储
- 落地异常检测算法（EWMA / 变化率）与 LightGBM 修复服务，替换前端静态演示数据
- 完善修复审批流、告警推送（邮件 / 短信 / 企业微信）与报表导出（PDF / Excel）
- 增加操作日志切面与数据权限（按井站/分组隔离）

---

## 十二、说明

本项目为「软件开发案例」课程实践项目，部分业务数据（气田地图、修复对比曲线、模型评估指标等）为前端静态演示数据，用于展示系统交互与可视化效果。
