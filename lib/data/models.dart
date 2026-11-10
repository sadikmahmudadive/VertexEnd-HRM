import 'package:flutter/material.dart';

import '../core/widgets/components.dart';

class Person {
  const Person({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.dept,
    required this.presence,
    required this.status,
    this.variant = 0,
  });
  final String id;
  final String name;
  final String initials;
  final String role;
  final String dept;
  final Presence presence;
  final String status;
  final int variant;
}

class LeaveType {
  const LeaveType(this.id, this.name, this.color, this.left, this.total);
  final String id;
  final String name;
  final Color color;
  final int left;
  final int total;
}

class LeaveEntry {
  const LeaveEntry({
    required this.day,
    required this.month,
    required this.title,
    required this.sub,
    required this.status,
    required this.tone,
  });
  final String day;
  final String month;
  final String title;
  final String sub;
  final String status;
  final Tone tone;
}

enum NotifKind { request, payslip, announcement, approved, reminder, profile }

enum NotifAction { approve, link, acknowledge }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.group,
    required this.kind,
    required this.text,
    required this.sub,
    required this.time,
    required this.unread,
    this.action,
    this.result = '',
  });
  final int id;
  final String group;
  final NotifKind kind;
  final String text;
  final String sub;
  final String time;
  final bool unread;
  final NotifAction? action;
  final String result;

  AppNotification copyWith({bool? unread, String? result}) => AppNotification(
        id: id,
        group: group,
        kind: kind,
        text: text,
        sub: sub,
        time: time,
        unread: unread ?? this.unread,
        action: action,
        result: result ?? this.result,
      );
}

class ApprovalRequest {
  const ApprovalRequest({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.type,
    required this.dates,
    required this.length,
    required this.reason,
    required this.impact,
    this.warn = false,
    this.variant = 0,
  });
  final int id;
  final String name;
  final String initials;
  final String role;
  final String type;
  final String dates;
  final String length;
  final String reason;
  final String impact;
  final bool warn;
  final int variant;
}

class DocItem {
  const DocItem(this.name, this.meta, this.category, this.ext,
      {this.tag = '', this.tone = Tone.neutral});
  final String name;
  final String meta;
  final String category;
  final String ext;
  final String tag;
  final Tone tone;
}

class ExpenseClaim {
  const ExpenseClaim(
    this.name,
    this.category,
    this.date,
    this.amount,
    this.status,
    this.tone, {
    this.id,
    this.receiptUrl,
  });
  final String? id;
  final String name;
  final String category;
  final String date;
  final int amount;
  final String status;
  final Tone tone;
  final String? receiptUrl;
}

class TaskItem {
  const TaskItem(this.id, this.title, this.sub, this.done, this.due, {this.soon = false});
  final int id;
  final String title;
  final String sub;
  final bool done;
  final String due;
  final bool soon;

  TaskItem toggled() => TaskItem(id, title, sub, !done, due, soon: soon);
}

class LeaveBar {
  const LeaveBar(this.col, this.span, this.type, this.label);
  final int col; // 1-based column (Mon = 1)
  final int span;
  final String type; // annual | sick | wfh
  final String label;
}

class CalendarRow {
  const CalendarRow(this.name, this.initials, this.variant, this.bars);
  final String name;
  final String initials;
  final int variant;
  final List<LeaveBar> bars;
}

class CalendarWeek {
  const CalendarWeek(this.range, this.relative, this.startDay, this.todayIndex, this.rows);
  final String range;
  final String relative;
  final int startDay;
  final int todayIndex; // 0-based, -1 for none
  final List<CalendarRow> rows;
}
