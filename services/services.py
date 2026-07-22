import os
import json
from dotenv import load_dotenv
import openai
load_dotenv()
import uuid
from datetime import datetime

def load_wrong_questions():
    """加载错题列表，文件不存在或格式错误时返回空列表"""
    path = _wrong_questions_path()
    if not os.path.exists(path):
        return []
    with open(path, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError:
            return []
    return data if isinstance(data, list) else []

def save_wrong_questions(questions):
    """全量保存错题列表"""
    path = _wrong_questions_path()
    with open(path, "w", encoding="utf-8") as f:
        json.dump(questions, f, ensure_ascii=False, indent=2)

def append_wrong_question(new_questions):
    """
    向错题文件追加一条或多条错题记录。
    new_questions 可以是单个 dict 或 list[dict]，格式需严格遵循示例结构。
    自动补全 questionId、userId 和 createdAt。
    """
    questions = load_wrong_questions()

    # 统一处理为列表
    items = new_questions if isinstance(new_questions, list) else [new_questions]

    for q in items:
        if not isinstance(q, dict):
            continue
        # 缺失字段自动补全
        q.setdefault("questionId", str(uuid.uuid4()))
        q.setdefault("userId", "unknown")
        q.setdefault("createdAt", datetime.now().isoformat())

        # 保证内部结构完整（防止后续读取时报错）
        q.setdefault("input", {
            "image": None,
            "myAnswer": None,
            "correctAnswer": None
        })
        ai = q.setdefault("AIAnalysis", {})
        ai.setdefault("course", "未知")
        ai.setdefault("knowledge", [])
        ai.setdefault("wrongType", "其他")
        ai.setdefault("reason", "")
        ai.setdefault("Tag", [])
        ai.setdefault("suggestion", [])

        questions.append(q)

    save_wrong_questions(questions)

def _base_dir():
	return os.path.dirname(os.path.dirname(__file__))

def _user_profile_path():
	return os.path.join(_base_dir(), "services", "mock_users.json")

def _course_profile_path():
	return os.path.join(_base_dir(), "services", "mock_courses.json")

def _wrong_questions_path():
	return os.path.join(_base_dir(), "services", "mock_wrong_questions.json")

def _extract_json_object(content):
	try:
		return json.loads(content)
	except json.JSONDecodeError:
		start = content.find("{")
		end = content.rfind("}")
		if start != -1 and end != -1 and end > start:
			try:
				return json.loads(content[start:end + 1])
			except json.JSONDecodeError:
				return None
	return None

def load_user_profile():
	profile_path = _user_profile_path()
	if not os.path.exists(profile_path):
		return {}
	with open(profile_path, "r", encoding="utf-8") as f:
		try:
			profile = json.load(f)
		except json.JSONDecodeError:
			return {}
	return profile if isinstance(profile, dict) else {}

def save_user_profile(profile):
	profile_path = _user_profile_path()
	with open(profile_path, "w", encoding="utf-8") as f:
		json.dump(profile, f, ensure_ascii=False, indent=2)

def load_course_profile():
	course_path = _course_profile_path()
	if not os.path.exists(course_path):
		return {}
	with open(course_path, "r", encoding="utf-8") as f:
		try:
			course = json.load(f)
		except json.JSONDecodeError:
			return {}
	return course if isinstance(course, (dict, list)) else {}

def save_course_profile(course):
	course_path = _course_profile_path()
	with open(course_path, "w", encoding="utf-8") as f:
		json.dump(course, f, ensure_ascii=False, indent=2)

def _normalize_course_collection(course_data):
	if isinstance(course_data, list):
		return course_data, "list"
	if isinstance(course_data, dict):
		return [course_data], "dict"
	return [], "list"

def _save_course_collection(courses, original_kind):
	course_path = _course_profile_path()
	data_to_save = courses[0] if original_kind == "dict" and len(courses) == 1 else courses
	with open(course_path, "w", encoding="utf-8") as f:
		json.dump(data_to_save, f, ensure_ascii=False, indent=2)

def _course_matches(course, selector):
	if not isinstance(course, dict) or not isinstance(selector, dict):
		return False
	selector_id = selector.get("courseId")
	selector_name = selector.get("courseName")
	if selector_id and str(course.get("courseId", "")) == str(selector_id):
		return True
	if selector_name and str(course.get("courseName", "")) == str(selector_name):
		return True
	return False

def apply_course_updates(course_data, course_updates):
    courses, original_kind = _normalize_course_collection(course_data)
    if isinstance(course_updates, dict):
        course_updates = [course_updates]
    if not isinstance(course_updates, list):
        return course_data, False

    changed = False
    for patch in course_updates:
        if not isinstance(patch, dict):
            continue
        selector = {
            "courseId": patch.get("courseId"),
            "courseName": patch.get("courseName"),
        }
        selector = {k: v for k, v in selector.items() if v not in (None, "")}

        target_course = None
        for course in courses:
            if _course_matches(course, selector):
                target_course = course
                break

        if target_course is None:
            # 新增课程：必须至少包含课程名或ID，且之前未匹配到
            if patch.get("courseName") or patch.get("courseId"):
                courses.append(patch)
                changed = True
            continue

        before = json.dumps(target_course, ensure_ascii=False, sort_keys=True)
        merge_profile_updates(target_course, patch)
        after = json.dumps(target_course, ensure_ascii=False, sort_keys=True)
        if before != after:
            changed = True

    return (courses[0] if original_kind == "dict" and len(courses) == 1 else courses), changed

def merge_profile_updates(profile, updates):
	if not isinstance(profile, dict) or not isinstance(updates, dict):
		return profile

	for key, value in updates.items():
		if isinstance(value, dict) and isinstance(profile.get(key), dict):
			profile[key] = merge_profile_updates(profile.get(key, {}), value)
		else:
			profile[key] = value
	return profile

def load_prompt_file(filename):
	prompt_path = os.path.join(_base_dir(), "prompts", filename)
	if not os.path.exists(prompt_path):
		return ""
	with open(prompt_path, "r", encoding="utf-8") as f:
		return f.read().strip()


def call_model_with_prompt(prompt, user_prompt):
	api_key = os.getenv("model_api_key")
	base_url = os.getenv("base_url")
	model_name = os.getenv("model_name")

	client = openai.OpenAI(api_key=api_key, base_url=base_url)
	messages = []
	messages.append({"role": "system", "content": "你是一个贴心的学习助手“知学搭子”。现在需要根据用户的问题和已有的任务数据，生成一段温暖、清晰、有条理的自然语言回复。"})
	messages.append({"role": "user", "content": prompt+user_prompt})

	response = client.chat.completions.create(
		model=model_name,
		messages=messages,
	)
	return response.choices[0].message.content

def call_query_tasks(prompt: str):
	return call_model_with_prompt(load_prompt_file("QueryTasksPrompt.txt"), prompt)


def call_analyze_weakness(prompt: str):
	return call_model_with_prompt(load_prompt_file("AnalyzeWeaknessPrompt.txt"), prompt)


def call_get_suggestion(prompt: str):
	return call_model_with_prompt(load_prompt_file("GetSuggestionPrompt.txt"), prompt)


def call_match_partner(prompt: str):
	return call_model_with_prompt(load_prompt_file("MatchPartnerPrompt.txt"), prompt)


def call_analyze_wrong(prompt: str):
	api_key = os.getenv("model_api_key")
	base_url = os.getenv("base_url")
	model_name = os.getenv("model_name")

	client = openai.OpenAI(api_key=api_key, base_url=base_url)
	system_prompt = load_prompt_file("AnalyzeWrongPrompt.txt")
	messages = []
	messages.append({"role": "system", "content": "你是一个专业的错题分析助手“知学搭子·错题诊断师”。你的任务是根据用户提供的错题信息，深入分析错误原因，定位知识点薄弱处，并给出可执行的补强建议。"})
	messages.append({"role": "user", "content": system_prompt+prompt})

	response = client.chat.completions.create(
		model=model_name,
		messages=messages,
		response_format={"type": "json_object"},
	)
	content = response.choices[0].message.content
	result = _extract_json_object(content) or {}
	reply = result.get("reply", "已帮你分析错题并提供了补强建议。")
	analysis = result.get("analysis", {})
	append_wrong_question(analysis)
	return reply

def call_update_profile(prompt: str):
	api_key = os.getenv("model_api_key")
	base_url = os.getenv("base_url")
	model_name = os.getenv("model_name")

	client = openai.OpenAI(api_key=api_key, base_url=base_url)
	system_prompt = load_prompt_file("UpdateProfilePrompt.txt")
	messages = []
	messages.append({"role": "system", "content": "你是一个信息更新解析器。你的任务不是直接回复用户，而是根据用户输入和当前档案，提取出可以写回 JSON 文件的结构化更新结果。"})
	messages.append({"role": "user", "content": system_prompt+prompt})

	response = client.chat.completions.create(
		model=model_name,
		messages=messages,
		response_format={"type": "json_object"},
		temperature=0,
	)
	content = response.choices[0].message.content
	result = _extract_json_object(content) or {}
	updates = result.get("updates", {})
	reply = result.get("reply", "已帮你更新用户信息。")

	if isinstance(updates, dict) and updates:
		user_updates = updates.get("user")
		course_updates = updates.get("course")

		if isinstance(user_updates, dict) and user_updates:
			profile = load_user_profile()
			merged_profile = merge_profile_updates(profile, user_updates)
			save_user_profile(merged_profile)

		if isinstance(course_updates, dict) and course_updates:
			course = load_course_profile()
			updated_course, changed = apply_course_updates(course, course_updates)
			if changed:
				if isinstance(updated_course, list):
					_save_course_collection(updated_course, "list")
				else:
					save_course_profile(updated_course)

		if isinstance(course_updates, list) and course_updates:
			course = load_course_profile()
			updated_course, changed = apply_course_updates(course, course_updates)
			if changed:
				if isinstance(updated_course, list):
					_save_course_collection(updated_course, "list")
				else:
					save_course_profile(updated_course)

	return reply