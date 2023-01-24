#!/bin/bash
set -e

echo "hello from the boundary worker"

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - ;\
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" ;\
sudo apt-get update && sudo apt-get install boundary-worker-hcp -y

mkdir /home/ubuntu/boundary/

# Boundary worker config
cat > /home/ubuntu/boundary/pki-worker.hcl <<- EOF
disable_mlock = true

hcp_boundary_cluster_id = "${CLUSTER_ID}"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  public_addr = "${WORKER_PUBLIC_IP}"
  auth_storage_path = "/home/ubuntu/boundary/worker1"
  tags {
    type = ["worker", "dev"]
  }
}
EOF

# Boundary Systemd Unit File
cat > /etc/systemd/system/boundaryworker.service <<- EOF
[Unit]
Description=BoundaryWorker
After=syslog.target network.target

[Service]
ExecStart=/usr/local/bin/boundary-worker server -config="/home/ubuntu/boundary/pki-worker.hcl"
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start boundaryworker