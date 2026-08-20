import 'server-only';

/** Bound on the server. Client features must never import this module. */
export function getRequestId(): string {
  return 'server';
}
