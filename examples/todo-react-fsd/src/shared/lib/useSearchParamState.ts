import { useCallback, useSyncExternalStore } from 'react';

// The browser URL is a system React does not own — syncing with it is the one
// legitimate job of a subscription (skills/react/hooks-discipline.md).
function subscribe(onChange: () => void): () => void {
  window.addEventListener('popstate', onChange);
  return () => window.removeEventListener('popstate', onChange);
}

export function useSearchParamState(key: string, defaultValue: string) {
  const value = useSyncExternalStore(subscribe, () => {
    return new URLSearchParams(window.location.search).get(key) ?? defaultValue;
  });

  const setValue = useCallback(
    (next: string) => {
      const params = new URLSearchParams(window.location.search);
      if (next === defaultValue) {
        params.delete(key);
      } else {
        params.set(key, next);
      }
      const query = params.toString();
      window.history.pushState(null, '', query ? `?${query}` : window.location.pathname);
      window.dispatchEvent(new PopStateEvent('popstate'));
    },
    [key, defaultValue],
  );

  return [value, setValue] as const;
}
