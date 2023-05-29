import { QueueClient, QueueServiceClient } from "@azure/storage-queue"
import { App } from "./constants"

export const getQueue = async (): Promise<QueueClient> => {
    const queueClient = QueueServiceClient
        .fromConnectionString(App.AzureStorage.Connection)
        .getQueueClient(App.AzureStorage.Queue)

    const exists = await queueClient.exists()

    // not nececary
    if (!exists) {
        await queueClient.create()
    }

    return queueClient
}