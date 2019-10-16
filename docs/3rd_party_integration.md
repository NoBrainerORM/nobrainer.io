---
layout: docs
title: 3rd-party Integration
permalink: /docs/3rd_party_integration/
---

NoBrainer can be extended to support other functionnality and play nicely with
other gems. The following describes such gems.

## Devise

[devise-nobrainer](https://github.com/nviennot/devise-nobrainer) is an adapter
to make [Devise](https://github.com/plataformatec/devise/) work nicely with
NoBrainer.

If devise does not work, make sure that your `config/initializers/devise.rb` file
contains `require 'devise/orm/nobrainer'`.

## CarrierWave

[carrierwave-nobrainer](https://github.com/nviennot/carrierwave-nobrainer) is an
adapter for [CarrierWave](https://github.com/carrierwaveuploader/carrierwave/).
CarrierWave associate uploaded files to models.

## Awesome Print

[awesome_print](https://github.com/michaeldv/awesome_print) pretty prints objects.
NoBrainer is supported natively.

## Searchkick

[Searchkick](https://github.com/ankane/searchkick) learns what your users are
looking for. As more people search, it gets smarter and the results get better.
It’s friendly for developers - and magical for your users.
NoBrainer is supported natively. This gem relies on ElasticSearch.

## Kaminari

[Kaminari](https://github.com/amatsuda/kaminari) is a paginator.
NoBrainer is supported through the
[kaminari-nobrainer](https://github.com/nviennot/kaminari-nobrainer) adaptor.

## NoBrainer::Tree

[nobrainer-tree](https://github.com/eksoverzero/nobrainer-tree) implements a tree
structure for NoBrainer documents using the materialized path pattern.

Note: The data structures used may lead to data inconsistencies in the face of
network partitions as this implementation would need transactions or 2pcs.

## DelayedJob
[delayed_job_nobrainer](https://github.com/eilers/delayed_job_nobrainer) is a backend for [DelayedJob](https://github.com/collectiveidea/delayed_job). 
DelayedJob implements delayed background tasks into Rails and is one of the Backends for [ActiveJobs](http://edgeguides.rubyonrails.org/active_job_basics.html).

