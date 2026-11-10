'use client';

import React, { useState } from 'react';
import {
  Settings,
  Cloud,
  CheckCircle2,
  ShieldCheck,
  Building2,
  Save,
} from 'lucide-react';
import { isFirebaseConfigured } from '@/lib/firebase';

export default function SettingsPage() {
  const [companyName, setCompanyName] = useState('Acme Bangladesh Ltd');
  const [companyCode, setCompanyCode] = useState('ACME-DHK');
  const [geofenceRadius, setGeofenceRadius] = useState('150');
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Header */}
      <div>
        <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
          System Settings & Cloud Integration
        </h1>
        <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
          Configure Firebase backend connections, Cloudinary media storage, and office geofence rules
        </p>
      </div>

      {/* Cloud Service Status Overview */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        {/* Firebase */}
        <div className="p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-9 h-9 rounded-xl bg-amber-500/10 text-amber-500 flex items-center justify-center border border-amber-500/15">
                <ShieldCheck className="w-5 h-5" />
              </div>
              <div>
                <h3 className="font-bold text-sm text-slate-900 dark:text-white">Firebase Backend</h3>
                <p className="text-[11px] text-slate-400">Auth & Firestore Database</p>
              </div>
            </div>
            <span
              className={`text-[10px] font-bold px-2.5 py-0.5 rounded-full ${
                isFirebaseConfigured
                  ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20'
                  : 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20'
              }`}
            >
              {isFirebaseConfigured ? 'Live Connected' : 'Demo Workspace'}
            </span>
          </div>

          <p className="text-xs text-slate-600 dark:text-slate-400 leading-relaxed">
            {isFirebaseConfigured
              ? 'Real-time sync active with Firestore collections: users, attendance, outwork_requests, leave_requests, and expenses.'
              : 'Running in simulated state mode. Configure NEXT_PUBLIC_FIREBASE_API_KEY in .env.local to link your live Firestore project.'}
          </p>

          <div className="pt-2 text-[11px] text-slate-400 font-mono">
            Project ID: <span className="font-bold text-slate-700 dark:text-slate-300">{process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || 'vertexhand-demo'}</span>
          </div>
        </div>

        {/* Cloudinary */}
        <div className="p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-9 h-9 rounded-xl bg-sky-500/10 text-sky-500 flex items-center justify-center border border-sky-500/15">
                <Cloud className="w-5 h-5" />
              </div>
              <div>
                <h3 className="font-bold text-sm text-slate-900 dark:text-white">Cloudinary Storage</h3>
                <p className="text-[11px] text-slate-400">Image & Receipt CDN</p>
              </div>
            </div>
            <span className="text-[10px] font-bold px-2.5 py-0.5 rounded-full bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20">
              Active CDN
            </span>
          </div>

          <p className="text-xs text-slate-600 dark:text-slate-400 leading-relaxed">
            All employee profile avatars, expense receipt scans, and on-site field duty photos are securely delivered via Cloudinary.
          </p>

          <div className="pt-2 text-[11px] text-slate-400 font-mono">
            Preset: <span className="font-bold text-slate-700 dark:text-slate-300">hrm_unsigned</span>
          </div>
        </div>
      </div>

      {/* Company Configuration Form */}
      <form onSubmit={handleSave} className="p-6 rounded-2xl bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] shadow-sm space-y-5 text-xs">
        <div className="flex items-center gap-2 border-b border-slate-100 dark:border-white/[0.05] pb-3">
          <Building2 className="w-4 h-4 text-indigo-500" />
          <h2 className="font-bold text-sm text-slate-900 dark:text-white">Company Workspace Settings</h2>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              Registered Company Name
            </label>
            <input
              type="text"
              value={companyName}
              onChange={(e) => setCompanyName(e.target.value)}
              className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            />
          </div>

          <div>
            <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              Company Code (Workspace Identifier)
            </label>
            <input
              type="text"
              value={companyCode}
              onChange={(e) => setCompanyCode(e.target.value)}
              className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 font-mono focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            />
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              Office Geofence Perimeter Radius (Meters)
            </label>
            <input
              type="number"
              value={geofenceRadius}
              onChange={(e) => setGeofenceRadius(e.target.value)}
              className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 font-mono focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            />
            <p className="text-[10px] text-slate-400 mt-1">
              Punches outside this perimeter trigger Outwork / On-Duty approval requests.
            </p>
          </div>

          <div>
            <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              Headquarters Address
            </label>
            <input
              type="text"
              defaultValue="Road 11, Banani, Dhaka 1213, Bangladesh"
              className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            />
          </div>
        </div>

        <div className="pt-2 flex items-center justify-between">
          {saved ? (
            <span className="text-xs text-emerald-600 dark:text-emerald-400 font-semibold flex items-center gap-1">
              <CheckCircle2 className="w-4 h-4" />
              <span>Settings saved successfully</span>
            </span>
          ) : (
            <span></span>
          )}

          <button
            type="submit"
            className="flex items-center gap-1.5 px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-sm shadow-indigo-600/30 transition-all hover:scale-[1.01] active:scale-[0.99]"
          >
            <Save className="w-3.5 h-3.5" />
            <span>Save Settings</span>
          </button>
        </div>
      </form>
    </div>
  );
}
