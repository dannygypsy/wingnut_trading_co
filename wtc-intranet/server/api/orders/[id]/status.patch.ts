import prisma from '../../../utils/prisma'

export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id')
    const { status } = await readBody(event)

    const valid = ['pending', 'completed', 'delivered', 'canceled']
    if (!valid.includes(status)) {
        throw createError({ statusCode: 400, message: 'Invalid status' })
    }

    await prisma.order.update({ where: { id }, data: { status } })
    return { success: true, status }
})