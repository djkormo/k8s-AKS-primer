## Based on https://github.com/Azure/azch-loadtest


### Usage

```sh
docker run --rm -it azch/loadtest <public ip of order capture service>
```

To run this using Azure Container Instances
```sh
az container create -g akschallenge --n loadtest --image azch/loadtest -e SERVICE_IP=<public ip of order capture service> --restart-policy Never --no-wait

az container attach -g akschallenge --n loadtest

az container delete -g akschallenge --n loadtest
```

```sh
az container create -g akschallenge --name loadtest --image azch/loadtest  --restart-policy Never  --no-wait --environment-variables SERVICE_IP=23.96.91.35
```

```sh
az container logs --resource-group akschallenge --name loadtest
```

### Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.