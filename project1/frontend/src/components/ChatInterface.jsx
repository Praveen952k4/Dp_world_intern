import React, { useState, useRef, useEffect } from 'react';
import { FiSend } from "react-icons/fi";
import { TypingIndicator } from './TypingIndicator';
import { useUser } from '../contexts/UserContext';


const ChatInterface = () => {
  const [messages, setMessages] = useState([
    {
      id: '1',
      content: "Hello! I'm your AI assistant. How can I help you today?",
      isBot: true,
      timestamp: new Date(),
    },
  ]);
  const [inputValue, setInputValue] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef(null);
  const { role } = useUser();

  const scrollToBottom = () => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  };
  useEffect(() => {
    scrollToBottom();
  }, [messages, isTyping]);

  const handleSendMessage = () => {
    if (!inputValue.trim()) return;

    const userMessage = {
      id: Date.now().toString(),
      content: inputValue,
      isBot: false,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInputValue('');
    setIsTyping(true);

    setTimeout(() => {
      const botMessage = {
        id: (Date.now() + 1).toString(),
        content: `Thank you for your message! As a ${role}, I'm here to help you. Your message was: "${userMessage.content}". This is a simulated response.`,
        isBot: true,
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, botMessage]);
      setIsTyping(false);
    }, 1500);
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  return (
    <div className="flex flex-col h-full border border-gray-300 rounded-lg p-4">
      {/* Header */}
      <div className="flex justify-between items-center border-b border-gray-200 pb-2 mb-3">
        <strong className="text-lg">🤖 AI Assistant Chat</strong>
        <span className="text-xs text-gray-500">Logged in as {role}</span>
      </div>

      {/* Messages Area */}
      <div className="flex-1 overflow-y-auto bg-gray-50 p-3 rounded-md space-y-3">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex items-end gap-2 ${
              message.isBot ? 'justify-start' : 'justify-end'
            }`}
          >
            {message.isBot && (
              <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center text-sm">🤖</div>
            )}

            <div
              className={`max-w-[70%] p-3 rounded-lg text-sm whitespace-pre-wrap ${
                message.isBot
                  ? 'bg-gray-200 text-black'
                  : 'bg-blue-600 text-white ml-10'
              }`}
            >
              <div>{message.content}</div>
              <div className="text-xs mt-1 opacity-70">
                {message.timestamp.toLocaleTimeString()}
              </div>
            </div>

            {!message.isBot && (
              <div className="w-8 h-8 bg-gray-400 rounded-full flex items-center justify-center text-sm">🧑</div>
            )}
          </div>
        ))}
        {isTyping && <TypingIndicator />}
        <div ref={messagesEndRef} />
      </div>

      {/* Input Area */}
      
<div className="border-t pt-3 mt-3">
  <div className="relative w-full">
    <textarea
      value={inputValue}
      onChange={(e) => setInputValue(e.target.value)}
      onKeyPress={handleKeyPress}
      placeholder="Type your message..."
      className="w-full p-2 pr-10 border border-gray-300 rounded-md text-sm resize-none min-h-[40px]"
    />
    <button
      onClick={handleSendMessage}
      disabled={!inputValue.trim()}
      className="absolute right-2 bottom-2 text-blue-600 disabled:text-gray-400"
    >
      <FiSend className="text-xl" />
    </button>
        </div>
        <p className="text-xs text-gray-500 mt-1">
          Press Enter to send, Shift+Enter for new line
        </p>
      </div>
    </div>
  );
};

export default ChatInterface;
