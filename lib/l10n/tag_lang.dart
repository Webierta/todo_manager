import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/tag.dart';

class TagLang {
  static String key(BuildContext context, Tag tag) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    switch (tag.name) {
      case 'personal':
        return appLang.personal;
      case 'work':
        return appLang.work;
      case 'shopping':
        return appLang.shopping;
      case 'idea':
        return appLang.idea;
      case 'project':
        return appLang.project;
      case 'meeting':
        return appLang.meeting;
      case 'event':
        return appLang.event;
      case 'anniversary':
        return appLang.anniversary;
      case 'family':
        return appLang.family;
      case 'friends':
        return appLang.friends;
      case 'social':
        return appLang.social;
      case 'house':
        return appLang.house;
      case 'community':
        return appLang.community;
      case 'business':
        return appLang.business;
      case 'party':
        return appLang.party;
      case 'holidays':
        return appLang.holidays;
      case 'finance':
        return appLang.finance;
      case 'health':
        return appLang.health;
      case 'sport':
        return appLang.sport;
      case 'nature':
        return appLang.nature;
      case 'pet':
        return appLang.pet;
      default:
        return appLang.personal;
    }
  }
}
