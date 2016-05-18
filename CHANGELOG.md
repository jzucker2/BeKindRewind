# BeKindRewind — CHANGELOG

## [2.3.1](https://github.com/jzucker2/BeKindRewind/releases/tag/2.3.1)

* Silenced warning for using deprecated matching override method

## [2.3.0](https://github.com/jzucker2/BeKindRewind/releases/tag/2.3.0)

* Refactored matching overrides

## [2.2.0](https://github.com/jzucker2/BeKindRewind/releases/tag/2.2.0)

* Added ability to override matching for components of a request URL

## [2.1.1](https://github.com/jzucker2/BeKindRewind/releases/tag/2.1.1)

* Fixed bug where request failed matching block fails to copy for `BKRTestConfiguration`

## [2.1.0](https://github.com/jzucker2/BeKindRewind/releases/tag/2.1.0)

* Added feature to execute a block when a request fails to match during playing.

## [2.0.0](https://github.com/jzucker2/BeKindRewind/releases/tag/2.0.0)

* Added ability to control timing of requests and responses during stubbing.
* Can set request download speed instead of a time (using a negative value).
* Added new matcher for request and response timing called BKRPlayheadWithTimingMatcher
* Fixed bug by moving VCR initialization from `XCTestCase` constructor to `setUp` to fix incorrect assumption of `XCTestCase` execution.

## [1.0.0](https://github.com/jzucker2/BeKindRewind/releases/tag/1.0.0)

* Official full release.
* Added `@since` tags to all inline documentation.
* Added support for testing on other platforms (OSX, tvOS) and running in CI.
* Recording an empty cassette (recording session has no network activity) is `YES` by default instead of `NO`.
* Cleaned up README for release, including a note on possible recording exceptions and solutions.

## [0.10.0](https://github.com/jzucker2/BeKindRewind/releases/tag/0.10.0)

* First stable, complete version.
* Proper handling of redirects.
* New matcher and redesigned playing architecture.
* Created helper method for comparing matching network requests.

## [0.9.5](https://github.com/jzucker2/BeKindRewind/releases/tag/0.9.5)

* Fixed chunked data responses.

## [0.9.4](https://github.com/jzucker2/BeKindRewind/releases/tag/0.9.4)

* Can now optionally reset matcher between sessions.

## [0.9.3](https://github.com/jzucker2/BeKindRewind/releases/tag/0.9.3)

* Added working main header file for simple `#import` usage in projects.

## [0.9.2](https://github.com/jzucker2/BeKindRewind/releases/tag/0.9.2)

* Cleaned up project and rewrote README.

## [0.9.1](https://github.com/jzucker2/BeKindRewind/releases/tag/0.9.1)

* Added a proper XCTestCase subclass.

## [0.9.0](https://github.com/jzucker2/BeKindRewind/releases/tag/0.9.0)

* Created a BKRTestVCR for easy use within XCTestCase

## [0.8.0](https://github.com/jzucker2/BeKindRewind/releases/tag/0.8.0)

* Fully working VCR with many fixes.

## [0.7.2](https://github.com/jzucker2/BeKindRewind/releases/tag/0.7.2)

* Completely refactored and streamlined tests.

## [0.7.1](https://github.com/jzucker2/BeKindRewind/releases/tag/0.7.1)

* Unified subclasses of BKRCassette into a single class (with categories for playing and recording functionality).

## [0.7.0](https://github.com/jzucker2/BeKindRewind/releases/tag/0.7.0)

* Significant rewrite with extended tests.
* Increased stability.

## [0.6.0](https://github.com/jzucker2/BeKindRewind/releases/tag/0.6.0)

* Fully working VCR subclasses (for recording and playing).

## [0.5.4](https://github.com/jzucker2/BeKindRewind/releases/tag/0.5.4)

* Full inline documentation.

## [0.5.3](https://github.com/jzucker2/BeKindRewind/releases/tag/0.5.3)

* Added significant inline documentation.

## [0.5.2](https://github.com/jzucker2/BeKindRewind/releases/tag/0.5.2)

* Added more inline documentation.

## [0.5.1](https://github.com/jzucker2/BeKindRewind/releases/tag/0.5.1)

* Started adding inline documentation.

## [0.5.0](https://github.com/jzucker2/BeKindRewind/releases/tag/0.5.0)

* Working version of all components except test subclass.

## [0.3.0](https://github.com/jzucker2/BeKindRewind/releases/tag/0.3.0)

* Working tests and proper player and error handling.

## [0.2.1](https://github.com/jzucker2/BeKindRewind/releases/tag/0.2.1)

* Removed warnings introduced with player.

## [0.2.0](https://github.com/jzucker2/BeKindRewind/releases/tag/0.2.0)

* Now includes working player.

## [0.1.5](https://github.com/jzucker2/BeKindRewind/releases/tag/0.1.5)

* Proper serializing and deserializing.

## [0.1.3](https://github.com/jzucker2/BeKindRewind/releases/tag/0.1.3)

* Updated CI and strengthened tests.

## [0.1.2](https://github.com/jzucker2/BeKindRewind/releases/tag/0.1.2)

* Cleaner version of framework.

## [0.1.1](https://github.com/jzucker2/BeKindRewind/releases/tag/0.1.1)

* Fixed a multitude of warnings.

## [0.1.0](https://github.com/jzucker2/BeKindRewind/releases/tag/0.1.0)

* Initial pod.
