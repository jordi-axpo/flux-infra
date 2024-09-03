### Build

As I am using minikube, to load the image to the cluster we need to reuse the Docker daemon from Minikube: 

```
eval $(minikube docker-env)
```
And then we can build the image:
```
docker build -t hello-version-flask:0.0.1 .
```
And then it's important to set the `imagePullPolicy` to `Never` in the deployment file, otherwise Kubernetes will try to download the image.

If everything is set up correctly, you can access the app with:
```
kubectl port-forward svc/flask 8888:80
```
