user 'root'

package 'openjdk-7-jdk'

group 'chef' do
  action :create
end

user 'chef' do
  manage_home false
  shell '/bin/nologin'
  group 'chef'
  home '/opt/tomcat'
end

directory '/opt/tomcat' do
  action :create
  recursive true
end

remote_file '/tmp/apache-tomcat-8.0.33.tar.gz' do
  source 'http://www-eu.apache.org/dist/tomcat/tomcat-8/v8.5.11/bin/apache-tomcat-8.5.11.tar.gz'
end

execute 'extract_tomcat' do
  command 'tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1'
  cwd '/tmp'
end

execute 'chgrp -R chef /opt/tomcat/conf'

directory '/opt/tomcat/conf' do
  group 'chef'
  mode '0474'
end

execute 'chmod g+r conf/*' do
  cwd '/opt/tomcat'
end

###
execute 'chgrp -R tomcat bin' do
  cwd '/opt/tomcat'
end

execute 'chmod g+rwx bin' do 
  cwd '/opt/tomcat'
end 

execute 'chmod g+r bin/*' do
  cwd '/opt/tomcat'
end
###

execute 'chown -R chef webapps/ work/ temp/ logs/ conf/' do
  cwd '/opt/tomcat'
end

template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
end

execute 'systemctl daemon-reload'

service 'tomcat' do
  action [:start, :enable]
end
