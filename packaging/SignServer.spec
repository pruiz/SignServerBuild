Name:           signserver
Version:        %{version}
Release:        %{release}
URL:            https://www.signserver.org/
License:        LGPL v2.1
Group:          Productivity/Other
Autoreqprov:    on
Summary:        SignServer Digital Signature Server
Source:         %{name}-%{version}.%{release}.tar.gz
BuildRequires:	jpackage-utils, java-1.6.0-openjdk-devel
BuildRequires:	jbossas >= 5.1.0
BuildRequires:	ant >= 1.8.2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
#=============================================================================

%global			_prefix					/opt/%{name}

#%if 0%{?fedora_version} || 0%{?rhel_version}
## Allows overrides of __find_provides in fedora distros... (already set to zero on newer suse distros)
#%define _use_internal_dependency_generator 0
#%endif

#=============================================================================

%description
PrimeKey's SignServer version: %{full_version_string}

%package -n signserver-server
Group:          Productivity/Other
Requires:	redhat-lsb-core
Requires:	java-1.6.0-openjdk-devel
Requires:	jpackage-utils
Requires:	jbossas >= 5.1.0, jbossas < 5.2.0
Requires:	glassfish-javamail = 1.4.0
BuildArch:	noarch
Summary:	SignServer's server-side EAR files.

%description -n signserver-server
SignServer's server-side EAR files, version: %{full_version_string}

%package -n signserver-client
Group:          Productivity/Other
Requires:	java-1.6.0-openjdk-devel
Requires:	jpackage-utils
BuildArch:	noarch
Summary:	SignServer's client commandline tools

%description -n signserver-client
SignServer's client commandline tools, version: %{full_version_string}

%prep
%setup -n %{name}

%build

export JBOSS_HOME="/var/lib/jbossas"
export APPSRV_HOME=$JBOSS_HOME
export ANT_HOME=/usr/share/ant
export ANT_OPTS="-Xmx256m -XX:MaxPermSize=128m"
export SIGNSERVER_HOME=/opt/signserver
export SIGNSERVER_NODEID=srv.signserver.dev

#./bin/ant clean
./bin/ant build
#./bin/ant deploy
./bin/ant compose-ear

%install
[ "${RPM_BUILD_ROOT}" != "/" ]&& %{__rm} -rf ${RPM_BUILD_ROOT}
OUTDIR="${RPM_BUILD_ROOT}/opt/%{name}"

mkdir -p "${RPM_BUILD_ROOT}/etc/signserver"
mkdir -p "$OUTDIR"/{bin,conf}
cp bin/{client.sh,signclient,signserver,signserver-db,stresstest,randomtest}  "$OUTDIR/bin"
cp -a lib  "$OUTDIR/"
rm -f "$OUTDIR"/lib/SignServer-Module-*
rm -f "$OUTDIR"/lib/SignServer-ejb-*
rm -f "$OUTDIR"/lib/SignServer-Lib-*
rm -f "$OUTDIR"/lib/SignServer-war-*
rm -f "$OUTDIR"/lib/SignServer-Server.jar
install -C -D "conf/log4j.properties" "${OUTDIR}/conf/log4j.properties"
install -C -D "conf/signserver_cli.properties.samples" "${OUTDIR}/conf/signserver_cli.properties"
touch "${RPM_BUILD_ROOT}/etc/signserver/signserver.conf"

#=============================================================================

%clean
[ "${RPM_BUILD_ROOT}" != "/" ]&& %{__rm} -rf ${RPM_BUILD_ROOT}
#=============================================================================

%files -n signserver-server
%defattr(-,root,root)
%config(noreplace) %attr(440,-,-) /etc/signserver/signserver.conf
/opt/signserver/lib/signserver.ear
/opt/signserver/lib/signserver.war

%files -n signserver-client
%defattr(-,root,root)
%config(noreplace)  /opt/signserver/conf/log4j.properties
%config(noreplace)  /opt/signserver/conf/signserver_cli.properties
%dir %attr(-,root,root) /opt/signserver
/opt/signserver/*
%exclude /opt/signserver/lib/signserver.ear
%exclude /opt/signserver/lib/signserver.war

%changelog 
