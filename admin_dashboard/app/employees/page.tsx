'use client';

import React, { useState } from 'react';
import { useHrmAdmin } from '@/lib/store';
import {
  Users,
  Search,
  Plus,
  Mail,
  Phone,
  Building2,
  Calendar,
  ShieldCheck,
  Check,
  X,
  Trash2,
} from 'lucide-react';
import AddEmployeeModal from '@/components/AddEmployeeModal';
import { Employee, CompanyRole } from '@/lib/types';

export default function EmployeesPage() {
  const { employees, addEmployee, deleteEmployee, roles, assignRoleToEmployee, currentUser } = useHrmAdmin();
  const [search, setSearch] = useState('');
  const [selectedDept, setSelectedDept] = useState('All');
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [assigningEmp, setAssigningEmp] = useState<Employee | null>(null);

  const departments = ['All', 'Engineering', 'Design', 'Sales', 'Finance', 'People'];

  const filtered = employees.filter((e) => {
    if (selectedDept !== 'All' && !e.dept.toLowerCase().includes(selectedDept.toLowerCase())) {
      return false;
    }
    if (search.trim()) {
      const q = search.toLowerCase();
      return (
        e.name.toLowerCase().includes(q) ||
        e.role.toLowerCase().includes(q) ||
        e.email.toLowerCase().includes(q) ||
        e.employeeId.toLowerCase().includes(q)
      );
    }
    return true;
  });

  const handleRoleChange = async (role: CompanyRole) => {
    if (!assigningEmp) return;
    await assignRoleToEmployee(assigningEmp.id, role.name, role.id);
    setAssigningEmp(null);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
              Employee Directory & Role Assignment
            </h1>
            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-purple-500/10 text-purple-600 dark:text-purple-400 border border-purple-500/20">
              Super Admin Control
            </span>
          </div>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
            {employees.length} team members registered at {currentUser?.companyName || 'Acme Bangladesh Ltd'} ({currentUser?.companyCode || 'ACME-DHK'})
          </p>
        </div>

        <button
          onClick={() => setIsAddOpen(true)}
          className="flex items-center gap-2 px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-sm shadow-indigo-600/30 transition-all self-start sm:self-auto hover:scale-[1.01] active:scale-[0.99]"
        >
          <Plus className="w-3.5 h-3.5" />
          <span>Add New Employee</span>
        </button>
      </div>

      {/* Filter and Search */}
      <div className="p-4 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div className="flex flex-wrap items-center gap-1.5">
          {departments.map((d) => (
            <button
              key={d}
              onClick={() => setSelectedDept(d)}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
                selectedDept === d
                  ? 'bg-indigo-600 text-white shadow-sm'
                  : 'bg-slate-100 dark:bg-white/[0.05] text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-white/[0.08]'
              }`}
            >
              {d}
            </button>
          ))}
        </div>

        <div className="relative w-full sm:w-72">
          <Search className="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search by name, role, email..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl pl-9 pr-4 py-1.5 text-xs text-slate-900 dark:text-slate-100 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
          />
        </div>
      </div>

      {/* Employees Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {filtered.length === 0 ? (
          <div className="col-span-full py-16 flex flex-col items-center justify-center text-center space-y-3 p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm">
            <Users className="w-10 h-10 text-slate-300 dark:text-slate-600 mb-1" />
            <p className="text-sm font-semibold text-slate-700 dark:text-slate-300">
              No employees in directory
            </p>
            <p className="text-xs text-slate-400 max-w-sm">
              Get started by registering team members using the &quot;Add New Employee&quot; button above
            </p>
          </div>
        ) : (
          filtered.map((emp) => {
            const roleObj = roles.find(
              (r) => r.id === emp.roleId || r.name.toLowerCase() === emp.role.toLowerCase()
            );

            return (
              <div
                key={emp.id}
                className="rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm p-5 space-y-4 hover:border-slate-300 dark:hover:border-white/15 transition-all group"
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    {emp.avatarUrl ? (
                      <img
                        src={emp.avatarUrl}
                        alt={emp.name}
                        className="w-11 h-11 rounded-full object-cover ring-2 ring-indigo-500/20"
                      />
                    ) : (
                      <div className="w-11 h-11 rounded-full bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 font-extrabold flex items-center justify-center text-sm border border-indigo-500/20">
                        {emp.name.substring(0, 2).toUpperCase()}
                      </div>
                    )}
                    <div>
                      <h3 className="font-bold text-sm text-slate-900 dark:text-white leading-tight">
                        {emp.name}
                      </h3>
                      <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">{emp.role}</p>
                    </div>
                  </div>

                  <span
                    className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                      emp.status === 'Active' || emp.status === 'In office'
                        ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20'
                        : 'bg-slate-100 dark:bg-white/[0.05] text-slate-400 border border-slate-200/80 dark:border-white/[0.07]'
                    }`}
                  >
                    {emp.status}
                  </span>
                </div>

                {/* Role Badge & Re-assign button */}
                <div className="p-2.5 rounded-xl bg-slate-50 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.05] flex items-center justify-between">
                  <div className="flex items-center gap-1.5 min-w-0">
                    <ShieldCheck className="w-3.5 h-3.5 text-purple-500 shrink-0" />
                    <span className="text-[11px] text-slate-400 shrink-0">Role:</span>
                    <span
                      className={`text-[10px] font-bold px-2 py-0.5 rounded-full border truncate ${
                        roleObj?.color || 'bg-slate-500/10 text-slate-500 border-slate-500/20'
                      }`}
                    >
                      {roleObj?.name || emp.role}
                    </span>
                  </div>

                  <div className="flex items-center gap-2 shrink-0">
                    <button
                      onClick={() => setAssigningEmp(emp)}
                      className="text-[11px] font-semibold text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 hover:underline"
                    >
                      Change Role
                    </button>
                    <button
                      onClick={() => {
                        if (confirm(`Remove ${emp.name} from directory?`)) {
                          deleteEmployee(emp.id);
                        }
                      }}
                      className="p-1 rounded-md text-slate-400 hover:text-rose-500 hover:bg-rose-500/10 transition-colors"
                      title="Remove Staff"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>

                <div className="space-y-1.5 text-xs text-slate-600 dark:text-slate-400 pt-1 border-t border-slate-100 dark:border-white/[0.05]">
                  <div className="flex items-center gap-2">
                    <Building2 className="w-3.5 h-3.5 text-slate-400" />
                    <span>
                      {emp.dept} · <span className="font-mono text-slate-500 dark:text-slate-400">{emp.employeeId}</span>
                    </span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Mail className="w-3.5 h-3.5 text-slate-400" />
                    <span className="truncate">{emp.email}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Phone className="w-3.5 h-3.5 text-slate-400" />
                    <span>{emp.phone}</span>
                  </div>
                </div>

                <div className="pt-2 flex items-center justify-between text-[11px] text-slate-400 border-t border-slate-100 dark:border-white/[0.05]">
                  <div className="flex items-center gap-1">
                    <Calendar className="w-3 h-3" />
                    <span>Joined {emp.joinDate}</span>
                  </div>
                  <span className="font-semibold text-slate-700 dark:text-slate-300">
                    {emp.status}
                  </span>
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Role Assignment Modal */}
      {assigningEmp && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-in fade-in duration-200">
          <div className="bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.08] rounded-2xl max-w-md w-full overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
            <div className="p-5 border-b border-slate-100 dark:border-white/[0.06] flex items-center justify-between">
              <div>
                <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                  Assign Company Role
                </h3>
                <p className="text-[11px] text-slate-500 dark:text-slate-400">
                  Select new role permissions for {assigningEmp.name}
                </p>
              </div>
              <button
                onClick={() => setAssigningEmp(null)}
                className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/10 flex items-center justify-center text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </div>

            <div className="p-5 space-y-2.5 max-h-[60vh] overflow-y-auto">
              {roles.map((r) => {
                const isSelected =
                  assigningEmp.roleId === r.id ||
                  assigningEmp.role.toLowerCase() === r.name.toLowerCase();

                return (
                  <button
                    key={r.id}
                    onClick={() => handleRoleChange(r)}
                    className={`w-full p-3.5 rounded-xl border text-left transition-all flex items-start justify-between gap-3 ${
                      isSelected
                        ? 'border-indigo-500 bg-indigo-50/50 dark:bg-indigo-950/20'
                        : 'border-slate-200/80 dark:border-white/[0.07] bg-white dark:bg-white/[0.02] hover:border-slate-300 dark:hover:border-white/15'
                    }`}
                  >
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${r.color}`}>
                          {r.name}
                        </span>
                        {isSelected && (
                          <span className="text-[10px] font-bold text-indigo-600 dark:text-indigo-400">
                            Current Role
                          </span>
                        )}
                      </div>
                      <p className="text-[11px] text-slate-500 dark:text-slate-400 leading-snug">
                        {r.description}
                      </p>
                    </div>

                    {isSelected && (
                      <div className="w-5 h-5 rounded-full bg-indigo-600 text-white flex items-center justify-center shrink-0">
                        <Check className="w-3 h-3" />
                      </div>
                    )}
                  </button>
                );
              })}
            </div>

            <div className="p-4 border-t border-slate-100 dark:border-white/[0.06] bg-slate-50/50 dark:bg-white/[0.02] flex items-center justify-end">
              <button
                type="button"
                onClick={() => setAssigningEmp(null)}
                className="px-4 py-2 text-xs font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-white/[0.06] rounded-xl transition-colors"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}

      <AddEmployeeModal
        isOpen={isAddOpen}
        onClose={() => setIsAddOpen(false)}
        onAdd={addEmployee}
      />
    </div>
  );
}
