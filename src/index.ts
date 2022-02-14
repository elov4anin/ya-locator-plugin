import { registerPlugin } from '@capacitor/core';

import type { VerYaLocatorPlugin } from './definitions';

const VerYaLocator = registerPlugin<VerYaLocatorPlugin>('VerYaLocator', {
  web: () => import('./web').then(m => new m.VerYaLocatorWeb()),
});

export * from './definitions';
export { VerYaLocator };
