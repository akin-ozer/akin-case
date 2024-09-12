# Overprosivion

Scheduled Scaling with CronJobs:

- The scale-up-app CronJob increases the number of replicas to 10 at 7:00 AM every day.
- The scale-down-app CronJob decreases the number of replicas to 3 at 7:00 PM every day.
- This provides scaling before and after peak hours.
- There are alternatives, for example: There can be custom Jenkins Job/GitHub Action that does this kind of scaling. 

Also to overprovision the nodes:
- We can use Cloud AutoScaling services or Karpenter. So we can make it less painful.
- For physical devices, we need an orchestrator like Ansible or RKE to manage nodes by code.

# Minimize Risk while deploying

 If we want to minimize the risks while deploying we have couple options:

- Blue/Green Deployment: The most risk-free option. Hard to implement and to maintain. 
Can be combined with Canary Deployment to test the new deployment safely.
- Canary Deployment: Most effective and data-driven solution. Very hard to implement but relatively easy to maintain.
This can be enriched with custom data and regression data from new deployment and observe if it's good to deploy while being safe.
- Rolling Deployment with Rollbacks: Not that safe but if there is nothing wrong with your application if won't cause downtime. 
Relatively medium hard to implement the rollback and easy to maintain. Not recommended when first 2 are available.

To switch traffic to new version, it depends on the method:

- Blue/Green Deployment: You just have one public and one private endpoints. Public one is live.
You need to test the new version on private endpoint and then convert it to the public one if everything is ok.
- Canary Deployment: You only have one endpoint which is redirected inside the cluster based on location/header/query parameter etc.
You need to update the logic to deploy the app after Canary phase.
- Rolling Deployment: One endpoint, the service gets updated instead.