# 工具契约目录（21 个）

> 快照时间：2026-09-15 · 与生产端点 `tools/list` 实时返回一致（可匿名查看）。
> 🔑 = 成品类工具，首次调用前需先执行一次 `get_protocol_instructions`（72 小时内免重复握手）。

---

## `estimate_etou_json` 🔑

估算转E投格式：估算数据JSON → construction_data.json（平台侧数据对接用）。前置：需先调 get_protocol_instructions。

**入参：**
  - `estimate` （必填） object
  - `project_info` （可选） object

---

## `estimate_excel` 🔑

投资估算：估算数据JSON → 三表Excel（估算表/汇总/技术经济指标，全公式），返回 file_base64（默认返回72h下载短链，return_mode="base64" 可回退）。格式规范先看 get_skill_instructions(skill=estimate)。前置：需先调 get_protocol_instructions。

**入参：**
  - `estimate` （必填） object
  - `file_name` （可选） string
  - `return_mode` （可选） string · 枚举: base64 / url
      成品交付方式：base64（默认，兼容）；url 推荐——返回72h下载短链（file.url），防大文件撑爆上下文，外部客户端建议默认 url

---

## `fast_calc_excel` 🔑

快速测算成品：5类txt → 12表全公式Excel（E投口径）。默认返回72h下载短链（file.url，防大文件撑爆上下文），return_mode="base64" 可回退（超10万字符自动降级短链）。前置：需先调 get_protocol_instructions。

**入参：**
  - `files` （必填） object
      5类txt：文件名→全文
  - `file_name` （可选） string
      成品文件名（可选，缺省自动生成）
  - `return_mode` （可选） string · 枚举: base64 / url
      交付方式：默认 url（72h短链）；base64 可回退（超过10万字符自动降级短链防客户端截断）

---

## `fast_calc_reports`

财务测算：5类输入txt → 16键JSON（11张报表+指标+IRR/MIRR诊断+资金缺口）。_meta.years=年份轴；financial_ratios=行清单[序号,指标名,月口径,年口径]；其余报表=年度矩阵{行名:{年份:数值}}。整体约50~60KB，若客户端响应上限50KB会被截断（尾部表丢失）：可传 tables="表名1,表名2" 分批拉取（省流且截断自检），完整表名清单=invest_exp_fundraising/debt_repayment_schedule/cost_expense_stat/revenue_stat/tax_stat/profit_distribution_stat/cash_flow_stat/balance_sheet/project_invest_cash_flow/investor_cash_flow/financial_ratios；返回JSON末位 complete:true=完整，缺失即被截断（重拉或分批）。数字必须原样引用，禁止自行换算。irr_health/warnings 提示 IRR 未收敛失灵时，以年口径 IRR 与修正后 MIRR 为主判据。

**入参：**
  - `files` （必填） object
      5类txt：文件名→全文
  - `tables` （可选） string
      可选：分批拉取的表名清单，逗号分隔，带不带.txt均可（如 "revenue_stat,cost_expense_stat"）；合法表名=invest_exp_fundraising/debt_repayment_schedule/cost_expense_stat/revenue_stat/tax_stat/profit_distribution_stat/cash_flow_stat/balance_sheet/project_invest_cash_flow/investor_cash_flow/financial_ratios；返回JSON末位 complete:true=完整，缺失即被截断（重拉或分批）

---

## `fast_calc_solve`

指标反算（秒级，二分法+引擎精算）：给定5类输入txt与目标指标值（如全投资税后IRR=8%），反推收入/成本/建设投资的调整幅度。杠杆（knob）：revenue_pct 收入整体±% / cost_pct 成本整体±% / invest_pct 建设投资±%（含税金额+进度款同步等比+闭合守卫）。目标（target）：irr_all_post/irr_all_pre/irr_cap_post/irr_cap_pre/irr_inv_pre/payback/dpayback/npv_all_post/npv_all_pre/npv_cap_post/npv_cap_pre/npv_inv_pre/npvr/pi（14项，IRR%/NPV万元/回收期月同报表原生口径）。want：down（默认，降到目标）/up（升到目标）。建议先用 fast_calc_reports 查看基准值再反算。返回语义：ok=true+nochange=true=已达标无需调整（见 msg）；ok=false+reason=range=探索范围内无解（message 含当前值→可达极限值，应如实告知用户并建议换杠杆或结构性调整）；k 逼近±90%/+300% 边界时 note 附⚠️边界警告（返回边界最优解而非精确达标解）。

