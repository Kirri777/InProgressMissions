# Changelog

## v10.1.0 (2026-06-13)

### Added
- Minimap button via LibDataBroker + LibDBIcon (LMB toggles garrison page, RMB opens settings)
- Settings panel with minimap visibility checkbox (Blizzard Settings API)
- Tooltip hints for LMB/RMB actions on minimap button

### Changed
- Refactored monolithic `InProgressMissions.lua` into modular `src/` structure with separate files for Core, Events, UI, Missions, Settings
- Replaced deprecated `GetItemInfo` with `C_Item.GetItemInfo`

### Fixed
- Nil error when opening covenant landing page without a covenant
- Nil error in mission list update when no missions available
- Lua diagnostic warnings across all source files

### Removed
- `improveCovenantMissionUI` toggle (feature always active by default)
- Unused legacy commented code blocks

## v10.0.39 (2026-06-13)

### Added
- Localized Notes and Category entries in TOC
- `.pkgmeta` for CurseForge packager
- CHANGELOG.md

### Fixed
- Nil error in `GarrisonLandingPageReportList_UpdateItems` when no missions available

## v10.0.38b (2024-08-14)

### Fixed
- Own missions not showing up in 11.0.2 ([#4](https://github.com/Kirri777/InProgressMissions/issues/4) — thanks [@hollo6](https://github.com/hollo6))
- `IsAddOnLoaded` error ([#3](https://github.com/Kirri777/InProgressMissions/issues/3) — thanks [@nancikennedy](https://github.com/nancikennedy))

## v10.0.38a (2024-07-29)

### Added
- Initial commit (fork)

### Fixed
- Compatibility with Patch 11.0 ([#1](https://github.com/Kirri777/InProgressMissions/issues/1) — thanks [@Hollo6](https://github.com/Hollo6) from CurseForge)
