import React, { createContext, useContext, useState } from 'react';
import { Slot } from 'expo-router';

export interface RegistrationData {
  fullName: string;
  dob: string;
  gender: string;
  fatherName: string;
  birthPlace: string;
  address: string;
  aadhaar: string;
  email: string;
  phone: string;
  nomineeName: string;
  nomineeRelationship: string;
  username?: string;
  pin?: string;
  password?: string;
}

interface RegistrationContextType {
  data: RegistrationData;
  updateData: (fields: Partial<RegistrationData>) => void;
  resetData: () => void;
}

const RegistrationContext = createContext<RegistrationContextType | undefined>(undefined);

export const useRegistration = () => {
  const context = useContext(RegistrationContext);
  if (!context) {
    throw new Error('useRegistration must be used within a RegistrationProvider');
  }
  return context;
};

const initialData: RegistrationData = {
  fullName: '',
  dob: '',
  gender: '',
  fatherName: '',
  birthPlace: '',
  address: '',
  aadhaar: '',
  email: '',
  phone: '',
  nomineeName: '',
  nomineeRelationship: '',
};

export default function RegisterLayout() {
  const [data, setData] = useState<RegistrationData>(initialData);

  const updateData = (fields: Partial<RegistrationData>) => {
    setData((prev) => ({ ...prev, ...fields }));
  };

  const resetData = () => {
    setData(initialData);
  };

  return (
    <RegistrationContext.Provider value={{ data, updateData, resetData }}>
      <Slot />
    </RegistrationContext.Provider>
  );
}
