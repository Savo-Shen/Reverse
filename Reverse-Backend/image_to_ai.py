'''
Author: Savo Shen savo_shen@qq.com
Date: 2025-07-26 17:26:30
LastEditors: Savo Shen savo_shen@qq.com
LastEditTime: 2025-07-27 02:41:33
FilePath: /Python/Users/savo_shen/Programs/Reverse/Reverse-Backend/image_to_ai.py
Description: 这个文件也帅到被人砍
不会打球的吉他手不是好程序员
Copyright (c) 2025 by Savo_Shen, All Rights Reserved. 
'''
# coding:utf-8
from __future__ import print_function

from volcengine import visual
from volcengine.visual.VisualService import VisualService

import cv2
import base64
import time

visual_service = VisualService()

visual_service.set_ak('')
visual_service.set_sk('')
    
def image_to_ai_request(image_base64):

    # call below method if you don't set ak and sk in $HOME/.volc/config
  
    # 请求Body(查看接口文档请求参数-请求示例，将请求参数内容复制到此)
    form = {
        "req_key": "jimeng_vgfm_i2v_l20",
        "binary_data_base64": [image_base64],  # 替换为你的图片base64编码
        "prompt": "这是一个街景全景图，我希望让里面的画面像现实一样动起来，像现实生活中一样就行",
        "aspect_ratio": "16:9"
        # ...
    }

    resp = visual_service.cv_sync2async_submit_task(form)
    print(resp)

    task_id = resp.get('data').get('task_id')

    return task_id

def image_to_ai_get(task_id):
    image_form = {
        "req_key": "jimeng_vgfm_i2v_l20",
        "task_id": task_id,
    }

    image_resp = visual_service.cv_sync2async_get_result(image_form)

    # binary_data_base64 = image_resp.get('data').get('binary_data_base64')
    video_status = image_resp.get('data').get('status')

    if video_status != "done":
        print("视频获取失败，原因: ", video_status)
        return 

    video_url = image_resp.get('data').get('video_url')

    return video_url

if __name__ == '__main__':
    # 运行示例

    image = cv2.imread(f'./imgs/01000300001310131258181905J/2013/horizontal.jpg')

    image_base64 = base64.b64encode(cv2.imencode('.jpg', image)[1].tobytes()).decode('utf-8')

    task_id = image_to_ai_request(image_base64)

    video_url = None

    while video_url is None:
        video_url = image_to_ai_get(task_id=task_id)
        if video_url is None:
            print("等待视频生成中...")
            time.sleep(30)

    print("生成的视频URL:", video_url)
