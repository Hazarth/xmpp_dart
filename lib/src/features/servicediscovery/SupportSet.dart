
import 'dart:collection';

import 'package:xmpp_stone/src/features/servicediscovery/Feature.dart';
import 'package:xmpp_stone/src/features/servicediscovery/Identity.dart';

Map<String, String> XEP_LIST = {
  'urn:xmpp:mam:2': 'XEP-0313'
};

class SupportSet {
  final List<Identity> identities;
  final List<Feature> features;

  late final Set<String> _supported_xeps;

  SupportSet(this.identities, this.features) {
    this._supported_xeps = features
      .where((feature) => XEP_LIST.containsKey(feature.xmppVar))
      .map((feature) => XEP_LIST[feature.xmppVar]!)
      .toSet();
  }

  bool isXepSupported(String xep) {
    return _supported_xeps.contains(xep);
  }

}