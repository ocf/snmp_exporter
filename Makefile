DOCKER_REVISION ?= snmp_exporter-$(USER)
DOCKER_TAG = docker-push.ocf.berkeley.edu/snmp_exporter:$(DOCKER_REVISION)

SNMP_EX_VERSION := v0.13.0

# Eventually this can probably be the same as SNMP_EX_VERSION, but we currently
# need features that are not in a release.
# This should be a git tag or commit ID to use for the snmp_exporter repo when
# using the generator utilities.
GENERATOR_REV := 3eb190d598b19f09a0a9f7e34d26989f1916c566

.PHONY: dev
dev: cook-image
	@echo "Will be accessible at http://$(shell hostname -f ):9116/"
	docker run --rm -p 9116:9116 "$(DOCKER_TAG)"

gen-config: generator.yml vendor-snmp-exporter
	cd vendor-snmp-exporter/generator && docker build -t snmp-generator .
	docker run -t \
		-v $(PWD)/vendor-snmp-exporter/generator/mibs:/root/.snmp/mibs:ro \
		-v $(PWD)/:/opt/ \
		snmp-generator generate

vendor-snmp-exporter:
	git clone -q https://github.com/prometheus/snmp_exporter vendor-snmp-exporter
	cd vendor-snmp-exporter/generator && \
		git checkout $(GENERATOR_REV) && \
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
