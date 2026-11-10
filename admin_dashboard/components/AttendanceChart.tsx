'use client';

import React, { useState, useEffect } from 'react';
import { Calendar, Inbox } from 'lucide-react';
import { useHrmAdmin } from '@/lib/store';

interface DayData {
  day: string;
  inOffice: number;
  outwork: number;
  leave: number;
  weekend: boolean;
  isToday: boolean;
}

const DEFAULT_DAYS: DayData[] = [
  { day: 'Day 1', inOffice: 0, outwork: 0, leave: 0, weekend: false, isToday: false },
  { day: 'Day 2', inOffice: 0, outwork: 0, leave: 0, weekend: false, isToday: false },
  { day: 'Day 3', inOffice: 0, outwork: 0, leave: 0, weekend: false, isToday: false },
  { day: 'Day 4', inOffice: 0, outwork: 0, leave: 0, weekend: false, isToday: false },
  { day: 'Day 5', inOffice: 0, outwork: 0, leave: 0, weekend: false, isToday: false },
  { day: 'Yesterday', inOffice: 0, outwork: 0, leave: 0, weekend: false, isToday: false },
  { day: 'Today', inOffice: 0, outwork: 0, leave: 0, weekend: false, isToday: true },
];

export default function AttendanceChart() {
  const { attendance, stats } = useHrmAdmin();
  const [days, setDays] = useState<DayData[]>(DEFAULT_DAYS);

  useEffect(() => {
    const list: DayData[] = [];
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const today = new Date();

    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(today.getDate() - i);
      const isWeekend = d.getDay() === 5 || d.getDay() === 6;
      const isToday = i === 0;

      const dayStr = d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' });
      const inOffice = attendance.filter((a) => !a.isOutwork && a.date.includes(dayStr)).length;
      const outwork = attendance.filter((a) => a.isOutwork && a.date.includes(dayStr)).length;

      list.push({
        day: isToday ? 'Today' : `${dayNames[d.getDay()]} ${d.getDate()}`,
        inOffice: isToday ? stats.inOfficeNow : inOffice,
        outwork: isToday ? stats.outworkNow : outwork,
        leave: 0,
        weekend: isWeekend,
        isToday,
      });
    }
    setDays(list);
  }, [attendance, stats.inOfficeNow, stats.outworkNow]);

  const maxTotal = Math.max(stats.totalEmployees, 1);
  const hasData = attendance.length > 0 || stats.inOfficeNow > 0 || stats.outworkNow > 0;

  return (
    <div className="p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-6">
        <div>
          <h3 className="text-sm font-bold text-slate-900 dark:text-white">
            7-Day Attendance Velocity
          </h3>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
            Head Office vs Field Outwork punch compliance
          </p>
        </div>
        <div className="flex items-center gap-3 text-xs">
          <div className="flex items-center gap-1.5">
            <span className="w-2.5 h-2.5 rounded-full bg-indigo-500"></span>
            <span className="text-slate-600 dark:text-slate-300 font-medium">In-Office</span>
          </div>
          <div className="flex items-center gap-1.5">
            <span className="w-2.5 h-2.5 rounded-full bg-amber-500"></span>
            <span className="text-slate-600 dark:text-slate-300 font-medium">Field Outwork</span>
          </div>
        </div>
      </div>

      {/* Bar Chart Visualization */}
      <div className="h-52 flex items-end justify-between gap-3 sm:gap-4 pt-6 pb-2 border-b border-slate-100 dark:border-white/[0.05] relative">
        {!hasData && (
          <div className="absolute inset-0 flex flex-col items-center justify-center text-center p-4 z-10 pointer-events-none">
            <Inbox className="w-8 h-8 text-slate-300 dark:text-slate-600 mb-1.5" />
            <p className="text-xs font-semibold text-slate-500 dark:text-slate-400">
              No punch data recorded yet
            </p>
            <p className="text-[11px] text-slate-400 dark:text-slate-500">
              Live mobile punches will plot here automatically
            </p>
          </div>
        )}

        {days.map((d) => {
          const officeHeight = (d.inOffice / maxTotal) * 100;
          const outworkHeight = (d.outwork / maxTotal) * 100;

          return (
            <div key={d.day} className="flex-1 flex flex-col items-center h-full justify-end group">
              {d.weekend ? (
                <div className="w-full h-8 rounded-xl bg-slate-100/60 dark:bg-white/[0.03] border border-dashed border-slate-200/80 dark:border-white/[0.06] flex items-center justify-center text-[10px] text-slate-400 font-medium">
                  Off
                </div>
              ) : (
                <div className="w-full flex flex-col items-center justify-end h-full relative">
                  {hasData && (
                    <div className="absolute -top-10 opacity-0 group-hover:opacity-100 transition-opacity bg-slate-900 dark:bg-slate-800 text-white text-[10px] px-2.5 py-1 rounded-lg shadow-xl pointer-events-none whitespace-nowrap z-20 font-medium border border-white/10">
                      {d.inOffice} Office · {d.outwork} Field
                    </div>
                  )}

                  <div className="w-7 sm:w-10 rounded-xl overflow-hidden flex flex-col-reverse justify-start shadow-sm transition-transform duration-200 group-hover:scale-105">
                    {/* In Office */}
                    <div
                      style={{ height: `${Math.max(officeHeight * 1.3, 0)}px` }}
                      className="w-full bg-indigo-500 hover:bg-indigo-400 transition-all"
                    ></div>
                    {/* Outwork */}
                    {d.outwork > 0 && (
                      <div
                        style={{ height: `${outworkHeight * 1.3}px` }}
                        className="w-full bg-amber-500 hover:bg-amber-400 transition-all border-b border-white/20"
                      ></div>
                    )}
                  </div>
                </div>
              )}
              <span
                className={`text-[11px] font-semibold mt-3 ${
                  d.isToday
                    ? 'text-indigo-600 dark:text-indigo-400 font-bold'
                    : 'text-slate-400 dark:text-slate-500'
                }`}
              >
                {d.day}
              </span>
            </div>
          );
        })}
      </div>

      {/* Footer Insight */}
      <div className="mt-4 flex items-center justify-between text-xs text-slate-500 dark:text-slate-400">
        <div className="flex items-center gap-1.5">
          <Calendar className="w-3.5 h-3.5 text-indigo-500" />
          <span>
            {hasData
              ? `Compliance rate: ${stats.attendanceRate}%`
              : 'No shift records logged yet'}
          </span>
        </div>
        <span className="font-semibold text-slate-500 dark:text-slate-400 text-[11px]">
          {hasData ? `${stats.totalEmployees} active staff` : 'Waiting for live punches'}
        </span>
      </div>
    </div>
  );
}
