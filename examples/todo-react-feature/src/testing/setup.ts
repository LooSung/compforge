import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

afterEach(() => {
  cleanup();
  // Reset URL state between tests (filter lives in the URL).
  window.history.replaceState(null, '', window.location.pathname);
});
