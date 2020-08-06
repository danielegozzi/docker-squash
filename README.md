# docker-squash
The third implementation of a typical docker task that Docker should have implemented/distributed a long time ago.

As of today, `docker build` supporta a `--squash` flag that relies on Docker features that I don't feel comfortable experimenting with. 

Other implementations of the same concept being:
* [jwilder/docker-squash](https://github.com/jwilder/docker-squash) in Go
* [goldmann/docker-squash](https://github.com/goldmann/docker-squash) in Python

One (1) lengthy overall (integration) test has been written validating one happy-path execution. If you plan to submit pull requests please extend the test code according to your fix.

Understand that this program is not systematically verified besides not having obviously crapped on my image store.

Usage:

```console
$ docker-squash.sh NAME[:TAG]
```

Effect:

The image will be instantiated in a temporary container, the container will be exported and imported in a new image composed by a single layer, thus eliminating all wasted space in intermediate layers (and erasing the history of the image origin).

The newly imported image will be tagged with the same name as the old image, thus *probably* making the old one a dangling image. Remember to prune dangling images every once in a while.

The image import command allows us to set the following image attributes as you would specify in a Dockerfile:
* `CMD`
* `ENTRYPOINT`
* `ENV`
* `EXPOSE`
* `ONBUILD`
* `USER`
* `VOLUME`
* `WORKDIR`

So I'm doing my best to copy those settings from the original image and of course this is the trickiest part.
