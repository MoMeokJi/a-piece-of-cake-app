import 'package:cake/ui/common_components/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String _visibleText(WidgetTester tester) {
  final text = tester.widget<Text>(find.byType(Text));
  final span = text.textSpan! as TextSpan;
  // 첫 자식이 드러난 글자, 둘째 자식이 아직 투명한 글자
  return (span.children!.first as TextSpan).text!;
}

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('animated 봇 말풍선은 글자를 한 자씩 드러낸다', (tester) async {
    await tester.pumpWidget(
      host(const ChatBubble(message: '안녕하세요', isUser: false, animated: true)),
    );
    expect(_visibleText(tester), '');

    await tester.pump(const Duration(milliseconds: 120));
    expect(_visibleText(tester), '안녕');

    await tester.pump(const Duration(seconds: 1));
    expect(_visibleText(tester), '안녕하세요');
  });

  testWidgets('문장이 바뀌면 처음부터 다시 친다', (tester) async {
    await tester.pumpWidget(
      host(const ChatBubble(message: '첫 질문', isUser: false, animated: true)),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(_visibleText(tester), '첫 질문');

    await tester.pumpWidget(
      host(const ChatBubble(message: '바뀐 질문', isUser: false, animated: true)),
    );
    expect(_visibleText(tester), '');
    await tester.pump(const Duration(seconds: 1));
    expect(_visibleText(tester), '바뀐 질문');
  });

  testWidgets('animated가 아니면 바로 전체를 보여준다', (tester) async {
    await tester.pumpWidget(
      host(const ChatBubble(message: '그대로', isUser: false)),
    );
    expect(find.text('그대로'), findsOneWidget);
  });
}
