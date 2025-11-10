Workspace organization and next steps to consolidate scaffolding

Goal
- Centralize the app source under the Xcode-managed folder and avoid duplicate `@main` entry points.

Current state
- The repo contains an Xcode app folder `FocusFlow/` (this is the canonical Xcode sources folder).
- There is also scaffold content created under a separate folder. This can cause duplicate `@main` definitions if both sets of files are added to the same target.

Recommended consolidation steps (on macOS with Xcode)
1. Open the project in Xcode
   - In Finder double-click `FocusFlow.xcodeproj` (or `FocusFlow.xcworkspace` if present).
2. Inspect Source Groups
   - In the Project navigator, locate the `FocusFlow` app target and see which files are included.
3. Keep a single app entry point
   - Ensure only one file declares `@main struct FocusFlowApp: App` in the App target. Remove or exclude any duplicate `FocusFlowApp.swift` from other folders.
4. Move scaffold files into `FocusFlow/`
   - Create groups/folders inside the `FocusFlow` group: `App`, `Features`, `Services`, `UI`, `Resources`, `Config`, `Tests`.
   - Add existing scaffold source files into those groups. When adding files, select "Add to targets" and include only the App (or appropriate extension) target.
   - Do NOT add the scaffold `App/FocusFlowApp.swift` if you want to keep the original `FocusFlow/FocusFlowApp.swift` as the entry point.
5. Add `FocusFlowShared` as a local Swift Package
   - In Xcode: File → Add Packages... → Add Local Package by selecting the `FocusFlow/FocusFlowShared` folder or add via Package.swift at repository path.
   - Add the package as a dependency to the app and any extensions that need it.
6. Configure Entitlements and Capabilities
   - In the App target and extension targets enable App Groups, HealthKit, Family Controls, Device Activity and add the correct App Group IDs in the .entitlements files.
7. Verify build targets per file
   - For each source file in Project navigator, open the File Inspector and confirm the "Target Membership" checkboxes.
8. Run on a device
   - DeviceActivity/FamilyControls/ManagedSettings features require a real device. Test these features on a physical iPhone.

If you want, I can perform the following automated changes here now (note: Xcode must be used on macOS to complete some wiring):
- Create `Package.swift` (done).
- Create or move placeholder files into `FocusFlow/` (I can copy placeholders but final target wiring must be done inside Xcode).
- Remove a duplicate `@main` file if you confirm which one to keep.

Tell me which `FocusFlowApp.swift` to keep as the canonical app entry point:
- A) `FocusFlow/FocusFlowApp.swift` (original created by Xcode) — recommended
- B) `FocusFlowApp/App/FocusFlowApp.swift` (scaffold placeholder)

After you choose, I can remove the other duplicate and create matching folder structure inside `FocusFlow/` with placeholders ready to be added to the Xcode project.
