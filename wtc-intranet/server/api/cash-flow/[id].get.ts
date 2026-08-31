import prisma from '../../utils/prisma'

export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id')
    const transaction = await prisma.cashFlow.findUnique({ where: { id } })
    if (!transaction) throw createError({ statusCode: 404, message: 'Transaction not found' })
    return { ...transaction, amount: Number(transaction.amount) }
})