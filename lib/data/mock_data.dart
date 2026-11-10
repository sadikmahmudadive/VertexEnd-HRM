import '../core/theme/app_colors.dart';
import '../core/widgets/components.dart';
import 'models.dart';

/// Sample data used while the backend is not connected.
abstract final class Mock {
  static const String meName = 'Rahim Ahmed';
  static const String meFirst = 'Rahim';
  static const String meInitials = 'RA';

  static const people = <Person>[
    Person(id: 'fi', name: 'Farhana Islam', initials: 'FI', role: 'HR director', dept: 'People', presence: Presence.inOffice, status: 'In office'),
    Person(id: 'ic', name: 'Imran Chowdhury', initials: 'IC', role: 'Analyst', dept: 'Finance', presence: Presence.onLeave, status: 'On leave', variant: 2),
    Person(id: 'ka', name: 'Karim Ahmed', initials: 'KA', role: 'Engineering manager', dept: 'Engineering', presence: Presence.inOffice, status: 'In office', variant: 1),
    Person(id: 'mi', name: 'Mehnaz Islam', initials: 'MI', role: 'Brand designer', dept: 'Design', presence: Presence.onBreak, status: 'On break'),
    Person(id: 'nr', name: 'Nadia Rahman', initials: 'NR', role: 'Product designer', dept: 'Design', presence: Presence.onLeave, status: 'On leave', variant: 1),
    Person(id: 'ra', name: 'Rahim Ahmed', initials: 'RA', role: 'Senior product designer', dept: 'Design', presence: Presence.inOffice, status: 'You'),
    Person(id: 'sh', name: 'Sadia Hossain', initials: 'SH', role: 'QA lead', dept: 'Engineering', presence: Presence.inOffice, status: 'In office', variant: 2),
    Person(id: 'ta', name: 'Tahmina Akter', initials: 'TA', role: 'Head of design', dept: 'Design', presence: Presence.inOffice, status: 'In office', variant: 1),
    Person(id: 'tl', name: 'Tanvir Alam', initials: 'TL', role: 'Backend engineer', dept: 'Engineering', presence: Presence.off, status: 'Offline'),
    Person(id: 'zc', name: 'Zara Chowdhury', initials: 'ZC', role: 'Accountant', dept: 'Finance', presence: Presence.inOffice, status: 'In office', variant: 2),
  ];

  static const leaveTypes = <LeaveType>[
    LeaveType('annual', 'Annual', HrmColors.leaveAnnual, 8, 12),
    LeaveType('sick', 'Sick', HrmColors.leaveSick, 3, 10),
    LeaveType('wfh', 'Work from home', HrmColors.leaveWfh, 3, 6),
    LeaveType('comp', 'Comp-off', HrmColors.leaveCompOff, 1, 2),
  ];

  static const upcomingLeave = <LeaveEntry>[
    LeaveEntry(day: '12', month: 'Nov', title: 'Annual leave', sub: '3 working days', status: 'Pending', tone: Tone.warning),
    LeaveEntry(day: '20', month: 'Nov', title: 'Work from home', sub: 'Friday, 1 day', status: 'Approved', tone: Tone.success),
  ];

  static const pastLeave = <LeaveEntry>[
    LeaveEntry(day: '05', month: 'Oct', title: 'Sick leave', sub: '2 days, certificate attached', status: 'Approved', tone: Tone.success),
    LeaveEntry(day: '02', month: 'Oct', title: 'Annual leave', sub: '2 days', status: 'Approved', tone: Tone.success),
    LeaveEntry(day: '14', month: 'Sep', title: 'Comp-off', sub: '1 day', status: 'Rejected', tone: Tone.danger),
  ];

  /// Weekend flags for November 2026 (1 Nov is a Sunday).
  static bool isWeekendNov(int d) => (d + 5) % 7 >= 5;
  static const teamOffNov = [13, 16, 17];

