import { getSession } from '../utils/auth'

export default defineEventHandler((event) => {
    const url = event.node.req.url || ''

    // Allow public routes through
    if (
        url.startsWith('/api/auth') ||
        url === '/signin' ||
        url.startsWith('/_nuxt') ||
        url.startsWith('/__nuxt')
    ) {
        return
    }

    const user = getSession(event)

    if (!user) {
        // For API routes return 401, for pages redirect to signin
        if (url.startsWith('/api/')) {
            throw createError({ statusCode: 401, message: 'Unauthorized' })
        } else {
            return sendRedirect(event, '/signin')
        }
    }

    // Attach user to event context so pages can access it
    event.context.user = user
})