def generateStudySuggestions(user,course):
    score = 0

    # 考试紧迫度
    if course["exam"]["daysLeft"] <= 7:
        score += 50

    # 最近状态
    if course["recentStatus"]["status"]=="近期复习不足":
        score += 30

    # 薄弱点
    if len(user["knowledge"]["weakness"])>0:
        score +=20

    if score>=80:

        return {
        "course":course["courseName"],
        "task":user["knowledge"]["weakness"][0],
        "reason":"考试临近，需要优先补强薄弱知识点",
        "duration":"30分钟",
        "priority":"高"
        }

    return {
    "course":course["courseName"],
    "task":"正常复习",
    "duration":"30分钟",
    "priority":"中"
    }
    
    
def analyzeWrongQuestion(imageID):
    if imageID=="img001":
        return {
            "course": "数据结构",
            "knowledge": [
                "二叉树遍历"
            ],
            "wrongType": "概念混淆",
            "reason": "未理解中序遍历访问顺序",
            "suggestions": [
                "复习二叉树遍历的定义和访问顺序",
                "做相关练习题巩固理解"
            ],
            "Tag": [
                "二叉树",
                "遍历"
            ]
        }
    else:
        return {
            "course":"未知",
            "knowledge":[],
            "wrongType":"未知",
            "reason":"未知",
            "suggestions":"请上传正确的题目图片",
            "Tag":[]
        }
        
def parseTime(timeStr):

    start,end = timeStr.split("-")

    h1,m1 = map(int,start.split(":"))
    h2,m2 = map(int,end.split(":"))

    return h1*60+m1, h2*60+m2

def formatTime(minutes):

    hour=minutes//60
    minute=minutes%60

    return f"{hour:02d}:{minute:02d}"

def getOverlapScore(userTimes,candidateTimes):
    maxOverlap=0
    OverlapStart=0
    OverlapEnd=0
    for t1 in userTimes:
        for t2 in candidateTimes:
            s1,e1=parseTime(t1)
            s2,e2=parseTime(t2)

            overlap=max(
                0,
                min(e1,e2)-max(s1,s2)
            )

            if overlap>maxOverlap:
                maxOverlap=overlap
                OverlapStart=max(s1,s2)
                OverlapEnd=min(e1,e2)
                
    if maxOverlap>=60:
        return {
            "score":20,
            "Start":formatTime(OverlapStart),
            "End":formatTime(OverlapEnd),
            "duration":maxOverlap
        }

    elif maxOverlap>=30:
        return {
            "score":10,
            "Start":formatTime(OverlapStart),
            "End":formatTime(OverlapEnd),
            "duration":maxOverlap
        }

    elif maxOverlap>0:
        return {
            "score":5,
            "Start":formatTime(OverlapStart),
            "End":formatTime(OverlapEnd),
            "duration":maxOverlap
        }

    return {
        "score":0,
        "Start":None,
        "End":None,
        "duration":0
    }

def matchPartner(user,candidate):
    score=0
    reasons=[]

    #课程
    if user["learningGoal"]["course"] and user["learningGoal"]["course"] in candidate["learningGoal"]["course"]:
        score+=40
        reasons.append(
        "学习课程一致"
        )

    #目标
    if user["learningGoal"]["goal"] and user["learningGoal"]["goal"] in candidate["learningGoal"]["goal"]:
        score+=25
        reasons.append(
        "学习目标一致"
        )

    #知识互补
    userWeak = user["knowledge"]["weakness"]
    userStrong = user["knowledge"]["strength"]

    candidateWeak = candidate["knowledge"]["weakness"]
    candidateStrong = candidate["knowledge"]["strength"]

    # A帮助B
    helpCandidate = list(set(userStrong) & set(candidateWeak))

    # B帮助A
    helpUser = list(set(userWeak) & set(candidateStrong))


    if helpUser and helpCandidate:
        score += 20
        reasons.append(
            "知识能力互补"
        )

    #时间
    res=getOverlapScore(user["time"]['freeTime'],candidate["time"]['freeTime'])
    if res["score"]>0:
        score+=res["score"]
        reasons.append("空闲时间匹配")

    return {
    "matchName":candidate["basicInfo"]["name"],
    "score":score,
    "reasons":reasons,
    "studyTime":f"{res['Start']}-{res['End']}" if res["Start"] else None,
    "duration":res["duration"]
    }


def matchBestPartner(user,candidates):
    bestMatch=None
    bestScore=0

    for candidate in candidates:
        res=matchPartner(user,candidate)
        if res["score"]>bestScore:
            bestScore=res["score"]
            bestMatch=res

    return bestMatch