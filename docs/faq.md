---
layout: docs
title: FAQ
prev_section: communication
next_section: credits
permalink: /faq/
---

## General Topics

### **Is NoBrainer production ready?**
NoBrainer is currently used in production systems, so I'd say yes.

### **Is NoBrainer thread safe?**
Yes. If you encounter an issue, please create an GitHub issue.

### **How is NoBrainer licensed?**
NoBrainer is licensed under the LGPLv3.

## Runtime Topics

### **`save` does not return true/false, why?**
Too many applications have code where `save` is used instead of `save!`,
which make things fail silently and difficult to debug.
Not raising exceptions should be explicit when persisting data, and so
`save?` is the non-raising version of `save`.

### **A stack overflow exception occured while overriding attributes**
Use `super` as explained on issue
[#55](https://github.com/nviennot/nobrainer/issues/55#issuecomment-32217530).

### Validations are run after `before_save`
I made this decision after seeing that many developers change model data in
`before_save` callbacks.

### **Why are getters called during object initialization**
When setting attributes, NoBrainer calls your corresponding getters to perform
dirty tracking and remember the value as explained on issue
[#57](https://github.com/nviennot/nobrainer/issues/57).

### **How to enable RQL query logging?**
Configure NoBrainer's logger with a level of `Logger::DEBUG`.

### **How to sync the indexes at boot time?**

You can add `NoBrainer.sync_indexes if Rails.env.development?` in an initializer for example.
