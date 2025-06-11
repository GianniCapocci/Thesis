if [ ! -f "/home/vagrant/.ssh/id_rsa" ]; then
    ssh-keygen -t rsa -N "" -f /home/vagrant/.ssh/id_rsa
fi
cp /home/vagrant/.ssh/id_rsa.pub /vagrant/control.pub

cat <<SSHEOF > /home/vagrant/.ssh/config
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
SSHEOF

cat /vagrant/control.pub >> /home/vagrant/.ssh/authorized_keys
echo alias k=kubectl >> /home/vagrant/.bashrc
echo alias c=clear >> /home/vagrant/.bashrc

chown -R vagrant:vagrant /home/vagrant/.ssh/