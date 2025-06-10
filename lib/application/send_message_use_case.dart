import '../domain/entities/message.dart';
import '../domain/repositories/message_repository.dart';

class SendMessageUseCase {
  final MessageRepository messageRepository;

  SendMessageUseCase(this.messageRepository);

  Future<Message?> sendMessage(Message message) async {
    try {
      final Message? messageResponse = await messageRepository.sendMessage(message);
      return messageResponse;
    } catch (e) {
      return null;
    }
  }
}