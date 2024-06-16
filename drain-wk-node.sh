# kubectl drain does not work because the node will most likely contain sets.
# The following force-command must therefore be added.

kubectl drain <node_name> --ignore-daemonsets --delete-local-data

# Then kubectl get nodes "SchedulingDisabled" means everything worked.
# Now kubectl delete node "<node_name>"
kubectl delete node <node_name>
