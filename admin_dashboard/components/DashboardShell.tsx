'use client';

import React, { useState } from 'react';
import Sidebar from './Sidebar';
import Navbar from './Navbar';
import AddEmployeeModal from './AddEmployeeModal';
import NewAnnouncementModal from './NewAnnouncementModal';
import AuthPortal from './AuthPortal';
import { useHrmAdmin } from '@/lib/store';

export default function DashboardShell({ children }: { children: React.ReactNode }) {
  const [isAddEmployeeOpen, setIsAddEmployeeOpen] = useState(false);
  const [isNewAnnouncementOpen, setIsNewAnnouncementOpen] = useState(false);
  const { currentUser, addEmployee, addAnnouncement } = useHrmAdmin();

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
        />
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
    </div>
  );
}
