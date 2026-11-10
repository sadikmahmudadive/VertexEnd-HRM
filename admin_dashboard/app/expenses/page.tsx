'use client';

import React, { useState } from 'react';
import { useHrmAdmin } from '@/lib/store';
import {
  Receipt,
  Check,
  X,
  ExternalLink,
  Calendar,
  Cloud,
} from 'lucide-react';
import ExpenseModal from '@/components/ExpenseModal';
import { ExpenseClaim } from '@/lib/types';

export default function ExpensesPage() {
  const { expenseClaims, approveExpense, rejectExpense } = useHrmAdmin();
  const [filter, setFilter] = useState<'all' | 'pending' | 'approved'>('all');
  const [selectedClaim, setSelectedClaim] = useState<ExpenseClaim | null>(null);

  const filtered = expenseClaims.filter((c) => {
    if (filter === 'pending') return c.status === 'Pending';
    if (filter === 'approved') return c.status === 'Approved';
    return true;
  });

  const totalApproved = expenseClaims
    .filter((c) => c.status === 'Approved')
    .reduce((acc, c) => acc + c.amount, 0);

  const totalPending = expenseClaims
    .filter((c) => c.status === 'Pending')
    .reduce((acc, c) => acc + c.amount, 0);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
              Expense Reimbursements & Receipts
            </h1>
            <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-sky-500/10 text-sky-600 dark:text-sky-400 border border-sky-500/20 flex items-center gap-1">
              <Cloud className="w-3 h-3" />
              <span>Cloudinary CDN</span>
            </span>
          </div>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
            Audit employee receipts stored on Cloudinary, review vendor bills, and approve for payroll
          </p>
        </div>

        {/* Filter buttons */}
        <div className="flex items-center gap-2">
          <button
            onClick={() => setFilter('all')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
              filter === 'all'
                ? 'bg-indigo-600 text-white shadow-sm'
                : 'bg-slate-100 dark:bg-white/[0.05] text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-white/[0.08]'
            }`}
          >
            All Claims ({expenseClaims.length})
          </button>
          <button
            onClick={() => setFilter('pending')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
              filter === 'pending'
                ? 'bg-amber-600 text-white shadow-sm'
                : 'bg-slate-100 dark:bg-white/[0.05] text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-white/[0.08]'
            }`}
          >
            Pending ({expenseClaims.filter((c) => c.status === 'Pending').length})
          </button>
          <button
            onClick={() => setFilter('approved')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
              filter === 'approved'
                ? 'bg-emerald-600 text-white shadow-sm'
                : 'bg-slate-100 dark:bg-white/[0.05] text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-white/[0.08]'
            }`}
          >
            Approved ({expenseClaims.filter((c) => c.status === 'Approved').length})
          </button>
        </div>
      </div>

      {/* Summary KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="p-5 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-1.5">
          <p className="text-xs text-slate-500 dark:text-slate-400 font-semibold">
            Total Approved (November)
          </p>
          <p className="text-3xl font-extrabold text-emerald-600 dark:text-emerald-400 tracking-tight">
            ৳ {totalApproved.toLocaleString()}
          </p>
          <p className="text-[11px] text-slate-400">Disbursed with monthly payroll</p>
        </div>

        <div className="p-5 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-1.5">
          <p className="text-xs text-slate-500 dark:text-slate-400 font-semibold">
            Pending Approval Queue
          </p>
          <p className="text-3xl font-extrabold text-amber-500 tracking-tight">
            ৳ {totalPending.toLocaleString()}
          </p>
          <p className="text-[11px] text-slate-400">
            {expenseClaims.filter((c) => c.status === 'Pending').length} claims awaiting review
          </p>
        </div>

        <div className="p-5 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-1.5">
          <p className="text-xs text-slate-500 dark:text-slate-400 font-semibold">
            Cloudinary Receipt Vault
          </p>
          <p className="text-3xl font-extrabold text-sky-500 tracking-tight">
            {expenseClaims.filter((c) => c.receiptImageUrl).length} Receipts
          </p>
          <p className="text-[11px] text-slate-400">Securely archived on Cloudinary</p>
        </div>
      </div>

      {/* Claims List */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {filtered.length === 0 ? (
          <div className="col-span-full py-16 flex flex-col items-center justify-center text-center space-y-2 p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm">
            <Receipt className="w-10 h-10 text-slate-300 dark:text-slate-600 mb-1" />
            <p className="text-sm font-semibold text-slate-700 dark:text-slate-300">
              No expense claims submitted
            </p>
            <p className="text-xs text-slate-400 max-w-sm">
              Employee reimbursement claims and receipt scans stored via Cloudinary will appear here
            </p>
          </div>
        ) : (
          filtered.map((claim) => (
            <div
              key={claim.id}
              className="rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm overflow-hidden flex flex-col justify-between hover:border-slate-300 dark:hover:border-white/15 transition-all group"
            >
              {/* Receipt Preview Thumbnail */}
              {claim.receiptImageUrl ? (
                <div
                  onClick={() => setSelectedClaim(claim)}
                  className="relative h-44 bg-slate-900 cursor-pointer overflow-hidden group"
                >
                  <img
                    src={claim.receiptImageUrl}
                    alt={claim.title}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  />
                  <div className="absolute inset-0 bg-black/40 group-hover:bg-black/20 transition-colors flex items-center justify-center opacity-0 group-hover:opacity-100">
                    <span className="px-3 py-1.5 rounded-xl bg-black/80 backdrop-blur-md text-white text-xs font-semibold flex items-center gap-1.5 border border-white/10">
                      <ExternalLink className="w-3.5 h-3.5" />
                      <span>Zoom Receipt</span>
                    </span>
                  </div>
                  <div className="absolute top-3 left-3 px-2 py-0.5 rounded-md bg-black/60 backdrop-blur-md text-[10px] text-white font-medium flex items-center gap-1 border border-white/10">
                    <Cloud className="w-3 h-3 text-sky-400" />
                    <span>Cloudinary Media</span>
                  </div>
                </div>
              ) : (
                <div className="p-5 pb-0">
                  <div className="h-32 rounded-xl border border-dashed border-slate-200/80 dark:border-white/[0.07] bg-slate-50/60 dark:bg-white/[0.02] flex flex-col items-center justify-center text-slate-400 text-xs">
                    <Receipt className="w-7 h-7 mb-1 text-slate-400" />
                    <span>Electronic Claim</span>
                  </div>
                </div>
              )}

              {/* Content */}
              <div className="p-5 space-y-3 flex-1">
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-sky-500/10 text-sky-600 dark:text-sky-400 border border-sky-500/20">
                    {claim.category}
                  </span>
                  <span
                    className={`text-[11px] font-bold px-2.5 py-0.5 rounded-full ${
                      claim.status === 'Approved'
                        ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20'
                        : claim.status === 'Rejected'
                        ? 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border border-rose-500/20'
                        : 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20'
                    }`}
                  >
                    {claim.status}
                  </span>
                </div>

                <div>
                  <h3 className="font-bold text-sm text-slate-900 dark:text-white leading-snug">
                    {claim.title}
                  </h3>
                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                    Submitted by <span className="font-semibold text-slate-700 dark:text-slate-300">{claim.employeeName}</span>
                  </p>
                </div>

                <div className="p-3 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06] flex items-center justify-between text-xs">
                  <div className="flex items-center gap-1 text-slate-400">
                    <Calendar className="w-3.5 h-3.5" />
                    <span>{claim.date}</span>
                  </div>
                  <span className="text-base font-extrabold text-slate-900 dark:text-white">
                    ৳ {claim.amount.toLocaleString()}
                  </span>
                </div>
              </div>

              {/* Actions */}
              <div className="p-4 border-t border-slate-100 dark:border-white/[0.05] bg-slate-50/50 dark:bg-white/[0.01] flex items-center justify-between">
                <button
                  onClick={() => setSelectedClaim(claim)}
                  className="text-xs font-semibold text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 flex items-center gap-1"
                >
                  <span>Audit</span>
                  <ExternalLink className="w-3.5 h-3.5" />
                </button>

                {claim.status === 'Pending' ? (
                  <div className="flex items-center gap-1.5">
                    <button
                      onClick={() => rejectExpense(claim.id)}
                      className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/10 flex items-center justify-center text-rose-500 hover:bg-rose-500/10 transition-colors"
                      title="Reject"
                    >
                      <X className="w-3.5 h-3.5" />
                    </button>
                    <button
                      onClick={() => approveExpense(claim.id)}
                      className="flex items-center gap-1 px-3 py-1.5 text-xs font-semibold rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white shadow-sm shadow-indigo-600/30 transition-all"
                    >
                      <Check className="w-3.5 h-3.5" />
                      <span>Approve</span>
                    </button>
                  </div>
                ) : (
                  <span className="text-[11px] font-semibold text-slate-400">
                    Logged for Payroll
                  </span>
                )}
              </div>
            </div>
          ))
        )}
      </div>

      <ExpenseModal
        claim={selectedClaim}
        onClose={() => setSelectedClaim(null)}
        onApprove={approveExpense}
        onReject={rejectExpense}
      />
    </div>
  );
}
