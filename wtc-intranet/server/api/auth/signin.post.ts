import { createSession } from '../../utils/auth'

export default defineEventHandler(async (event) => {
    const { username, password } = await readBody(event)

    const validUsername = process.env.WTC_USERNAME
    const validPassword = process.env.WTC_PASSWORD

    if (username !== validUsername || password !== validPassword) {
        throw createError({ statusCode: 401, message: 'Invalid credentials' })
    }

    createSession(event, {
        name: username,
        email: process.env.ALLOWED_EMAILS?.split(',')[0] ?? ''
    })

    return { success: true }
})