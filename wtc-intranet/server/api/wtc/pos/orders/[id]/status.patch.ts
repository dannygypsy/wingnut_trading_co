export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id') || ''
    const { status } = await readBody(event)

    const allowed = ['pending', 'completed', 'delivered', 'canceled']
    if (!allowed.includes(status)) {
        throw createError({
            statusCode: 400,
            message: `Invalid status. Must be one of: ${allowed.join(', ')}`
        })
    }

    const orders = await prisma.$queryRaw<any[]>`
    SELECT status FROM wtc_orders WHERE id = ${id}`
    if (orders.length === 0) throw createError({ statusCode: 404, message: 'Order not found.' })

    const oldStatus = orders[0].status

    // Canceling → restore transfer inventory
    if (status === 'canceled' && oldStatus !== 'canceled') {
        const placements = await prisma.$queryRaw<any[]>`
      SELECT oc.inventory_id
      FROM wtc_order_customizations oc
      JOIN wtc_order_items oi ON oc.item_id = oi.id
      WHERE oi.order_id = ${id} AND oc.inventory_id IS NOT NULL`

        for (const p of placements) {
            await prisma.$executeRaw`
        UPDATE wtc_inventory SET remaining = remaining + 1 WHERE id = ${p.inventory_id}`
        }
    }

    // Un-canceling → re-decrement transfer inventory
    if (oldStatus === 'canceled' && status !== 'canceled') {
        const placements = await prisma.$queryRaw<any[]>`
      SELECT oc.inventory_id
      FROM wtc_order_customizations oc
      JOIN wtc_order_items oi ON oc.item_id = oi.id
      WHERE oi.order_id = ${id} AND oc.inventory_id IS NOT NULL`

        for (const p of placements) {
            await prisma.$executeRaw`
        UPDATE wtc_inventory SET remaining = remaining - 1
        WHERE id = ${p.inventory_id} AND remaining > 0`
        }
    }

    await prisma.$executeRaw`UPDATE wtc_orders SET status = ${status} WHERE id = ${id}`

    console.log(`POS order ${id} status: ${oldStatus} → ${status}`)
    return { success: true, status }
})