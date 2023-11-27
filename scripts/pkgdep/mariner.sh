#!/usr/bin/env bash

#  SPDX-License-Identifier: BSD-3-Clause
#  All rights reserved.

is_repo() { tdnf repolist --all | grep -q "^$1"; }

additional_dependencies() {
	# Additional dependencies for SPDK CLI
	tdnf install -y python3-pexpect
	# Additional dependencies for ISA-L used in compression
	tdnf install -y help2man
	# Additional dependencies for DPDK
	if ! [[ "$(uname -m)" = "aarch64" ]]; then
		tdnf install -y nasm
	fi
	tdnf install -y libnuma-devel
	# Additional dependencies for USDT
	tdnf install -y systemtap-sdt-devel
	if [[ $INSTALL_DEV_TOOLS == "true" ]]; then
		# Tools for developers
		devtool_pkgs=(git sg3_utils pciutils bash-completion ruby-devel)
		devtool_pkgs+=(gcovr python3-pycodestyle)
		tdnf install -y "${devtool_pkgs[@]}"
	fi
	if [[ $INSTALL_PMEM == "true" ]]; then
		# Additional dependencies for building pmem based backends
		tdnf install -y libpmemobj-devel || true
	fi
	if [[ $INSTALL_FUSE == "true" ]]; then
		# Additional dependencies for FUSE and NVMe-CUSE
		tdnf install -y fuse3-devel
	fi
	if [[ $INSTALL_RBD == "true" ]]; then
		# Additional dependencies for RBD bdev in NVMe over Fabrics
		tdnf install -y librados-devel librbd-devel
	fi
	if [[ $INSTALL_RDMA == "true" ]]; then
		# Additional dependencies for RDMA transport in NVMe over Fabrics
		tdnf install -y libibverbs librdmacm
	fi
	if [[ $INSTALL_DOCS == "true" ]]; then
		# Additional dependencies for building docs
		tdnf install -y mscgen || echo "Warning: couldn't install mscgen via tdnf. Please install mscgen manually."
		tdnf install -y doxygen graphviz
	fi
	if [[ $INSTALL_DAOS == "true" ]]; then
		echo "Unsupported. Skipping installation of DAOS bdev dependencies."
	fi
	# Additional dependencies for Avahi
	if [[ $INSTALL_AVAHI == "true" ]]; then
		# Additional dependencies for Avahi
		tdnf install -y avahi-devel
	fi
}

tdnf install -y ca-certificates build-essential
tdnf install -y CUnit-devel \
	clang \
	clang-devel \
	cmake \
	json-c-devel \
	libaio-devel \
	libcmocka-devel \
	libiscsi-devel \
	libuuid-devel \
	ncurses-devel \
	openssl-devel \
	procps-ng \
	python \
	python3-devel \
	python3-pip \
	tar \
	unzip \

if [[ ! -e /usr/bin/python ]]; then
	sudo ln -s /usr/bin/python3 /usr/bin/python
fi

# If running as root, print a warning
if [[ $EUID -eq 0 ]]; then
	echo "Warning: Running as root. You may want to install the pip packages as a normal user or in a venv."
fi
pip3 install meson
pip3 install ninja
pip3 install pyelftools
pip3 install ijson
pip3 install python-magic
pip3 install pyyaml
pip3 install grpcio grpcio-tools

additional_dependencies
