# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2019-08-30
### Added
- Support a retrying feature on `Scnnr::Connection`.
- Start supporting Ruby 2.5 and 2.6.

## [1.2.0] - 2018-10-11
### Added
- Support `target` parameter for `Scnnr::Client#coordinate`.

## [1.1.1] - 2018-06-20
### Added
- Support `force` parameter for `Scnnr::Client#recognize_url`.

## [1.1.0] - 2018-03-23
### Added
- Support `public` parameter for `Scnnr::Client#recognize_image`.
- Add `Scnnr::Client#coordinate` to request `POST /v1/coordinates`.

## [1.0.0] - 2017-11-01
### Added
- Allow timeouts greater than 25s when recognising images.

### Fixed
- Fix that `Scnnr::Client#fetch` with a long timeout does not make multiple requests.

### Removed
- Remove `async` from `Scnnr::Response`.

## [0.2.0] - 2017-10-20
### Added
- Add reference links to README.

### Fixed
- Fix the client specs to make them easier to understand.
- Fix to handle `unexpected-content` and `bad-request` API errors.

### Changed
- Rename `UnsupportedError` -> `UnexpectedError`.

## [0.1.0] - 2017-09-21
### Added
- Initial release of scnnr-ruby.
