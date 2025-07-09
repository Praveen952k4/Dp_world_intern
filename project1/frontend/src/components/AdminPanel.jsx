import React, { useState } from "react";

export default function AdminPanel() {
  const [uploadedFiles, setUploadedFiles] = useState([]);
  const [isDragging, setIsDragging] = useState(false);

  const handleFileUpload = (files) => {
    if (!files) return;

    Array.from(files).forEach((file) => {
      const newFile = {
        id: Math.random().toString(36).substr(2, 9),
        name: file.name,
        size: file.size,
        uploadedAt: new Date(),
      };

      setUploadedFiles((prev) => [...prev, newFile]);
      alert(`${file.name} has been uploaded to the knowledge base.`);
    });
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragging(false);
    handleFileUpload(e.dataTransfer.files);
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = (e) => {
    e.preventDefault();
    setIsDragging(false);
  };

  const removeFile = (id) => {
    setUploadedFiles((prev) => prev.filter((file) => file.id !== id));
    alert("File has been removed from the knowledge base.");
  };

  const formatFileSize = (bytes) => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
  };

  return (
    <div className="h-full border rounded-lg bg-white shadow-sm p-4 space-y-6">
      {/* Header */}
      <div className="flex items-center gap-2 font-semibold text-lg">
        <span className="text-blue-600">↑</span>
        Admin Panel
      </div>

      {/* File Upload Area */}
      <div className="space-y-2">
        <label className="block text-sm font-medium">Upload Knowledge Base Files</label>
        <div
          className={`border-2 border-dashed rounded-lg p-6 text-center transition-colors ${
            isDragging
              ? "border-blue-500 bg-blue-100"
              : "border-gray-300 hover:border-blue-400"
          }`}
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
        >
          <div className="text-gray-500 text-2xl mb-2">📤</div>
          <p className="text-sm text-gray-500 mb-2">
            Drag and drop files here, or click to select
          </p>
          <input
            type="file"
            multiple
            className="hidden"
            id="file-upload"
            onChange={(e) => handleFileUpload(e.target.files)}
          />
          <label
            htmlFor="file-upload"
            className="cursor-pointer inline-block px-3 py-1 text-sm border rounded hover:bg-gray-100"
          >
            Select Files
          </label>
        </div>
      </div>

      <div className="space-y-2">
        <label className="block text-sm font-medium">
          Uploaded Files ({uploadedFiles.length})
        </label>
        <div className="space-y-2 max-h-64 overflow-y-auto">
          {uploadedFiles.length === 0 ? (
            <p className="text-sm text-gray-500 text-center py-4">
              No files uploaded yet
            </p>
          ) : (
            uploadedFiles.map((file) => (
              <div
                key={file.id}
                className="flex items-center justify-between p-2 bg-gray-100 rounded"
              >
                <div className="flex items-center gap-2 flex-1 min-w-0">
                  <span className="text-blue-600 text-sm">📄</span>
                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-medium truncate">{file.name}</p>
                    <p className="text-xs text-gray-500">
                      {formatFileSize(file.size)} • {file.uploadedAt.toLocaleTimeString()}
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => removeFile(file.id)}
                  className="text-sm text-gray-500 hover:text-red-500"
                >
                  ✖
                </button>
              </div>
            ))
          )}
        </div>
      </div>

      {/* Knowledge Base Status */}
      <div className="space-y-2">
        <label className="block text-sm font-medium">Knowledge Base Status</label>
        <div className="flex items-center gap-2 p-2 bg-green-100 rounded">
          <span className="text-green-600">✔</span>
          <span className="text-sm text-green-800">
            Knowledge base is active and ready
          </span>
        </div>
      </div>
    </div>
  );
}
