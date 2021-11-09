---
layout: docs
title: Testing
permalink: /docs/testing/
---

After having cloned the nobrainer repository, you can run the Rspec test suite
using the following.

## Prerequisites

You can use a Ruby version manager and install all on your local machine, or you
can use Docker (recommended way).

So you need to install [Docker](https://docs.docker.com/get-docker/) first.

This project is compatible with [Docker Compose](https://docs.docker.com/compose/)
which is best while developing since you can very quickly run the desired tests.

### Running the suite with Compose

The first step is to build the Docker image with the command:

{% highlight ruby %}
docker-compose build gem
{% endhighlight %}

After this is done, you can run the suite with:

{% highlight ruby %}
docker-compose up
{% endhighlight %}

Docker Compose will first download the Docker image of RethinkDB and then start
the database and run the entire test suite.
Keep this window open, RethinkDB runs and you'll be able to `exec` in the `gem`
container some commands.

Now change the code as you need and then when you need to run some tests:

{% highlight ruby %}
docker-compose exec gem bundle exec rspec <path to your spec file(s)>
{% endhighlight %}

### Cleanup

When you're done and want to cleanup your system, you can stop the stack using
`CTRL` + `C` and then run the following command:

{% highlight ruby %}
docker-compose down
{% endhighlight %}

**WARNING:** All the data will be lost.

### What about the CI?

Nobrainer uses the awesome [Earthly](https://earthly.dev/) tool in order to
build and run the tests. It's a build automation tool that allow you to execute
all your builds in containers, which makes builds self-contained, repeatable,
portable and parallel.

In other words: If tests are passing in Earthly locally, it will pass on the CI
too!

You can [install Earthly](https://earthly.dev/get-earthly) locally and run
the test suite with:

{% highlight ruby %}
earthly +rspec
{% endhighlight %}
