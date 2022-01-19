import 'package:xmpp_stone/src/elements/XmppAttribute.dart';
import 'package:xmpp_stone/src/elements/forms/FieldElement.dart';
import 'package:xmpp_stone/src/elements/forms/QueryElement.dart';
import 'package:xmpp_stone/src/elements/forms/XElement.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

/// <query xmlns='http://jabber.org/protocol/disco#info'/>
///       <error code='404' type='cancel'>
///         <item-not-found xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
///         <text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'>
///           Conference room does not exist</text>
///       </error>
///
enum GroupChatroomAction {
  NONE,
  FIND_ROOM,
  FIND_RESERVED_CONFIG,
  CREATE_ROOM,
  CREATE_RESERVED_ROOM,
  JOIN_ROOM,
  ACCEPT_ROOM,
  GET_ROOM_MEMBERS,
  ADD_MEMBERS,
}

class GroupChatroomError {
  final String errorCode;
  final String errorMessage;
  final String errorType;
  final bool hasError;

  const GroupChatroomError(
      {required this.errorCode,
      required this.errorMessage,
      required this.errorType,
      required this.hasError});

  static GroupChatroomError empty() {
    return GroupChatroomError(
        errorCode: '', errorMessage: '', errorType: '', hasError: false);
  }

  static GroupChatroomError parse(AbstractStanza stanza) {
    XmppElement? errorElement = stanza.children.firstWhere(
        (element) => element!.name == 'error',
        orElse: () => XmppElement());
    XmppElement? errorItem = errorElement!.children.firstWhere(
        (element) => element!.name == 'item-not-found',
        orElse: () => XmppElement());
    XmppElement? textItem = errorElement.children.firstWhere(
        (element) => element!.name == 'text',
        orElse: () => XmppElement());

    return GroupChatroomError(
        errorCode: errorElement.getAttribute('code') != null
            ? errorElement.getAttribute('code')!.value ?? ''
            : '',
        errorMessage: textItem!.textValue ?? '',
        errorType: errorItem!.name ?? '',
        hasError: true);
  }
}

class GroupChatroom {
  final GroupChatroomAction action;
  final String roomName;
  final bool isAvailable;
  final XmppElement info;
  final GroupChatroomError error;
  final List<Jid> groupMembers;

  GroupChatroom(
      {required this.action,
      required this.roomName,
      required this.info,
      required this.isAvailable,
      required this.groupMembers,
      required this.error});
}

class InvalidGroupChatroom extends GroupChatroom {
  InvalidGroupChatroom({
    required GroupChatroomAction action,
    required GroupChatroomError error,
    required XmppElement info,
    isAvailable = false,
    roomName = '',
  }) : super(
            action: action,
            roomName: roomName,
            info: info,
            isAvailable: isAvailable,
            groupMembers: [],
            error: error);
}

class GroupChatroomConfig {
  final String name;
  final String description;
  final bool enablelogging;
  final bool changesubject;
  final bool allowinvites;
  final bool allowPm;
  final int maxUser;
  final List<String> presencebroadcast;
  final List<String> getmemberlist;
  final bool publicroom;
  final bool persistentroom;
  final bool membersonly;
  final bool passwordprotectedroom;

  const GroupChatroomConfig({
    required this.name,
    required this.description,
    required this.enablelogging,
    required this.changesubject,
    required this.allowinvites,
    required this.allowPm,
    required this.maxUser,
    required this.presencebroadcast,
    required this.getmemberlist,
    required this.publicroom,
    required this.persistentroom,
    required this.membersonly,
    required this.passwordprotectedroom,
  });

  static GroupChatroomConfig build({
    required name,
    required description,
  }) {
    return GroupChatroomConfig(
        name: name,
        description: description,
        enablelogging: false,
        changesubject: false,
        allowinvites: true,
        allowPm: true,
        maxUser: 20,
        presencebroadcast: ['moderator', 'participant', 'visitor'],
        getmemberlist: ['moderator', 'participant', 'visitor'],
        publicroom: false,
        persistentroom: true,
        membersonly: true,
        passwordprotectedroom: false);
  }
}

class GroupChatroomConfigForm {
  final GroupChatroomConfig config;
  const GroupChatroomConfigForm({required this.config});

