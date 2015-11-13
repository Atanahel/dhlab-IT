#!/bin/bash
apt-get update
apt-get install debconf-utils -y -qq
cat <<EOF | debconf-set-selections
nslcd   nslcd/ldap-bindpw       password
nslcd   nslcd/ldap-sasl-mech    select
nslcd   nslcd/ldap-sasl-authcid string
nslcd   nslcd/ldap-sasl-authzid string
nslcd   nslcd/ldap-auth-type    select  none
libnss-ldapd    libnss-ldapd/clean_nsswitch     boolean false
libnss-ldapd:amd64      libnss-ldapd/clean_nsswitch     boolean false
nslcd   nslcd/ldap-reqcert      select
nslcd   nslcd/ldap-base string  o=epfl,c=ch
libnss-ldapd    libnss-ldapd/nsswitch   multiselect     group, passwd, shadow
libnss-ldapd:amd64      libnss-ldapd/nsswitch   multiselect     group, passwd, shadow
nslcd   nslcd/ldap-sasl-realm   string
nslcd   nslcd/ldap-sasl-krb5-ccname     string  /var/run/nslcd/nslcd.tkt
nslcd   nslcd/ldap-uris string  ldap://scoldap.epfl.ch
nslcd   nslcd/ldap-binddn       string
nslcd   nslcd/ldap-starttls     boolean false
nslcd   nslcd/ldap-sasl-secprops        string
EOF
apt-get -y install libpam-ldapd libnss-ldapd nss-updatedb libnss-db nscd nslcd ldap-utils -qq
apt-get -y install python-ldap -qq
apt-get -y install cifs-utils -qq
apt-get -y install sysv-rc-conf -qq
apt-get -y install python-pam -qq
apt-get -y install python-lockfile -qq
apt-get -y install subversion -qq
cd /tmp/
svn export https://github.com/dhlab-epfl/dhlab-IT/trunk/scripts/scripts-auto
cp -r /tmp/scripts-auto/* /
cd

sed -i 's|^BASE.*|BASE      o=epfl,c=ch|' /etc/ldap/ldap.conf
sed -i 's|^URI.*|URI       ldap://scoldap.epfl.ch|' /etc/ldap/ldap.conf

service nslcd restart
service nscd restart