---
layout: page
title:  "Tutorial: Quick start"
date:   2021-01-18 21:37:00 -0600
categories: blog
---

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/kpireporter/kpireporter-examples/HEAD?filepath=tutorial-quickstart%2FTutorialQuickstart.ipynb)

## Install KPI Reporter

For this tutorial, we will only need a few plugins. You can install `kpireport[all]` to install all available plugins.


```bash
pip install kpireport kpireport-mysql kpireport-plot
```

<details>
  <summary>View output</summary>
  <pre>Requirement already satisfied: kpireport in /opt/conda/lib/python3.8/site-packages (0.0.1)
Requirement already satisfied: kpireport-mysql in /opt/conda/lib/python3.8/site-packages (0.0.2)
Requirement already satisfied: kpireport-plot in /opt/conda/lib/python3.8/site-packages (0.1.2)
Requirement already satisfied: pandas in /opt/conda/lib/python3.8/site-packages (from kpireport) (1.2.1)
Requirement already satisfied: stevedore in /opt/conda/lib/python3.8/site-packages (from kpireport) (3.3.0)
Requirement already satisfied: jinja2 in /opt/conda/lib/python3.8/site-packages (from kpireport) (2.11.2)
Requirement already satisfied: pyyaml in /opt/conda/lib/python3.8/site-packages (from kpireport) (5.4.1)
Requirement already satisfied: python-slugify in /opt/conda/lib/python3.8/site-packages (from kpireport) (4.0.1)
Requirement already satisfied: PyMySQL in /opt/conda/lib/python3.8/site-packages (from kpireport-mysql) (1.0.2)
Requirement already satisfied: matplotlib in /opt/conda/lib/python3.8/site-packages (from kpireport-plot) (3.3.3)
Requirement already satisfied: MarkupSafe>=0.23 in /opt/conda/lib/python3.8/site-packages (from jinja2->kpireport) (1.1.1)
Requirement already satisfied: python-dateutil>=2.1 in /opt/conda/lib/python3.8/site-packages (from matplotlib->kpireport-plot) (2.8.1)
Requirement already satisfied: cycler>=0.10 in /opt/conda/lib/python3.8/site-packages (from matplotlib->kpireport-plot) (0.10.0)
Requirement already satisfied: pillow>=6.2.0 in /opt/conda/lib/python3.8/site-packages (from matplotlib->kpireport-plot) (8.1.0)
Requirement already satisfied: pyparsing!=2.0.4,!=2.1.2,!=2.1.6,>=2.0.3 in /opt/conda/lib/python3.8/site-packages (from matplotlib->kpireport-plot) (2.4.7)
Requirement already satisfied: kiwisolver>=1.0.1 in /opt/conda/lib/python3.8/site-packages (from matplotlib->kpireport-plot) (1.3.1)
Requirement already satisfied: numpy>=1.15 in /opt/conda/lib/python3.8/site-packages (from matplotlib->kpireport-plot) (1.19.5)
Requirement already satisfied: six in /opt/conda/lib/python3.8/site-packages (from cycler>=0.10->matplotlib->kpireport-plot) (1.15.0)
Requirement already satisfied: pytz>=2017.3 in /opt/conda/lib/python3.8/site-packages (from pandas->kpireport) (2020.5)
Requirement already satisfied: text-unidecode>=1.3 in /opt/conda/lib/python3.8/site-packages (from python-slugify->kpireport) (1.3)
Requirement already satisfied: pbr!=2.1.0,>=2.0.0 in /opt/conda/lib/python3.8/site-packages (from stevedore->kpireport) (5.5.1)
</pre>
</details>

## Set up test database

For this tutorial, we'll be using a test database on a local MySQL server. The [initdb.sql](./initdb.sql) file has the test data; you can update this file and re-run this cell to re-seed the local database.


```bash
# Start the server in the background
[[ -f /tmp/mysql.pid ]] || (mysqld_safe &) && while [[ ! -f /tmp/mysql.pid ]]; do sleep 1; done
# Initialize the database and tables
mysql <initdb.sql && echo "Database initialized."
```

<details>
  <summary>View output</summary>
  <pre>2021-01-24T01:24:00.601626Z mysqld_safe Logging to '/tmp/mysql_error.log'.
