import { sanitizeBigInt } from '#server/utils/bigint.ts'

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
      SELECT remaining AS total_remaining
      FROM wtc_inventory
      WHERE (product_id = ${rawId} OR product_id LIKE ${rawId + '%'}) AND size = ${size}
      LIMIT 1`
    } else {
        rows = await prisma.$queryRaw<any[]>`
      SELECT SUM(remaining) AS total_remaining
      FROM wtc_inventory
      WHERE product_id = ${rawId} OR product_id LIKE ${rawId + '%'}`
    }

    const remaining = Number(rows[0]?.total_remaining) || 0
    if (remaining <= 0) {
        throw createError({ statusCode: 409, message: 'No stock remaining.' })
    }

    return { success: true, in_stock: true, remaining }
})