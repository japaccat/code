
Spark Cluster VCN creation scripts.

Using OCI Cli commands.

Host : OCI Console Code Editor.

Region : AP-SINGAPORE-2 -- Singapore West (Singapore)

Availability Domain : AP-SINGAPORE-2-AD-1 -- AD1

VCN : vcn-spark
----------------
# Return the json data for compartment tsupi
CID=$(oci iam compartment list --name tsupi --compartment-id-in-subtree true --query data[0].id --raw-output)

# VCN CIDR Block in json format.
VCB='["X.X.X.X/24"]'

# Create the VCN and Return the Id
VID=$(oci network vcn create --compartment-id $CID --cidr-blocks $VCB --display-name vcn-spark --dns-label vcnspark --query data.id --raw-output)

Gateways: Internet Gateway (IG), NAT Gateway (NG), Service Gateway (SG)
------------------------------------------------------------------------
# Create the Internet Gateway and Return the Id
IGI=$(oci network internet-gateway create  --compartment-id $CID --is-enabled TRUE --vcn-id $VID --display-name IG --query data.id --raw-output)

# Create the Nat Gateway and Return the Id
NGI=$(oci network nat-gateway create --compartment-id $CID --vcn-id $VID --display-name NG --query data.id --raw-output)

# List the available Oracle Services
SID=$(oci network service list --query data[1].id --raw-output)

# Format the Service Id to a valid Json 
SID='[{"serviceId":"'$SID'"}]'

# Create the Service Gateway and Return the Id
SGI=$(oci network service-gateway create --compartment-id $CID --services $SID --vcn-id $VID --display-name SG --query data.id --raw-output)

# Return the Internet Gateway Id 
#IGI=$(oci network internet-gateway list --compartment-id $CID --vcn-id $VID --display-name IG --query data[0].id --raw-output)

# Return the Nat Gateway Id
#NGI=$(oci network nat-gateway list --compartment-id $CID --vcn-id $VID --display-name NG --query data[0].id --raw-output)

# Return the Service Gateway Id
#SGI=$(oci network service-gateway list --compartment-id $CID --vcn-id $VID --query 'data[?"display-name"==`SG`].id|[0]' --raw-output)

Total Subnets : 2
------------------
Public Subnet
-------------
# Create Public Subnet and Return the Id
SSMI=$(oci network subnet create --cidr-block 'X.X.X.X/25' --compartment-id $CID --vcn-id $VID --display-name spark-master --dns-label sparkmaster --query data.id --raw-output)

Public Subnet Route Table
-------------------------
# Format the Route Rules for Spark Master to Json format
RRSM='[{"destination":"0.0.0.0/0","destination-type":"CIDR_BLOCK","network-entity-id":"'$IGI'","route-type":"STATIC"}]'

# Create Route Table For Spark Master Subnet and Return Id
RTSMI=$(oci network route-table create --compartment-id $CID --route-rules $RRSM --vcn-id $VID --display-name spark-master-rt --query data.id --raw-output)

# Update the Spark Master Public Subnet to use Spark Master Route Table 
oci network subnet update --subnet-id $SSMI --route-table-id $RTSMI --force

Public Subnet Security List
---------------------------
# Standard list of IP protocol numbers;
# TCP = 6
# UDP = 17
# ICMP = 1

# Format Spark Master Egress Rules 
SMESR='[{"destination":"0.0.0.0/0","destination-type":"CIDR_BLOCK","is-stateless":false,"protocol":"all","tcp-options":null,"udp-options":null}]'

# Format Spark Master Ingress Rules
SMISR='[{"is-stateless":false,"protocol":"6","source":"0.0.0.0/0","source-type":"CIDR_BLOCK","tcp-options":null,"udp-options":null},
      {"is-stateless":false,"protocol":"1","source":"0.0.0.0/0","source-type":"CIDR_BLOCK","tcp-options":null,"udp-options":null},
      {"is-stateless":false,"protocol":"17","source":"0.0.0.0/0","source-type":"CIDR_BLOCK","tcp-options":null,"udp-options":null}]'          

# Create Spark Master Security List and Return Id 
SMSLI=$(oci network security-list create --compartment-id $CID --egress-security-rules $SMESR --ingress-security-rules $SMISR --vcn-id $VID --display-name spark-master-sl --query data.id --raw-output)

# Return the Spark Master Security List Id
#SMSLI=oci network security-list list --compartment-id $CID --vcn-id $VID --display-name spark-master-sl --query data[0].id --raw-output

# Format Spark Master Security List Id to Json Format
SMSLI='["'$SMSLI'"]'

# Update the Spark Master Subnet to use the Spark Master Security List as Default
oci network subnet update --subnet-id $SSMI --security-list-ids $SMSLI --force

Private Subnet
--------------
# Create Private Subnet and Return the Id
SSWI=$(oci network subnet create --cidr-block 'X.X.X.X/25' --compartment-id $CID --vcn-id $VID --display-name spark-worker --dns-label sparkworker --prohibit-public-ip-on-vnic true --query data.id --raw-output)

Private Subnet Route Table
--------------------------
# Format Route Rules for Spark Worker to Json format
RRSW='[{"destination":"0.0.0.0/0","destination-type":"CIDR_BLOCK","network-entity-id":"'$NGI'","route-type":"STATIC"},
      {"destination":"all-xsp-services-in-oracle-services-network","destination-type":"SERVICE_CIDR_BLOCK","network-entity-id":"'$SGI'","route-type":"STATIC"}]'

# Create Route Table for Spark Worker Subnet and Return Id
RTSWI=$(oci network route-table create --compartment-id $CID --route-rules $RRSW --vcn-id $VID --display-name spark-worker-rt --query data.id --raw-output)

# Update the Spark Worker Private Subnet to use Spark Worker Route Table
oci network subnet update --subnet-id $SSWI --route-table-id $RTSWI --force

Private Subnet Security List
----------------------------
# Format Spark Worker Egress Rules
SWESR='[{"destination":"10.1.0.0/24","destination-type":"CIDR_BLOCK","is-stateless":false,"protocol":"all","tcp-options":null,"udp-options":null}]'

# Format Spark Worker Ingress Rules 
SWISR='[{"is-stateless":false,"protocol":"6","source":"10.1.0.0/24","source-type":"CIDR_BLOCK","tcp-options":null,"udp-options":null},
      {"is-stateless":false,"protocol":"1","source":"10.1.0.0/24","source-type":"CIDR_BLOCK","tcp-options":null,"udp-options":null},
      {"is-stateless":false,"protocol":"17","source":"10.1.0.0/24","source-type":"CIDR_BLOCK","tcp-options":null,"udp-options":null}]'        

# Create Spark Worker Security List
SWSLI=$(oci network security-list create --compartment-id $CID --egress-security-rules $SWESR --ingress-security-rules $SWISR --vcn-id $VID --display-name spark-worker-sl --query data.id --raw-output)

# Return the Spark Master Security List Id
#SWSLI=oci network security-list list --compartment-id $CID --vcn-id $VID --display-name spark-worker-sl --query data[0].id --raw-output

# Format Spark Worker Security List Id to Json Format
SWSLI='["'$SWSLI'"]'

# Update the Spark Worker Subnet to use the Spark Worker Security List as Default
oci network subnet update --subnet-id $SSWI --security-list-ids $SWSLI --force
