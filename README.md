# FocusFlow

Aplicação iOS em SwiftUI para ajudar pessoas a reduzirem distrações, planear blocos de foco e conquistar minutos extra de utilização ao atingir metas de atividade física. O projeto integra **Screen Time/Family Controls**, **ManagedSettings**, **DeviceActivity** e **HealthKit** para controlar apps, acompanhar passos e libertar bónus de tempo.

## Visão geral
- **Onboarding guiado**: recolhe a meta principal, o limite diário de utilização e ativa o fluxo inicial antes de entrar na app.
- **Dashboard**: mostra o próximo bloco de foco, progresso diário, estatísticas de uso, dicas de motivação e banners de permissões.
- **Bónus por atividade**: `ActivityBonusOrchestrator` soma minutos extra conforme passos lidos no HealthKit e desbloqueia apps temporariamente.
- **Bloqueio de apps e websites**: `ScreenTimeManager` aplica/remove escudos usando seleções do `FamilyActivitySelection`.
- **Sessões rápidas**: ações para iniciar, pausar ou pedir pausa de 5 minutos mantendo feedback visual (ProgressRing, haptics simples).
- **Motivação e dicas**: serviço de frases aleatórias (`MotivationService`) e lembretes configuráveis.
- **Configurações**: ajuste de metas, haptics e seleção de apps bloqueados em `SettingsView`/`BlockedAppsView`.

## Arquitetura
- **SwiftUI + MVVM**: `FocusFlowApp` decide entre onboarding e `RootView`; cada feature possui `View` + `ViewModel` e usa `@AppStorage` para preferências rápidas.
- **Services**: camadas para HealthKit (`HealthKitManager`), Screen Time/ManagedSettings (`ScreenTimeManager`), persistência simples (`AppGroupStorage`), cálculo de bónus por passos (`StepBonusEngine`/`ActivityBonusOrchestrator`).
- **Design system**: componentes como `ProgressRing` e temas de onboarding (`OnboardingTheme`).
- **Compatibilidade**: orientado para iOS 16+ por exigir Family Controls/DeviceActivity; algumas APIs não funcionam no simulador.

## Estrutura do repositório
- `FocusFlow/`
  - `App/`: ponto de entrada (`FocusFlowApp`, `AppDelegate`), roteamento e `RootView`.
  - `Core/`: configuração (`Config`), temas (`DesignSystem`), recursos (`Resources`), serviços (`Services` para HealthKit, Screen Time, persistência) e utilitários.
  - `Features/`: ecrãs de Onboarding, Dashboard (permissões, cartões, barras de ações), Permissions, Settings e Motivation.
  - `FocusFlow.entitlements`: habilita Family Controls, HealthKit e App Groups.
- `FocusFlowShared/`: pacote Swift de modelos/utilidades partilhados (ex.: `ActivityCredit`).
- `FFDeviceActivityReport/`: extensão placeholder para relatórios de atividade do Screen Time.
- `FFShieldConfigurationUI/`: extensão placeholder para UI de escudos do ManagedSettingsUI.
- `Packages/` e `Scripts/`: anotações para dependências via SPM e scripts de automação/lint (placeholders).
- `FocusFlow.xcodeproj`: projeto Xcode com alvos da app e extensões.

## Requisitos
- **Xcode** 15 ou superior.
- **iOS** 16+ (Family Controls/DeviceActivity/ManagedSettings são restritos a dispositivos físicos).
- Conta Apple Developer com permissões para HealthKit e Screen Time.

## Configuração rápida
1. **Clonar**
   ```bash
   git clone https://github.com/<sua-conta>/FocusFlow.git
   cd FocusFlow
   ```
2. **Abrir no Xcode**
   - Use `FocusFlow.xcodeproj` e selecione uma equipa de assinatura.
3. **Ajustar identificadores**
   - Actualize o *Bundle Identifier* da app e das extensões (`FFDeviceActivityReport`, `FFShieldConfigurationUI`) para o seu domínio.
   - Ajuste o App Group em `FocusFlow/Core/Services/Persistence/AppGroupStorage.swift` e em `FocusFlow.entitlements` para o identificador que controla.
4. **Habilitar capacidades**
   - Family Controls, DeviceActivity, ManagedSettings, HealthKit e App Groups devem estar ativos na app e extensões correspondentes.
5. **Executar no dispositivo**
   - No primeiro uso, conclua o onboarding e acione o banner de permissões para pedir acesso ao Screen Time e HealthKit.
   - Selecione apps/domínios a bloquear em Settings → “Blocked Apps”.
## Dicas de desenvolvimento
- HealthKit/Screen Time só respondem em dispositivo físico; o fluxo de bónus por passos ficará a zero no simulador.
- `ActivityBonusOrchestrator` e `DashboardViewModel` usam `@MainActor` e Combine; ao integrar com dados reais, mantenha atualizações na main queue.
- Use o `ManagedSettingsStore` em `ScreenTimeManager` para aplicar/remover escudos após receber autorizações.
