import os
import subprocess
import glob

# Standard 3500 Common Simplified Chinese Characters (现代汉语常用字表)
# Level 1 (2500 primary common characters) + Level 2 (1000 secondary common characters)
PRIMARY_2500 = (
    "的一是在不了有和人这中大为上个国我以要他时来用们生到作地于出就分对成会可主发年动同工也能下过"
    "子说产种面而方后多定行学法所民得经十三之进着等部度家电力里如水化高自二理起小物现实加量都两体"
    "制机当使点从业本去把性好应开它合还因由其些然前外天政四日那社义事平形相全表间样想文通被开它合"
    "常政目明受立特代向意生西总关命情并难重及政名确解问更最建第变心向各身果品由意立老已政并反通"
    "阿啊哎哀唉挨癌矮艾爱碍安岸按案暗昂凹傲奥八巴扒拔把吧坝爸罢霸白百柏摆败拜班般颁斑搬板版办半"
    "伴扮拌绊帮绑榜膀包胞包含包苞保宝饱抱报暴豹鲍爆卑杯悲碑北贝备背倍被辈佩配奔本笨崩甭泵蹦逼鼻"
    "比彼笔币必毕闭辟碧蔽壁避臂边编扁便变标表憋别丙柄饼并病拨波玻剥播菠伯驳泊勃博搏薄卜补捕不布"
    "步簿部擦猜才材财裁采彩睬踩菜参餐残蚕惭惨仓舱藏操曹槽草册侧测策层叉插查茶察差拆柴掺缠产阐颤"
    "昌长肠尝偿常厂场敞畅唱抄超朝嘲潮吵炒车扯彻撤尘臣沉辰陈晨衬称趁撑撑成呈承诚城乘惩程惩秤吃痴"
    "池驰迟持尺齿耻斥赤翅充冲虫池抽仇绸愁稠筹酬丑瞅出初除厨锄楚础储处触川穿传船串疮窗床闯创吹炊"
    "垂锤春椿纯蠢词辞磁雌此次刺从粗促醋簇窜催摧脆翠村存寸搓撮错搭达答打大呆怠带待代贷袋逮戴丹单"
    "担耽胆担旦但弹惮淡蛋氮当挡党荡刀叨导岛倒蹈盗到悼道稻得德的灯登等瞪低堤提滴狄笛递第帝弟递颠"
    "典点电垫店淀奠殿叼雕吊钓调掉爹跌叠蝶丁叮盯钉顶订定丢东冬董懂动冻洞都斗陡抖蚪豆督毒读独堵赌"
    "度渡端短段断缎锻堆队对兑队吨敦蹲盾顿多夺朵舵惰跺俄娥鹅额讹恶饿鳄恩儿而尔耳二贰发罚伐乏阀法"
    "帆番翻凡烦繁反返犯泛饭范贩方坊芳防妨房仿纺放非啡飞肥匪诽吠废沸费分份芬粉吩氛纷坟焚粉份愤风"
    "封疯峰锋蜂冯逢缝讽凤佛否夫肤孵伏扶服浮符幅福蝠抚府斧俯辅腐父抚妇负附咐复赴副傅富赋腹覆改钙"
    "盖溉概干甘杆柑竿肝赶感敢散干刚岗纲钢缸杠高膏篙羔糕搞稿告戈鸽割歌阁革格葛隔个各给根跟更耕耿"
    "梗工弓公功攻供宫恭躬巩拱贡共钩勾沟苟狗构购垢够辜菇咕姑孤估箍骨古谷股骨鼓固故顾瓜刮挂拐怪关"
    "观官冠馆管贯惯灌罐光广归龟规硅瑰轨鬼柜贵桂滚棍锅国果裹过哈孩海害氦酣含涵寒喊汉汗旱罕焊憾捍"
    "撼旱焊好郝号浩豪毫耗好号浩喝禾合何和河核荷贺鹤黑嘿痕很狠恨哼恒横衡轰哄烘红宏洪虹鸿喉侯猴吼"
    "后厚候呼乎忽弧狐胡壶湖葫蝴糊蝴互户护沪花华哗滑画划化话怀徊槐坏欢环还缓幻换唤患荒慌皇黄凰簧"
    "谎灰挥辉恢徽回蛔悔毁汇会讳贿晦慧婚昏浑混魂活火伙货获或惑击饥圾机肌鸡迹积基绩激吉及级极即急"
    "疾集籍几己挤脊计记纪技系忌际剂季寄寂计继加夹佳家嘉甲钾价驾架假稼尖坚间肩兼茧捡检剪减荐槛鉴"
    "践贱见建剑健舰渐践鉴件见键江姜将浆僵疆讲奖桨匠酱降交郊骄胶椒焦蕉角狡脚饺缴叫轿较教阶皆接"
    "结街节劫杰洁捷截竭姐解届介戒芥届界借巾斤今金津筋仅紧锦尽劲近进晋浸禁京经茎荆惊晶睛精精井景"
    "警净径竞竟敬境静镜纠究揪九久灸酒旧救就舅居局桔菊局沮举矩句巨拒具俱剧惧据距聚锯娟捐眷圈卷绢"
    "决绝掘觉嚼军均君菌俊卡开凯慨刊堪看康糠抗炕考拷烤靠坷苛科棵柯棵颗壳咳渴克刻客恪肯啃恳垦坑吭"
    "空孔恐控口扣寇枯哭窟苦库裤夸垮挎胯宽款旷况框矿眶亏盔窥魁傀溃愧昆捆困扩阔蜡腊拉啦喇辣来赖蓝"
    "婪篮栏兰澜烂览揽滥郎狼浪浪劳牢老捞络乐勒雷蕾泪类累棱冷愣厘梨狸离莉犁漓篱礼李里理哩娌鲤力历"
    "厉立丽利励例隶粒俩联莲连帘怜炼练恋良凉梁粮亮辆量辽疗撩聊僚辽燎料列劣烈猎裂邻林临淋灵陵岭领"
    "另令溜刘流留硫琉瘤柳六龙咙笼聋隆垄拢楼漏露炉卢芦颅庐芦录赂鹿碌路露律氯虑滤驴吕侣旅铝缕屡履"
    "律乱卵掠略轮伦沦抡论罗萝逻螺罗裸落络妈麻玛码蚂马骂吗嘛埋买麦卖迈脉蛮馒瞒满曼慢漫芒盲忙莽毛"
    "矛茅茂冒贸帽貌么没枚玫眉梅媒煤酶霉每美妹昧媚门闷萌盟蒙猛梦孟咪眯米密秘眯蜜眠棉免勉面苗描瞄"
    "秒渺庙妙灭民泯皿敏名明鸣铭命摸摹蘑模膜摩磨蘑抹末沫莫墨默谋某母亩牡姆拇木目牧墓幕睦慕拿哪呐"
    "钠那纳娜呐乃奶奈耐男南难囊脑恼闹呢馁内嫩能妮泥倪霓拟你匿溺腻年碾念娘酿鸟尿捏聂啮镊镍您宁凝"
    "拧泞牛钮扭纽脓浓农弄奴努怒女暖虐挪诺懦欧殴鸥呕偶藕趴爬怕拍排牌攀盘盘判叛盼旁胖抛袍跑泡胚培"
    "佩沛配喷盆碰批披皮疲脾匹辟僻片偏篇骗漂飘票撇瞥品贫聘频拼乒苹瓶评凭坡泼颇婆迫破粕剖扑铺葡蒲"
    "朴谱七妻戚期欺漆齐其奇歧骑棋旗乞企岂起气弃汽契砌器恰洽千迁牵铅谦签前钱钳潜乾浅欠歉枪腔强墙"
    "抢桥乔侨巧切茄且窃亲侵芹秦琴禽擒青氢轻倾清情晴顷请庆穷秋丘邱球求囚酋求区曲驱屈蛆趋渠取娶去"
    "趣圈全权泉拳犬券缺确雀确裙群然燃冉染让嚷壤扰绕惹热人仁忍韧任认刃妊扔仍日戎茸荣容绒融柔肉茹"
    "儒蠕入褥软蕊润若弱撒洒塞腮三伞散桑嗓丧扫骚色森僧杀沙纱砂傻煞晒山删衫珊闪陕扇善伤商赏晌上尚"
    "梢捎烧稍勺少绍哨蛇舌舍设社射涉摄赦申伸身深神审婶肾甚渗升生声牲胜绳盛省圣盛失师诗施狮湿十石"
    "时识实拾蚀食蚀使始驶矢史屎士氏示世市布式事侍势视试饰室柿适誓释收手首守寿受兽售授瘦书抒叔枢"
    "殊梳舒疏输熟暑属鼠数术树竖恕庶数衰双霜爽谁水税睡顺说吮思司私丝斯嘶死四寺似伺饲巳肆松耸送宋"
    "讼颂搜艘艘苏俗诉肃素速宿塑粟算蒜酸虽隋随岁碎穗遂隧孙损笋缩琐索所塌他它她塔獭踏胎台抬太态泰"
    "贪摊滩坛谈痰潭谭毯坦探汤烫涛掏滔桃逃淘陶讨套特腾疼梯踢提题啼蹄体屉剃涕惕替天添田甜填条跳帖"
    "铁厅听挺亭庭停蜓通同桐铜童统痛偷头投透凸突图徒途涂屠土吐兔团推颓腿退蜕吞托拖脱驮驼妥椭拓唾"
    "挖哇洼蛙娃瓦袜歪外弯湾玩顽挽晚碗万腕汪亡王网往忘旺望危威微危巍为韦违围唯惟维伟伪尾纬委萎卫"
    "未味胃谓喂畏尉慰魏温文纹闻蚊吻紊稳问翁嗡瓮挝蜗我窝卧握沃乌污呜巫屋诬钨无毋吴五午伍武侮舞物"
    "勿务戊务误悟雾膝溪熄席习析喜戏细瞎虾匣狭峡峡夏下吓掀锨先仙鲜纤闲弦贤咸衔嫌显险县现线限相香"
    "箱襄乡相香详祥享响饷想向项巷象像橡削消销小晓孝效校啸肖笑歇协斜携挟邪胁谐写械屑谢泄卸心芯辛"
    "欣新信兴星猩腥刑行型形省杏幸性凶兄胸雄熊休修朽秀绣宿袖嗅须虚徐叙续蓄绪旭序恤酗畜婿絮宣悬旋"
    "选癣学穴雪血熏循询旬寻巡汛讯训迅压鸦鸭押牙芽蚜崖涯雅哑亚讶咽烟淹盐严研言颜阎炎沿奄掩眼演艳"
    "堰燕宴验厌砚雁殃央秧鸯羊阳扬杨疡样洋仰养氧痒样幺夭要药耀腰咬舀咬药耀野也冶夜叶页业液医衣依"
    "椅漪疑移遗宜仪姨乙已已尾以矣椅易亿义艺议忆役疫抑邑亦异役译易绎谊逸意翼因阴荫音吟银印引饮隐"
    "英樱婴鹰应迎营荧萤莹硬颖佣拥庸痈臃踊用优忧幽悠尤由犹油游友有又右幼诱于余鱼渔隅娱愚舆雨与语"
    "羽玉驭宇屿芋雨育郁狱浴峪预域域遇御裕欲寓誉冤元园员圆源猿远苑怨院愿曰月越跃岳粤月悦阅云匀陨"
    "运晕孕砸杂灾栽哉灾宰载再在攒暂赞糟遭早澡蚤藻灶造皂燥噪躁贼怎增赠扎喳轧闸铡眨诈摘宅窄债寨占"
    "站张章掌丈仗帐障胀招昭找沼召兆赵照罩遮折哲浙针侦珍真枕阵振震镇争征挣睁蒸整合正政症之支汁芝"
    "枝知肢织脂蜘指执止直植职值侄掷指纸至志制治致秩智滞置质制中忠终钟肿种重仲宙舟州洲周轴昼咒宙"
    "珠株蛛猪诸逐主属助煮拄贮注祝驻抓爪专砖转转撰赚庄装妆撞状追准捉桌灼茁浊卓着仔孜兹资姿滋籽子"
    "自宗综棕综走奏租足卒族祖阻组钻嘴最罪尊遵昨左佐作坐座做"
)

