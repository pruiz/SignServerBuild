packages:
  unzip:
    fromrepo: base,updates
  java-1.6.0-openjdk:
    fromrepo: base,updates
  java-1.6.0-openjdk-devel:
    fromrepo: base,updates
  jbossas.noarch:
    fromrepo: jpackage-generic-free
  ant.noarch:
    fromrepo: jpackage-generic-free

mono:
  version: 4.0.1.43-2.1.nw.el6
  packages:
    - mono-devel
    - mono-web
    - mono-wcf
    - mono-mvc
    - mono-winforms
    - mono-winfx
    - mono-data
    - mono-data-sqlite
    - mono-extras
    - monodoc
