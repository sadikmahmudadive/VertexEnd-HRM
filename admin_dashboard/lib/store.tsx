'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import {
  Employee,
  AttendanceRecord,
  OutworkRequest,
  LeaveRequest,
  ExpenseClaim,
  Announcement,
  DashboardStats,
  AdminUser,
  CompanyRole,
} from './types';
import {
  INITIAL_EMPLOYEES,
  INITIAL_ATTENDANCE,
  INITIAL_OUTWORK,
  INITIAL_LEAVES,
  INITIAL_EXPENSES,
  INITIAL_ANNOUNCEMENTS,
  DEFAULT_ROLES,
} from './data';
import { isFirebaseConfigured, auth, db } from './firebase';
import {
  GoogleAuthProvider,
  signInWithPopup,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
} from 'firebase/auth';
import {
  collection,
  onSnapshot,
  doc,
  setDoc,
  getDoc,
  updateDoc,
  addDoc,
  deleteDoc,
  serverTimestamp,
} from 'firebase/firestore';

interface RegisterParams {
  email: string;
  password?: string;
  companyName: string;
  companyCode: string;
  displayName: string;
}

const getFriendlyFirebaseError = (err: any): string => {
  const code = err?.code || '';
  if (code.includes('auth/email-already-in-use')) {
    return 'This email is already registered. Please click Existing Sign In.';
  }
  if (code.includes('auth/invalid-email')) {
    return 'Please enter a valid email address.';
  }
  if (code.includes('auth/weak-password')) {
    return 'Password should be at least 6 characters.';
  }
  if (
    code.includes('auth/user-not-found') ||
    code.includes('auth/wrong-password') ||
    code.includes('auth/invalid-credential')
  ) {
    return 'Invalid email or password.';
  }
  if (code.includes('auth/popup-closed-by-user')) {
    return 'Google sign-in popup was closed before completion.';
  }
  if (code.includes('auth/popup-blocked')) {
    return 'Google sign-in popup was blocked by browser. Please enable popups.';
  }
  if (code.includes('auth/operation-not-allowed')) {
    return 'Sign-in provider not yet enabled in Firebase Console (Authentication -> Sign-in method).';
  }
  return err?.message || 'Authentication error';
};

interface HrmStoreContextType {
  currentUser: AdminUser | null;
  roles: CompanyRole[];
  employees: Employee[];
  attendance: AttendanceRecord[];
  outworkRequests: OutworkRequest[];
  leaveRequests: LeaveRequest[];
  expenseClaims: ExpenseClaim[];
  announcements: Announcement[];
  stats: DashboardStats;
  darkMode: boolean;
  toggleDarkMode: () => void;
  // Auth Mutations
  registerSuperAdmin: (params: RegisterParams) => Promise<{ success: boolean; error?: string }>;
  signInWithGoogle: (companyMeta?: { companyName: string; companyCode: string }) => Promise<{ success: boolean; error?: string }>;
  signInEmail: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
  signOutAdmin: () => Promise<void>;
  // Roles Mutations
  createRole: (role: Omit<CompanyRole, 'id'>) => Promise<void>;
  deleteRole: (id: string) => Promise<void>;
  assignRoleToEmployee: (employeeId: string, roleName: string, roleId?: string) => Promise<void>;
  // Staff Mutations
  addEmployee: (emp: Omit<Employee, 'id'>) => Promise<void>;
  updateEmployee: (id: string, updates: Partial<Employee>) => Promise<void>;
  deleteEmployee: (id: string) => Promise<void>;
  // Requests Mutations
  approveOutwork: (id: string) => Promise<void>;
  rejectOutwork: (id: string) => Promise<void>;
  approveLeave: (id: string) => Promise<void>;
  rejectLeave: (id: string) => Promise<void>;
  approveExpense: (id: string) => Promise<void>;
  rejectExpense: (id: string) => Promise<void>;
  addAnnouncement: (ann: Omit<Announcement, 'id' | 'createdAt'>) => Promise<void>;
  deleteAnnouncement: (id: string) => Promise<void>;
}

const HrmStoreContext = createContext<HrmStoreContextType | null>(null);

