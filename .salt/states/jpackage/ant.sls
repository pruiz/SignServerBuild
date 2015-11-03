ant:
  pkg.installed:
    - fromrepo: jpackage-generic-free
    - requires:
      - pkgrepo: pkgrepo-jpackage-generic-free

ant-javamail:
  pkg.installed:
    - fromrepo: jpackage-generic-free
    - requires:
      - pkgrepo: pkgrepo-jpackage-generic-free

/usr/share/ant/lib/ant.jar:
  cmd.run:
    - name: /usr/bin/build-jar-repository -p . ant
    - cwd: /usr/share/ant/lib
    - creates: /usr/share/ant/lib/ant.jar
    - requires:
      - pkg: ant
      - pkg: jpackage-utils
