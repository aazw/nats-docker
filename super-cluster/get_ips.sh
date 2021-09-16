#!/bin/bash

set -eu

echo custer-1-nats-server-1: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' super-cluster_cluster-1-nats-server-1_1)
echo custer-1-nats-server-2: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' super-cluster_cluster-1-nats-server-2_1)
echo custer-1-nats-server-3: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' super-cluster_cluster-1-nats-server-3_1)
echo custer-1-nats-server-4: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' super-cluster_cluster-1-nats-server-4_1)
echo custer-1-nats-server-5: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' super-cluster_cluster-1-nats-server-5_1)
echo custer-2-nats-server-1: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' super-cluster_cluster-2-nats-server-1_1)
echo custer-2-nats-server-2: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' super-cluster_cluster-2-nats-server-2_1)
echo custer-2-nats-server-3: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' super-cluster_cluster-2-nats-server-3_1)
echo custer-2-nats-server-4: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' super-cluster_cluster-2-nats-server-4_1)
echo custer-2-nats-server-5: $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' super-cluster_cluster-2-nats-server-5_1)
