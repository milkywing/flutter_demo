class WrongItem {
  WrongItem(Map<String, dynamic> json)
      : tid = json['tid'],
        name = json['name'],
        questionIds = json['questionIds']?.cast<int>() ?? [];

  WrongItem.fromJson(Map<String, dynamic> json) : this(json);

  /// 试卷编号
  final int tid;

  /// 试卷标题
  final String name;

  /// 错题编号集
  final List<int> questionIds;

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('\n==========>WrongItem<==========\n');
    sb.write('"tid":$tid,\n');
    sb.write('"name":`$name`,\n');
    sb.write('"questionIds":$questionIds,\n');
    return sb.toString();
  }
}

// void main(List<String> args) {
//   Map<String, dynamic> json = {
//     'tid': 233,
//     'name': '2020年全国硕士研究生入学统一考试',
//     'questionIds': [1, 2, 3],
//   };
//   print(WrongItem.fromJson(json));
// }
