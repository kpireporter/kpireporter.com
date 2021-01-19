---
layout: page
title:  "Tutorial: Quick start"
date:   2021-01-18 21:37:00 -0600
categories: blog
---

## Get the Docker image

For this tutorial, we will use the Docker image published to the public Docker Hub.


```bash
docker pull kpireporter/kpireporter:edge
```

    edge: Pulling from kpireporter/kpireporter
    Digest: sha256:84190806a8915e8de87d688da17af56fd8b1cae193dddbe27996d975721e94f3
    Status: Image is up to date for kpireporter/kpireporter:edge
    docker.io/kpireporter/kpireporter:edge



## Set up test database

For this tutorial, we will use a temporary MySQL database running in a Docker container. It will be initialized with one table `tutorial.new_users`, which we will use to render visualizations from.

In order to have our KPI Reporter container "see" the database over Docker networking, we have to create our own Docker network instead of utilizing the default `bridge` network.


```bash
docker network inspect tutorial_net 2>&1 >/dev/null || docker network create tutorial_net
```


Start a MariaDB container and pass some environment variables ([as documented on Docker Hub](https://hub.docker.com/_/mariadb)) to initialize a database and a default user, which we will use when authenticating. Note the name of the container is **tutorial_mysql**--we will configure this as the DB host in the report configuration.


```bash
docker stop tutorial_mysql 2>/dev/null && echo "Cleaned up old DB container"
docker run --rm -d --net=tutorial_net \
  --env MYSQL_RANDOM_ROOT_PASSWORD=1 \
  --env MYSQL_USER=kpireporter --env MYSQL_PASSWORD=kpireporter --env MYSQL_DATABASE=tutorial \
  -v $(realpath initdb.sql):/docker-entrypoint-initdb.d/initdb.sql \
  --name=tutorial_mysql mariadb:latest
```

    tutorial_mysql
    Cleaned up old DB container
    b93b0a566ede06d2cdc5603d2852a05b871962cceb4491452919be9dc71bf243



> **Note**: you may need to wait a few (~30) seconds for the database to fully initialize before proceeding to the next step.

## Run your first report

The [`config.yaml`](./config.yaml) file contains our report configuration. We will start by defining a **datasource** for our MariaDB server and a **view** displaying the result of a query as a bar chart.


```bash
cat config.yaml
```

    ---
    title: Quickstart Tutorial

    datasources:
        my_db:
            plugin: mysql
            args:
                host: tutorial_mysql
                user: ${DATABASE_USER}
                password: ${DATABASE_PASSWORD}

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
            args:
                output_dir: /out



By default, the report will be rendered as HTML using the [Static](https://kpi-reporter.readthedocs.io/en/latest/plugins/static.html) plugin.


```bash
rm -rf out && mkdir -p out
docker run --rm --net=tutorial_net \
  -v $(realpath config.yaml):/etc/kpireporter/config.yaml -v $(realpath out):/out \
  --env DATABASE_USER=kpireporter --env DATABASE_PASSWORD=kpireporter \
  kpireporter/kpireporter:edge
```

    INFO:kpireport.plugin:Initialized datasource my_db
    INFO:matplotlib.font_manager:Generating new fontManager, this may take some time...
    INFO:kpireport.plugin:Loaded view plugins: ['jenkins.build_summary', 'plot', 'single_stat', 'prometheus.alert_summary', 'table']
    INFO:kpireport.plugin:Initialized view num_users
    WARNING:kpireport.plugin:Could not load plugin 'scp': No module named 'kpireport_scp.SCPOutputDriver'
    INFO:kpireport.plugin:Loaded output driver plugins: ['static', 's3', 'sendgrid', 'smtp', 'slack']
    INFO:kpireport.plugin:Initialized output driver html
    INFO:kpireport.report:Sending report via output driver html
    Generated report in 1645.40ms.



## Examine output

**[View output HTML](./out/latest-quickstart-tutorial/index.html)**

## Adding a new view

We will now add a new view that shows the total number of users in the database, using the [Single stat](https://kpi-reporter.readthedocs.io/en/latest/plugins/plot.html#single-stat) plugin.



```bash
cat config-2.yaml
```

    ---
    title: Quickstart Tutorial

    datasources:
        my_db:
            plugin: mysql
            args:
                host: tutorial_mysql
                user: ${DATABASE_USER}
                password: ${DATABASE_PASSWORD}

    views:
        num_users:
            cols: 3
            plugin: plot
            args:
                datasource: my_db
                query: select * from tutorial.new_users
                kind: bar
        total_users:
            cols: 3
            plugin: single_stat
            args:
                datasource: my_db
                query: select sum(num_users) from tutorial.new_users

    outputs:
        html:
            plugin: static
            args:
                output_dir: /out




```bash
rm -rf out && mkdir -p out
# Note we now pass "config-2.yaml" as the bind mount source.
docker run --rm --net=tutorial_net \
  -v $(realpath config-2.yaml):/etc/kpireporter/config.yaml -v $(realpath out):/out \
  --env DATABASE_USER=kpireporter --env DATABASE_PASSWORD=kpireporter \
  kpireporter/kpireporter:edge
```

    INFO:kpireport.plugin:Loaded datasource plugins: ['jenkins', 'prometheus', 'mysql', 'googleanalytics']
    INFO:kpireport.plugin:Initialized datasource my_db
    INFO:matplotlib.font_manager:Generating new fontManager, this may take some time...
    INFO:kpireport.plugin:Loaded view plugins: ['jenkins.build_summary', 'plot', 'single_stat', 'prometheus.alert_summary', 'table']
    INFO:kpireport.plugin:Initialized view num_users
    INFO:kpireport.plugin:Initialized view total_users
    WARNING:kpireport.plugin:Could not load plugin 'scp': No module named 'kpireport_scp.SCPOutputDriver'
    INFO:kpireport.plugin:Loaded output driver plugins: ['static', 's3', 'sendgrid', 'smtp', 'slack']
    INFO:kpireport.plugin:Initialized output driver html
    INFO:kpireport.report:Sending report via output driver html
    Generated report in 1728.26ms.
    [?2004h



**[View output HTML](./out/latest-quickstart-tutorial/index.html)**

Notice that we added a `title` to the single stat view to give more context as to what the number indicates. Additionally, the view was placed side-by-side with the first plot by adjusting the `columns` parameter for each view. By default every report uses a 6-column layout, but this [can be configured at the theme level](https://kpi-reporter.readthedocs.io/en/latest/api/report.html#kpireport.report.Theme.num_columns).

## Have fun!

This example has hopefully given you some ideas on how to get started creating your first report :)
If you are interested in not outputting HTML, but instead sending via email, refer to the plugin documentation for, e.g., the [SMTP](https://kpi-reporter.readthedocs.io/en/latest/plugins/smtp.html) or [SendGrid](https://kpi-reporter.readthedocs.io/en/stable/plugins/sendgrid.html) plugins.


```bash

```
