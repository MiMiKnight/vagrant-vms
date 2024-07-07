
# 参考教程
https://www.cnblogs.com/voipman/p/15378589.html
https://blog.csdn.net/alex_yangchuansheng/article/details/125734352
https://ai-feier.github.io/p/k8s-secret-%E4%B8%80%E6%96%87%E8%AF%A6%E8%A7%A3-%E5%85%A8%E9%9D%A2%E8%A6%86%E7%9B%96-secret-%E4%BD%BF%E7%94%A8%E5%9C%BA%E6%99%AF-%E5%85%A8%E5%AE%B6%E6%A1%B6/
https://blog.csdn.net/lwxvgdv/article/details/139505471
#########################################


# 创建namespace
backend-namespace.yaml
kubectl create -f backend-namespace.yaml

# 创建nginx deployment
nginx-deployment.yaml
kubectl create -f nginx-deployment.yaml

# 创建 nginx service
nginx-service.yaml
kubectl create -f nginx-service.yaml

# 创建nginx ingress
nginx-ingress.yaml
curl -k https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml -o nginx-ingress.yaml
kubectl create -f nginx-ingress.yaml

#########################################
spec.selector.matchLabels是必须字段，而它又必须和spec.template.metadata.lables的键值一致。

#########################################
# 获取命名空间
kubectl get namespaces
# 查询指定命名空间详情
kubectl describe namespace backend
# 创建 docker-registry secret
kubectl create secret docker-registry \
 --docker-server=https://harbor.devops.vm.mimiknight.cn \
 --docker-username=mmk \
 --docker-password=HNNUjsjx1
