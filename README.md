This application creates an RSS feed containing the last 30 pods added to [CocoaPods/specs](https://github.com/CocoaPods/specs) and during each update it tweets about the new pods.

## Application

- Running on Ruby 1.9.2/3.
- Procfile-based Sinatra application.
- Requires a host caplable of managing a git repository.
- Available at http://feeds.cocoapods.org [Not working yet].
- Based on [cococapods.org](https://github.com/CocoaPods/CocoaPods.org).

## Setup

```shell
$ cp .env.sample .env
$ vim .env
$ bundle install
$ foreman start
```

[GitHub post-receive hook](http://help.github.com/post-receive-hooks/):

```shell
$ curl -d 'payload={"ref":"refs/heads/master"}' http://localhost:5000/hook
```

## Events

- Initialization:
    1. the specs repo is cloned or updated in `tmp/.cocoapods/master`.
    2. the feed is created in `public/new-pods.rss`.
- GitHub post-receive hook:
    1. the specs repo is updated.
    2. the feed is recreated.
    3. tweets for the new pods.

## Performance

- Finding the creation date requires to execute git for every pod.
    - the creation date _should_ never change and for this reason are cached directly by the CocoaPods lib.
    - This app should cache this information itself but, to keep things simple, it simply leverages the existing infrastructure.
- GitHub stats require a network roundtrip for every pod.
    - As the watcher and the followers change slowly the pod command caches this information for 3 days.
    - This app to preserve processor time during the feed generation simply offers a snapshot of the stats at the publication of the pod in the feed.
        - i.e. the `cache_duration` in `Pod::Specification::Statistics` is set to a huge time.
