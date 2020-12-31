---
layout: page
title: About
permalink: /about/
---

Visualizing metrics is an incredibly common and valuable task. Virtually every
department in a business likes to leverage data when making decisions. Time and
time again I've seen developers implement one-off solutions for automatic
reporting, sometimes quick and dirty, sometimes highly polished. For example:

  * A weekly email to the entire company showing the main engagement KPIs for
    the product.
  * A weekly Slack message to a team channel showing how many alerts the on-call
    team member had to respond to in the previous week.
  * A daily summary of sales numbers and targets.

Thanks largely to Grafana, teams are customizing real-time dashboards to always
have an up-to-date view on the health of a system or the health of the business.
However, there is often value in distilling a continuum of real-time metrics
into a short digestible report. KPI Reporter attempts to make it easier to build
such reports.

A few guiding principles that shape this project:

  1. **It should be possible to run on-premises.** It is far easier to run a
     reporting tool within an infrastructure due to the amount of data sinks
     that must be accessible. Security teams should rightly raise eyebrows when
     databases are exposed externally just so a reporting tool can reach in.
  2. **It should be highly customizable.** There should not be many assumptions
     about either layout or appearance. The shape and type of data ultimately
     will drive this.
  3. **It should be possible to extend.** The space of distinct user needs is
     massive. While the tool should aim to provide a lot of useful functionality
     out of the box, it will always be the case that custom extensions will be
     required to achieve a particular implementation. The tool should embrace
     this reality.

[Read More](https://kpi-reporter.readthedocs.io/en/latest/about.html)
