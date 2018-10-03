snmp-exporter
=============

This repo controls the Docker image for the OCF SNMP exporter.

Configuration happens in `generator.yml`. To generate the "real" `snmp.yml` config file, run `make gen-config`.

See the [`snmp_exporter` generator docs](https://github.com/prometheus/snmp_exporter/tree/master/generator) for more info on how config generation works.
