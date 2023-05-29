import { getQueue } from "../common"
import { logger } from "../helpers"

export const consume = async (noMessages = 3) => {
    logger.info('Running consumer...', {})

    const messageQueue = await getQueue()

    const messages = await messageQueue.receiveMessages({
        numberOfMessages: noMessages
    })

    for(let i in messages.receivedMessageItems) {
        const message = messages.receivedMessageItems[i]

        logger.info('Message Received: ', { 
            content: message.messageText,
            messageId: message.messageId
        })

        const data = JSON.parse(message.messageText)

        await new Promise((resolve, _) => {
            logger.info(`Sleeping for ${data.runId} = ${data.payload.sleep}`)
            setTimeout(() => { 
                logger.info(`Sleeping done for ${data.runId}`)
                resolve(null)
            }, data.payload.sleep)
        })

        await messageQueue.deleteMessage(message.messageId, message.popReceipt)
    }
}