export default defineEventHandler(async (event) => {
    const pid = ((getQuery(event).pid as string) || '').trim()
    if (!pid) throw createError({ statusCode: 400, message: 'pid is required.' })

    const parts = pid.split('|')
    const pidPart = parts[0] ?? ''
    const rawId = pidPart.replace(/^WTC-/i, '').toLowerCase()
    const size = parts[1]?.trim() ?? null

    let rows: any[]

    if (size) {
        rows = await prisma.$queryRaw<any[]>`
      SELECT i.product_id, i.id AS item_id, i.name, i.size, i.category, i.retail,
             i.remaining AS total_remaining,
             (SELECT GROUP_CONCAT(p.name ORDER BY p.sort_order, p.name SEPARATOR ',')
              FROM wtc_inventory_placements p
              JOIN wtc_inventory_categories c ON p.category_id = c.id
              WHERE c.name = i.category) AS placements
      FROM wtc_inventory i
      WHERE (i.product_id = ${rawId} OR i.product_id LIKE ${rawId + '%'}) AND i.size = ${size}
      LIMIT 1`
    } else {
        rows = await prisma.$queryRaw<any[]>`
      SELECT i.product_id,
             MAX(i.name) AS name, MAX(i.size) AS size, MAX(i.category) AS category,
             MAX(i.retail) AS retail, SUM(i.remaining) AS total_remaining,
             (SELECT GROUP_CONCAT(p.name ORDER BY p.sort_order, p.name SEPARATOR ',')
              FROM wtc_inventory_placements p
              JOIN wtc_inventory_categories c ON p.category_id = c.id
              WHERE c.name = MAX(i.category)) AS placements
      FROM wtc_inventory i
      WHERE i.product_id = ${rawId} OR i.product_id LIKE ${rawId + '%'}
      GROUP BY i.product_id`
    }

    if (rows.length === 0) {
        throw createError({
            statusCode: 404,
            message: `Product not found for product_id '${rawId}'${size ? ` size '${size}'` : ''}.`
        })
    }

    const row = rows[0]
    const cat = row.category?.toLowerCase() || ''

    return {
        success: true,
        product_id: pidPart,
        name: row.name,
        size: row.size,
        category: row.category,
        retail: parseFloat(row.retail) || 0,
        is_transfer: cat.includes('transfer') || cat.includes('decal'),
        in_stock: (Number(row.total_remaining) || 0) > 0,
        placements: row.placements
            ? row.placements.split(',').map((p: string) => p.trim()).filter(Boolean)
            : []
    }
})