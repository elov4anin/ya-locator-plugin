export interface VerYaLocatorPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
