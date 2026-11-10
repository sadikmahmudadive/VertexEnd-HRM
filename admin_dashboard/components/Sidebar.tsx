'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  LayoutDashboard,
  Clock,
  Briefcase,
  CalendarDays,
  Users,
  Receipt,
  Megaphone,
  Settings,
  Sparkles,
  ChevronRight,
  Sun,
  Moon,
  ShieldCheck,
  LogOut,
} from 'lucide-react';
import { useHrmAdmin } from '@/lib/store';

export default function Sidebar() {
  const pathname = usePathname();
  const { stats, darkMode, toggleDarkMode, currentUser, roles, signOutAdmin } = useHrmAdmin();

  const sections = [
    {
      title: 'Analytics & Shift',
      items: [
        {
          name: 'Overview',
          href: '/',
          icon: LayoutDashboard,
          badge: null,
        },
        {
          name: 'Live Attendance',
          href: '/attendance',
          icon: Clock,
          badge: stats.inOfficeNow + stats.outworkNow > 0 ? `${stats.inOfficeNow + stats.outworkNow}` : null,
          badgeColor: 'bg-emerald-500/10 text-emerald-500 dark:text-emerald-400 border border-emerald-500/20',
        },
        {
          name: 'Field Outwork',
          href: '/outwork',
          icon: Briefcase,
          badge: stats.outworkNow > 0 ? `${stats.outworkNow}` : null,
          badgeColor: 'bg-amber-500/10 text-amber-500 dark:text-amber-400 border border-amber-500/20',
        },
      ],
    },
    {
      title: 'HR & Approvals',
      items: [
        {
          name: 'Leave Requests',
          href: '/leaves',
          icon: CalendarDays,
          badge: stats.pendingApprovals > 0 ? `${stats.pendingApprovals}` : null,
          badgeColor: 'bg-indigo-500/10 text-indigo-500 dark:text-indigo-400 border border-indigo-500/20',
        },
        {
          name: 'Directory',
          href: '/employees',
          icon: Users,
          badge: stats.totalEmployees > 0 ? `${stats.totalEmployees}` : null,
          badgeColor: 'bg-slate-500/10 text-slate-500 dark:text-slate-400 border border-slate-500/15',
        },
        {
          name: 'Expenses',
          href: '/expenses',
          icon: Receipt,
          badge: 'CDN',
          badgeColor: 'bg-sky-500/10 text-sky-500 dark:text-sky-400 border border-sky-500/20',
        },
      ],
    },
    {
      title: 'Company',
      items: [
        {
          name: 'Roles & Access',
          href: '/roles',
          icon: ShieldCheck,
          badge: `${roles.length}`,
          badgeColor: 'bg-purple-500/10 text-purple-600 dark:text-purple-400 border border-purple-500/20',
        },
        {
          name: 'Announcements',
          href: '/announcements',
          icon: Megaphone,
          badge: null,
        },
        {
          name: 'Settings',
          href: '/settings',
          icon: Settings,
          badge: null,
        },
      ],
    },
  ];

  const userInitials = currentUser?.displayName
    ? currentUser.displayName
        .split(' ')
        .map((n) => n[0])
        .join('')
        .toUpperCase()
        .slice(0, 2)
    : 'SA';

  return (
    <aside className="w-60 border-r border-slate-200/80 dark:border-white/[0.06] bg-white dark:bg-[#0b0f18] flex flex-col h-screen sticky top-0 z-30 transition-colors select-none">
      {/* Brand Header */}
      <div className="h-16 px-5 flex items-center justify-between border-b border-slate-100 dark:border-white/[0.04]">
        <div className="flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-xl bg-gradient-to-tr from-indigo-600 to-purple-600 flex items-center justify-center text-white shadow-sm shadow-indigo-600/30">
            <Sparkles className="w-4 h-4" />
          </div>
          <div>
            <span className="font-extrabold text-sm tracking-tight text-slate-900 dark:text-white block leading-none">
              VertexHand
            </span>
            <span className="text-[10px] text-slate-400 font-medium tracking-wide">
              {currentUser?.companyCode || 'Admin Portal'}
            </span>
          </div>
        </div>
      </div>

      {/* Navigation Sections */}
      <nav className="flex-1 overflow-y-auto px-3 py-4 space-y-6">
        {sections.map((section) => (
          <div key={section.title} className="space-y-1">
            <p className="px-3 text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">
              {section.title}
            </p>
            {section.items.map((item) => {
              const Icon = item.icon;
              const isActive = pathname === item.href;

              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={`group flex items-center justify-between px-3 py-2 rounded-xl text-xs font-medium transition-all ${
                    isActive
                      ? 'bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 font-semibold'
                      : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 hover:bg-slate-50 dark:hover:bg-white/[0.03]'
                  }`}
                >
                  <div className="flex items-center gap-2.5">
                    <Icon
                      className={`w-4 h-4 transition-colors ${
                        isActive
                          ? 'text-indigo-600 dark:text-indigo-400'
                          : 'text-slate-400 group-hover:text-slate-600 dark:group-hover:text-slate-300'
                      }`}
                    />
                    <span>{item.name}</span>
                  </div>

                  {item.badge && (
                    <span
                      className={`text-[10px] font-bold px-1.5 py-0.5 rounded-full ${
                        item.badgeColor ||
                        'bg-slate-100 dark:bg-white/[0.06] text-slate-600 dark:text-slate-300'
                      }`}
                    >
                      {item.badge}
                    </span>
                  )}
                </Link>
              );
            })}
          </div>
        ))}
      </nav>

      {/* Sleek Super Admin & Theme Footer */}
      <div className="p-3 border-t border-slate-100 dark:border-white/[0.04] space-y-2">
        <div className="p-2 rounded-xl bg-slate-50 dark:bg-white/[0.02] border border-slate-100 dark:border-white/[0.04] flex items-center justify-between">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="relative shrink-0">
              {currentUser?.avatarUrl ? (
                <img
                  src={currentUser.avatarUrl}
                  alt={currentUser.displayName}
                  className="w-8 h-8 rounded-lg object-cover ring-1 ring-purple-500/30"
                />
              ) : (
                <div className="w-8 h-8 rounded-lg bg-gradient-to-tr from-purple-600 to-indigo-600 flex items-center justify-center text-white font-bold text-xs shadow-sm shadow-purple-600/30">
                  {userInitials}
                </div>
              )}
              <span className="w-2 h-2 rounded-full bg-emerald-500 absolute -bottom-0.5 -right-0.5 ring-2 ring-white dark:ring-[#0b0f18]"></span>
            </div>
            <div className="min-w-0">
              <p className="text-xs font-semibold text-slate-800 dark:text-slate-200 leading-tight truncate">
                {currentUser?.displayName || 'Super Admin'}
              </p>
              <p className="text-[10px] text-purple-600 dark:text-purple-400 font-bold truncate">
                Super Admin
              </p>
            </div>
          </div>

          <div className="flex items-center gap-1 shrink-0">
            <button
              onClick={toggleDarkMode}
              className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/[0.08] flex items-center justify-center text-slate-500 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-white/[0.05] transition-colors"
              title="Toggle theme"
            >
              {darkMode ? (
                <Moon className="w-3.5 h-3.5 text-indigo-400" />
              ) : (
                <Sun className="w-3.5 h-3.5 text-amber-500" />
              )}
            </button>
            <button
              onClick={signOutAdmin}
              className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/[0.08] flex items-center justify-center text-slate-400 hover:text-rose-500 hover:bg-rose-500/10 transition-colors"
              title="Sign out"
            >
              <LogOut className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>
      </div>
    </aside>
  );
}
