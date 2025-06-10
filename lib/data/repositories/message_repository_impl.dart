import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../api/message_api.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageApi messageApi;

  MessageRepositoryImpl(this.messageApi);

  @override
  Future<Message?> sendMessage(Message message) async {
    return await messageApi.sendMessage(message);
  }
}