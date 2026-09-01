export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id') || ''

    const orders = await prisma.$queryRaw<any[]>`
    SELECT id, salesperson_name, customer, notes, discount_percent, total,
           status, payment_method, created_at
    FROM wtc_orders WHERE id = ${id}`

    if (orders.length === 0) throw createError({ statusCode: 404, message: 'Order not found.' })

    const order = orders[0]

    const items = await prisma.$queryRaw<any[]>`
    SELECT id, inventory_id, name, size, retail, quantity
    FROM wtc_order_items WHERE order_id = ${id}`

    for (const item of items) {
        const placements = await prisma.$queryRaw<any[]>`
      SELECT position AS slot, inventory_id AS transfer_id,
             name AS transfer_name, retail AS transfer_retail
      FROM wtc_order_customizations WHERE item_id = ${item.id}`
        item.placements = placements
    }

    order.items = items
    return { success: true, order }
})