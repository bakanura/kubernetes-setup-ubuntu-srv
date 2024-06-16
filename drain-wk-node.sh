# kubectl drain does not work because the node will most likely contain sets.
# The following force-command must therefore be added.

kubectl drain mynodenamehere --ignore-daemonsets --delete-local-data

# Then kubectl get nodes "SchedulingDisabled" means everything worked.
# Now kubectl delete node "mynodenamehere"
kubectl delete node ckawn01
