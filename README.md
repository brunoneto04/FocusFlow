# FocusFlow

Projeto scaffolding criado para começar o desenvolvimento do app FocusFlow.

Estrutura criada (resumida):
- FocusFlowApp/ (app target)
- FocusFlowShared/ (Swift Package)
- FFDeviceActivityMonitor/ (Device Activity Monitor extension)
- FFShieldConfigurationUI/ (ManagedSettingsUI extension)
- FFDeviceActivityReport/ (optional report extension)
- Packages/
- Scripts/

Próximos passos:
1. Abrir o `.xcodeproj` ou criar um workspace e adicionar targets + Swift Package.
2. Ajustar entitlements e App Group IDs.
3. Implementar serviços reais para HealthKit, FamilyControls e ManagedSettings.
