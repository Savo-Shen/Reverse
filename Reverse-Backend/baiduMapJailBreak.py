import threading

import requests, json, re, os, random, time, math,datetime
from PIL import Image
from io import BytesIO

import cv2, numpy as np

from PIL import Image
from py360convert import e2c, c2e

import shutil

x_pi = 3.14159265358979324 * 3000.0 / 180.0
pi = 3.1415926535897932384626  # π
a = 6378245.0  # 长半轴
ee = 0.00669342162296594323  # 扁率
# 百度墨卡托投影纠正矩阵
LLBAND = [75, 60, 45, 30, 15, 0]
LL2MC = [
    [-0.0015702102444, 111320.7020616939, 1704480524535203, -10338987376042340, 26112667856603880, -35149669176653700,
     26595700718403920, -10725012454188240, 1800819912950474, 82.5],
    [0.0008277824516172526, 111320.7020463578, 647795574.6671607, -4082003173.641316, 10774905663.51142,
     -15171875531.51559, 12053065338.62167, -5124939663.577472, 913311935.9512032, 67.5],
    [0.00337398766765, 111320.7020202162, 4481351.045890365, -23393751.19931662, 79682215.47186455, -115964993.2797253,
     97236711.15602145, -43661946.33752821, 8477230.501135234, 52.5],
    [0.00220636496208, 111320.7020209128, 51751.86112841131, 3796837.749470245, 992013.7397791013, -1221952.21711287,
     1340652.697009075, -620943.6990984312, 144416.9293806241, 37.5],
    [-0.0003441963504368392, 111320.7020576856, 278.2353980772752, 2485758.690035394, 6070.750963243378,
     54821.18345352118, 9540.606633304236, -2710.55326746645, 1405.483844121726, 22.5],
    [-0.0003218135878613132, 111320.7020701615, 0.00369383431289, 823725.6402795718, 0.46104986909093,
     2351.343141331292, 1.58060784298199, 8.77738589078284, 0.37238884252424, 7.45]]
# 百度墨卡托转回到百度经纬度纠正矩阵
MCBAND = [12890594.86, 8362377.87, 5591021, 3481989.83, 1678043.12, 0]
MC2LL = [[1.410526172116255e-8, 0.00000898305509648872, -1.9939833816331, 200.9824383106796, -187.2403703815547,
          91.6087516669843, -23.38765649603339, 2.57121317296198, -0.03801003308653, 17337981.2],
         [-7.435856389565537e-9, 0.000008983055097726239, -0.78625201886289, 96.32687599759846, -1.85204757529826,
          -59.36935905485877, 47.40033549296737, -16.50741931063887, 2.28786674699375, 10260144.86],
         [-3.030883460898826e-8, 0.00000898305509983578, 0.30071316287616, 59.74293618442277, 7.357984074871,
          -25.38371002664745, 13.45380521110908, -3.29883767235584, 0.32710905363475, 6856817.37],
         [-1.981981304930552e-8, 0.000008983055099779535, 0.03278182852591, 40.31678527705744, 0.65659298677277,
          -4.44255534477492, 0.85341911805263, 0.12923347998204, -0.04625736007561, 4482777.06],
         [3.09191371068437e-9, 0.000008983055096812155, 0.00006995724062, 23.10934304144901, -0.00023663490511,
          -0.6321817810242, -0.00663494467273, 0.03430082397953, -0.00466043876332, 2555164.4],
         [2.890871144776878e-9, 0.000008983055095805407, -3.068298e-8, 7.47137025468032, -0.00000353937994,
          -0.02145144861037, -0.00001234426596, 0.00010322952773, -0.00000323890364, 826088.5]]


