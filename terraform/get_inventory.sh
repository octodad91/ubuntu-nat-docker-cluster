#!/bin/bash

NETWORK_NAME="isolated-net"
INVENTORY_FILE="../ansible/inventory.ini"

echo "[docker_cluster]" > "$INVENTORY_FILE"

virsh net-dhcp-leases $NETWORK_NAME | grep ipv4 | awk '{print $5}' | cut -d/ -f1 >> "$INVENTORY_FILE"

echo "Inventory created: $INVENTORY_FILE"
