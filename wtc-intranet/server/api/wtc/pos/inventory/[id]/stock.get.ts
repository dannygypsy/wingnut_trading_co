export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id') || ''
    const rawId = id.replace(/^WTC-/i, '')

    const rows = await prisma.$queryRaw<any[]>`
    SELECT remaining FROM wtc_inventory
    WHERE id = ${rawId} OR LOWER(id) LIKE ${rawId.toLowerCase() + '%'}`

    if (rows.length === 0) throw createError({ statusCode: 404, message: 'Item not found.' })

    const remaining = rows[0].remaining

    if (remaining !== null && Number(remaining) <= 0) {
        throw createError({ statusCode: 409, message: 'No stock remaining for this transfer.' })
    }

    return { success: true, remaining: Number(remaining) }
})