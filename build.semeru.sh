podman build -f Dockerfile.quarkus.semeru.base --cap-add=ALL --secret id=criu_secrets,src=.env -t restcrud-semeru-base .
podman build -f Dockerfile.quarkus.semeru --cap-add=ALL --security-opt seccomp=unconfined --net=host --cpuset-cpus 2 -m 1g -t restcrud-semeru-1cpu --no-cache .
podman build -f Dockerfile.quarkus.semeru --cap-add=ALL --security-opt seccomp=unconfined --net=host --cpuset-cpus 2-3 -m 1g -t restcrud-semeru-2cpu --no-cache .
podman build -f Dockerfile.quarkus.semeru --cap-add=ALL --security-opt seccomp=unconfined --net=host --cpuset-cpus 2-5 -m 1g -t restcrud-semeru-4cpu --no-cache .
