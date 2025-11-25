# Pre-req : oci cli setup required on code editor terminal.

OCI Cli scripts executed on Code Editor

Region : AP-Singapore-2

# VCN components: 
Gateways : Internet Gateway,Nat Gateway,Service Gateway

# Subnets : 
Public And Private

# Security List : 
Dedicated Security List for Public And Private Subnet

# Routing Table : 
Dedicated Route Table for Public And Private Subnet


# Compute :
One Spark Master in Public Subnet
One Spark Worker in Private Subnet

# Spark Release : 4.0.1
Package Type : Pre-built for Apache Hadoop 3.4 and later with Spark Connect Enabled

# Python Packages installed on Spark Master for pyspark : 
wheel pyspark[sql] pandas pyarrow grpcio protobuf grpcio-status

# Script : 
oci-cli-commands-to-provision-spark-cluster
