import type { PermissionState } from '@capacitor/core';

export interface VerYaLocatorPlugin {
  requestCoordinates(options: { version: string, url: string, api_key: string }): Promise<{version: string, url: string, api_key: string}>;
}

export interface PermissionStatus {
  location: PermissionState;
  network: PermissionState;
}