def gcj02tobd09(lng, lat):
    """
    火星坐标系(GCJ02)转百度坐标系(BD09)
    :param lng:火星坐标经度
    :param lat:火星坐标纬度
    :return:
    """
    z = math.sqrt(lng * lng + lat * lat) + 0.00002 * math.sin(lat * x_pi)
    theta = math.atan2(lat, lng) + 0.000003 * math.cos(lng * x_pi)
    bd_lng = z * math.cos(theta) + 0.0065
    bd_lat = z * math.sin(theta) + 0.006
    return [bd_lng, bd_lat]


def bd09togcj02(bd_lon, bd_lat):
    """
    百度坐标系(BD09)转火星坐标系(GCJ02)
    :param bd_lat:百度坐标纬度
    :param bd_lon:百度坐标经度
    :return:转换后的坐标列表形式
    """
    x = bd_lon - 0.0065
    y = bd_lat - 0.006
    z = math.sqrt(x * x + y * y) - 0.00002 * math.sin(y * x_pi)
    theta = math.atan2(y, x) - 0.000003 * math.cos(x * x_pi)
    gg_lng = z * math.cos(theta)
    gg_lat = z * math.sin(theta)
    return [gg_lng, gg_lat]


def wgs84togcj02(lng, lat):
    """
    WGS84转GCJ02(火星坐标系)
    :param lng:WGS84坐标系的经度
    :param lat:WGS84坐标系的纬度
    :return:
    """
    if out_of_china(lng, lat):  # 判断是否在国内
        return lng, lat
    dlat = transformlat(lng - 105.0, lat - 35.0)
    dlng = transformlng(lng - 105.0, lat - 35.0)
    radlat = lat / 180.0 * pi
    magic = math.sin(radlat)
    magic = 1 - ee * magic * magic
    sqrtmagic = math.sqrt(magic)
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * pi)
    dlng = (dlng * 180.0) / (a / sqrtmagic * math.cos(radlat) * pi)
    mglat = lat + dlat
    mglng = lng + dlng
    return [mglng, mglat]


def wgstobd09(lon, lat):
    tmplon, tmplat = wgs84togcj02(lon, lat)
    return gcj02tobd09(tmplon, tmplat)


def wgstobdmc(lon, lat):
    tmplon, tmplat = wgstobd09(lon, lat)
    return bd09tomercator(tmplon, tmplat)


def gcj02towgs84(lng, lat):
    """
    GCJ02(火星坐标系)转GPS84
    :param lng:火星坐标系的经度
    :param lat:火星坐标系纬度
    :return:
    """
    if out_of_china(lng, lat):
        return lng, lat
    dlat = transformlat(lng - 105.0, lat - 35.0)
    dlng = transformlng(lng - 105.0, lat - 35.0)
    radlat = lat / 180.0 * pi
    magic = math.sin(radlat)
    magic = 1 - ee * magic * magic
    sqrtmagic = math.sqrt(magic)
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * pi)
    dlng = (dlng * 180.0) / (a / sqrtmagic * math.cos(radlat) * pi)
    mglat = lat + dlat
    mglng = lng + dlng
    return [lng * 2 - mglng, lat * 2 - mglat]


def transformlat(lng, lat):
    ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * math.sqrt(math.fabs(lng))
    ret += (20.0 * math.sin(6.0 * lng * pi) + 20.0 * math.sin(2.0 * lng * pi)) * 2.0 / 3.0
    ret += (20.0 * math.sin(lat * pi) + 40.0 *
            math.sin(lat / 3.0 * pi)) * 2.0 / 3.0
    ret += (160.0 * math.sin(lat / 12.0 * pi) + 320 *
            math.sin(lat * pi / 30.0)) * 2.0 / 3.0
    return ret


def transformlng(lng, lat):
    ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * math.sqrt(math.fabs(lng))
    ret += (20.0 * math.sin(6.0 * lng * pi) + 20.0 * math.sin(2.0 * lng * pi)) * 2.0 / 3.0
    ret += (20.0 * math.sin(lng * pi) + 40.0 * math.sin(lng / 3.0 * pi)) * 2.0 / 3.0
    ret += (150.0 * math.sin(lng / 12.0 * pi) + 300.0 * math.sin(lng / 30.0 * pi)) * 2.0 / 3.0
    return ret


