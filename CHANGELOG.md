# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [2.0.0.0] - 2017-12-08

### Changed

- Load distribution mode can be be specified via ```parameters('network').loadbalancing.rules.(first | second).loadDistribution```. If you're using load balancer this property needs to be defined in your scripts. This is breaking change and thats why I am bumping to 2.0.0.0  Available values:
- - Default
- - SourceIP
- - SourceIPProtocol
