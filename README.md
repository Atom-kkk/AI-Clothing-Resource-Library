# AI 服装参考库 · 中文汉化版 · 增加上传/生成提示词

> 1407 张 AI 服装参考图的**纯静态**画廊：零依赖、零构建，可本地离线运行，支持手动上传、自定义分类与一键生成 AI 提示词。

**在线演示：** <https://ai-clothing-library.app.workbuddy.host/?sharecode=E2QQTAQUAL>
**PNG 原图打包：** <https://pan.quark.cn/s/3b0b414ac2d3>（1407 张 1366×2048 无损，无需提取码）
**原始图库：** <https://ai-costume-gallery.pages.dev/>（`衣装集 COSTUME-DB-01`）
**原作者：** ギア · [@giaaibusi](https://x.com/giaaibusi)
**中文版参考实现：** [GodAI-Master/ai-costume-gallery-zh](https://github.com/GodAI-Master/ai-costume-gallery-zh)

> **预览：** 打开上面的「在线演示」即可看到完整界面（1407 张图的网格、分类页签、灯箱与 AI 提示词面板）。
> README 里不再内嵌图片——GitHub 的 Markdown 图片统一走 `raw.githubusercontent.com`，该域名在中国大陆常被阻断，会显示成空白框。

---

## 这是什么

原始图库是一套面向 AI 绘画的服装参考素材（不含任何人物），元数据为日文，单页静态 HTML。本项目在它的基础上做成一个**可以长期自己用下去**的工具：

1. **素材完全本地化** —— 1407 张缩略图（360×540，共 13 MB）与 1407 张展示图（1366×2048，共 116 MB）全部落地到 `assets/`，断网、无 CDN 也能正常浏览与下载。
2. **能往里加东西** —— 手动上传自己的服装图（拖拽/多选），指定分类与关键词，编号按分类自动续号；上传的图可以改分类、改关键词、删除。
3. **分类可扩展** —— 内置 8 个分类之外，可以自建分类并指定编号前缀（如「居家 JJ-0001」）。
4. **能直接产出提示词** —— 点开任意一张图，点「生成」即调用 DeepSeek 写一条文生图英文提示词，可改、可复制、自动保存。
5. **零门槛运行** —— 只有一个 `index.html`，双击就能用；也能扔到任意静态托管上。

## 与原始站点 / 中文版实现的区别

| | 原站 COSTUME-DB-01 | [中文版 Next.js 实现](https://github.com/GodAI-Master/ai-costume-gallery-zh) | 本项目 |
| --- | --- | --- | --- |
| 技术栈 | 单页 HTML | Next.js 16 + React 19 | 单文件 HTML，零依赖 |
| 展示图 | 源站外链 | 仍指源站 | **全部本地**（含 1366×2048 原尺寸） |
| 上传自己的图 | ✗ | ✗ | **✓** 拖拽/多选，存浏览器 IndexedDB |
| 自定义分类 | ✗ | ✗ | **✓** 可配编号前缀 |
| 图片编辑/删除 | ✗ | ✗ | **✓** 仅限上传的图，内置图只读 |
| AI 提示词 | ✗ | ✗ | **✓** DeepSeek，可改可存 |
| 打开方式 | 需服务器 | 需 Node 构建 | 双击 `file://` 即可 |

## 功能

### 浏览
- 8 个内置分类页签，计数按实际条目实时统计
- ID / 关键词搜索，中英文等价（`lace` = `蕾丝`，`白` 会同时命中「白色」「象牙白」）
- 每批 120 张，滚到底自动追加；`查看更多` 显示剩余数量
- 卡片 → 灯箱：先显示缩略图，解码完成后无缝换成大图
- `← / →` 切换，`Esc` 关闭，关闭后焦点回到原卡片；手机可左右滑动
- 下载原图（WebP 1366×2048）

### 上传与整理（数据存在浏览器本地）
- 「上传服装」支持拖拽或选择文件，多选，JPG / PNG / WebP / HEIC 均可
- 每张**必须**选分类 + 填关键词，缺失时红框提示并阻止保存
- 编号按分类累加（`SPR-0261`、`SUM-0261`…），序号有独立计数器，删除后不回退、不重号
- 上传时自动生成 640px 缩略图（canvas → WebP），原图单独保存
- 「＋ 分类」新建分类，可指定 1–4 位编号前缀，留空自动生成并去重
- 上传的图可改分类（会按新分类重新编号）、改关键词、删除；内置 1407 张只读

### AI 提示词（需自备 DeepSeek API Key）
- 图片详情里点「生成」，按该服装的分类 + 关键词写 60–90 词英文提示词
- 提示词可手动修改、复制、自动保存；已有提示词的卡片左下角有 `AI` 角标
- 提示词模板（system prompt）可自行改写，固化自己的出图风格

## 数据规模

| 分类 | 条数 | 编号前缀 |
| --- | ---: | --- |
| 春 | 215 | `SPR` |
| 夏 | 254 | `SUM` |
| 秋 | 244 | `AUT` |
| 冬 | 253 | `WIN` |
| 内衣 | 199 | `LNG` |
| 派对 | 48 | `PTY` |
| 泳装 | 54 | `SWM` |
| 性感 | 140 | `SXY` |
| **合计** | **1407** | |

## 目录结构

```
.
├── index.html          # 样式 / 逻辑 / 1407 条数据全部内联（约 400 KB）
├── assets/
│   ├── img/            # 展示图 1366×2048 WebP，1407 张，约 116 MB
│   ├── thumbs/         # 缩略图 360×540 WebP，1407 张，约 13 MB
│   └── png/            # 源站 PNG 原图，1366×2048 无损，约 1.3 GB —— 本地镜像，已 gitignore
├── scripts/            # 原图拉取脚本（断点续传 + 并发 + 自动重试）
├── NOTICE-IMAGES.md    # 图片权利与来源说明（图片不随代码以 MIT 授权）
├── LICENSE             # 代码：MIT
└── README.md
```

## 数据结构

内置数据是 `index.html` 里的一个数组，字段名沿用原站的日文（它们是筛选键），中文只在渲染层替换：

```js
const D = [{
  id: "SPR-0001",
  "カテゴリ": "春",
  "キーワード": "ivory frill knit denim mini skirt coat socks white sneakers",
  "サムネ": "assets/thumbs/SPR-0001.webp",
  "画像":   "assets/img/SPR-0001.webp",
  "原寸":   "assets/img/SPR-0001.webp"
}, /* … */];
```

| 字段 | 示例 | 说明 |
| --- | --- | --- |
| `id` | `SPR-0001` | 编号，`分类前缀-四位序号` |
| `カテゴリ` | `春` | 分类名 |
| `キーワード` | `ivory frill knit …` | 空格分隔的英文标签，用于搜索与 AI 提示词 |
| `サムネ` / `画像` / `原寸` | `assets/…` | 缩略图 / 展示图 / 下载原图，全部本地 |

上传的图片不存在这个数组里，而是存浏览器（见下一节），加载时合并进 `D` 并带 `_local` 标记。

## 本地存储与隐私

上传的图片、分类、提示词、AI 设置**全部只存在浏览器**，不上传任何服务器：

| 位置 | 键名 | 内容 |
| --- | --- | --- |
| IndexedDB | `costume-db` → store `items` | 上传图的原图 Blob + 缩略图 Blob 与元数据 |
| localStorage | `costume.items` | IndexedDB 不可用时的降级存储（dataURL） |
| localStorage | `costume.extraCats` | 自定义分类名数组 |
| localStorage | `costume.catPrefix` | 自定义分类的编号前缀 |
| localStorage | `costume.seq.<分类>` | 各分类的编号计数器 |
| localStorage | `costume.prompts` | `{ 编号: 提示词 }` |
| localStorage | `costume.aiCfg` | DeepSeek Key / 接口地址 / 模型 / 模板 |

彻底清空：浏览器开发者工具 → Application → 清除本站点的 IndexedDB 与 Local Storage。

> **Key 的安全**：DeepSeek API Key 以明文存在 `localStorage`，只在你点「生成」时随请求发往你填的接口地址。公共电脑上不要填。

## 本地使用

**方式一：直接双击**

打开 `index.html` 即可，无需服务器、无需联网（AI 功能除外）。

**方式二：本地静态服务器（推荐）**

```bash
cd AI-Clothing-Resource-Library
python3 -m http.server 8080
# http://localhost:8080
```

> ⚠️ `file://` 和 `http://localhost` 是**不同来源**，IndexedDB / localStorage 互不相通。上传过图片后请固定用同一种方式打开，否则会出现「之前上传的图不见了」。

## 部署

纯静态文件，扔哪都能跑：

| 平台 | 做法 |
| --- | --- |
| 任意静态托管 | 上传全部文件，入口 `index.html` |
| GitHub Pages | Settings → Pages → 分支 `main` / 根目录 |
| Cloudflare Pages / Vercel / Netlify | 构建命令留空，输出目录 `/` |
| 内网 / NAS | 放进 Web 目录即可 |

仓库含 `assets/` 约 129 MB，克隆与上传都偏慢；需要瘦身可只保留 `thumbs/`，或对 `assets/img/` 启用 Git LFS。

## AI 提示词配置

1. 点工具栏「AI 设置」，填 [platform.deepseek.com](https://platform.deepseek.com/api_keys) 申请的 API Key，点「保存设置」→「测试连接」。
2. 接口地址默认 `https://api.deepseek.com`（OpenAI 兼容，路径 `/chat/completions`），模型默认 `deepseek-flash`，也可填 `deepseek-v4-pro` 或其他兼容服务。
3. 点开任意图片 → 右侧「AI 提示词」→「生成」。

默认提示词模板要求模型：只写服装本体（版型/材质/颜色/细节/风格）、不得出现人物或人体、纯白无缝背景、正面 2:3、60–90 个英文词、逗号短语、不要解释与负面词。想换成平铺/悬空/细节特写等风格，直接在设置里改模板。

费用按 token 计，单张约几百 tokens，建议先拿几张试。

## 常见问题

**上传的图刷新后不见了？**
换过打开方式（`file://` ↔ `http://localhost`），两者存储隔离；也可能是清过浏览器数据。

**编号为什么不从 0001 开始？**
编号按分类续号：取该分类前缀下的最大号 +1，所以「春」的新图是 `SPR-0261`（原数据最大到 0260）。

**点生成提示词报 `HTTP 401`？**
Key 无效或余额不足；重新填一份，再点「测试连接」。

**提示「网络或跨域请求失败」？**
接口地址填错、网络不通，或换成了不支持浏览器跨域的第三方服务。

**上传很慢 / 存不下？**
图片会先压缩出缩略图再入库，原图另存；浏览器配额通常够几百张，但清数据会丢，重要素材请另存磁盘。

## 素材说明

| 层级 | 尺寸 | 本地化 | 体积 |
| --- | --- | --- | --- |
| 缩略图 `assets/thumbs/` | 360×540 WebP | ✅ 1407/1407 | 约 13 MB |
| 展示图 `assets/img/` | 1366×2048 WebP | ✅ 1407/1407 | 约 116 MB |
| 原图 PNG（源站） | 1366×2048 PNG | 🟡 本地镜像 / 网盘，未入 git | 约 1.3 GB（每张约 0.95 MB） |

展示图与源站 PNG 同分辨率，所以仓库主体只提交 WebP，克隆快、Pages 也不会超限。

**PNG 原图为什么只存本地？** 1407 张无损 PNG 合计约 1.3 GB，塞进 git 会让克隆、拉取和 GitHub Pages 都很难受，所以 `assets/png/` 走 `.gitignore`，不随仓库分发。

**想拿到这批 PNG 原图，两条路：**

**① 网盘直接下（最省事）** — <https://pan.quark.cn/s/3b0b414ac2d3>　1407 张 1366×2048 无损 PNG 打包，无需提取码。

**② 自己跑脚本从源站拉** — 幂等、可中断续传，断网会自动退避重试：

```bash
bash scripts/fetch-all-png.sh          # 全量 1407 张，约 1.3 GB
PAR=8 bash scripts/fetch-all-png.sh    # 手动指定并发（默认 10）
```

两种方式拿到后都放进 `assets/png/`，页面会自动探测——本地有 `assets/png/` 时下载按钮变成「下载原图（PNG 无损）」，没有则退回「下载原图（WebP）」，两种环境都不会 404。

> 图片权利归原作者，网盘与脚本仅作个人备份与学习用途。

**拉取脚本一览：**

| 脚本 | 作用 |
| --- | --- |
| `scripts/fetch-all-png.sh` | 外层循环：连通性预检 + 跑到全量齐了为止，零进展指数退避 |
| `scripts/fetch-origin-png.sh` | 单轮批量：xargs 并发调 worker，汇总 OK / SKIP / FAIL |
| `scripts/fetch-one-png.sh` | 单张 worker：下载 + 校验 PNG 魔数，坏文件自动换 IP 重试 |
| `scripts/png-ids.txt` | 1407 条待下载编号清单 |
| `scripts/cf-ips.txt` | Cloudflare 边缘 IP 池，用于绕开被污染的 DNS |
| `scripts/verify-png.py` | 全量体检：签名 + 逐块 CRC32 + IEND 结尾，`--delete-bad` 直接删掉坏图 |

三个脚本都是**幂等**的：已存在且校验通过的文件直接跳过，中断后重跑不会重复下载。

**校验分三层，缺一层就会漏掉截断文件**（这是真踩过的坑）：

| 层 | 判据 | 为什么需要 |
| --- | --- | --- |
| 1 | `curl` 退出码为 0 | `curl -m` 超时会中断传输，磁盘上留下半截文件但退出码非 0；不看退出码就无从分辨 |
| 2 | 文件末 12 字节是 `IEND` 块 | 截断的 PNG 依旧有合法文件头和合法体积，只有结尾能暴露 |
| 3 | 体积 > 400 KB | 兜底，挡掉空响应和错误页 |

`scripts/verify-png.py` 是最严的一层：逐块校验 CRC32，连 `IDAT` 数据流都验。**下载完务必跑一遍**：

```bash
python3 scripts/verify-png.py                 # 只检查并列出坏图
python3 scripts/verify-png.py --delete-bad    # 顺手删掉坏图，再重跑 fetch-all-png.sh 补齐
```

**为什么要写死 IP？** 某些环境（容器、沙箱、被劫持的网络）会把 `*.pages.dev` 解析到 `198.18.0.0/15` 这类假地址，表现为「TCP 能连、TLS 握手直接断」，`SSL_ERROR_SYSCALL` 刷屏。源站挂在 Cloudflare 上，任意边缘 IP 都能按 SNI 正确回源，所以脚本用 `curl --resolve` 把域名钉到 `cf-ips.txt` 里的真实 IP。这些 IP 哪天失效了，换成 [Cloudflare 官方 IP 段](https://www.cloudflare.com/ips/) 里任意一个即可；把 `cf-ips.txt` 清空则回退到系统 DNS。

**并发别开太大。** 实测这站（经代理出口）在 10 并发时约 750 KB/s，开到 16 并发会把出口直接打挂、全部失败。脚本默认 `PAR=10`。

## 内容提示

图库为 AI 生成的虚构服装图像，不含人物面部与人体，也不是真实商品照片。分类名称涉及内衣、性感等题材，仅供艺术创作与前端技术实践使用，请勿用于违法用途。

## 版权与致谢

- **图片与原始数据的著作权归原作者 ギア（[@giaaibusi](https://x.com/giaaibusi)）所有**，来源为 `衣装集 COSTUME-DB-01`（<https://ai-costume-gallery.pages.dev/>）。
- 原站说明：图片可免费用于创作（含商业作品的制作、编辑、参考），但**禁止再分发、转载或转售图片数据本身**。本仓库对图片**不主张任何权利**，也不构成对原作品的商业授权；如需商用请自行联系原作者。
- 本仓库仅作个人学习、素材存档与前端工程实践；若原作者认为有不妥，请联系删除。
- 界面文案体例参考了 [GodAI-Master/ai-costume-gallery-zh](https://github.com/GodAI-Master/ai-costume-gallery-zh)（MIT），数据结构沿用原站字段名。
- **代码**（`index.html` 中的样式、脚本、交互逻辑）以 **MIT** 授权，见 [LICENSE](LICENSE)；该协议**不覆盖** `assets/` 里的图片，详见 [NOTICE-IMAGES.md](NOTICE-IMAGES.md)。

## 更新记录

- **2026-10** 补齐源站 1407 张 PNG 无损原图：提供网盘打包下载 + 断点续传脚本；「下载原图」按钮自动在 PNG / WebP 间切换；新增 `verify-png.py` 做逐块 CRC 与像素级校验
- **2026-10** 素材全部本地化，移除所有外部 CDN 依赖；补全 README、许可与图片来源说明
- **2026-10** 接入 DeepSeek 生成文生图提示词；卡片增加 `AI` 角标
- **2026-10** 上传必须选分类与关键词；编号改为按分类累加；支持编辑与删除上传图
- **2026-10** 加入手动上传、自定义分类、浏览器本地存储
