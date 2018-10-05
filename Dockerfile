ARG snmp_exporter_version=latest
FROM prom/snmp-exporter:${snmp_exporter_version}

COPY snmp.yml /etc/snmp_exporter
