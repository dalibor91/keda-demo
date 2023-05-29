import { getQueue } from "../common"
import { logger, randStr } from "../helpers"

export const produce = async (limit = 99): Promise<void> => {
    logger.info('Running producer...')

    const messageQueue = await getQueue();
    for (let i=0; i< limit; i++) {
        const response = await messageQueue.sendMessage(JSON.stringify({
            runId: randStr(),
            payload: {
                sleep: Math.floor(Math.random()*10000)
            }
        }))
    
        logger.info('Message sent', {
            messageId: response.messageId,
            errorCode: response.errorCode,
            expires: response.expiresOn
        })
    }
}