export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const q = (query.q as string || '').trim()
    if (!q) return { results: [] }

    const results = await prisma.$queryRaw<any[]>`
        SELECT product_id,
               MAX(name) AS name,
               MAX(full_name) AS full_name,
               MAX(size) AS size,
               MAX(category) AS category,
               MAX(retail) AS retail,
               MAX(type) AS type
        FROM wtc_inventory
        WHERE (name LIKE ${`%${q}%`} OR full_name LIKE ${`%${q}%`})
          AND product_id IS NOT NULL
        GROUP BY product_id
        ORDER BY MAX(name)
        LIMIT 10
    `

    return { results }
})