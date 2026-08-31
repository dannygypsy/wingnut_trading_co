import prisma from '../../utils/prisma'

export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id')
    const body = await readBody(event)

    const transaction = await prisma.cashFlow.update({
        where: { id },
        data: {
            transaction_date: new Date(body.transaction_date),
            type: body.type,
            category: body.category,
            description: body.description,
            amount: parseFloat(body.amount),
            payment_method: body.payment_method || null,
            vendor: body.vendor || null,
            notes: body.notes || null,
        }
    })

    return { success: true, id: transaction.id }
})