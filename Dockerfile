From centos:6

MAINTAINER shamaton

ARG version="5.6.27"

# update & install mysql
RUN yum -y update \
 && yum -y install http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm \
 && yum -y --enablerepo=mysql56-community install mysql-community-server-${version} \
 && yum clean all

# add conf
RUN rm -f /etc/my.cnf
COPY ./my.cnf /etc/my.cnf

# add script
COPY ./start.sh /root/start.sh
RUN chmod a+x /root/start.sh

# port open
EXPOSE 3306

# activate mysql
CMD ["/root/start.sh"]
