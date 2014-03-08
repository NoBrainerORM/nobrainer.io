---
layout: docs
title: FAQ
prev_section: communication
next_section: credits
permalink: /faq/
---

### General Topics

* **Is NoBrainer production ready?**  
Hard to tell. We need courageous people to make it battle tested.

* **Is NoBrainer thread safe?**  
Yes. If you encounter an issue, please create an GitHub issue.

* **Is NoBrainer going to be maintained in the future?**  
Yes.

* **How is NoBrainer licensed?**  
NoBrainer is licensed under the LGPLv3.

### Runtime Issues

* **A stack overflow exception occured while overriding attributes**  
Use `super` as explained on issue
[#55](https://github.com/nviennot/nobrainer/issues/55#issuecomment-32217530).

* **Why are getters are called during object initialization**  
When setting attributes, NoBrainer calls your corresponding getters to perform
dirty tracking and remember the value as explained on issue
[#57](https://github.com/nviennot/nobrainer/issues/57).
