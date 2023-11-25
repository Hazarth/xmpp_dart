import 'package:xmpp_stone/src/features/message_archive/MessageArchiveData.dart';
import 'package:xmpp_stone/src/elements/stanzas/MessageStanza.dart';

abstract class MessageArchiveListener {
  void onFinish(MessageArchiveResult? iqStanza);
  void onMessage(MessageStanza? message);
}
