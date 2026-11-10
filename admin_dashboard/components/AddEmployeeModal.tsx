'use client';

import React, { useState } from 'react';
import { X, UserPlus, Check, ShieldCheck } from 'lucide-react';
import { Employee, Presence } from '@/lib/types';
import { useHrmAdmin } from '@/lib/store';

interface AddEmployeeModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAdd: (emp: Omit<Employee, 'id'>) => Promise<void>;
}

export default function AddEmployeeModal({
  isOpen,
  onClose,
  onAdd,
}: AddEmployeeModalProps) {
  const { roles, currentUser } = useHrmAdmin();

  const [name, setName] = useState('');
  const [role, setRole] = useState('');
  const [roleId, setRoleId] = useState(roles[0]?.id || 'role-staff');
  const [dept, setDept] = useState('Engineering');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('+880 ');
  const [employeeId, setEmployeeId] = useState('ACME-0250');
  const [loading, setLoading] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !role.trim()) return;

    setLoading(true);
    const parts = name.trim().split(' ');
    const initials = parts.length >= 2
      ? `${parts[0][0]}${parts[1][0]}`.toUpperCase()
      : name.substring(0, 2).toUpperCase();

    const selectedRole = roles.find((r) => r.id === roleId);

    await onAdd({
      name: name.trim(),
      initials,
      role: role.trim(),
      roleId: selectedRole?.id || roleId,
      dept,
      presence: 'inOffice' as Presence,
      status: 'In office',
      email: email.trim() || `${parts[0].toLowerCase()}@${(currentUser?.companyName || 'acme').toLowerCase().replace(/\s+/g, '')}.com.bd`,
      phone: phone.trim(),
      companyCode: currentUser?.companyCode || 'ACME-DHK',
      employeeId,
      joinDate: new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' }),
    });

    setLoading(false);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-in fade-in duration-200">
      <div className="bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.08] rounded-2xl max-w-md w-full overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="p-5 border-b border-slate-100 dark:border-white/[0.06] flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 flex items-center justify-center border border-indigo-500/15">
              <UserPlus className="w-4 h-4" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                Add New Employee
              </h3>
              <p className="text-[11px] text-slate-500 dark:text-slate-400">
                Register staff and assign company role
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/10 flex items-center justify-center text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-5 space-y-3.5 text-xs">
          <div>
            <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              Full Name *
            </label>
            <input
              type="text"
              required
              placeholder="e.g. Mahfuz Rahman"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                Designation / Job Title *
              </label>
              <input
                type="text"
                required
                placeholder="e.g. Solutions Architect"
                value={role}
                onChange={(e) => setRole(e.target.value)}
                className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              />
            </div>

            <div>
              <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                Assigned Role Authority
              </label>
              <select
                value={roleId}
                onChange={(e) => setRoleId(e.target.value)}
                className="w-full bg-slate-50 dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              >
                {roles.map((r) => (
                  <option key={r.id} value={r.id}>
                    {r.name}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                Department
              </label>
              <select
                value={dept}
                onChange={(e) => setDept(e.target.value)}
                className="w-full bg-slate-50 dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              >
                <option value="Engineering">Engineering</option>
                <option value="Design">Design</option>
                <option value="Sales">Sales & Marketing</option>
                <option value="Finance">Finance & Accounts</option>
                <option value="People">People / HR</option>
              </select>
            </div>

            <div>
              <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                Employee ID
              </label>
              <input
                type="text"
                value={employeeId}
                onChange={(e) => setEmployeeId(e.target.value)}
                className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 font-mono focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                Work Email
              </label>
              <input
                type="email"
                placeholder="name@acme.com.bd"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              />
            </div>
            <div>
              <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                Phone Number
              </label>
              <input
                type="text"
                placeholder="+880 1700 000000"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              />
            </div>
          </div>

          <div className="p-4 border-t border-slate-100 dark:border-white/[0.06] -mx-5 -mb-5 mt-5 bg-slate-50/50 dark:bg-white/[0.02] flex items-center justify-end gap-2.5">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-xs font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-white/[0.06] rounded-xl transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex items-center gap-1.5 px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-sm shadow-indigo-600/30 transition-all disabled:opacity-50 hover:scale-[1.01] active:scale-[0.99]"
            >
              <Check className="w-3.5 h-3.5" />
              <span>{loading ? 'Saving...' : 'Add Staff Member'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