def out_of_china(lng, lat):
    """
    判断是否在国内，不在国内不做偏移
    :param lng:
    :param lat:
    :return:
    """
    if lng < 72.004 or lng > 137.8347:
        return True
    if lat < 0.8293 or lat > 55.8271:
        return True
    return False


def wgs84tomercator(lng, lat):
    """
    wgs84投影到墨卡托
    :param lng:
    :param lat:
    :return:
    """
    x = lng * 20037508.34 / 180
    y = math.log(math.tan((90 + lat) * math.pi / 360)) / (math.pi / 180) * 20037508.34 / 180
    return x, y


def mercatortowgs84(x, y):
    """
    墨卡托投影坐标转回wgs84
    :param x:
    :param y:
    :return:
    """
    lng = x / 20037508.34 * 180
    lat = 180 / math.pi * (2 * math.atan(math.exp(y / 20037508.34 * 180 * math.pi / 180)) - math.pi / 2)
    return lng, lat


def getRange(cC, cB, T):
    if (cB != None):
        cC = max(cC, cB)
    if (T != None):
        cC = min(cC, T)
    return cC


def getLoop(cC, cB, T):
    while (cC > T):
        cC -= T - cB
    while (cC < cB):
        cC += T - cB
    return cC


def convertor(cC, cD):
    if (cC == None or cD == None):
        print('null')
        return None
    T = cD[0] + cD[1] * abs(cC.x)
    cB = abs(cC.y) / cD[9]
    cE = cD[2] + cD[3] * cB + cD[4] * cB * cB + cD[5] * cB * cB * cB + cD[6] * cB * cB * cB * cB + cD[
        7] * cB * cB * cB * cB * cB + cD[8] * cB * cB * cB * cB * cB * cB
    if (cC.x < 0):
        T = T * -1
    else:
        T = T
    if (cC.y < 0):
        cE = cE * -1
    else:
        cE = cE
    return [T, cE]


def convertLL2MC(T):
    cD = None
    T.x = getLoop(T.x, -180, 180)
    T.y = getRange(T.y, -74, 74)
    cB = T
    for cC in range(0, len(LLBAND), 1):
        if (cB.y >= LLBAND[cC]):
            cD = LL2MC[cC]
            break
    if (cD != None):
        for cC in range(len(LLBAND) - 1, -1, -1):
            if (cB.y <= -LLBAND[cC]):
                cD = LL2MC[cC]
                break
    cE = convertor(T, cD)
    return cE


def convertMC2LL(cB):
    cC = LLT(abs(cB.x), abs(cB.y))
    cE = None
    for cD in range(0, len(MCBAND), 1):
        if (cC.y >= MCBAND[cD]):
            cE = MC2LL[cD]
            break
    T = convertor(cB, cE)
    return T


def bd09tomercator(lng, lat):
    """
    bd09投影到百度墨卡托
    :param lng:
    :param lat:
    :return:
    """
    baidut = LLT(lng, lat)
    return convertLL2MC(baidut)


def mercatortobd09(x, y):
    """
    墨卡托投影坐标转回bd09
    :param x:
    :param y:
    :return:
    """
    baidut = LLT(x, y)
    return convertMC2LL(baidut)


class LLT:
    def __init__(self, x, y):
        self.x = x
        self.y = y


