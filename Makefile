DOCKER_REVISION ?= snmp_exporter-$(USER)
DOCKER_TAG = docker-push.ocf.berkeley.edu/snmp_exporter:$(DOCKER_REVISION)

SNMP_EX_VERSION := v0.13.0

.PHONY: dev
dev: gen-config cook-image
	@echo "Will be accessible at http://$(shell hostname -f ):9116/"
	docker run --rm -p 9116:9116 "$(DOCKER_TAG)"

gen-config: generator.yml vendor-snmp-exporter
	docker run -ti \
		-v $(PWD)/vendor-snmp-exporter/generator/mibs:/root/.snmp/mibs:ro \
		-v $(PWD)/:/opt/ \
		snmp-generator generate

vendor-snmp-exporter:
	git clone -q https://github.com/prometheus/snmp_exporter vendor-snmp-exporter
	cd vendor-snmp-exporter/generator && make mibs
	cd vendor-snmp-exporter/generator && docker build -t snmp-generator .

.PHONY: clean
clean:
	rm -rf vendor-snmp-exporter

.PHONY: cook-image
cook-image:
	docker build --build-arg snmp_exporter_version=$(SNMP_EX_VERSION) --pull -t $(DOCKER_TAG) .

.PHONY: push-image
	docker push $(DOCKER_TAG)
