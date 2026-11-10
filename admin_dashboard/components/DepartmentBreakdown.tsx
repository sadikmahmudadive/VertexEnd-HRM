'use client';

import React from 'react';
import { useHrmAdmin } from '@/lib/store';
import { Building2, Users } from 'lucide-react';

export default function DepartmentBreakdown() {
  const { employees } = useHrmAdmin();

  const depts = [
    { name: 'Engineering', color: 'bg-indigo-500', barColor: 'bg-indigo-500' },
    { name: 'Design', color: 'bg-purple-500', barColor: 'bg-purple-500' },
    { name: 'Finance', color: 'bg-emerald-500', barColor: 'bg-emerald-500' },
    { name: 'Sales', color: 'bg-amber-500', barColor: 'bg-amber-500' },
    { name: 'People', color: 'bg-sky-500', barColor: 'bg-sky-500' },
  ];

  const total = employees.length;

  return (
    <div className="p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-5">
      <div>
        <h3 className="text-sm font-bold text-slate-900 dark:text-white">
          Team Distribution
        </h3>
        <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
          Workforce headcount across departments
        </p>
      </div>

      {total === 0 ? (
        <div className="py-8 flex flex-col items-center justify-center text-center space-y-2">
          <div className="w-10 h-10 rounded-xl bg-slate-100 dark:bg-white/[0.04] flex items-center justify-center text-slate-400">
            <Users className="w-5 h-5" />
          </div>
          <p className="text-xs font-semibold text-slate-600 dark:text-slate-300">
            No team members added
          </p>
          <p className="text-[11px] text-slate-400 max-w-[200px]">
            Add staff to see headcount and department percentages
          </p>
        </div>
      ) : (
        <div className="space-y-3.5">
          {depts.map((d) => {
            const count = employees.filter((e) =>
              e.dept.toLowerCase().includes(d.name.toLowerCase())
            ).length;
            const pct = Math.round((count / total) * 100);

            return (
              <div key={d.name} className="space-y-1.5">
                <div className="flex items-center justify-between text-xs">
                  <div className="flex items-center gap-2">
                    <span className={`w-2 h-2 rounded-full ${d.color}`}></span>
                    <span className="font-medium text-slate-700 dark:text-slate-300">
                      {d.name}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 text-slate-500 dark:text-slate-400 font-medium">
                    <span className="text-[11px]">{count} staff</span>
                    <span className="font-semibold text-slate-800 dark:text-slate-200">{pct}%</span>
                  </div>
                </div>
                <div className="w-full h-1.5 rounded-full bg-slate-100 dark:bg-white/[0.06] overflow-hidden">
                  <div
                    style={{ width: `${pct}%` }}
                    className={`h-full ${d.barColor} rounded-full transition-all duration-500`}
                  ></div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      <div className="pt-4 border-t border-slate-100 dark:border-white/[0.05] flex items-center justify-between text-xs text-slate-500 dark:text-slate-400">
        <div className="flex items-center gap-1.5">
          <Building2 className="w-3.5 h-3.5 text-slate-400" />
          <span>Primary Office</span>
        </div>
        <span className="font-semibold text-slate-700 dark:text-slate-300">
          Banani HQ, Dhaka
        </span>
      </div>
    </div>
  );
}
