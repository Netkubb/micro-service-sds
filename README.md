# SDS Project

## How to setup kubernetes cluster

#### Set up master node ( VM )

```bash
# setting c_group
sudo nano /etc/default/grub

#add this then reboot
cgroup_enable=memory cgroup_memory=1

# get k3s
curl -sfL https://get.k3s.io/ | sh -

# start k3s service
sudo systemctl start k3s

# get k3s token
sudo cat /var/lib/rancher/k3s/server/node-token

# you will get token like this
#K107a7f84ab9b1fbfb4ecb22489baf3feef2ef61726df9fa7547959692af15d3d3d3d:server:356b040166c1005248c23bcd01f39d43
```

#### Set up worker nodes ( Pi )

```bash
# setting c_group
sudo nano /boot/cmdline.txt

#add this then reboot
cgroup_memory=1 cgroup_enable=memory

#join the worker node to cluster
curl -sfL https://get.k3s.io/ | K3S_URL=https://<server-ip>:6443/ K3S_TOKEN=<k3s-token> K3S_NODE_NAME=<hostname> sh -

#example
#curl -sfL https://get.k3s.io/ | K3S_URL=https://172.20.10.3:6443/ K3S_TOKEN=K107a7f84ab9b1fbfb4ecb22489baf3feef2ef61726df9fa7547959692af15d3d3d3d:server:356b040166c1005248c23bcd01f39d43 K3S_NODE_NAME=raspberrypi2 sh -

```

- edit k3s_token

```bash
#stop k3s-agent service
sudo systemctl stop k3s-agent

# add new K3S_TOKEN here
sudo nano /etc/systemd/system/k3s-agent.service.envs

# remove k3s-agent data
sudo rm -rf /var/lib/rancher/k3s/agent

sudo systemctl daemon-reload

# start k3s-agent service and join cluster
sudo systemctl start k3s-agent
```

- test k3s-agent on masternode

```bash
# on master node
kubectl get nodes
```

#### Monitoring On local machine

on master node ( vm )

```bash
# get k3s config
sudo cat /rancher/k3s/k3s.yaml

# then copy all content
```

on local machine

```bash
# go to kube config file
code ${home}/.kube/config
```

copy config from master to local machine

- add cluster, context, user

- change name of cluster, context, user to "pi"

- change cluster server ip from 127.0.0.1 to master ip

![alt text](/docs/image-1.png)

on .kube/config
![alt text](/docs/image-2.png)

on local machine

```bash
# see if there is pi cluster
kubectl config get-contexts

# now we switch to cluster pi
kubectl config get-context pi

# test if local machine can monitor cluter
kubectl get nodes

#if we see any agents its ok
```

## How to deploy application

#### Registries

on local machine

```bash
# run registry container
docker run -d -p 5000:5000 --name registry registry:2

# run script deployment
./deployment.sh
```

on master node

```bash
# get image from local machine's registry
sudo nano /etc/rancher/k3s/registries.yaml

# add this and change endpoint to local machine ip
mirrors:
  "localhost:5000":
    endpoint:
      - "http://<local-machine-ip>:5000"

#restart k3s service
sudo systemctl restart k3s

#check deployment
kubectl get pods

# if all pods is running then its ok
```
