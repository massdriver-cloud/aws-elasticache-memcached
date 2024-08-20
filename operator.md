## AWS ElastiCache Memcached

AWS ElastiCache is a fully managed, in-memory data store and cache service that supports flexible, real-time use cases. With ElastiCache for Memcached, you can seamlessly set up, run, and scale popular open-source, high-performance, distributed memory object caching system Memcached, as a managed service.

### Design Decisions

- **High Availability**: The module is designed to deploy ElastiCache Memcached clusters that support high availability and failover by using Multi-AZ deployments.
- **Scalability**: The module supports adding multiple nodes to the Memcached cluster, enabling horizontal scalability.
- **Security**: The module enforces VPC-based deployment and supports encryption in transit and at rest. Security groups are also configured to restrict access to the Memcached cluster.
- **Monitoring and Maintenance**: Automated cloud watch alarms and automatic backups are configured for easier maintenance and monitoring.

### Runbook

#### Unable to Connect to Memcached Cluster

Sometimes, users may face issues while connecting to the Memcached cluster. To troubleshoot connection issues, you can use the AWS CLI to check the cluster status and verify network configurations.

Check Memcached Cluster Status:

```sh
aws elasticache describe-cache-clusters --cache-cluster-id your-cluster-id --show-cache-node-info
```

Check the `CacheClusterStatus` field; it should be `available`. Also, ensure that the `Caches Nodes` have valid IP addresses.

Verify Security Group Rules:

```sh
aws ec2 describe-security-groups --group-ids your-security-group-id
```

Make sure that the security group allows inbound connections on the Memcached port (default is 11211).

#### Memcached Cluster High Latency

High latency can drastically affect the performance of your applications. To troubleshoot high latency:

Check Cluster Metrics (CloudWatch):

```sh
aws cloudwatch get-metric-statistics --namespace AWS/ElastiCache --metric-name CurrConnections --start-time $(date -u -d '15 minutes ago' +"%Y-%m-%dT%H:%M:%SZ") --end-time $(date -u +"%Y-%m-%dT%H:%M:%SZ") --period 300 --statistics Average --dimensions Name=CacheClusterId,Value=your-cluster-id
```

Check for the `CurrConnections` metric. A very high number might indicate the need for scaling the cluster.

Check Memcached Utilization:

```sh
memcached-tool your-memcached-endpoint:11211 stats
```

Look for high values under "STATS" like `bytes`, `curr_connections`, and `get_hits/get_misses` ratio. These statistics give you an overview of the current load and performance of your Memcached cluster.

#### Data Inconsistency Issues

Inconsistent data often results from network partitions or suboptimal configuration settings. To resolve data inconsistency:

Check Node Status:

```sh
aws elasticache describe-cache-clusters --cache-cluster-id your-cluster-id --show-cache-node-info
```

Ensure all nodes in the Memcached cluster are `available`.

Flush Cache:

```sh
echo "flush_all" | nc your-memcached-endpoint 11211
```

This command will clear the cache and can help in resolving inconsistency temporarily. Be cautious as this will remove all the cached data in Memcached.

#### Memory Allocation Issues

If Memcached is running out of memory, it can evict existing items, impacting application performance.

Check Memory Usage:

```sh
memcached-tool your-memcached-endpoint:11211 display
```

Observe fields like `limit_maxbytes` and `bytes`. If the usage (`bytes`) consistently approaches the limit (`limit_maxbytes`), consider scaling your cluster.

Resize Node Groups:

```sh
aws elasticache modify-cache-cluster --cache-cluster-id your-cluster-id --num-cache-nodes new-node-count
```

Replace `new-node-count` with the desired number of nodes to allocate more memory to the cluster. This operation can take a while and may cause downtime.

These troubleshooting tips should help you manage and resolve common issues with AWS ElastiCache Memcached effectively.

