import { randomUUID } from 'node:crypto'

export default defineEventHandler(async (event) => {
    const body = await readBody(event)

    if (!body.items || body.items.length === 0) {
        throw createError({ statusCode: 400, message: 'Order must contain at least one item.' })
    }

    const now = new Date()
    const nowStr = now.toISOString().slice(0, 19).replace('T', ' ')

    // Generate WTC-YYYYMMDD-### — count today's orders, then increment
    const dateStr = now.toISOString().slice(0, 10).replace(/-/g, '')
    const prefix = `WTC-${dateStr}-`

    const countResult = await prisma.$queryRaw<[{ cnt: bigint }]>`
        SELECT COUNT(*) AS cnt FROM wtc_orders WHERE id LIKE ${prefix + '%'}`
    const nextNum = Number(countResult[0].cnt) + 1
    const orderId = `${prefix}${String(nextNum).padStart(3, '0')}`

    await prisma.$executeRaw`
        INSERT INTO wtc_orders
        (id, customer, notes, created_at, created_by, salesperson_name, total, status, discount_percent, payment_method)
        VALUES (
                   ${orderId},
                   ${body.customer_name || ''},
                   ${body.notes || null},
                   ${nowStr},
                   ${body.salesperson_name || ''},
                   ${body.salesperson_name || null},
                   ${body.total || 0},
                   'pending',
                   ${body.discount_pct || 0},
                   ${body.payment_method || 'not paid'}
               )`

    for (const item of body.items) {
        const itemId = randomUUID()

        // Resolve blank product_id → oldest batch UUID
        let blankInventoryId: string | null = null
        if (item.blank_id) {
            const rawBlankId = item.blank_id.replace(/^WTC-/i, '').toLowerCase()
            const blankBatches = await prisma.$queryRaw<any[]>`
                SELECT id FROM wtc_inventory
                WHERE (product_id = ${rawBlankId} OR product_id LIKE ${rawBlankId + '%'})
                ORDER BY purchased_on ASC
                LIMIT 1`
            if (blankBatches.length > 0) blankInventoryId = blankBatches[0].id
        }

        await prisma.$executeRaw`
            INSERT INTO wtc_order_items (id, order_id, inventory_id, name, retail, quantity, size)
            VALUES (
                       ${itemId}, ${orderId}, ${blankInventoryId},
                       ${item.blank_name || ''}, ${item.price || 0}, ${item.quantity || 1}, ${item.size || ''}
                   )`

        if (item.placements && item.placements.length > 0) {
            for (const placement of item.placements) {
                if (!placement.transfer_id) continue

                const rawTransferId = placement.transfer_id.replace(/^WTC-/i, '').toLowerCase()
                const transferBatches = await prisma.$queryRaw<any[]>`
                    SELECT id FROM wtc_inventory
                    WHERE (product_id = ${rawTransferId} OR product_id LIKE ${rawTransferId + '%'})
                      AND remaining > 0
                    ORDER BY purchased_on ASC
                    LIMIT 1`
                const transferInventoryId = transferBatches.length > 0 ? transferBatches[0].id : null

                // Skip if no batch found — inventory_id is NOT NULL in the DB
                if (transferInventoryId) {
                    await prisma.$executeRaw`
            INSERT INTO wtc_order_customizations (id, order_id, item_id, position, inventory_id, name, retail)
            VALUES (
              ${randomUUID()}, ${orderId}, ${itemId},
              ${placement.slot || ''}, ${transferInventoryId},
              ${placement.transfer_name || ''}, ${placement.transfer_retail || 0}
            )`

                    await prisma.$executeRaw`
            UPDATE wtc_inventory SET remaining = remaining - 1 WHERE id = ${transferInventoryId}`
                }
            }
        }
    }

    console.log(`POS order ${orderId} created by ${body.salesperson_name}`)
    return { success: true, id: orderId }
})