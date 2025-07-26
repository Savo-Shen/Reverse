import cv2, numpy as np
import os
from PIL import Image
from py360convert import e2c, c2e
import shutil

def composite_images():

    # 读取四张图
    # imgs = [cv2.imread(f'ours/1/bg{i}.png') for i in range(1, 8)]
    
    # 遍历图片目录 temp
    imgs = []
    for filename in sorted(os.listdir('./temp')):
        if filename.endswith('.jpg') or filename.endswith('.png') or filename.endswith('.JPG'):
            img_path = os.path.join('./temp', filename)
            img = cv2.imread(img_path)
            if img is not None:
                imgs.append(img)

    print(len(imgs), "张图片被读取")

    # 自动拼接为全景图
    stitcher = cv2.Stitcher_create(cv2.Stitcher_PANORAMA)
    # stitcher.setWaveCorrection(True)
    # stitcher.setWaveCorrectKind(cv2.detail.WAVE_CORRECT_HORIZ)
    # cv2.SIFT_create()
    # cv2.AKAZE_create()
    # features_finder = cv2.SIFT_create()
    # stitcher.setFeaturesFinder(features_finder)
    status, pano = stitcher.stitch(imgs)
    if status != cv2.Stitcher_OK:
        print("拼接失败，尝试使用其他方法，错误码:", status)
        return f"拼接失败，错误码 {status}"

    # 自动裁剪边缘黑色区域
    gray = cv2.cvtColor(pano, cv2.COLOR_BGR2GRAY)
    mask = cv2.threshold(gray, 1, 255, cv2.THRESH_BINARY_INV)[1]
    cols = np.mean(gray, axis=0); rows = np.mean(gray, axis=1)
    vc = np.where(cols > 10)[0]; vr = np.where(rows > 10)[0]
    crop = pano[vr[0]:vr[-1]+1, vc[0]:vc[-1]+1]
    mask = mask[vr[0]:vr[-1]+1, vc[0]:vc[-1]+1]  # <-- 同步裁剪

    h, w = crop.shape[:2]
    new_h = h; new_w = 2 * h
    crop = cv2.resize(crop, (new_w, new_h))
    mask = cv2.resize(mask, (new_w, new_h))

    filled = cv2.inpaint(crop, mask, inpaintRadius=3, flags=cv2.INPAINT_TELEA)

    # cv2.imwrite("horizontal.jpg", filled)
    print("✅ 生成 equirectangular 全景图完成")

    shutil.rmtree('./temp')  # 删除临时目录

    return filled

if __name__ == "__main__":
    result = composite_images()

    cv2.imwrite("temp/horizontal.jpg", result)
    print("全景图已保存为 horizontal.jpg")
    # 如果需要显示图片，可以使用以下代码
    # cv2.imshow("Equirectangular Panorama", result)
    # cv2.waitKey(0)
    # cv2.destroyAllWindows()