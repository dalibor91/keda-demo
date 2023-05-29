import { logger } from "./helpers"
import { produce } from "./producer"
import { consume } from "./consumer"


const run = async (target: string) => {
    switch(target) {
        case 'produce':
            await produce()
            break
        case 'consume':
            await consume()
            break
        default:
            logger.error('Unknown target', { target })
            process.exit(1)
    }
}

run(process.argv[2] ?? 'unknown')
