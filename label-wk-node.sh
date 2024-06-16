# new release v0.0.8-dev display all roles including:
# 
The new release v0.0.8-dev shows all roles including: worker, master, and etcd, but a known limitation is that once the node is labeled,
# this label does not change until the node is deleted/read as a Kubernetes node.
# You can manually label the node using the command below.

kubectl label node <node_name> node-role.kubernetes.io/worker=worker"
