FROM ubuntu:14.04

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# Install essential packages
RUN apt-get update && apt-get install -y \
	build-essential \
	curl \
	maven \
	openssh-server \
	software-properties-common \
	vim \
	wget \
	htop tree zsh fish \
	python-pip groff-base

# Install AWS CLI
RUN pip install awscli

# Install Java 8
# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN add-apt-repository -y ppa:webupd8team/java \
	&& apt-get update -y \
	&& echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
	&& apt-get install -y oracle-java8-installer \
	&& update-java-alternatives -s java-8-oracle \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/oracle-jdk8-installer

# RUN groupadd tomcat
# RUN useradd -s /bin/false -g tomcat -d /usr/local/tomcat tomcat

RUN cd /tmp && wget http://apache.mirror.anlx.net/tomcat/tomcat-8/v8.5.11/bin/apache-tomcat-8.5.11.tar.gz
RUN tar xzvf /tmp/apache-tomcat-8*.tar.gz -C /usr/local/tomcat --strip-components=1

# RUN cd /usr/local/tomcat && chgrp -R tomcat conf && chmod g+rwx conf && chmod g+r conf/* && chown -R tomcat work/ temp/ logs/

COPY app /opt/elucidate

RUN cd /opt/elucidate/elucidate-parent && mvn clean package install -U \
	&& cd ../elucidate-common-lib && mvn clean package install -U \
	&& cd ../elucidate-converter && mvn clean package install -U \
	&& cd ../elucidate-server && mvn clean package install -U \
	&& cp /opt/elucidate/elucidate-server/target/annotation.war /usr/local/tomcat/webapps

COPY run_elucidate.sh /opt/elucidate

EXPOSE 8080