**入参：**
  - `files` （必填） object
      5类输入txt：文件名→全文
  - `knob` （必填） string · 枚举: revenue_pct / cost_pct / invest_pct
      反算杠杆：收入/成本/建设投资 整体±%
  - `target` （必填） string · 枚举: irr_all_post / irr_all_pre / irr_cap_post / irr_cap_pre / irr_inv_pre / payback / dpayback / npv_all_post / npv_all_pre / npv_cap_post / npv_cap_pre / npv_inv_pre / npvr / pi
      目标指标
  - `goal` （必填） number
      目标值（IRR与回收期同报表原生口径：%/月）
  - `want` （可选） string · 枚举: down / up
      降至目标（默认）/升至目标

---

## `generate_dashboard`

财务看板（动态资金流演绎+双口径动态偿债能力分析）→ 单文件HTML（约1.1MB，侧边栏导航：总览/动态资金流演绎/敏感性热力/双口径动态偿债能力，ECharts内联可离线查看），返回 file_base64（约1.1MB大文件，默认返回72h下载短链（return_mode="base64" 可回退））。两种用法二选一：①推荐 input 传完整五类输入（project_basic_info/construction_data/revenue_data/cost_data/financing_data 的 .txt），由平台引擎计算标准11张报表（与平台后续分析同源同口径，勿自行拼装报表）；②reports 传E投原生导出的11张标准报表txt+input附 project_basic_info.txt（自行拼装的精简表会被守门拦截）。

**入参：**
  - `reports` （可选） object
      E投原生导出的11张报表txt：文件名→全文（用法②）
  - `input` （必填） object
      用法①：完整五类输入txt（推荐，平台计算标准报表）；用法②：至少含 project_basic_info.txt
  - `return_mode` （可选） string · 枚举: base64 / url
      成品交付方式：base64（默认，兼容）；url 推荐——返回72h下载短链（file.url），防大文件撑爆上下文，外部客户端建议默认 url

---

## `generate_ppt_html` 🔑

演示文稿封装：内容HTML → 自包含HTML（Plotly.js内联，离线可用）。先用 ppt_extract_data 取数并撰写内容，再调本工具出成品（成品常达2~4MB，默认返回72h下载短链（return_mode="base64" 可回退））。HTML结构要求先看 get_skill_instructions(skill=ppt)。前置：需先调 get_protocol_instructions。

**入参：**
  - `content_html` （必填） string
      完整内容HTML文档
  - `file_name` （可选） string
      成品文件名（.html）
  - `return_mode` （可选） string · 枚举: base64 / url
      成品交付方式：base64（默认，兼容）；url 推荐——返回72h下载短链（file.url），防大文件（本工具成品常达MB级）撑爆上下文，外部客户端建议默认 url

---

## `generate_word_report`

Word报告双管线：report_type=gongwen（默认）=通用公文格式，标题+内容块数组；report_type=feasibility/econ=可研/经济评价报告；report_type=national=国民经济评价专项报告（10章标准目录+national_data{benefits,costs,rate}与 run_national_econ 输入同构，附表自动组装）——平台可研技能标准（正文四号字、封面、目录、11张附表自动组装、图表标准渲染；专业版60-75页/简版30-40页），传 report+charts，附表数据源三选一 p_id/files（五类输入，推荐——引擎直算标准11张全年份轴）/reports。**章目录与标准硬校验**（可研8章/经济评价6章，名称顺序不可改，不符拒收并返回标准目录）；正文数字自动与引擎值域比对（number_audit.unmatched 清单=疑似换算/编造，须改回引擎原值）；**数字占位符（推荐）**：{{章节.键.年份}} 由系统从引擎值直灌（键名=get_chapter_data 各章 data 键，chapter=list 查清单），数字零漂移。默认返回72h下载短链（return_mode="base64" 可回退）。gongwen 模式 content_blocks 每块：标题/正文 {"type":"heading1|heading2|heading3|body","text":"..."}；说明行 {"type":"info","label":"口径","value":"万元"}（或 {"type":"info","text":"..."}）；表格 {"type":"table","headers":["列1","列2"],"rows":[["a","b"]]}（也接受 header/columns 别名、[[表头行],[数据行]...] 整体二维数组、竖线分隔文本）。

