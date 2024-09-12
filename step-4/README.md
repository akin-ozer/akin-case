# Move CI to cloud

- Using GitHub Actions, no maintaining og the control plane. No plugin installs. Runners anywhere(cloud, on/prem, custom mac devices)
- Easier and better way to write CI and CD pipelines.
- Everything is dockerized, so better stability between runs.
- GitHub has it's own artifact storage, but we can use custom s3 buckets as well. And let developers download them easily. Also `TestFlight` integration would help.
- Example GitHub Action at example-ci.yaml
- Licencing can be done with env variables in jobs and for Android: 
```
- name: Setup Android SDK
  uses: android-actions/setup-android@v2

- name: Accept Android SDK Licenses
  run: yes | sdkmanager --licenses
```

# Challenges in IOS Dev
- Example GitHub Action at fastlane.yaml
- Set up Fastlane in your project and create the Fastfile.
- Configure match for code signing management.
- Set up your CI/CD pipeline (in this case, GitHub Actions).
- Store necessary secrets (certificates, passwords) in your CI/CD platform.

# Disaster recovery for Kubernetes in AWS

Disaster recovery only works when it's regularly tested, covers everything, done fast enough. If you can't recover from it, you don't have a backup.

There are 2 general way of DR:

1: (my favourite)Automate everything and make everything parameterized:

- ~80% of the work is automatically done if your infra code is well-written and well-architected.
- First of all, when you have well-architected infra code. You should be able to run it multiple times. 
Also you can change the region and everything goes there instead.
- If everything you have is in 1 region then you should be replicate the creation of everything in new region.
- Need custom data migration for databases/s3 buckets/custom ebs volumes/other stateful app data.
Better if they are already replicated to designated DR region continuously. So if we can't reach to the data in old region, it's not a big problem.
- Need to trigger app deployment on this new cluster. Hopefully it's written in a way that cluster name, region, aws account id etc. are parameterized.
- Need to add custom DR related pipelines to reroute networking everything to DR resources.

2: More traditional way of doing DR with backups and restoring.

- Infra code is still need to be somewhat decently written and architected. But some manual work is expected in this route.
- There should be services/CronJobs that regularly creates backups of k8s, databases, s3 buckets, ebs volumes etc. and sends these to designated DR region.
- For Kubernetes Velero can be used but it needs careful planning and regular testing becuase it can't really understand dependencies by itself so it needs lots of tuning.
- For AWS related resources, using in-place tools are better than custom scripts but more costly.
- Need to reroute networking everything to DR resources.
- If this approach is regularly tested, not that bad but it's kind of hard to maintain between infra changes.
Because it might require custom dependency management and lots of manual steps.

### Summary

DR is really hard to implement and maintain in general. Using automation tools wherever applicable does help with reducing the workload.
- For example `terraform`ing everything helps a lot with the provisioning of the new resources.
- Using Ansible wherever necessary helps with configuration management and using variables to configure the environments.
- Using Managed Databases/s3/Managed Message Queues/EBS/AWS Secrets Manager(or SSM Parameter Store) helps with DR resource creation and creating backups/applying backups.
- Creating custom Pipelines/Cron Jobs/Ansible Playbooks to manage manual work reduces errors in the process and make everything faster.