#!/bin/bash

# 设置脚本在遇到错误时立即退出，确保不会执行后续命令
set -e
# 
set -v

# 显示执行的命令
set -x


# 安装依赖包，包括 epel-release 并启用
yum -y install epel-release
yum-config-manager --enable epel
yum -y install \
    curl \
    which \
    make \
    gcc \
    perl \
    rpm-build \
    perl-IPC-Cmd
yum -y install perl-WWW-Curl
yum -y remove openssl


# 创建并进入 openssl 目录
mkdir ~/openssl && cd ~/openssl

# 安全性优化：定义一个安全的URL，避免中间人攻击
OPENSSL_URL="https://www.openssl.org/source/openssl-"

# 获取最新版本号并构造下载链接
latest_version=$(curl -s "${OPENSSL_URL}" | grep -Po '(?<=<a href="openssl-)[^"]*(?=.tar.gz")')
OPENSSL_TARBALL="openssl-${latest_version}.tar.gz"
OPENSSL_URL="${OPENSSL_URL}${OPENSSL_TARBALL}"

# 检查并下载openssl源码包
if [ -f "${OPENSSL_TARBALL}" ]; then
    echo "Checking the integrity of the existing file ${OPENSSL_TARBALL}"
    if ! tar -tzf "${OPENSSL_TARBALL}" &> /dev/null; then
        echo "Existing file ${OPENSSL_TARBALL} is corrupted. Removing it and downloading again."
        rm -f "${OPENSSL_TARBALL}"
    else
        echo "Existing file ${OPENSSL_TARBALL} is valid."
    fi
fi
# 如果源代码包不存在，则从网上下载
if [ ! -f "${OPENSSL_TARBALL}" ]; then
    # 安全性优化：取消跳过证书检查
    wget "${OPENSSL_URL}"
fi

# 创建 SPEC 文件
cat << 'EOF' > ~/openssl/openssl3.spec
Summary: OpenSSL 3.3.1 for CentOS
Name: openssl
Version: %{?version}%{!?version:3.3.1}
Release: 1%{?dist}
Obsoletes: %{name} <= %{version}
Provides: %{name} = %{version}
URL: https://www.openssl.org/
License: GPLv2+

Source: https://www.openssl.org/source/%{name}-%{version}.tar.gz

BuildRequires: make gcc perl perl-WWW-Curl
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
%global openssldir /usr/openssl

%description
https://github.com/philyuchkoff/openssl-RPM-Builder
OpenSSL RPM for version 3.3.1 on CentOS

%package devel
Summary: Development files for programs which will use the openssl library
Group: Development/Libraries
Requires: %{name} = %{version}-%{release}

%description devel
OpenSSL RPM for version 3.3.1 on CentOS (development package)

%prep
%setup -q

%build
./config --prefix=%{openssldir} --openssldir=%{openssldir}
make

%install
[ "%{buildroot}" != "/" ] && %{__rm} -rf %{buildroot}
%make_install

echo "BuildRoot: %{buildroot}"

mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libdir}
ln -sf %{openssldir}/lib64/libssl.so.3 %{buildroot}%{_libdir}
ln -sf %{openssldir}/lib64/libcrypto.so.3 %{buildroot}%{_libdir}
ln -sf %{openssldir}/bin/openssl %{buildroot}%{_bindir}

%clean
[ "%{buildroot}" != "/" ] && %{__rm} -rf %{buildroot}

%files
%{openssldir}
%defattr(-,root,root)
/usr/bin/openssl
/usr/lib64/libcrypto.so.3
/usr/lib64/libssl.so.3

%files devel
%{openssldir}/include/*
%defattr(-,root,root)

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig
EOF

# 创建必要的目录
mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp ~/openssl/openssl3.spec /root/rpmbuild/SPECS/openssl.spec

# 移动下载的 tarball 到 SOURCES 目录
mv ${OPENSSL_TARBALL} /root/rpmbuild/SOURCES

# 构建 RPM 包
cd /root/rpmbuild/SPECS && \
    rpmbuild \
    -D "version 3.3.1" \
    -ba openssl.spec
