# Example build with mock:
# mock --buildsrpm -r epel-6-x86_64 --symlink-dereference --sources=/home/imriz/rpmbuild/SOURCES/mcollective-rsync-1.0.11.tar.gz --spec=/Volumes/mhdev/working-copies/IT/trunk/RPMBuilds/rpmbuild/SPECS/mcollective-distributor.spec --resultdir=/tmp/mock/"%(dist)s"/"%(target_arch)s"/
# mock --rebuild -r epel-6-x86_64  --resultdir=/tmp/mock/"%(dist)s"/"%(target_arch)s"/ /tmp/mock/el6/x86_64/mcollective-rsync-1.0.11-1.el6.src.rpm

%global _mco_libdir /usr/libexec/mcollective

%if "%{?scl}" == "ruby193"
    %global scl_prefix %{scl}-
    %global scl_ruby /usr/bin/ruby193-ruby
    %global scl_rake /usr/bin/ruby193-rake
    ### TODO temp disabled for SCL
    %global nodoc 1
%else
    %global scl_ruby /usr/bin/ruby
    %global scl_rake /usr/bin/rake
%endif


Name: mcollective-rsync
Version: %{?MH_VERSION:0.0.1}
Release: 1%{?dist}
Summary: Parallel rsync used in MyHeritage

License: MyHeritage
Source0: %{name}-%{version}.tar.gz
BuildArch:  noarch

%package agent
Summary: Mcollective agent for running parallel rsync
Group: MyHeritage/Dist/Agents
Requires: mcollective

%package application
Summary: Mcollective application for running parallel rsync
Group: MyHeritage/Dist/Applications
Requires: mcollective

%prep
%setup -n mcollective-rsync

%files agent
%{_mco_libdir}/mcollective/agent

%files application
%{_mco_libdir}/mcollective/application

%description agent
Mcollective agent package to get and deploy a tar package from a URL and refresh the APC cache

%description application
Mcollective application to call all the agents and summorize replies

%description
Mcollective packages to provide tools for emergency dist capabilities in MyHeritage

%install
%{__install} -d -m 755 %{buildroot}%{_mco_libdir}/mcollective
cp -rp %{_builddir}/mcollective-rsync/* %{buildroot}%{_mco_libdir}/mcollective