2021-01-24T01:24:00.630732Z mysqld_safe Starting mysqld daemon with databases from /tmp/mysql
Database initialized.
</pre>
</details>

## Run your first report

The [`config.yaml`](./config.yaml) file contains our report configuration. We will start by defining a **datasource** for our MariaDB server and a **view** displaying the result of a query as a bar chart.


```bash
cat config.yaml
```

<details>
  <summary>View output</summary>
  <pre>---
title: Quickstart Tutorial

datasources:
    my_db:
        plugin: mysql
        args:
            host: localhost
            user: ${NB_USER}

views:
    num_users:
        plugin: plot
        args:
            datasource: my_db
            query: select * from tutorial.new_users
            kind: bar

outputs:
    html:
        plugin: static
</pre>
</details>

By default, the report will be rendered as HTML using the [Static](https://kpi-reporter.readthedocs.io/en/latest/plugins/static.html) plugin.


```bash
kpireport -c config.yaml
```

<details>
  <summary>View output</summary>
  <pre>INFO:kpireport.plugin:Loaded datasource plugins: ['mysql', 'jenkins', 'prometheus']
INFO:kpireport.plugin:Initialized datasource my_db
INFO:kpireport.plugin:Loaded view plugins: ['jenkins.build_summary', 'plot', 'single_stat', 'prometheus.alert_summary']
INFO:kpireport.plugin:Initialized view num_users
INFO:kpireport.plugin:Loaded output driver plugins: ['static', 'slack', 's3', 'scp', 'sendgrid', 'smtp']
INFO:kpireport.plugin:Initialized output driver html
INFO:kpireport.report:Sending report via output driver html
Generated report in 1439.04ms.
</pre>
</details>

## Adding a new view

We will now add a new view that shows the total number of users in the database, using the [Single stat](https://kpi-reporter.readthedocs.io/en/latest/plugins/plot.html#single-stat) plugin.



```bash
cat config-2.yaml
```

<details>
  <summary>View output</summary>
  <pre>---
title: Quickstart Tutorial

datasources:
    my_db:
        plugin: mysql
        args:
            host: localhost
            user: ${NB_USER}

views:
    num_users:
        cols: 4
        plugin: plot
        args:
            datasource: my_db
            query: select * from tutorial.new_users
            kind: bar
    total_users:
        title: Total new users
        cols: 2
        plugin: single_stat
        args:
            datasource: my_db
            query: select sum(num_new_users) from tutorial.new_users

outputs:
    html:
        plugin: static
</pre>
</details>


```bash
kpireport -c config-2.yaml
```

<details>
  <summary>View output</summary>
  <pre>INFO:kpireport.plugin:Loaded datasource plugins: ['mysql', 'jenkins', 'prometheus']
INFO:kpireport.plugin:Initialized datasource my_db
INFO:kpireport.plugin:Loaded view plugins: ['jenkins.build_summary', 'plot', 'single_stat', 'prometheus.alert_summary']
INFO:kpireport.plugin:Initialized view num_users
INFO:kpireport.plugin:Initialized view total_users
INFO:kpireport.plugin:Loaded output driver plugins: ['static', 'slack', 's3', 'scp', 'sendgrid', 'smtp']
INFO:kpireport.plugin:Initialized output driver html
INFO:kpireport.report:Sending report via output driver html
Generated report in 1346.79ms.
</pre>
</details>

Notice that we added a `title` to the single stat view to give more context as to what the number indicates. Additionally, the view was placed side-by-side with the first plot by adjusting the `columns` parameter for each view. By default every report uses a 6-column layout, but this [can be configured at the theme level](https://kpi-reporter.readthedocs.io/en/latest/api/report.html#kpireport.report.Theme.num_columns).

## Have fun!

This example has hopefully given you some ideas on how to get started creating your first report :)
If you are interested in not outputting HTML, but instead sending via email, refer to the plugin documentation for, e.g., the [SMTP](https://kpi-reporter.readthedocs.io/en/latest/plugins/smtp.html) or [SendGrid](https://kpi-reporter.readthedocs.io/en/stable/plugins/sendgrid.html) plugins.
