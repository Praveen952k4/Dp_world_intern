import { createContext, useContext } from "react";

const UserContext = createContext(undefined);

export function UserProvider({ role, children }) {
  const value = {
    role,
    isAdmin: role === "admin",
    isEmployee: role === "employee",
  };

  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error("useUser must be used within a UserProvider");
  }
  return context;
}