  XmppElement buildInstantRoom() {
    QueryElement query = QueryElement();
    query.setXmlns('http://jabber.org/protocol/muc#owner');
    XElement xElement = XElement.build();
    xElement.setType(FormType.SUBMIT);
    query.addChild(xElement);
    return query;
  }

  XmppElement buildForm() {
    QueryElement query = QueryElement();
    query.setXmlns('http://jabber.org/protocol/muc#owner');
    XElement xElement = XElement.build();
    xElement.setType(FormType.SUBMIT);

    // XmppElement titleElement = XmppElement();
    // titleElement.name = 'title';
    // titleElement.textValue = 'Configuration for "coven" Room';

    // XmppElement instructionElement = XmppElement();
    // instructionElement.name = 'instructions';
    // instructionElement.textValue = 'Your room coven@macbeth has been created!';

    // xElement.addChild(titleElement);
    // xElement.addChild(instructionElement);

    xElement.addField(FieldElement.build(
        varAttr: 'FORM_TYPE',
        value: 'http://jabber.org/protocol/muc#roomconfig'));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_roomname', value: config.name));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_roomdesc', value: config.description));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_persistentroom',
        value: config.persistentroom ? '1' : '0'));
    xElement.addField(
        FieldElement.build(varAttr: 'muc#roomconfig_publicroom', value: '1'));
    xElement.addField(FieldElement.build(varAttr: 'public_list', value: '1'));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_passwordprotectedroom', value: '0'));

    xElement.addField(FieldElement.build(varAttr: 'muc#roomconfig_roomsecret'));

    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_getmemberlist', values: config.getmemberlist));

    xElement.addField(
        FieldElement.build(varAttr: 'muc#roomconfig_maxusers', value: '100'));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_whois', value: 'moderators'));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_membersonly',
        value: config.membersonly ? '1' : '0'));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_moderatedroom', value: '1'));
    xElement.addField(
        FieldElement.build(varAttr: 'members_by_default', value: '1'));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_changesubject', value: '1'));
    xElement.addField(FieldElement.build(
        varAttr: 'allow_private_messages', value: config.allowPm ? '1' : '0'));
    xElement
        .addField(FieldElement.build(varAttr: 'allow_query_users', value: '1'));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_allowinvites',
        value: config.allowinvites ? '1' : '0'));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_allowmultisessions', value: '1'));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_allowvisitorstatus', value: '1'));
    xElement.addField(FieldElement.build(
        varAttr: 'muc#roomconfig_allowvisitornickchange', value: '1'));
    query.addChild(xElement);
    return query;
  }
}

