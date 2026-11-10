'use client';

import React from 'react';
import { X, Check, MapPin, Building2, Calendar, ExternalLink, Cloud } from 'lucide-react';
import { OutworkRequest } from '@/lib/types';

interface OutworkModalProps {
  request: OutworkRequest | null;
  onClose: () => void;
  onApprove: (id: string) => void;
  onReject: (id: string) => void;
}

export default function OutworkApprovalModal({
  request,
  onClose,
  onApprove,
  onReject,
}: OutworkModalProps) {
  if (!request) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-in fade-in duration-200">
      <div className="bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.08] rounded-2xl max-w-lg w-full overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="p-5 border-b border-slate-100 dark:border-white/[0.06] flex items-center justify-between">
          <div>
            <div className="flex items-center gap-2">
              <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20">
                Outwork Duty
              </span>
              <span className="text-xs text-slate-500 dark:text-slate-400">
                {request.createdAt}
              </span>
            </div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white mt-1">
              {request.category} at {request.clientName}
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
          {/* Employee Card */}
          <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06]">
            {request.employeeAvatar ? (
              <img
                src={request.employeeAvatar}
                alt={request.employeeName}
                className="w-10 h-10 rounded-full object-cover ring-2 ring-indigo-500/20"
              />
            ) : (
              <div className="w-10 h-10 rounded-full bg-indigo-600 text-white font-bold flex items-center justify-center text-sm">
                {request.employeeName.substring(0, 2).toUpperCase()}
              </div>
            )}
            <div>
              <p className="text-sm font-semibold text-slate-900 dark:text-white leading-tight">
                {request.employeeName}
              </p>
              <p className="text-xs text-slate-500 dark:text-slate-400">
                {request.employeeRole}
              </p>
            </div>
          </div>

          {/* Details Grid */}
          <div className="grid grid-cols-2 gap-3">
            <div className="p-3 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06]">
              <div className="flex items-center gap-1.5 text-xs text-slate-500 dark:text-slate-400 mb-1">
                <Building2 className="w-3.5 h-3.5 text-indigo-500" />
                <span>Client Company</span>
              </div>
              <p className="text-xs font-semibold text-slate-900 dark:text-white">
                {request.clientName}
              </p>
            </div>

            <div className="p-3 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06]">
              <div className="flex items-center gap-1.5 text-xs text-slate-500 dark:text-slate-400 mb-1">
                <MapPin className="w-3.5 h-3.5 text-amber-500" />
                <span>Location</span>
              </div>
              <p className="text-xs font-semibold text-slate-900 dark:text-white">
                {request.location}
              </p>
            </div>

            <div className="p-3 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06] col-span-2">
              <div className="flex items-center gap-1.5 text-xs text-slate-500 dark:text-slate-400 mb-1">
                <Calendar className="w-3.5 h-3.5 text-emerald-500" />
                <span>Schedule & Duration</span>
              </div>
              <p className="text-xs font-semibold text-slate-900 dark:text-white">
                {request.schedule}
              </p>
            </div>
          </div>

          {/* Reason */}
          <div className="space-y-1">
            <p className="text-xs font-semibold text-slate-700 dark:text-slate-300">
              Meeting Purpose / Assignment Description
            </p>
            <div className="p-3 rounded-xl bg-slate-50/80 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06] text-xs text-slate-700 dark:text-slate-300 leading-relaxed">
              &ldquo;{request.reason}&rdquo;
            </div>
          </div>

          {/* Cloudinary On-Site Verification Photo */}
          {request.proofImageUrl && (
            <div className="space-y-2">
              <div className="flex items-center justify-between text-xs text-slate-500 dark:text-slate-400">
                <span className="font-semibold text-slate-800 dark:text-slate-200 flex items-center gap-1.5">
                  <Cloud className="w-3.5 h-3.5 text-sky-500" />
                  <span>On-Site Photo Proof (Cloudinary CDN)</span>
                </span>
                <a
                  href={request.proofImageUrl}
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
                  src={request.proofImageUrl}
                  alt={request.clientName}
                  className="w-full h-52 object-cover"
                />
              </div>
            </div>
          )}
        </div>

        {/* Footer Actions */}
        <div className="p-4 border-t border-slate-100 dark:border-white/[0.06] bg-slate-50/50 dark:bg-white/[0.02] flex items-center justify-end gap-2.5">
          <button
            onClick={onClose}
            className="px-4 py-2 text-xs font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-white/[0.06] rounded-xl transition-colors"
          >
            Close
          </button>

          {request.status === 'Pending' && (
            <>
              <button
                onClick={() => {
                  onReject(request.id);
                  onClose();
                }}
                className="px-3.5 py-2 text-xs font-semibold text-rose-600 dark:text-rose-400 border border-slate-200 dark:border-white/10 hover:bg-rose-500/10 rounded-xl transition-colors"
              >
                Reject Request
              </button>
              <button
                onClick={() => {
                  onApprove(request.id);
                  onClose();
                }}
                className="flex items-center gap-1.5 px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-sm shadow-indigo-600/30 transition-all hover:scale-[1.01] active:scale-[0.99]"
              >
                <Check className="w-3.5 h-3.5" />
                <span>Approve Exemption</span>
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
