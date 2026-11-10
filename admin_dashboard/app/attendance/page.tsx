'use client';

import React, { useState } from 'react';
import { useHrmAdmin } from '@/lib/store';
import {
  Clock,
  Briefcase,
  MapPin,
  Download,
  Search,
  Building2,
  CheckCircle2,
  ExternalLink,
} from 'lucide-react';
import OutworkApprovalModal from '@/components/OutworkApprovalModal';
import { OutworkRequest } from '@/lib/types';

export default function AttendancePage() {
  const { attendance, outworkRequests, approveOutwork, rejectOutwork } = useHrmAdmin();
  const [filter, setFilter] = useState<'all' | 'office' | 'outwork'>('all');
  const [search, setSearch] = useState('');
  const [selectedOutwork, setSelectedOutwork] = useState<OutworkRequest | null>(null);

  const filtered = attendance.filter((item) => {
    if (filter === 'office' && item.isOutwork) return false;
    if (filter === 'outwork' && !item.isOutwork) return false;
    if (search.trim()) {
      const q = search.toLowerCase();
      return (
        item.employeeName.toLowerCase().includes(q) ||
        item.location.toLowerCase().includes(q) ||
        (item.clientName && item.clientName.toLowerCase().includes(q))
      );
    }
    return true;
  });

  const exportCSV = () => {
    const headers = ['Employee', 'Role', 'Date', 'Clock In', 'Mode', 'Location', 'Client Name', 'Duration'];
    const rows = attendance.map((a) => [
      `"${a.employeeName}"`,
      `"${a.employeeRole}"`,
      `"${a.date}"`,
      `"${a.clockInTime}"`,
      a.isOutwork ? '"Outwork"' : '"In-Office"',
      `"${a.location}"`,
      `"${a.clientName || 'Head Office'}"`,
      `"${Math.floor(a.durationMinutes / 60)}h ${a.durationMinutes % 60}m"`,
    ]);
    const csvContent = 'data:text/csv;charset=utf-8,' + [headers.join(','), ...rows.map((e) => e.join(','))].join('\n');
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', `VertexHand_Attendance_${new Date().toISOString().substring(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
              Live Attendance & Outwork Monitor
            </h1>
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
          </div>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
            Real-time shift punches, office geofence verification & outdoor duty audits
          </p>
        </div>

        <button
          onClick={exportCSV}
          className="flex items-center gap-2 px-3.5 py-2 text-xs font-semibold rounded-xl bg-slate-900 dark:bg-white text-white dark:text-slate-900 hover:opacity-90 transition-opacity self-start sm:self-auto shadow-sm"
        >
          <Download className="w-3.5 h-3.5" />
          <span>Export CSV Report</span>
        </button>
      </div>

      {/* Filter / Search Bar */}
      <div className="p-4 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div className="flex items-center gap-2">
          <button
            onClick={() => setFilter('all')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
              filter === 'all'
                ? 'bg-indigo-600 text-white shadow-sm'
                : 'bg-slate-100 dark:bg-white/[0.05] text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-white/[0.08]'
            }`}
          >
            All Shifts ({attendance.length})
          </button>
          <button
            onClick={() => setFilter('office')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
              filter === 'office'
                ? 'bg-indigo-600 text-white shadow-sm'
                : 'bg-slate-100 dark:bg-white/[0.05] text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-white/[0.08]'
            }`}
          >
            In-Office ({attendance.filter((a) => !a.isOutwork).length})
          </button>
          <button
            onClick={() => setFilter('outwork')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
              filter === 'outwork'
                ? 'bg-indigo-600 text-white shadow-sm'
                : 'bg-slate-100 dark:bg-white/[0.05] text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-white/[0.08]'
            }`}
          >
            Outwork ({attendance.filter((a) => a.isOutwork).length})
          </button>
        </div>

        <div className="relative w-full sm:w-72">
          <Search className="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search by name, site, or location..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl pl-9 pr-4 py-1.5 text-xs text-slate-900 dark:text-slate-100 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
          />
        </div>
      </div>

      {/* Attendance Table */}
      <div className="rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b border-slate-200/80 dark:border-white/[0.06] bg-slate-50/70 dark:bg-white/[0.02] text-slate-500 dark:text-slate-400 font-semibold uppercase tracking-wider text-[10px]">
                <th className="p-4">Employee</th>
                <th className="p-4">Punch Time</th>
                <th className="p-4">Mode & Status</th>
                <th className="p-4">Location / Client Site</th>
                <th className="p-4">Shift Duration</th>
                <th className="p-4 text-right">Proof / Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-white/[0.04] font-medium text-slate-800 dark:text-slate-200">
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-12 text-center">
                    <div className="flex flex-col items-center justify-center space-y-2">
                      <Clock className="w-8 h-8 text-slate-300 dark:text-slate-600 mb-1" />
                      <p className="text-xs font-semibold text-slate-700 dark:text-slate-300">
                        No attendance punches found
                      </p>
                      <p className="text-[11px] text-slate-400">
                        Staff punches clocked via mobile apps will appear in this real-time register
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                filtered.map((record) => {
                  const outworkReq = outworkRequests.find((r) => r.employeeId === record.employeeId);

                  return (
                    <tr
                      key={record.id}
                      className="hover:bg-slate-50/80 dark:hover:bg-white/[0.02] transition-colors"
                    >
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 font-bold flex items-center justify-center text-xs">
                            {record.employeeName.substring(0, 2).toUpperCase()}
                          </div>
                          <div>
                            <p className="font-bold text-slate-900 dark:text-white leading-tight">
                              {record.employeeName}
                            </p>
                            <p className="text-[11px] text-slate-400">{record.employeeRole}</p>
                          </div>
                        </div>
                      </td>

                      <td className="p-4">
                        <div className="flex items-center gap-1.5 font-mono text-xs">
                          <Clock className="w-3.5 h-3.5 text-slate-400" />
                          <span>{record.clockInTime}</span>
                        </div>
                        <span className="text-[10px] text-slate-400">{record.date}</span>
                      </td>

                      <td className="p-4">
                        {record.isOutwork ? (
                          <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20">
                            <Briefcase className="w-3 h-3" />
                            <span>Outwork Active</span>
                          </div>
                        ) : (
                          <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20">
                            <CheckCircle2 className="w-3 h-3" />
                            <span>In-Office Geofence</span>
                          </div>
                        )}
                      </td>

                      <td className="p-4">
                        <div>
                          {record.clientName && (
                            <p className="font-bold text-slate-900 dark:text-white flex items-center gap-1">
                              <Building2 className="w-3 h-3 text-slate-400" />
                              <span>{record.clientName}</span>
                            </p>
                          )}
                          <p className="text-[11px] text-slate-500 dark:text-slate-400 flex items-center gap-1 mt-0.5">
                            <MapPin className="w-3 h-3 text-slate-400 shrink-0" />
                            <span>{record.location}</span>
                          </p>
                        </div>
                      </td>

                      <td className="p-4 font-mono">
                        <span className="font-bold text-slate-900 dark:text-white">
                          {Math.floor(record.durationMinutes / 60)}h {record.durationMinutes % 60}m
                        </span>
                        <p className="text-[10px] text-slate-400">of 9h shift</p>
                      </td>

                      <td className="p-4 text-right">
                        {record.isOutwork && outworkReq ? (
                          <button
                            onClick={() => setSelectedOutwork(outworkReq)}
                            className="px-2.5 py-1 text-[11px] font-semibold rounded-lg bg-indigo-50 dark:bg-indigo-950/40 text-indigo-600 dark:text-indigo-400 border border-indigo-200 dark:border-indigo-800/40 hover:bg-indigo-100 transition-colors inline-flex items-center gap-1"
                          >
                            <span>Review Duty</span>
                            <ExternalLink className="w-3 h-3" />
                          </button>
                        ) : (
                          <span className="text-[11px] text-slate-400 font-medium">Verified</span>
                        )}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      <OutworkApprovalModal
        request={selectedOutwork}
        onClose={() => setSelectedOutwork(null)}
        onApprove={approveOutwork}
        onReject={rejectOutwork}
      />
    </div>
  );
}