/*

<?xml version="1.0" encoding="UTF-8"?>
<xmpp_stone>
   <iq from="test2b3626e00-7789-11ec-b82f-6dc971962c7e@conference.dev.xmpp.hiapp-chat.com" to="621271021001@dev.xmpp.hiapp-chat.com/iOS-D9BDC54B-0B61-410B-8FBB-633B3196A8C7-cb8cf018-5195-47fd-9785-3ab33511a6ab" id="HJPLWRKPU" type="result">
      <query xmlns="http://jabber.org/protocol/muc#owner">
         <instructions>You need an x:data capable client to configure room</instructions>
         <x xmlns="jabber:x:data" type="form">
            <title>Configuration of room test2b3626e00-7789-11ec-b82f-6dc971962c7e@conference.dev.xmpp.hiapp-chat.com</title>
            <field type="hidden" var="FORM_TYPE">
               <value>http://jabber.org/protocol/muc#roomconfig</value>
            </field>
            <field type="text-single" label="Room title" var="muc#roomconfig_roomname">
               <value />
            </field>
            <field type="text-single" label="Room description" var="muc#roomconfig_roomdesc">
               <value />
            </field>
            <field type="boolean" label="Make room persistent" var="muc#roomconfig_persistentroom">
               <value>0</value>
            </field>
            <field type="boolean" label="Make room public searchable" var="muc#roomconfig_publicroom">
               <value>1</value>
            </field>
            <field type="boolean" label="Make participants list public" var="public_list">
               <value>1</value>
            </field>
            <field type="boolean" label="Make room password protected" var="muc#roomconfig_passwordprotectedroom">
               <value>0</value>
            </field>
            <field type="text-private" label="Password" var="muc#roomconfig_roomsecret">
               <value />
            </field>
            <field type="list-multi" label="Roles and affiliations that may retrieve member list" var="muc#roomconfig_getmemberlist">
               <value>moderator</value>
               <value>participant</value>
               <value>visitor</value>
               <option label="moderator">
                  <value>moderator</value>
               </option>
               <option label="participant">
                  <value>participant</value>
               </option>
               <option label="visitor">
                  <value>visitor</value>
               </option>
            </field>
            <field type="list-single" label="Maximum Number of Occupants" var="muc#roomconfig_maxusers">
               <value>200</value>
               <option label="5">
                  <value>5</value>
               </option>
               <option label="10">
                  <value>10</value>
               </option>
               <option label="20">
                  <value>20</value>
               </option>
               <option label="30">
                  <value>30</value>
               </option>
               <option label="50">
                  <value>50</value>
               </option>
               <option label="100">
                  <value>100</value>
               </option>
               <option label="200">
                  <value>200</value>
               </option>
               <option label="300">
                  <value>300</value>
               </option>
            </field>
            <field type="list-single" label="Present real Jabber IDs to" var="muc#roomconfig_whois">
               <value>moderators</value>
               <option label="moderators only">
                  <value>moderators</value>
               </option>
               <option label="anyone">
                  <value>anyone</value>
               </option>
            </field>
            <field type="boolean" label="Make room members-only" var="muc#roomconfig_membersonly">
               <value>0</value>
            </field>
            <field type="boolean" label="Make room moderated" var="muc#roomconfig_moderatedroom">
               <value>1</value>
            </field>
            <field type="boolean" label="Default users as participants" var="members_by_default">
               <value>1</value>
            </field>
            <field type="boolean" label="Allow users to change the subject" var="muc#roomconfig_changesubject">
               <value>1</value>
            </field>
            <field type="boolean" label="Allow users to send private messages" var="allow_private_messages">
               <value>1</value>
            </field>
            <field type="boolean" label="Allow users to query other users" var="allow_query_users">
               <value>1</value>
            </field>
            <field type="boolean" label="Allow users to send invites" var="muc#roomconfig_allowinvites">
               <value>0</value>
            </field>
            <field type="boolean" label="Allow users to enter room with multiple sessions" var="muc#roomconfig_allowmultisessions">
               <value>1</value>
            </field>
            <field type="boolean" label="Allow visitors to send status text in presence updates" var="muc#roomconfig_allowvisitorstatus">
               <value>1</value>
            </field>
            <field type="boolean" label="Allow visitors to change nickname" var="muc#roomconfig_allowvisitornickchange">
               <value>1</value>
            </field>
         </x>
      </query>
   </iq>
</xmpp_stone>

*/

class JoinGroupChatroomConfig {
  final String affiliation;
  final String role;
  final DateTime historySince;
  final bool shouldGetHistory;

  const JoinGroupChatroomConfig({
    required this.affiliation,
    required this.role,
    required this.historySince,
    required this.shouldGetHistory,
  });

  static JoinGroupChatroomConfig build({
    required DateTime historySince,
    required bool shouldGetHistory,
  }) {
    return JoinGroupChatroomConfig(
      affiliation: 'member',
      role: 'participant',
      historySince: historySince,
      shouldGetHistory: shouldGetHistory,
    );
  }

  XmppElement buildJoinRoomXElement() {
    XElement xElement = XElement.build();
    xElement.addAttribute(
        XmppAttribute('xmlns', 'http://jabber.org/protocol/muc#user'));

    XmppElement itemRole = XmppElement();
    itemRole.name = 'item';
    itemRole.addAttribute(XmppAttribute('affiliation', affiliation));
    itemRole.addAttribute(XmppAttribute('role', role));
    xElement.addChild(itemRole);

    return xElement;
  }

  XmppElement buildAcceptRoomXElement() {
    XElement xElement = XElement.build();
    xElement
        .addAttribute(XmppAttribute('xmlns', 'http://jabber.org/protocol/muc'));
    return xElement;
  }
}

class AcceptGroupChatroomInvitationConfig {
  XmppElement buildAcceptRoomXElement() {
    XElement xElement = XElement.build();
    xElement
        .addAttribute(XmppAttribute('xmlns', 'http://jabber.org/protocol/muc'));
    return xElement;
  }
}
