import prisma from '../../utils/prisma'

export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id')
    await prisma.cashFlow.delete({ where: { id } })
    return { success: true }
})