**入参：**
  - `files` （可选） object
      五类输入txt全文（附表推荐数据源：引擎直算标准11张全年份轴，防自拼表删全0列）
  - `title` （可选） string
  - `subtitle` （可选） string
  - `project_name` （可选） string
  - `project_id` （可选） string
  - `project_stage` （可选） string
  - `add_toc` （可选） boolean
  - `content_blocks` （可选） array
  - `report_type` （可选） string · 枚举: gongwen / feasibility / econ / national
      出稿管线：gongwen=通用公文格式（默认，title+content_blocks 简单块，正文三号）；national=国民经济评价专项报告（10章标准目录+national_data{benefits,costs,rate}与run_national_econ输入同构，5张专项附表自动组装，契约见 get_skill_instructions(skill=national_report)）；feasibility=可行性研究报告——按平台可研技能标准（发改委2023大纲，正文四号字、封面、自动目录、11张E投附表全年份自动组装、图表按技能标准渲染；专业版60-75页≥300段、简版30-40页≥150段，篇幅标准与report契约见 get_skill_instructions(skill=feasibility_report)）；econ=经济评价报告（6章，契约见 econ_report 模板）
  - `report` （可选） object
      feasibility/econ 的报告正文 {meta:{project_name,project_stage,date,type:government|enterprise}, chapters:[{title, sections:[{title, paragraphs:[段落字符串], tables?, charts?:[key], subsections?}]}]}；附表 appendix 不要自己搬——传 p_id 或 reports 由系统自动组装
  - `charts` （可选） array
      feasibility/econ 图表数据规格数组：[{key,type:pie|bar|bar_grouped|line|area|line_fill|tornado|hist_cdf,title,categories,series:[{name,values}],unit?,threshold?:{value,label},baseline?,color_mode?}]——系统按可研技能标准（Microsoft YaHei、150dpi、饼图右侧图例只显百分比）渲染PNG并插入 section.charts 引用处；数据一律取自 get_chapter_data/run_uncertainty 返回值
  - `p_id` （可选） string
      平台项目号（feasibility/econ 自动组装11张附表用；与 reports 二选一）
  - `stage` （可选） string
      项目阶段目录，默认 scheme_stage
  - `reports` （可选） object
      11张报表数据源（fast_calc_reports 返回的 tables 整包，或 {报表文件名:原生txt}），无平台项目号的外部会话用
  - `file_name` （可选） string
  - `return_mode` （可选） string · 枚举: base64 / url
      成品交付方式：默认 url——返回72h下载短链（file.url），防大文件撑爆上下文；base64 可回退

---

## `get_chapter_data`

报告章节取数：可研报告(feasibility,8章)或经济评价报告(econ,6章)按章节返回结构化数据+写作要点，供撰写后走 generate_word_report 出稿。chapter=list 先看目录；数据源 p_id(+stage) 或 reports 对象（无平台项目号时可先 fast_calc_reports 生成11张表再传入）。数字一律引用返回值。模板先看 get_skill_instructions(skill=feasibility_report|econ_report)。 各章返回的 data 键可作 generate_word_report 段落占位符 {{章节.键[.年份|.total]}}（比率可|pct）——数字由系统直灌，推荐用。

**入参：**
  - `report_type` （必填） string · 枚举: feasibility / econ
      报告类型
  - `chapter` （可选） string
      章节id（list=目录）
  - `p_id` （可选） string
      E投项目号（纯数字，与 reports 二选一）
  - `stage` （可选） string · 枚举: scheme_stage / contract_stage / operating_stage
      默认 scheme_stage
  - `reports` （可选） object
      直接提交报表（与 p_id 二选一）：{E投标准报表文件名: 原生txt全文}，或 JSON {文件名:{行名:{年份:数值}}} / [[表头行],[数据行]...] 二维数组（financial_ratios 传 [{idx,name,m,a}] 列表），或 fast_calc_reports 返回的 tables 整包；可子集
  - `files` （可选） object
      5类输入txt：文件名→全文（与 p_id/reports 三选一——引擎直算标准报表后取章节值，外部会话推荐）

---

## `get_protocol_instructions`

读取Agent接入总则（目录结构/文件命名/落盘存档/成品命名强制规范）。调用 fast_calc_excel 前必须先读（记录72小时内有效）。

**入参：**
  无参数

---

## `get_skill_instructions`

