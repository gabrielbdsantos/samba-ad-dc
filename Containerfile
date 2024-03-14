FROM ubuntu:latest

# Create a shared volume for regular backups
VOLUME /backup

RUN apt-get update && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  acl attr samba samba-dsdb-modules samba-vfs-modules smbclient winbind \
  libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils \
  net-tools chrony tzdata

RUN rm /etc/samba/smb.conf /etc/krb5.conf

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
