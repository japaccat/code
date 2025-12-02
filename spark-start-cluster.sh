CID=$(oci iam compartment list --name tsupi --compartment-id-in-subtree true --query data[0].id --raw-output)
SMCII=$(oci compute instance list --compartment-id $CID --display-name sm0ci --query data[0].id --raw-output)
SMPIP=$(oci compute instance list-vnics --compartment-id $CID --instance-id $SMCII --query 'data[0]."public-ip"' --raw-output)
SM0LS=$(oci compute instance list --compartment-id $CID --display-name sm0ci --query 'data[0]."lifecycle-state"' --raw-output)
SW0LS=$(oci compute instance list --compartment-id $CID --display-name sw0ci --query 'data[0]."lifecycle-state"' --raw-output)

if [ "$SM0LS" = "RUNNING" ]; then
	ssh opc@$SMPIP bash << 'EOF'
		source ~/.bash_profile
		cd \$SPARK_HOME/sbin
		./start-master.sh
	EOF
fi

if [ "$SW0LS" = "RUNNING" ]; then
	ssh opc@$SMPIP bash << 'EOF'
		source ~/.bash_profile
		cd \$SPARK_HOME/sbin
		./start-workers.sh
	EOF
fi
