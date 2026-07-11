(# 数据格式与服务函数说明)

下面文档归纳了工程中四个 JSON 文件的数据格式，以及 `services.py` 中函数的职责、参数、返回值与注意事项，方便阅读与二次开发。

1) `mock_courses.json`（对象）

- 字段：
	- `courseId`: string，例如 `"c001"`
	- `courseName`: string，例如 `"数据结构"`
	- `exam`: object
		- `date`: string（YYYY-MM-DD），例如 `"2026-07-20"`
		- `daysLeft`: number，例如 `5`
	- `priority`: string，例如 `"高"`
	- `recentStatus`: object
		- `studyHours`: number，例如 `2`
		- `status`: string，例如 `"近期复习不足"`

说明：表示单门课程及其考试时间、优先级和最近复习状态。

2) `mock_users.json`（对象，单用户）

- 字段：
	- `userId`: string，例如 `"u001"`
	- `basicInfo`: object：`name`、`grade`、`major`
	- `learningGoal`: object：`course`（课程名）、`goal`（学习目标）
	- `time`: object：`freeTime`（数组，格式 `"HH:MM-HH:MM"`）
	- `knowledge`: object：`weakness`（数组）、`strength`（数组）

说明：存放单个用户的资料、空闲时间与知识薄弱/强项。

3) `mock_candidates.json`（数组）

- 每项结构同 `mock_users.json`，表示候选学习伙伴列表。

4) `mock_wrong_questions.json`（对象）

- 字段示例：
	- `questionId`: string
	- `userId`: string
	- `input`: object：例如包含 `image`、`myAnswer`、`correctAnswer`
	- `AIAnalysis`: object：
		- `course`: string
		- `knowledge`: array（可为字符串数组或对象数组，需在使用端统一）
		- `wrongType`: string
		- `reason`: string
		- `Tag`: array of string
		- `suggestion`: array of object（每项 `{studyTag, task}`）

说明：记录单题及 AI 分析结果，注意 `knowledge` 在不同场景可能结构不完全一致（请在使用方做校验）。

---

## `services.py` 函数说明（逐一）

文件：`services.py`

1) generateStudySuggestions(user, course)

- 功能：根据课程的考试紧迫度、最近复习状态和用户薄弱项生成简短学习建议。
- 参数：
	- `user`: 用户对象（同 `mock_users.json` 结构）
	- `course`: 课程对象（同 `mock_courses.json` 结构）
- 返回：object，例如：
	- `{ "course": "数据结构", "task": "二叉树遍历", "reason": "考试临近...", "duration": "30分钟" }`

2) analyzeWrongQuestion(imageID)

- 功能：提供错题的示例分析（当前实现为基于 imageID 的硬编码示例）。
- 参数：`imageID`（string）
- 返回：object，形如：
	- `{ "course":"数据结构", "knowledge":["二叉树遍历"], "wrongType":"概念混淆", "reason":"...", "suggestions":["..."], "Tag":["..."] }`

3) parseTime(timeStr)

- 功能：把字符串 `"HH:MM-HH:MM"` 转为 `(startMinutes, endMinutes)`（整数分钟）。
- 参数：`timeStr`（string）
- 返回：tuple(int, int)
- 注意：未对格式做严格校验，调用方应确保输入格式正确；跨午夜的时间段（如 `23:00-01:00`）不在当前实现范围内。

4) formatTime(minutes)

- 功能：把分钟数转为 `"HH:MM"` 字符串。

5) getOverlapScore(userTimes, candidateTimes)

- 功能：计算两组时间段（字符串数组）中最大重叠时长，并根据重叠时长返回评分与重叠段。
- 参数：
	- `userTimes`, `candidateTimes`: `["HH:MM-HH:MM", ...]`
- 返回：object，例如：
	- 无重叠：`{"score":0, "Start":None, "End":None, "duration":0}`
	- >=60 分钟：`{"score":20, "Start":"20:00", "End":"21:30", "duration":90}`
- 注意：当前实现未处理跨午夜的区间，也没有验证时间字符串是否合法。

6) matchPartner(user, candidate)

- 功能：计算单个候选人的匹配得分并返回理由与重叠时间。
- 参数：`user`（对象），`candidate`（对象）
- 返回：object，例如：
	- `{ "matchName":"小红", "score":75, "reasons":["学习课程一致","空闲时间匹配"], "studyTime":"20:00-21:00", "duration":60 }`
- 匹配项说明：
	- 课程匹配 +40
	- 学习目标匹配 +25
	- 知识互补 +20
	- 时间重叠分值由 `getOverlapScore` 提供（0 / 5 / 10 / 20）
- 注意：建议把课程/目标匹配的逻辑从 `in` 改为更明确的比较，或允许多课程字符串解析。

7) matchBestPartner(user, candidates)

- 功能：遍历候选人列表，返回得分最高的匹配信息（由 `matchPartner` 得出）。
- 返回：`matchPartner` 的结果对象或 `None`（若列表为空）。
- 注意：未对并列最高分做特殊处理（可按时间重叠时长或其它规则作为 tiebreaker）。


