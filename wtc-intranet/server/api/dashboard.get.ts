import prisma from '../utils/prisma'

export default defineEventHandler(async () => {
    const now = new Date()
    const startOfWeek = new Date(now)
    startOfWeek.setDate(now.getDate() - now.getDay())
    startOfWeek.setHours(0, 0, 0, 0)

    const [weeklySales, inventorySummary, lowStockItems, recentOrders] = await Promise.all([
        prisma.order.aggregate({
            where: { created_at: { gte: startOfWeek } },
            _sum: { total: true },
            _count: { _all: true }
        }),
        prisma.inventory.aggregate({
            _sum: { remaining: true },
            _count: { _all: true }
        }),
        prisma.$queryRaw<[{ count: bigint }]>`
      SELECT COUNT(*) as count FROM wtc_inventory
      WHERE remaining < (num_purchased * 0.25) AND remaining > 0
    `,
        prisma.order.findMany({
            take: 5,
            orderBy: { created_at: 'desc' },
            select: {
                id: true,
                customer: true,
                total: true,
                status: true,
                created_at: true,
                _count: { select: { items: true } }
            }
        })
    ])

    return {
        weeklyRevenue: Number(weeklySales._sum.total ?? 0),
        weeklyOrderCount: weeklySales._count._all,
        totalInventoryItems: inventorySummary._count._all,
        totalInventoryRemaining: Number(inventorySummary._sum.remaining ?? 0),
        lowStockCount: Number(lowStockItems[0]?.count ?? 0),
        recentOrders: recentOrders.map(o => ({
            ...o,
            total: Number(o.total)
        }))
    }
})