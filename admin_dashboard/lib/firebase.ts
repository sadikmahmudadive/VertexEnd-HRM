import { initializeApp, getApps, getApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY || "AIzaSyBPwoDryLMG9OlG_8kmvCCbDJaWPE0afDs",
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN || "vertexhand-demo.firebaseapp.com",
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || "vertexhand-demo",
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET || "vertexhand-demo.firebasestorage.app",
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID || "545830925830",
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID || "1:545830925830:web:ae7fce765ee48cdcdd3587",
  measurementId: process.env.NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID || "G-7J8Y2DCG4Q",
};

export const isFirebaseConfigured =
  Boolean(process.env.NEXT_PUBLIC_FIREBASE_API_KEY || firebaseConfig.apiKey) &&
  process.env.NEXT_PUBLIC_FIREBASE_API_KEY !== 'YOUR-WEB-API-KEY';

const app = !getApps().length
  ? initializeApp(firebaseConfig)
  : getApp();

export const auth = getAuth(app);
export const db = getFirestore(app);
export default app;
