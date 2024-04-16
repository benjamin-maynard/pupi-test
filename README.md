# Privately Used Public IP's

Standalone Terraform configuration for testing out GKE when using PUPI ranges.

Configures Private GKE Cluster using either Service Networking or Private Service Connect (which Private Clusters will transition to when on 1.29+ https://cloud.google.com/kubernetes-engine/docs/concepts/network-overview#control-plane).

## Usage

Edit [terraform.tfvars](terraform.tfvars) and substitute variables as appropriate.

```
terraform init
terraform apply
```

## Terraform Files (Numbered for better understanding)

1. [001-networking.tf](001-networking.tf): Provisions a VPC, Subnet, Pod and Services ranges in the `30.0.0.0/8` range. Enables [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access) for the subnet.
2. [002-dns.tf](002-dns.tf): Configures DNS for Private Google Access.
3. [003-cluster.tf](003-cluster.tf): Creates the GKE Cluster, using either Service Networking or Private Service Access, depending on the value of `use_private_service_connect` in [variables.tf](variables.tf).
4. [004-asm.tf](004-asm.tf): Joins the Cluster to GKE Hub, enables Managed ASM.
5. [005-load-balancing.tf](005-load-balancing.tf): Reserves a IP on the subnet for testing ILB.
6. [006-vm.tf](006-vm.tf): Creates a VM on the subnet with an external IP address which can be SSH'd to connect to the private subnet resources.

## Testing

## Wait for ASM Managed to deploy
```
gcloud container hub features describe servicemesh
```

Wait for `controlPlaneManagement` and `dataPlaneManagement` to be `READY`.

## Deploy test manifests

1. [test-manifests/001-nginx-deployment-only.yaml](test-manifests/001-nginx-deployment-only.yaml): Nginx deployment for testing
2. [test-manifests/002-nginx-ilb.yaml](test-manifests/002-nginx-ilb.yaml): Exposes Nginx via an Internal Load Balancer (can test via Curl from the VM)
3. [test-manifests/003-nginx-container-native-lb.yaml](test-manifests/003-nginx-container-native-lb.yaml): Exposes nginx via an External Load Balancer using [Container Native Load Balancing](https://cloud.google.com/kubernetes-engine/docs/how-to/container-native-load-balancing)
4. [test-manifests/004-istio-ingress-gw-only.yaml](test-manifests/004-istio-ingress-gw-only.yaml): Creates and exposes an Istio Ingress Gateway via an External Load Balancer (TCP)
5. [test-manifests/005-nginx-ingressgw-exposure.yaml](test-manifests/005-nginx-ingressgw-exposure.yaml): Exposes the nginx deployment via the Ingress Gateway


