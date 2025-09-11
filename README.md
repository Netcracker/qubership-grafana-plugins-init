# Overview

[![Build](https://github.com/Netcracker/qubership-grafana-plugins-init/actions/workflows/build.yaml/badge.svg)](https://github.com/Netcracker/qubership-grafana-plugins-init/actions/workflows/build.yaml)
[![Check Links](https://github.com/Netcracker/qubership-grafana-plugins-init/actions/workflows/link-checker.yaml/badge.svg)](https://github.com/Netcracker/qubership-grafana-plugins-init/actions/workflows/link-checker.yaml)
[![Super-Linter](https://github.com/Netcracker/qubership-grafana-plugins-init/actions/workflows/super-linter.yaml/badge.svg)](https://github.com/Netcracker/qubership-grafana-plugins-init/actions/workflows/super-linter.yaml)

This init container is intended for grafana customization with predefined list of plugins.

All the plugins listed in plugins list file will be added to grafana while appropriate grafana pod start in Kubernetes.

These plugins are downloaded while this image build instead of init container runtime.

## Plugins list

* DataSources:
  * [ClickHouse](https://grafana.com/grafana/plugins/vertamedia-clickhouse-datasource)
  * [JSON](https://grafana.com/grafana/plugins/simpod-json-datasource)
  * [GraphQL Data Source](https://grafana.com/grafana/plugins/retrodaredevil-wildgraphql-datasource)
  * [Infinity](https://grafana.com/grafana/plugins/yesoreyeram-infinity-datasource)
  * [VictoriaMetrics](https://grafana.com/grafana/plugins/victoriametrics-metrics-datasource)
  * [VictoriaLogs](https://grafana.com/grafana/plugins/victoriametrics-logs-datasource)
* Applications:
  * [Grafana Logs Drilldown](https://grafana.com/grafana/plugins/grafana-lokiexplore-app)
  * [Grafana Traces Drilldown](https://grafana.com/grafana/plugins/grafana-exploretraces-app)
  * [Grafana Profiles Drilldown](https://grafana.com/grafana/plugins/grafana-pyroscope-app)
* Panels:
  * [Breadcrumb Panel](https://grafana.com/grafana/plugins/timomyl-breadcrumb-panel)
  * [D3 Gauge](https://grafana.com/grafana/plugins/briangann-gauge-panel)
  * [Diagram](https://grafana.com/grafana/plugins/jdbranham-diagram-panel)
  * [HTML graphics](https://grafana.com/grafana/plugins/gapit-htmlgraphics-panel)
  * [Polystat](https://grafana.com/grafana/plugins/grafana-polystat-panel)
  * [Service Dependency Graph](https://grafana.com/grafana/plugins/novatec-sdg-panel)
  * [Status Panel](https://grafana.com/grafana/plugins/vonage-status-panel)
  * [SVG](https://grafana.com/grafana/plugins/aceiot-svg-panel)

## How to it work

During build grafana-plugin-init container all plugins download from
[https://grafana.com/api/plugins](https://grafana.com/api/plugins)
(User interface available by link [https://grafana.com/grafana/plugins/](https://grafana.com/grafana/plugins/))
and add into Docker image.

When operator create or update Grafana deployment it create deployment with two containers:

* grafana-plugins-init - `initContainer` which run with volume `grafana-plugins` (mount to `/opt/plugins`) in which it
  copy all plugins
* grafana - `container` with Grafana which also has volume `grafana-plugins` (mount to `/var/lib/grafana/plugins`)

When pod `grafana-deployment` start with init container, it always run first and execute initialize actions.
So when `initContainer` start it copy all plugins from image to mounted volume `grafana-plugins`.

Next it complete it work and grafana container start also with volume `grafana-plugins`.

Structure of init image:

```bash
/
└── entrypoint.sh
└── etc
    └── grafana
        └── plugins
            ├── NeoCat-grafana-cal-heatmap-panel-d7d3579
            ├── Vonage-Grafana_Status_panel-ca77e0d
            ├── algenty-grafana-flowcharting-276ca4a
            ├── black-mirror-1-singlestat-math-0aca146
            ├── briangann-gauge-panel
            ├── ...
            └── vertamedia-clickhouse-datasource
```

## How to add plugin

There is file `plugins.list` which contains plugin name and plugin version specified via space separator.
Currently plugins can be download only from:

```bash
https://grafana.com/api/plugins
```

Format:

```bash
<plugin_name> <version>
```

For example for include plugin which store on artifactory by link:

```bash
https://grafana.com/api/plugins/briangann-gauge-panel/versions/2.0.1/download
```

need specify:

```bash
briangann-gauge-panel 2.0.1
```

## How to add plugin manually

In some cases it may be necessary add plugin which was downloaded manually from Grafana.com or from any other source.

For build this image locally with custom plugins need:

1. Edit `download_plugins.sh` and comment step for remove directory `/tmp/plugins`

    ```bash
    echo "=> Remove directories from pervious build..."

    rm -rf ${DESTINATION_PATH}
    mkdir -p ${DESTINATION_PATH}
    ```

2. Download and extract folder with plugin to `/tmp/plugins`. For example:

    ```bash
    /tmp
    └── /plugins
        └── /<manually-downloaded-plugin-1>
            └── <plugin-content>
        └── /<manually-downloaded-plugin-2>
            └── <plugin-content>
    ```

3. Run

    ```bash
    docker build .
    ```

During build script `docker build` download all plugins as ZIP files into `/tmp/downloads`.
Then it unarchive all plugins into `/tmp/plugins`.

And during build Docker image Docker will copy all files from `/tmp/plugins` to `/etc/grafana/plugins/`.
