FROM ubuntu:25.04

# Versions
ENV NODE_VERSION       "22"

# Storage locations
ENV MTA_BUILDER_HOME   "/opt/mta-builder"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# Labels
LABEL org.opencontainers.image.title         "SAP Business Technology Platform (SAP BTP) Tools optimized for GitLab Runner"
LABEL org.opencontainers.image.description   "The following software and tools are included: python3, cf, mbt, node"

RUN apt-get update -yq && \
# Install base packages
	apt-get install -yq \
		apt-utils \
		build-essential \
		ca-certificates \
		gettext-base \
		git \
		gnupg \
		lsb-release \
		python3-pip \
		tar \
		unzip \
		wget \
		zip && \
# Disable Python virtual environments warning
	# rm "/usr/lib/python3.12/EXTERNALLY-MANAGED" && \
# Create storage locations
	mkdir -p "$MTA_BUILDER_HOME" && \
# Install Node.js \
  wget -q -O - https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/nodesource.gpg && \
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION?}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
	apt-get update -yq && \
	apt-get install -yq nodejs && \
# Install Node.js packages (https://www.npmjs.com/package)
	npm install @ui5/cli -g && \
	npm install grunt-cli -g && \
	npm install gulp-cli -g && \
	npm install showdown -g && \
	npm install eslint -g && \
	npm install eslint-plugin-ui5 -g && \
	npm install eslint-config-ui5 -g && \
# Install Cloud Foundry CLI
  wget -q -O - "https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key" | gpg --dearmor -o /etc/apt/trusted.gpg.d/cloudfoundry.gpg && \
	echo "deb [signed-by=/etc/apt/trusted.gpg.d/cloudfoundry.gpg] https://packages.cloudfoundry.org/debian stable main" > /etc/apt/sources.list.d/cloudfoundry-cli.list && \
	apt-get update -yq && \
	apt-get install -yq cf8-cli && \
# ...so that "cf deploy" is available
	#cf install-plugin multiapps -f && \
# Install mbt / Currently there is a bug in binwrap, so we have to use this workaround ( https://github.com/avh4/binwrap/issues/21 ) 
	npm install mbt -g --ignore-scripts && \
	cd /usr/lib/node_modules/mbt/ && \
	chmod -R 777 . && \
	npm install && \
# Basic smoke test
	cf --version && \
	envsubst --version | head -1 && \
	# java --version && \
	lsb_release -a && \
	mbt --version && \
	# mkdocs --version && \
	# neo.sh version && \
	node --version && \
	npm --version && \
	python3 --version && \
	tar --version | head -1 && \
	uname -a && \
	unzip -v | head -1 && \
	wget --version | head -1 && \
	zip -v | head -2 && \
# Delete cache
	pip3 cache purge && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*