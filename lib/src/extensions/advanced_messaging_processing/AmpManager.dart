// Inspired by this XEP-0079: https://xmpp.org/extensions/xep-0079.html
import 'package:xmpp_stone_obelisk/src/Connection.dart';
import 'package:xmpp_stone_obelisk/src/features/servicediscovery/AmpNegotiator.dart';

class AmpManager {
  static Map<Connection, AmpManager> instances = <Connection, AmpManager>{};

  static AmpManager getInstance(Connection connection) {
    var manager = instances[connection];
    if (manager == null) {
      manager = AmpManager(connection);
      instances[connection] = manager;
    }

    return manager;
  }

  final Connection _connection;

  AmpManager(this._connection);

  bool isReady() {
    return _connection.connectionNegotatiorManager
        .isNegotiateorSupport((element) => element is AmpNegotiator);
  }
}