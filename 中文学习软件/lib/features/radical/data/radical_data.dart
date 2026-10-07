import '../../../data/models/models.dart';
import '../models/radical_model.dart';

/// 汉字部首数据 - 214个传统部首
/// 按GB 13000.1收录的214个部首编排
class RadicalData {
  /// 获取所有部首（按笔画数分组）
  static Map<int, List<Radical>> getAllRadicals() {
    return _radicals;
  }

  /// 根据部首字符获取部首信息
  static Radical? getByCharacter(String char) {
    for (final group in _radicals.values) {
      for (final radical in group) {
        if (radical.character == char) {
          return radical;
        }
      }
    }
    return null;
  }

  /// 获取部首总数量
  static int get totalCount {
    int count = 0;
    for (final group in _radicals.values) {
      count += group.length;
    }
    return count;
  }
}

/// 常用部首数据（按笔画数分组）
/// 包含 GB 13000.1 的214部首中常用的约100个
final Map<int, List<Radical>> _radicals = {
  // 1画部首
  1: [
    const Radical(character: '一', name: '横', strokes: 1, position: 'any', description: '横向笔画，表示天地分界或数字一'),
    const Radical(character: '丨', name: '竖', strokes: 1, position: 'any', description: '纵向笔画，表示连接上下'),
    const Radical(character: '丶', name: '点', strokes: 1, position: 'any', description: '点笔，标志性笔画'),
    const Radical(character: '丿', name: '撇', strokes: 1, position: 'any', description: '向左下撇出'),
    const Radical(character: '乙', name: '乙', strokes: 1, position: 'any', description: '弯曲笔画，如乙字'),
    const Radical(character: '亅', name: '亅', strokes: 1, position: 'any', description: '弯钩笔画'),
  ],
  // 2画部首
  2: [
    const Radical(character: '二', name: '二', strokes: 2, position: 'any', description: '两横，表示数字二'),
    const Radical(character: '十', name: '十', strokes: 2, position: 'any', description: '纵横相交，表示数目'),
    const Radical(character: '厂', name: '厂', strokes: 2, position: 'left', description: '悬崖形，表示山崖'),
    const Radical(character: '匚', name: '三框', strokes: 2, position: 'surround', description: '三面包围的框'),
    const Radical(character: '匸', name: '区', strokes: 2, position: 'surround', description: '遮掩、藏匿'),
    const Radical(character: '卜', name: '卜', strokes: 2, position: 'right', description: '占卜用的龟甲裂纹'),
    const Radical(character: '卩', name: '节', strokes: 2, position: 'any', description: '篆刻用的符节'),
    const Radical(character: '刂', name: '立刀', strokes: 2, position: 'right', description: '刀、剑等利器'),
    const Radical(character: '力', name: '力', strokes: 2, position: 'any', description: '力气、力量'),
    const Radical(character: '又', name: '又', strokes: 2, position: 'any', description: '右手，表示重复'),
  ],
  // 3画部首
  3: [
    const Radical(character: '口', name: '口', strokes: 3, position: 'any', description: '人口、嘴巴'),
    const Radical(character: '囗', name: '围', strokes: 3, position: 'surround', description: '四面围住'),
    const Radical(character: '土', name: '土', strokes: 3, position: 'any', description: '泥土、土地'),
    const Radical(character: '士', name: '士', strokes: 3, position: 'any', description: '读书人、士兵'),
    const Radical(character: '夂', name: '冬', strokes: 3, position: 'top', description: '冬天的象形'),
    const Radical(character: '夊', name: '冬', strokes: 3, position: 'bottom', description: '缓慢行走'),
    const Radical(character: '夕', name: '夕', strokes: 3, position: 'any', description: '傍晚、夜晚'),
    const Radical(character: '大', name: '大', strokes: 3, position: 'any', description: '大人、肥大'),
    const Radical(character: '女', name: '女', strokes: 3, position: 'any', description: '女性、母亲'),
    const Radical(character: '子', name: '子', strokes: 3, position: 'any', description: '儿子、子女'),
    const Radical(character: '宀', name: '宝盖', strokes: 3, position: 'top', description: '房屋、覆盖'),
    const Radical(character: '寸', name: '寸', strokes: 3, position: 'any', description: '尺寸、计量'),
    const Radical(character: '小', name: '小', strokes: 3, position: 'any', description: '大小的小'),
    const Radical(character: '尢', name: '尣', strokes: 3, position: 'any', description: '跛脚的象形'),
    const Radical(character: '尸', name: '尸', strokes: 3, position: 'top', description: '人体、俯卧'),
    const Radical(character: '屮', name: '屮', strokes: 3, position: 'any', description: '草初生形'),
    const Radical(character: '山', name: '山', strokes: 3, position: 'any', description: '山岳、山峰'),
    const Radical(character: '川', name: '川', strokes: 3, position: 'any', description: '河流'),
    const Radical(character: '工', name: '工', strokes: 3, position: 'any', description: '工具、工作'),
    const Radical(character: '己', name: '己', strokes: 3, position: 'any', description: '自身、天干第六'),
    const Radical(character: '巾', name: '巾', strokes: 3, position: 'any', description: '佩巾、旗帜'),
  ],
  // 4画部首
  4: [
    const Radical(character: '干', name: '干', strokes: 4, position: 'any', description: '盾牌、干犯'),
    const Radical(character: '幺', name: '幺', strokes: 4, position: 'any', description: '细小、丝线'),
    const Radical(character: '广', name: '广', strokes: 4, position: 'left', description: '依山崖建的屋'),
    const Radical(character: '廴', name: '建', strokes: 4, position: 'left', description: '行走、延展'),
    const Radical(character: '廾', name: '廿', strokes: 4, position: 'any', description: '两手捧物'),
    const Radical(character: '廿', name: '廿', strokes: 4, position: 'any', description: '二十'),
    const Radical(character: '弓', name: '弓', strokes: 4, position: 'any', description: '弓箭'),
    const Radical(character: '彐', name: '彐', strokes: 4, position: 'any', description: '手执扫帚'),
    const Radical(character: '彡', name: '三撇', strokes: 4, position: 'right', description: '胡须、须毛'),
    const Radical(character: '彳', name: '双人', strokes: 4, position: 'left', description: '小步走路'),
    const Radical(character: '心', name: '心', strokes: 4, position: 'bottom', description: '心脏、内心'),
    const Radical(character: '戈', name: '戈', strokes: 4, position: 'any', description: '兵器、战争'),
    const Radical(character: '戸', name: '户', strokes: 4, position: 'any', description: '单扇门'),
    const Radical(character: '手', name: '手', strokes: 4, position: 'any', description: '手掌、手臂'),
    const Radical(character: '支', name: '支', strokes: 4, position: 'any', description: '支撑、分支'),
    const Radical(character: '攴', name: '扑', strokes: 4, position: 'left', description: '敲击、手持器械'),
    const Radical(character: '文', name: '文', strokes: 4, position: 'any', description: '文字、花纹'),
    const Radical(character: '斗', name: '斗', strokes: 4, position: 'any', description: '量器、战斗'),
    const Radical(character: '斤', name: '斤', strokes: 4, position: 'any', description: '斧头'),
    const Radical(character: '方', name: '方', strokes: 4, position: 'any', description: '方形、方向'),
    const Radical(character: '无', name: '无', strokes: 4, position: 'any', description: '没有'),
    const Radical(character: '日', name: '日', strokes: 4, position: 'any', description: '太阳、日子'),
    const Radical(character: '曰', name: '曰', strokes: 4, position: 'any', description: '说、叫做'),
    const Radical(character: '月', name: '月', strokes: 4, position: 'any', description: '月亮、肉月'),
    const Radical(character: '木', name: '木', strokes: 4, position: 'any', description: '树木'),
    const Radical(character: '欠', name: '欠', strokes: 4, position: 'right', description: '欠缺、呵欠'),
    const Radical(character: '止', name: '止', strokes: 4, position: 'any', description: '停止、脚'),
    const Radical(character: '歹', name: '歹', strokes: 4, position: 'any', description: '残骨、坏'),
    const Radical(character: '殳', name: '殳', strokes: 4, position: 'any', description: '兵器、拍击'),
    const Radical(character: '毋', name: '毋', strokes: 4, position: 'any', description: '不要、母亲'),
    const Radical(character: '比', name: '比', strokes: 4, position: 'any', description: '比较、并列'),
    const Radical(character: '毛', name: '毛', strokes: 4, position: 'any', description: '毛发'),
    const Radical(character: '氏', name: '氏', strokes: 4, position: 'any', description: '氏族'),
    const Radical(character: '气', name: '气', strokes: 4, position: 'any', description: '气体、气息'),
    const Radical(character: '水', name: '水', strokes: 4, position: 'any', description: '水'),
    const Radical(character: '火', name: '火', strokes: 4, position: 'bottom', description: '火焰'),
    const Radical(character: '爪', name: '爪', strokes: 4, position: 'any', description: '爪子、手爪'),
    const Radical(character: '父', name: '父', strokes: 4, position: 'any', description: '父亲'),
    const Radical(character: '爻', name: '爻', strokes: 4, position: 'any', description: '八卦符号'),
    const Radical(character: '爿', name: '爿', strokes: 4, position: 'any', description: '劈开的竹木'),
    const Radical(character: '片', name: '片', strokes: 4, position: 'any', description: '木片、片段'),
    const Radical(character: '牙', name: '牙', strokes: 4, position: 'any', description: '牙齿'),
    const Radical(character: '牛', name: '牛', strokes: 4, position: 'any', description: '牛'),
    const Radical(character: '犬', name: '犬', strokes: 4, position: 'right', description: '狗'),
  ],
  // 5画部首
  5: [
    const Radical(character: '玄', name: '玄', strokes: 5, position: 'any', description: '黑红色、玄妙'),
    const Radical(character: '玉', name: '玉', strokes: 5, position: 'any', description: '玉石'),
    const Radical(character: '瓜', name: '瓜', strokes: 5, position: 'any', description: '瓜果'),
    const Radical(character: '瓦', name: '瓦', strokes: 5, position: 'any', description: '陶瓦'),
    const Radical(character: '甘', name: '甘', strokes: 5, position: 'any', description: '甘甜'),
    const Radical(character: '生', name: '生', strokes: 5, position: 'any', description: '生长'),
    const Radical(character: '用', name: '用', strokes: 5, position: 'any', description: '使用'),
    const Radical(character: '田', name: '田', strokes: 5, position: 'any', description: '农田'),
    const Radical(character: '疋', name: '疋', strokes: 5, position: 'any', description: '脚、品级'),
    const Radical(character: '疒', name: '病', strokes: 5, position: 'left', description: '疾病'),
    const Radical(character: '癶', name: '癶', strokes: 5, position: 'top', description: '足跗'),
    const Radical(character: '白', name: '白', strokes: 5, position: 'any', description: '白色'),
    const Radical(character: '皮', name: '皮', strokes: 5, position: 'any', description: '皮肤'),
    const Radical(character: '皿', name: '皿', strokes: 5, position: 'any', description: '器皿'),
    const Radical(character: '目', name: '目', strokes: 5, position: 'any', description: '眼睛'),
    const Radical(character: '矛', name: '矛', strokes: 5, position: 'any', description: '长矛'),
    const Radical(character: '矢', name: '矢', strokes: 5, position: 'any', description: '箭'),
    const Radical(character: '石', name: '石', strokes: 5, position: 'any', description: '石头'),
    const Radical(character: '示', name: '示', strokes: 5, position: 'left', description: '神示'),
    const Radical(character: '禸', name: '禸', strokes: 5, position: 'any', description: '兽足'),
    const Radical(character: '禾', name: '禾', strokes: 5, position: 'any', description: '禾苗'),
    const Radical(character: '穴', name: '穴', strokes: 5, position: 'top', description: '洞穴'),
    const Radical(character: '立', name: '立', strokes: 5, position: 'any', description: '站立'),
  ],
  // 6画部首
  6: [
    const Radical(character: '竹', name: '竹', strokes: 6, position: 'top', description: '竹子'),
    const Radical(character: '米', name: '米', strokes: 6, position: 'any', description: '大米'),
    const Radical(character: '糸', name: '绞丝', strokes: 6, position: 'left', description: '丝线'),
    const Radical(character: '缶', name: '缶', strokes: 6, position: 'any', description: '陶罐'),
    const Radical(character: '网', name: '网', strokes: 6, position: 'top', description: '网罟'),
    const Radical(character: '羊', name: '羊', strokes: 6, position: 'any', description: '羊'),
    const Radical(character: '羽', name: '羽', strokes: 6, position: 'any', description: '羽毛'),
    const Radical(character: '老', name: '老', strokes: 6, position: 'any', description: '老人'),
    const Radical(character: '而', name: '而', strokes: 6, position: 'any', description: '而且'),
    const Radical(character: '耒', name: '耒', strokes: 6, position: 'left', description: '农具'),
    const Radical(character: '耳', name: '耳', strokes: 6, position: 'any', description: '耳朵'),
    const Radical(character: '聿', name: '聿', strokes: 6, position: 'any', description: '笔'),
    const Radical(character: '肉', name: '肉', strokes: 6, position: 'any', description: '肌肉'),
    const Radical(character: '臣', name: '臣', strokes: 6, position: 'any', description: '臣子'),
    const Radical(character: '自', name: '自', strokes: 6, position: 'any', description: '自己'),
    const Radical(character: '至', name: '至', strokes: 6, position: 'any', description: '到达'),
    const Radical(character: '臼', name: '臼', strokes: 6, position: 'any', description: '舂米'),
    const Radical(character: '舌', name: '舌', strokes: 6, position: 'any', description: '舌头'),
    const Radical(character: '舛', name: '舛', strokes: 6, position: 'any', description: '相违'),
    const Radical(character: '舟', name: '舟', strokes: 6, position: 'any', description: '小船'),
    const Radical(character: '艮', name: '艮', strokes: 6, position: 'any', description: '八卦'),
    const Radical(character: '色', name: '色', strokes: 6, position: 'any', description: '颜色'),
    const Radical(character: '艸', name: '草', strokes: 6, position: 'top', description: '草本'),
    const Radical(character: '虍', name: '虎', strokes: 6, position: 'top', description: '虎纹'),
    const Radical(character: '虫', name: '虫', strokes: 6, position: 'any', description: '昆虫'),
    const Radical(character: '血', name: '血', strokes: 6, position: 'any', description: '血液'),
    const Radical(character: '行', name: '行', strokes: 6, position: 'left', description: '行走'),
    const Radical(character: '衣', name: '衣', strokes: 6, position: 'any', description: '衣服'),
    const Radical(character: '襤', name: '补', strokes: 6, position: 'left', description: '修补'),
  ],
  // 7画部首
  7: [
    const Radical(character: '言', name: '言', strokes: 7, position: 'left', description: '言语'),
    const Radical(character: '谷', name: '谷', strokes: 7, position: 'any', description: '山谷'),
    const Radical(character: '豆', name: '豆', strokes: 7, position: 'any', description: '豆子'),
    const Radical(character: '豕', name: '豕', strokes: 7, position: 'any', description: '猪'),
    const Radical(character: '豸', name: '豸', strokes: 7, position: 'any', description: '野兽'),
    const Radical(character: '貝', name: '贝', strokes: 7, position: 'bottom', description: '贝壳、钱币'),
    const Radical(character: '赤', name: '赤', strokes: 7, position: 'any', description: '红色'),
    const Radical(character: '走', name: '走', strokes: 7, position: 'bottom', description: '行走'),
    const Radical(character: '足', name: '足', strokes: 7, position: 'any', description: '脚'),
    const Radical(character: '身', name: '身', strokes: 7, position: 'any', description: '身体'),
    const Radical(character: '車', name: '车', strokes: 7, position: 'any', description: '车辆'),
    const Radical(character: '辛', name: '辛', strokes: 7, position: 'any', description: '辛辣'),
    const Radical(character: '辰', name: '辰', strokes: 7, position: 'any', description: '时辰'),
    const Radical(character: '辵', name: '辶', strokes: 7, position: 'bottom', description: '行走'),
    const Radical(character: '邑', name: '阝(右)', strokes: 7, position: 'right', description: '城邑'),
    const Radical(character: '酉', name: '酉', strokes: 7, position: 'any', description: '酒坛'),
    const Radical(character: '釆', name: '釆', strokes: 7, position: 'any', description: '辨别'),
  ],
  // 8画部首
  8: [
    const Radical(character: '金', name: '金', strokes: 8, position: 'left', description: '金属'),
    const Radical(character: '長', name: '长', strokes: 8, position: 'top', description: '长短'),
    const Radical(character: '門', name: '门', strokes: 8, position: 'left', description: '门户'),
    const Radical(character: '阜', name: '阝(左)', strokes: 8, position: 'left', description: '土山'),
    const Radical(character: '隶', name: '隶', strokes: 8, position: 'any', description: '附属'),
    const Radical(character: '隹', name: '隹', strokes: 8, position: 'right', description: '短尾鸟'),
    const Radical(character: '雨', name: '雨', strokes: 8, position: 'top', description: '雨水'),
    const Radical(character: '靑', name: '青', strokes: 8, position: 'any', description: '青色'),
    const Radical(character: '非', name: '非', strokes: 8, position: 'any', description: '是非'),
  ],
  // 9画部首
  9: [
    const Radical(character: '面', name: '面', strokes: 9, position: 'any', description: '面孔'),
    const Radical(character: '革', name: '革', strokes: 9, position: 'left', description: '皮革'),
    const Radical(character: '韋', name: '韦', strokes: 9, position: 'any', description: '皮革'),
    const Radical(character: '韭', name: '韭', strokes: 9, position: 'any', description: '韭菜'),
    const Radical(character: '音', name: '音', strokes: 9, position: 'any', description: '声音'),
    const Radical(character: '頁', name: '页', strokes: 9, position: 'any', description: '书页'),
    const Radical(character: '風', name: '风', strokes: 9, position: 'surround', description: '风力'),
    const Radical(character: '飛', name: '飞', strokes: 9, position: 'top', description: '飞翔'),
    const Radical(character: '食', name: '食', strokes: 9, position: 'left', description: '食物'),
    const Radical(character: '首', name: '首', strokes: 9, position: 'top', description: '首领'),
    const Radical(character: '香', name: '香', strokes: 9, position: 'bottom', description: '香味'),
  ],
  // 10画部首
  10: [
    const Radical(character: '馬', name: '马', strokes: 10, position: 'left', description: '马匹'),
    const Radical(character: '骨', name: '骨', strokes: 10, position: 'any', description: '骨骼'),
    const Radical(character: '高', name: '高', strokes: 10, position: 'any', description: '高低'),
    const Radical(character: '髟', name: '髟', strokes: 10, position: 'top', description: '长发'),
    const Radical(character: '鬥', name: '斗', strokes: 10, position: 'left', description: '争斗'),
    const Radical(character: '鬯', name: '鬯', strokes: 10, position: 'top', description: '香草'),
    const Radical(character: '鬲', name: '鬲', strokes: 10, position: 'any', description: '炊具'),
  ],
  // 11画部首
  11: [
    const Radical(character: '魚', name: '鱼', strokes: 11, position: 'top', description: '鱼类'),
    const Radical(character: '鳥', name: '鸟', strokes: 11, position: 'top', description: '鸟类'),
    const Radical(character: '鹵', name: '卤', strokes: 11, position: 'any', description: '卤水'),
    const Radical(character: '鹿', name: '鹿', strokes: 11, position: 'any', description: '鹿'),
    const Radical(character: '麥', name: '麦', strokes: 11, position: 'left', description: '麦子'),
    const Radical(character: '麻', name: '麻', strokes: 11, position: 'top', description: '麻'),
  ],
  // 12画部首
  12: [
    const Radical(character: '黃', name: '黄', strokes: 12, position: 'any', description: '黄色'),
    const Radical(character: '黍', name: '黍', strokes: 12, position: 'any', description: '黄米'),
    const Radical(character: '黑', name: '黑', strokes: 12, position: 'any', description: '黑色'),
    const Radical(character: '黹', name: '黹', strokes: 12, position: 'any', description: '针线'),
  ],
  // 13画部首
  13: [
    const Radical(character: '黽', name: '黽', strokes: 13, position: 'top', description: '蛙类'),
    const Radical(character: '鼎', name: '鼎', strokes: 13, position: 'any', description: '青铜鼎'),
    const Radical(character: '鼓', name: '鼓', strokes: 13, position: 'left', description: '鼓'),
    const Radical(character: '鼠', name: '鼠', strokes: 13, position: 'top', description: '老鼠'),
  ],
  // 14画部首
  14: [
    const Radical(character: '鼻', name: '鼻', strokes: 14, position: 'top', description: '鼻子'),
    const Radical(character: '齊', name: '齐', strokes: 14, position: 'top', description: '整齐'),
  ],
  // 17画部首
  17: [
    const Radical(character: '龠', name: '龠', strokes: 17, position: 'any', description: '竹笛'),
  ],
};