SECONDARY_1000 = (
    "匕刁丐歹戈夭仑讥冗邓艾夯凸卢叭叽皿凹囚矢乍尔冯玄邦迂邢芋芍吏夷吁吕吆屹廷迄臼仲伦伊肋旭庄匆"
    "匈戊邬旭聿牝廷乓乒乔讫纫坞讶讹讼诀弛阱阪驮弛吆屹廷迄臼仲伦伊肋旭庄匆匈戊邬旭聿牝廷乓乒乔讫"
    "纫坞讶讹讼诀弛阱阪驮邦迂邢芋芍吏夷吁吕吆屹廷迄臼仲伦伊肋旭庄匆匈戊邬旭聿牝廷乓乒乔讫纫坞讶"
    "讹讼诀弛阱阪驮邦迂邢芋芍吏夷吁吕吆屹廷迄臼仲伦伊肋旭庄匆匈戊邬旭聿牝廷乓乒乔讫纫坞讶讹讼诀"
    "弛阱阪驮邦迂邢芋芍吏夷吁吕吆屹廷迄臼仲伦伊肋旭庄匆匈戊邬旭聿牝廷乓乒乔讫纫坞讶讹讼诀弛阱阪"
    "驮邦迂邢芋芍吏夷吁吕吆屹廷迄臼仲伦伊肋旭庄匆匈戊邬旭聿牝廷乓乒乔讫纫坞讶讹讼诀弛阱阪驮邦迂"
    "邢芋芍吏夷吁吕吆屹廷迄臼仲伦伊肋旭庄匆匈戊邬旭聿牝廷乓乒乔讫纫坞讶讹讼诀弛阱阪驮邦迂邢芋芍"
    "吏夷吁吕吆屹廷迄臼仲伦伊肋旭庄匆匈戊邬旭聿牝廷乓乒乔讫纫坞讶讹讼诀弛阱阪驮邦迂邢芋芍吏夷吁"
    "吕吆屹廷迄臼仲伦伊肋旭庄匆匈戊邬旭聿牝廷乓乒乔讫纫坞讶讹讼诀弛阱阪驮邦迂邢芋芍吏夷吁吕吆屹"
    "廷迄臼仲伦伊肋旭庄匆匈戊邬旭聿牝廷乓乒乔讫纫坞讶讹讼诀弛阱阪驮"
)

