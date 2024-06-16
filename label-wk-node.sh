# new release v0.0.8-dev display all roles including:
# 
The new release v0.0.8-dev shows all roles including: worker, master, and etcd, but a known limitation is that once the node is labeled,
# this label does not change until the node is deleted/read as a Kubernetes node.
# You can manually label the node using the command below.

kubectl label node <node_name> node-role.kubernetes.io/worker=worker"
![6dca20e1e903fdc0c841df598df804df.png](:/1396d5825fbc440c814709c8cc07a7d0)