读取技能工作流指令模板：nlmodel=快速测算、estimate=投资估算、ppt=演示文稿、permitted_cost=准许成本定价、national_econ=国民经济评价。

**入参：**
  - `skill` （必填） string · 枚举: nlmodel / estimate / ppt / permitted_cost / national_econ / feasibility_report / econ_report / national_report

---

## `match_cost_indicators`

造价指标匹配：子项/工程描述 → 平台指标库候选指标（名称/单位/指标值/备注，按相关度排序）。投资估算时逐子项先调本工具匹配，禁止编造指标库中不存在的造价指标；全量指标库不下发，仅返回匹配候选。

**入参：**
  - `query` （必填） string
      子项描述，如"城市次干路""污水处理厂 5万吨/日""给水管道 DN800"
  - `top_k` （可选） integer
      返回候选数（1-15，默认8）

---

## `permitted_cost_excel` 🔑

准许成本加合理收益定价：定价数据JSON → 全公式Excel（主表+固定资产+无形资产+有效资产+运营维护费+准许收益+趋势/敏感性，补贴模式含对外收入+政府补贴定价）。返回 file_base64（默认返回72h下载短链，return_mode="base64" 可回退）。数据收集五步与schema先看 get_skill_instructions(skill=permitted_cost)。前置：需先调 get_protocol_instructions。

**入参：**
  - `data` （必填） object
      定价数据JSON：project(对象)+fixed_assets(数组)+intangible_assets(数组)+years(非空数组，含运行维护费与wacc)+revenues(可选，补贴模式)
  - `file_name` （可选） string
      成品文件名（.xlsx，遵循总则命名规范）
  - `return_mode` （可选） string · 枚举: base64 / url
      成品交付方式：base64（默认，兼容）；url 推荐——返回72h下载短链（file.url），防大文件撑爆上下文，外部客户端建议默认 url

---

## `ppt_extract_data` 🔑

演示文稿取数：E投报表txt → 结构化数据JSON（供撰写PPT文稿内容，不必手抄报表数字）。dimension: all|debt|profit|investment|cashflow|operation。前置：需先调 get_protocol_instructions。

**入参：**
  - `reports` （必填） object
      至少1张报表txt：文件名→全文
  - `dimension` （可选） string · 枚举: all / cashflow / debt / investment / operation / profit

---

## `query_usage`

用量统计：查询自己当月（或指定 YYYY-MM）的调用量/下行流量/平均耗时与分端点统计。

**入参：**
  - `month` （可选） string
      YYYY-MM，缺省当月

---

## `run_delivery_bundle` 🔑

一键交付流水线（推荐给外部Agent）：5类输入txt → Excel(12表)+财务看板+敏感性分析(quick≈20s)+可选Word报告，成品全部72h短链。耗时25-30s（含word≈28s），建议客户端超时≥60s。单件失败不中断：返回 files 成功件清单+errors 失败明细。report 提供合规结构（econ 6章/feasibility 8章标准目录+免责句）时追加 Word。前置：需先调 get_protocol_instructions。

**入参：**
  - `files` （必填） object
      5类txt：文件名→全文
  - `report` （可选） object
      可选：Word报告结构（meta/chapters/sections，需符合 report_type 标准目录+免责句；缺省不出 Word）
  - `report_type` （可选） string · 枚举: econ / feasibility
      Word报告类型（默认 econ）
  - `quick` （可选） boolean
      敏感性分析 quick 模式（默认 true≈20s；false=完整模式1-3分钟，慎用）
  - `file_name` （可选） string
      可选：Word报告成品文件名（仅 report 提供、bundle 含 Word 时生效；其余件名自动生成）

---

## `run_model_check`

报表勾稽体检：E/A/F/B/C/D六段73项勾稽校验（恒等式/跨表一致性/财务逻辑/表内构成/行业易错点/综合评价评级），秒级返回逐项结果（✅通过/⚠️提示/❌失败/ℹ️信息）。两种用法：①传 p_id(+stage) 按平台项目号定位自己的项目；②直接传 reports 对象（可子集，缺的报表自动标数据缺失）。无平台项目号时可先 fast_calc_reports 生成11张表再传入。交付前自检或向用户展示报表质量用。

