# RSS and Twitter notifications for new Pods
[![Build Status](https://secure.travis-ci.org/CocoaPods/feeds.cocoapods.org.svg)](http://travis-ci.org/CocoaPods/feeds.cocoapods.org)

This application creates and updates an RSS feed containing the
last 30 pods added to [CocoaPods/specs](https://github.com/CocoaPods/specs).
During each update it tweets the new pods.

## Application

- Running on Ruby 1.8.7, 1.9.2, and 1.9.3.
- Procfile-based Sinatra application. 
- Available at http://feeds.cocoapods.org.
- Based on [CocoaPods/CocoaPods.org](https://github.com/CocoaPods/CocoaPods.org).
- Exception tracking provided by [except.io](http://except.io/).

## Setup

```shell
$ cp .env.sample .env
$ vim .env
$ rake bootstrap
$ foreman start
```

Run Tests:

```shell
$ rake
```


## License and Contributions

This application and CocoaPods are available under the [MIT license](http://www.opensource.org/licenses/mit-license.php).

Contributing to the [CocoaPods projects](https://github.com/CocoaPods) is really easy and gratifying. 
You even get push access when one of your patches is accepted.

## Events
    
- Trunk post-receive hook:
    1. A pod is added or updated