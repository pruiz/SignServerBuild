packages:
  unzip:
    fromrepo: base,updates
  git:
    fromrepo: base,updates
  rpm-build:
    fromrepo: base,updates
  java-1.6.0-openjdk:
    fromrepo: base,updates
  java-1.6.0-openjdk-devel:
    fromrepo: base,updates
  jbossas.noarch:
    fromrepo: jpackage-generic-free
    requires:
      - pkgrepo: pkgrepo-jpackage-generic-free
