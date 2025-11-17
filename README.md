
Spark Cluster VCN creation scripts.
Using OCI Cli commands.
Host : OCI Console Code Editor.
Region : AP-SINGAPORE-2 -- Singapore West (Singapore)
Availability Domain : AP-SINGAPORE-2-AD-1 -- AD1

VCN CIDR : 10.1.0.0/24

Gateways: Internet Gateway (IG), NAT Gateway (NG), Service Gateway (SG)

Total Subnets : 2

Public Subnets CIDR : 10.1.0.0/25  --- spark-master
Public Subnet Route Table  --- spark-master-rt
Public Subnet Security List  --- spark-master-sl

Private Subnet CIDR : 10.1.0.128/25  --- Spark Workers
Private Subnet Route Table  --- spark-worker-rt
Private Subnet Security List  --- spark-worker-sl

Compute Instances
sm0ci  --- Public Subnet  --- VM.Standard.E5.Flex --- Latest Oracle Autonomous Linux, 4 OCPUs, 64 GBs
sw0ci  --- Private Subnet  --- VM.Standard.E5.Flex --- Latest Oracle Autonomous Linux, 4 OCPUs, 64 GBs