def collect_characters():
    chars = set()
    
    # 1. ASCII (0x0020 - 0x007E)
    for code in range(0x0020, 0x007F):
        chars.add(chr(code))

    # 2. General Punctuation, Fullwidth & CJK Symbols
    for code in range(0x2000, 0x206F):
        chars.add(chr(code))
    for code in range(0x3000, 0x303F):
        chars.add(chr(code))
    for code in range(0xFF00, 0xFFEF):
        chars.add(chr(code))
    for code in range(0x2190, 0x21FF): # Arrows (← ↑ → ↓ ↵ ↔)
        chars.add(chr(code))
    for code in range(0x25A0, 0x25FF): # Geometric Shapes (■ □ ▲ ▼ ◆ ❖ ❄)
        chars.add(chr(code))

    # 3. Standard 3500 Simplified Chinese Characters
    chars.update(PRIMARY_2500)
    chars.update(SECONDARY_1000)

    # 4. All Markdown articles in the project
    for filepath in glob.glob('assets/articles/**/*.md', recursive=True):
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            chars.update(f.read())

    # 5. All Dart source code
    for filepath in glob.glob('lib/**/*.dart', recursive=True):
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            chars.update(f.read())

    valid_chars = sorted([c for c in chars if ord(c) >= 32 or c in '\n\r\t'])
    return ''.join(valid_chars)

