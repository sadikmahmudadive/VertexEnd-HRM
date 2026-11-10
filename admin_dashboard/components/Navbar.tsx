'use client';

import React from 'react';
import { Search, Bell, Plus, Cloud, ShieldCheck } from 'lucide-react';
import { isFirebaseConfigured } from '@/lib/firebase';
import { useHrmAdmin } from '@/lib/store';

interface NavbarProps {
  onAddEmployee?: () => void;
  onNewAnnouncement?: () => void;
  onSearchChange?: (q: string) => void;
}

export default function Navbar({
  onAddEmployee,
  onNewAnnouncement,
  onSearchChange,
}: NavbarProps) {
  const { currentUser } = useHrmAdmin();

  return (
    <header className="h-16 border-b border-slate-200/70 dark:border-white/[0.06] bg-white/70 dark:bg-[#090d16]/70 backdrop-blur-xl sticky top-0 z-30 px-6 flex items-center justify-between transition-colors">
      {/* Search Input (Command-bar style) */}
      <div className="flex items-center gap-3">
        <div className="relative flex items-center w-72 sm:w-88 group">
          <Search className="w-3.5 h-3.5 absolute left-3 text-slate-400 group-hover:text-slate-600 dark:group-hover:text-slate-300 transition-colors pointer-events-none" />
          <input
            type="text"
            placeholder="Search staff, outwork, claims..."
            onChange={(e) => onSearchChange?.(e.target.value)}
            className="w-full bg-slate-100/70 dark:bg-white/[0.04] border border-slate-200/80 dark:border-white/[0.07] rounded-xl pl-9 pr-14 py-1.5 text-xs font-medium text-slate-900 dark:text-slate-100 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500/60 dark:focus:border-indigo-400/60 transition-all"
          />
          <div className="absolute right-2.5 flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[10px] font-mono font-medium text-slate-400 bg-slate-200/50 dark:bg-white/[0.06] border border-slate-300/40 dark:border-white/[0.08] pointer-events-none">
            <span className="text-[9px]">⌘</span>K
          </div>
        </div>
      </div>

      {/* Center / Right status & action buttons */}
      <div className="flex items-center gap-3">
        {/* Backend & Cloudinary Status Badges */}
        <div className="hidden lg:flex items-center gap-2">
          <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-medium bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
            <span>{isFirebaseConfigured ? 'Firestore Live' : 'Live Sync Ready'}</span>
          </div>

          <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-medium bg-sky-500/10 text-sky-600 dark:text-sky-400 border border-sky-500/20">
            <Cloud className="w-3 h-3 text-sky-500" />
            <span>Cloudinary</span>
          </div>
        </div>

        {/* Company & Super Admin indicator */}
        <div className="hidden sm:block text-right pr-2">
          <div className="flex items-center justify-end gap-1.5">
            <ShieldCheck className="w-3.5 h-3.5 text-purple-500" />
            <p className="text-xs font-semibold text-slate-800 dark:text-slate-200">
              {currentUser?.companyName || 'Acme Bangladesh Ltd'}
            </p>
          </div>
          <p className="text-[10px] text-slate-400 font-mono">
            Workspace: {currentUser?.companyCode || 'ACME-DHK'}
          </p>
        </div>

        <div className="h-4 w-px bg-slate-200 dark:bg-white/10 hidden sm:block"></div>

        {/* Quick action buttons */}
        {onNewAnnouncement && (
          <button
            onClick={onNewAnnouncement}
            className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-slate-700 dark:text-slate-300 hover:text-slate-900 dark:hover:text-white bg-slate-100/80 dark:bg-white/[0.05] hover:bg-slate-200/80 dark:hover:bg-white/[0.08] rounded-xl border border-slate-200/80 dark:border-white/[0.07] transition-all"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>Notice</span>
          </button>
        )}

        {onAddEmployee && (
          <button
            onClick={onAddEmployee}
            className="flex items-center gap-1.5 px-3.5 py-1.5 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-sm shadow-indigo-600/30 transition-all hover:scale-[1.01] active:scale-[0.99]"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>Add Staff</span>
          </button>
        )}

        {/* Notification Bell */}
        <button
          className="relative w-8 h-8 rounded-xl border border-slate-200/80 dark:border-white/[0.07] bg-white dark:bg-white/[0.03] flex items-center justify-center text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-white/[0.08] transition-colors"
          title="Notifications"
        >
          <Bell className="w-3.5 h-3.5" />
          <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 rounded-full bg-indigo-500"></span>
        </button>
      </div>
    </header>
  );
}
