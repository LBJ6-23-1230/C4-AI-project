import os
import json
import time
from datetime import datetime
from dotenv import load_dotenv
load_dotenv()
import openai
from services.services import (
    call_analyze_weakness,
    call_analyze_wrong,
    call_get_suggestion,
    call_match_partner,
    call_query_tasks,
    call_update_profile,
)

def load_user_data():
    return {
        "users": json.load(open('services/mock_users.json', 'r', encoding='utf-8')),
        "courses": json.load(open('services/mock_courses.json', 'r', encoding='utf-8'))
    }


def load_candidate_data():
    return json.load(open('services/mock_candidates.json', 'r', encoding='utf-8'))

def load_prompt():
    with open('prompts/MainAgentPrompt.txt', 'r', encoding='utf-8') as f:
        return f.read()
    
def get_History():
    history_path = 'services/history.json'
    with open(history_path, 'r', encoding='utf-8') as f:
        try:
            history = json.load(f)
        except json.JSONDecodeError:
            return []

    return history if isinstance(history, list) else []


def save_history_entry(user_input, bot_response):
    history_path = 'services/history.json'
    history = get_History()
    history.append({
        "user_input": user_input,
        "bot_response": bot_response,
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    })

    with open(history_path, 'w', encoding='utf-8') as f:
        json.dump(history, f, ensure_ascii=False, indent=2)

def format_history(history,num_entries=10):
    formatted_history =""
    for entry in history[-num_entries:]:
        formatted_entry = f"""user_Input: {entry.get('user_input', '')}\n
        Bot: {entry.get('bot_response', '')}"""
        formatted_history += formatted_entry
    return formatted_history


def format_deadline_status(deadline_str, current_date=None):
    current_date = current_date or datetime.now().date()
    deadline_date = datetime.strptime(deadline_str, "%Y-%m-%d").date()
    days_diff = (deadline_date - current_date).days

    if days_diff == 0:
        return "今天截止"
    if days_diff > 0:
        return f"倒计时{days_diff}天"
    return f"已过期{abs(days_diff)}天"


def format_task_lines(courses):
    current_date = datetime.now().date()
    task_lines = []

    course_items = []
    if isinstance(courses, list):
        course_items = courses
    elif isinstance(courses, dict):
        course_items = [courses]

    for course in course_items:
        course_name = course.get("courseName", "未知课程")
        for index, task in enumerate(course.get("tasks", []), start=1):
            deadline = task.get("deadline", "")
            deadline_status = format_deadline_status(deadline, current_date) if deadline else "未知"
            task_lines.append(
                f"{index}. {course_name}：{task.get('taskname', '未知任务')}（DDL: {deadline}，{deadline_status}）"
            )

    return task_lines


def parse_intent_response(content: str):
    try:
        intent_data = json.loads(content)
        return intent_data.get("intent", "unknown")
    except json.JSONDecodeError:
        start = content.find("{")
        end = content.rfind("}")
        if start != -1 and end != -1 and end > start:
            try:
                intent_data = json.loads(content[start:end + 1])
                return intent_data.get("intent", "unknown")
            except json.JSONDecodeError:
                return "unknown"
        return "unknown"

class MainChatClient:
    def __init__(self):
        self.api_key = os.getenv("model_api_key")
        self.base_url = os.getenv("base_url")
        self.model_name = os.getenv("model_name")
        self.client = openai.OpenAI(api_key=self.api_key, base_url=self.base_url)
        self.prompt=load_prompt()
        
    def chat(self, prompt: str):
        response = self.client.chat.completions.create(
            model=self.model_name,
            messages=[
                {"role": "system", "content": self.prompt},
                {"role": "user", "content": f"""现在请分析以下用户输入，仅返回 JSON：
                用户输入：{prompt}"""}
            ],
            response_format={"type": "json_object"},
            temperature=0
        )
        print(f"模型原始响应：{response.choices[0].message.content}")
        intent = parse_intent_response(response.choices[0].message.content)
        
        history=get_History()
        formatted_history=format_history(history)
        user_data=load_user_data()
        candidate_data=load_candidate_data()
        task_lines = format_task_lines(user_data.get("courses", {}))
    
        new_prompt=f"""对话历史：{formatted_history}
            用户输入：{prompt}
            当前日期：{time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())}
            用户信息：{user_data.get('users', {})}
            课程信息：{user_data.get('courses', {})}
            任务列表：{chr(10).join(task_lines)}"""

        partner_prompt = f"""对话历史：{formatted_history}
            用户输入：{prompt}
            当前日期：{time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())}
            用户信息：{user_data.get('users', {})}
            用户学习目标：{user_data.get('users', {}).get('learningGoal', {})}
            用户空闲时间：{user_data.get('users', {}).get('time', {})}
            用户知识情况：{user_data.get('users', {}).get('knowledge', {})}
            候选人列表：{candidate_data}"""
            
        print(f"当前日期：{time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())}")
        response_text=""
        if intent=='query_tasks':
            print("query_tasks")
            response_text= call_query_tasks(new_prompt)
        
        elif intent=='analyze_weakness':
            print("analyze_weakness")
            response_text = call_analyze_weakness(new_prompt)

        elif intent=='get_suggestion':
            print("get_suggestion")
            response_text = call_get_suggestion(new_prompt)

        elif intent=='match_partner':
            print("match_partner")
            response_text = call_match_partner(partner_prompt)

        elif intent=='analyze_wrong':
            print("analyze_wrong")
            response_text = call_analyze_wrong(new_prompt)
        
        elif intent=='update_profile':
            print("update_profile")
            response_text = call_update_profile(new_prompt)
        
        elif intent=='unknown':
            response_text = "抱歉，我无法理解您的请求。请提供更多详细信息或重新表述您的问题。"
            
        save_history_entry(prompt, response_text)
        return response_text
