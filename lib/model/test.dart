import './question.dart';

class Test {
  Test(Map<String, dynamic> json)
      : tid = json['tid'],
        time = json['time'],
        name = json['name'],
        description = json['description'],
        subject = json['subject'],
        subjectId = json['subjectId'],
        publisher = json['publisher'],
        publisherId = json['publisherId'],
        isFree = json['isFree'],
        price = json['price'] {
    if (json['questions'] is List) {
      questions = (json['questions'] as List<Map<String, dynamic>>)
          .map((e) => new Question(e))
          .toList();
    }
  }

  Test.fromJson(Map<String, dynamic> json) : this(json);

  /// 试卷编号
  final int tid;

  /// 出题时间
  final String time;

  /// 试卷标题
  final String name;

  /// 试卷描述
  final String description;

  /// 试卷科目
  final String subject;

  final int subjectId;

  /// 出题者
  final String publisher;

  final int publisherId;

  /// 是否免费
  final bool isFree;

  /// 售价
  final double price;

  /// 试题
  List<Question> questions = [];

  Map<String, dynamic> toJson() => {
        'tid': tid,
        'time': time,
        'name': name,
        'description': description,
        'subject': subject,
        'subjectId': subjectId,
        'publisher': publisher,
        'publisherId': publisherId,
        'isFree': isFree,
        'price': price,
        'questions': questions,
      };

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('============>Test<============\n');
    sb.write('"tid":$tid,\n');
    sb.write('"time":`$time`,\n');
    sb.write('"name":`$name`,\n');
    sb.write('"description":`$description`,\n');
    sb.write('"subject":`$subject`,\n');
    sb.write('"publisher":`$publisher`,\n');
    sb.write('"isFree":$isFree,\n');
    sb.write('"price":$price,\n');
    sb.write('"questions": $questions,\n');
    return sb.toString();
  }
}

// void main(List<String> args) {
//   Map<String, dynamic> json = {
//     'tid': 233,
//     'time': '2020-11-11',
//     'name': '2020年全国硕士研究生入学统一考试（政治）',
//     'description': '2020年考研政治',
//     'subject': '政治',
//     'subjectId': 233,
//     'publisher': '教育部',
//     'publisherId': 233,
//     'isFree': true,
//     'price': 0.0,
//     'questions': [
//       {
//         'qid': 114514,
//         'type': 1,
//         'chapter': '物质世界和实践——哲学概述',
//         'content': '在维可的回忆中，伊尔缪伊一共使用了多少个“欲望的摇篮”？',
//         'choices': ['两个', '三个', '四个', '五个'],
//         'correctChoices': [0, 1],
//         'correctBlank': '我的世界',
//       },
//     ],
//   };
//   Test test = new Test(json);
//   print(test);
// }
