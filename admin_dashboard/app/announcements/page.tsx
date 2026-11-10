'use client';

import React, { useState } from 'react';
import { useHrmAdmin } from '@/lib/store';
import { Megaphone, Plus, Trash2, Calendar, User, AlertTriangle } from 'lucide-react';
import NewAnnouncementModal from '@/components/NewAnnouncementModal';

export default function AnnouncementsPage() {
  const { announcements, addAnnouncement, deleteAnnouncement } = useHrmAdmin();
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
            Company Announcements & Notices
          </h1>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
            Broadcast official notices, holidays, and policy updates directly to mobile apps
          </p>
        </div>

        <button
          onClick={() => setIsOpen(true)}
          className="flex items-center gap-2 px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-sm shadow-indigo-600/30 transition-all self-start sm:self-auto hover:scale-[1.01] active:scale-[0.99]"
        >
          <Plus className="w-3.5 h-3.5" />
          <span>New Announcement</span>
        </button>
      </div>

      {/* Announcements Feed */}
      <div className="space-y-4">
        {announcements.length === 0 ? (
          <div className="py-16 flex flex-col items-center justify-center text-center space-y-2 p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm">
            <Megaphone className="w-10 h-10 text-slate-300 dark:text-slate-600 mb-1" />
            <p className="text-sm font-semibold text-slate-700 dark:text-slate-300">
              No announcements broadcast yet
            </p>
            <p className="text-xs text-slate-400 max-w-sm">
              Create notices, policy updates, and holiday alerts to push directly to employee mobile apps
            </p>
          </div>
        ) : (
          announcements.map((ann) => (
            <div
              key={ann.id}
              className="p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-3 relative group hover:border-slate-300 dark:hover:border-white/15 transition-all"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span
                    className={`text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full ${
                      ann.priority === 'High'
                        ? 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border border-rose-500/20'
                        : 'bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 border border-indigo-500/20'
                    }`}
                  >
                    {ann.category}
                  </span>

                  {ann.priority === 'High' && (
                    <span className="flex items-center gap-1 text-[11px] font-semibold text-rose-500">
                      <AlertTriangle className="w-3 h-3" />
                      <span>High Priority</span>
                    </span>
                  )}
                </div>

                <div className="flex items-center gap-3">
                  <span className="text-xs text-slate-400 font-medium">{ann.createdAt}</span>
                  <button
                    onClick={() => deleteAnnouncement(ann.id)}
                    className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/10 text-slate-400 hover:text-rose-500 hover:bg-rose-500/10 flex items-center justify-center transition-colors opacity-0 group-hover:opacity-100"
                    title="Remove"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>

              <h3 className="text-base font-bold text-slate-900 dark:text-white leading-snug">
                {ann.title}
              </h3>

              <p className="text-xs text-slate-600 dark:text-slate-300 leading-relaxed whitespace-pre-line">
                {ann.body}
              </p>

              <div className="pt-3 border-t border-slate-100 dark:border-white/[0.05] flex items-center justify-between text-xs text-slate-400">
                <div className="flex items-center gap-1.5 font-medium">
                  <User className="w-3.5 h-3.5 text-indigo-500" />
                  <span>Posted by {ann.authorName}</span>
                </div>
                <span className="text-[11px] font-semibold text-emerald-600 dark:text-emerald-400">
                  Live on Mobile App
                </span>
              </div>
            </div>
          ))
        )}
      </div>

      <NewAnnouncementModal
        isOpen={isOpen}
        onClose={() => setIsOpen(false)}
        onAdd={addAnnouncement}
      />
    </div>
  );
}
