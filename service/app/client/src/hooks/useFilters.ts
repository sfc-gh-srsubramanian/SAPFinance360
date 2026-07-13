import React, { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import { fetchFilters } from '@/lib/api';

interface FilterContextType {
  companyCodes: string[];
  selectedCompanyCodes: string[];
  setSelectedCompanyCodes: (codes: string[]) => void;
  fiscalYears: string[];
  selectedFiscalYears: string[];
  setSelectedFiscalYears: (years: string[]) => void;
  loading: boolean;
}

const FilterContext = createContext<FilterContextType>({
  companyCodes: [],
  selectedCompanyCodes: [],
  setSelectedCompanyCodes: () => {},
  fiscalYears: [],
  selectedFiscalYears: [],
  setSelectedFiscalYears: () => {},
  loading: true,
});

export function FilterProvider({ children }: { children: ReactNode }) {
  const [companyCodes, setCompanyCodes] = useState<string[]>([]);
  const [selectedCompanyCodes, setSelectedCompanyCodes] = useState<string[]>([]);
  const [fiscalYears, setFiscalYears] = useState<string[]>([]);
  const [selectedFiscalYears, setSelectedFiscalYears] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchFilters()
      .then((data) => {
        setCompanyCodes(data.companyCodes);
        setSelectedCompanyCodes(data.companyCodes);
        setFiscalYears(data.fiscalYears);
        setSelectedFiscalYears(data.fiscalYears);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, []);

  return React.createElement(
    FilterContext.Provider,
    {
      value: {
        companyCodes,
        selectedCompanyCodes,
        setSelectedCompanyCodes,
        fiscalYears,
        selectedFiscalYears,
        setSelectedFiscalYears,
        loading,
      },
    },
    children
  );
}

export function useFilters() {
  return useContext(FilterContext);
}
