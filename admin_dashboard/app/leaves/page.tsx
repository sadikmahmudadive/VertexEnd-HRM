'use client';

import React, { useState } from 'react';
import { useHrmAdmin } from '@/lib/store';
import { Check, X, Calendar, Clock } from 'lucide-react';

export default function LeavesPage() {
  const { leaveRequests, approveLeave, rejectLeave } = useHrmAdmin();
  const [filter, setFilter] = useState<'all' | 'pending' | 'approved' | 'rejected'>('all');

  const filtered = leaveRequests.filter((l) => {
    if (filter === 'pending') return l.status === 'Pending';
    if (filter === 'approved') return l.status === 'Approved';
    if (filter === 'rejected') return l.status === 'Rejected';
    return true;
  });

  const getUsed = (type: string) =>
    leaveRequests
      .filter((l) => l.leaveType.toLowerCase().includes(type.toLowerCase()) && l.status === 'Approved')
      .reduce((acc, l) => acc + l.days, 0);

  const quotas = [
    { type: 'Annual Leave', total: 14, used: getUsed('Annual'), color: 'bg-emerald-500' },
    { type: 'Sick Leave', total: 10, used: getUsed('Sick'), color: 'bg-rose-500' },
    { type: 'Work From Home', total: 12, used: getUsed('Work From Home'), color: 'bg-indigo-500' },
    { type: 'Comp-Off', total: 4, used: getUsed('Comp-off'), color: 'bg-amber-500' },
  ].map((q) => ({
    ...q,
    remaining: Math.max(q.total - q.used, 0),
  }));

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
          Leave Management & Approvals
        </h1>
        <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
          Review time-off applications, evaluate team coverage impact, and update balances
        </p>
      </div>

      {/* Quota Overview Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {quotas.map((q) => (
          <div
            key={q.type}
            className="p-5 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-2.5"
          >
            <div className="flex items-center justify-between text-xs">
              <span className="font-semibold text-slate-700 dark:text-slate-300">{q.type}</span>
              <span className="text-slate-400 font-medium">{q.remaining}d left</span>
            </div>
            <div className="flex items-baseline justify-between">
              <span className="text-2xl font-extrabold text-slate-900 dark:text-white tracking-tight">
                {q.used} <span className="text-xs font-normal text-slate-400">/ {q.total} used</span>
              </span>
            </div>
            <div className="w-full h-1.5 rounded-full bg-slate-100 dark:bg-white/[0.06] overflow-hidden">
              <div
                style={{ width: `${(q.used / q.total) * 100}%` }}
                className={`h-full ${q.color} rounded-full transition-all duration-500`}
              ></div>
            </div>
          </div>
        ))}
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center gap-2">
        {(['all', 'pending', 'approved', 'rejected'] as const).map((t) => (
          <button
            key={t}
            onClick={() => setFilter(t)}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold capitalize transition-colors ${
              filter === t
                ? 'bg-indigo-600 text-white shadow-sm'
                : 'bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-white/[0.04]'
            }`}
          >
            {t} ({t === 'all' ? leaveRequests.length : leaveRequests.filter((r) => r.status.toLowerCase() === t).length})
          </button>
        ))}
      </div>

      {/* Requests List */}
      <div className="rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm overflow-hidden">
        {filtered.length === 0 ? (
          <div className="p-12 flex flex-col items-center justify-center text-center space-y-2">
            <Calendar className="w-8 h-8 text-slate-300 dark:text-slate-600 mb-1" />
            <p className="text-xs font-semibold text-slate-700 dark:text-slate-300">
              No leave requests found
            </p>
            <p className="text-[11px] text-slate-400">
              Employee leave applications and time-off requests will appear here for manager review
            </p>
          </div>
        ) : (
          <div className="divide-y divide-slate-100 dark:divide-white/[0.04]">
            {filtered.map((item) => (
              <div
                key={item.id}
                className="p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-50/60 dark:hover:bg-white/[0.02] transition-colors"
              >
                <div className="space-y-1.5">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="font-bold text-sm text-slate-900 dark:text-white">
                      {item.employeeName}
                    </span>
                    <span className="text-xs text-slate-400">({item.employeeRole})</span>
                    <span
                      className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                        item.leaveType === 'Annual'
                          ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20'
                          : item.leaveType === 'Sick'
                          ? 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border border-rose-500/20'
                          : 'bg-purple-500/10 text-purple-600 dark:text-purple-400 border border-purple-500/20'
                      }`}
                    >
                      {item.leaveType} · {item.days} days
                    </span>
                    <span
                      className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                        item.status === 'Approved'
                          ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20'
                          : item.status === 'Rejected'
                          ? 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border border-rose-500/20'
                          : 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20'
                      }`}
                    >
                      {item.status}
                    </span>
                  </div>

                  <p className="text-xs text-slate-600 dark:text-slate-300 font-medium">
                    &ldquo;{item.reason}&rdquo;
                  </p>

                  <div className="flex items-center gap-4 text-[11px] text-slate-400">
                    <div className="flex items-center gap-1">
                      <Calendar className="w-3 h-3" />
                      <span>Requested Dates: {item.dates}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Clock className="w-3 h-3" />
                      <span>Applied: {item.createdAt}</span>
                    </div>
                  </div>
                </div>

                {/* Action Buttons */}
                {item.status === 'Pending' ? (
                  <div className="flex items-center gap-2 self-end sm:self-center shrink-0">
                    <button
                      onClick={() => rejectLeave(item.id)}
                      className="flex items-center gap-1 px-3 py-1.5 text-xs font-semibold rounded-xl border border-slate-200 dark:border-white/10 text-rose-500 hover:bg-rose-500/10 transition-colors"
                    >
                      <X className="w-3.5 h-3.5" />
                      <span>Reject</span>
                    </button>
                    <button
                      onClick={() => approveLeave(item.id)}
                      className="flex items-center gap-1 px-3.5 py-1.5 text-xs font-semibold rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white shadow-sm shadow-indigo-600/30 transition-all"
                    >
                      <Check className="w-3.5 h-3.5" />
                      <span>Approve</span>
                    </button>
                  </div>
                ) : (
                  <span className="text-xs font-semibold text-slate-400 self-end sm:self-center">
                    Resolved
                  </span>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