  static const approvals = <ApprovalRequest>[
    ApprovalRequest(id: 1, name: 'Nadia Rahman', initials: 'NR', role: 'Product designer', type: 'Sick leave', dates: '5 – 6 Nov', length: '2 days', reason: 'Fever, doctor advised rest. Certificate attached.', impact: '2 others off on these dates'),
    ApprovalRequest(id: 2, name: 'Karim Ahmed', initials: 'KA', role: 'Engineer', type: 'Work from home', dates: 'Fri 6 Nov', length: '1 day', reason: 'Waiting for a plumber at home.', impact: 'No one else is off', variant: 1),
    ApprovalRequest(id: 3, name: 'Sadia Hossain', initials: 'SH', role: 'QA lead', type: 'Annual leave', dates: '9 – 10 Nov', length: '2 days', reason: 'Short trip to Sylhet.', impact: '1 other off', variant: 2),
    ApprovalRequest(id: 4, name: 'Imran Chowdhury', initials: 'IC', role: 'Analyst', type: 'Annual leave', dates: '23 – 27 Nov', length: '5 days', reason: 'Family wedding.', impact: 'Overlaps the release week', warn: true),
  ];

  static const attendanceApprovals = <ApprovalRequest>[
    ApprovalRequest(
      id: 101,
      name: 'Tanvir Ahmed',
      initials: 'TA',
      role: 'Solutions Architect',
      type: 'Outwork / Field Visit',
      dates: 'Today, 10 Nov',
      length: 'Full day',
      reason: 'On-site system integration & pilot deployment at Apex Footwear HQ, Gulshan.',
      impact: 'Field work outside office geofence',
      variant: 1,
    ),
    ApprovalRequest(
      id: 102,
      name: 'Farzana Yasmin',
      initials: 'FY',
      role: 'Enterprise Sales',
      type: 'Outwork / Client Meeting',
      dates: 'Wed 11 Nov',
      length: 'Half day (2:00 PM – 6:00 PM)',
      reason: 'Contract renewal walkthrough with Grameenphone enterprise team.',
      impact: 'Client site · Banani',
      variant: 2,
    ),
  ];

  static const notifications = <AppNotification>[
    AppNotification(id: 1, group: 'Today', kind: NotifKind.request, text: 'Nadia Rahman requested sick leave', sub: '5 – 6 Nov, 2 days', time: '9:41 AM', unread: true, action: NotifAction.approve),
    AppNotification(id: 2, group: 'Today', kind: NotifKind.payslip, text: 'Your October payslip is ready', sub: 'Net pay is hidden until you reveal it', time: '8:00 AM', unread: true, action: NotifAction.link),
    AppNotification(id: 3, group: 'Today', kind: NotifKind.announcement, text: 'Remote work policy needs your acknowledgement', sub: 'From Farhana Islam', time: '7:30 AM', unread: true, action: NotifAction.acknowledge),
    AppNotification(id: 4, group: 'Earlier', kind: NotifKind.approved, text: 'Karim approved your work from home on Fri 20 Nov', sub: 'Request', time: 'Yesterday', unread: false),
    AppNotification(id: 5, group: 'Earlier', kind: NotifKind.reminder, text: 'Submit your timesheet for last week', sub: 'Reminder', time: '2 days ago', unread: false),
    AppNotification(id: 6, group: 'Earlier', kind: NotifKind.profile, text: 'Finish your profile: add an emergency contact', sub: 'Profile 80% complete', time: '3 days ago', unread: false),
  ];

  static const documents = <DocItem>[
    DocItem('Employment contract', 'PDF · 240 KB · 3 Mar 2021', 'Contracts', 'PDF', tag: 'Signed', tone: Tone.success),
    DocItem('Offer letter', 'PDF · 118 KB · 12 Feb 2021', 'Contracts', 'PDF'),
    DocItem('Remote work policy 2026', 'PDF · 96 KB · Yesterday', 'Policies', 'PDF', tag: 'To read', tone: Tone.warning),
    DocItem('Leave policy 2026', 'PDF · 140 KB · 2 Jan 2026', 'Policies', 'PDF'),
    DocItem('Tax certificate 2025-26', 'PDF · 64 KB · 15 Jul 2026', 'Tax', 'PDF'),
    DocItem('National ID', 'JPG · 1.2 MB · Verified', 'Contracts', 'JPG', tag: 'Verified', tone: Tone.success),
  ];

