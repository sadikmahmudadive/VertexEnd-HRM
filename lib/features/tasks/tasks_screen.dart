import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/ui.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late List<TaskItem> _tasks = List.of(Mock.tasks);

  void _flip(TaskItem t) {
    HapticFeedback.selectionClick();
    setState(() => _tasks = [for (final x in _tasks) x.id == t.id ? x.toggled() : x]);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final done = _tasks.where((t) => t.done).length;
    final all = done == _tasks.length;
    TaskItem? next;
    for (final t in _tasks) {
      if (!t.done) {
        next = t;
        break;
      }
    }
    const pieces = <(double, double, double, bool, int)>[
      (-80, -60, 10, false, 0),
      (70, -72, 8, true, 1),
      (92, 20, 12, false, 2),
      (30, 90, 9, true, 0),
      (-70, 76, 11, false, 3),
    ];
    final palette = [Colors.white, HrmColors.leaveWfh, c.secondary500, HrmColors.leaveSick];

    return HrmScreen(
      title: 'Tasks',
      children: [
        HeroCard(
          child: Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    ProgressRing(
                      value: done / _tasks.length,
                      size: 120,
                      stroke: 10,
                      color: Colors.white,
                      track: Colors.white.withValues(alpha: 0.25),
                      duration: const Duration(milliseconds: 800),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$done/${_tasks.length}',
                              style: T.h1.copyWith(color: Colors.white).tnum),
                          Text('done', style: T.caption.col(Colors.white.withValues(alpha: 0.9))),
                        ],
                      ),
                    ),
                    if (all)
                      for (final p in pieces)
                        Container(
                          width: p.$3,
                          height: p.$3,
                          decoration: BoxDecoration(
                            color: palette[p.$5],
                            shape: p.$4 ? BoxShape.circle : BoxShape.rectangle,
                            borderRadius: p.$4 ? null : BorderRadius.circular(3),
                          ),
                        )
                            .animate()
                            .move(
                                begin: Offset.zero,
                                end: Offset(p.$1, p.$2),
                                duration: 1400.ms,
                                curve: Curves.easeOutCubic)
                            .rotate(end: 0.6, duration: 1400.ms)
                            .fadeOut(delay: 600.ms, duration: 800.ms),
                  ],
                ),
              ),
              const SizedBox(width: Sp.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(all ? 'All done' : 'Your first week',
                        style: T.h3.copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(
                        all
                            ? 'You are all set. Welcome aboard.'
                            : '${_tasks.length - done} to go. You are doing great.',
                        style: T.label
                            .weight(FontWeight.w400)
                            .col(Colors.white.withValues(alpha: 0.92))),
                  ],
                ),
              ),
            ],
          ),
        ).rise(1),
        if (next != null)
          Container(
            padding: const EdgeInsets.all(Sp.s4),
            decoration: BoxDecoration(
              color: c.primary50,
              borderRadius: Rd.rLg,
              border: Border.all(color: c.primary500.withValues(alpha: 0.35)),
            ),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: c.primary500, shape: BoxShape.circle),
                child: Icon(LucideIcons.arrowRight, size: 20, color: c.textOnPrimary),
              ),
              const SizedBox(width: Sp.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UP NEXT', style: T.overline.col(c.primary600)),
                    Text(next.title, style: T.bodyStrong.col(c.textPrimary)),
                    Text(next.due, style: T.caption.col(c.textSecondary)),
                  ],
                ),
              ),
            ]),
          ).rise(2),
        HrmList(children: [
          for (final t in _tasks)
            HrmListTile(
              minHeight: 68,
              leading: HrmCheck(checked: t.done),
              title: t.title,
              subtitle: t.sub,
              titleColor: t.done ? c.textSecondary : null,
              trailing: t.done || t.due.isEmpty
                  ? null
                  : HrmBadge(t.due, tone: t.soon ? Tone.warning : Tone.neutral),
              onTap: () => _flip(t),
            ),
        ]).rise(3),
      ],
    );
  }
}
