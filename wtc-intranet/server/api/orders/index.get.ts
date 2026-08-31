import prisma from '../../utils/prisma'
import { Prisma } from '@prisma/client'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const { startDate, endDate, search } = query as Record<string, string>

    const dateWhere: any = {}
    if (startDate) {
        dateWhere.created_at = { ...dateWhere.created_at, gte: new Date(startDate) }
    }
    if (endDate) {
        const end = new Date(endDate)
        end.setDate(end.getDate() + 1)
        dateWhere.created_at = { ...dateWhere.created_at, lt: end }
    }

    const searchWhere = search ? {
        customizations: { some: { name: { contains: search } } }
    } : {}

    const where = { ...dateWhere, ...searchWhere }

    // Build conditional date fragments for raw profit queries
    const startFilter = startDate
        ? Prisma.sql`AND o.created_at >= ${new Date(startDate)}`
        : Prisma.empty

    const endFilter = endDate
        ? Prisma.sql`AND o.created_at < ${new Date(new Date(endDate).setDate(new Date(endDate).getDate() + 1))}`
        : Prisma.empty

    const [orders, itemProfitResult, customProfitResult] = await Promise.all([
        prisma.order.findMany({
            where,
            orderBy: { created_at: 'desc' },
            include: {
                _count: { select: { items: true, customizations: true } }
            }
        }),
        prisma.$queryRaw<[{ profit: number }]>`
      SELECT COALESCE(SUM((oi.retail - COALESCE(inv.cost, 0)) * oi.quantity), 0) as profit
      FROM wtc_order_items oi
      JOIN wtc_orders o ON o.id = oi.order_id
      LEFT JOIN wtc_inventory inv ON inv.id = oi.inventory_id
      WHERE 1=1
      ${startFilter}
      ${endFilter}
    `,
        prisma.$queryRaw<[{ profit: number }]>`
      SELECT COALESCE(SUM(oc.retail - COALESCE(inv.cost, 0)), 0) as profit
      FROM wtc_order_customizations oc
      JOIN wtc_orders o ON o.id = oc.order_id
      LEFT JOIN wtc_inventory inv ON inv.id = oc.inventory_id
      WHERE 1=1
      ${startFilter}
      ${endFilter}
    `
    ])

    const grossRevenue = orders.reduce((sum, o) => sum + Number(o.total), 0)
    const netProfit = Number(itemProfitResult[0]?.profit ?? 0) + Number(customProfitResult[0]?.profit ?? 0)

    return {
        summary: {
            totalOrders: orders.length,
            grossRevenue,
            netProfit
        },
        orders: orders.map(o => ({
            id: o.id,
            customer: o.customer,
            created_at: o.created_at.toISOString(),
            total: Number(o.total),
            status: o.status,
            payment_method: o.payment_method,
            item_count: o._count.items,
            customization_count: o._count.customizations
        }))
    }
})