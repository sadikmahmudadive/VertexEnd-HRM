'use client';

import React, { useState } from 'react';
import { ShieldAlert, Copy, Check, ExternalLink, X, Terminal } from 'lucide-react';

interface FirestoreRulesModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const FIRESTORE_RULES_SNIPPET = `rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Allow authenticated users (Super Admin & Staff) full access
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}`;

export const FIRESTORE_DEV_RULES_SNIPPET = `rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Open development mode (instant test)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}`;

export default function FirestoreRulesModal({ isOpen, onClose }: FirestoreRulesModalProps) {
  const [copiedTab, setCopiedTab] = useState<'auth' | 'dev' | null>(null);
  const [activeTab, setActiveTab] = useState<'auth' | 'dev'>('auth');

  if (!isOpen) return null;

  const currentSnippet = activeTab === 'auth' ? FIRESTORE_RULES_SNIPPET : FIRESTORE_DEV_RULES_SNIPPET;

  const copyRules = async (tab: 'auth' | 'dev') => {
    const text = tab === 'auth' ? FIRESTORE_RULES_SNIPPET : FIRESTORE_DEV_RULES_SNIPPET;
    await navigator.clipboard.writeText(text);
    setCopiedTab(tab);
    setTimeout(() => setCopiedTab(null), 2500);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-in fade-in duration-200">
      <div className="bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.08] rounded-3xl max-w-xl w-full overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="p-6 border-b border-slate-100 dark:border-white/[0.06] flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-amber-500/10 text-amber-500 flex items-center justify-center border border-amber-500/20">
              <ShieldAlert className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-base font-bold text-slate-900 dark:text-white">
                Update Firestore Security Rules
              </h3>
              <p className="text-xs text-slate-500 dark:text-slate-400">
                Fix &quot;Missing or insufficient permissions&quot; in Firebase
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-xl border border-slate-200 dark:border-white/10 flex items-center justify-center text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-4 text-xs">
          <p className="text-slate-600 dark:text-slate-300 leading-relaxed">
            By default, new Firebase projects start with locked security rules (<code className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-white/[0.06] text-amber-600 dark:text-amber-400 font-mono">allow read, write: if false;</code>). Follow these 3 steps to activate live sync:
          </p>

          <ol className="list-decimal list-inside space-y-2 text-slate-700 dark:text-slate-300 font-medium">
            <li>
              Open your Firebase Console:
              <a
                href="https://console.firebase.google.com/project/vertexhand-demo/firestore/rules"
                target="_blank"
                rel="noreferrer"
                className="ml-1 text-indigo-600 dark:text-indigo-400 underline font-semibold inline-flex items-center gap-1"
              >
                <span>vertexhand-demo &rarr; Firestore &rarr; Rules</span>
                <ExternalLink className="w-3 h-3" />
              </a>
            </li>
            <li>Copy either the <strong>Authenticated Rules</strong> (recommended) or <strong>Open Test Rules</strong> below.</li>
            <li>Paste into the editor and click <strong>Publish</strong>.</li>
          </ol>

          {/* Rule Tabs */}
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <div className="flex p-0.5 bg-slate-100 dark:bg-white/[0.04] rounded-lg border border-slate-200/80 dark:border-white/[0.06] text-[11px] font-semibold">
                <button
                  type="button"
                  onClick={() => setActiveTab('auth')}
                  className={`px-3 py-1 rounded-md transition-all ${
                    activeTab === 'auth'
                      ? 'bg-white dark:bg-white/[0.1] text-slate-900 dark:text-white shadow-sm'
                      : 'text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-white'
                  }`}
                >
                  Authenticated (Production)
                </button>
                <button
                  type="button"
                  onClick={() => setActiveTab('dev')}
                  className={`px-3 py-1 rounded-md transition-all ${
                    activeTab === 'dev'
                      ? 'bg-white dark:bg-white/[0.1] text-slate-900 dark:text-white shadow-sm'
                      : 'text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-white'
                  }`}
                >
                  Open Test (Development)
                </button>
              </div>

              <button
                type="button"
                onClick={() => copyRules(activeTab)}
                className="flex items-center gap-1.5 px-3 py-1 text-[11px] font-semibold rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white shadow-sm shadow-indigo-600/30 transition-all"
              >
                {copiedTab === activeTab ? (
                  <>
                    <Check className="w-3 h-3" />
                    <span>Copied!</span>
                  </>
                ) : (
                  <>
                    <Copy className="w-3 h-3" />
                    <span>Copy Rules</span>
                  </>
                )}
              </button>
            </div>

            {/* Code Box */}
            <div className="relative rounded-2xl bg-slate-950 p-4 border border-slate-800 font-mono text-[11px] text-slate-300 leading-relaxed overflow-x-auto max-h-56">
              <pre className="whitespace-pre">{currentSnippet}</pre>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-slate-100 dark:border-white/[0.06] bg-slate-50/50 dark:bg-white/[0.02] flex items-center justify-between">
          <a
            href="https://console.firebase.google.com/project/vertexhand-demo/firestore/rules"
            target="_blank"
            rel="noreferrer"
            className="flex items-center gap-1.5 px-4 py-2 rounded-xl bg-amber-500 hover:bg-amber-600 text-white font-semibold text-xs transition-colors"
          >
            <span>Open Firebase Console Rules</span>
            <ExternalLink className="w-3.5 h-3.5" />
          </a>

          <button
            type="button"
            onClick={() => {
              onClose();
              window.location.reload();
            }}
            className="px-4 py-2 rounded-xl text-xs font-semibold text-slate-700 dark:text-slate-200 hover:bg-slate-200/60 dark:hover:bg-white/[0.08] transition-colors"
          >
            Reload Website
          </button>
        </div>
      </div>
    </div>
  );
}

