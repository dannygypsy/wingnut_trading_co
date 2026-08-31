import prisma from '../../utils/prisma'
import { randomUUID } from 'crypto'

export default defineEventHandler(async (event) => {
    const body = await readBody(event)
    const user = event.context.user

    const transaction = await prisma.cashFlow.create({
        data: {
            id: randomUUID(),
            transaction_date: new Date(body.transaction_date),
            type: body.type,
            category: body.category,
            description: body.description,
            amount: parseFloat(body.amount),
            payment_method: body.payment_method || null,
            vendor: body.vendor || null,
            notes: body.notes || null,
            created_by: user?.name ?? 'unknown',
        }
    })

    return { success: true, id: transaction.id }
})