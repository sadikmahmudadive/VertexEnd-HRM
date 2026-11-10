'use client';

import React from 'react';
import { X, Check, ExternalLink, Calendar, User, Cloud } from 'lucide-react';
import { ExpenseClaim } from '@/lib/types';

interface ExpenseModalProps {
  claim: ExpenseClaim | null;
  onClose: () => void;
  onApprove: (id: string) => void;
  onReject: (id: string) => void;
}

export default function ExpenseModal({
  claim,
  onClose,
  onApprove,
  onReject,
}: ExpenseModalProps) {
  if (!claim) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-in fade-in duration-200">
      <div className="bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.08] rounded-2xl max-w-lg w-full overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="p-5 border-b border-slate-100 dark:border-white/[0.06] flex items-center justify-between">
          <div>
            <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-sky-500/10 text-sky-600 dark:text-sky-400 border border-sky-500/20">
              {claim.category} Reimbursement
            </span>
            <h3 className="text-base font-bold text-slate-900 dark:text-white mt-1">
              {claim.title}
            </h3>
          </div>
          <button
            onClick={onClose}
            className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/10 flex items-center justify-center text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>

        {/* Body */}
        <div className="p-5 space-y-4 max-h-[75vh] overflow-y-auto">
          {/* Amount Badge */}
          <div className="p-4 rounded-xl bg-slate-50 dark:bg-white/[0.02] border border-slate-200/70 dark:border-white/[0.07] flex items-center justify-between">
            <div>
              <p className="text-xs text-slate-500 dark:text-slate-400 font-medium">Claim Amount</p>
              <p className="text-2xl font-extrabold text-slate-900 dark:text-white mt-0.5">
                ৳ {claim.amount.toLocaleString()}
              </p>
            </div>
            <div className="text-right">
              <span
                className={`text-xs font-semibold px-2.5 py-1 rounded-full ${
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
          </div>

          {/* Details */}
          <div className="grid grid-cols-2 gap-3 text-xs">
            <div className="p-3 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06]">
              <div className="flex items-center gap-1.5 text-slate-500 dark:text-slate-400 mb-1">
                <User className="w-3.5 h-3.5 text-indigo-500" />
                <span>Submitted by</span>
              </div>
              <p className="font-semibold text-slate-900 dark:text-white">
                {claim.employeeName}
              </p>
            </div>

            <div className="p-3 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06]">
              <div className="flex items-center gap-1.5 text-slate-500 dark:text-slate-400 mb-1">
                <Calendar className="w-3.5 h-3.5 text-emerald-500" />
                <span>Expense Date</span>
              </div>
              <p className="font-semibold text-slate-900 dark:text-white">
                {claim.date}
              </p>
            </div>
          </div>

          {/* Cloudinary Receipt Image */}
          {claim.receiptImageUrl ? (
            <div className="space-y-2">
              <div className="flex items-center justify-between text-xs text-slate-500 dark:text-slate-400">
                <span className="font-semibold text-slate-800 dark:text-slate-200 flex items-center gap-1.5">
                  <Cloud className="w-3.5 h-3.5 text-sky-500" />
                  <span>Cloudinary Receipt Image</span>
                </span>
                <a
                  href={claim.receiptImageUrl}
                  target="_blank"
                  rel="noreferrer"
                  className="flex items-center gap-1 text-indigo-600 dark:text-indigo-400 hover:underline"
                >
                  <span>Open Full Size</span>
                  <ExternalLink className="w-3 h-3" />
                </a>
              </div>
              <div className="rounded-xl overflow-hidden border border-slate-200/80 dark:border-white/[0.08] bg-slate-900">
                <img
                  src={claim.receiptImageUrl}
                  alt={claim.title}
                  className="w-full h-56 object-contain bg-slate-950"
                />
              </div>
            </div>
          ) : null}
        </div>

        {/* Footer Actions */}
        <div className="p-4 border-t border-slate-100 dark:border-white/[0.06] bg-slate-50/50 dark:bg-white/[0.02] flex items-center justify-end gap-2.5">
          <button
            onClick={onClose}
            className="px-4 py-2 text-xs font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-white/[0.06] rounded-xl transition-colors"
          >
            Close
          </button>

          {claim.status === 'Pending' && (
            <>
              <button
                onClick={() => {
                  onReject(claim.id);
                  onClose();
                }}
                className="px-3.5 py-2 text-xs font-semibold text-rose-600 dark:text-rose-400 border border-slate-200 dark:border-white/10 hover:bg-rose-500/10 rounded-xl transition-colors"
              >
                Reject Claim
              </button>
              <button
                onClick={() => {
                  onApprove(claim.id);
                  onClose();
                }}
                className="flex items-center gap-1.5 px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-sm shadow-indigo-600/30 transition-all hover:scale-[1.01] active:scale-[0.99]"
              >
                <Check className="w-3.5 h-3.5" />
                <span>Approve Reimbursement</span>
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
