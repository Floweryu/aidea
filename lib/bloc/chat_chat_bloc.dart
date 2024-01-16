import 'package:askaide/helper/constant.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/chat_message_repo.dart';
import 'package:askaide/repo/model/chat_history.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'chat_chat_event.dart';
part 'chat_chat_state.dart';

class ChatChatBloc extends Bloc<ChatChatEvent, ChatChatState> {
  final ChatMessageRepository _chatMessageRepository;
  ChatChatBloc(this._chatMessageRepository) : super(ChatChatInitial()) {
    // 加载最近的历史记录
    on<ChatChatLoadRecentHistories>((event, emit) async {
      final histories = await _chatMessageRepository.recentChatHistories(
        chatAnywhereRoomId,
        4,
        userId: APIServer().localUserID(),
      );

      var examples = await APIServer().example('openai:$defaultChatModel');
      examples = <ChatExample>[];
      final lists = [
        {
          "title": "嗓子痒咳嗽吃什么药效果快？",
          "models": ["openai:gpt-", "文心千帆:", "讯飞星火:"]
        },
        {
          "title": "感冒好了为何咳嗽老不好？",
          "models": ["openai:gpt-", "文心千帆:", "讯飞星火:"]
        },
        {
          "title": "为什么孩子会抑郁？",
          "models": ["openai:gpt-", "文心千帆:", "讯飞星火:"]
        },
        {
          "title": "冬季如何预防流感？",
          "models": ["openai:gpt-", "文心千帆:", "讯飞星火:"]
        },
        {
          "title": "肚子不舒服怎么办？",
          "models": ["openai:gpt-", "文心千帆:", "讯飞星火:"]
        },
        {
          "title": "发烧吃什么药？如何降温？",
          "models": ["openai:gpt-", "文心千帆:", "讯飞星火:"]
        },
      ];

      for (var example in lists) {
        examples.add(ChatExample(
          example['title'].toString(),
          models: ((example['models'] ?? []) as List<dynamic>)
              .map((e) => e.toString())
              .toList(),
        ));
      }
      
      // examples 随机排序
      examples.shuffle();

      emit(ChatChatRecentHistoriesLoaded(
        histories: histories,
        examples: examples,
      ));
    });

    // 删除历史记录
    on<ChatChatDeleteHistory>((event, emit) async {
      await _chatMessageRepository.deleteChatHistory(event.chatId);
      add(ChatChatLoadRecentHistories());
    });
  }
}
