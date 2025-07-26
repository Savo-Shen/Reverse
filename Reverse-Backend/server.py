'''
Author: Savo Shen savo_shen@qq.com
Date: 2025-07-24 16:22:00
LastEditors: Savo Shen savo_shen@qq.com
LastEditTime: 2025-07-27 01:22:12
FilePath: /Python/Users/savo_shen/Programs/Reverse/Reverse-Backend/server.py
Description: 这个文件也帅到被人砍
不会打球的吉他手不是好程序员
Copyright (c) 2025 by Savo_Shen, All Rights Reserved. 
'''

import os
import io
import cv2, numpy as np
import shutil
import base64
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS  # 用于处理跨域请求
import time, random
from baiduMapJailBreak import baidu_map_jailbreak  # 假设你有这个模块
from composite_images import composite_images  # 假设你有这个模块
from image_to_ai import image_to_ai_request, image_to_ai_get  # 假设你有这个模块

app = Flask(__name__)
CORS(app)  # 启用跨域请求支持

@app.route('/baidu_map_jailbreak', methods=['POST'])
def jailbreak():
    data = request.get_json()
    x = data.get('x')
    y = data.get('y')
    sid = data.get('sid', "-1")  # 如果没有提供sid，则默认为-1
    # print(x, y, year)
    result = baidu_map_jailbreak(x, y, sid=sid)
    print(result)
    json_result = {
        "timeline": {
            "years": result[0],
            "sid": result[1]
        }
    }
    # time.sleep(1)  # 随机休息0-2秒
    # return send_file('./horizontal.jpg', mimetype='image/jpeg')
    return jsonify(json_result)

@app.route('/get_image', methods=['GET'])
def get_image():
    try:
        year = request.args.get('year', type=str)
        sid  = request.args.get('sid', type=str)
        return send_file(f'./imgs/{sid}/{year}/horizontal.jpg', mimetype='image/jpeg')
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/composite_image', methods=['POST'])
def composite_image():
    print("收到合成请求")
    try:
        # 获取上传的图片文件列表
        images = request.files.getlist('images')  # key 要和前端 FormData 中一致

        if not images or len(images) == 0:
            return jsonify({'error': '未上传任何图片'}), 400

        # 示例：将图片保存本地再返回文件名列表
        saved_paths = []
        if not os.path.exists('./temp'):
            os.makedirs('./temp')
        for idx, file in enumerate(images):
            filename = f'temp_image_{idx}.jpg'
            save_path = f'./temp/{filename}'
            file.save(save_path)
            saved_paths.append(save_path)

        result = composite_images()  # 调用合成函数

        success, buffer = cv2.imencode('.jpg', result)

        if not success:
            return jsonify({'error': '图像编码失败'}), 500

        return send_file(
            io.BytesIO(buffer.tobytes()),  # 将 NumPy 数组转为内存流
            mimetype='image/jpeg',
            as_attachment=False,
            download_name='inpainted.jpg'  # 可选：指定前端文件名
        )
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/get_ai_image', methods=['POST'])
def get_ai_image_request():
    data = request.get_json()

    year = data.get('year')
    sid = data.get('sid')

    # result = [f for f in os.listdir(f'./imgs/{sid}') if f != '.DS_Store']

    image = cv2.imread(f'./imgs/{sid}/{year}/horizontal.jpg')
    # 将图片编码为 base64 字符串
    image_base64 = base64.b64encode(cv2.imencode('.jpg', image)[1].tobytes()).decode('utf-8')

    task_id = image_to_ai_request(
        image_base64
    )

    print(task_id)

    video_url = None

    while True:
        video_url = image_to_ai_get(task_id=task_id)
        if video_url is None:
            print("等待视频生成中...")
            time.sleep(30)
        else:
            break

    print("生成的视频URL:", video_url)

    return jsonify({
        'video_url': video_url,
    })

@app.route('/mock_video', methods=['GET'])
def mock_video():
    # 模拟返回一个视频文件
    video_path = './local/video2.mp4'
    if os.path.exists(video_path):
        return send_file(video_path, mimetype='video/mp4', as_attachment=False, download_name='mock_video.mp4')
    else:
        return jsonify({'error': '视频文件不存在'}), 404


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)

    