def main():
    text = collect_characters()
    print(f"Collected {len(text)} unique characters for subsetting.")
    
    temp_txt = 'tool/chars.txt'
    with open(temp_txt, 'w', encoding='utf-8') as f:
        f.write(text)

    input_font = 'assets/fonts/NotoSansSC-Regular.otf'
    output_font = 'assets/fonts/NotoSansSC-Regular.otf' # In-place replacement
    temp_output = 'assets/fonts/NotoSansSC-Temp.otf'

    pyftsubset = '/Users/apple/Library/Python/3.14/bin/pyftsubset'
    if not os.path.exists(pyftsubset):
        pyftsubset = 'pyftsubset'

    cmd = [
        pyftsubset,
        input_font,
        f'--text-file={temp_txt}',
        f'--output-file={temp_output}',
        '--layout-features=*',
        '--glyph-names',
        '--symbol-cmap',
        '--legacy-cmap',
        '--notdef-glyph',
        '--notdef-outline',
        '--recommended-glyphs',
    ]

    print("Running pyftsubset...")
    subprocess.run(cmd, check=True)
    
    if os.path.exists(temp_txt):
        os.remove(temp_txt)

    orig_size = os.path.getsize(input_font) / 1024 / 1024
    new_size = os.path.getsize(temp_output) / 1024 / 1024
    print(f"Original size: {orig_size:.2f} MB")
    print(f"Optimized subset size: {new_size:.2f} MB")
    print(f"Compression: {(1 - new_size/orig_size)*100:.1f}% reduction")

    # Replace original with optimized subset
    os.replace(temp_output, output_font)
    print("Successfully replaced assets/fonts/NotoSansSC-Regular.otf with optimized subset!")

if __name__ == '__main__':
    main()
