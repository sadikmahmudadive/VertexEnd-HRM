import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  String _q = '';
  String _dept = 'All';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final needle = _q.trim().toLowerCase();
    final rows = Mock.people.where((p) {
      final okDept = _dept == 'All' || p.dept == _dept;
      final okQ = needle.isEmpty || '${p.name} ${p.role}'.toLowerCase().contains(needle);
      return okDept && okQ;
    }).toList();

    final children = <Widget>[];
    var last = '';
    var n = 0;
    for (final p in rows) {
      final l = p.name[0];
      if (l != last) {
        children.add(Overline(l));
        last = l;
      }
      children.add(_PersonTile(p).rise(n++));
    }

    return HrmScreen(
      title: 'Directory',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Sp.s1),
          child: Text('${rows.length} people', style: T.caption.col(c.textSecondary)),
        ),
      ],
      children: [
        TextField(
          onChanged: (v) => setState(() => _q = v),
          style: T.body.col(c.textPrimary),
          cursorColor: c.primary500,
          decoration: InputDecoration(
            hintText: 'Search name or role',
            hintStyle: T.body.col(c.textTertiary),
            prefixIcon: Icon(LucideIcons.search, size: 20, color: c.textSecondary),
            filled: true,
            fillColor: c.bgSubtle,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(
                borderRadius: Rd.rFull, borderSide: BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: Rd.rFull, borderSide: BorderSide(color: c.primary500, width: 2)),
          ),
        ).rise(1),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              for (final d in const ['All', 'Design', 'Engineering', 'Finance', 'People']) ...[
                HrmChip(d, selected: _dept == d, onTap: () => setState(() => _dept = d)),
                const SizedBox(width: Sp.s2),
              ],
            ],
          ),
        ).rise(2),
        ...children,
        if (rows.isEmpty)
          const EmptyState(
            icon: LucideIcons.search,
            title: 'No one matches that',
            message: 'Try a different name or team.',
          ),
      ],
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile(this.p);
  final Person p;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return HrmCard(
      padding: const EdgeInsets.symmetric(horizontal: Sp.s4, vertical: Sp.s2),
      onTap: () => context.push('/directory/${p.id}'),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            HrmAvatar(p.initials, variant: p.variant, presence: p.presence),
            const SizedBox(width: Sp.s3),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: T.bodyStrong.col(c.textPrimary)),
                  Text('${p.role} · ${p.status}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: T.caption.col(c.textSecondary)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 20, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}