  static const expenseHistory = <ExpenseClaim>[
    ExpenseClaim('Office supplies', 'Supplies', '29 Oct', 3020, 'Approved', Tone.success),
    ExpenseClaim('Client taxi', 'Travel', '27 Oct', 680, 'Approved', Tone.success),
    ExpenseClaim('Internet bill', 'Internet', '25 Oct', 1500, 'Approved', Tone.success),
    ExpenseClaim('Team lunch', 'Meals', '21 Oct', 2570, 'Pending', Tone.warning),
    ExpenseClaim('Parking', 'Travel', '20 Oct', 680, 'Pending', Tone.warning),
  ];

  static const tasks = <TaskItem>[
    TaskItem(1, 'Sign your employment contract', 'HR', true, ''),
    TaskItem(2, 'Upload your National ID', 'You', true, ''),
    TaskItem(3, 'Set up your laptop', 'IT', true, ''),
    TaskItem(4, 'Meet your buddy, Karim Ahmed', 'Karim Ahmed', true, ''),
    TaskItem(5, 'Add your bank details', 'You', false, 'Due 6 Nov', soon: true),
    TaskItem(6, 'Add an emergency contact', 'You', false, 'Due 9 Nov'),
    TaskItem(7, 'Complete security training', '20 minutes · IT', false, 'Due 10 Nov'),
  ];

  static const calendarWeeks = <CalendarWeek>[
    CalendarWeek('2 – 8 Nov 2026', 'This week', 2, 1, [
      CalendarRow('Imran C.', 'IC', 2, [LeaveBar(1, 5, 'annual', 'Annual')]),
      CalendarRow('Nadia R.', 'NR', 1, [LeaveBar(4, 2, 'sick', 'Sick')]),
      CalendarRow('Karim A.', 'KA', 1, [LeaveBar(5, 1, 'wfh', 'WFH')]),
      CalendarRow('Tanvir A.', 'TL', 0, [LeaveBar(2, 1, 'wfh', 'WFH')]),
      CalendarRow('Sadia H.', 'SH', 2, []),
    ]),
    CalendarWeek('9 – 15 Nov 2026', 'Next week', 9, -1, [
      CalendarRow('Imran C.', 'IC', 2, []),
      CalendarRow('Nadia R.', 'NR', 1, []),
      CalendarRow('Rahim A.', 'RA', 0, [LeaveBar(4, 2, 'annual', 'Annual')]),
      CalendarRow('Sadia H.', 'SH', 2, [LeaveBar(1, 2, 'annual', 'Annual')]),
      CalendarRow('Karim A.', 'KA', 1, [LeaveBar(5, 1, 'wfh', 'WFH')]),
    ]),
  ];

  static const askAnswers = <String, (String, String, bool)>{
    'How many sick days do I have?': (
      'You have 3 of your 10 sick days left this year. Absences over 1 day need a medical certificate.',
      'Leave policy 2026, section 3.2',
      true
    ),
    'When is my next payday?': (
      'November salary is paid on 30 Nov 2026, in 27 days. Your payslip appears the same morning.',
      'Payroll calendar 2026',
      false
    ),
    'Can I work from home next Friday?': (
      'Yes. You have 3 work-from-home days left. Send the request by Thursday 6 PM so Tahmina can approve it in time.',
      'Remote work policy 2026',
      false
    ),
    'Who approves my leave?': (
      'Tahmina Akter, your line manager, approves leave. If she is away, Farhana Islam from People approves.',
      'Approval matrix',
      false
    ),
  };
}
