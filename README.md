# OpenSSL 3.3.1:

## Build:

```bash
sudo yum -y groupinstall 'Development Tools'
git clone https://github.com/philyuchkoff/openssl-RPM-Builder
cd openssl-RPM-Builder
chmod +x install-openssl_3.sh 
sudo bash install-openssl_3.sh
 ```
 
 Builded RPM will be in

    /root/rpmbuild/RPMS/x86_64/
    
After `install-openssl_3.sh` will finish, you can install builded rpm:

```bash
sudo rpm -ivvh /root/rpmbuild/RPMS/x86_64/openssl-3.3.1-1.el7.x86_64.rpm --nodeps
 ```  
