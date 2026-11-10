export type Presence = 'inOffice' | 'onBreak' | 'outwork' | 'off' | 'onLeave';

export interface CompanyRole {
  id: string;
  name: string;
  description: string;
  color: string;
  permissions: {
    canApproveOutwork: boolean;
    canApproveLeaves: boolean;
    canApproveExpenses: boolean;
    canManageEmployees: boolean;
    canManageRoles: boolean;
    canBroadcastAnnouncements: boolean;
    canViewAnalytics: boolean;
  };
  isSystemRole?: boolean;
}

export interface AdminUser {
  uid: string;
  email: string;
  displayName: string;
  avatarUrl?: string;
  isSuperAdmin: boolean;
  companyName: string;
  companyCode: string;
  role: string;
  createdAt?: string;
}

export interface Employee {
  id: string;
  name: string;
  initials: string;
  role: string;
  roleId?: string;
  dept: string;
  presence: Presence;
  status: string;
  email: string;
  phone: string;
  companyCode: string;
  employeeId: string;
  avatarUrl?: string;
  joinDate: string;
}

export interface AttendanceRecord {
  id: string;
  employeeId: string;
  employeeName: string;
  employeeRole: string;
  employeeAvatar?: string;
  date: string;
  clockInTime: string;
  clockOutTime?: string;
  isOutwork: boolean;
  location: string;
  clientName?: string;
  status: 'clocked_in' | 'completed' | 'late' | 'on_break';
  durationMinutes: number;
  proofImageUrl?: string;
}

export interface OutworkRequest {
  id: string;
  employeeId: string;
  employeeName: string;
  employeeRole: string;
  employeeAvatar?: string;
  category: string;
  clientName: string;
  location: string;
  schedule: string;
  reason: string;
  status: 'Pending' | 'Approved' | 'Rejected';
  proofImageUrl?: string;
  createdAt: string;
}

export interface LeaveRequest {
  id: string;
  employeeId: string;
  employeeName: string;
  employeeRole: string;
  employeeAvatar?: string;
  leaveType: 'Annual' | 'Sick' | 'Work From Home' | 'Comp-off';
  dates: string;
  days: number;
  reason: string;
  impact?: string;
  status: 'Pending' | 'Approved' | 'Rejected';
  createdAt: string;
}

export interface ExpenseClaim {
  id: string;
  employeeId: string;
  employeeName: string;
  employeeAvatar?: string;
  title: string;
  category: 'Meals' | 'Travel' | 'Supplies' | 'Internet';
  amount: number;
  date: string;
  status: 'Pending' | 'Approved' | 'Rejected';
  receiptImageUrl?: string;
  createdAt: string;
}

export interface Announcement {
  id: string;
  title: string;
  category: 'Policy' | 'Notice' | 'Event' | 'Holiday';
  priority: 'High' | 'Normal' | 'Low';
  body: string;
  authorName: string;
  createdAt: string;
}

export interface DashboardStats {
  totalEmployees: number;
  inOfficeNow: number;
  outworkNow: number;
  onLeaveNow: number;
  pendingApprovals: number;
  attendanceRate: number;
  monthlyClaimsTotal: number;
}
