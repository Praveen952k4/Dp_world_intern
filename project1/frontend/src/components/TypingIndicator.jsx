import React from "react";

export function TypingIndicator() {
  return (
    <div className="flex gap-3 justify-start items-center my-2">
      <div className="w-8 h-8 rounded-full bg-blue-500 text-white flex items-center justify-center text-sm font-bold">
        <span role="img" aria-label="bot">🤖</span>
      </div>
      <div className="bg-gray-100 text-gray-900 rounded-lg px-3 py-2 animate-fade-in">
        <div className="flex gap-1">
          <span className="w-2 h-2 bg-gray-500 rounded-full animate-pulse"></span>
          <span className="w-2 h-2 bg-gray-500 rounded-full animate-pulse [animation-delay:75ms]"></span>
          <span className="w-2 h-2 bg-gray-500 rounded-full animate-pulse [animation-delay:150ms]"></span>
        </div>
      </div>
    </div>
  );
}
