---
layout: docs
title: FAQ
permalink: /faq/
---

## General Topics

### **Is NoBrainer production ready?**
NoBrainer is currently used in production systems, so I'd say yes.

### **Is NoBrainer thread safe?**
Yes. If you encounter an issue, please create a GitHub issue.

### **How is NoBrainer licensed?**
NoBrainer is licensed under the LGPLv3.

## Runtime Topics

### **A stack overflow exception occured while overriding attributes**
Use `super` as explained on issue
[#55](https://github.com/nviennot/nobrainer/issues/55#issuecomment-32217530).

### **Why are getters called during object initialization**
When setting attributes, NoBrainer calls your corresponding getters to perform
dirty tracking and remember the value as explained on issue
[#57](https://github.com/nviennot/nobrainer/issues/57).

### **How to enable RQL query logging?**
Configure NoBrainer's logger with a level of `Logger::DEBUG`.

### **How to sync the DB schema at boot time?**

You can add `NoBrainer.sync_schema if Rails.env.development?` in an initializer for example.
