#!/bin/sh

echo "Start grafana-plugins-init container..."

echo "Available plugins:"
ls -lah /etc/grafana/plugins

echo "Copy plugins from /etc/grafana/plugins to /opt/plugins (which should be mounted as a volume)..."
cp -r /etc/grafana/plugins /opt/plugins

echo "Plugins are successfully copied"
