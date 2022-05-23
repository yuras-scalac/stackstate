# Stackstate tech task

## Used tools

```
minikube version: v1.25.2
Kubernetesa v1.23.4-rc.0 
Docker 20.10.12
Terraform v1.1.8
Helm v3.5.0
argocd CLI v2.3.3+07ac038.dirty
argocd v2.3.4+ac8b7df
```

## HOW TO

### Start minikube

```
minikube start --memory 8192 --cpus 4 --kubernetes-version=v1.23.4-rc.0 --driver=hyperkit
```

<img width="1142" alt="image" src="https://user-images.githubusercontent.com/76940088/169788960-5c72da2f-6117-4855-8618-94fe6d573707.png">

### Clone this repository

```
git clone https://github.com/yuras-scalac/stackstate.git
cd stackstate
```

### Terraform init and apply

```
terraform init
terraform apply
```

<img width="608" alt="image" src="https://user-images.githubusercontent.com/76940088/169790501-bd77afe8-3509-4ba8-b158-c634bc4c491c.png">

### Waiting for everything to go online

```
watch kubectl get pods -n sock-shop
```
<img width="913" alt="image" src="https://user-images.githubusercontent.com/76940088/169790840-ee2fd4b3-fcbb-4da7-8071-a5e72829a712.png">

### Check frontend

```
minikube service list | grep front | awk '{print $8}'
```

<img width="1217" alt="image" src="https://user-images.githubusercontent.com/76940088/169791563-db9f528c-26d6-4f7a-b2ed-d11f64db7e87.png">

### Confirm in browser 

<img width="1774" alt="image" src="https://user-images.githubusercontent.com/76940088/169791743-e683b510-60d7-4112-a957-dbddcc331b88.png">

### Deploy stress tests
```
kubectl apply -f sock-shop/deploy/kubernetes/manifests-loadtest/loadtest-dep.yaml
```
<img width="1227" alt="image" src="https://user-images.githubusercontent.com/76940088/169792130-04f613b3-dd16-4657-bcff-89e67fa0ffba.png">

### Check monitoring

```
kubectl -n monitoring port-forward svc/prometheus-grafana -n monitoring 3000:80
```

<img width="1920" alt="image" src="https://user-images.githubusercontent.com/76940088/169792429-37a4866b-0d08-42ba-95d6-7600179469cb.png">

### Check AgoCD deployment

```
kubectl port-forward --namespace argo svc/argo-argo-cd-server 8080:80
```

<img width="901" alt="image" src="https://user-images.githubusercontent.com/76940088/169792681-62ae5420-8606-4130-81b8-70d3ca6258ab.png">