**入参：**
  - `p_id` （可选） string
      E投项目号（纯数字，与 reports 二选一）
  - `stage` （可选） string · 枚举: scheme_stage / contract_stage / operating_stage
      默认 scheme_stage
  - `reports` （可选） object
      直接提交报表（与 p_id 二选一）：{E投标准报表文件名: 原生txt全文}，或 JSON {文件名:{行名:{年份:数值}}} / [[表头行],[数据行]...] 二维数组（financial_ratios 传 [{idx,name,m,a}] 列表），或 fast_calc_reports 返回的 tables 整包；可子集

---

## `run_national_econ`

国民经济评价：效益/费用数组（第0年起，万元，影子价格口径，剔除税收/补贴/国内利息等转移支付）→ ENPV/EIRR/BCR/累计净效益+可行性判定，默认附单因素敏感性与多情景对比。效益费用识别与影子价格调整方法先看 get_skill_instructions(skill=national_econ)。

**入参：**
  - `benefits` （必填） array
      逐年经济效益流量（万元）
  - `costs` （必填） array
      逐年经济费用流量（万元，建设投资自第0年起）
  - `rate` （可选） number
      社会折现率（默认0.08，一般8%，长受益期公益性项目可6%）
  - `sensitivity` （可选） boolean
      是否附敏感性/情景分析（默认true）

---

## `run_revenue_review`

收入费用合理性审查：R收入(5项)/C费用(6项)/X交叉(5项)共16项，🔴明显不合理/🟡需关注/🟢正常/ℹ️数值输出待联网对标（需benchmark/地方定价的项已给测算数值与判定阈值，宿主AI联网比对后可自行定级）。双输入：p_id(+stage) 或 reports 对象（无平台项目号时可先 fast_calc_reports 生成11张表再传入）。

**入参：**
  - `p_id` （可选） string
      E投项目号（纯数字，与 reports 二选一）
  - `stage` （可选） string · 枚举: scheme_stage / contract_stage / operating_stage
      默认 scheme_stage
  - `reports` （可选） object
      直接提交报表（与 p_id 二选一）：{E投标准报表文件名: 原生txt全文}，或 JSON {文件名:{行名:{年份:数值}}} / [[表头行],[数据行]...] 二维数组（financial_ratios 传 [{idx,name,m,a}] 列表），或 fast_calc_reports 返回的 tables 整包；可子集

---

## `run_uncertainty` 🔑

不确定性分析：引擎真算敏感性/情景/蒙特卡洛+总报告。两种用法：①p_id(+stage) 定位自己的平台项目，交付物落盘用户工作区并返回文件清单；②files 直传5类输入txt（无平台项目号场景，可由 fast_calc_reports 造数闭环产出），成品入平台文件库返回72h下载短链清单（url 可直接交给用户浏览器下载）。不回base64。耗时1~3分钟，超时设≥300秒。前置：需先调 get_protocol_instructions。

**入参：**
  - `p_id` （可选） string
      E投项目号（纯数字），与 files 二选一
  - `files` （可选） object
      5类输入txt全文 {文件名:内容}，与 p_id 二选一（外部客户端推荐，成品返回72h下载短链）
  - `stage` （可选） string · 枚举: scheme_stage / contract_stage / operating_stage
  - `mc_samples` （可选） integer
      50~2000，默认400
  - `range` （可选） number
      因子扰动幅度%，5~60，默认20；模板要求±5%与±10%两档时，请分别以 range=5、range=10 调用两次
  - `quick` （可选） boolean
      快速模式：跳过情景与蒙特卡洛，敏感性粗网格（单因素5点/双因素9×9）+总报告，实测约20~25秒，客户端超时30秒可用；需要精细网格（9点/21×21）与蒙特卡洛时走完整分析（1-3分钟）并加大客户端超时
  - `factors` （可选） string
      逗号分隔敏感性因子名单（可选）

---

## `submit_feedback`

提交用户反馈（2026-09-12 新增）：宿主AI在用户对工具/结果/平台表达不满、建议或疑问时调用，把反馈转录落库（平台侧每日巡检处理）。content=用户原话或忠实摘要（勿加入AI自己的推测）；涉及具体失败时附 tool 与 rid（从报错返回里取）。告知用户已记录。低门槛：无需先读总则。

**入参：**
  - `content` （必填） string
      反馈内容（2~2000字，用户原话或忠实摘要）
  - `tool` （可选） string
      涉及的工具名（可选）
  - `rid` （可选） string
      关联运行id（可选，报错返回里的 rid）
  - `contact` （可选） string
      用户自愿留下的联系方式（可选）

---
