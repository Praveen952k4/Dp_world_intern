import React, { useState } from 'react';
import { UserProvider } from './contexts/UserContext';
import ChatInterface from './components/ChatInterface';
import AdminPanel from './components/AdminPanel';



const App = () => {
  const [currentRole, setCurrentRole] = useState('employee');

  const toggleRole = () => {
    setCurrentRole((prev) => (prev === 'admin' ? 'employee' : 'admin'));
  };

  return (
    <UserProvider role={currentRole}>
      <div className="min-h-screen bg-gray-100">
        {/* Header */}
        <header className="border-b bg-white p-4 shadow-sm">
          <div className="max-w-6xl mx-auto flex items-center justify-between">
            <h1 className="text-2xl font-bold">DP world</h1>
            <div className="flex items-center gap-4">
              <span className="text-sm text-gray-600">
                Current Role:{' '}
                <span className="font-medium capitalize">{currentRole}</span>
              </span>
              <button
                onClick={toggleRole}
                className="text-sm border border-gray-300 px-3 py-1 rounded-md bg-white hover:bg-gray-50"
              >
                {currentRole === 'admin'
                  ? 'Switch to Employee'
                  : 'Switch to Admin'}
              </button>
            </div>
          </div>
        </header>
        <main className="max-w-6xl mx-auto p-4">
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 h-[calc(100vh-8rem)]">
            {currentRole === 'admin' && (
              <div className="lg:col-span-1">
                <AdminPanel />
              </div>
            )}
            <div
              className={
                currentRole === 'admin'
                  ? 'lg:col-span-3'
                  : 'lg:col-span-4'
              }
            >
              <ChatInterface />
            </div>
          </div>
        </main>
      </div>
    </UserProvider>
  );
};

export default App;