def Random_choose_useragent():
    ualist = ['Opera/9.80 (Windows NT 6.1; U; cs) Presto/2.7.62 Version/11.01',
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2919.83 Safari/537.36',
              'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2656.18 Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.124 Safari/537.36',
              'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1866.237 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36',
              'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.0; Trident/4.0; InfoPath.1; SV1; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 3.0.04506.30)',
              'Mozilla/5.0 (X11; Linux; rv:74.0) Gecko/20100101 Firefox/74.0',
              'Mozilla/5.0 (X11; CrOS i686 4319.74.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36',
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.517 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36',
              'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.13; ko; rv:1.9.1b2) Gecko/20081201 Firefox/60.0',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2866.71 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20130401 Firefox/31.0',
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2919.83 Safari/537.36',
              'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2226.0 Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1664.3 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.62 Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36',
              'Mozilla/5.0 (X11; CrOS i686 4319.74.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36',
              'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36',
              'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET CLR 2.0.50727; Media Center PC 6.0)',
              'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.2 Safari/537.36',
              'Mozilla/5.0 (X11; Ubuntu; Linux i686 on x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2820.59 Safari/537.36',
              'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_6; zh-cn) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27',
              'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2226.0 Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.124 Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2656.18 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2866.71 Safari/537.36',
              'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_5; ar) AppleWebKit/533.19.4 (KHTML, like Gecko) Version/5.0.3 Safari/533.19.4',
              'Opera/9.80 (Windows NT 5.2; U; ru) Presto/2.7.62 Version/11.01',
              'Mozilla/5.0 (X11; OpenBSD i386) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36',
              'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 Safari/537.36',
              'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.2117.157 Safari/537.36',
              'Mozilla/4.0 (Compatible; MSIE 8.0; Windows NT 5.2; Trident/6.0)',
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.17 Safari/537.36',
              'Mozilla/5.0 (Windows; U; Windows NT 5.1; ja-JP) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.3 Safari/533.19.4',
              'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36',
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1467.0 Safari/537.36']
    headers = {
        'User-Agent': random.choice(ualist)}
    return headers


def xy_to_sid(x, y, input_params):
    params = {
        "udt": input_params['date'],
        "action": 0,
        'x': x,
        'y': y,
        'l': 18.367179030452565,
        "mode": 'day',
        't': 1553246985040,
        'fn': 'jsonp69972182',
        'qt': 'qsdata'
    }

    try:
        r = requests.get("https://mapsv0.bdimg.com/?", params, headers=input_params['headers'], timeout=(3, 7))
        str1 = str(r.content, encoding="utf8")
        jsonstr = str1.split('(')[1].split(')')[0]
        j = json.loads(jsonstr)
        if j["result"]["error"] == 0:
            sid = j['content']['id']
            return sid
        else:  # 如果error不为0，说明这个坐标点没有街景影像
            print("无街景")
            return -1
    except Exception as e:
        print("x,y to sid失败！")
        print(str(e))


# sid to datetime  sid得到时间轴，通过时间轴抓取对应时间的图像
# 输入参数分别 点对应的sid，百度坐标x，y，点序号
def sid_to_date_img(sid, trueX, trueY, wgslon, wgslat, rid, input_params):
    bdsid_param = {
        'sid': sid,
        'pc': 1,
        'udt': input_params['date'],
        # 'udt': input_params['date'],
        'fn': 'jsonp.p3991630',
        'qt': 'sdata'
    }
    # 用于拼接
    image_parts = []
    try:
        # 一个采样点可能有在数个时间点采集的街景影像，这里根据采样点标识ID获取最新的采样点-时间标识ID
        # 同时获取采样点对应的道路的走向，以获得视角与道路走向平行或垂直的街景影像
        r = requests.get("https://mapsv0.bdimg.com/?", bdsid_param, headers=input_params['headers'], timeout=(3, 7))
        str1 = str(r.content, encoding="utf8")
        p2 = re.compile(r'[(](.*)[)]', re.S)  # 贪婪匹配
        jsonstr2 = str(re.findall(p2, str1)[0])
        j = json.loads(jsonstr2)
        direction = float(j['content'][0]['MoveDir'])  # 获取道路的方位

        timeid_list = []
        year_list = []
        for i in range(len(j['content'][0]['TimeLine'])):
            year = j['content'][0]['TimeLine'][i]['Year']
            #print(year)
            # if int(year) == rid:
            timeid = j['content'][0]['TimeLine'][i]['ID']
            # print(timeid)
            timeid_list.append(timeid)
            year_list.append(year)
        # 遍历希望获取的数个方向
        for i in range(len(timeid_list)):
        # for timeid in timeid_list:
            image_parts = []
            for head in input_params['directions']:
                bdimg_params = {
                    'fovy': 100,
                    'quality': 100,
                    'panoid': timeid_list[i],  # panoid 与sid对应
                    'heading': (head + direction) % 360,
                    'width': 1024,
                    'height': 1024,
                    'qt': 'pr3d'
                }
                savedir = f"{input_params['outpath']}/{sid}/{year_list[i]}"
                savepath = f"{savedir}/{year_list[i]}_{wgslon}_{wgslat}_{head}.png"
                if os.path.exists(savepath):
                    # print(f"已存在 {savepath}，跳过下载。")
                    continue
                try:
                    r = requests.get("https://mapsv0.bdimg.com/?", bdimg_params, headers=input_params['headers'],
                                     timeout=(3, 7))
                except Exception as e:
                    print(str(e))
                # 如果获取成功，就保存影像
                if r.headers['Content-Type'] == 'image/jpeg':
                    # save image to list
                    img = Image.open(BytesIO(r.content))
                    image_parts.append(img)

                    if not os.path.exists(savedir):
                        os.makedirs(savedir)
                        print(f"创建目录 {savedir}")
                    if not os.path.exists(savepath):
                        open(savepath, 'wb').write(r.content)
                        print(f"✅ 成功获取图像 {savepath}")
                else:
                    print("未成功获取任何图像，跳过拼接与生成等距图。")
                    return 1
            # 拼接图片
            #######################################
            if image_parts:
                # 转换 PIL.Image 为 OpenCV 格式（numpy数组）
                imgs = [cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR) for img in image_parts]

                # 自动拼接为全景图
                stitcher = cv2.Stitcher_create(cv2.Stitcher_PANORAMA)
                status, pano = stitcher.stitch(imgs)
                if status != cv2.Stitcher_OK:
                    raise RuntimeError(f"拼接失败，错误码 {status}")

                # 自动裁剪边缘黑色区域
                gray = cv2.cvtColor(pano, cv2.COLOR_BGR2GRAY)
                mask = cv2.threshold(gray, 1, 255, cv2.THRESH_BINARY_INV)[1]
                cols = np.mean(gray, axis=0); rows = np.mean(gray, axis=1)
                vc = np.where(cols > 10)[0]; vr = np.where(rows > 10)[0]
                crop = pano[vr[0]:vr[-1]+1, vc[0]:vc[-1]+1]
                mask = mask[vr[0]:vr[-1]+1, vc[0]:vc[-1]+1]  # 同步裁剪

                h, w = crop.shape[:2]
                new_h = h
                new_w = 2 * h
                crop = cv2.resize(crop, (new_w, new_h))
                mask = cv2.resize(mask, (new_w, new_h))

                filled = cv2.inpaint(crop, mask, inpaintRadius=3, flags=cv2.INPAINT_TELEA)

                if not os.path.exists(f"./imgs/{sid}/{year_list[i]}/horizontal.jpg"):
                    # os.remove(f"./imgs/{year_list[i]}/horizontal.jpg")
                    # print(f"删除旧的 {year_list[i]}/horizontal.jpg")
                    cv2.imwrite(f"./imgs/{sid}/{year_list[i]}/horizontal.jpg", filled)
                    print("✅ 生成 equirectangular 全景图完成")
                # shutil.rmtree(savedir)  # 删除保存的单张图像目录
                # image_parts.clear()  # 清空列表以便下次使用
        return year_list, sid


    except Exception as e:
        print("sid to img失败！")
        print(str(e))


