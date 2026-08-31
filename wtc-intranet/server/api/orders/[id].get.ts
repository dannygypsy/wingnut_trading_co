import prisma from '../../utils/prisma'

export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id')

    const order = await prisma.order.findUnique({
        where: { id },
        include: {
            items: {
                include: {
                    inventory: {
                        select: {
                            cost: true,
                            type: true,
                            category: true,
                            size: true,
                        }
                    },
                    customizations: {
                        include: {
                            inventory: {
                                select: {
                                    cost: true,
                                }
                            }
                        }
                    }
                }
            }
        }
    })

    if (!order) throw createError({ statusCode: 404, message: 'Order not found' })

    const items = order.items.map(item => {
        const cost = Number(item.inventory?.cost ?? 0)
        const retail = Number(item.retail)
        const itemProfit = (retail - cost) * item.quantity

        const customizations = item.customizations.map(c => {
            const cCost = Number(c.inventory?.cost ?? 0)
            const cRetail = Number(c.retail)
            return {
                id: c.id,
                name: c.name,
                retail: cRetail,
                cost: cCost,
                customization_profit: cRetail - cCost
            }
        })

        return {
            id: item.id,
            name: item.name,
            quantity: item.quantity,
            retail,
            cost,
            item_profit: itemProfit,
            category: item.inventory?.category ?? null,
            type: item.inventory?.type ?? null,
            size: item.inventory?.size ?? null,
            customizations
        }
    })

    const totalProfit = items.reduce((sum, item) => {
        const customProfit = item.customizations.reduce((s, c) => s + c.customization_profit, 0)
        return sum + item.item_profit + customProfit
    }, 0)

    return {
        id: order.id,
        customer: order.customer,
        created_at: order.created_at.toISOString(),
        total: Number(order.total),
        status: order.status,
        payment_method: order.payment_method,
        discount_desc: order.discount_desc,
        discount_percent: order.discount_percent ? Number(order.discount_percent) : null,
        totalProfit,
        items
    }
})