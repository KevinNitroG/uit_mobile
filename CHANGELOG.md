# Changelog

## [1.1.0](https://github.com/KevinNitroG/uit_mobile/compare/v1.0.6...v1.1.0) (2026-02-25)


### Features

* improve home screen UX and add debug JSON viewer ([bb35bfa](https://github.com/KevinNitroG/uit_mobile/commit/bb35bfa9bbb062fc5fbdb56b92698011c3783162))


### Bug Fixes

* pending is con cho, fee screen rewrite? ([b5ee98c](https://github.com/KevinNitroG/uit_mobile/commit/b5ee98c3e35caca761521df5510630e138dc2876))
* restore previousDebt in remaining calc and fix home fee card overflow ([d9a5dbf](https://github.com/KevinNitroG/uit_mobile/commit/d9a5dbf85c077d018ddfe4904031e005d310e0e2))
* simplify fee remaining to max(due - paid, 0) and theme debug JSON view ([dadf8a8](https://github.com/KevinNitroG/uit_mobile/commit/dadf8a8c87ece087a61d6c679c2a53e6b0426231))

## [1.0.6](https://github.com/KevinNitroG/uit_mobile/compare/v1.0.5...v1.0.6) (2026-02-25)


### Bug Fixes

* header of overview score be centerl ([75257a1](https://github.com/KevinNitroG/uit_mobile/commit/75257a1ce4a0235390d9e21ff4a4fd3ffc637019))

## [1.0.5](https://github.com/KevinNitroG/uit_mobile/compare/v1.0.4...v1.0.5) (2026-02-25)


### Bug Fixes

* i18n debt ([ee933ba](https://github.com/KevinNitroG/uit_mobile/commit/ee933bac06f01c258c22ff5fa5419916258eb495))

## [1.0.4](https://github.com/KevinNitroG/uit_mobile/compare/v1.0.3...v1.0.4) (2026-02-25)


### Bug Fixes

* no total debt? just check is paid in fee ([11259c2](https://github.com/KevinNitroG/uit_mobile/commit/11259c2824a19b71825528e8e80886f0f4ac8581))


### Documentation

* **README:** note no maintain ([b30dd22](https://github.com/KevinNitroG/uit_mobile/commit/b30dd22405a86a5f7c9edcec26144174617dd5d9))

## [1.0.3](https://github.com/KevinNitroG/uit_mobile/compare/v1.0.2...v1.0.3) (2026-02-25)


### Bug Fixes

* version tracked by release please ([7fc8ea6](https://github.com/KevinNitroG/uit_mobile/commit/7fc8ea68c1029e72ec2b2f0933b947aa2ec7fa51))


### Refactoring

* use notruoc from API directly for previous debt instead of computing remaining ([7a8d211](https://github.com/KevinNitroG/uit_mobile/commit/7a8d211aa930cbaac73ebb6ae56dee7c49d1cba9))

## [1.0.2](https://github.com/KevinNitroG/uit_mobile/compare/v1.0.1...v1.0.2) (2026-02-24)


### Refactoring

* the way release please track version ([2e30e78](https://github.com/KevinNitroG/uit_mobile/commit/2e30e782de50abe97c93e21175466ff4c0a72be6))


### Documentation

* **README:** note feature cache and refresh token ([86ab15d](https://github.com/KevinNitroG/uit_mobile/commit/86ab15d1e066c468ec973f33340eda5086cd3020))

## [1.0.1](https://github.com/KevinNitroG/uit_mobile/compare/v1.0.0...v1.0.1) (2026-02-24)


### Refactoring

* improve ui/ux across multiple screens ([f429c10](https://github.com/KevinNitroG/uit_mobile/commit/f429c107effa5fe1e315e03437e8798f27e881b8))

## [1.0.0](https://github.com/KevinNitroG/uit_mobile/compare/v0.3.0...v1.0.0) (2026-02-24)


### ⚠ BREAKING CHANGES

* **exams, deadlines, fees:** Exam and Deadline model fields as enums/booleans, may affect consumers

### Features

* **exams, deadlines, fees:** robust data parsing and user-friendly display ([26c37a8](https://github.com/KevinNitroG/uit_mobile/commit/26c37a88be06971596a4439d680b8f8453168f5e))
* general score screen, maybe it is overview or something ([0c401fc](https://github.com/KevinNitroG/uit_mobile/commit/0c401fc4265d0ef42f905cd52cf9d413c2bd3567))


### Bug Fixes

* **fees, auth:** wire fees into Hive cache and restore instant startup ([61b6b38](https://github.com/KevinNitroG/uit_mobile/commit/61b6b38fdd7ad220db641ef447354520e9c13b2f))

## [0.3.0](https://github.com/KevinNitroG/uit_mobile/compare/v0.2.0...v0.3.0) (2026-02-24)


### Features

* i18n for day in timetable ([13e12a1](https://github.com/KevinNitroG/uit_mobile/commit/13e12a16f537f35ddb504b7e511f6e338957b6d0))


### Documentation

* README ([bf49620](https://github.com/KevinNitroG/uit_mobile/commit/bf49620715105209d9d573bc4b17bec0ff4811e4))
* **README:** some todo feature ([916f030](https://github.com/KevinNitroG/uit_mobile/commit/916f0308e40aad31ddb5e1860f3a0df083827ce1))

## [0.2.0](https://github.com/KevinNitroG/uit_mobile/compare/v0.1.0...v0.2.0) (2026-02-24)


### Features

* AI do so much, but account switching doesn't work ([5d9efba](https://github.com/KevinNitroG/uit_mobile/commit/5d9efba38dd827f030a5b91ac588615c8f1f5b8d))
* AI fix the auth? ([5d5a830](https://github.com/KevinNitroG/uit_mobile/commit/5d5a830edc605786abe0d752352e9117f7a047a3))
* exam screen, account switching still not work, and release please ([b244618](https://github.com/KevinNitroG/uit_mobile/commit/b244618866edaa2ebe53579280177caf3e61268e))
* init plan md ([bf9ba55](https://github.com/KevinNitroG/uit_mobile/commit/bf9ba55f268bddc2536c929b43e3c6c6c6cfb48d))


### Bug Fixes

* android with internet perm, and trim score, exam screen idk what did it change? ([93bf875](https://github.com/KevinNitroG/uit_mobile/commit/93bf8750f6f51bad55bd7fa290eef6bb95d20777))
* ios uri auth? ([e2d2a2c](https://github.com/KevinNitroG/uit_mobile/commit/e2d2a2cdb45fa41e0b68f809915e34c0036dbb08))
