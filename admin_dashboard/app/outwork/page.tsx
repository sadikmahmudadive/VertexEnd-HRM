'use client';

import React, { useState } from 'react';
import { useHrmAdmin } from '@/lib/store';
import {
  Briefcase,
  Building2,
  MapPin,
  Check,
  X,
  ExternalLink,
} from 'lucide-react';
import OutworkApprovalModal from '@/components/OutworkApprovalModal';
import { OutworkRequest } from '@/lib/types';

export default function OutworkPage() {
  const { outworkRequests, approveOutwork, rejectOutwork } = useHrmAdmin();
  const [filter, setFilter] = useState<'all' | 'pending' | 'approved'>('all');
  const [selectedRequest, setSelectedRequest] = useState<OutworkRequest | null>(null);

  const filtered = outworkRequests.filter((r) => {
    if (filter === 'pending') return r.status === 'Pending';
    if (filter === 'approved') return r.status === 'Approved';
    return true;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
              Field Duty & Outwork Management
            </h1>
            <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20">
              Geofence Exemption System
            </span>
          </div>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
            Audit outdoor client visits, inspect on-site photo proofs via Cloudinary, and manage exemptions
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
            All Requests ({outworkRequests.length})
          </button>
          <button
            onClick={() => setFilter('pending')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
              filter === 'pending'
                ? 'bg-amber-600 text-white shadow-sm'
                : 'bg-slate-100 dark:bg-white/[0.05] text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-white/[0.08]'
            }`}
          >
            Pending ({outworkRequests.filter((r) => r.status === 'Pending').length})
          </button>
          <button
            onClick={() => setFilter('approved')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
              filter === 'approved'
                ? 'bg-emerald-600 text-white shadow-sm'
                : 'bg-slate-100 dark:bg-white/[0.05] text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-white/[0.08]'
            }`}
          >
            Approved ({outworkRequests.filter((r) => r.status === 'Approved').length})
          </button>
        </div>
      </div>

      {/* Grid of Outwork Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {filtered.length === 0 ? (
          <div className="col-span-full py-16 flex flex-col items-center justify-center text-center space-y-2 p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm">
            <Briefcase className="w-10 h-10 text-slate-300 dark:text-slate-600 mb-1" />
            <p className="text-sm font-semibold text-slate-700 dark:text-slate-300">
              No field outwork requests
            </p>
            <p className="text-xs text-slate-400 max-w-sm">
              Outdoor duty requests with client details, schedule, and on-site photos will appear here
            </p>
          </div>
        ) : (
          filtered.map((item) => (
          <div
            key={item.id}
            className="rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm overflow-hidden flex flex-col justify-between hover:border-slate-300 dark:hover:border-white/15 transition-all group"
          >
            {/* Cloudinary On-Site Proof Photo Banner (if available) */}
            {item.proofImageUrl ? (
              <div className="relative h-44 bg-slate-900 overflow-hidden">
                <img
                  src={item.proofImageUrl}
                  alt={item.clientName}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-[#0f1422] via-black/30 to-transparent"></div>
                <div className="absolute top-3 left-3 px-2 py-0.5 rounded-md bg-black/60 backdrop-blur-md text-[10px] text-white font-medium flex items-center gap-1 border border-white/10">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                  Cloudinary Proof
                </div>
                <div className="absolute bottom-3 left-3 right-3 text-white">
                  <p className="text-xs font-bold leading-tight flex items-center gap-1">
                    <Building2 className="w-3.5 h-3.5 text-amber-400" />
                    <span>{item.clientName}</span>
                  </p>
                  <p className="text-[11px] text-slate-300 flex items-center gap-1 mt-0.5">
                    <MapPin className="w-3 h-3 text-slate-400" />
                    <span>{item.location}</span>
                  </p>
                </div>
              </div>
            ) : (
              <div className="p-5 pb-0">
                <div className="p-3 rounded-xl bg-slate-50 dark:bg-white/[0.02] border border-slate-200/60 dark:border-white/[0.06] flex items-center gap-2 text-xs">
                  <Building2 className="w-4 h-4 text-indigo-500" />
                  <span className="font-bold text-slate-900 dark:text-white">{item.clientName}</span>
                </div>
              </div>
            )}

            {/* Content */}
            <div className="p-5 space-y-3 flex-1">
              <div className="flex items-center justify-between">
                <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20">
                  {item.category}
                </span>
                <span
                  className={`text-[11px] font-bold px-2.5 py-0.5 rounded-full ${
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

              {/* Employee & Schedule */}
              <div className="space-y-1.5 text-xs">
                <div className="flex items-center gap-2">
                  <span className="text-slate-400 font-medium">Assigned:</span>
                  <span className="font-bold text-slate-900 dark:text-white">
                    {item.employeeName}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-slate-400 font-medium">Schedule:</span>
                  <span className="font-semibold text-slate-700 dark:text-slate-300">
                    {item.schedule}
                  </span>
                </div>
              </div>

              {/* Reason / Agenda */}
              <p className="text-xs text-slate-600 dark:text-slate-400 line-clamp-2 leading-relaxed bg-slate-50/80 dark:bg-white/[0.02] p-2.5 rounded-xl border border-slate-200/60 dark:border-white/[0.06]">
                &ldquo;{item.reason}&rdquo;
              </p>
            </div>

            {/* Actions */}
            <div className="p-4 border-t border-slate-100 dark:border-white/[0.05] bg-slate-50/50 dark:bg-white/[0.01] flex items-center justify-between gap-2">
              <button
                onClick={() => setSelectedRequest(item)}
                className="text-xs font-semibold text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 flex items-center gap-1"
              >
                <span>Full Details</span>
                <ExternalLink className="w-3.5 h-3.5" />
              </button>

              {item.status === 'Pending' ? (
                <div className="flex items-center gap-1.5">
                  <button
                    onClick={() => rejectOutwork(item.id)}
                    className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/10 flex items-center justify-center text-rose-500 hover:bg-rose-500/10 transition-colors"
                    title="Reject"
                  >
                    <X className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => approveOutwork(item.id)}
                    className="flex items-center gap-1 px-3 py-1.5 text-xs font-semibold rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white shadow-sm shadow-indigo-600/30 transition-all"
                  >
                    <Check className="w-3.5 h-3.5" />
                    <span>Approve</span>
                  </button>
                </div>
              ) : (
                <span className="text-[11px] font-semibold text-slate-400">
                  Decision Recorded
                </span>
              )}
            </div>
          </div>
        )))}
      </div>

      <OutworkApprovalModal
        request={selectedRequest}
        onClose={() => setSelectedRequest(null)}
        onApprove={approveOutwork}
        onReject={rejectOutwork}
      />
    </div>
  );
}
