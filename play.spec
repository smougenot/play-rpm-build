# Change Play version as needed
%if %{?PLAY_VERSION:1}%{!?PLAY_VERSION:0}
%define my_play_version    %{PLAY_VERSION}
%else
%define my_play_version    1.2.4
%endif

Name:           play
Version:        %{my_play_version}
Release:        1%{?dist}
Summary:        Play Framework
Group:          System Environment/Daemons
License:        Apache License, Version 2
URL:            http://www.playframework.org/
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}

%define _sysconffile      %{_sysconfdir}/sysconfig/%{name}
%define myappdir          /opt/%{name}
%define myappusername     play
%define myappgroupname    play

Source0:        http://download.playframework.org/releases/%{name}-%{version}.zip
Source1:        play-sysconfig

BuildRequires:  unzip
Requires:       java >= 1.6, java-devel >= 1.6
Requires:       python%{?el5:26} >= 2.6
Requires(pre):  %{_sbindir}/groupadd
Requires(pre):  %{_sbindir}/useradd
Requires(post): %{_sbindir}/userdel
Requires(post): %{_sbindir}/groupdel


%description
The Play framework is a clean alternative to bloated Enterprise Java stacks.
It focuses on developer productivity and targets RESTful architectures.

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT/

mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/sysconfig
mkdir -p $RPM_BUILD_ROOT%{myappdir}

# Ignore Wintel related content.
cp -R framework modules resources play $RPM_BUILD_ROOT/%{myappdir}/

# sysconfig
cp  %{SOURCE1}  $RPM_BUILD_ROOT%{_sysconffile}
sed -i 's|@@SKEL_APP@@|%{name}|g' $RPM_BUILD_ROOT%{_sysconffile}
sed -i 's|@@SKEL_APPDIR@@|%{myappdir}|g' $RPM_BUILD_ROOT%{_sysconffile}

%clean
rm -rf $RPM_BUILD_ROOT

%pre
# First install time, add user and group
if [ "$1" == "1" ]; then
  echo "Creating group %{myappgroupname} if not already done"
  getent group %{myappgroupname} >/dev/null || \
    %{_sbindir}/groupadd -r %{myappgroupname} 2>/dev/null || :
 
  echo "Creating user %{myappusername} if not already done"
  getent passwd %{myappusername} >/dev/null || \
  %{_sbindir}/useradd -s /sbin/nologin -c "%{name} user" -g %{myappgroupname} -r -d %{myappdir} %{myappusername} 2>/dev/null || :
fi

%postun
# enlever le user
%{_sbindir}/userdel %{myappusername} 2>/dev/null || :
# enlever le grope
%{_sbindir}/groupdel %{myappgroupname} 2>/dev/null || :


%files
%defattr(-,%{myappusername},%{myappgroupname},-)
%attr(0644,root,root) %{_sysconffile}

%dir 
%attr(0755,%{myappusername},%{myappgroupname}) %{myappdir}

%doc COPYING
%doc README.textile
#%doc documentation/
#%doc samples-and-tests/
#%doc support/


%changelog
* Fri Mar 9 2012 Sylvain Mougenot <sylvain.mougenot@gmail.com>
- scritp the build,
- parameter for the play version
* Mon Nov 21 2011 Dan Carley <dan.carley@gmail.com> 1.2.3-1
- Initial package.