# 百度坐标得到街景图片
# 参数 百度坐标X、Y、点序号
def xy_to_img(x, y, lon, lat, rid, input_params):
    sid = xy_to_sid(x, y, input_params)  # 先根据坐标获取街景采样点的唯一标识ID
    if sid != -1:
        result = sid_to_date_img(sid, x, y, lon, lat, rid, input_params)
        # print(rid)
        return result


# 输入经纬度得到街景相片
# 参数 经度、纬度、点序号
def lon_lat_to_img(lon, lat, rid, input_params):
    x, y = wgstobdmc(lon, lat)  # 先将WGS1984坐标转为百度墨卡托坐标
    result = xy_to_img(x, y, lon, lat, rid, input_params)  # 使用百度墨卡托坐标获取街景影像
    return result



def ReadRID(filename):
    if not os.path.exists(filename):
        f = open(filename, 'w')
        f.close()
        return 1
    with open(filename, 'r') as f:
        num_str = f.readlines()[-1]
        num = int(num_str.split(',')[0])
    return num

def baidu_map_jailbreak(X, Y, sid="-1", year=2019):
    # 输出图片位置
    input_params = {
        'outpath': r'/Users/savo_shen/Programs/Reverse/Reverse-Backend/imgs',  # 存放街景影像的输出路径
        # 'directions': [0, 90, 180, 270],  # 获取的方向
        # 'directions': [0, 60, 120, 180, 240, 300],
        'directions': [0, 45, 90, 135, 180, 225, 270, 315],  # 获取的方向
        # 'directions': [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330],
        'headers': Random_choose_useragent(),  # 请求头
        # 'date': datetime.datetime(time.strptime(input('202212'), "%Y%m")[0:2]),
        'date': time.strftime("%Y%m%d", time.localtime()),
    }
    outpath = r'/Users/savo_shen/Programs/Reverse/Reverse-Backend/imgs/'
    if not os.path.exists(outpath):
        os.mkdir(outpath)
    filelist = os.listdir(outpath)
    # 打开坐标csv文件
    with open(r'/Users/savo_shen/Programs/Reverse/Reverse-Backend/location.csv', 'r') as data:
        lines = data.readlines()[1:]
        for line in lines:
            line = line.strip()
            # print(line)
            # rid = line.split(',')[2]
            rid = year
            # wgslon = float(line.split(',')[0])
            wgslon = float(X)
            # wgslat = float(line.split(',')[1])
            wgslat = float(Y)
            if rid not in filelist:  # 已有直接跳过
                s = time.time()
                if random.random() < 0.2:  # 0.2 的概率需要sleep
                    time.sleep(random.random() * 2)  # 随机休息0-2秒
                try:
                    # t = threading.Thread(target=lon_lat_to_img, args=(wgslon, wgslat, rid, input_params))
                    # t.start()
                    if sid == "-1":
                        print("正在通过经纬度获取街景影像，点序号：", X, Y)
                        result = lon_lat_to_img(wgslon, wgslat, rid, input_params)
                        # result = xy_to_img(wgslon, wgslat, wgslon, wgslat, rid, input_params)
                    else:

                        if os.path.exists(f"{input_params['outpath']}/{sid}"):
                            print(f"点 {sid} 的街景影像已存在，跳过下载。")
                            # year_list = os.listdir(f"{input_params['outpath']}/{sid}")
                            year_list = [f for f in os.listdir(f"{input_params['outpath']}/{sid}") if f != '.DS_Store']
                            result = year_list, sid
                        else:

                            print("正在通过sid获取街景影像，点序号：", sid)
                            result = sid_to_date_img(sid, wgslon, wgslat, wgslon, wgslat, rid, input_params)
                    return result
                except Exception as e:
                    print(rid, repr(e))


if __name__ == '__main__':
    x = 0
    y = 0
    year = 2020
    baidu_map_jailbreak(x, y, sid="01000300001310131258181905J")
    baidu_map_jailbreak(x, y, sid="09002200122212301028307801C")
    baidu_map_jailbreak(x, y, sid="09029200011609281004462427O")
    baidu_map_jailbreak(x, y, sid="09001700011610051618530276G")
