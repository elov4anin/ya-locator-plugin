import { WebPlugin } from '@capacitor/core';

import type { VerYaLocatorPlugin } from './definitions';

export class VerYaLocatorWeb extends WebPlugin implements VerYaLocatorPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
