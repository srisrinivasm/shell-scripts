sudo groupadd tomcat
sudo useradd -g tomcat -d /opt/tomcat tomcat
cd /tmp
curl -O https://downloads.apache.org/tomcat/tomcat-9/v9.0.35/bin/apache-tomcat-9.0.35.tar.gz
sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-*tar.gz -C /opt/tomcat --strip-components=1
sudo chgrp -R tomcat /opt/tomcat/
cd /opt/tomcat
sudo chmod -R g+r /opt/tomcat/conf/
sudo chmod g+x /opt/tomcat/conf/
sudo chown -R tomcat webapps/ work/ temp/ logs/

sudo JAVA_HOME=`update-java-alternatives -l |head 1 |awk '{print $3}'`

# Copy tomcat.service file from cloned GIT reposiotry of shell scripts
sudo cp /tmp/shell-scripts /etc/systemd/system/tomcat.service
sudo sed -i "s|Environment=JAVA_HOME=|Environment=JAVA_HOME=${JAVA_HOME}|g" /etc/systemd/system/tomcat.service

sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl status tomcat

# Add roles and create user to Tomcat configuration - by adding following lines to /opt/tomcat/conf/tomcat-users.xml
# <role rolename="manager-script"/>
# <user username="deployer" password="deployer" roles="manager-script"/>
sudo sed -i '/\/tomcat-users*/i \<role rolename\=\"manager-script\"\/\>\n\<user username\=\"deployer\" password\=\"deployer\" roles\=\"manager-script\"\/\>' /opt/tomcat/conf/tomcat-users.xml

# To remove restriction of accessing Manager app type from remote server
sudo sed -i '/\<Valve/i \<\!\-\-' /opt/tomcat/webapps/manager/META-INF/context.xml
sudo sed -i '/\<Manager/i \-\-\>' /opt/tomcat/webapps/manager/META-INF/context.xml

# To remove restriction of accessing Host Manager app type from remote server
sudo sed -i '/\<Valve/i \<\!\-\-' /opt/tomcat/webapps/host-manager/META-INF/context.xml
sudo sed -i '/\<Manager/i \-\-\>' /opt/tomcat/webapps/host-manager/META-INF/context.xml

sudo systemctl restart tomcat
