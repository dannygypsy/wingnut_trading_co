export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id')
    if (!id) throw createError({ statusCode: 400, message: 'Missing ID' })

    const body = await readBody(event)

    const item = await prisma.inventory.update({
        where: { id },
        data: {
            product_id: body.product_id || null,
            category: body.category,
            name: body.name,
            size: body.size || null,
            full_name: body.full_name,
            type: body.type || null,
            cost: parseFloat(body.cost),
            retail: parseFloat(body.retail),
            purchased_on: new Date(body.purchased_on),
            num_purchased: parseInt(body.num_purchased),
            remaining: parseInt(body.remaining),
        }
    })

    return item
})