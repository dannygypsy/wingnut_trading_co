export default defineEventHandler(async (event) => {
    const q = ((getQuery(event).q as string) || '').trim()
    if (!q) throw createError({ statusCode: 400, message: 'Query parameter q is required.' })

    let rows: any[]

    if (/^WTC-/i.test(q)) {
        const uuidPrefix = q.replace(/^WTC-/i, '').toLowerCase()
        rows = await prisma.$queryRaw<any[]>`
      SELECT id, product_id, category, name, full_name, size, retail,
             (SELECT GROUP_CONCAT(p.name ORDER BY p.name SEPARATOR ',')
              FROM wtc_inventory_placements p
              JOIN wtc_inventory_categories c ON p.category_id = c.id
              WHERE c.name = i.category) AS placements
      FROM wtc_inventory i
      WHERE LOWER(id) LIKE ${uuidPrefix + '%'}
      LIMIT 10`
    } else {
        rows = await prisma.$queryRaw<any[]>`
      SELECT id, product_id, category, name, full_name, size, retail,
             (SELECT GROUP_CONCAT(p.name ORDER BY p.name SEPARATOR ',')
              FROM wtc_inventory_placements p
              JOIN wtc_inventory_categories c ON p.category_id = c.id
              WHERE c.name = i.category) AS placements
      FROM wtc_inventory i
      WHERE name LIKE ${`%${q}%`} OR full_name LIKE ${`%${q}%`} OR category LIKE ${`%${q}%`}
      ORDER BY name
      LIMIT 20`
    }

    const results = rows.map(row => ({
        id: `WTC-${row.id.substring(0, 8).toUpperCase()}`,
        raw_id: row.id,
        product_id: row.product_id || null,
        category: row.category,
        name: row.name,
        full_name: row.full_name,
        size: row.size,
        retail: row.retail,
        placements: row.placements
            ? row.placements.split(',').map((p: string) => p.trim()).filter(Boolean)
            : []
    }))

    return { success: true, results }
})