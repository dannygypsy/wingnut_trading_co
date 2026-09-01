export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id')
    if (!id) throw createError({ statusCode: 400, message: 'Missing ID' })

    const item = await prisma.inventory.findUnique({
        where: { id },
        select: {
            id: true,
            product_id: true,
            name: true,
            size: true,
            category: true,
            type: true,
            retail: true,
        }
    })
    if (!item) throw createError({ statusCode: 404, message: 'Item not found' })

    // Placements via category join
    const placements = await prisma.$queryRaw<{ name: string }[]>`
    SELECT p.name
    FROM wtc_inventory_placements p
    JOIN wtc_inventory_categories c ON p.category_id = c.id
    JOIN wtc_inventory i ON i.category = c.name
    WHERE i.id = ${id}
    ORDER BY p.sort_order, p.name
  `

    const wtcId = 'WTC-' + id.substring(0, 8).toUpperCase()
    let price = Number(item.retail)
    let subPrice = ''

    if (item.type === 'blank') {
        price = price + 5
        subPrice = 'INCLUDES 1 TRANSFER'
    } else if (item.type === 'transfer') {
        subPrice = 'TRANSFER ONLY'
    }

    return {
        id,
        product_id: item.product_id,
        wtcId,
        name: item.name,
        category: item.category,
        size: item.size,
        price,
        subPrice,
        placements: placements.map(p => p.name),
    }
})