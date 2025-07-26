'''
Author: Savo Shen savo_shen@qq.com
Date: 2025-07-24 15:15:28
LastEditors: Savo Shen savo_shen@qq.com
LastEditTime: 2025-07-24 15:15:31
FilePath: /Python/图片合成全景图/py360convert.py
Description: 这个文件也帅到被人砍
不会打球的吉他手不是好程序员
Copyright (c) 2025 by Savo_Shen, All Rights Reserved. 
'''
from py360convert import e2p
import numpy as np
from PIL import Image

# 加载8张图片
images = [Image.open(f"./imgs/2019/bg{i}.png") for i in range(1, 6)]
images = [np.array(img) for img in images]

# 将图片转换为立方体贴图
cubemap = np.array(images).reshape((2, 2, 2, *images[0].shape))

# 将立方体贴图转换为等距投影图
equirectangular = e2p.convert(cubemap)

# 保存结果
Image.fromarray(equirectangular).save("panorama.jpg")