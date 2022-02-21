import { WebPlugin } from '@capacitor/core';

import type { VerYaLocatorPlugin } from './definitions';

export class VerYaLocatorWeb extends WebPlugin implements VerYaLocatorPlugin {

  async requestCoordinates(options: { version: string, url: string, api_key: string }): Promise<{ version: string, url: string, api_key: string }> {
    console.log('options', options);
    throw this.unimplemented('Not implemented on web.');
  }
}
