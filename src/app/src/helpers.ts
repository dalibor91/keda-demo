export const envFetch = (name: string, deflt?: string): string => {
    if (process.env[name] === undefined) {
        if (deflt === undefined) {
            throw new Error(`Can't find "${name}" also default is undefined`)
        }

        return deflt;
    } 

    // TS is still a bit dumb so we need to do this 
    // or we can add one more if block
    //@ts-ignore
    return process.env[name]
}

export const randStr = () => Math.random().toString(32).substring(2)

export const logger = {
    info: (message: string, context: any = {}): void => {
        console.log({
            type: 'info',
            message,
            context
        })
    },
    error: (message: string, context: any = {}): void => {
        console.log({
            type: 'error',
            message,
            context
        })
    },
}