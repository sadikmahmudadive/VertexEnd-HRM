import {
  Employee,
  AttendanceRecord,
  OutworkRequest,
  LeaveRequest,
  ExpenseClaim,
  Announcement,
  DashboardStats,
  CompanyRole,
} from './types';

export const INITIAL_EMPLOYEES: Employee[] = [];
export const INITIAL_ATTENDANCE: AttendanceRecord[] = [];
export const INITIAL_OUTWORK: OutworkRequest[] = [];
export const INITIAL_LEAVES: LeaveRequest[] = [];
export const INITIAL_EXPENSES: ExpenseClaim[] = [];
export const INITIAL_ANNOUNCEMENTS: Announcement[] = [];

export const DEFAULT_ROLES: CompanyRole[] = [
  {
    id: 'role-super-admin',
    name: 'Super Admin',
    description: 'Complete unrestricted control over company workspace, roles, and financials',
    color: 'bg-purple-500/10 text-purple-600 dark:text-purple-400 border-purple-500/20',
    isSystemRole: true,
    permissions: {
      canApproveOutwork: true,
      canApproveLeaves: true,
      canApproveExpenses: true,
      canManageEmployees: true,
      canManageRoles: true,
      canBroadcastAnnouncements: true,
      canViewAnalytics: true,
    },
  },
  {
    id: 'role-hr-manager',
    name: 'HR Manager',
    description: 'Manages employee directory, leave requests, and company announcements',
    color: 'bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 border-indigo-500/20',
    permissions: {
      canApproveOutwork: false,
      canApproveLeaves: true,
      canApproveExpenses: true,
      canManageEmployees: true,
      canManageRoles: false,
      canBroadcastAnnouncements: true,
      canViewAnalytics: true,
    },
  },
  {
    id: 'role-field-supervisor',
    name: 'Field Supervisor',
    description: 'Audits and approves field duty punches, client site visits, and GPS tags',
    color: 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20',
    permissions: {
      canApproveOutwork: true,
      canApproveLeaves: false,
      canApproveExpenses: false,
      canManageEmployees: false,
      canManageRoles: false,
      canBroadcastAnnouncements: false,
      canViewAnalytics: true,
    },
  },
  {
    id: 'role-staff',
    name: 'Staff Member',
    description: 'Standard team member with mobile punch, leave application, and claims access',
    color: 'bg-slate-500/10 text-slate-600 dark:text-slate-400 border-slate-500/20',
    permissions: {
      canApproveOutwork: false,
      canApproveLeaves: false,
      canApproveExpenses: false,
      canManageEmployees: false,
      canManageRoles: false,
      canBroadcastAnnouncements: false,
      canViewAnalytics: false,
    },
  },
];

export const INITIAL_STATS: DashboardStats = {
  totalEmployees: 0,
  inOfficeNow: 0,
  outworkNow: 0,
  onLeaveNow: 0,
  pendingApprovals: 0,
  attendanceRate: 0,
  monthlyClaimsTotal: 0,
};