export function HrmStoreProvider({ children }: { children: React.ReactNode }) {
  const [currentUser, setCurrentUser] = useState<AdminUser | null>(null);
  const [roles, setRoles] = useState<CompanyRole[]>(DEFAULT_ROLES);
  const [employees, setEmployees] = useState<Employee[]>(INITIAL_EMPLOYEES);
  const [attendance, setAttendance] = useState<AttendanceRecord[]>(INITIAL_ATTENDANCE);
  const [outworkRequests, setOutworkRequests] = useState<OutworkRequest[]>(INITIAL_OUTWORK);
  const [leaveRequests, setLeaveRequests] = useState<LeaveRequest[]>(INITIAL_LEAVES);
  const [expenseClaims, setExpenseClaims] = useState<ExpenseClaim[]>(INITIAL_EXPENSES);
  const [announcements, setAnnouncements] = useState<Announcement[]>(INITIAL_ANNOUNCEMENTS);
  const [darkMode, setDarkMode] = useState<boolean>(true);

  // Restore theme mode and cached session on mount
  useEffect(() => {
    const isDark = document.documentElement.classList.contains('dark') || true;
    setDarkMode(isDark);
    if (isDark) {
      document.documentElement.classList.add('dark');
    }

    try {
      const savedUser = localStorage.getItem('vh_super_admin_user');
      if (savedUser) {
        setCurrentUser(JSON.parse(savedUser));
      }
      const savedRoles = localStorage.getItem('vh_company_roles');
      if (savedRoles) {
        setRoles(JSON.parse(savedRoles));
      }
    } catch {
      // Ignore local storage error in non-browser or sandbox environment
    }
  }, []);

  const toggleDarkMode = () => {
    setDarkMode((prev) => {
      const next = !prev;
      if (next) {
        document.documentElement.classList.add('dark');
      } else {
        document.documentElement.classList.remove('dark');
      }
      return next;
    });
  };

  // Connect live Firebase Auth & Firestore streams
  useEffect(() => {
    if (!isFirebaseConfigured) return;

    try {
      // Auth listener
      const unsubAuth = onAuthStateChanged(auth, async (user) => {
        if (user) {
          try {
            const userDoc = await getDoc(doc(db, 'users', user.uid));
            if (userDoc.exists()) {
              const data = userDoc.data();
              const adminProfile: AdminUser = {
                uid: user.uid,
                email: user.email || data.email,
                displayName: user.displayName || data.name || 'Super Admin',
                avatarUrl: user.photoURL || data.avatarUrl,
                isSuperAdmin: data.isSuperAdmin ?? true,
                companyName: data.companyName || 'Acme Bangladesh Ltd',
                companyCode: data.companyCode || 'ACME-DHK',
                role: data.role || 'Super Admin',
              };
              setCurrentUser(adminProfile);
              localStorage.setItem('vh_super_admin_user', JSON.stringify(adminProfile));
            } else {
              const adminProfile: AdminUser = {
                uid: user.uid,
                email: user.email || 'admin@acme.com.bd',
                displayName: user.displayName || 'Super Admin',
                avatarUrl: user.photoURL || undefined,
                isSuperAdmin: true,
                companyName: 'Acme Bangladesh Ltd',
                companyCode: 'ACME-DHK',
                role: 'Super Admin',
              };
              setCurrentUser(adminProfile);
              localStorage.setItem('vh_super_admin_user', JSON.stringify(adminProfile));
            }
          } catch (e) {
            console.warn('Error fetching Firestore user profile:', e);
            if (user.email) {
              const adminProfile: AdminUser = {
                uid: user.uid,
                email: user.email,
                displayName: user.displayName || 'Super Admin',
                avatarUrl: user.photoURL || undefined,
                isSuperAdmin: true,
                companyName: 'Acme Bangladesh Ltd',
                companyCode: 'ACME-DHK',
                role: 'Super Admin',
              };
              setCurrentUser(adminProfile);
            }
          }
        }
      });

      // Users / Staff stream
      const unsubUsers = onSnapshot(
        collection(db, 'users'),
        (snap) => {
          const list: Employee[] = snap.docs.map((d) => {
            const data = d.data();
            return {
              id: d.id,
              name: data.name || 'Staff Member',
              initials: data.initials || (data.name ? data.name.substring(0, 2).toUpperCase() : 'SM'),
              role: data.role || 'Staff Member',
              roleId: data.roleId,
              dept: data.dept || 'General',
              presence: data.presence || 'inOffice',
              status: data.status || 'Active',
              email: data.email || '',
              phone: data.phone || '',
              companyCode: data.companyCode || 'ACME-DHK',
              employeeId: data.employeeId || d.id,
              avatarUrl: data.avatarUrl,
              joinDate: data.joinDate || '2026',
            };
          });
          setEmployees(list);
        },
        (err) => console.warn('Firestore users stream notice:', err.message)
      );

      // Outwork stream
      const unsubOutwork = onSnapshot(
        collection(db, 'outwork_requests'),
        (snap) => {
          const list: OutworkRequest[] = snap.docs.map((d) => {
            const data = d.data();
            return {
              id: d.id,
              employeeId: data.userId || data.employeeId || '',
              employeeName: data.userName || data.employeeName || 'Employee',
              employeeRole: data.category || data.employeeRole || 'Field Duty',
              category: data.category || 'Client visit',
              clientName: data.clientName || '',
              location: data.location || '',
              schedule: data.schedule || 'Today',
              reason: data.reason || '',
              status: data.status || 'Pending',
              proofImageUrl: data.proofImageUrl,
              createdAt: data.createdAt?.toDate ? data.createdAt.toDate().toLocaleDateString() : (data.createdAt || 'Today'),
            };
          });
          setOutworkRequests(list);
        },
        (err) => console.warn('Firestore outwork stream notice:', err.message)
      );

      // Leave requests stream
      const unsubLeaves = onSnapshot(
        collection(db, 'leave_requests'),
        (snap) => {
          const list: LeaveRequest[] = snap.docs.map((d) => {
            const data = d.data();
            return {
              id: d.id,
              employeeId: data.userId || data.employeeId || '',
              employeeName: data.userName || data.employeeName || 'Staff Member',
              employeeRole: data.employeeRole || data.role || 'Employee',
              employeeAvatar: data.avatarUrl || data.employeeAvatar,
              leaveType: data.leaveType || 'Annual',
              dates: data.dates || data.dateRange || 'Upcoming',
              days: data.days || 1,
              reason: data.reason || '',
              impact: data.impact,
              status: data.status || 'Pending',
              createdAt: data.createdAt?.toDate ? data.createdAt.toDate().toLocaleDateString() : (data.createdAt || 'Today'),
            };
          });
          setLeaveRequests(list);
        },
        (err) => console.warn('Firestore leaves stream notice:', err.message)
      );

      // Expense claims stream
      const unsubExpenses = onSnapshot(
        collection(db, 'expenses'),
        (snap) => {
          const list: ExpenseClaim[] = snap.docs.map((d) => {
            const data = d.data();
            return {
              id: d.id,
              employeeId: data.userId || data.employeeId || '',
              employeeName: data.userName || data.employeeName || 'Staff Member',
              employeeAvatar: data.avatarUrl || data.employeeAvatar,
              title: data.title || 'Expense Claim',
              category: data.category || 'Travel',
              amount: Number(data.amount) || 0,
              date: data.date || 'Today',
              status: data.status || 'Pending',
              receiptImageUrl: data.receiptImageUrl || data.receiptUrl,
              createdAt: data.createdAt?.toDate ? data.createdAt.toDate().toLocaleDateString() : (data.createdAt || 'Today'),
            };
          });
          setExpenseClaims(list);
        },
        (err) => console.warn('Firestore expenses stream notice:', err.message)
      );

      // Attendance stream
      const unsubAttendance = onSnapshot(
        collection(db, 'attendance'),
        (snap) => {
          const list: AttendanceRecord[] = snap.docs.map((d) => {
            const data = d.data();
            return {
              id: d.id,
              employeeId: data.userId || data.employeeId || '',
              employeeName: data.userName || data.employeeName || 'Staff Member',
              employeeRole: data.employeeRole || data.role || 'Staff',
              employeeAvatar: data.avatarUrl || data.employeeAvatar,
              date: data.date || 'Today',
              clockInTime: data.clockInTime || data.inTime || '09:00 AM',
              clockOutTime: data.clockOutTime || data.outTime,
              isOutwork: data.isOutwork || false,
              location: data.location || 'Banani HQ, Dhaka',
              clientName: data.clientName,
              status: data.status || 'clocked_in',
              durationMinutes: data.durationMinutes || 0,
              proofImageUrl: data.proofImageUrl,
            };
          });
          setAttendance(list);
        },
        (err) => console.warn('Firestore attendance stream notice:', err.message)
      );

      // Announcements stream
      const unsubAnnouncements = onSnapshot(
        collection(db, 'announcements'),
        (snap) => {
          const list: Announcement[] = snap.docs.map((d) => {
            const data = d.data();
            return {
              id: d.id,
              title: data.title || '',
              category: data.category || 'Notice',
              priority: data.priority || 'Normal',
              body: data.body || '',
              authorName: data.authorName || 'Super Admin',
              createdAt: data.createdAt?.toDate ? data.createdAt.toDate().toLocaleDateString() : (data.createdAt || 'Today'),
            };
          });
          setAnnouncements(list);
        },
        (err) => console.warn('Firestore announcements stream notice:', err.message)
      );

      // Roles stream
      const unsubRoles = onSnapshot(
        collection(db, 'roles'),
        (snap) => {
          if (!snap.empty) {
            const list: CompanyRole[] = snap.docs.map((d) => {
              const data = d.data();
              return {
                id: d.id,
                name: data.name,
                description: data.description || '',
                color: data.color || 'bg-slate-500/10 text-slate-500 border-slate-500/20',
                permissions: data.permissions || {
                  canApproveOutwork: false,
                  canApproveLeaves: false,
                  canApproveExpenses: false,
                  canManageEmployees: false,
                  canManageRoles: false,
                  canBroadcastAnnouncements: false,
                  canViewAnalytics: false,
                },
                isSystemRole: data.isSystemRole || false,
              };
            });
            setRoles(list);
          }
        },
        (err) => console.warn('Firestore roles stream notice:', err.message)
      );

      return () => {
        unsubAuth();
        unsubUsers();
        unsubOutwork();
        unsubLeaves();
        unsubExpenses();
        unsubAttendance();
        unsubAnnouncements();
        unsubRoles();
      };
    } catch (e) {
      console.warn('Firebase sync listener initialization notice:', e);
    }
  }, []);

  // Compute live dashboard stats
  const pendingApprovalsCount =
    outworkRequests.filter((r) => r.status === 'Pending').length +
    leaveRequests.filter((r) => r.status === 'Pending').length +
    expenseClaims.filter((r) => r.status === 'Pending').length;

  const inOfficeCount = employees.filter((e) => e.presence === 'inOffice').length;
  const outworkCount = employees.filter((e) => e.presence === 'outwork').length;
  const onLeaveCount = employees.filter((e) => e.presence === 'onLeave').length;

  const stats: DashboardStats = {
    totalEmployees: employees.length,
    inOfficeNow: inOfficeCount,
    outworkNow: outworkCount,
    onLeaveNow: onLeaveCount,
    pendingApprovals: pendingApprovalsCount,
    attendanceRate:
      employees.length > 0
        ? Math.round(((inOfficeCount + outworkCount) / employees.length) * 1000) / 10
        : 0,
    monthlyClaimsTotal: expenseClaims.reduce((acc, c) => acc + (c.status === 'Approved' ? c.amount : 0), 0),
  };

  // Auth: Register as Super Admin with new Email & Password
  const registerSuperAdmin = async ({
    email,
    password,
    companyName,
    companyCode,
    displayName,
  }: RegisterParams): Promise<{ success: boolean; error?: string }> => {
    const formattedCode = companyCode.trim().toUpperCase() || 'ACME-DHK';

    try {
      let uid = `super-${Date.now()}`;

      if (isFirebaseConfigured && password) {
        const cred = await createUserWithEmailAndPassword(auth, email, password);
        uid = cred.user.uid;

        // Create company document
        try {
          await setDoc(doc(db, 'companies', formattedCode), {
            name: companyName,
            code: formattedCode,
            superAdminUid: uid,
            createdAt: serverTimestamp(),
          });

          // Create super admin profile in users collection
          await setDoc(doc(db, 'users', uid), {
            uid,
            name: displayName,
            email,
            role: 'Super Admin',
            isSuperAdmin: true,
            companyCode: formattedCode,
            companyName,
            createdAt: serverTimestamp(),
          });
        } catch (dbErr) {
          console.warn('Notice writing Firestore documents during register:', dbErr);
        }
      }

      const adminUser: AdminUser = {
        uid,
        email,
        displayName,
        isSuperAdmin: true,
        companyName,
        companyCode: formattedCode,
        role: 'Super Admin',
      };

      setCurrentUser(adminUser);
      localStorage.setItem('vh_super_admin_user', JSON.stringify(adminUser));
      return { success: true };
    } catch (e: any) {
      console.error('Super Admin registration error:', e);
      return { success: false, error: getFriendlyFirebaseError(e) };
    }
  };

  // Auth: Sign in / Register with Google ID as Super Admin
  const signInWithGoogle = async (
    companyMeta?: { companyName: string; companyCode: string }
  ): Promise<{ success: boolean; error?: string }> => {
    try {
      const companyName = companyMeta?.companyName || 'Acme Bangladesh Ltd';
      const companyCode = (companyMeta?.companyCode || 'ACME-DHK').trim().toUpperCase();

      let uid = `google-${Date.now()}`;
      let email = 'superadmin@acme.com.bd';
      let displayName = 'Super Administrator';
      let avatarUrl: string | undefined = undefined;

      if (isFirebaseConfigured) {
        const provider = new GoogleAuthProvider();
        const cred = await signInWithPopup(auth, provider);
        const user = cred.user;
        uid = user.uid;
        email = user.email || email;
        displayName = user.displayName || displayName;
        avatarUrl = user.photoURL || undefined;

        try {
          // Check if existing user in Firestore
          const userSnap = await getDoc(doc(db, 'users', uid));
          if (!userSnap.exists()) {
            // New account with Google: grant Super Admin status
            await setDoc(doc(db, 'companies', companyCode), {
              name: companyName,
              code: companyCode,
              superAdminUid: uid,
              createdAt: serverTimestamp(),
            });

            await setDoc(doc(db, 'users', uid), {
              uid,
              name: displayName,
              email,
              avatarUrl: avatarUrl || null,
              role: 'Super Admin',
              isSuperAdmin: true,
              companyCode,
              companyName,
              createdAt: serverTimestamp(),
            });
          }
        } catch (dbErr) {
          console.warn('Notice writing Firestore documents during Google auth:', dbErr);
        }
      }

      const adminUser: AdminUser = {
        uid,
        email,
        displayName,
        avatarUrl,
        isSuperAdmin: true,
        companyName,
        companyCode,
        role: 'Super Admin',
      };

      setCurrentUser(adminUser);
      localStorage.setItem('vh_super_admin_user', JSON.stringify(adminUser));
      return { success: true };
    } catch (e: any) {
      console.error('Google sign in error:', e);
      return { success: false, error: getFriendlyFirebaseError(e) };
    }
  };

  // Auth: Sign in with existing email
  const signInEmail = async (email: string, password: string): Promise<{ success: boolean; error?: string }> => {
    try {
      if (isFirebaseConfigured) {
        const cred = await signInWithEmailAndPassword(auth, email, password);
        try {
          const userDoc = await getDoc(doc(db, 'users', cred.user.uid));
          if (userDoc.exists()) {
            const data = userDoc.data();
            const adminProfile: AdminUser = {
              uid: cred.user.uid,
              email: cred.user.email || email,
              displayName: cred.user.displayName || data.name || 'Super Admin',
              avatarUrl: cred.user.photoURL || data.avatarUrl,
              isSuperAdmin: data.isSuperAdmin ?? true,
              companyName: data.companyName || 'Acme Bangladesh Ltd',
              companyCode: data.companyCode || 'ACME-DHK',
              role: data.role || 'Super Admin',
            };
            setCurrentUser(adminProfile);
            localStorage.setItem('vh_super_admin_user', JSON.stringify(adminProfile));
            return { success: true };
          }
        } catch (dbErr) {
          console.warn('Notice reading user doc in Firestore:', dbErr);
        }

        const adminProfile: AdminUser = {
          uid: cred.user.uid,
          email: cred.user.email || email,
          displayName: cred.user.displayName || 'Super Admin',
          avatarUrl: cred.user.photoURL || undefined,
          isSuperAdmin: true,
          companyName: 'Acme Bangladesh Ltd',
          companyCode: 'ACME-DHK',
          role: 'Super Admin',
        };
        setCurrentUser(adminProfile);
        localStorage.setItem('vh_super_admin_user', JSON.stringify(adminProfile));
        return { success: true };
      }

      // Offline / fallback sign in
      const adminUser: AdminUser = {
        uid: 'admin-local',
        email,
        displayName: 'Super Administrator',
        isSuperAdmin: true,
        companyName: 'Acme Bangladesh Ltd',
        companyCode: 'ACME-DHK',
        role: 'Super Admin',
      };
      setCurrentUser(adminUser);
      localStorage.setItem('vh_super_admin_user', JSON.stringify(adminUser));
      return { success: true };
    } catch (e: any) {
      return { success: false, error: getFriendlyFirebaseError(e) };
    }
  };

  // Auth: Sign out
  const signOutAdmin = async () => {
    if (isFirebaseConfigured) {
      try {
        await signOut(auth);
      } catch (e) {
        console.warn('Sign out error:', e);
      }
    }
    setCurrentUser(null);
    localStorage.removeItem('vh_super_admin_user');
  };

  // Role Management: Create new custom role
  const createRole = async (newRoleData: Omit<CompanyRole, 'id'>) => {
    const newId = `role-${Date.now()}`;
    const newRole: CompanyRole = { ...newRoleData, id: newId };
    const updated = [...roles, newRole];
    setRoles(updated);
    localStorage.setItem('vh_company_roles', JSON.stringify(updated));

    if (isFirebaseConfigured) {
      try {
        await setDoc(doc(db, 'roles', newId), {
          ...newRoleData,
          createdAt: serverTimestamp(),
        });
      } catch (e) {
        console.error('Error creating role in Firestore:', e);
      }
    }
  };

  // Role Management: Delete custom role
  const deleteRole = async (id: string) => {
    const updated = roles.filter((r) => r.id !== id);
    setRoles(updated);
    localStorage.setItem('vh_company_roles', JSON.stringify(updated));

    if (isFirebaseConfigured) {
      try {
        await deleteDoc(doc(db, 'roles', id));
      } catch (e) {
        console.error('Error deleting role in Firestore:', e);
      }
    }
  };

  // Role Assignment: Assign role to an employee
  const assignRoleToEmployee = async (employeeId: string, roleName: string, roleId?: string) => {
    setEmployees((prev) =>
      prev.map((e) => (e.id === employeeId ? { ...e, role: roleName, roleId } : e))
    );

    if (isFirebaseConfigured) {
      try {
        await updateDoc(doc(db, 'users', employeeId), {
          role: roleName,
          roleId: roleId || null,
        });
      } catch (e) {
        console.error('Error assigning role in Firestore:', e);
      }
    }
  };

  // Staff Management: Add new employee
  const addEmployee = async (emp: Omit<Employee, 'id'>) => {
    const newId = `emp-${Date.now()}`;
    const newEmp: Employee = { ...emp, id: newId };
    setEmployees((prev) => [newEmp, ...prev]);

    if (isFirebaseConfigured) {
      try {
        await addDoc(collection(db, 'users'), {
          ...emp,
          createdAt: serverTimestamp(),
        });
      } catch (e) {
        console.error('Error saving user to Firestore:', e);
      }
    }
  };

  const updateEmployee = async (id: string, updates: Partial<Employee>) => {
    setEmployees((prev) => prev.map((e) => (e.id === id ? { ...e, ...updates } : e)));
    if (isFirebaseConfigured) {
      try {
        await updateDoc(doc(db, 'users', id), updates);
      } catch (e) {
        console.error('Error updating employee in Firestore:', e);
      }
    }
  };

  const deleteEmployee = async (id: string) => {
    setEmployees((prev) => prev.filter((e) => e.id !== id));
    if (isFirebaseConfigured) {
      try {
        await deleteDoc(doc(db, 'users', id));
      } catch (e) {
        console.error('Error deleting employee in Firestore:', e);
      }
    }
  };

  const approveOutwork = async (id: string) => {
    setOutworkRequests((prev) =>
      prev.map((r) => (r.id === id ? { ...r, status: 'Approved' } : r))
    );
    if (isFirebaseConfigured) {
      try {
        await updateDoc(doc(db, 'outwork_requests', id), { status: 'Approved' });
      } catch (e) {
        console.error('Error approving outwork in Firestore:', e);
      }
    }
  };

  const rejectOutwork = async (id: string) => {
    setOutworkRequests((prev) =>
      prev.map((r) => (r.id === id ? { ...r, status: 'Rejected' } : r))
    );
    if (isFirebaseConfigured) {
      try {
        await updateDoc(doc(db, 'outwork_requests', id), { status: 'Rejected' });
      } catch (e) {
        console.error('Error rejecting outwork in Firestore:', e);
      }
    }
  };

  const approveLeave = async (id: string) => {
    setLeaveRequests((prev) =>
      prev.map((r) => (r.id === id ? { ...r, status: 'Approved' } : r))
    );
    if (isFirebaseConfigured) {
      try {
        await updateDoc(doc(db, 'leave_requests', id), { status: 'Approved' });
      } catch (e) {
        console.error('Error approving leave in Firestore:', e);
      }
    }
  };

  const rejectLeave = async (id: string) => {
    setLeaveRequests((prev) =>
      prev.map((r) => (r.id === id ? { ...r, status: 'Rejected' } : r))
    );
    if (isFirebaseConfigured) {
      try {
        await updateDoc(doc(db, 'leave_requests', id), { status: 'Rejected' });
      } catch (e) {
        console.error('Error rejecting leave in Firestore:', e);
      }
    }
  };

  const approveExpense = async (id: string) => {
    setExpenseClaims((prev) =>
      prev.map((c) => (c.id === id ? { ...c, status: 'Approved' } : c))
    );
    if (isFirebaseConfigured) {
      try {
        await updateDoc(doc(db, 'expenses', id), { status: 'Approved' });
      } catch (e) {
        console.error('Error approving expense in Firestore:', e);
      }
    }
  };

  const rejectExpense = async (id: string) => {
    setExpenseClaims((prev) =>
      prev.map((c) => (c.id === id ? { ...c, status: 'Rejected' } : c))
    );
    if (isFirebaseConfigured) {
      try {
        await updateDoc(doc(db, 'expenses', id), { status: 'Rejected' });
      } catch (e) {
        console.error('Error rejecting expense in Firestore:', e);
      }
    }
  };

  const addAnnouncement = async (ann: Omit<Announcement, 'id' | 'createdAt'>) => {
    const newId = `anc-${Date.now()}`;
    const newAnc: Announcement = {
      ...ann,
      id: newId,
      createdAt: 'Just now',
    };
    setAnnouncements((prev) => [newAnc, ...prev]);
    if (isFirebaseConfigured) {
      try {
        await addDoc(collection(db, 'announcements'), {
          ...ann,
          createdAt: serverTimestamp(),
        });
      } catch (e) {
        console.error('Error creating announcement in Firestore:', e);
      }
    }
  };

  const deleteAnnouncement = async (id: string) => {
    setAnnouncements((prev) => prev.filter((a) => a.id !== id));
    if (isFirebaseConfigured) {
      try {
        await deleteDoc(doc(db, 'announcements', id));
      } catch (e) {
        console.error('Error deleting announcement in Firestore:', e);
      }
    }
  };

  return (
    <HrmStoreContext.Provider
      value={{
        currentUser,
        roles,
        employees,
        attendance,
        outworkRequests,
        leaveRequests,
        expenseClaims,
        announcements,
        stats,
        darkMode,
        toggleDarkMode,
        registerSuperAdmin,
        signInWithGoogle,
        signInEmail,
        signOutAdmin,
        createRole,
        deleteRole,
        assignRoleToEmployee,
        addEmployee,
        updateEmployee,
        deleteEmployee,
        approveOutwork,
        rejectOutwork,
        approveLeave,
        rejectLeave,
        approveExpense,
        rejectExpense,
        addAnnouncement,
        deleteAnnouncement,
      }}
    >
      {children}
    </HrmStoreContext.Provider>
  );
}

export function useHrmAdmin() {
  const ctx = useContext(HrmStoreContext);
  if (!ctx) {
    throw new Error('useHrmAdmin must be used within HrmStoreProvider');
  }
  return ctx;
}
