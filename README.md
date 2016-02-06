Sidekiq HOL (Head-of-Line)
==========================

## Description

For high priority jobs, and you don't want to bypass the job queue, submit your Sidekiq job to the head of the queue.

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'sidekiq-hol'
```

## Caveats

`sidekiq-hol` does not work with `reliable_fetch`, Sidekiq Enterprise Rate Limiting, or any other feature that dynamically reorders jobs within a Sidekiq queue.

## Usage

Add a worker to process jobs asynchronously using Sidekiq-HOL:

```ruby
class SomeWorker
  include Sidekiq::Hol::Worker

  def perform(name, count)
    # do something
  end
end
```

Create the asynchronous job:

```ruby
SomeWorker.perform_hol_async 'maggie', 1
```

Even though `SomeWorker` includes `Sidekiq::Hol::Worker` you can still use the regular `perform_async` method to submit a job at the end of a queue:

```ruby
SomeWorker.perform_async 'lisa', 8
```

## Motivation

In one of the apps I was working on, some of the Sidekiq jobs were both long-running (they could take several minutes, or hours to complete) and numerous. If someone had wanted a job to be executed immediately, this might not have been possible since it would have been placed at the end of the queue, and earlier jobs could have taken weeks or months to finish.

`sidekiq-hol` solves this problem by allowing a user to submit high-priority jobs at the front of the job queue. Note, if all jobs were to be submitted using `sidekiq-hol` then this would defeat its purpose. Please use it judiciously!

Licence
=======

See [LICENCE](https://github.com/mykoweb/sidekiq-hol/blob/master/LICENSE)
