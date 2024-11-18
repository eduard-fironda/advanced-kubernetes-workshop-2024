## Task 19

Install [Kyverno](https://kyverno.io/) from the [Helm chart](https://kyverno.io/docs/installation/methods/#install-kyverno-using-helm) in a new `kyverno` namespace, with the default values.

Let's create an `Audit` policy in the `default` namespace, which doesn't allow to use images with the `latest` tag, or without a tag at all (taken from [here](https://kyverno.io/policies/best-practices/disallow-latest-tag/disallow-latest-tag/):

```sh
kubectl apply -f manifests/policy/disallow-latest-tag-policy.yaml
```

Let's check what happens if we try to create a deployment using an image without a tag. It should work, as the policy is in audit mode, but we'll see the policy validation error in the events:

```sh
kubectl create deployment nginx --image nginx
# deployment.apps/nginx created
kubectl get events
# 6s          Warning   PolicyViolation     policy/disallow-latest-tag    Deployment default/nginx: [autogen-require-image-tag] fail; validation error: An image tag is required. rule autogen-require-image-tag failed at path /spec/template/spec/containers/0/image/
# 6s          Warning   PolicyViolation     policy/disallow-latest-tag    Pod default/nginx-77b4fdf86c-k9g8b: [require-image-tag] fail; validation error: An image tag is required. rule require-image-tag failed at path /spec/containers/0/image/
# [...]
```

Now let's delete the deployment, switch the policy to `Enforce` mode, and create the deployment again. This time we should get a policy validation error, and the deployment will not be created:

```sh
kubectl delete deployment nginx
# deployment.apps "nginx" deleted
kubectl patch --type merge policy disallow-latest-tag --patch '{"spec":{"validationFailureAction":"Enforce"}}'
# policy.kyverno.io/disallow-latest-tag patched
kubectl create deployment nginx --image nginx
# error: failed to create deployment: admission webhook "validate.kyverno.svc-fail" denied the request: 
#
# resource Deployment/default/nginx was blocked due to the following policies 
#
# disallow-latest-tag:
#   autogen-require-image-tag: 'validation error: An image tag is required. rule autogen-require-image-tag
#     failed at path /spec/template/spec/containers/0/image/'
kubectl get deployment nginx
# Error from server (NotFound): deployments.apps "nginx" not found
```

Delete the Kyverno policy, and do the same with the `ValidatingAdmissionPolicy` in `manifests/policy/validatingadmissionpolicy`.

## Task 20

Clone the `example-app`[https://github.com/lbogdan/example-app/] repository locally.

Deploy the Helm chart in the `helm` folder to a new `app-staging` namespace, with a release name of `example-app`. Set environment to `staging`.

Expose it through ingress (with or without TLS). Check that you can access `/hash/test`, `/counter/1` and `/counter/1/inc` endpoints.

Restart (delete) the pod. Check what happens to the `/counter/1/inc` requests.

Scale the app to two replicas. Check what happens to the `/counter/1/inc` requests.

## Task 21

Enable PostgreSQL by setting `config.dbType` and `postgresql.enabled`. Check what happens to the `/counter/1/inc` requests.

## Task 22

Check if you can connect to the database from a different pod.

Enable network policy.

Check that the `/counter/1/inc` endpoint still works.

Check again if you can connect to the database from a different pod.

## Task 23

Experiment with the readiness probe by setting the `ASYNC_QUEUE` environment variable to `0` and increase `config.rounds` to 20.

## Task 24

Experiment with [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

```sh
# validate
kubectl label --dry-run=server --overwrite ns app-staging pod-security.kubernetes.io/enforce=restricted
# Warning: existing pods in namespace "app-staging" violate the new PodSecurity enforce level "restricted:latest"
# Warning: example-app-f5b96b955-p8mj6: allowPrivilegeEscalation != false, unrestricted capabilities, runAsNonRoot != true, seccompProfile
# namespace/app-staging labeled (server dry run)
#
# apply
kubectl label --overwrite ns app-staging pod-security.kubernetes.io/enforce=restricted
# [...]
# namespace/app-staging labeled
```

Delete the pod. What happens? Why?

Enable security in `example-app` values and redeploy. What happens? Why?

Use the image tag `v0.0.25`.

## Task 25

Experiment with the [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).

## Task 26

Disable PostgreSQL, create a CloudNativePG cluster and configure it in `example-app` values `externalPostgresql`.

## Task 27

Update the Helm chart to support providing sealed secrets instead of secrets.

## Task 28

Deploy `example-app` in a new `app-dev` namespace and experiment with [Okteto](https://www.okteto.com/). Make a change, commit, add a release tag, push. Deploy it to staging after the image is built and pushed.

## Task 29

Add the staging app, and create a new production app, in ArgoCD.
