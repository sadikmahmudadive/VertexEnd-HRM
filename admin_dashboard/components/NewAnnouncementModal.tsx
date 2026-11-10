'use client';

import React, { useState } from 'react';
import { X, Megaphone, Send } from 'lucide-react';
import { Announcement } from '@/lib/types';

interface NewAnnouncementModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAdd: (ann: Omit<Announcement, 'id' | 'createdAt'>) => Promise<void>;
}

export default function NewAnnouncementModal({
  isOpen,
  onClose,
  onAdd,
}: NewAnnouncementModalProps) {
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState<'Policy' | 'Notice' | 'Event' | 'Holiday'>('Notice');
  const [priority, setPriority] = useState<'High' | 'Normal' | 'Low'>('Normal');
  const [body, setBody] = useState('');
  const [loading, setLoading] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !body.trim()) return;

    setLoading(true);
    await onAdd({
      title: title.trim(),
      category,
      priority,
      body: body.trim(),
      authorName: 'HR Administration',
    });
    setLoading(false);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-in fade-in duration-200">
      <div className="bg-white dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.08] rounded-2xl max-w-md w-full overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
        <div className="p-5 border-b border-slate-100 dark:border-white/[0.06] flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-purple-500/10 text-purple-600 dark:text-purple-400 flex items-center justify-center border border-purple-500/15">
              <Megaphone className="w-4 h-4" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                Broadcast Announcement
              </h3>
              <p className="text-[11px] text-slate-500 dark:text-slate-400">
                Pushes to all employee mobile apps
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="w-7 h-7 rounded-lg border border-slate-200 dark:border-white/10 flex items-center justify-center text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-5 space-y-3.5 text-xs">
          <div>
            <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              Title *
            </label>
            <input
              type="text"
              required
              placeholder="e.g. Office Relocation or Policy Update"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                Category
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value as any)}
                className="w-full bg-slate-50 dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              >
                <option value="Notice">Notice</option>
                <option value="Policy">Policy</option>
                <option value="Event">Event</option>
                <option value="Holiday">Holiday</option>
              </select>
            </div>
            <div>
              <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                Priority
              </label>
              <select
                value={priority}
                onChange={(e) => setPriority(e.target.value as any)}
                className="w-full bg-slate-50 dark:bg-[#0f1422] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              >
                <option value="Normal">Normal</option>
                <option value="High">High Priority</option>
                <option value="Low">Low</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              Notice Body *
            </label>
            <textarea
              required
              rows={4}
              placeholder="Write the announcement details that will appear on mobile apps..."
              value={body}
              onChange={(e) => setBody(e.target.value)}
              className="w-full bg-slate-50 dark:bg-white/[0.03] border border-slate-200/80 dark:border-white/[0.07] rounded-xl px-3 py-2 text-xs text-slate-900 dark:text-slate-100 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 resize-none"
            ></textarea>
          </div>

          <div className="p-4 border-t border-slate-100 dark:border-white/[0.06] -mx-5 -mb-5 mt-5 bg-slate-50/50 dark:bg-white/[0.02] flex items-center justify-end gap-2.5">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-xs font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-white/[0.06] rounded-xl transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex items-center gap-1.5 px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-500 rounded-xl shadow-sm shadow-indigo-600/30 transition-all disabled:opacity-50 hover:scale-[1.01] active:scale-[0.99]"
            >
              <Send className="w-3.5 h-3.5" />
              <span>{loading ? 'Broadcasting...' : 'Broadcast Notice'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
