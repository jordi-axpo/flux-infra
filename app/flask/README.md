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
---
Now let's make an update to the code:

1. In `app/flask/src/main.py`: change `VERSION` to 0.0.2

And let's simulate manually what an automated CI pipeline would do:

2. In `app/flask/deploy/deployment.yaml`: change `image: hello-version-flask:0.0.1` to 0.0.2
3. Build the image with the new tag:
```
docker build -t hello-version-flask:0.0.2 .
```
Make sure you were on the same terminal, or you will need to run again `eval $(minikube docker-env)`
4. Push the code to the repo

You can now port-forward again to see the changes. It may take some time, so you can force the reconciliation by running:
```
flux reconcile kustomization flux-system
```