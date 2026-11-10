'use client';

import React, { useState } from 'react';
import { useHrmAdmin } from '@/lib/store';
import {
  ShieldCheck,
  Plus,
  Trash2,
  Users,
  Check,
  X,
  Lock,
  Sparkles,
  Info,
} from 'lucide-react';
import { CompanyRole } from '@/lib/types';

export default function RolesPage() {
  const { roles, employees, createRole, deleteRole, currentUser } = useHrmAdmin();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [roleName, setRoleName] = useState('');
  const [description, setDescription] = useState('');
  const [color, setColor] = useState('bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 border-indigo-500/20');
  const [permissions, setPermissions] = useState({
    canApproveOutwork: false,
    canApproveLeaves: false,
    canApproveExpenses: false,
    canManageEmployees: false,
    canManageRoles: false,
    canBroadcastAnnouncements: false,
    canViewAnalytics: true,
  });

  const colorOptions = [
    { label: 'Indigo', value: 'bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 border-indigo-500/20' },
    { label: 'Purple', value: 'bg-purple-500/10 text-purple-600 dark:text-purple-400 border-purple-500/20' },
    { label: 'Amber', value: 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20' },
    { label: 'Emerald', value: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/20' },
    { label: 'Sky', value: 'bg-sky-500/10 text-sky-600 dark:text-sky-400 border-sky-500/20' },
    { label: 'Rose', value: 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border-rose-500/20' },
  ];

  const handleCreateRole = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!roleName.trim()) return;

    await createRole({
      name: roleName.trim(),
      description: description.trim() || 'Custom company role created by Super Admin',
      color,
      permissions,
      isSystemRole: false,
    });

    setRoleName('');
    setDescription('');
    setIsModalOpen(false);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
              Roles & Permissions Architecture
            </h1>
            <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-purple-500/10 text-purple-600 dark:text-purple-400 border border-purple-500/20">
              Super Admin Control
            </span>
          </div>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
            Define role boundaries, grant management approvals, and assign team privileges for {currentUser?.companyName || 'your company'}
          </p>
        </div>

        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-2 px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-sm shadow-indigo-600/30 transition-all self-start sm:self-auto hover:scale-[1.01] active:scale-[0.99]"
        >
          <Plus className="w-3.5 h-3.5" />
          <span>Create New Role</span>
        </button>
      </div>

      {/* Roles Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {roles.map((r) => {
          const assignedCount = employees.filter(
            (e) => e.role.toLowerCase() === r.name.toLowerCase() || e.roleId === r.id
          ).length;

          return (
            <div
              key={r.id}
              className="rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm p-6 flex flex-col justify-between hover:border-slate-300 dark:hover:border-white/15 transition-all group"
            >
              <div className="space-y-3.5">
                <div className="flex items-start justify-between">
                  <span className={`text-[11px] font-bold px-2.5 py-0.5 rounded-full border ${r.color}`}>
                    {r.name}
                  </span>

                  {r.isSystemRole ? (
                    <span className="text-[10px] font-semibold text-slate-400 flex items-center gap-1">
                      <Lock className="w-3 h-3 text-slate-400" />
                      <span>System</span>
                    </span>
                  ) : (
                    <button
                      onClick={() => deleteRole(r.id)}
                      className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/10 text-slate-400 hover:text-rose-500 hover:bg-rose-500/10 flex items-center justify-center transition-colors opacity-0 group-hover:opacity-100"
                      title="Delete role"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  )}
                </div>

                <p className="text-xs text-slate-500 dark:text-slate-400 leading-relaxed">
                  {r.description}
                </p>

                {/* Permissions List */}
                <div className="pt-2 border-t border-slate-100 dark:border-white/[0.05] space-y-2 text-xs">
                  <p className="text-[10px] uppercase font-bold tracking-wider text-slate-400">
                    Permissions Granted
                  </p>
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between text-[11px]">
                      <span className="text-slate-600 dark:text-slate-300">Outwork / Field Approvals</span>
                      {r.permissions.canApproveOutwork ? (
                        <Check className="w-3.5 h-3.5 text-emerald-500" />
                      ) : (
                        <X className="w-3.5 h-3.5 text-slate-300 dark:text-slate-600" />
                      )}
                    </div>
                    <div className="flex items-center justify-between text-[11px]">
                      <span className="text-slate-600 dark:text-slate-300">Leave Approvals</span>
                      {r.permissions.canApproveLeaves ? (
                        <Check className="w-3.5 h-3.5 text-emerald-500" />
                      ) : (
                        <X className="w-3.5 h-3.5 text-slate-300 dark:text-slate-600" />
                      )}
                    </div>
                    <div className="flex items-center justify-between text-[11px]">
                      <span className="text-slate-600 dark:text-slate-300">Expense Reimbursements</span>
                      {r.permissions.canApproveExpenses ? (
                        <Check className="w-3.5 h-3.5 text-emerald-500" />
                      ) : (
                        <X className="w-3.5 h-3.5 text-slate-300 dark:text-slate-600" />
                      )}
                    </div>
                    <div className="flex items-center justify-between text-[11px]">
                      <span className="text-slate-600 dark:text-slate-300">Staff Management</span>
                      {r.permissions.canManageEmployees ? (
                        <Check className="w-3.5 h-3.5 text-emerald-500" />
                      ) : (
                        <X className="w-3.5 h-3.5 text-slate-300 dark:text-slate-600" />
                      )}
                    </div>
                    <div className="flex items-center justify-between text-[11px]">
                      <span className="text-slate-600 dark:text-slate-300">Role Architecture</span>
                      {r.permissions.canManageRoles ? (
                        <Check className="w-3.5 h-3.5 text-emerald-500" />
                      ) : (
                        <X className="w-3.5 h-3.5 text-slate-300 dark:text-slate-600" />
                      )}
                    </div>
                  </div>
                </div>
              </div>

              {/* Footer */}
              <div className="mt-4 pt-3 border-t border-slate-100 dark:border-white/[0.05] flex items-center justify-between text-xs text-slate-400">
                <div className="flex items-center gap-1.5">
                  <Users className="w-3.5 h-3.5 text-indigo-500" />
                  <span>Assigned:</span>
                </div>
                <span className="font-bold text-slate-800 dark:text-slate-200">
                  {assignedCount} {assignedCount === 1 ? 'employee' : 'employees'}
                </span>
              </div>
            </div>
          );
        })}
      </div>

      {/* Create Role Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-in fade-in duration-200">
          <div className="bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.08] rounded-2xl max-w-lg w-full overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
            <div className="p-5 border-b border-slate-100 dark:border-white/[0.06] flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 flex items-center justify-center border border-indigo-500/15">
                  <ShieldCheck className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                    Create Custom Role
                  </h3>
                  <p className="text-[11px] text-slate-500 dark:text-slate-400">
                    Define title, description, and permissions
                  </p>
                </div>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/10 flex items-center justify-center text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </div>

            <form onSubmit={handleCreateRole} className="p-5 space-y-4 text-xs">
              <div>
                <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                  Role Title *
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Operations Lead, Branch Manager, Auditor"
                  value={roleName}
                  onChange={(e) => setRoleName(e.target.value)}
                  className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-white placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                  Role Description
                </label>
                <input
                  type="text"
                  placeholder="Summarize this role responsibilities..."
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-white placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
                />
              </div>

              {/* Color Tag Selection */}
              <div>
                <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                  Badge Color
                </label>
                <div className="flex flex-wrap gap-2">
                  {colorOptions.map((c) => (
                    <button
                      key={c.label}
                      type="button"
                      onClick={() => setColor(c.value)}
                      className={`px-3 py-1 rounded-lg text-[11px] font-semibold border transition-all ${
                        c.value
                      } ${color === c.value ? 'ring-2 ring-indigo-500 shadow-sm' : 'opacity-70 hover:opacity-100'}`}
                    >
                      {c.label}
                    </button>
                  ))}
                </div>
              </div>

              {/* Permission Checkboxes */}
              <div className="space-y-2 pt-2 border-t border-slate-100 dark:border-white/[0.05]">
                <label className="block font-semibold text-slate-700 dark:text-slate-300">
                  Select Authorities & Permissions
                </label>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                  <label className="flex items-center gap-2 p-2.5 rounded-xl bg-slate-50 dark:bg-white/[0.02] border border-slate-200/70 dark:border-white/[0.06] cursor-pointer hover:border-slate-300 dark:hover:border-white/15">
                    <input
                      type="checkbox"
                      checked={permissions.canApproveOutwork}
                      onChange={(e) =>
                        setPermissions({ ...permissions, canApproveOutwork: e.target.checked })
                      }
                      className="rounded text-indigo-600 focus:ring-indigo-500"
                    />
                    <span>Approve Field Outwork</span>
                  </label>

                  <label className="flex items-center gap-2 p-2.5 rounded-xl bg-slate-50 dark:bg-white/[0.02] border border-slate-200/70 dark:border-white/[0.06] cursor-pointer hover:border-slate-300 dark:hover:border-white/15">
                    <input
                      type="checkbox"
                      checked={permissions.canApproveLeaves}
                      onChange={(e) =>
                        setPermissions({ ...permissions, canApproveLeaves: e.target.checked })
                      }
                      className="rounded text-indigo-600 focus:ring-indigo-500"
                    />
                    <span>Approve Leave Requests</span>
                  </label>

                  <label className="flex items-center gap-2 p-2.5 rounded-xl bg-slate-50 dark:bg-white/[0.02] border border-slate-200/70 dark:border-white/[0.06] cursor-pointer hover:border-slate-300 dark:hover:border-white/15">
                    <input
                      type="checkbox"
                      checked={permissions.canApproveExpenses}
                      onChange={(e) =>
                        setPermissions({ ...permissions, canApproveExpenses: e.target.checked })
                      }
                      className="rounded text-indigo-600 focus:ring-indigo-500"
                    />
                    <span>Approve Expenses</span>
                  </label>

                  <label className="flex items-center gap-2 p-2.5 rounded-xl bg-slate-50 dark:bg-white/[0.02] border border-slate-200/70 dark:border-white/[0.06] cursor-pointer hover:border-slate-300 dark:hover:border-white/15">
                    <input
                      type="checkbox"
                      checked={permissions.canManageEmployees}
                      onChange={(e) =>
                        setPermissions({ ...permissions, canManageEmployees: e.target.checked })
                      }
                      className="rounded text-indigo-600 focus:ring-indigo-500"
                    />
                    <span>Manage Staff Directory</span>
                  </label>

                  <label className="flex items-center gap-2 p-2.5 rounded-xl bg-slate-50 dark:bg-white/[0.02] border border-slate-200/70 dark:border-white/[0.06] cursor-pointer hover:border-slate-300 dark:hover:border-white/15">
                    <input
                      type="checkbox"
                      checked={permissions.canBroadcastAnnouncements}
                      onChange={(e) =>
                        setPermissions({
                          ...permissions,
                          canBroadcastAnnouncements: e.target.checked,
                        })
                      }
                      className="rounded text-indigo-600 focus:ring-indigo-500"
                    />
                    <span>Post Announcements</span>
                  </label>

                  <label className="flex items-center gap-2 p-2.5 rounded-xl bg-slate-50 dark:bg-white/[0.02] border border-slate-200/70 dark:border-white/[0.06] cursor-pointer hover:border-slate-300 dark:hover:border-white/15">
                    <input
                      type="checkbox"
                      checked={permissions.canManageRoles}
                      onChange={(e) =>
                        setPermissions({ ...permissions, canManageRoles: e.target.checked })
                      }
                      className="rounded text-indigo-600 focus:ring-indigo-500"
                    />
                    <span>Create & Edit Roles</span>
                  </label>
                </div>
              </div>

              <div className="p-4 border-t border-slate-100 dark:border-white/[0.06] -mx-5 -mb-5 mt-5 bg-slate-50/50 dark:bg-white/[0.02] flex items-center justify-end gap-2.5">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 text-xs font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-white/[0.06] rounded-xl transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex items-center gap-1.5 px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-sm shadow-indigo-600/30 transition-all hover:scale-[1.01] active:scale-[0.99]"
                >
                  <Check className="w-3.5 h-3.5" />
                  <span>Create Role</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

