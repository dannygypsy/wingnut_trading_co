export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const date = (query.date as string) || new Date().toISOString().slice(0, 10)
    const search = ((query.search as string) || '').trim()

    let orders: any[]

    if (search) {
        orders = await prisma.$queryRaw<any[]>`
      SELECT o.id, o.salesperson_name, o.customer, o.discount_percent,
             o.total, o.status, o.payment_method, o.created_at,
             COUNT(i.id) AS item_count
      FROM wtc_orders o
      LEFT JOIN wtc_order_items i ON i.order_id = o.id
      WHERE o.customer LIKE ${`%${search}%`} OR o.id LIKE ${`%${search}%`}
      GROUP BY o.id
      ORDER BY o.created_at DESC
      LIMIT 200`
    } else {
        orders = await prisma.$queryRaw<any[]>`
      SELECT o.id, o.salesperson_name, o.customer, o.discount_percent,
             o.total, o.status, o.payment_method, o.created_at,
             COUNT(i.id) AS item_count
      FROM wtc_orders o
      LEFT JOIN wtc_order_items i ON i.order_id = o.id
      WHERE DATE(o.created_at) = ${date}
      GROUP BY o.id
      ORDER BY o.created_at DESC
      LIMIT 200`
    }

    return { success: true, orders, date }
})