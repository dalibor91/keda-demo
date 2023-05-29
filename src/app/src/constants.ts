import { envFetch, randStr } from "./helpers";

export const App = {
    AzureStorage: {
        Connection: envFetch('AZURE_STORAGE_CONNECTION_STRING'),
        Queue: envFetch('AZURE_STORAGE_QUEUE_NAME', '')
        // Queue: {

        // }
    },
    Debug: envFetch('NODE_ENV', 'production') === 'developement',
    // just some random id to record process run
    RunId: randStr()
} as const;