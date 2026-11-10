'use client';

import React, { useState } from 'react';
import Sidebar from './Sidebar';
import Navbar from './Navbar';
import AddEmployeeModal from './AddEmployeeModal';
import NewAnnouncementModal from './NewAnnouncementModal';
import FirestoreRulesModal from './FirestoreRulesModal';
import AuthPortal from './AuthPortal';
import { useHrmAdmin } from '@/lib/store';
import { AlertTriangle, ChevronRight, X } from 'lucide-react';

export default function DashboardShell({ children }: { children: React.ReactNode }) {
  const [isAddEmployeeOpen, setIsAddEmployeeOpen] = useState(false);
  const [isNewAnnouncementOpen, setIsNewAnnouncementOpen] = useState(false);
  const [isRulesModalOpen, setIsRulesModalOpen] = useState(false);
  const [isBannerDismissed, setIsBannerDismissed] = useState(false);
  const { currentUser, addEmployee, addAnnouncement, firestoreRulesLocked } = useHrmAdmin();

  // If not signed in as Super Admin, prompt Auth & Registration Portal while preserving segment tree
  if (!currentUser) {
    return (
      <>
        <AuthPortal />
        <div className="hidden" aria-hidden="true">
          {children}
        </div>
      </>
    );
  }

  return (
    <div className="flex min-h-screen bg-[#f8fafc] dark:bg-[#090d16] text-slate-900 dark:text-slate-100 transition-colors">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0">
        <Navbar
          onAddEmployee={() => setIsAddEmployeeOpen(true)}
          onNewAnnouncement={() => setIsNewAnnouncementOpen(true)}
          onOpenRulesModal={() => setIsRulesModalOpen(true)}
        />

        {/* Firestore Rules Alert Banner */}
        {firestoreRulesLocked && !isBannerDismissed && (
          <div className="bg-amber-500/10 border-b border-amber-500/20 px-6 py-2.5 flex items-center justify-between gap-4 text-xs text-amber-800 dark:text-amber-300">
            <div className="flex items-center gap-2.5 min-w-0">
              <AlertTriangle className="w-4 h-4 text-amber-500 shrink-0" />
              <p className="truncate">
                <strong>Firebase Notice:</strong> Firestore Security Rules are currently locked in your Firebase Console. Live database sync is blocked by default permissions.
              </p>
            </div>
            <div className="flex items-center gap-2 shrink-0">
              <button
                onClick={() => setIsRulesModalOpen(true)}
                className="px-2.5 py-1 rounded-lg bg-amber-500 hover:bg-amber-600 text-white font-semibold transition-colors flex items-center gap-1 shadow-sm"
              >
                <span>Fix Rules</span>
                <ChevronRight className="w-3 h-3" />
              </button>
              <button
                onClick={() => setIsBannerDismissed(true)}
                className="p-1 text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors"
                title="Dismiss"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </div>
          </div>
        )}

        <main className="flex-1 p-6 lg:p-8 max-w-7xl w-full mx-auto space-y-6">
          {children}
        </main>
      </div>

      <AddEmployeeModal
        isOpen={isAddEmployeeOpen}
        onClose={() => setIsAddEmployeeOpen(false)}
        onAdd={addEmployee}
      />

      <NewAnnouncementModal
        isOpen={isNewAnnouncementOpen}
        onClose={() => setIsNewAnnouncementOpen(false)}
        onAdd={addAnnouncement}
      />

      <FirestoreRulesModal
        isOpen={isRulesModalOpen}
        onClose={() => setIsRulesModalOpen(false)}
      />
    </div>
  );
}

