DOCKER_REVISION ?= snmp_exporter-$(USER)
DOCKER_TAG = docker-push.ocf.berkeley.edu/snmp_exporter:$(DOCKER_REVISION)

SNMP_EX_VERSION := master

.PHONY: dev
dev: cook-image
	@echo "Will be accessible at http://$(shell hostname -f ):9116/"
	docker run --rm -p 9116:9116 "$(DOCKER_TAG)"

gen-config: generator.yml vendor-snmp-exporter
	cd vendor-snmp-exporter/generator && docker build -t snmp-generator .
	docker run -t \
		-v $(PWD)/vendor-snmp-exporter/generator/mibs:/mibs:ro \
		-v $(PWD)/:/opt/ \
		-e MIBDIRS=/mibs \
		snmp-generator generate

vendor-snmp-exporter:
	git clone -q https://github.com/prometheus/snmp_exporter vendor-snmp-exporter
	cd vendor-snmp-exporter/generator && \
		git checkout $(SNMP_EX_VERSION) && \
		make mibs

.PHONY: clean
clean:
	rm -rf vendor-snmp-exporter snmp.yml

.PHONY: cook-image
cook-image: gen-config
	docker build --build-arg snmp_exporter_version=$(SNMP_EX_VERSION) --pull -t $(DOCKER_TAG) .

.PHONY: push-image
push-image:
	docker push $(DOCKER_TAG)
