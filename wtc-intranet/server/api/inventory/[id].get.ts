export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id')
    if (!id) throw createError({ statusCode: 400, message: 'Missing ID' })

    const item = await prisma.inventory.findUnique({
        where: { id },
        select: {
            id: true,
            product_id: true,
            category: true,
            name: true,
            size: true,
            full_name: true,
            type: true,
            cost: true,
            retail: true,
            purchased_on: true,
            num_purchased: true,
            remaining: true,
        }
    })
    if (!item) throw createError({ statusCode: 404, message: 'Not found' })

    return {
        ...item,
        cost: parseFloat(item.cost.toString()),
        retail: parseFloat(item.retail.toString()),
        num_purchased: Number(item.num_purchased),
        remaining: Number(item.remaining),
    }
})