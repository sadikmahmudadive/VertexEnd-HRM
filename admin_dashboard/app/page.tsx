'use client';

import React, { useState } from 'react';
import StatsCards from '@/components/StatsCards';
import AttendanceChart from '@/components/AttendanceChart';
import DepartmentBreakdown from '@/components/DepartmentBreakdown';
import OutworkApprovalModal from '@/components/OutworkApprovalModal';
import ExpenseModal from '@/components/ExpenseModal';
import { useHrmAdmin } from '@/lib/store';
import {
  Briefcase,
  Check,
  X,
  ExternalLink,
  MapPin,
  Clock,
  ArrowRight,
  ShieldCheck,
  Building2,
  CheckCircle2,
  Inbox,
} from 'lucide-react';
import Link from 'next/link';
import { OutworkRequest, ExpenseClaim } from '@/lib/types';

export default function OverviewPage() {
  const {
    outworkRequests,
    leaveRequests,
    expenseClaims,
    approveOutwork,
    rejectOutwork,
    approveLeave,
    rejectLeave,
    approveExpense,
    rejectExpense,
    currentUser,
  } = useHrmAdmin();

  const [selectedOutwork, setSelectedOutwork] = useState<OutworkRequest | null>(null);
  const [selectedExpense, setSelectedExpense] = useState<ExpenseClaim | null>(null);

  const pendingLeaves = leaveRequests.filter((r) => r.status === 'Pending');
  const pendingOutworks = outworkRequests.filter((r) => r.status === 'Pending');
  const pendingExpenses = expenseClaims.filter((c) => c.status === 'Pending');

  return (
    <div className="space-y-6">
      {/* Executive Overview Header */}
      <div className="relative overflow-hidden rounded-2xl p-6 sm:p-7 bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm">
        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-5">
          <div className="max-w-xl space-y-2">
            <div className="inline-flex items-center gap-2 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
              <span>Operations Live · Ready for Clock-Ins</span>
            </div>

            <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-slate-900 dark:text-white">
              Welcome back, {currentUser?.displayName || 'Super Admin'}
            </h1>
            <p className="text-xs sm:text-sm text-slate-500 dark:text-slate-400 leading-relaxed">
              {currentUser?.companyName || 'Acme Bangladesh Ltd'} workspace is active ({currentUser?.companyCode || 'ACME-DHK'}). Monitor team presence, audit outdoor outwork punches, and review employee leave or expense claims.
            </p>
          </div>

          {/* Quick Shortcuts */}
          <div className="flex flex-wrap items-center gap-2.5 shrink-0">
            <Link
              href="/attendance"
              className="px-4 py-2 text-xs font-semibold rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white transition-all shadow-sm shadow-indigo-600/25 flex items-center gap-1.5"
            >
              <Clock className="w-3.5 h-3.5" />
              <span>Live Attendance</span>
            </Link>
            <Link
              href="/outwork"
              className="px-4 py-2 text-xs font-semibold rounded-xl bg-slate-100 hover:bg-slate-200 dark:bg-white/[0.05] dark:hover:bg-white/[0.09] text-slate-800 dark:text-slate-200 border border-slate-200/80 dark:border-white/[0.08] transition-all flex items-center gap-1.5"
            >
              <Briefcase className="w-3.5 h-3.5 text-amber-500" />
              <span>Field Outwork ({pendingOutworks.length})</span>
            </Link>
          </div>
        </div>
      </div>

      {/* KPI Stats Cards */}
      <StatsCards />

      {/* Charts & Breakdown Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <AttendanceChart />
        </div>
        <div>
          <DepartmentBreakdown />
        </div>
      </div>

      {/* Two-Column Section: Outwork Active Feeds & Approvals Queue */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Live Outwork / Field Duty Punches */}
        <div className="p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-xl bg-amber-500/10 text-amber-500 flex items-center justify-center border border-amber-500/15">
                <Briefcase className="w-4 h-4" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                  Field Duty / Outwork Feed
                </h3>
                <p className="text-[11px] text-slate-500 dark:text-slate-400">
                  Staff actively on field duty outside office geofence
                </p>
              </div>
            </div>
            <Link
              href="/outwork"
              className="text-xs font-semibold text-indigo-600 dark:text-indigo-400 hover:underline flex items-center gap-1"
            >
              <span>View All</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>

          {outworkRequests.length === 0 ? (
            <div className="py-8 flex flex-col items-center justify-center text-center space-y-2">
              <div className="w-10 h-10 rounded-xl bg-slate-100 dark:bg-white/[0.04] flex items-center justify-center text-slate-400">
                <Briefcase className="w-5 h-5 text-amber-500/60" />
              </div>
              <p className="text-xs font-semibold text-slate-700 dark:text-slate-300">
                No active field duty punches
              </p>
              <p className="text-[11px] text-slate-400 max-w-xs">
                Staff clocked in outside office geofence will appear here with location & client tags
              </p>
            </div>
          ) : (
            <div className="space-y-2.5">
              {outworkRequests.slice(0, 3).map((item) => (
                <div
                  key={item.id}
                  className="p-3.5 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06] flex items-start justify-between gap-3 hover:border-slate-300 dark:hover:border-white/15 transition-all"
                >
                  <div className="flex items-start gap-3">
                    {item.employeeAvatar ? (
                      <img
                        src={item.employeeAvatar}
                        alt={item.employeeName}
                        className="w-9 h-9 rounded-full object-cover ring-2 ring-amber-500/20 shrink-0"
                      />
                    ) : (
                      <div className="w-9 h-9 rounded-full bg-amber-500/20 text-amber-600 dark:text-amber-400 font-bold flex items-center justify-center text-xs shrink-0">
                        {item.employeeName.substring(0, 2).toUpperCase()}
                      </div>
                    )}
                    <div>
                      <div className="flex items-center gap-2">
                        <p className="text-xs font-bold text-slate-900 dark:text-white">
                          {item.employeeName}
                        </p>
                        <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20">
                          {item.category}
                        </span>
                      </div>

                      <div className="flex items-center gap-1.5 text-xs font-medium text-slate-700 dark:text-slate-300 mt-1">
                        <Building2 className="w-3 h-3 text-slate-400" />
                        <span>{item.clientName}</span>
                      </div>

                      <div className="flex items-center gap-1.5 text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">
                        <MapPin className="w-3 h-3 text-slate-400" />
                        <span>{item.location}</span>
                      </div>
                    </div>
                  </div>

                  <div className="text-right flex flex-col items-end gap-1.5 shrink-0">
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
                    <button
                      onClick={() => setSelectedOutwork(item)}
                      className="text-[11px] font-semibold text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 flex items-center gap-1"
                    >
                      <span>Inspect</span>
                      <ExternalLink className="w-3 h-3" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Pending Approval Center */}
        <div className="p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-xl bg-purple-500/10 text-purple-500 flex items-center justify-center border border-purple-500/15">
                <ShieldCheck className="w-4 h-4" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                  Pending Approvals Queue
                </h3>
                <p className="text-[11px] text-slate-500 dark:text-slate-400">
                  {pendingLeaves.length + pendingExpenses.length} requests awaiting managerial decision
                </p>
              </div>
            </div>
            <Link
              href="/leaves"
              className="text-xs font-semibold text-indigo-600 dark:text-indigo-400 hover:underline flex items-center gap-1"
            >
              <span>Manage</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>

          {pendingLeaves.length === 0 && pendingExpenses.length === 0 ? (
            <div className="py-8 flex flex-col items-center justify-center text-center space-y-2">
              <div className="w-10 h-10 rounded-xl bg-slate-100 dark:bg-white/[0.04] flex items-center justify-center text-slate-400">
                <CheckCircle2 className="w-5 h-5 text-emerald-500/80" />
              </div>
              <p className="text-xs font-semibold text-slate-700 dark:text-slate-300">
                All caught up!
              </p>
              <p className="text-[11px] text-slate-400 max-w-xs">
                No pending leave requests or expense claims requiring managerial decision
              </p>
            </div>
          ) : (
            <div className="space-y-2.5">
              {pendingLeaves.slice(0, 2).map((item) => (
                <div
                  key={item.id}
                  className="p-3.5 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06] flex items-center justify-between gap-3"
                >
                  <div>
                    <div className="flex items-center gap-2">
                      <p className="text-xs font-bold text-slate-900 dark:text-white">
                        {item.employeeName}
                      </p>
                      <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-purple-500/10 text-purple-600 dark:text-purple-400 border border-purple-500/20">
                        {item.leaveType} · {item.days}d
                      </span>
                    </div>
                    <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-1">
                      {item.dates} — {item.reason}
                    </p>
                  </div>
                  <div className="flex items-center gap-1.5 shrink-0">
                    <button
                      onClick={() => rejectLeave(item.id)}
                      className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/10 flex items-center justify-center text-rose-500 hover:bg-rose-500/10 transition-colors"
                      title="Reject"
                    >
                      <X className="w-3.5 h-3.5" />
                    </button>
                    <button
                      onClick={() => approveLeave(item.id)}
                      className="w-7 h-7 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white flex items-center justify-center shadow-sm shadow-indigo-600/30 transition-all"
                      title="Approve"
                    >
                      <Check className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              ))}

              {pendingExpenses.slice(0, 2).map((claim) => (
                <div
                  key={claim.id}
                  className="p-3.5 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06] flex items-center justify-between gap-3"
                >
                  <div>
                    <div className="flex items-center gap-2">
                      <p className="text-xs font-bold text-slate-900 dark:text-white">
                        {claim.employeeName}
                      </p>
                      <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-sky-500/10 text-sky-600 dark:text-sky-400 border border-sky-500/20">
                        {claim.category}
                      </span>
                    </div>
                    <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-1">
                      {claim.title} · <span className="font-bold text-slate-800 dark:text-slate-200">৳ {claim.amount.toLocaleString()}</span>
                    </p>
                  </div>
                  <div className="flex items-center gap-1.5 shrink-0">
                    <button
                      onClick={() => setSelectedExpense(claim)}
                      className="px-2.5 py-1 text-[11px] font-semibold rounded-lg bg-slate-200/80 dark:bg-white/[0.06] text-slate-700 dark:text-slate-300 hover:bg-slate-300 dark:hover:bg-white/10 transition-colors"
                    >
                      Receipt
                    </button>
                    <button
                      onClick={() => approveExpense(claim.id)}
                      className="w-7 h-7 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white flex items-center justify-center shadow-sm shadow-indigo-600/30 transition-all"
                      title="Approve"
                    >
                      <Check className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Modals */}
      <OutworkApprovalModal
        request={selectedOutwork}
        onClose={() => setSelectedOutwork(null)}
        onApprove={approveOutwork}
        onReject={rejectOutwork}
      />

      <ExpenseModal
        claim={selectedExpense}
        onClose={() => setSelectedExpense(null)}
        onApprove={approveExpense}
        onReject={rejectExpense}
      />
    </div>
  );
}
