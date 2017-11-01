# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## [1.0.0] - 2017-11-01
### Added
- Allow timeouts greater than 25s when recognising images.

### Fixed
- Fix that `Scnnr::Client#fetch` with a long timeout does not make multiple request.

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
