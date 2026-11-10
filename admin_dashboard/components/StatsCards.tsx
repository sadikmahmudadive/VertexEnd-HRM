'use client';

import React from 'react';
import { Users, Clock, Briefcase, ShieldCheck, ArrowUpRight } from 'lucide-react';
import { useHrmAdmin } from '@/lib/store';
import Link from 'next/link';

export default function StatsCards() {
  const { stats } = useHrmAdmin();

  const cards = [
    {
      label: 'Total Workforce',
      value: stats.totalEmployees,
      sub: stats.totalEmployees > 0 ? 'Registered team members' : 'No staff added yet',
      icon: Users,
      trend: stats.totalEmployees > 0 ? `${stats.totalEmployees} active` : 'Directory empty',
      trendPositive: stats.totalEmployees > 0,
      iconColor: 'text-indigo-500 dark:text-indigo-400',
      iconBg: 'bg-indigo-500/10 border-indigo-500/15',
      href: '/employees',
    },
    {
      label: 'Clocked-In Today',
      value: stats.inOfficeNow + stats.outworkNow,
      sub: `${stats.inOfficeNow} in-office · ${stats.outworkNow} outwork`,
      icon: Clock,
      trend: stats.totalEmployees > 0 ? `${stats.attendanceRate}% on time` : 'No shifts today',
      trendPositive: stats.inOfficeNow + stats.outworkNow > 0,
      iconColor: 'text-emerald-500 dark:text-emerald-400',
      iconBg: 'bg-emerald-500/10 border-emerald-500/15',
      href: '/attendance',
    },
    {
      label: 'Field Outwork',
      value: stats.outworkNow,
      sub: 'Client sites & field visits',
      icon: Briefcase,
      trend: stats.outworkNow > 0 ? 'GPS verified' : 'No field duties active',
      trendPositive: true,
      iconColor: 'text-amber-500 dark:text-amber-400',
      iconBg: 'bg-amber-500/10 border-amber-500/15',
      href: '/outwork',
    },
    {
      label: 'Pending Approvals',
      value: stats.pendingApprovals,
      sub: 'Outwork, leaves & expenses',
      icon: ShieldCheck,
      trend: stats.pendingApprovals > 0 ? `${stats.pendingApprovals} require action` : 'All caught up',
      trendPositive: stats.pendingApprovals === 0,
      iconColor: 'text-purple-500 dark:text-purple-400',
      iconBg: 'bg-purple-500/10 border-purple-500/15',
      href: '/leaves',
    },
  ];

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {cards.map((c) => {
        const Icon = c.icon;
        return (
          <Link
            key={c.label}
            href={c.href}
            className="group relative p-5 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm hover:border-slate-300 dark:hover:border-white/15 transition-all duration-200 hover:-translate-y-0.5"
          >
            <div className="flex items-center justify-between mb-3.5">
              <span className="text-xs font-semibold text-slate-500 dark:text-slate-400">
                {c.label}
              </span>
              <div
                className={`w-9 h-9 rounded-xl flex items-center justify-center border ${c.iconBg} ${c.iconColor} transition-transform group-hover:scale-105`}
              >
                <Icon className="w-4 h-4" />
              </div>
            </div>

            <div className="space-y-1">
              <div className="flex items-baseline justify-between">
                <span className="text-3xl font-extrabold text-slate-900 dark:text-white tracking-tight">
                  {c.value}
                </span>
                <ArrowUpRight className="w-4 h-4 text-slate-400 opacity-0 group-hover:opacity-100 transition-opacity" />
              </div>
              <p className="text-[11px] text-slate-400 dark:text-slate-500 font-medium">
                {c.sub}
              </p>
            </div>

            <div className="mt-4 pt-3 border-t border-slate-100 dark:border-white/[0.05] flex items-center justify-between text-[11px]">
              <span
                className={`font-semibold ${
                  c.trendPositive
                    ? 'text-emerald-600 dark:text-emerald-400'
                    : 'text-slate-400 dark:text-slate-500'
                }`}
              >
                {c.trend}
              </span>
              <span className="text-slate-400 group-hover:text-slate-600 dark:group-hover:text-slate-200 text-[10px] font-medium transition-colors">
                View &rarr;
              </span>
            </div>
          </Link>
        );
      })}
    </div>
  );
}
